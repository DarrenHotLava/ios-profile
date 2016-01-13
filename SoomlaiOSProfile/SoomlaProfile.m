/*
 Copyright (C) 2012-2014 Soomla Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "SoomlaProfile.h"
#import "Reward.h"
#import "UserProfileUtils.h"
#import "ProfileEventHandling.h"
#import "UserProfileNotFoundException.h"
#import "UserProfileStorage.h"
#import "SoomlaUtils.h"
#import "Leaderboard.h"
#import "ProviderNotFoundException.h"
#import "IAuthProvider.h"
#import "ProviderManager.h"
#import "ISocialProvider.h"
#import "ConfirmationDialog.h"
#import "IGameServicesProvider.h"
#import "Score.h"

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import <KeyValueStorage.h>
#import <Reward.h>

#define SOOMLA_PROFILE_VERSION @"1.4.1"

#define DB_KEY_PREFIX @"soomla.profile"

// if using Unity social provider this is YES
BOOL UsingExternalProvider;

@interface SoomlaProfile () <SKStoreProductViewControllerDelegate>

@end


@implementation SoomlaProfile {
    ProviderManager *_providerManager;
    ConfirmationDialog *_confirmationDialog;
}

@synthesize initialized;

static NSString* TAG = @"SOOMLA SoomlaProfile";


+ (void)usingExternalProvider:(BOOL)isExternal {

    UsingExternalProvider = isExternal;
}

+ (BOOL)isUsingExternalProvider {
    return UsingExternalProvider;
}

+ (NSString*)getVersion {
    return SOOMLA_PROFILE_VERSION;
}

- (BOOL)initialize {
    return [self initialize:nil];
}

- (BOOL)initialize:(NSDictionary *)customParams {

    if (self.initialized) {
        LogDebug(TAG, @"SoomlaProfile already initialized.");
        return NO;
    }

    if (UsingExternalProvider) {
        _providerManager = [[ProviderManager alloc] init];
    }
    else {
        _providerManager = [[ProviderManager alloc] initWithProviderParameters:customParams];
    }

    self.initialized = YES;

    [ProfileEventHandling postProfileInitialized];

    [self settleAutoLogin];

    return YES;
}

- (void)setLoggedInForProvider:(Provider)provider toValue:(BOOL)loggedIn {
    NSString *key = [self getLoggedInStorageKeyForProvider:provider];
    if (loggedIn) {
        [KeyValueStorage setValue:@"true" forKey:key];
    } else {
        [KeyValueStorage deleteValueForKey:key];
    }
}

- (NSString *)getLoggedInStorageKeyForProvider:(Provider)provider {
    return [NSString stringWithFormat:@"%@.%@.%@", DB_KEY_PREFIX, [UserProfileUtils providerEnumToString:provider], @"loggedIn"];
}

- (BOOL)wasLoggedInWithProvider:(Provider)provider {
    return [[KeyValueStorage getValueForKey:[self getLoggedInStorageKeyForProvider:provider]] isEqualToString:@"true"];
}


- (void)settleAutoLogin {
    NSArray *authProviders = [_providerManager getAllAuthProviders];
    for (id<IAuthProvider> authProvider in authProviders) {
        Provider provider = [authProvider getProvider];
        if ([authProvider isAutoLogin]) {
            if ([self wasLoggedInWithProvider:provider]) {
                NSString *payload = @"";
                Reward *reward = nil;
                if ([authProvider isLoggedIn]) {
                    [self setLoggedInForProvider:provider toValue:NO];
                    [ProfileEventHandling postLoginStarted:provider withAutoLogin:YES andPayload:payload];
                    [authProvider getUserProfile:^(UserProfile *userProfile) {
                        [UserProfileStorage setUserProfile:userProfile];
                        [self setLoggedInForProvider:[authProvider getProvider] toValue:YES];
                        [ProfileEventHandling postLoginFinished:userProfile withAutoLogin:YES andPayload:payload];

                        if (reward) {
                            [reward give];
                        }
                    } fail:^(NSString *message) {
                        [ProfileEventHandling postLoginFailed:[authProvider getProvider] withMessage:message andAutoLogin:YES andPayload:payload];
                    }];
                } else {
                    [self loginWithProvider:provider andAutoLogin:YES andPayload:payload andReward:reward];
                }
            }
        }
    }
}

- (void)loginWithProvider:(Provider)provider {
    [self loginWithProvider:provider andPayload:@"" andReward:nil];
}

- (void)loginWithProvider:(Provider)provider andReward:(Reward *)reward {
    [self loginWithProvider:provider andPayload:@"" andReward:reward];
}

- (void)loginWithProvider:(Provider)provider andPayload:(NSString *)payload andReward:(Reward *)reward {
    [self loginWithProvider:provider andAutoLogin:NO andPayload:payload andReward:reward];
}

- (void)loginWithProvider:(Provider)provider andAutoLogin:(BOOL)autoLogin andPayload:(NSString *)payload andReward:(Reward *)reward {
    id<IAuthProvider> authProvider = [_providerManager getAuthProvider:provider];

    [self setLoggedInForProvider:provider toValue:NO];

    [ProfileEventHandling postLoginStarted:provider withAutoLogin:autoLogin andPayload:payload];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [authProvider login:^(Provider provider) {
            [authProvider getUserProfile:^(UserProfile *userProfile) {
                [UserProfileStorage setUserProfile:userProfile];
                [self setLoggedInForProvider:[authProvider getProvider] toValue:YES];
                [ProfileEventHandling postLoginFinished:userProfile withAutoLogin:autoLogin andPayload:payload];

                if (reward) {
                    [reward give];
                }
            } fail:^(NSString *message) {
                [ProfileEventHandling postLoginFailed:[authProvider getProvider] withMessage:message andAutoLogin:autoLogin andPayload:payload];
            }];
        } fail:^(NSString *message) {
            [ProfileEventHandling postLoginFailed:provider withMessage:message andAutoLogin:autoLogin andPayload:payload];
        } cancel:^{
            [ProfileEventHandling postLoginCancelled:provider withAutoLogin:autoLogin andPayload:payload];
        }];
    }];
}

- (void)logoutWithProvider:(Provider)provider {
    id<IAuthProvider> authProvider = [_providerManager getAuthProvider:provider];
    UserProfile* userProfile = nil;

    @try {
        userProfile = [self getStoredUserProfileWithProvider:provider];
    }
    @catch (NSException *ex) {
        LogError(TAG, ([NSString stringWithFormat:@"%@", [ex callStackSymbols]]));
    }

    // Perform logout process
    [self setLoggedInForProvider:provider toValue:NO];
    [ProfileEventHandling postLogoutStarted:provider];

    if (![self isLoggedInWithProvider:provider]) {
        if (userProfile) {
            [UserProfileStorage removeUserProfile:userProfile];
        }
        [ProfileEventHandling postLogoutFinished:provider];
        return;
    }

    [authProvider logout:^() {
        if (userProfile) {
            [UserProfileStorage removeUserProfile:userProfile];
        }
        [ProfileEventHandling postLogoutFinished:provider];
    } fail:^(NSString* message) {
        [ProfileEventHandling postLogoutFailed:provider withMessage:message];
    }];
}

- (void)logoutFromAllProviders {
    NSArray* providers = [UserProfileUtils availableProviders];
    for(NSNumber* providerNum in providers) {
        @try {
            [self logoutWithProvider:(Provider)[providerNum intValue]];
        }@catch (ProviderNotFoundException *exception) {
            // Skip
        }
    }
}

- (BOOL)isLoggedInWithProvider:(Provider)provider {
    id<IAuthProvider> authProvider = [_providerManager getAuthProvider:provider];
    return [authProvider isLoggedIn];
}

- (UserProfile *)getStoredUserProfileWithProvider:(Provider)provider {
    UserProfile* userProfile = [UserProfileStorage getUserProfile:provider];
    if (!userProfile) {
        @throw [[UserProfileNotFoundException alloc] init];
    }
    return userProfile;
}

- (NSArray *)getStoredUserProfiles {
    NSArray* providers = [UserProfileUtils availableProviders];
    NSMutableArray* userProfiles = [NSMutableArray array];
    for(NSNumber* providerNum in providers) {
        @try {
            UserProfile* userProfile = [UserProfileStorage getUserProfile:(Provider)[providerNum intValue]];
            if (userProfile) {
                [userProfiles addObject:userProfile];
            }
        }@catch (NSException *exception) {
            // Skip
        }
    }
    return userProfiles;
}

- (void)updateStatusWithProvider:(Provider)provider andStatus:(NSString *)status andPayload:(NSString *)payload andReward:(Reward *)reward andConfirmation:(bool)showConfirmation andCustomMessage:(NSString *)customMessage {
    if (showConfirmation) {

        NSString *messageToShow = customMessage ? customMessage : [NSString
                stringWithFormat:@"Are you sure you want to publish this message to %@: \"%@\"?",
                                 [UserProfileUtils providerEnumToString:provider],
                                 status
        ];

        _confirmationDialog = [ConfirmationDialog showWithTitle:@"Confirmation" withMessage:messageToShow withResult:^(bool result){
            _confirmationDialog = nil;
            if (result) {
                [self internalUpdateStatusWithProvider:provider andStatus:status andPayload:payload andReward:reward];
            }
        }];
    } else {
        [self internalUpdateStatusWithProvider:provider andStatus:status andPayload:payload andReward:reward];
    }
}

- (void)internalUpdateStatusWithProvider:(Provider)provider andStatus:(NSString *)status andPayload:(NSString *)payload andReward:(Reward *)reward {

    id<ISocialProvider> socialProvider = [_providerManager getSocialProvider:provider];

    // Perform update status process
    [ProfileEventHandling postSocialActionStarted:provider withType:UPDATE_STATUS withPayload:payload];
    [socialProvider updateStatus:status success:^{
        if (reward) {
            [reward give];
        }

        [ProfileEventHandling postSocialActionFinished:provider withType:UPDATE_STATUS withPayload:payload];
    } fail:^(NSString *message) {
        [ProfileEventHandling postSocialActionFailed:provider withType:UPDATE_STATUS withMessage:message withPayload:payload];
    }];
}

- (void)updateStatusWithProvider:(Provider)provider andStatus:(NSString *)status andPayload:(NSString *)payload andReward:(Reward *)reward {
    [self updateStatusWithProvider:provider andStatus:status andPayload:payload andReward:reward andConfirmation:false andCustomMessage:nil];
}

- (void)updateStatusWithProvider:(Provider)provider andStatus:(NSString *)status andReward:(Reward *)reward {
    [self updateStatusWithProvider:provider andStatus:status andPayload:@"" andReward:reward andConfirmation:false andCustomMessage:nil];
}

- (void)updateStatusWithProviderDialog:(Provider)provider andLink:(NSString *)link andPayload:(NSString *)payload andReward:(Reward *)reward {
    id<ISocialProvider> socialProvider = [_providerManager getSocialProvider:provider];

    // Perform update status process with dialog
    [ProfileEventHandling postSocialActionStarted:provider withType:UPDATE_STATUS withPayload:payload];
    [socialProvider updateStatusWithProviderDialog:link success:^{
        if (reward) {
            [reward give];
        }

        [ProfileEventHandling postSocialActionFinished:provider withType:UPDATE_STATUS withPayload:payload];
    } fail:^(NSString *message) {
        [ProfileEventHandling postSocialActionFailed:provider withType:UPDATE_STATUS withMessage:message withPayload:payload];
    }];
}

- (void)updateStatusWithProviderDialog:(Provider)provider andLink:(NSString *)link andReward:(Reward *)reward {
    [self updateStatusWithProviderDialog:provider andLink:link andPayload:@"" andReward:reward];
}

- (void)updateStoryWithProvider:(Provider)provider
                     andMessage:(NSString *)message
                        andName:(NSString *)name
                     andCaption:(NSString *)caption
                 andDescription:(NSString *)description
                        andLink:(NSString *)link
                     andPicture:(NSString *)picture
                     andPayload:(NSString *)payload
                      andReward:(Reward *)reward {

    [self updateStoryWithProvider:provider andMessage:message andName:name andCaption:caption andDescription:description andLink:link andPicture:picture andPayload:payload andReward:reward andShowConfirmation:false andCustomMessage:NULL];
}

- (void)updateStoryWithProvider:(Provider)provider andMessage:(NSString *)message andName:(NSString *)name andCaption:(NSString *)caption andDescription:(NSString *)description andLink:(NSString *)link andPicture:(NSString *)picture andPayload:(NSString *)payload andReward:(Reward *)reward andShowConfirmation:(bool)showConfirmation andCustomMessage:(NSString *)customMessage {

    if (showConfirmation) {
        NSString *messageToShow = customMessage ? customMessage :
                [NSString stringWithFormat:@"Are you sure you want to publish to %@?",
                                           [UserProfileUtils providerEnumToString:provider]];

        _confirmationDialog = [ConfirmationDialog showWithTitle:@"Confirmation" withMessage:messageToShow withResult:^(bool result) {_confirmationDialog = nil;
            if (result) {
                                                                 [self internalUpdateStoryWithProvider:provider
                                                                                            andMessage:message
                                                                                               andName:name
                                                                                            andCaption:caption
                                                                                        andDescription:description
                                                                                               andLink:link
                                                                                            andPicture:picture
                                                                                            andPayload:payload
                                                                                             andReward:reward];
            }
        }];
    } else {
        [self internalUpdateStoryWithProvider:provider
                                   andMessage:message
                                      andName:name
                                   andCaption:caption
                               andDescription:description
                                      andLink:link
                                   andPicture:picture
                                   andPayload:payload
                                    andReward:reward];
    }
}

- (void)internalUpdateStoryWithProvider:(Provider)provider andMessage:(NSString *)message andName:(NSString *)name andCaption:(NSString *)caption andDescription:(NSString *)description andLink:(NSString *)link andPicture:(NSString *)picture andPayload:(NSString *)payload andReward:(Reward *)reward {
    id<ISocialProvider> socialProvider = [_providerManager getSocialProvider:provider];

    // Perform update story process
    [ProfileEventHandling postSocialActionStarted:provider withType:UPDATE_STORY withPayload:payload];
    [socialProvider updateStoryWithMessage:message andName:name andCaption:caption andDescription:description andLink:link andPicture:picture success:^{
        if (reward) {
            [reward give];
        }

        [ProfileEventHandling postSocialActionFinished:provider withType:UPDATE_STORY withPayload:payload];
    } fail:^(NSString *message) {
        [ProfileEventHandling postSocialActionFailed:provider withType:UPDATE_STORY withMessage:message withPayload:payload];
    }];
}

- (void)updateStoryWithProvider:(Provider)provider
                     andMessage:(NSString *)message
                        andName:(NSString *)name
                     andCaption:(NSString *)caption
                 andDescription:(NSString *)description
                        andLink:(NSString *)link
                     andPicture:(NSString *)picture
                      andReward:(Reward *)reward {
    [self updateStoryWithProvider:provider andMessage:message andName:name andCaption:caption
                   andDescription:description andLink:link andPicture:picture andPayload:@"" andReward:reward];
}

- (void)updateStoryWithProviderDialog:(Provider)provider
                                  andName:(NSString *)name
                               andCaption:(NSString *)caption
                           andDescription:(NSString *)description
                                  andLink:(NSString *)link
                               andPicture:(NSString *)picture
                           andPayload:(NSString *)payload
                                andReward:(Reward *)reward {
    id<ISocialProvider> socialProvider = [_providerManager getSocialProvider:provider];

    // Perform update story process
    [ProfileEventHandling postSocialActionStarted:provider withType:UPDATE_STORY withPayload:payload];
    [socialProvider updateStoryWithMessageDialog:name andCaption:caption andDescription:description andLink:link andPicture:picture success:^{
        if (reward) {
            [reward give];
        }

        [ProfileEventHandling postSocialActionFinished:provider withType:UPDATE_STORY withPayload:payload];
    } fail:^(NSString *message) {
        [ProfileEventHandling postSocialActionFailed:provider withType:UPDATE_STORY withMessage:message withPayload:payload];
    }];
}

- (void)updateStoryWithProviderDialog:(Provider)provider
                              andName:(NSString *)name
                           andCaption:(NSString *)caption
                       andDescription:(NSString *)description
                              andLink:(NSString *)link
                           andPicture:(NSString *)picture
                            andReward:(Reward *)reward {
    [self updateStoryWithProviderDialog:provider andName:name andCaption:caption
                   andDescription:description andLink:link andPicture:picture andPayload:@"" andReward:reward];
}

- (void)uploadImageWithProvider:(Provider)provider
                     andMessage:(NSString *)message
                    andFilePath:(NSString *)filePath
                     andPayload:(NSString *)payload
                      andReward:(Reward *)reward {

    [self uploadImageWithProvider:provider andMessage:message andFilePath:filePath andPayload:payload andReward:reward andConfirmation:false andCustomMessage:nil];
}

- (void)uploadImageWithProvider:(Provider)provider
                     andMessage:(NSString *)message
               andImageFileName:(NSString *)imageFileName
                   andImageData:(NSData *)imageData
                     andPayload:(NSString *)payload
                      andReward:(Reward *)reward
                andConfirmation:(BOOL)confirmation
               andCustomMessage:(NSString *)customMessage {

    id<ISocialProvider> socialProvider = [_providerManager getSocialProvider:provider];

    // Perform upload image process
    [ProfileEventHandling postSocialActionStarted:provider withType:UPLOAD_IMAGE withPayload:payload];
    [socialProvider uploadImageWithMessage:message andImageFileName:imageFileName andImageData:imageData success:^{
        [ProfileEventHandling postSocialActionFinished:provider withType:UPLOAD_IMAGE withPayload:payload];
        if (reward) {
            [reward give];
        }
    } fail:^(NSString *message) {
        [ProfileEventHandling postSocialActionFailed:provider withType:UPLOAD_IMAGE withMessage:message withPayload:payload];
    }];
}
- (void)uploadImageWithProvider:(Provider)provider
                     andMessage:(NSString *)message
                    andFilePath:(NSString *)filePath
                     andPayload:(NSString *)payload
                      andReward:(Reward *)reward
                andConfirmation:(BOOL)showConfirmation
               andCustomMessage:(NSString *)customMessage {

    if (showConfirmation) {
        NSString *messageToShow = customMessage ? customMessage :
                [NSString stringWithFormat:@"Are you sure you want to upload image to %@?",
                                           [UserProfileUtils providerEnumToString:provider]];

        _confirmationDialog = [ConfirmationDialog showWithTitle:@"Confirmation" withMessage:messageToShow withResult:^(bool result) {
            _confirmationDialog = nil;
            if (result) {
                [self internalUploadImageWithProvider:provider
                                           andMessage:message
                                          andFilePath:filePath
                                           andPayload:payload
                                            andReward:reward];
            }
        }];
    } else {
        [self internalUploadImageWithProvider:provider
                                   andMessage:message
                                  andFilePath:filePath
                                   andPayload:payload
                                    andReward:reward];
    }
}

- (void)internalUploadImageWithProvider:(Provider)provider andMessage:(NSString *)message andFilePath:(NSString *)filePath andPayload:(NSString *)payload andReward:(Reward *)reward {

    id<ISocialProvider> socialProvider = [_providerManager getSocialProvider:provider];

    // Perform upload image process
    [ProfileEventHandling postSocialActionStarted:provider withType:UPLOAD_IMAGE withPayload:payload];
    [socialProvider uploadImageWithMessage:message andFilePath:filePath success:^{

        if (reward) {
            [reward give];
        }
        [ProfileEventHandling postSocialActionFinished:provider withType:UPLOAD_IMAGE withPayload:payload];
    } fail:^(NSString *message) {
        [ProfileEventHandling postSocialActionFailed:provider withType:UPLOAD_IMAGE withMessage:message withPayload:payload];
    }];
}

- (void)uploadImageWithProvider:(Provider)provider
                     andMessage:(NSString *)message
                    andFilePath:(NSString *)filePath
                      andReward:(Reward *)reward {
    [self uploadImageWithProvider:provider andMessage:message andFilePath:filePath andPayload:@"" andReward:reward];
}

- (void)uploadCurrentScreenshot:(Provider)provider title:(NSString *)title message:(NSString *)message {
    [self uploadCurrentScreenshot:provider title:title message:message payload:@"" andReward:nil];
}

+ (UIImage *)getScreenshot {
    UIGraphicsBeginImageContextWithOptions(((UIWindow *)[UIApplication sharedApplication].windows[0]).bounds.size, NO, [UIScreen mainScreen].scale);

    [((UIWindow *)[UIApplication sharedApplication].windows[0]) drawViewHierarchyInRect:((UIWindow *)[UIApplication sharedApplication].windows[0]).bounds
                                                                     afterScreenUpdates:YES];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)uploadCurrentScreenshot:(Provider)provider title:(NSString *)title message:(NSString *)message
                        payload:(NSString *)payload andReward:(Reward *)reward {
    UIImage *screenshot = [[self class] getScreenshot];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"current_screenshot.png"];

    [UIImagePNGRepresentation(screenshot) writeToFile:filePath atomically:YES];
    [self uploadImageWithProvider:provider andMessage:message andFilePath:filePath
                       andPayload:payload andReward:reward];
}

- (void)getContactsWithProvider:(Provider)provider andPayload:(NSString *)payload andReward:(Reward *)reward {
    [self getContactsWithProvider:provider andFromStart:false andPayload:payload andReward:reward];
}

- (void)getContactsWithProvider:(Provider)provider andFromStart:(bool)fromStart andPayload:(NSString *)payload andReward:(Reward *)reward {
    id<ISocialProvider> socialProvider = [_providerManager getSocialProvider:provider];

    // Perform get contacts process
    [ProfileEventHandling postGetContactsStarted:provider withType:GET_CONTACTS withFromStart:fromStart withPayload:payload];
    [socialProvider getContacts: fromStart success:^(NSArray *contacts, bool hasMore) {
        if (reward) {
            [reward give];
        }
        [ProfileEventHandling postGetContactsFinished:provider withType:GET_CONTACTS withContacts:contacts withPayload:payload withHasMore:hasMore];
    } fail:^(NSString *message) {

        [ProfileEventHandling postGetContactsFailed:provider withType:GET_CONTACTS withMessage:message withFromStart:fromStart withPayload:payload];
    }];
}

- (void)getContactsWithProvider:(Provider)provider andReward:(Reward *)reward {
    [self getContactsWithProvider:provider andPayload:@"" andReward:reward];
}

- (void)getFeedWithProvider:(Provider)provider andFromStart:(bool)fromStart andPayload:(NSString *)payload andReward:(Reward *)reward {
    id<ISocialProvider> socialProvider = [_providerManager getSocialProvider:provider];

    // Perform get feed process
    [ProfileEventHandling postGetFeedStarted:provider withType:GET_FEED withFromStart:fromStart withPayload:payload];

    [socialProvider getFeed: fromStart success:^(NSArray *feeds, bool hasMore) {
        if (reward) {
            [reward give];
        }
        [ProfileEventHandling postGetFeedFinished:provider withType:GET_FEED withContacts:feeds withPayload:payload withHasMore:hasMore];
    } fail:^(NSString *message) {
        [ProfileEventHandling postGetFeedFailed:provider withType:GET_FEED withMessage:message withFromStart:fromStart withPayload:payload];
    }];
}

- (void)getFeedWithProvider:(Provider)provider andReward:(Reward *)reward {
    [self getFeedWithProvider:provider andFromStart:NO andPayload:@"" andReward:reward];
}

- (void)inviteWithProvider:(Provider)provider inviteMessage:(NSString *)inviteMessage dialogTitle:(NSString *)dialogTitle
                   payload:(NSString *)payload andReward:(Reward *)reward {
    id<ISocialProvider> socialProvider = [_providerManager getSocialProvider:provider];

    SocialActionType currentActionType = INVITE;
    [ProfileEventHandling postInviteStarted:provider withType:currentActionType withPayload:payload];
    [socialProvider invite:inviteMessage dialogTitle:dialogTitle success:^(NSString *requestId, NSArray *invitedIds) {
        if (reward) {
            [reward give];
        }
        [ProfileEventHandling postInviteFinished:provider withType:currentActionType requestId:requestId
                                      invitedIds:invitedIds withPayload:payload];
    } fail:^(NSString *message) {
        [ProfileEventHandling postInviteFailed:provider withType:currentActionType withMessage:message withPayload:payload];
    } cancel:^{
        [ProfileEventHandling postInviteCancelled:provider withType:currentActionType withPayload:payload];
    }];
}

- (void)inviteWithProvider:(Provider)provider inviteMessage:(NSString *)inviteMessage andReward:(Reward *)reward {
    [self inviteWithProvider:provider inviteMessage:inviteMessage dialogTitle:nil payload:@"" andReward:nil];
}

- (void)like:(Provider)provider andPageId:(NSString *)pageId andReward:(Reward *)reward {
    id<ISocialProvider> socialProvider = [_providerManager getSocialProvider:provider];

    [socialProvider like:pageId];
    if (reward) {
        [reward give];
    }
}

- (void)openAppRatingPage {
    NSString *appID = [[NSBundle mainBundle] infoDictionary][@"iTunesAppID"];
    if (!appID) {
        [NSException raise:NSInvalidArgumentException format:@"To open app review page, add iTunesAppID at your Info.plist."];
    } else {
        SKStoreProductViewController *appPageController = [[SKStoreProductViewController alloc] init];
        [appPageController loadProductWithParameters:@{
                SKStoreProductParameterITunesItemIdentifier: appID
        } completionBlock:nil];
        appPageController.delegate = self;
        [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:appPageController
                                                                                       animated:YES completion:nil];
        [ProfileEventHandling postUserRating];
    }
}

-(void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)multiShareWithText:(NSString *)text andImageFilePath:(NSString *)imageFilePath {
    NSArray *postItems;
    if (imageFilePath && imageFilePath.length > 0) {
        UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
        postItems = @[text, image];
    } else {
        postItems = @[text];
    }

    UIActivityViewController *activityVC = [[UIActivityViewController alloc]
            initWithActivityItems:postItems
            applicationActivities:nil];

    UIViewController *rootViewController = [[UIApplication sharedApplication] keyWindow].rootViewController;
    if ( [rootViewController respondsToSelector:@selector(popoverPresentationController)] ) {
        activityVC.popoverPresentationController.sourceView = rootViewController.view;
    }
    [rootViewController presentViewController:activityVC animated:YES completion:nil];
}

- (void)getLeaderboardsWithProvider:(Provider)provider payload:(NSString *)payload andReward:(Reward *)reward {
    id<IGameServicesProvider> gsProvider = [_providerManager getGameServicesProvider:provider];

    [ProfileEventHandling postGetLeaderboardsStarted:provider withPayload:payload];
    [gsProvider getLeaderboardsWithSuccess:^(NSArray *leaderboards, BOOL hasMore) {
        if (reward) {
            [reward give];
        }
        [ProfileEventHandling postGetLeaderboardsFinished:provider withLeaderboardsList:leaderboards andPayload:payload];
    } fail:^(NSString *message) {
        [ProfileEventHandling postGetLeaderboardsFailed:provider withMessage:message andPayload:payload];
    }];
}

- (void)getScoresWithProvider:(Provider)provider forLeaderboard:(Leaderboard *)leaderboard payload:(NSString *)payload andReward:(Reward *)reward {
    [self getScoresWithProvider:provider forLeaderboard:leaderboard fromStart:NO payload:payload andReward:reward];
}

- (void)getScoresWithProvider:(Provider)provider forLeaderboard:(Leaderboard *)leaderboard fromStart:(BOOL)fromStart payload:(NSString *)payload andReward:(Reward *)reward {
    id<IGameServicesProvider> gsProvider = [_providerManager getGameServicesProvider:provider];

    [ProfileEventHandling postGetScoresStarted:provider forLeaderboard:leaderboard fromStart:fromStart withPayload:payload];
    [gsProvider getScoresFromLeaderboard:leaderboard.ID fromStart:fromStart withSuccess:^(NSArray *result, BOOL hasMore) {
        if (reward) {
            [reward give];
        }
        for (Score *sc in result) {
            sc.leaderboard = leaderboard;
        }
        [ProfileEventHandling postGetScoresFinished:provider forLeaderboard:leaderboard withScoresList:result hasMore:hasMore andPayload:payload];
    }                               fail:^(NSString *message) {
        [ProfileEventHandling postGetScoresFailed:provider forLeaderboard:leaderboard fromStart:fromStart withMessage:message andPayload:payload];
    }];
}

- (void)submitScoreForProvider:(Provider)provider score:(NSNumber *)score toLeaderboard:(Leaderboard *)leaderboard payload:(NSString *)payload andReward:(Reward *)reward {
    id<IGameServicesProvider> gsProvider = [_providerManager getGameServicesProvider:provider];

    [ProfileEventHandling postSubmitScoreStarted:provider toLeaderboard:leaderboard withPayload:payload];
    [gsProvider submitScore:score toLeaderboard:leaderboard.ID withSuccess:^(Score *newScore) {
        if (reward) {
            [reward give];
        }
        newScore.leaderboard = leaderboard;
        [ProfileEventHandling postSubmitScoreFinished:provider score:newScore toLeaderboard:leaderboard andPayload:payload];
    } fail:^(NSString *message) {
        [ProfileEventHandling postSubmitScoreFailed:provider toLeaderboard:leaderboard withMessage:message andPayload:payload];
    }];
}

- (void)showLeaderboardsForProvider:(Provider)provider andPayload:(NSString *)payload  {
    [self showLeaderboardsForProvider:provider payload:payload andReward:nil];
}

- (void)showLeaderboardsForProvider:(Provider)provider payload:(NSString *)payload andReward:(Reward *)reward {
    id<IGameServicesProvider> gsProvider = [_providerManager getGameServicesProvider:provider];

    [gsProvider showLeaderboards];
    if (reward) {
        [reward give];
    }
    [ProfileEventHandling postShowLeaderboards:provider withPayload:payload];
}

- (BOOL)tryHandleOpenURL:(Provider)provider openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[_providerManager getAuthProvider:provider] tryHandleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
}

- (BOOL)tryHandleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSArray *authProviders = [_providerManager getAllAuthProviders];
    for (id<IAuthProvider> authProvider in authProviders) {
        if ([authProvider tryHandleOpenURL:url sourceApplication:sourceApplication annotation:annotation]) {
            return YES;
        }
    }
    return NO;
}

// private

+ (SoomlaProfile*)getInstance {
    static SoomlaProfile* _instance = nil;

    @synchronized( self ) {
        if( _instance == nil ) {
            _instance = [[SoomlaProfile alloc ] init];
        }
    }

    return _instance;
}

@end

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

#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import "SoomlaFacebook.h"
#import "UserProfile.h"
#import "SoomlaUtils.h"

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCUnusedClassInspection"

#define DEFAULT_LOGIN_PERMISSIONS @[@"public_profile", @"email", @"user_birthday", @"user_photos", @"user_friends", @"user_posts"]
#define DEFAULT_PAGE_SIZE 20

@interface SoomlaFacebook () <FBSDKGameRequestDialogDelegate, FBSDKSharingDelegate>

@property(nonatomic) NSNumber *lastContactPage;
@property(nonatomic) NSNumber *lastFeedPage;
@property(nonatomic, strong) NSMutableArray *permissions;

@end


@implementation SoomlaFacebook {
    NSArray *_loginPermissions;
    BOOL _autoLogin;
    
    inviteSuccess _inviteSuccessHandler;
    inviteCancel _inviteCancelHandler;
    inviteFail _inviteFailHandler;

    socialActionSuccess _shareDialogSuccessHandler;
    socialActionFail _shareDialogFailHandler;
}

@synthesize loginSuccess, loginFail, loginCancel,
            logoutSuccess;

static NSString *TAG = @"SOOMLA SoomlaFacebook";

- (id)init {
    self = [super init];
    if (!self) return nil;

    LogDebug(TAG, @"addObserver kUnityOnOpenURL notification");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(innerHandleOpenURL:)
                                                 name:@"kUnityOnOpenURL"
                                               object:nil];

    return self;
}

- (void)dealloc {
    LogDebug(TAG, @"removeObserver kUnityOnOpenURL notification");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)innerHandleOpenURL:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"kUnityOnOpenURL"]) {
        LogDebug(TAG, @"Successfully received the kUnityOnOpenURL notification!");

        NSURL *url = [[notification userInfo] valueForKey:@"url"];
        NSString *sourceApplication = [[notification userInfo] valueForKey:@"sourceApplication"];
        id annotation = [[notification userInfo] valueForKey:@"annotation"];
        BOOL urlWasHandled  = [[FBSDKApplicationDelegate sharedInstance]
                application:[UIApplication sharedApplication]
                    openURL:url
          sourceApplication:sourceApplication
                 annotation:annotation];

        LogDebug(TAG,
                        ([NSString stringWithFormat:@"urlWasHandled: %@",
                                                    urlWasHandled ? @"True" : @"False"]));
    }
}

- (void)applyParams:(NSDictionary *)providerParams {
    _loginPermissions = DEFAULT_LOGIN_PERMISSIONS;
    if (providerParams) {
        _autoLogin = providerParams[@"autoLogin"] != nil ? [providerParams[@"autoLogin"] boolValue] : NO;
        if (providerParams[@"permissions"]) {
            _loginPermissions = [providerParams[@"permissions"] componentsSeparatedByString:@","];
        }
    } else {
        _autoLogin = NO;
    }
    // enable FBSDKProfile to automatically track the currentAccessToken
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
}

- (Provider)getProvider {
    return FACEBOOK;
}

- (void)login:(loginSuccess)success fail:(loginFail)fail cancel:(loginCancel)cancel {

    if (!self.isLoggedIn) {
        [[FBSDKLoginManager new] logInWithReadPermissions:_loginPermissions
                                       fromViewController:[[UIApplication sharedApplication].windows[0] rootViewController]
                                                  handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (error) {
                fail(error.localizedDescription);
            } else if (result.isCancelled) {
                cancel();
            } else {
                success(FACEBOOK);
            }
        }];
    } else {
        success(FACEBOOK);
    }
}

/*
 Asks for the user's public profile and birthday.
 First checks for the existence of the `public_profile` and `user_birthday` permissions
 If the permissions are not present, requests them
 If/once the permissions are present, makes the user info request
 */
- (void)getUserProfile:(userProfileSuccess)success fail:(userProfileFail)fail {
    LogDebug(TAG, @"Getting user profile");
    [self checkPermissions: @[@"public_profile", @"user_birthday", @"user_location", @"user_likes"] withWrite:NO success:^() {

        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me?fields=id,name,email,first_name,last_name,picture,birthday,languages,gender,location" parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                LogDebug(TAG, ([NSString stringWithFormat:@"user info: %@", result]));


                NSDictionary *extraDict = @{
                        @"access_token": [FBSDKAccessToken currentAccessToken].tokenString,
                        @"permissions": [FBSDKAccessToken currentAccessToken].permissions.allObjects,
                        @"expiration_date": @((NSInteger)[FBSDKAccessToken currentAccessToken].expirationDate)
                };
                UserProfile *userProfile = [[UserProfile alloc] initWithProvider:FACEBOOK
                                                                    andProfileId:result[@"id"]
                                                                     andUsername:result[@"email"]
                                                                        andEmail:result[@"email"]
                                                                    andFirstName:result[@"first_name"]
                                                                     andLastName:result[@"last_name"]
                                                                        andExtra:extraDict];

                userProfile.gender = result[@"gender"];
                userProfile.birthday = result[@"birthday"];
                userProfile.location = result[@"location"][@"name"];
                userProfile.language = result[@"languages"][0][@"name"];
                userProfile.avatarLink = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", result[@"id"]];

                success(userProfile);
            } else {
                LogError(TAG, error.description);
                fail(error.description);
            }
        }];

    } fail:^(NSString *errorMessage) {
        fail(errorMessage);
    }];
}


- (void)logout:(logoutSuccess)success fail:(logoutFail)fail {
    [[FBSDKLoginManager new] logOut];
    success();
}

/**
 Checks if the user is logged-in using the authentication provider
 
 @return YES if the user is already logged-in using the authentication provider, NO otherwise
 */
- (BOOL)isLoggedIn {
    return [FBSDKAccessToken currentAccessToken] != nil
            && [[FBSDKAccessToken currentAccessToken].expirationDate compare:[NSDate date]] == NSOrderedDescending;
}

- (BOOL)isAutoLogin {
    return _autoLogin;
}


- (BOOL)tryHandleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:[UIApplication sharedApplication]
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)updateStatus:(NSString *)status success:(socialActionSuccess)success fail:(socialActionFail)fail {
    LogDebug(TAG, @"Updating status");

    [self checkPermissions: @[@"publish_actions"] withWrite:YES success:^() {
        // NOTE: pre-filling fields associated with Facebook posts,
        // unless the user manually generated the content earlier in the workflow of your app,
        // can be against the Platform policies: https://developers.facebook.com/policy
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/feed" parameters:@{@"message" : status} HTTPMethod:@"POST"] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                // Status update posted successfully to Facebook
                success();
            } else {
                // An error occurred, we need to handle the error
                // See: https://developers.facebook.com/docs/ios/errors
                fail(error.description);
            }
        }];
    } fail:^(NSString *errorMessage) {
        fail(errorMessage);
    }];
}

- (void)updateStatusWithProviderDialog:(NSString *)link success:(socialActionSuccess)success fail:(socialActionFail)fail {
    LogDebug(TAG, @"Updating status");
    
    [self openDialog:link andName:nil andCaption:nil andDescription:nil andPicture:nil success:success fail:fail];
}

-(void) openDialog:(NSString *)link
           andName:(NSString *)name
        andCaption:(NSString *)caption
    andDescription:(NSString *)description
        andPicture:(NSString *)picture
           success:(socialActionSuccess)success
              fail:(socialActionFail)fail {
    [self checkPermissions:@[@"publish_actions"] withWrite:YES success:^{

        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        if (link) {
            content.contentURL = [NSURL URLWithString:link];
            if (description) {
                content.contentDescription = description;
            }
            if (picture) {
                content.imageURL = [NSURL URLWithString:picture];
            }
            if (caption) {
                content.contentTitle = caption;
            }
        }

        _shareDialogSuccessHandler = success;
        _shareDialogFailHandler = fail;

        [FBSDKShareDialog showFromViewController:[[UIApplication sharedApplication].windows[0] rootViewController]
                                     withContent:content
                                        delegate:self];
    } fail:^(NSString *errorMessage) {
        fail(errorMessage);
    }];
}

-(void)cleanDialogHandlers {
    _shareDialogSuccessHandler = nil;
    _shareDialogFailHandler = nil;
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    _shareDialogSuccessHandler();
    [self cleanDialogHandlers];
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    _shareDialogFailHandler(error.localizedDescription);
    [self cleanDialogHandlers];
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    _shareDialogFailHandler(@"User canceled story publishing.");
    [self cleanDialogHandlers];
}

- (void)updateStoryWithMessage:(NSString *)message
                       andName:(NSString *)name
                    andCaption:(NSString *)caption
                andDescription:(NSString *)description
                       andLink:(NSString *)link
                    andPicture:(NSString *)picture
                       success:(socialActionSuccess)success
                          fail:(socialActionFail)fail {

    [self checkPermissions: @[@"publish_actions"] withWrite:YES success:^() {

        // NOTE: pre-filling fields associated with Facebook posts,
        // unless the user manually generated the content earlier in the workflow of your app,
        // can be against the Platform policies: https://developers.facebook.com/policy

        // Put together the dialog parameters
        NSDictionary *params = @{
                @"message" : message,
                @"name" : name,
                @"caption" : caption,
                @"description" : description,
                @"link" : link,
                @"picture" : picture
        };

        // Make the request

        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/feed" parameters:params HTTPMethod:@"POST"] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                success();
            } else {
                fail(error.description);
            }
        }];
    } fail:^(NSString *errorMessage) {
        fail(errorMessage);
    }];
}

- (void)updateStoryWithMessageDialog:(NSString *)name
                          andCaption:(NSString *)caption
                      andDescription:(NSString *)description
                             andLink:(NSString *)link
                          andPicture:(NSString *)picture
                             success:(socialActionSuccess)success
                                fail:(socialActionFail)fail {
    LogDebug(TAG, @"Updating story");
    
    [self openDialog:link andName:name andCaption:caption andDescription:description andPicture:picture success:success fail:fail];
}

- (void)getContacts:(bool)fromStart success:(contactsActionSuccess)success fail:(contactsActionFail)fail {
//    NSLog(@"============================ getContacts ============================");

    int offset = DEFAULT_PAGE_SIZE * (fromStart ? 0 : (self.lastContactPage != nil ? [self.lastContactPage integerValue] : 0));
    self.lastContactPage = nil;

    [self checkPermissions: @[@"user_friends"] withWrite:NO success:^() {

        /* make the API call */
        NSDictionary *parameters = @{
            @"fields": @"id,email,first_name,last_name,gender,birthday,location",
            @"limit":  @(DEFAULT_PAGE_SIZE).stringValue,
            @"offset": @(offset).stringValue
        };
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/friends" parameters:parameters HTTPMethod:@"GET"] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (error) {
                // An error occurred, we need to handle the error
                // See: https://developers.facebook.com/docs/ios/errors
                LogError(TAG, ([NSString stringWithFormat:@"Get contacts error: %@", error.description]));
                fail(error.description);
            } else {
                // Success
                LogDebug(TAG, ([NSString stringWithFormat:@"Get contacts success: %@", result]));

                if (result[@"paging"][@"next"] != nil) {
                    self.lastContactPage = @(offset + 1);
                }

                NSArray *rawContacts = result[@"data"];
                NSMutableArray *contacts = [NSMutableArray array];

                for (NSDictionary *contactDict in rawContacts) {
                    UserProfile *contact = [[UserProfile alloc] initWithProvider:FACEBOOK
                                                                    andProfileId:contactDict[@"id"]
                                                                     andUsername:contactDict[@"email"]
                                                                        andEmail:contactDict[@"email"]
                                                                    andFirstName:contactDict[@"first_name"]
                                                                     andLastName:contactDict[@"last_name"]];
                    contact.gender = contactDict[@"gender"];
                    contact.birthday = contactDict[@"birthday"];
                    if (contactDict[@"location"]) {
                        contact.location = contactDict[@"location"][@"name"];
                    }
                    contact.avatarLink = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", contactDict[@"id"]];

                    [contacts addObject:contact];
                }

                success(contacts, self.lastContactPage != nil);
            }
        }];
    } fail:^(NSString *errorMessage) {
        fail(errorMessage);
    }];
}

- (void)getFeed:(bool)fromStart success:(feedsActionSuccess)success fail:(feedsActionFail)fail {
//    NSLog(@"============================ getFeed ============================");

    int offset = DEFAULT_PAGE_SIZE * (fromStart ? 0 : (self.lastFeedPage != nil ? [self.lastFeedPage integerValue] : 0));
    self.lastFeedPage = nil;

    [self checkPermissions: @[@"user_posts"] withWrite:NO success:^() {

        /* make the API call */
        NSDictionary *parameters = @{
                @"limit":  @(DEFAULT_PAGE_SIZE).stringValue,
                @"offset": @(offset).stringValue
        };
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/feed?fields=message" parameters:parameters HTTPMethod:@"GET"] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (error) {

                // An error occurred, we need to handle the error
                // See: https://developers.facebook.com/docs/ios/errors
                LogError(TAG, ([NSString stringWithFormat:@"Get feeds error: %@", error.description]));
                fail(error.description);
            } else {
                // Success
                if (result[@"paging"][@"next"] != nil) {
                    self.lastFeedPage = @(offset + 1);
                }
                LogDebug(TAG, ([NSString stringWithFormat:@"Get feeds success: %@", result]));
                NSMutableArray *feeds = [NSMutableArray array];
                NSArray *rawFeeds = result[@"data"];
                for (NSDictionary *dict in rawFeeds) {
                    NSString *str;
                    str = dict[@"message"];
                    if (str) {
                        [feeds addObject:str];
                    }
                }
                success(feeds, self.lastFeedPage != nil);
            }
        }];
    } fail:^(NSString *errorMessage) {
        fail(errorMessage);
    }];
}

- (void)invite:(NSString *)inviteMessage dialogTitle:(NSString *)dialogTitle success:(inviteSuccess)success fail:(inviteFail)fail cancel:(inviteCancel)cancel {
    _inviteSuccessHandler = success;
    _inviteFailHandler = fail;
    _inviteCancelHandler = cancel;
    
    FBSDKGameRequestDialog *dialog = [FBSDKGameRequestDialog new];
    FBSDKGameRequestContent *content = [FBSDKGameRequestContent new];
    content.title = dialogTitle;
    content.message = inviteMessage;
    
    dialog.content = content;
    dialog.delegate = self;
    [dialog show];
}


-(void)gameRequestDialog:(FBSDKGameRequestDialog *)gameRequestDialog didCompleteWithResults:(NSDictionary *)results {
    NSRegularExpression *invitedRegExp = [NSRegularExpression regularExpressionWithPattern:@"to\\[\\d\\]"
                                                                                   options:NSRegularExpressionUseUnicodeWordBoundaries
                                                                                     error:nil];
    NSString *requestId = results[@"request"];
    NSArray *invitedIds = [results.allValues objectsAtIndexes:[results.allValues indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL * stop) {
        NSString *relatedKey = [results allKeysForObject:obj][0];
        NSRange found = [invitedRegExp firstMatchInString:relatedKey options:0 range:NSMakeRange(0, relatedKey.length)].range;
        return found.location == 0 && found.length == relatedKey.length;
    }]];
    if (_inviteSuccessHandler) {
        _inviteSuccessHandler(requestId, invitedIds);
    }
}

-(void)gameRequestDialog:(FBSDKGameRequestDialog *)gameRequestDialog didFailWithError:(NSError *)error {
    if (_inviteFailHandler) {
        _inviteFailHandler(error.localizedDescription);
    }
}

-(void)gameRequestDialogDidCancel:(FBSDKGameRequestDialog *)gameRequestDialog {
    if (_inviteCancelHandler) {
        _inviteCancelHandler();
    }
}

- (void)uploadImageWithMessage:(NSString *)message
                   andFilePath:(NSString *)filePath
                       success:(socialActionSuccess)success
                          fail:(socialActionFail)fail {

    [self checkPermissions: @[@"publish_actions"] withWrite:YES success:^() {
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        // Put together the dialog parameters
        NSDictionary *params = @{
                @"picture": UIImagePNGRepresentation(image),
                @"message" : message
        };

        // Make the request
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/photos" parameters:params HTTPMethod:@"POST"] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                success();
            } else {
                fail(error.description);
            }
        }];
    } fail:^(NSString *errorMessage) {
        fail(errorMessage);
    }];

}

- (void)uploadImageWithMessage:(NSString *)message
              andImageFileName: (NSString *)fileName
                  andImageData: (NSData *)imageData
                       success:(socialActionSuccess)success
                          fail:(socialActionFail)fail{

    [self checkPermissions: @[@"publish_actions"] withWrite:YES success:^() {

        UIImage *image = [UIImage imageWithData:imageData];
        // Put together the dialog parameters
        NSDictionary *params = @{
                @"picture": UIImagePNGRepresentation(image),
                @"message" : message
        };

        // Make the request
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/photos" parameters:params HTTPMethod:@"POST"] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                success();
            } else {
                fail(error.description);
            }
        }];
     } fail:^(NSString *errorMessage) {
        fail(errorMessage);
    }];
}

- (void)like:(NSString *)pageId {

    NSURL *providerURL = nil;
    NSString *baseURL = @"fb://profile/";

    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:baseURL]] &&
            ([pageId rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location == NSNotFound))
    {
        providerURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseURL, pageId]];
    } else {
        providerURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.facebook.com/%@", pageId]];
    }

    [[UIApplication sharedApplication] openURL:providerURL];
}

/**
A helper method for requesting user data from Facebook.
*/

- (void)checkPermissions:(NSArray*)requestedPermissions withWrite:(BOOL)writePermissions success:(void (^)())success fail:(void(^)(NSString* message))fail {

    NSMutableArray *missedPermissions = [[NSMutableArray alloc] init];

    for (NSString *permission in requestedPermissions) {
        if (![[FBSDKAccessToken currentAccessToken] hasGranted:permission]) {
            [missedPermissions addObject:permission];
        }
    }

    if ([missedPermissions count] == 0) {
        success();
        return;
    }

    if (writePermissions) {
        // Ask for the missing publish permissions
        [[FBSDKLoginManager new] logInWithPublishPermissions:missedPermissions
                                          fromViewController:[[UIApplication sharedApplication].windows[0] rootViewController]
                                                     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (error) {
                [[self permissions] addObjectsFromArray:missedPermissions];
                fail(error.description);
            } else {
                success();
            }
        }];
    }
    else {
        // Ask for the missing read permissions
        [[FBSDKLoginManager new] logInWithReadPermissions:missedPermissions
                                       fromViewController:[[UIApplication sharedApplication].windows[0] rootViewController]
                                                  handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (error) {
                [[self permissions] addObjectsFromArray:missedPermissions];
                fail(error.description);
            } else {
                success();
            }
        }];
    }
}

@end

#pragma clang diagnostic pop
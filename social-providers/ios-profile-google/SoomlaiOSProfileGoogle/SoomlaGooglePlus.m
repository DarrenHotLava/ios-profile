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

#import "SoomlaGooglePlus.h"
#import "UserProfile.h"
#import "Leaderboard.h"
#import "SoomlaUtils.h"
#import "Leaderboard+GPGS.h"
#import "Score+GPGS.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import <gpg/GooglePlayGames.h>

@interface SoomlaGooglePlus () <GIDSignInDelegate, GIDSignInUIDelegate,  GPPShareDelegate, GPGStatusDelegate>

@property (nonatomic, strong) loginSuccess loginSuccess;
@property (nonatomic, strong) loginFail loginFail;
@property (nonatomic, strong) loginCancel loginCancel;
@property (nonatomic, strong) logoutSuccess logoutSuccess;
@property (nonatomic, strong) logoutFail logoutFail;

@property (strong, nonatomic) socialActionSuccess socialActionSuccess;
@property (strong, nonatomic) socialActionFail socialActionFail;

@property (nonatomic, strong) id lastPageToken;
@property (nonatomic, strong) id lastFeedPageToken;

@end

@implementation SoomlaGooglePlus {
    BOOL _autoLogin;
    BOOL _enableGameServices;

    NSMutableDictionary *_savedLeaderboards;
}

static NSString *TAG = @"SOOMLA SoomlaGooglePlus";
static NSString *GoogleKeychainName;

-(NSArray *)scopes {
    static NSArray *_scopes = nil;
    dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _scopes = @[
                kGTLAuthScopePlusLogin,
                kGTLAuthScopePlusUserinfoProfile
        ];
    });
    return _scopes;
}

- (id)init {
    self = [super init];
    
    if (!self)
        return nil;

    GoogleKeychainName = [NSString stringWithFormat:@"SoomlaGooglePlus: %@", [[NSBundle mainBundle] bundleIdentifier]];
    //subscribe to notification from unity via UnityAppController AppController_SendNotificationWithArg(kUnityOnOpenURL, notifData)
    LogDebug(TAG, @"addObserver kUnityOnOpenURL notification");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(innerHandleOpenURL:)
                                                 name:@"kUnityOnOpenURL"
                                               object:nil];
    _savedLeaderboards = [NSMutableDictionary new];
    
    return self;
}

- (void)applyParams:(NSDictionary *)providerParams{
    if (providerParams){
        _autoLogin = providerParams[@"autoLogin"] != nil ? [providerParams[@"autoLogin"] boolValue] : NO;
        _clientId = providerParams[@"clientId"];
        _enableGameServices = providerParams[@"enableGameServices"] != nil ? [providerParams[@"enableGameServices"] boolValue] : NO;
    } else {
        _autoLogin = NO;
    }
}

- (void)login:(loginSuccess)success fail:(loginFail)fail cancel:(loginCancel)cancel{
    LogDebug(TAG, @"Login");
    
    [self setLoginBlocks:success fail:fail cancel:cancel];
    
    NSString *authParamsCheckResult = [self checkAuthParams];
    
    if (authParamsCheckResult){
        fail([NSString stringWithFormat:@"Authentication params check failed: %@", authParamsCheckResult]);
        return;
    }

    [GIDSignIn sharedInstance].scopes = @[
            kGTLAuthScopePlusLogin,
            kGTLAuthScopePlusUserinfoProfile
    ];
    [GIDSignIn sharedInstance].clientID = self.clientId;
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].uiDelegate = self;
    [GPGManager sharedInstance].statusDelegate = self;
    if (_enableGameServices) {
        [[GPGManager sharedInstance] signInWithClientID:self.clientId silently:NO];
    } else {
        [[GIDSignIn sharedInstance] signIn];
    }
}

-(void)didFinishGamesSignInWithError:(NSError *)error {
    if (error == nil) {
        GTMOAuth2Authentication *auth = [[GTMOAuth2Authentication alloc] init];

        [auth setClientID:[GIDSignIn sharedInstance].clientID];
        [auth setClientSecret:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"GoogleClientSecret"]];
        [auth setUserEmail:[GIDSignIn sharedInstance].currentUser.profile.email];
        [auth setUserID:[GIDSignIn sharedInstance].currentUser.userID];
        [auth setAccessToken:[GIDSignIn sharedInstance].currentUser.authentication.accessToken];
        [auth setRefreshToken:[GIDSignIn sharedInstance].currentUser.authentication.refreshToken];
        [auth setExpirationDate: [GIDSignIn sharedInstance].currentUser.authentication.accessTokenExpirationDate];

        //did this dirty hack because Google can't do his work properly
        [[GPPSignIn sharedInstance] setValue:auth forKey:@"authentication"];

        self.loginSuccess([self getProvider]);
    } else {
        self.loginFail(error.localizedDescription);
    }
}

-(void)didFinishGamesSignOutWithError:(NSError *)error {
    if (error == nil) {
        [[GPPSignIn sharedInstance] setValue:nil forKey:@"authentication"];
        self.logoutSuccess();
    } else {
        self.logoutFail(error.localizedDescription);
    }
}

-(void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if (error == nil) {
        GTMOAuth2Authentication *auth = [[GTMOAuth2Authentication alloc] init];

        [auth setClientID:signIn.clientID];
        [auth setClientSecret:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"GoogleClientSecret"]];
        [auth setUserEmail:user.profile.email];
        [auth setUserID:user.userID];
        [auth setAccessToken:user.authentication.accessToken];
        [auth setRefreshToken:user.authentication.refreshToken];
        [auth setExpirationDate: user.authentication.accessTokenExpirationDate];

        //did this dirty hack because Google can't do his work properly
        [[GPPSignIn sharedInstance] setValue:auth forKey:@"authentication"];
        self.loginSuccess(GOOGLE);
    } else {
        if (error.code == kGIDSignInErrorCodeCanceled) {
            self.loginCancel();
        }
        self.loginFail([error localizedDescription]);
    }
}

-(void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if (error == nil) {
        [[GPPSignIn sharedInstance] setValue:nil forKey:@"authentication"];
        self.logoutSuccess();
    } else {
        self.logoutFail(error.localizedDescription);
    }
}

-(void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController {
    [([UIApplication sharedApplication].windows[0]).rootViewController presentViewController:viewController animated:YES completion:nil];
}

-(void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)getUserProfile:(userProfileSuccess)success fail:(userProfileFail)fail{
    LogDebug(TAG, @"getUserProfile");
    GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
    plusService.retryEnabled = YES;
    [plusService setAuthorizer:[GIDSignIn sharedInstance].currentUser.authentication.fetcherAuthorizer];
    
    GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
    [plusService executeQuery:query
            completionHandler:^(GTLServiceTicket *ticket,
                                GTLPlusPerson *person,
                                NSError *error) {
                if (error) {
                    LogError(TAG, @"Failed getting user profile");
                    fail([error localizedDescription]);
                } else {
                    UserProfile *userProfile = [self parseGoogleContact:person withExtraData:YES];
                    success(userProfile);
                }
            }];
}

- (void)logout:(logoutSuccess)success fail:(logoutFail)fail{
    LogDebug(TAG, @"logout");
    self.logoutSuccess = success;
    self.logoutFail = fail;
    if (_enableGameServices) {
        [[GPGManager sharedInstance] signOut];
    } else {
        [[GIDSignIn sharedInstance] disconnect];
    }
}

- (void)didDisconnectWithError:(NSError *)error {
    if (error) {
        self.logoutFail([error localizedDescription]);
    } else {
        [self clearLoginBlocks];
        self.logoutSuccess();
    }
}

- (BOOL)isLoggedIn{
    LogDebug(TAG, @"isLoggedIn");
    return ([GIDSignIn sharedInstance].currentUser != nil);
}

- (BOOL)isAutoLogin {
    return _autoLogin;
}

- (BOOL)tryHandleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[GIDSignIn sharedInstance] handleURL:url sourceApplication:sourceApplication annotation:annotation];
}

- (void)innerHandleOpenURL:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"kUnityOnOpenURL"]) {
        LogDebug(TAG, @"Successfully received the kUnityOnOpenURL notification!");

        NSURL *url = [[notification userInfo] valueForKey:@"url"];
        NSString *sourceApplication = [notification.userInfo valueForKey:@"sourceApplication"];
        id annotation = [[notification userInfo] valueForKey:@"annotation"];
        BOOL urlWasHandled = [self tryHandleOpenURL:url sourceApplication:sourceApplication annotation:annotation];

        LogDebug(TAG,
                ([NSString stringWithFormat:@"urlWasHandled: %@",
                                            urlWasHandled ? @"True" : @"False"]));
    }
}

- (void)updateStatus:(NSString *)status success:(socialActionSuccess)success fail:(socialActionFail)fail{
    LogDebug(TAG, @"updateStatus");
    [self setSocialActionBlocks:success fail:fail];
    id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
    [shareBuilder setPrefillText:status];
    [shareBuilder open];
}

- (void)updateStatusWithProviderDialog:(NSString *)link success:(socialActionSuccess)success fail:(socialActionFail)fail{
    LogDebug(TAG, @"updateStatus");
    [self setSocialActionBlocks:success fail:fail];
    id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
    [shareBuilder setURLToShare:[NSURL URLWithString:link]];
    [shareBuilder open];
}

- (void)updateStoryWithMessage:(NSString *)message
                       andName:(NSString *)name
                    andCaption:(NSString *)caption
                andDescription:(NSString *)description
                       andLink:(NSString *)link
                    andPicture:(NSString *)picture
                       success:(socialActionSuccess)success
                          fail:(socialActionFail)fail
{
    [self setSocialActionBlocks:success fail:fail];
    id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
    [shareBuilder setPrefillText:message];
    [shareBuilder setURLToShare:[NSURL URLWithString:link]];
    [shareBuilder open];
}

- (void)updateStoryWithMessageDialog:(NSString *)name
                          andCaption:(NSString *)caption
                      andDescription:(NSString *)description
                             andLink:(NSString *)link
                          andPicture:(NSString *)picture
                             success:(socialActionSuccess)success
                                fail:(socialActionFail)fail
{
    fail(@"updateStoryWithMessageDialog is not implemented");
}

- (void)uploadImageWithMessage:(NSString *)message
                   andFilePath:(NSString *)filePath
                       success:(socialActionSuccess)success
                          fail:(socialActionFail)fail
{
    LogDebug(TAG, @"uploadImage");
    [self setSocialActionBlocks:success fail:fail];
    [GPPShare sharedInstance].delegate = self;
    id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
    [shareBuilder setPrefillText:message];
    [shareBuilder attachImage:[UIImage imageWithContentsOfFile:filePath]];
    [shareBuilder open];
}

- (void)uploadImageWithMessage:(NSString *)message
              andImageFileName: (NSString *)fileName
                  andImageData: (NSData *)imageData
                       success:(socialActionSuccess)success
                          fail:(socialActionFail)fail{
    LogDebug(TAG, @"uploadImage");
    [self setSocialActionBlocks:success fail:fail];
    [GPPShare sharedInstance].delegate = self;
    id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];

    [shareBuilder setPrefillText:message];

    UIImage *image = [UIImage imageWithData:imageData];
    [shareBuilder attachImage:image];

    [shareBuilder open];
}

- (void)finishedSharingWithError:(NSError *)error {
    
    if (!error) {
        self.socialActionSuccess();
    } else if (error.code == kGPPErrorShareboxCanceled) {
        self.socialActionFail(@"Social Action Cancelled");
    } else {
        self.socialActionFail([NSString stringWithFormat:@"Social Action Failed (%@)", [error localizedDescription]]);
    }
    [self clearSocialActionBlocks];
}

- (void)getContacts:(bool)fromStart success:(contactsActionSuccess)success fail:(contactsActionFail)fail {
    LogDebug(TAG, @"getContacts");
    GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
    plusService.retryEnabled = YES;
    [plusService setAuthorizer:[GIDSignIn sharedInstance].currentUser.authentication.fetcherAuthorizer];
    
    GTLQueryPlus *query =
    [GTLQueryPlus queryForPeopleListWithUserId:@"me"
                                    collection:kGTLPlusCollectionVisible];

    NSString *pageToken = fromStart ? nil : self.lastPageToken;
    self.lastPageToken = nil;
    if (pageToken) {
        [query setPageToken: pageToken];
    }

    [plusService executeQuery:query
            completionHandler:^(GTLServiceTicket *ticket,
                                GTLPlusPeopleFeed *peopleFeed,
                                NSError *error) {

                self.lastPageToken = peopleFeed.nextPageToken;

                if (error) {
                    LogError(TAG, @"Failed getting contacts");
                    fail([error localizedDescription]);
                } else {

                    NSArray* rawContacts = peopleFeed.items;
                    
                    NSMutableArray *contacts = [NSMutableArray array];
                    
                    for (GTLPlusPerson *rawContact in rawContacts) {
                        UserProfile *contact = [self parseGoogleContact:rawContact];
                        
                        [contacts addObject:contact];
                    }
                    
                    success(contacts, peopleFeed.nextPageToken != nil);
                }
            }];
}

- (void)getFeed:(bool)fromFirst success:(feedsActionSuccess)success fail:(feedsActionFail)fail {
    LogDebug(TAG, @"getFeed");

    GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
    plusService.retryEnabled = YES;
    [plusService setAuthorizer:[GIDSignIn sharedInstance].currentUser.authentication.fetcherAuthorizer];

    GTLQueryPlus *query = [GTLQueryPlus queryForActivitiesListWithUserId:@"me" collection:kGTLPlusCollectionPublic];

    NSString *pageToken = fromFirst ? nil : self.lastFeedPageToken;
    self.lastFeedPageToken = nil;
    if (pageToken) {
        [query setPageToken:pageToken];
    }

    [plusService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLPlusActivityFeed * feed, NSError *error) {
        if (!error) {
            NSMutableArray *feedsResult = [NSMutableArray new];
            for (GTLPlusActivity *activity in feed.items) {
                NSString *stringToFeed = @"";
                if (activity.object && activity.object.content) {
                    stringToFeed = activity.object.content;
                }
                [feedsResult addObject:stringToFeed];
            }
            success(feedsResult, feed.nextPageToken != nil);
        } else {
            fail(error.localizedDescription);
        }
    }];
}

- (Provider)getProvider {
    return GOOGLE;
}

- (void)like:(NSString *)pageId{
    
    NSString *baseURL = @"gplus://plus.google.com/";

    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:baseURL]])
    {
        baseURL = @"https://plus.google.com/";
    }
    
    if ([pageId rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound)
    {
        pageId = [NSString stringWithFormat:@"+%@", pageId];
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseURL, pageId]]];
}

-(UserProfile *)parseGoogleContact:(GTLPlusPerson *)googleContact withExtraData:(BOOL)withExtraData {
    NSString* displayName = googleContact.displayName;
    NSString* firstName, *lastName;

    if (displayName)
    {
        NSArray *names = [displayName componentsSeparatedByString:@" "];
        if (names && ([names count] > 0)) {
            firstName = names[0];
            if ([names count] > 1) {
                lastName = names[1];
            }
        }
    }

    GTLPlusPersonEmailsItem *email = [googleContact.emails objectAtIndex:0];
    GTMOAuth2Authentication *auth = [GIDSignIn sharedInstance].currentUser.authentication.fetcherAuthorizer;
    NSDictionary *extraDict = nil;
    if (withExtraData) {
        extraDict = @{
                @"access_token": auth.accessToken,
                @"refresh_token": auth.refreshToken,
                @"expiration_date": @((NSInteger)auth.expirationDate.timeIntervalSince1970)
        };
    }

    UserProfile * profile =
            [[UserProfile alloc] initWithProvider:GOOGLE
                                     andProfileId:[self parseGoogleContactInfoString:googleContact.identifier]
                                      andUsername: @""
                                         andEmail:[self parseGoogleContactInfoString:[email value]]
                                     andFirstName:firstName
                                      andLastName:lastName
                                         andExtra:extraDict];

    profile.username = @"";
    profile.gender = [self parseGoogleContactInfoString:googleContact.gender];
    profile.birthday = [self parseGoogleContactInfoString:googleContact.birthday];
    profile.location = [self parseGoogleContactInfoString:googleContact.currentLocation];
    profile.avatarLink = [self parseGoogleContactInfoString:[googleContact.image url]];
    profile.language = [self parseGoogleContactInfoString:googleContact.language];

    return profile;
}

- (void)invite:(NSString *)inviteMessage dialogTitle:(NSString *)dialogTitle success:(inviteSuccess)success
          fail:(inviteFail)fail cancel:(inviteCancel)cancel {
    if (fail) {
        fail(@"Invitation isn't supported in Google+.");
    }
}

-(void)getLeaderboardsWithSuccess:(successWithArrayHandler)success fail:(failureHandler)fail {
    if (_enableGameServices) {
        [GPGLeaderboardMetadata allMetadataFromDataSource:GPGDataSourceNetwork completionHandler:^(NSArray *metadataArray, NSError *error) {
            if (error == nil) {
                NSMutableArray *result = [NSMutableArray new];
                for (GPGLeaderboardMetadata *metadata in metadataArray) {
                    Leaderboard *leaderboard = [[Leaderboard alloc] initWithLeaderboardMetadata:metadata];
                    if (leaderboard) {
                        [result addObject:leaderboard];
                    }
                }
                success(result, NO);
            } else {
                fail(error.localizedDescription);
            }
        }];
    } else {
        fail(@"To use GPGS features, please set `enableGameServices = YES` in Google provider initialization parameters.");
    }
}

-(void)getScoresFromLeaderboard:(NSString *)leaderboardId fromStart:(BOOL)fromStart withSuccess:(successWithArrayHandler)success fail:(failureHandler)fail {
    if (_enableGameServices) {
        GPGLeaderboard *currentLeaderboard;
        if (fromStart || (currentLeaderboard = _savedLeaderboards[leaderboardId]) == nil) {
            currentLeaderboard = [GPGLeaderboard leaderboardWithId:leaderboardId];
            currentLeaderboard.timeScope = GPGLeaderboardTimeScopeAllTime;
        }
        [currentLeaderboard loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error) {
            if (error == nil) {
                NSMutableArray *result = [NSMutableArray new];
                for (GPGScore *gpgScore in scores) {
                    Score *score = [[Score alloc] initWithGooglePlayScore:gpgScore];
                    if (score) {
                        [result addObject:score];
                    }
                }
                _savedLeaderboards[leaderboardId] = currentLeaderboard;
                success(result, currentLeaderboard.hasNextPage);
            } else {
                fail(error.localizedDescription);
            }
        }];
    } else {
        fail(@"To use GPGS features, please set `enableGameServices = YES` in Google provider initialization parameters.");
    }
}

-(void)submitScore:(NSNumber *)scoreValue toLeaderboard:(NSString *)leaderboardId withSuccess:(reportScoreSuccessHandler)success fail:(failureHandler)fail {
    if (_enableGameServices) {
        GPGScore *score = [[GPGScore alloc] initWithLeaderboardId:leaderboardId];
        score.value = [scoreValue longLongValue];
        [score submitScoreWithCompletionHandler: ^(GPGScoreReport *report, NSError *error) {
            if (error == nil) {
                [GPGPlayer localPlayerWithCompletionHandler:^(GPGPlayer *player, NSError *error) {
                    if (error == nil) {
                        success([[Score alloc] initWithGooglePlayScore:report.highScoreForLocalPlayerAllTime andPlayer:player]);
                    } else {
                        fail(error.localizedDescription);
                    }
                }];
            } else {
                fail(error.localizedDescription);
            }
        }];
    } else {
        fail(@"To use GPGS features, please set `enableGameServices = YES` in Google provider initialization parameters.");
    }
}

-(void)showLeaderboards {
    if (_enableGameServices) {
        [[GPGLauncherController sharedInstance] presentLeaderboardList];
    } else {
        [SoomlaUtils LogError:TAG
                  withMessage:@"To use GPGS features, please set `enableGameServices = YES` in Google provider initialization parameters."];
    }
}

-(UserProfile *) parseGoogleContact: (GTLPlusPerson *)googleContact{
    return [self parseGoogleContact:googleContact withExtraData:NO];
}

- (NSString *)parseGoogleContactInfoString:(NSString * )orig{
    return (orig) ? orig : @"";
}

-(void)setLoginBlocks:(loginSuccess)success fail:(loginFail)fail cancel:(loginCancel)cancel{
    self.loginSuccess = success;
    self.loginFail = fail;
    self.loginCancel = cancel;
}

-(void)setSocialActionBlocks:(socialActionSuccess)success fail:(socialActionFail)fail{
    self.socialActionSuccess = success;
    self.socialActionFail = fail;
}

- (void)clearLoginBlocks {
    self.loginSuccess = nil;
    self.loginFail = nil;
    self.loginCancel = nil;
}

- (void)clearSocialActionBlocks {
    self.socialActionSuccess = nil;
    self.socialActionFail = nil;
}

- (NSString *)checkAuthParams{
    if (!_clientId)
        return @"Missing client id";
    return nil;
}

- (void)dealloc {
    LogDebug(TAG, @"removeObserver kUnityOnOpenURL notification");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

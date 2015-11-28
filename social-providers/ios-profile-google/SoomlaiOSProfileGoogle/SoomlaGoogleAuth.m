/*
 Copyright (C) 2012-2015 Soomla Inc.

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


#import "SoomlaGoogleAuth.h"

#import <objc/runtime.h>
#import <objc/message.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GoogleSignIn/GoogleSignIn.h>

#import "SoomlaProfile.h"
#import "UserProfile.h"
#import "SoomlaUtils.h"

@interface SoomlaGoogleAuth () <GIDSignInDelegate, GIDSignInUIDelegate>

@property (nonatomic, strong) loginSuccess loginSuccess;
@property (nonatomic, strong) loginFail loginFail;
@property (nonatomic, strong) loginCancel loginCancel;
@property (nonatomic, strong) logoutSuccess logoutSuccess;
@property (nonatomic, strong) logoutFail logoutFail;

@end


@implementation SoomlaGoogleAuth {
    BOOL _autoLogin;
}

static NSString *TAG = @"SOOMLA SoomlaGooglePlus";
static NSString *GoogleKeychainName;

- (Provider)getProvider {
    return GOOGLE;
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
    return self;
}

- (void)applyParams:(NSDictionary *)providerParams{
    if (providerParams){
        _autoLogin = providerParams[@"autoLogin"] != nil ? [providerParams[@"autoLogin"] boolValue] : NO;
        _clientId = providerParams[@"clientId"];
    } else {
        _autoLogin = NO;
    }
    [GIDSignIn sharedInstance].clientID = self.clientId;
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
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].uiDelegate = self;
    [[GIDSignIn sharedInstance] signIn];
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

-(UserProfile *) parseGoogleContact: (GTLPlusPerson *)googleContact {
    return [self parseGoogleContact:googleContact withExtraData:NO];
}

-(UserProfile *)parseGoogleContact:(GTLPlusPerson *)googleContact withExtraData:(BOOL)withExtraData {
    NSString* displayName = googleContact.displayName;
    NSString* firstName, *lastName;

    if (displayName)
    {
        NSArray *names = (NSArray *)[displayName componentsSeparatedByString:@" "];
        if (names && ([names count] > 0)) {
            firstName = names[0];
            if ([names count] > 1) {
                lastName = names[1];
            }
        }
    }

    GTLPlusPersonEmailsItem *email = googleContact.emails[0];
    GIDAuthentication *auth = [GIDSignIn sharedInstance].currentUser.authentication;
    NSDictionary *extraDict = nil;
    if (withExtraData) {
        extraDict = @{
                @"access_token": auth.accessToken,
                @"refresh_token": auth.refreshToken,
                @"expiration_date": @((NSInteger)auth.accessTokenExpirationDate.timeIntervalSince1970)
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

- (NSString *)parseGoogleContactInfoString:(NSString * )orig {
    return (orig) ? orig : @"";
}

- (void)logout:(logoutSuccess)success fail:(logoutFail)fail {
    LogDebug(TAG, @"logout");
    self.logoutSuccess = success;
    self.logoutFail = fail;
    [[GIDSignIn sharedInstance] disconnect];
    self.logoutSuccess();
}

- (BOOL)isLoggedIn {
    LogDebug(TAG, @"isLoggedIn");
    return [GIDSignIn sharedInstance].currentUser != nil;
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

- (NSString *)checkAuthParams {
    if (!self.clientId)
        return @"Missing client id";
    return nil;
}

-(void)setLoginBlocks:(loginSuccess)success fail:(loginFail)fail cancel:(loginCancel)cancel {
    self.loginSuccess = success;
    self.loginFail = fail;
    self.loginCancel = cancel;
}

- (void)clearLoginBlocks {
    self.loginSuccess = nil;
    self.loginFail = nil;
    self.loginCancel = nil;
}

- (void)dealloc {

    LogDebug(TAG, @"removeObserver kUnityOnOpenURL notification");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
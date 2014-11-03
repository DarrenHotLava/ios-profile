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

#import <UIKit/UIKit.h>

#import "STTwitterOS.h"
#import "STTwitterOAuth.h"

#import "SoomlaTwitter.h"
#import "UserProfile.h"
#import "UserProfileStorage.h"

#import "SoomlaUtils.h"
#import "KeyValueStorage.h"

NSString *const TWITTER_OAUTH_TOKEN     = @"oauth.token";
NSString *const TWITTER_OAUTH_SECRET    = @"oauth.secret";

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCUnusedClassInspection"

// Private properties

@interface SoomlaTwitter ()

@property (strong, nonatomic) STTwitterAPI *twitter;

@end

@implementation SoomlaTwitter

@synthesize loginSuccess, loginFail, loginCancel,
            logoutSuccess;

static SoomlaTwitter *instance;

static NSString* DB_KEY_PREFIX  = @"soomla.profile.twitter.";
static NSString *TAG            = @"SOOMLA SoomlaTwitter";

- (id)init {
    self = [super init];
    if (!self) return nil;
    
    _consumerKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SoomlaTwitterConsumerKey"];
    _consumerSecret = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SoomlaTwitterConsumerSecret"];
    
    if ([self isEmptyString:self.consumerKey] || [self isEmptyString:self.consumerSecret]) {
        LogDebug(TAG, @"Either consumer key or consumer secret were not provided in plist, falling back to native only");
        webAvailable = NO;
    }
    else {
        webAvailable = YES;
    }

//    LogDebug(TAG, @"addObserver kUnityOnOpenURL notification");
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(innerHandleOpenURL:)
//                                                 name:@"kUnityOnOpenURL"
//                                               object:nil];
    
    @synchronized( self ) {
        if( instance == nil ) {
            instance = self;
        }
    }

    return self;
}

- (void)dealloc {
//    LogDebug(TAG, @"removeObserver kUnityOnOpenURL notification");
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//- (void)innerHandleOpenURL:(NSNotification *)notification {
//    // TODO: Check it
//    if ([[notification name] isEqualToString:@"kUnityOnOpenURL"]) {
//        LogDebug(TAG, @"Successfully received the kUnityOnOpenURL notification!");
//
//        NSURL *url = [[notification userInfo] valueForKey:@"url"];
//        NSString *sourceApplication = [[notification userInfo] valueForKey:@"sourceApplication"];
////        id annotation = [[notification userInfo] valueForKey:@"annotation"];
//        BOOL urlWasHandled = [FBAppCall handleOpenURL:url
//                                    sourceApplication:sourceApplication
//                                      fallbackHandler:^(FBAppCall *call) {
//                    LogDebug(TAG, ([NSString stringWithFormat:@"Unhandled deep link: %@", url]));
//                    // Here goes the code to handle the links
//                    // Use the links to show a relevant view of your app to the user
//                }];
//
//        LogDebug(TAG,
//                        ([NSString stringWithFormat:@"urlWasHandled: %@",
//                                                    urlWasHandled ? @"True" : @"False"]));
//    }
//}

- (Provider)getProvider {
    return TWITTER;
}

- (void)login:(loginSuccess)success fail:(loginFail)fail cancel:(loginCancel)cancel {
    LogDebug(TAG, @"Login started...");
    
    if (webOnly) {
        [self loginWithWeb:success fail:fail cancel:cancel];
    }
    else {
        self.twitter = [STTwitterAPI twitterAPIOSWithFirstAccount];
        
        [_twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
            success([self getProvider]);
        } errorBlock:^(NSError *error) {
            if (error.code == STTwitterOSUserDeniedAccessToTheirAccounts) {
                LogError(TAG, @"User denied access");
                fail([NSString stringWithFormat:@"%ld: %@", (long)error.code, error.localizedDescription]);
            }
            else {
                LogDebug(TAG, @"Unable to natively login to Twitter trying via web");
                [self loginWithWeb:success fail:fail cancel:cancel];
            }
        }];
    }
}

- (void)loginWithWeb:(loginSuccess)success fail:(loginFail)fail cancel:(loginCancel)cancel {
    
    if (!webAvailable) {
        return;
    }
    
    if ([self tryLoginFromDB:success fail:fail cancel:cancel]) {
        return;
    }
    
    self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:self.consumerKey
                                                 consumerSecret:self.consumerSecret];
    
    [_twitter postTokenRequest:^(NSURL *url, NSString *oauthToken) {
        self.loginSuccess = success;
        self.loginFail = fail;
        self.loginCancel = cancel;
        [[UIApplication sharedApplication] openURL:url];
    } authenticateInsteadOfAuthorize:NO
                    forceLogin:@(YES)
                    screenName:nil
                 oauthCallback:[NSString stringWithFormat:@"%@://twitter_access_tokens/", [self getURLScheme]]
                    errorBlock:^(NSError *error) {
                        LogError(TAG, @"Unable to login via web");
                        fail([NSString stringWithFormat:@"%ld: %@", (long)error.code, error.localizedDescription]);
                    }];
}

- (BOOL)tryLoginFromDB:(loginSuccess)success fail:(loginFail)fail cancel:(loginCancel)cancel {
    NSString *oauthToken = [KeyValueStorage getValueForKey:[self getTwitterStorageKey:TWITTER_OAUTH_TOKEN]];
    NSString *oauthSecret = [KeyValueStorage getValueForKey:[self getTwitterStorageKey:TWITTER_OAUTH_SECRET]];
    
    if ([self isEmptyString:oauthToken] || [self isEmptyString:oauthSecret]) {
        return NO;
    }
    
    self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:_consumerKey consumerSecret:_consumerSecret
                                                     oauthToken:oauthToken oauthTokenSecret:oauthSecret];
    
    [self.twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
        success([self getProvider]);
    } errorBlock:^(NSError *error) {
        // Something's wrong with my oauth tokens, retry login from web
        [KeyValueStorage deleteValueForKey:[self getTwitterStorageKey:TWITTER_OAUTH_TOKEN]];
        [KeyValueStorage deleteValueForKey:[self getTwitterStorageKey:TWITTER_OAUTH_SECRET]];
        [self loginWithWeb:success fail:fail cancel:cancel];
    }];
    
    return YES;
}

- (NSString *) getURLScheme {
    return [[NSString stringWithFormat:@"tw%@", self.consumerKey] lowercaseString];
}

- (void) applyOauthTokens:(NSString *)token andVerifier:(NSString *)verifier {
    [_twitter postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
        
        [KeyValueStorage setValue:oauthToken forKey:[self getTwitterStorageKey:TWITTER_OAUTH_TOKEN]];
        [KeyValueStorage setValue:oauthTokenSecret forKey:[self getTwitterStorageKey:TWITTER_OAUTH_SECRET]];
        
        self.loginSuccess([self getProvider]);
        
        [self clearLoginBlocks];
    } errorBlock:^(NSError *error) {
        LogError(TAG, @"Unable to login via web");
        self.loginFail([NSString stringWithFormat:@"%ld: %@", (long)error.code, error.localizedDescription]);
    }];
}

- (void)getUserProfile:(userProfileSuccess)success fail:(userProfileFail)fail {
}

- (void)logout:(logoutSuccess)success fail:(logoutFail)fail {
}

- (BOOL)isLoggedIn {
    return NO;
}

- (void)updateStatus:(NSString *)status success:(socialActionSuccess)success fail:(socialActionFail)fail {

}

- (void)updateStatusWithProviderDialog:(NSString *)link success:(socialActionSuccess)success fail:(socialActionFail)fail {

}

-(void) openDialog:(NSString *)link
           andName:(NSString *)name
        andCaption:(NSString *)caption
    andDescription:(NSString *)description
        andPicture:(NSString *)picture
           success:(socialActionSuccess)success
              fail:(socialActionFail)fail {

}

- (void)updateStoryWithMessage:(NSString *)message
                       andName:(NSString *)name
                    andCaption:(NSString *)caption
                andDescription:(NSString *)description
                       andLink:(NSString *)link
                    andPicture:(NSString *)picture
                       success:(socialActionSuccess)success
                          fail:(socialActionFail)fail {

}

- (void)updateStoryWithMessageDialog:(NSString *)name
                          andCaption:(NSString *)caption
                      andDescription:(NSString *)description
                             andLink:(NSString *)link
                          andPicture:(NSString *)picture
                             success:(socialActionSuccess)success
                                fail:(socialActionFail)fail {
}

- (void)getContacts:(contactsActionSuccess)success fail:(contactsActionFail)fail {

}

- (void)getFeed:(feedsActionSuccess)success fail:(feedsActionFail)fail {

}

- (void)uploadImageWithMessage:(NSString *)message
                   andFilePath:(NSString *)filePath
                       success:(socialActionSuccess)success
                          fail:(socialActionFail)fail {

}

- (void)like:(NSString *)pageName {

}

+ (SoomlaTwitter *) getInstance {
    return instance;
}

//
// Private Methods
//


/*
 Helper methods for clearing callback blocks
 */

- (void)clearLoginBlocks {
    self.loginSuccess = nil;
    self.loginFail = nil;
    self.loginCancel = nil;
}

- (BOOL) isEmptyString:(NSString *)target {
    return !target || ([target length] == 0);
}

- (NSString *) getTwitterStorageKey:(NSString *)postfix {
    return [NSString stringWithFormat:@"%@%@", DB_KEY_PREFIX, postfix];
}

@end

#pragma clang diagnostic pop
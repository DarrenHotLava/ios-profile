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

#import "AuthController.h"
#import "UserProfile.h"
#import "UserProfileStorage.h"
#import "UserProfileNotFoundException.h"
#import "ProfileEventHandling.h"
#import "IAuthProvider.h"
#import "Reward.h"
#import "SoomlaUtils.h"
#import "KeyValueStorage.h"

@implementation AuthController {
}

static NSString* DB_KEY_PREFIX  = @"soomla.profile.common";

static NSString* TAG = @"SOOMLA AuthController";

- (id)initWithParameters:(NSDictionary *)providerParams {
    if (self = [super init]) {

        // TODO: Check if providerPkgPrefix can be omitted completely in iOS
        if (![self loadProvidersWithProtocol:@protocol(IAuthProvider) andProviderParams:providerParams]) {
            NSString* msg = @"You don't have a IAuthProvider service attached. \
                            Decide which IAuthProvider you want, and add its static libraries \
                            and headers to the target's search path.";
            LogDebug(TAG, msg);
        } else {
            
        }
    }

    return self;
}

- (id)initWithoutLoadingProviders {
    if (self = [super init]) {
    }
    return self;
}

- (void)loginWithProvider:(Provider)provider andPayload:(NSString *)payload andReward:(Reward *)reward {
    
    
    id<IAuthProvider> authProvider = (id<IAuthProvider>)[self getProvider:provider];

    [self setLoggedInForProvider:provider toValue:NO];

    [ProfileEventHandling postLoginStarted:provider withPayload:payload];
    
    // Perform login process
    // TODO: Check if need to change any nonatomic properties
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [authProvider login:^(Provider provider) {
            [self afterLoginWithAuthProvider:authProvider withReward:reward withPayload:payload];
        } fail:^(NSString *message) {
            [ProfileEventHandling postLoginFailed:provider withMessage:message withPayload:payload];
        } cancel:^{
            [ProfileEventHandling postLoginCancelled:provider withPayload:payload];
        }];
    }];
}

- (void)logoutWithProvider:(Provider)provider {
    
    id<IAuthProvider> authProvider = (id<IAuthProvider>)[self getProvider:provider];
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
    [authProvider logout:^() {
        if (userProfile) {
            [UserProfileStorage removeUserProfile:userProfile];
            [ProfileEventHandling postLogoutFinished:provider];
        }
    }
    fail:^(NSString* message) {
        [ProfileEventHandling postLogoutFailed:provider withMessage:message];
    }];
}

- (BOOL)isLoggedInWithProvider:(Provider)provider {
    id<IAuthProvider> authProvider = (id<IAuthProvider>)[self getProvider:provider];
    return [authProvider isLoggedIn];
}

- (UserProfile *)getStoredUserProfileWithProvider:(Provider)provider {
    UserProfile* userProfile = [UserProfileStorage getUserProfile:provider];
    if (!userProfile) {
        @throw [[UserProfileNotFoundException alloc] init];
    }
    return userProfile;
}

- (BOOL)tryHandleOpenURL:(Provider)provider openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    id<IAuthProvider> authProvider = (id<IAuthProvider>)[self getProvider:provider];
    return [authProvider tryHandleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
}

- (BOOL)tryHandleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    for(id key in self.providers) {
        id<IAuthProvider> value = self.providers[key];
        if ([value tryHandleOpenURL:url sourceApplication:sourceApplication annotation:annotation]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)setLoggedInForProvider:(Provider)provider toValue:(BOOL)loggedIn {
    NSString *key = [self getLoggedInStorageKeyForProvider:provider];
    if (loggedIn) {
        [KeyValueStorage setValue:@"true" forKey:key];
    } else {
        [KeyValueStorage deleteValueForKey:key];
    }
}

- (BOOL)wasLoggedInWithProvider:(Provider)provider {
    return [@"true" isEqualToString:[KeyValueStorage getValueForKey: [self getLoggedInStorageKeyForProvider:provider]]];
}

- (NSString *)getLoggedInStorageKeyForProvider:(Provider)provider {
    return [NSString stringWithFormat:@"%@.%@", DB_KEY_PREFIX, [UserProfileUtils providerEnumToString:provider]];
}

- (void)performAutoLogin {
    for (id key in self.providers) {
        id<IAuthProvider> authProvider = self.providers[key];
        Provider provider = [authProvider getProvider];
        if ([self wasLoggedInWithProvider:provider]) {
            NSString *payload = @"";
            Reward *reward = nil;
            if ([authProvider isLoggedIn]) {
                [self setLoggedInForProvider:provider toValue:NO];
                [ProfileEventHandling postLoginStarted:provider withPayload:payload];
                [self afterLoginWithAuthProvider:authProvider withReward:nil withPayload:payload];
            } else {
                [self loginWithProvider:provider andPayload:payload andReward:reward];
            }
        }
    }
 }

- (void)afterLoginWithAuthProvider:(id <IAuthProvider>)authProvider withReward:(Reward *)reward withPayload:(NSString *)payload {
    [authProvider getUserProfile:^(UserProfile *userProfile) {
        [UserProfileStorage setUserProfile:userProfile];
        if (reward) {
            [reward give];
        }

        [self setLoggedInForProvider:[authProvider getProvider] toValue:YES];
        [ProfileEventHandling postLoginFinished:userProfile withPayload:payload];
    } fail:^(NSString *message) {
        [ProfileEventHandling postLoginFailed:[authProvider getProvider] withMessage:message withPayload:payload];
    }];
}

@end

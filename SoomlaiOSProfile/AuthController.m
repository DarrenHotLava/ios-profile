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
#import "UserProfileEventHandling.h"
#import "IAuthProvider.h"
#import "Reward.h"
#import "SoomlaUtils.h"

@implementation AuthController

static NSString* TAG = @"SOOMLA AuthController";

- (id)init {
    if (self = [super init]) {

        // TODO: Check if providerPkgPrefix can be omitted completely in iOS
        if (![self loadProvidersWithProtocol:@protocol(IAuthProvider)]) {
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

- (void)loginWithProvider:(enum Provider)provider andReward:(Reward *)reward {
    
    
    id<IAuthProvider> authProvider = (id<IAuthProvider>)[self getProvider:provider];
    [UserProfileEventHandling postLoginStarted:provider];
    
    // Perform login process
    // TODO: Check if need to change any nonatomic properties
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [authProvider login:^(enum Provider provider) {
            [authProvider getUserProfile: ^(UserProfile *userProfile) {
                [UserProfileStorage setUserProfile:userProfile];
                [UserProfileEventHandling postLoginFinished:userProfile];

                if (reward) {
                    [reward give];
                }
            } fail:^(NSString *message) {
                [UserProfileEventHandling postLoginFailed:provider withMessage:message];
            }];
        } fail:^(NSString *message) {
            [UserProfileEventHandling postLoginFailed:provider withMessage:message];
        } cancel:^{
            [UserProfileEventHandling postLoginCancelled:provider];
        }];
    }];
}

- (void)logoutWithProvider:(enum Provider)provider {
    
    id<IAuthProvider> authProvider = (id<IAuthProvider>)[self getProvider:provider];
    UserProfile* userProfile = nil;
    
    @try {
        userProfile = [self getStoredUserProfileWithProvider:provider];
    }
    @catch (NSException *ex) {
        LogError(TAG, ([NSString stringWithFormat:@"%@", [ex callStackSymbols]]));
    }
    
    // Perform logout process
    [UserProfileEventHandling postLogoutStarted:provider];
    [authProvider logout:^() {
        if (userProfile) {
            [UserProfileStorage removeUserProfile:userProfile];
            [UserProfileEventHandling postLogoutFinished:provider];
        }
    }
    fail:^(NSString* message) {
        [UserProfileEventHandling postLogoutFailed:provider withMessage:message];
    }];
}

- (UserProfile *)getStoredUserProfileWithProvider:(enum Provider)provider {
    UserProfile* userProfile = [UserProfileStorage getUserProfile:provider];
    if (!userProfile) {
        @throw [[UserProfileNotFoundException alloc] init];
    }
    return userProfile;
}


@end

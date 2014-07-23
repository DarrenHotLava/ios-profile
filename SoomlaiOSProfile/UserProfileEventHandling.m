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

#import "UserProfileEventHandling.h"
#import "UserProfile.h"
#import "BadgeReward.h"


@implementation UserProfileEventHandling

+ (void)observeAllEventsWithObserver:(id)observer withSelector:(SEL)selector {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_USER_PROFILE_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_LOGIN_STARTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_LOGIN_FINISHED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_LOGIN_CANCELLED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_LOGIN_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_LOGOUT_STARTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_LOGOUT_FINISHED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_LOGOUT_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_SOCIAL_ACTION_STARTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_SOCIAL_ACTION_FINISHED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_SOCIAL_ACTION_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_GET_CONTACTS_STARTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_GET_CONTACTS_FINISHED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_GET_CONTACTS_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_BP_REWARD_GIVEN object:nil];
}

+ (void)postUserProfileUpdated:(UserProfile *)userProfile {
    NSDictionary *userInfo = @{DICT_ELEMENT_USER_PROFILE: userProfile};
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_USER_PROFILE_UPDATED object:self userInfo:userInfo];
}

+ (void)postLoginStarted:(enum Provider)provider {
    NSDictionary *userInfo = @{DICT_ELEMENT_PROVIDER: @(provider)};
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_LOGIN_STARTED object:self userInfo:userInfo];
}

+ (void)postLoginFinished:(UserProfile *)userProfile {
    NSDictionary *userInfo = @{DICT_ELEMENT_USER_PROFILE: userProfile};
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_LOGIN_FINISHED object:self userInfo:userInfo];
}

+ (void)postLoginCancelled:(enum Provider)provider {
    NSDictionary *userInfo = @{DICT_ELEMENT_PROVIDER: @(provider)};
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_LOGIN_CANCELLED object:self userInfo:userInfo];
}

+ (void)postLoginFailed:(enum Provider)provider withMessage:(NSString *)message {
    NSDictionary *userInfo = @{DICT_ELEMENT_PROVIDER: @(provider), DICT_ELEMENT_MESSAGE: message};
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_LOGIN_FAILED object:self userInfo:userInfo];
}

+ (void)postLogoutStarted:(enum Provider)provider {
    NSDictionary *userInfo = @{DICT_ELEMENT_PROVIDER: @(provider)};
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_LOGOUT_STARTED object:self userInfo:userInfo];
}

+ (void)postLogoutFinished:(enum Provider)provider {
    NSDictionary *userInfo = @{DICT_ELEMENT_PROVIDER: @(provider)};
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_LOGOUT_FINISHED object:self userInfo:userInfo];
}

+ (void)postLogoutFailed:(enum Provider)provider withMessage:(NSString *)message {
    NSDictionary *userInfo = @{DICT_ELEMENT_PROVIDER: @(provider), DICT_ELEMENT_MESSAGE: message};
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_LOGOUT_FAILED object:self userInfo:userInfo];
}

+ (void)postSocialActionStarted:(enum Provider)provider withType:(enum SocialActionType)socialActionType {
    NSDictionary *userInfo = @{DICT_ELEMENT_PROVIDER: @(provider), DICT_ELEMENT_SOCIAL_ACTION_TYPE: @(socialActionType)};
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_SOCIAL_ACTION_STARTED object:self userInfo:userInfo];
}

+ (void)postSocialActionFinished:(enum Provider)provider withType:(enum SocialActionType)socialActionType {
    NSDictionary *userInfo = @{DICT_ELEMENT_PROVIDER: @(provider), DICT_ELEMENT_SOCIAL_ACTION_TYPE: @(socialActionType)};
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_SOCIAL_ACTION_FINISHED object:self userInfo:userInfo];
}

+ (void)postSocialActionFailed:(enum Provider)provider withType:(enum SocialActionType)socialActionType withMessage:(NSString *)message {
    NSDictionary *userInfo = @{DICT_ELEMENT_PROVIDER: @(provider),
                               DICT_ELEMENT_SOCIAL_ACTION_TYPE: @(socialActionType),
                               DICT_ELEMENT_MESSAGE: message};
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_SOCIAL_ACTION_FAILED object:self userInfo:userInfo];
}

+ (void)postGetContactsStarted:(enum Provider)provider withType:(enum SocialActionType)socialActionType {
    NSDictionary *userInfo = @{DICT_ELEMENT_PROVIDER: @(provider), DICT_ELEMENT_SOCIAL_ACTION_TYPE: @(socialActionType)};
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_GET_CONTACTS_STARTED object:self userInfo:userInfo];
}

+ (void)postGetContactsFinished:(enum Provider)provider withType:(enum SocialActionType)socialActionType withContacts:(NSArray *)contacts {
    NSDictionary *userInfo = @{DICT_ELEMENT_PROVIDER: @(provider),
                               DICT_ELEMENT_SOCIAL_ACTION_TYPE: @(socialActionType),
                               DICT_ELEMENT_CONTACTS: contacts};
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_GET_CONTACTS_FINISHED object:self userInfo:userInfo];
}

+ (void)postGetContactsFailed:(enum Provider)provider withType:(enum SocialActionType)socialActionType withMessage:(NSString *)message {
    NSDictionary *userInfo = @{DICT_ELEMENT_PROVIDER: @(provider),
                               DICT_ELEMENT_SOCIAL_ACTION_TYPE: @(socialActionType),
                               DICT_ELEMENT_MESSAGE: message};
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_GET_CONTACTS_FAILED object:self userInfo:userInfo];
}

// TODO: add feeds


+ (void)postRewardGiven:(Reward *)reward {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              reward, DICT_ELEMENT_REWARD,
                              [NSNumber numberWithBool:[reward isKindOfClass:[BadgeReward class]]], DICT_ELEMENT_IS_BADGE,
                              nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_BP_REWARD_GIVEN object:self userInfo:userInfo];
}


@end

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

#import "UserProfileUtils.h"
#import "SocialActionUtils.h"

@class UserProfile;
@class Reward;

// Events
#define EVENT_UP_USER_PROFILE_UPDATED           @"up_user_profile_updated"

#define EVENT_UP_LOGIN_STARTED                  @"up_login_started"
#define EVENT_UP_LOGIN_FINISHED                 @"up_login_finished"
#define EVENT_UP_LOGIN_FAILED                   @"up_login_failed"
#define EVENT_UP_LOGIN_CANCELLED                @"up_login_cancelled"

#define EVENT_UP_LOGOUT_STARTED                 @"up_logout_started"
#define EVENT_UP_LOGOUT_FINISHED                @"up_logout_finished"
#define EVENT_UP_LOGOUT_FAILED                  @"up_logout_failed"

#define EVENT_UP_SOCIAL_ACTION_STARTED          @"up_social_action_started"
#define EVENT_UP_SOCIAL_ACTION_FINISHED         @"up_social_action_finished"
#define EVENT_UP_SOCIAL_ACTION_CANCELLED        @"up_social_action_cancelled"
#define EVENT_UP_SOCIAL_ACTION_FAILED           @"up_social_action_failed"

#define EVENT_UP_GET_CONTACTS_STARTED           @"up_get_contacts_started"
#define EVENT_UP_GET_CONTACTS_FINISHED          @"up_get_contacts_finished"
#define EVENT_UP_GET_CONTACTS_FAILED            @"up_get_contacts_failed"

#define EVENT_UP_GET_FEED_STARTED           @"up_get_feed_started"
#define EVENT_UP_GET_FEED_FINISHED          @"up_get_feed_finished"
#define EVENT_UP_GET_FEED_FAILED            @"up_get_feed_failed"

#define EVENT_BP_REWARD_GIVEN                   @"bp_reward_given"


// UserInfo Elements
#define DICT_ELEMENT_USER_PROFILE               @"userProfile"
#define DICT_ELEMENT_PROVIDER                   @"provider"
#define DICT_ELEMENT_SOCIAL_ACTION_TYPE         @"socialActiontype"
#define DICT_ELEMENT_MESSAGE                    @"message"
#define DICT_ELEMENT_CONTACTS                   @"contacts"
#define DICT_ELEMENT_FEEDS                      @"feeds"
#define DICT_ELEMENT_REWARD                     @"reward"
#define DICT_ELEMENT_IS_BADGE                   @"isBadge"


@interface UserProfileEventHandling : NSObject

+ (void)observeAllEventsWithObserver:(id)observer withSelector:(SEL)selector;

+ (void)postUserProfileUpdated:(UserProfile *)userProfile;
+ (void)postLoginStarted:(enum Provider)provider;
+ (void)postLoginFinished:(UserProfile *)userProfile;
+ (void)postLoginFailed:(enum Provider)provider withMessage:(NSString *)message;
+ (void)postLoginCancelled:(enum Provider)provider;
+ (void)postLogoutStarted:(enum Provider)provider;
+ (void)postLogoutFinished:(enum Provider)provider;
+ (void)postLogoutFailed:(enum Provider)provider withMessage:(NSString *)message;
+ (void)postSocialActionStarted:(enum Provider)provider withType:(enum SocialActionType)socialActionType;
+ (void)postSocialActionFinished:(enum Provider)provider withType:(enum SocialActionType)socialActionType;
+ (void)postSocialActionCancelled:(enum Provider)provider withType:(enum SocialActionType)socialActionType;
+ (void)postSocialActionFailed:(enum Provider)provider withType:(enum SocialActionType)socialActionType withMessage:(NSString *)message;
+ (void)postGetContactsStarted:(enum Provider)provider withType:(enum SocialActionType)socialActionType;
+ (void)postGetContactsFinished:(enum Provider)provider withType:(enum SocialActionType)socialActionType withContacts:(NSArray *)contacts;
+ (void)postGetContactsFailed:(enum Provider)provider withType:(enum SocialActionType)socialActionType withMessage:(NSString *)message;
+ (void)postGetFeedStarted:(enum Provider)provider withType:(enum SocialActionType)socialActionType;
+ (void)postGetFeedFinished:(enum Provider)provider withType:(enum SocialActionType)socialActionType withContacts:(NSArray *)feeds;
+ (void)postGetFeedFailed:(enum Provider)provider withType:(enum SocialActionType)socialActionType withMessage:(NSString *)message;
+ (void)postRewardGiven:(Reward *)reward;

@end

//
//  UserProfileEventHandling.h
//  SoomlaiOSProfile
//
//  Created by Gur Dotan on 6/2/14.
//  Copyright (c) 2014 Soomla. All rights reserved.
//

#import "UserProfileUtils.h"
#import "SocialActionUtils.h"

@class UserProfile;

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
#define EVENT_UP_SOCIAL_ACTION_FAILED           @"up_social_action_failed"

// UserInfo Elements
#define DICT_ELEMENT_USER_PROFILE               @"userProfile"
#define DICT_ELEMENT_PROVIDER                   @"provider"
#define DICT_ELEMENT_SOCIAL_ACTION_TYPE         @"socialActiontype"
#define DICT_ELEMENT_MESSAGE                    @"message"


@interface UserProfileEventHandling : NSObject

+ (void)postUserProfileUpdated:(UserProfile *)userProfile;
+ (void)postLoginStarted:(enum Provider)provider;
+ (void)postLoginFinished:(UserProfile *)userProfile;
+ (void)postLoginFailed:(NSString *)message;
+ (void)postLoginCancelled;
+ (void)postLogoutStarted:(enum Provider)provider;
+ (void)postLogoutFinished:(UserProfile *)userProfile;
+ (void)postLogoutFailed:(NSString *)message;
+ (void)postSocialActionStarted:(enum SocialActionType)socialActionType;
+ (void)postSocialActionFinished:(enum SocialActionType)socialActionType;
+ (void)postSocialActionFailed:(enum SocialActionType)socialActionType withMessage:(NSString *)message;

@end
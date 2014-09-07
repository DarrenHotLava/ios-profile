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

/**
 A utility class for fetching and storing user profile info locally on the device.
 */
@class UserProfile;


@interface UserProfileStorage : NSObject

/**
 Persists the given user profile to the device storage
 
 @param userProfile the user profile to save
 */
+ (void)setUserProfile:(UserProfile *)userProfile;

+ (void)setUserProfile:(UserProfile *)userProfile andNotify:(BOOL)notify;

/**
 Removes the given user profile from the device storage
 
 @param userProfile the user profile to remove
 */
+ (void)removeUserProfile:(UserProfile *)userProfile;

/**
 Fetches the user profile stored for the given provider
 
 @param provider the provider which will be used to fetch the user profile
 @return a user profile
 */
+ (UserProfile *)getUserProfile:(Provider)provider;

@end

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

#import "UserProfileStorage.h"
#import "UserProfile.h"
#import "ProfileEventHandling.h"
#import "KeyValueStorage.h"
#import "SoomlaUtils.h"

@implementation UserProfileStorage

static NSString* DB_KEY_PREFIX  = @"soomla.profile.";
static NSString* TAG            = @"SOOMLA UserProfileStorage";


+ (void)setUserProfile:(UserProfile *)userProfile {
    [self setUserProfile:userProfile andNotify:YES];
}

+ (void)setUserProfile:(UserProfile *)userProfile andNotify:(BOOL)notify {

    NSString* value = [SoomlaUtils dictToJsonString:[userProfile toDictionary]];
    NSString* key = [self keyUserProfile:userProfile.provider];
    [KeyValueStorage setValue:value forKey:key];
    if (notify) {
        [ProfileEventHandling postUserProfileUpdated:userProfile];
    }
}

+ (void)removeUserProfile:(UserProfile *)userProfile {
    NSString* key = [self keyUserProfile:userProfile.provider];
    [KeyValueStorage deleteValueForKey:key];
}

+ (UserProfile *)getUserProfile:(Provider)provider {
    
    NSString* key = [self keyUserProfile:provider];
    NSString* userProfileJSON = [KeyValueStorage getValueForKey:key];
    if (!userProfileJSON || [userProfileJSON length] == 0) {
        return nil;
    }
    
    NSDictionary* userProfileDict = [SoomlaUtils jsonStringToDict:userProfileJSON];
    UserProfile* userProfile = [[UserProfile alloc] initWithDictionary:userProfileDict];
    return userProfile;
}

+ (NSString *)keyUserProfile:(Provider)provider {
    return [NSString stringWithFormat:@"%@userprofile.%@", DB_KEY_PREFIX, [UserProfileUtils providerEnumToString:provider]];
}

@end

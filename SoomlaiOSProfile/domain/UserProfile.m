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

#import "UserProfile.h"
#import "JSONConsts.h"
#import "SoomlaUtils.h"
#import "PJSONConsts.h"

@implementation UserProfile

@synthesize provider, profileId, email, username, firstName, lastName, avatarLink, location, gender, language, birthday, extra;


- (id)initWithProvider:(Provider)oProvider
          andProfileId:(NSString *)oProfileId
           andUsername:(NSString *)oUsername
              andEmail:(NSString *)oEmail
          andFirstName:(NSString *)oFirstName
           andLastName:(NSString *)oLastName {
    return [self initWithProvider:oProvider andProfileId:oProfileId andUsername:oUsername andEmail:oEmail
                     andFirstName:oFirstName andLastName:oLastName andExtra:nil];
}

- (id)initWithProvider:(Provider)oProvider
          andProfileId:(NSString *)oProfileId
           andUsername:(NSString *)oUsername
              andEmail:(NSString *)oEmail
          andFirstName:(NSString *)oFirstName
           andLastName:(NSString *)oLastName
              andExtra:(NSDictionary *)oExtra {

    if (self = [super init]) {
        provider = oProvider;
        ID = self.profileId = oProfileId;
        self.username = oUsername;
        self.email = oEmail;
        self.firstName = oFirstName;
        self.lastName = oLastName;
        extra = oExtra;
    }

    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        provider = [UserProfileUtils providerStringToEnum:dict[UP_PROVIDER]];
        ID = self.profileId = dict[UP_PROFILEID];
        self.username = dict[UP_USERNAME];
        self.email = dict[UP_EMAIL];
        self.firstName = dict[UP_FIRSTNAME];
        self.lastName = dict[UP_LASTNAME];
        self.avatarLink = dict[UP_AVATAR];
        self.location = dict[UP_LOCATION];
        self.gender = dict[UP_GENDER];
        self.language = dict[UP_LANGUAGE];
        self.birthday = dict[UP_BIRTHDAY];
        extra = dict[UP_EXTRA];
    }
    
    return self;
}

- (NSDictionary*)toDictionary {
    NSMutableDictionary *result = [[super toDictionary] mutableCopy];
    [result addEntriesFromDictionary:@{
            UP_PROVIDER : [UserProfileUtils providerEnumToString:self.provider],
            UP_PROFILEID : self.profileId ?: [NSNull null],
            UP_USERNAME : self.username ?: [NSNull null],
            UP_EMAIL : self.email ?: [NSNull null],
            UP_FIRSTNAME : self.firstName ?: [NSNull null],
            UP_LASTNAME : self.lastName ?: [NSNull null],
            UP_AVATAR : self.avatarLink ?: [NSNull null],
            UP_LOCATION : self.location ?: [NSNull null],
            UP_GENDER : self.gender ?: [NSNull null],
            UP_LANGUAGE : self.language ?: [NSNull null],
            UP_BIRTHDAY : self.birthday ?: [NSNull null],
            UP_EXTRA : self.extra ?: [NSNull null]
    }];
    return result;
}

- (NSString *)getFullName {
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

@end

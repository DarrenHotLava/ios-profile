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

#import "SocialActionUtils.h"

@implementation SocialActionUtils

+ (NSString*)actionEnumToString:(SocialActionType)actionType {
    switch (actionType) {
        case UPDATE_STATUS:
            return @"UPDATE_STATUS";
            break;
        case UPDATE_STORY:
            return @"UPDATE_STORY";
            break;
        case UPLOAD_IMAGE:
            return @"UPLOAD_IMAGE";
            break;
        case GET_CONTACTS:
            return @"GET_CONTACTS";
            break;
        case GET_FEED:
            return @"GET_FEED";
            break;
            
        default:
            break;
    }
    
    return nil;
}
+ (NSString *)actionNumberToString:(NSNumber*)actionNumber {
    return [self actionEnumToString:(SocialActionType) [actionNumber intValue]];
}

+ (SocialActionType)actionStringToEnum:(NSString *)actionTypeString {
    if ([actionTypeString isEqualToString:@"UPDATE_STATUS"]) {
        return UPDATE_STATUS;
    }
    else if([actionTypeString isEqualToString:@"UPDATE_STORY"]) {
        return UPDATE_STORY;
    }
    else if([actionTypeString isEqualToString:@"UPLOAD_IMAGE"]) {
        return UPLOAD_IMAGE;
    }
    else if([actionTypeString isEqualToString:@"GET_CONTACTS"]) {
        return GET_CONTACTS;
    }
    else if([actionTypeString isEqualToString:@"GET_FEED"]) {
        return GET_FEED;
    }
    else {
        [NSException raise:NSGenericException format:@"Unexpected FormatType."];
    }
    
    return -1;
}

@end
//
//  SocialActionUtils.m
//  SoomlaiOSProfile
//
//  Created by Ori Dotan on 6/3/14.
//  Copyright (c) 2014 Soomla. All rights reserved.
//

#import "SocialActionUtils.h"

@implementation SocialActionUtils

+ (NSString*)actionEnumToString:(enum SocialActionType)actionType {
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
        case GET_FEEDS:
            return @"GET_FEEDS";
            break;
            
        default:
            break;
    }
    
    return nil;
}

+ (enum SocialActionType)actionStringToEnum:(NSString *)actionTypeString {
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
    else if([actionTypeString isEqualToString:@"GET_FEEDS"]) {
        return GET_FEEDS;
    }
    else {
        [NSException raise:NSGenericException format:@"Unexpected FormatType."];
    }
    
    return -1;
}

@end
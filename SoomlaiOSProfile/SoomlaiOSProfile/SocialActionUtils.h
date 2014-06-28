//
//  SocialActionUtils.h
//  SoomlaiOSProfile
//
//  Created by Gur Dotan on 6/3/14.
//  Copyright (c) 2014 Soomla. All rights reserved.
//


typedef NS_ENUM(NSInteger, SocialActionType) {
    UPDATE_STATUS,
    UPDATE_STORY,
    UPLOAD_IMAGE,
    GET_CONTACTS,
    GET_FEEDS
};

@interface SocialActionUtils : NSObject

+ (NSString *)actionEnumToString:(enum SocialActionType)actionType;

+ (enum SocialActionType)actionStringToEnum:(NSString *)actionTypeString;

@end
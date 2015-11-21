//
// Created by Eugene Butusov on 21/11/15.
// Copyright (c) 2015 Soomla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserProfileUtils.h"


@interface SoomlaSerializableObject : NSObject {
    @protected
        Provider provider;
}

@property (nonatomic, readonly) Provider provider;

/**
 Constructor

 @param dict An `NSDictionary` representation of the current object
 */
- (id)initWithDictionary:(NSDictionary *)dict;

/**
 Converts the current object to an `NSDictionary`.

 @return This instance of `UserProfile` as an `NSDictionary`.
 */
- (NSDictionary*)toDictionary;

@end
//
// Created by Eugene Butusov on 21/11/15.
// Copyright (c) 2015 Soomla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SoomlaSerializableObject.h"

@class UserProfile;


@interface Score : SoomlaSerializableObject

@property (nonatomic, strong) NSNumber *rank;
@property (nonatomic, strong) UserProfile *player;
@property (nonatomic, strong) NSNumber *value;

@end
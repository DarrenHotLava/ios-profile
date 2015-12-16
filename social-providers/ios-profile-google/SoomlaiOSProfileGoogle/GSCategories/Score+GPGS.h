//
// Created by Eugene Butusov on 03/12/15.
// Copyright (c) 2015 SOOMLA Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Score.h"

@class GPGScore;
@class GPGPlayer;

@interface Score (GPGS)

-(instancetype)initWithGooglePlayScore:(GPGScore *)score;
-(instancetype)initWithGooglePlayScore:(GPGScore *)score andPlayer:(GPGPlayer *)player;

@end
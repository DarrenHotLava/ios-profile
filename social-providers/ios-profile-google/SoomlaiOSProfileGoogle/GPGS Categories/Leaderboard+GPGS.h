//
// Created by Eugene Butusov on 03/12/15.
// Copyright (c) 2015 SOOMLA Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Leaderboard.h"

@class GPGLeaderboardMetadata;

@interface Leaderboard (GPGS)

-(instancetype)initWithLeaderboardMetadata:(GPGLeaderboardMetadata *)leaderboardMetadata;

@end
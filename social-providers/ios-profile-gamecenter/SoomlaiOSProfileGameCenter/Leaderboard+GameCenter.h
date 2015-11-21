//
// Created by Eugene Butusov on 21/11/15.
// Copyright (c) 2015 SOOMLA Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "Leaderboard.h"

@interface Leaderboard (GameCenter)

-(instancetype)initWithGamecenterLeaderboard:(GKLeaderboard *)leaderboard;

@end
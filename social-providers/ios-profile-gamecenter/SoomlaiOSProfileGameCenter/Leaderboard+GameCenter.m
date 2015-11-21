//
// Created by Eugene Butusov on 21/11/15.
// Copyright (c) 2015 SOOMLA Inc. All rights reserved.
//

#import "Leaderboard+GameCenter.h"


@implementation Leaderboard (GameCenter)

-(instancetype)initWithGamecenterLeaderboard:(GKLeaderboard *)leaderboard {
    if (self = [super init]) {
        provider = GAME_CENTER;
        self.identifier = leaderboard.identifier;
    }
    return self;
}

@end
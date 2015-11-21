//
// Created by Eugene Butusov on 21/11/15.
// Copyright (c) 2015 SOOMLA Inc. All rights reserved.
//

#import "Score+GameCenter.h"
#import "SoomlaGameCenter.h"


@implementation Score (GameCenter)

-(instancetype)initWithGamecenterScore:(GKScore *)score {
    if (self = [super init]) {
        provider = GAME_CENTER;
        self.rank = @(score.rank);
        self.player = [SoomlaGameCenter userProfileFromGameKitPlayer:score.player];
        self.value = @(score.value);
    }
    return self;
}

@end
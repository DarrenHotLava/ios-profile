//
// Created by Eugene Butusov on 03/12/15.
// Copyright (c) 2015 SOOMLA Inc. All rights reserved.
//

#import <gpg/GooglePlayGames.h>
#import "Leaderboard+GPGS.h"
#import "Leaderboard.h"


@implementation Leaderboard (GPGS)

-(instancetype)initWithLeaderboardMetadata:(GPGLeaderboardMetadata *)leaderboardMetadata {
    if (self = [self initWithProvider:GOOGLE]) {
        _ID = leaderboardMetadata.leaderboardId;
        _iconUrl = leaderboardMetadata.iconUrl.absoluteString;
        _name = leaderboardMetadata.title;
    }
    return self;
}

@end
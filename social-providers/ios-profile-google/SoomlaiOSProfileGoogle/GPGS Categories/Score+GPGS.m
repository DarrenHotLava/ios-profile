//
// Created by Eugene Butusov on 03/12/15.
// Copyright (c) 2015 SOOMLA Inc. All rights reserved.
//

#import <gpg/GooglePlayGames.h>
#import "Score+GPGS.h"
#import "UserProfile.h"


@implementation Score (GPGS)

-(instancetype)initWithGooglePlayScore:(GPGScore *)score andPlayer:(GPGPlayer *)player {
    if (self = [super init]) {
        self.value = @(score.value);
        self.rank = @(score.rank);
        NSString *playerFirstName = [player.displayName componentsSeparatedByString:@" "][0];
        NSString *playerLastName = [player.displayName componentsSeparatedByString:@" "].count == 2
                ? [player.displayName componentsSeparatedByString:@" "][1] : @"";
        self.player = [[UserProfile alloc] initWithProvider:GOOGLE
                                               andProfileId:player.playerId
                                                andUsername:@"" // not provided
                                                   andEmail:@"" // not provided
                                               andFirstName:playerFirstName
                                                andLastName:playerLastName];
        self.player.avatarLink = player.imageUrl.absoluteString;
    }
    return self;
}

-(instancetype)initWithGooglePlayScore:(GPGScore *)score {
    if (self = [self initWithGooglePlayScore:score andPlayer:score.player]) {

    }
    return self;
}

@end
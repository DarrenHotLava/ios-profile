//
// Created by Eugene Butusov on 21/11/15.
// Copyright (c) 2015 Soomla. All rights reserved.
//

#import "Score.h"
#import "UserProfile.h"
#import "PJSONConsts.h"


@implementation Score {

}

-(instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        self.rank = dict[UP_SCORE_RANK];
        self.player = [[UserProfile alloc] initWithDictionary:dict[UP_USER_PROFILE]];
        self.value = dict[UP_SCORE_VALUE];
    }
    return self;
}

-(NSDictionary *)toDictionary {
    NSMutableDictionary *result = [[super toDictionary] mutableCopy];
    [result addEntriesFromDictionary:@{
            UP_SCORE_RANK:    self.rank,
            UP_USER_PROFILE:  self.player.toDictionary,
            UP_SCORE_VALUE:   self.value
    }];
    return result;
}

@end
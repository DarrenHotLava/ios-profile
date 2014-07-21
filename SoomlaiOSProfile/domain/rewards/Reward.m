/*
 Copyright (C) 2012-2014 Soomla Inc.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "Reward.h"
#import "BPJSONConsts.h"
#import "RewardStorage.h"
#import "StoreUtils.h"

@implementation Reward

@synthesize rewardId, name, repeatable;

static NSString* TAG = @"SOOMLA Reward";

- (id)initWithRewardId:(NSString *)oRewardId andName:(NSString *)oName {
    self = [super init];
    if ([self class] == [Reward class]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Error, attempting to instantiate AbstractClass directly." userInfo:nil];
    }
    
    if (self) {
        self.rewardId = oRewardId;
        self.name = oName;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if ([self class] == [Reward class]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Error, attempting to instantiate AbstractClass directly." userInfo:nil];
    }
    
    if (self) {
        self.rewardId = [dict objectForKey:BP_REWARD_REWARDID];
        self.name = [dict objectForKey:BP_NAME];
        self.repeatable = [[dict objectForKey:BP_REWARD_REPEAT] boolValue];
    }
    
    return self;
}

- (NSDictionary *)toDictionary {
    return [[NSDictionary alloc] initWithObjectsAndKeys:
            self.rewardId, BP_REWARD_REWARDID,
            self.name, BP_NAME,
            self.repeatable, BP_REWARD_REPEAT,
            nil];
}

- (void)give {
    if ([RewardStorage isRewardGiven:self] && !self.repeatable) {
        LogDebug(TAG, ([NSString stringWithFormat:@"Reward was already given and is not repeatable. id: %@", self.rewardId]));
        return;
    }

    if ([self giveInner]) {
        [RewardStorage setStatus:YES forReward:self];
    }
}

- (void)take {
    [RewardStorage setStatus:NO forReward:self];
}

- (BOOL)isOwned {
    return [RewardStorage isRewardGiven:self];
}

- (BOOL)giveInner {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}



@end

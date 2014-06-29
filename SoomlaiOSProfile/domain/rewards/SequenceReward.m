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

#import "SequenceReward.h"
#import "BPJSONConsts.h"
#import "BadgeReward.h"
#import "VirtualItemReward.h"
#import "RewardStorage.h"
#import "StoreUtils.h"

@implementation SequenceReward

@synthesize rewards;

static NSString* TAG = @"SOOMLA SequenceReward";

- (id)initWithRewardId:(NSString *)oRewardId andName:(NSString *)oName andRewards:(NSArray *)oRewards {
    if (self = [super initWithRewardId:oRewardId andName:oName]) {
        self.rewards = oRewards;
    }
    
    return self;
}


- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        
        NSMutableArray* tmpRewards = [NSMutableArray array];
        NSArray* rewardsArr = [dict objectForKey:BP_REWARDS];
        
        // Iterate over all rewards in the JSON array and for each one create
        // an instance according to the reward type
        for (NSDictionary* rewardDict in rewardsArr) {
            
            NSString* type = [rewardDict objectForKey:BP_TYPE];
            if ([type isEqualToString:@"badge"]) {
                [tmpRewards addObject:[[BadgeReward alloc] initWithDictionary:rewardDict]];
            } else if ([type isEqualToString:@"item"]) {
                [tmpRewards addObject:[[VirtualItemReward alloc] initWithDictionary:rewardDict]];
            } else {
                LogError(TAG, ([NSString stringWithFormat:@"Unknown reward type: %@", type]));
            }
        }
        
        self.rewards = tmpRewards;
    }
    
    return self;
}

- (NSDictionary *)toDictionary {
    NSDictionary* parentDict = [super toDictionary];
    
    NSMutableArray* rewardsArr = [NSMutableArray array];
    for (Reward* reward in self.rewards) {
        [rewardsArr addObject:[reward toDictionary]];
    }
    
    NSMutableDictionary* toReturn = [[NSMutableDictionary alloc] initWithDictionary:parentDict];
    [toReturn setValue:rewardsArr forKey:BP_REWARDS];
    [toReturn setValue:@"sequence" forKey:BP_TYPE];
    
    return toReturn;
}




- (Reward *)getLastGivenReward {
    int idx = [RewardStorage getLastSeqIdxGivenForReward:self];
    if (idx < 0) {
        return nil;
    }
    return [self.rewards objectAtIndex:idx];
}

- (BOOL)hasMoreToGive {
    return [RewardStorage getLastSeqIdxGivenForReward:self] < [self.rewards count] ;
}

- (BOOL)forceGiveNextReward:(Reward *)reward {
    for (int i = 0; i < [self.rewards count]; i++) {
        if ([((Reward*)[self.rewards objectAtIndex:i]).rewardId isEqualToString:reward.rewardId]) {
            [RewardStorage setLastSeqIdxGiven:(i - 1) ForReward:self];
            return YES;
        }
    }

    return NO;
}

- (BOOL)giveInner {
    int idx = [RewardStorage getLastSeqIdxGivenForReward:self];
    if (idx >= [rewards count]) {
        return NO; // all rewards in the sequence were given
    }
    
    [RewardStorage setLastSeqIdxGiven:(++idx) ForReward:self];
    return YES;
}

@end

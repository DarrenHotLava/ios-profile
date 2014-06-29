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

#import "RewardStorage.h"
#import "Reward.h"
#import "Blueprint.h"
#import "UserProfileEventHandling.h"
#import "StorageManager.h"
#import "KeyValueStorage.h"

@implementation RewardStorage


+ (void)setStatus:(BOOL)status forReward:(Reward *)reward {
    [self setStatus:status forReward:reward andNotify:YES];
}

+ (void)setStatus:(BOOL)status forReward:(Reward *)reward andNotify:(BOOL)notify {
    NSString* key = [self keyRewardGivenWithRewardId:reward.rewardId];
    
    if (status) {
        [[[StorageManager getInstance] keyValueStorage] setValue:@"yes" forKey:key];
        
        if (notify) {
            [UserProfileEventHandling postRewardGiven:reward];
        }
    } else {
        [[[StorageManager getInstance] keyValueStorage] deleteValueForKey:key];
    }
}

+ (BOOL)isRewardGiven:(Reward *)reward {
    NSString* key = [self keyRewardGivenWithRewardId:reward.rewardId];
    NSString* val = [[[StorageManager getInstance] keyValueStorage] getValueForKey:key];
    return (val && [val length] > 0);
}

+ (int)getLastSeqIdxGivenForReward:(Reward *)reward {
    NSString* key = [self keyRewardIdxSeqGivenWithRewardId:reward.rewardId];
    NSString* val = [[[StorageManager getInstance] keyValueStorage] getValueForKey:key];
    
    if (!val || [val length] == 0){
        return -1;
    }
    
    return [val intValue];
}

+ (void)setLastSeqIdxGiven:(int)idx ForReward:(Reward *)reward {
    NSString* key = [self keyRewardIdxSeqGivenWithRewardId:reward.rewardId];
    NSString* val = [[NSNumber numberWithInt:idx] stringValue];
    
    [[[StorageManager getInstance] keyValueStorage] setValue:val forKey:key];
}


// Private

+ (NSString *)keyRewardsWithRewardId:(NSString *)rewardId AndPostfix:(NSString *)postfix {
    return [NSString stringWithFormat: @"%@rewards.%@.%@", BP_DB_KEY_PREFIX, rewardId, postfix];
}

+ (NSString *)keyRewardGivenWithRewardId:(NSString *)rewardId {
    return [self keyRewardsWithRewardId:rewardId AndPostfix:@"given"];
}

+ (NSString *)keyRewardIdxSeqGivenWithRewardId:(NSString *)rewardId {
    return [self keyRewardsWithRewardId:rewardId AndPostfix:@"seq.idx"];
}


@end

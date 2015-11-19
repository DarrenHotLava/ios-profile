/*
 Copyright (C) 2012-2015 Soomla Inc.

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

#import <Reward.h>
#import "GameServicesController.h"
#import "IGameServicesProvider.h"
#import "ProfileEventHandling.h"


@implementation GameServicesController

static NSString* TAG = @"SOOMLA GameServicesController";

-(void)getFriendsListWithProvider:(Provider)provider payload:(NSString *)payload andReward:(Reward *)reward {
    id<IGameServicesProvider> gsProvider = (id<IGameServicesProvider>)[self getProvider:provider];

    [ProfileEventHandling postGetGameFriendsStarted:provider withPayload:payload];
    [gsProvider getFriendsListWithSuccess:^(NSArray *userProfiles) {
        if (reward) {
            [reward give];
        }
        [ProfileEventHandling postGetGameFriendsFinished:provider withFriendsList:userProfiles andPayload:payload];
    } fail:^(NSString *message) {
        [ProfileEventHandling postGetGameFriendsFailed:provider withMessage:message andPayload:payload];
    }];
}

-(void)getLeaderboardsWithProvider:(Provider)provider payload:(NSString *)payload andReward:(Reward *)reward {
    id<IGameServicesProvider> gsProvider = (id<IGameServicesProvider>)[self getProvider:provider];

    [ProfileEventHandling postGetLeaderboardsStarted:provider withPayload:payload];
    [gsProvider getLeaderboardsWithSuccess:^(NSArray *leaderboards) {
        if (reward) {
            [reward give];
        }
        [ProfileEventHandling postGetLeaderboardsFinished:provider withLeaderboardsList:leaderboards andPayload:payload];
    } fail:^(NSString *message) {
        [ProfileEventHandling postGetLeaderboardsFailed:provider withMessage:message andPayload:payload];
    }];
}

-(void)getScoresWithProvider:(Provider)provider
              forLeaderboard:(NSString *)leaderboardId
                     payload:(NSString *)payload
                   andReward:(Reward *)reward {

}

@end
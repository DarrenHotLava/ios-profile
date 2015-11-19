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

#import "IAuthProvider.h"
#import "IGameServicesCallbacks.h"

/**
 A provider that exposes game services capabilities such as leaderboards, achievements, challenges and scoring
 */

@protocol IGameServicesProvider <IAuthProvider>

-(void)getFriendsListWithSuccess:(friendsSuccessHandler)success fail:(failureHandler)fail;

-(void)getLeaderboardsWithSuccess:(leaderboardsSuccessHandler)success fail:(failureHandler)fail;

-(void)getScoresOfLeaderboard:(NSString *)leaderboardId withSuccess:(scoresSuccessHandler)success fail:(failureHandler)fail;

@end

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

#import <Foundation/Foundation.h>
#import "AuthController.h"

/**
 A class that loads all game services providers and performs specified
 actions on with them.

 Inheritance: GameServicesController > AuthController > ProviderLoader
 */
@interface GameServicesController : AuthController

/**
 Constructor

 Loads all game services providers
 @param providerParams Special initialization parameters for loaded providers
 */
-(id)initWithParameters:(NSDictionary *)providerParams;

-(void)getFriendsListWithProvider:(Provider)provider payload:(NSString *)payload andReward:(Reward *)reward;

-(void)getLeaderboardsWithProvider:(Provider)provider payload:(NSString *)payload andReward:(Reward *)reward;

-(void)getScoresWithProvider:(Provider)provider
              forLeaderboard:(NSString *)leaderboardId
                     payload:(NSString *)payload
                   andReward:(Reward *)reward;


@end
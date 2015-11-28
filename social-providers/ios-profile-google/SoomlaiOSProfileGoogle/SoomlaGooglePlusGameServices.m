//
// Created by Eugene Butusov on 28/11/15.
// Copyright (c) 2015 SOOMLA Inc. All rights reserved.
//

#import "SoomlaGooglePlusGameServices.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import <gpg/GooglePlayGames.h>


@implementation SoomlaGooglePlusGameServices {

}

/**
 Fetches the game's leaderboards list

 @param success a leaderboards fetch success callback
 @param fail a leaderboards fetch failure callback
 */
-(void)getLeaderboardsWithSuccess:(successWithArrayHandler)success fail:(failureHandler)fail {
    //TODO: implement leaderboards fetching
}

/**
 Fetches the game's scores list from specified leaderboard

 @param leaderboardId Leaderboard containing desired scores list
 @param fromStart Should we reset pagination or request the next page
 @param success a scores fetch success callback
 @param fail a scores fetch failure callback
 */
-(void)getScoresFromLeaderboard:(NSString *)leaderboardId fromStart:(BOOL)fromStart withSuccess:(successWithArrayHandler)success fail:(failureHandler)fail {
    //TODO: implement scores fetching
}

/**
 Reports scores for specified leaderboard

 @param score Value to report
 @param leaderboardId Target leaderboard
 @param success a score report success callback
 @param fail a score report failure callback
 */
-(void)submitScore:(NSNumber *)score toLeaderboard:(NSString *)leaderboardId withSuccess:(reportScoreSuccessHandler)success fail:(failureHandler)fail {
    //TODO: implement scores submitting
}

@end
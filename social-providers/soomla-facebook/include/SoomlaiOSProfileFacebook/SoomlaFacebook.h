//
//  SoomlaFacebook.h
//  SoomlaiOSProfileExample
//
//  Created by Gur Dotan on 6/10/14.
//  Copyright (c) 2014 Soomla. All rights reserved.
//

#import "ISocialProvider.h"

#import <FacebookSDK/FacebookSDK.h>

@interface SoomlaFacebook : NSObject <ISocialProvider> {
    loginSuccess loginSuccess;
    loginFail loginFail;
    loginCancel loginCancel;
    logoutSuccess logoutSuccess;
    logoutFail logoutFail;
    userProfileSuccess userProfileSuccess;
    userProfileFail userProfileFail;
    socialActionSuccess socialActionSuccess;
    socialActionFail socialActionFail;
    feedsActionSuccess feedsActionSuccess;
    feedsActionFail feedsActionFail;
}

@property (strong, nonatomic) loginSuccess loginSuccess;
@property (strong, nonatomic) loginFail loginFail;
@property (strong, nonatomic) loginCancel loginCancel;
@property (strong, nonatomic) logoutSuccess logoutSuccess;
@property (strong, nonatomic) logoutFail logoutFail;
@property (strong, nonatomic) userProfileSuccess userProfileSuccess;
@property (strong, nonatomic) userProfileFail userProfileFail;
@property (strong, nonatomic) socialActionSuccess socialActionSuccess;
@property (strong, nonatomic) socialActionFail socialActionFail;
@property (strong, nonatomic) feedsActionSuccess feedsActionSuccess;
@property (strong, nonatomic) feedsActionFail feedsActionFail;

// Make this method public to allow access from App Delegate
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;

@end

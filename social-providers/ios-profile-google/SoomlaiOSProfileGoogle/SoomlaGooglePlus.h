//
//  SoomlaiOSProfileGoogle.h
//  SoomlaiOSProfileGoogle
//
//  Created by Dima on 11/5/14.
//  Copyright (c) 2014 SOOMLA Inc. All rights reserved.
//

#import "ISocialProvider.h"
#import <GooglePlus/GooglePlus.h>

@interface SoomlaGooglePlus : NSObject<ISocialProvider, GPPSignInDelegate>{
    loginSuccess loginSuccess;
    loginFail loginFail;
    loginCancel loginCancel;
    logoutSuccess logoutSuccess;
    logoutFail logoutFail;
    
    @private
    BOOL loggedIn;
}

@property (strong, nonatomic) loginSuccess loginSuccess;
@property (strong, nonatomic) loginFail loginFail;
@property (strong, nonatomic) loginCancel loginCancel;
@property (strong, nonatomic) logoutSuccess logoutSuccess;
@property (strong, nonatomic) logoutFail logoutFail;
@property (strong, nonatomic, readonly) NSString *clientId;

@end

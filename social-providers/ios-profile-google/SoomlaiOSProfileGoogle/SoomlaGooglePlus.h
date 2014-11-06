//
//  SoomlaiOSProfileGoogle.h
//  SoomlaiOSProfileGoogle
//
//  Created by Dima on 11/5/14.
//  Copyright (c) 2014 SOOMLA Inc. All rights reserved.
//

#import "ISocialProvider.h"

@interface SoomlaGooglePlus : NSObject<ISocialProvider>{
    loginSuccess loginSuccess;
    loginFail loginFail;
    loginCancel loginCancel;
    logoutSuccess logoutSuccess;
}

@property (strong, nonatomic) loginSuccess loginSuccess;
@property (strong, nonatomic) loginFail loginFail;
@property (strong, nonatomic) loginCancel loginCancel;
@property (strong, nonatomic) logoutSuccess logoutSuccess;

@end

//
// Created by Eugene Butusov on 28/11/15.
// Copyright (c) 2015 SOOMLA Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAuthProvider.h"
#import <GooglePlus/GooglePlus.h>

@interface SoomlaGoogleAuth : NSObject <IAuthProvider, GPPSignInDelegate> {
    loginSuccess loginSuccess;
    loginFail loginFail;
    loginCancel loginCancel;
    logoutSuccess logoutSuccess;
    logoutFail logoutFail;
}


@property (strong, nonatomic) loginSuccess loginSuccess;
@property (strong, nonatomic) loginFail loginFail;
@property (strong, nonatomic) loginCancel loginCancel;
@property (strong, nonatomic) logoutSuccess logoutSuccess;
@property (strong, nonatomic) logoutFail logoutFail;

@property (strong, nonatomic, readonly) NSString *clientId;

-(UserProfile *) parseGoogleContact: (GTLPlusPerson *)googleContact;
-(UserProfile *)parseGoogleContact:(GTLPlusPerson *)googleContact withExtraData:(BOOL)withExtraData;

@end
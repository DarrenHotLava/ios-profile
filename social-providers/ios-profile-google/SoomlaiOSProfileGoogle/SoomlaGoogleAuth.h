//
// Created by Eugene Butusov on 28/11/15.
// Copyright (c) 2015 SOOMLA Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAuthProvider.h"
#import <GooglePlus/GooglePlus.h>
#import <GoogleSignIn/GoogleSignIn.h>

@interface SoomlaGoogleAuth : NSObject <IAuthProvider> {

}

@property (strong, nonatomic, readonly) NSString *clientId;

-(UserProfile *) parseGoogleContact:(GTLPlusPerson *)googleContact;
-(UserProfile *)parseGoogleContact:(GTLPlusPerson *)googleContact withExtraData:(BOOL)withExtraData;

@end
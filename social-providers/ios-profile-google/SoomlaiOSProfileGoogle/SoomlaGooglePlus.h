//
//  SoomlaiOSProfileGoogle.h
//  SoomlaiOSProfileGoogle
//
//  SOOMLA wrapper for GooglePlus framework
//

#import "ISocialProvider.h"
#import <GooglePlus/GooglePlus.h>

@interface SoomlaGooglePlus : NSObject<ISocialProvider, GPPSignInDelegate>{
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

@end

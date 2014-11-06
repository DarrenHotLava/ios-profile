//
//  SoomlaiOSProfileGoogle.m
//  SoomlaiOSProfileGoogle
//
//  Created by Dima on 11/5/14.
//  Copyright (c) 2014 SOOMLA Inc. All rights reserved.
//

#import "SoomlaGooglePlus.h"
#import <GoogleOpenSource/GoogleOpenSource.h>

@implementation SoomlaGooglePlus

@synthesize loginSuccess, loginFail, loginCancel, logoutSuccess, logoutFail, GooglePlusAppId;

static NSString *TAG = @"SOOMLA SoomlaGooglePlus";

//aClientId - the client ID from Google Developers Console project
- (id)init{
    self = [super init];
    
    if (!self)
        return nil;
    
    return self;
}

- (void)login:(loginSuccess)success fail:(loginFail)fail cancel:(loginCancel)cancel{
    //set login handlers
    self.loginSuccess = success;
    self.loginFail = fail;
    self.loginCancel = cancel;
    
    //check if app id is set
    if (!GooglePlusAppId)
        self.loginFail(@"GooglePlus app id is not set!");
    
    //auth
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.clientID = self.GooglePlusAppId;
    signIn.scopes = @[ kGTLAuthScopePlusLogin ];
    [signIn authenticate];
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error {
    NSLog(@"Received error %@ and auth object %@",error, auth);
    if (error) {
       self.loginFail([error localizedDescription]);
    } else {
        [self refreshInterfaceBasedOnSignIn];
    }
}

-(void)refreshInterfaceBasedOnSignIn {
    if ([[GPPSignIn sharedInstance] authentication]) {
        // The user is signed in.
        loggedIn = YES;
        self.loginSuccess(GOOGLE);
        // Perform other actions here, such as showing a sign-out button
    } else {
        loggedIn = NO;
        self.loginFail(@"GooglePlus Authentication failed.");
    }
}

- (void)getUserProfile:(userProfileSuccess)success fail:(userProfileFail)fail{
    //TODO
}

- (void)logout:(logoutSuccess)success fail:(logoutFail)fail{
    //will be required in case of disconnect!
//    self.logoutSuccess = success;
//    self.logoutFail = fail;
    [[GPPSignIn sharedInstance] signOut];
}

//In case of calling [[GPPSignIn sharedInstance] disconnect] => signout vs disconect???
//- (void)didDisconnectWithError:(NSError *)error {
//    if (error) {
//        self.logoutFail([error localizedDescription]);
//    } else {
//        // The user is signed out and disconnected.
//        // Clean up user data as specified by the Google+ terms.
//        loggedIn = NO;
//        self.logoutSuccess();
//    }
//}

- (BOOL)isLoggedIn{
    return loggedIn;
}

- (BOOL)tryHandleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [GPPURLHandler handleURL:url
           sourceApplication:sourceApplication
                         annotation:annotation];
}

- (void)updateStatus:(NSString *)status success:(socialActionSuccess)success fail:(socialActionFail)fail{
    //TODO
}

- (void)updateStatusWithProviderDialog:(NSString *)link success:(socialActionSuccess)success fail:(socialActionFail)fail{
    //TODO
}

- (void)updateStoryWithMessage:(NSString *)message
                       andName:(NSString *)name
                    andCaption:(NSString *)caption
                andDescription:(NSString *)description
                       andLink:(NSString *)link
                    andPicture:(NSString *)picture
                       success:(socialActionSuccess)success
                          fail:(socialActionFail)fail
{
    //TODO
}

- (void)updateStoryWithMessageDialog:(NSString *)name
                          andCaption:(NSString *)caption
                      andDescription:(NSString *)description
                             andLink:(NSString *)link
                          andPicture:(NSString *)picture
                             success:(socialActionSuccess)success
                                fail:(socialActionFail)fail
{
    //TODO
}

- (void)getContacts:(contactsActionSuccess)success fail:(contactsActionFail)fail{
    //TODO
}

- (void)getFeed:(feedsActionSuccess)success fail:(feedsActionFail)fail{
    //TODO
}

- (void)uploadImageWithMessage:(NSString *)message
                   andFilePath:(NSString *)filePath
                       success:(socialActionSuccess)success
                          fail:(socialActionFail)fail
{
    //TODO
}

- (Provider)getProvider {
    return GOOGLE;
}

- (void)like:(NSString *)pageName{
    //TODO
}

@end

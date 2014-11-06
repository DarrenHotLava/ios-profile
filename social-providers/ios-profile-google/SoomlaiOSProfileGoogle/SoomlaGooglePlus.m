//
//  SoomlaiOSProfileGoogle.m
//  SoomlaiOSProfileGoogle
//
//  Created by Dima on 11/5/14.
//  Copyright (c) 2014 SOOMLA Inc. All rights reserved.
//

#import "SoomlaGooglePlus.h"

@implementation SoomlaGooglePlus

@synthesize loginSuccess, loginFail, loginCancel,
logoutSuccess;

static NSString *TAG = @"SOOMLA SoomlaGooglePlus";

- (void)login:(loginSuccess)success fail:(loginFail)fail cancel:(loginCancel)cancel{
    //TODO
}

- (void)getUserProfile:(userProfileSuccess)success fail:(userProfileFail)fail{
    //TODO
}

- (void)logout:(logoutSuccess)success fail:(logoutFail)fail{
    //TODO
}

- (BOOL)isLoggedIn{
    //TODO
    return NO;
}

- (BOOL)tryHandleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    //TODO
    return NO;
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

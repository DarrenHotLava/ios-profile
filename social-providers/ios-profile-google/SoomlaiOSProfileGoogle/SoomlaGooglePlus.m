//
//  SoomlaiOSProfileGoogle.m
//  SoomlaiOSProfileGoogle
//
//  Created by Dima on 11/5/14.
//  Copyright (c) 2014 SOOMLA Inc. All rights reserved.
//

#import "SoomlaGooglePlus.h"
#import "UserProfile.h"
#import "SoomlaUtils.h"
#import <GoogleOpenSource/GoogleOpenSource.h>

@implementation SoomlaGooglePlus

@synthesize loginSuccess, loginFail, loginCancel, logoutSuccess, logoutFail, clientId;

static NSString *TAG = @"SOOMLA SoomlaGooglePlus";

//aClientId - the client ID from Google Developers Console project
- (id)init{
    self = [super init];
    
    if (!self)
        return nil;
    
    return self;
}

- (void)applyParams:(NSDictionary *)providerParams{
    if (providerParams){
        clientId = [providerParams objectForKey:@"clientId"];
    }
}

- (void)login:(loginSuccess)success fail:(loginFail)fail cancel:(loginCancel)cancel{
    LogDebug(TAG, @"Login");
    
    //check if clientId was set
    if (!clientId)
        fail(@"GooglePlus client id is not set!");
    
    [self setLoginBlocks:success fail:fail cancel:cancel];
    
    [self authenticate];
}

//Initialize 
- (void)authenticate{
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.clientID = self.clientId;
    signIn.scopes = @[ kGTLAuthScopePlusLogin ];
    signIn.shouldFetchGoogleUserEmail = YES;
    signIn.delegate = self;
    [signIn authenticate];
}

//callback for GPPSignIn end of authentication process
- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error {
    if (error) {
       self.loginFail([error localizedDescription]);
    } else {
        [self refreshInterfaceBasedOnSignIn];
    }
}

//check if authentication status and update
-(void)refreshInterfaceBasedOnSignIn {
    if ([[GPPSignIn sharedInstance] authentication]) {
        // The user is signed in.
        loggedIn = YES;
        self.loginSuccess(GOOGLE);
    } else {
        loggedIn = NO;
        [self clearLoginBlocks];
        self.loginFail(@"GooglePlus Authentication failed.");
    }
}

- (void)getUserProfile:(userProfileSuccess)success fail:(userProfileFail)fail{
    LogDebug(TAG, @"Getting user profile");
    GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
    plusService.retryEnabled = YES;
    [plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];
    
    GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
    [plusService executeQuery:query
            completionHandler:^(GTLServiceTicket *ticket,
                                GTLPlusPerson *person,
                                NSError *error) {
                if (error) {
                    fail([error localizedDescription]);
                } else {
                    UserProfile *userProfile = [[UserProfile alloc] initWithProvider:GOOGLE
                                                                        andProfileId:person.identifier
                                                                         andUsername:@"" //user name is not available!
                                                                         andEmail:[person.emails objectAtIndex:0]                                                           andFirstName:person.name.givenName
                                                                         andLastName:person.name.familyName];
                    userProfile.gender = person.gender;
                    userProfile.birthday = person.birthday;
                    userProfile.location = person.currentLocation;
                    userProfile.avatarLink = person.image.url;
                    
                    success(userProfile);
                }
            }];
}

- (void)logout:(logoutSuccess)success fail:(logoutFail)fail{
    LogDebug(TAG, @"Logout");
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
    LogDebug(TAG, @"isLoggedIn");
    return loggedIn;
}

- (BOOL)tryHandleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [GPPURLHandler handleURL:url
           sourceApplication:sourceApplication
                         annotation:annotation];
}

- (void)updateStatus:(NSString *)status success:(socialActionSuccess)success fail:(socialActionFail)fail{
    id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
    [shareBuilder setPrefillText:status];
    [shareBuilder open];
}

- (void)updateStatusWithProviderDialog:(NSString *)link success:(socialActionSuccess)success fail:(socialActionFail)fail{
    id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
    [shareBuilder setURLToShare:[NSURL URLWithString:link]];
    [shareBuilder open];
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
    id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
    [shareBuilder setPrefillText:message];
    [shareBuilder setTitle:name description:description thumbnailURL:[NSURL URLWithString:picture]];
    [shareBuilder setURLToShare:[NSURL URLWithString:link]];
    [shareBuilder open];
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
    GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
    plusService.retryEnabled = YES;
    [plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];
    
    GTLQueryPlus *query =
    [GTLQueryPlus queryForPeopleListWithUserId:@"me"
                                    collection:kGTLPlusCollectionVisible];
    [plusService executeQuery:query
            completionHandler:^(GTLServiceTicket *ticket,
                                GTLPlusPeopleFeed *peopleFeed,
                                NSError *error) {
                if (error) {
                    fail([error localizedDescription]);
                } else {
                    // Get an array of people from GTLPlusPeopleFeed
                    NSArray* rawContacts = peopleFeed.items;
                    
                    NSMutableArray *contacts = [NSMutableArray array];
                    
                    for (GTLPlusPerson *rawContact in rawContacts) {
                        UserProfile *contact = [[UserProfile alloc] initWithProvider:GOOGLE
                                                                        andProfileId:rawContact.identifier                                                                         andUsername: @""
                                                                            andEmail:[rawContact.emails objectAtIndex:0]
                                                                        andFirstName:rawContact.name.givenName
                                                                         andLastName:rawContact.name.familyName];
                        contact.gender = rawContact.gender;
                        contact.birthday = rawContact.birthday;
                        if (rawContact.currentLocation) {
                            contact.location = rawContact.currentLocation;
                        }
                                                
                        contact.avatarLink = [rawContact.image url];
                        
                        [contacts addObject:contact];
                    }
                    
                    success(contacts);
                }
            }];
    
}

- (void)getFeed:(feedsActionSuccess)success fail:(feedsActionFail)fail{
    //TODO
}

- (void)uploadImageWithMessage:(NSString *)message
                   andFilePath:(NSString *)filePath
                       success:(socialActionSuccess)success
                          fail:(socialActionFail)fail
{
    id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
    [shareBuilder setPrefillText:message];
    [shareBuilder attachImage:[UIImage imageNamed:filePath]];
    [shareBuilder open];
}

- (Provider)getProvider {
    return GOOGLE;
}

- (void)like:(NSString *)pageName{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"https://plus.google.com/+", pageName]];
    [[UIApplication sharedApplication] openURL:url];
}

-(void)setLoginBlocks:(loginSuccess)success fail:(loginFail)fail cancel:(loginCancel)cancel{
    self.loginSuccess = success;
    self.logoutFail = fail;
    self.loginCancel = cancel;
}

- (void)clearLoginBlocks {
    self.loginSuccess = nil;
    self.loginFail = nil;
    self.loginCancel = nil;
}

@end

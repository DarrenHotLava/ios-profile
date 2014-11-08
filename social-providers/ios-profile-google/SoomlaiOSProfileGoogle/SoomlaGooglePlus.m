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

@implementation SoomlaGooglePlus{
//    GPPSignIn *signIn;
}

@synthesize loginSuccess, loginFail, loginCancel, logoutSuccess, logoutFail, clientId;

static NSString *TAG = @"SOOMLA SoomlaGooglePlus";
static NSString *kDefaultContactInfoValue = @"";

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
    
    [self startAuth];
}

//Initialize 
- (void)startAuth{
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGoogleUserEmail = YES;
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.clientID = self.clientId;
    signIn.scopes = @[ kGTLAuthScopePlusLogin ];
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
        self.loginSuccess(GOOGLE);
    } else {
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
                    UserProfile *userProfile = [self getProfileFromGoogleContact:person];
                    
                    success(userProfile);
                }
            }];
}

- (void)logout:(logoutSuccess)success fail:(logoutFail)fail{
    LogDebug(TAG, @"Logout");
    self.logoutSuccess = success;
    self.logoutFail = fail;
    [[GPPSignIn sharedInstance] disconnect];
}

- (void)didDisconnectWithError:(NSError *)error {
    if (error) {
        self.logoutFail([error localizedDescription]);
    } else {
        // The user is signed out and disconnected.
        // Clean up user data as specified by the Google+ terms.
        [self clearLoginBlocks];
        self.logoutSuccess();
    }
}

- (BOOL)isLoggedIn{
    LogDebug(TAG, @"isLoggedIn");
    return ([GPPSignIn sharedInstance].authentication != nil);
}

- (BOOL)tryHandleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [GPPURLHandler handleURL:url
           sourceApplication:sourceApplication
                         annotation:annotation];
}

- (void)updateStatus:(NSString *)status success:(socialActionSuccess)success fail:(socialActionFail)fail{
    LogDebug(TAG, @"updateStatus");
    @try{
        id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
        [shareBuilder setPrefillText:status];
        [shareBuilder open];
        success();
    }
    @catch(NSException *exception){
        LogError(TAG, @"Failed updating status.");
        fail([NSString stringWithFormat:@"Failed updating status with exception %@", [exception reason]]);
    }
    
}

- (void)updateStatusWithProviderDialog:(NSString *)link success:(socialActionSuccess)success fail:(socialActionFail)fail{
    LogDebug(TAG, @"updateStatus");
    @try {
        id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
        [shareBuilder setURLToShare:[NSURL URLWithString:link]];
        [shareBuilder open];
        success();
    }
    @catch (NSException *exception) {
        LogError(TAG, @"Failed updating status with dialog");
        fail([NSString stringWithFormat:@"Failed updating status with dialog with exception %@", [exception reason]]);
    }
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
    @try {
        id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
        [shareBuilder setPrefillText:message];
        [shareBuilder setTitle:name description:description thumbnailURL:[NSURL URLWithString:picture]];
        [shareBuilder setURLToShare:[NSURL URLWithString:link]];
        [shareBuilder open];
    }
    @catch (NSException *exception) {
        LogError(TAG, @"Failed updating story");
        fail([NSString stringWithFormat:@"Failed updating story with exception %@", [exception reason]]);
    }
}

- (void)updateStoryWithMessageDialog:(NSString *)name
                          andCaption:(NSString *)caption
                      andDescription:(NSString *)description
                             andLink:(NSString *)link
                          andPicture:(NSString *)picture
                             success:(socialActionSuccess)success
                                fail:(socialActionFail)fail
{
    fail(@"updateStoryWithMessageDialog is not implemented");
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
                        UserProfile *contact = [self getProfileFromGoogleContact:rawContact];
                        
                        [contacts addObject:contact];
                    }
                    
                    success(contacts);
                }
            }];
    
}

-(UserProfile *) getProfileFromGoogleContact: (GTLPlusPerson *)googleContact{
    GTLPlusPersonEmailsItem *email = [googleContact.emails objectAtIndex:0];
    UserProfile * profile =
    [[UserProfile alloc] initWithProvider:GOOGLE
                             andProfileId:[self parseGoogleContactInfoString:googleContact.identifier]
                              andUsername: kDefaultContactInfoValue //TODO
                                 andEmail:[self parseGoogleContactInfoString:[email value]]
                                andFirstName:[self parseGoogleContactInfoString:googleContact.name.givenName]
                              andLastName:[self parseGoogleContactInfoString:googleContact.name.familyName]];
    profile.gender = [self parseGoogleContactInfoString:googleContact.gender];
    profile.birthday = [self parseGoogleContactInfoString:googleContact.birthday];
    profile.location = [self parseGoogleContactInfoString:googleContact.currentLocation];
    profile.avatarLink = [self parseGoogleContactInfoString:[googleContact.image url]];
    profile.language = [self parseGoogleContactInfoString:googleContact.language];
    return profile;
    
}

- (NSString *)parseGoogleContactInfoString:(NSString * )orig{
    return (orig) ? orig : kDefaultContactInfoValue;
}

- (void)getFeed:(feedsActionSuccess)success fail:(feedsActionFail)fail{
    fail(@"getFeed is not implemented!");
}

- (void)uploadImageWithMessage:(NSString *)message
                   andFilePath:(NSString *)filePath
                       success:(socialActionSuccess)success
                          fail:(socialActionFail)fail
{
    @try {
        id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
        [shareBuilder setPrefillText:message];
        [shareBuilder attachImage:[UIImage imageNamed:filePath]];
        [shareBuilder open];
        success();
    }
    @catch (NSException *exception) {
        LogError(TAG, @"Failed uploading image.");
        fail([NSString stringWithFormat:@"Failed uploading image with exception %@", [exception reason]]);
    }
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

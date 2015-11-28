/*
 Copyright (C) 2012-2014 Soomla Inc.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "SoomlaGooglePlus.h"
#import "UserProfile.h"
#import "SoomlaUtils.h"
#import "SoomlaProfile.h"
#import <GoogleOpenSource/GoogleOpenSource.h>

@interface SoomlaGooglePlus ()

@property (nonatomic, strong) id lastPageToken;
@property (nonatomic, strong) id lastFeedPageToken;

@end

@implementation SoomlaGooglePlus {

}

@synthesize socialActionSuccess, socialActionFail;

static NSString *TAG = @"SOOMLA SoomlaGooglePlus";
static NSString *GoogleKeychainName;

- (void)applyParams:(NSDictionary *)providerParams {
    [super applyParams:providerParams];

    GPPShare *share = [GPPShare sharedInstance];
    share.delegate = self;
}

- (void)updateStatus:(NSString *)status success:(socialActionSuccess)success fail:(socialActionFail)fail{
    LogDebug(TAG, @"updateStatus");
    [self setSocialActionBlocks:success fail:fail];
    id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
    [shareBuilder setPrefillText:status];
    [shareBuilder open];
}

- (void)updateStatusWithProviderDialog:(NSString *)link success:(socialActionSuccess)success fail:(socialActionFail)fail{
    LogDebug(TAG, @"updateStatus");
    [self setSocialActionBlocks:success fail:fail];
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
    [self setSocialActionBlocks:success fail:fail];
    id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
    [shareBuilder setPrefillText:message];
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
    fail(@"updateStoryWithMessageDialog is not implemented");
}

- (void)uploadImageWithMessage:(NSString *)message
                   andFilePath:(NSString *)filePath
                       success:(socialActionSuccess)success
                          fail:(socialActionFail)fail
{
    LogDebug(TAG, @"uploadImage");
    [self setSocialActionBlocks:success fail:fail];
    [GPPShare sharedInstance].delegate = self;
    id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
    [shareBuilder setPrefillText:message];
    [shareBuilder attachImage:[UIImage imageWithContentsOfFile:filePath]];
    [shareBuilder open];
}

- (void)uploadImageWithMessage:(NSString *)message
              andImageFileName: (NSString *)fileName
                  andImageData: (NSData *)imageData
                       success:(socialActionSuccess)success
                          fail:(socialActionFail)fail{
    LogDebug(TAG, @"uploadImage");
    [self setSocialActionBlocks:success fail:fail];
    [GPPShare sharedInstance].delegate = self;
    id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];

    [shareBuilder setPrefillText:message];

    UIImage *image = [UIImage imageWithData:imageData];
    [shareBuilder attachImage:image];

    [shareBuilder open];
}

- (void)finishedSharingWithError:(NSError *)error {
    
    if (!error) {
        self.socialActionSuccess();
    } else if (error.code == kGPPErrorShareboxCanceled) {
        self.socialActionFail(@"Social Action Cancelled");
    } else {
        self.socialActionFail([NSString stringWithFormat:@"Social Action Failed (%@)", [error localizedDescription]]);
    }
    [self clearSocialActionBlocks];
}

- (void)getContacts:(bool)fromStart success:(contactsActionSuccess)success fail:(contactsActionFail)fail {
    LogDebug(TAG, @"getContacts");
    GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
    plusService.retryEnabled = YES;
    [plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];
    
    GTLQueryPlus *query =
    [GTLQueryPlus queryForPeopleListWithUserId:@"me"
                                    collection:kGTLPlusCollectionVisible];

    NSString *pageToken = fromStart ? nil : self.lastPageToken;
    self.lastPageToken = nil;
    if (pageToken) {
        [query setPageToken: pageToken];
    }

    [plusService executeQuery:query
            completionHandler:^(GTLServiceTicket *ticket,
                                GTLPlusPeopleFeed *peopleFeed,
                                NSError *error) {

                self.lastPageToken = peopleFeed.nextPageToken;

                if (error) {
                    LogError(TAG, @"Failed getting contacts");
                    fail([error localizedDescription]);
                } else {

                    NSArray* rawContacts = peopleFeed.items;
                    
                    NSMutableArray *contacts = [NSMutableArray array];
                    
                    for (GTLPlusPerson *rawContact in rawContacts) {
                        UserProfile *contact = [self parseGoogleContact:rawContact];
                        
                        [contacts addObject:contact];
                    }
                    
                    success(contacts, peopleFeed.nextPageToken != nil);
                }
            }];
}

- (void)getFeed:(bool)fromFirst success:(feedsActionSuccess)success fail:(feedsActionFail)fail {
    LogDebug(TAG, @"getFeed");

    GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
    plusService.retryEnabled = YES;
    [plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];

    GTLQueryPlus *query = [GTLQueryPlus queryForActivitiesListWithUserId:@"me" collection:kGTLPlusCollectionPublic];

    NSString *pageToken = fromFirst ? nil : self.lastFeedPageToken;
    self.lastFeedPageToken = nil;
    if (pageToken) {
        [query setPageToken:pageToken];
    }

    [plusService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLPlusActivityFeed * feed, NSError *error) {
        if (!error) {
            NSMutableArray *feedsResult = [NSMutableArray new];
            for (GTLPlusActivity *activity in feed.items) {
                NSString *stringToFeed = @"";
                if (activity.object && activity.object.content) {
                    stringToFeed = activity.object.content;
                }
                [feedsResult addObject:stringToFeed];
            }
            success(feedsResult, feed.nextPageToken != nil);
        } else {
            fail(error.localizedDescription);
        }
    }];
}

- (void)like:(NSString *)pageId{
    
    NSString *baseURL = @"gplus://plus.google.com/";

    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:baseURL]])
    {
        baseURL = @"https://plus.google.com/";
    }
    
    if ([pageId rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound)
    {
        pageId = [NSString stringWithFormat:@"+%@", pageId];
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseURL, pageId]]];
}

- (void)invite:(NSString *)inviteMessage dialogTitle:(NSString *)dialogTitle success:(inviteSuccess)success
          fail:(inviteFail)fail cancel:(inviteCancel)cancel {
    if (fail) {
        fail(@"Invitation isn't supported in Google+.");
    }
}

-(void)setSocialActionBlocks:(socialActionSuccess)success fail:(socialActionFail)fail{
    self.socialActionSuccess = success;
    self.socialActionFail = fail;
}

- (void)clearSocialActionBlocks {
    self.socialActionSuccess = nil;
    self.socialActionFail = nil;
}

@end

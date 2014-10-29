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

#import "SocialController.h"
#import "ISocialProvider.h"
#import "UserProfileEventHandling.h"
#import "SocialActionUtils.h"
#import "Reward.h"
#import "SoomlaUtils.h"
#import "ISocialProvider.h"

@implementation SocialController

static NSString* TAG = @"SOOMLA SocialController";


- (id)init {
    if (self = [super initWithoutLoadingProviders]) {
        
        // TODO: Check if providerPkgPrefix can be omitted completely in iOS
        if (![self loadProvidersWithProtocol:@protocol(ISocialProvider)]) {
            NSString* msg = @"You don't have a ISocialProvider service attached. \
            Decide which ISocialProvider you want, and add its static libraries \
            and headers to the target's search path.";
            LogDebug(TAG, msg);
        }
    }
    
    return self;
}

- (void)updateStatusWithProvider:(Provider)provider andStatus:(NSString *)status andPayload:(NSString *)payload andReward:(Reward *)reward {
    
    id<ISocialProvider> socialProvider = (id<ISocialProvider>)[self getProvider:provider];
    
    
    // Perform update status process
    [UserProfileEventHandling postSocialActionStarted:provider withType:UPDATE_STATUS withPayload:payload];
    [socialProvider updateStatus:status success:^{
        [UserProfileEventHandling postSocialActionFinished:provider withType:UPDATE_STATUS withPayload:payload];
        
        if (reward) {
            [reward give];
        }
    } fail:^(NSString *message) {
        [UserProfileEventHandling postSocialActionFailed:provider withType:UPDATE_STATUS withMessage:message withPayload:payload];
    }];
}

- (void)updateStatusWithProviderDialog:(Provider)provider andLink:(NSString *)link andPayload:(NSString *)payload andReward:(Reward *)reward {
    id<ISocialProvider> socialProvider = (id<ISocialProvider>)[self getProvider:provider];
    
    
    // Perform update status process with dialog
    [UserProfileEventHandling postSocialActionStarted:provider withType:UPDATE_STATUS withPayload:payload];
    [socialProvider updateStatusWithProviderDialog:link success:^{
        [UserProfileEventHandling postSocialActionFinished:provider withType:UPDATE_STATUS withPayload:payload];
        
        if (reward) {
            [reward give];
        }
    } fail:^(NSString *message) {
        [UserProfileEventHandling postSocialActionFailed:provider withType:UPDATE_STATUS withMessage:message withPayload:payload];
    }];
}

- (void)updateStoryWithProvider:(Provider)provider
                     andMessage:(NSString *)message
                        andName:(NSString *)name
                     andCaption:(NSString *)caption
                 andDescription:(NSString *)description
                        andLink:(NSString *)link
                     andPicture:(NSString *)picture
                     andPayload:(NSString *)payload
                      andReward:(Reward *)reward {

    id<ISocialProvider> socialProvider = (id<ISocialProvider>)[self getProvider:provider];
    
    // Perform update story process
    [UserProfileEventHandling postSocialActionStarted:provider withType:UPDATE_STORY withPayload:payload];
    [socialProvider updateStoryWithMessage:message andName:name andCaption:caption
                            andDescription:description andLink:link andPicture:picture success:^{
        
        [UserProfileEventHandling postSocialActionFinished:provider withType:UPDATE_STORY withPayload:payload];
        if (reward) {
            [reward give];
        }
    } fail:^(NSString *message) {
        [UserProfileEventHandling postSocialActionFailed:provider withType:UPDATE_STORY withMessage:message withPayload:payload];
    }];
}

- (void)updateStoryWithProviderDialog:(Provider)provider
                              andName:(NSString *)name
                           andCaption:(NSString *)caption
                       andDescription:(NSString *)description
                              andLink:(NSString *)link
                           andPicture:(NSString *)picture
                           andPayload:(NSString *)payload
                            andReward:(Reward *)reward {
    id<ISocialProvider> socialProvider = (id<ISocialProvider>)[self getProvider:provider];
    
    // Perform update story process
    [UserProfileEventHandling postSocialActionStarted:provider withType:UPDATE_STORY withPayload:payload];
    [socialProvider updateStoryWithMessageDialog:name andCaption:caption
                            andDescription:description andLink:link andPicture:picture success:^{
                                
                                [UserProfileEventHandling postSocialActionFinished:provider withType:UPDATE_STORY withPayload:payload];
                                if (reward) {
                                    [reward give];
                                }
                            } fail:^(NSString *message) {
                                [UserProfileEventHandling postSocialActionFailed:provider withType:UPDATE_STORY withMessage:message withPayload:payload];
                            }];
}

- (void)uploadImageWithProvider:(Provider)provider
                     andMessage:(NSString *)message
                    andFilePath:(NSString *)filePath
                     andPayload:(NSString *)payload
                      andReward:(Reward *)reward {
    
    id<ISocialProvider> socialProvider = (id<ISocialProvider>)[self getProvider:provider];
    
    // Perform upload image process
    [UserProfileEventHandling postSocialActionStarted:provider withType:UPLOAD_IMAGE withPayload:payload];
    [socialProvider uploadImageWithMessage:message andFilePath:filePath success:^{
        
        [UserProfileEventHandling postSocialActionFinished:provider withType:UPLOAD_IMAGE withPayload:payload];
        if (reward) {
            [reward give];
        }
    } fail:^(NSString *message) {
        [UserProfileEventHandling postSocialActionFailed:provider withType:UPLOAD_IMAGE withMessage:message withPayload:payload];
    }];
}

- (void)getContactsWith:(Provider)provider andPayload:(NSString *)payload andReward:(Reward *)reward {
    
    id<ISocialProvider> socialProvider = (id<ISocialProvider>)[self getProvider:provider];
    
    // Perform get contacts process
    [UserProfileEventHandling postGetContactsStarted:provider withType:GET_CONTACTS withPayload:payload];
    [socialProvider getContacts:^(NSArray *contacts) {

        [UserProfileEventHandling postGetContactsFinished:provider withType:GET_CONTACTS withContacts:contacts withPayload:payload];
        if (reward) {
            [reward give];
        }
    } fail:^(NSString *message) {
        [UserProfileEventHandling postGetContactsFailed:provider withType:GET_CONTACTS withMessage:message withPayload:payload];
    }];
}

- (void)getFeed:(Provider)provider andPayload:(NSString *)payload andReward:(Reward *)reward {

    id<ISocialProvider> socialProvider = (id<ISocialProvider>)[self getProvider:provider];

    // Perform get feed process
    [UserProfileEventHandling postGetFeedStarted:provider withType:GET_FEED withPayload:payload];
    [socialProvider getFeed:^(NSArray *feeds) {

        [UserProfileEventHandling postGetFeedFinished:provider withType:GET_FEED withContacts:feeds withPayload:payload];
        if (reward) {
            [reward give];
        }
    } fail:^(NSString *message) {
        [UserProfileEventHandling postGetFeedFailed:provider withType:GET_FEED withMessage:message withPayload:payload];
    }];
}

- (void)like:(Provider)provider andPageName:(NSString *)pageName andReward:(Reward *)reward {
    id<ISocialProvider> socialProvider = (id<ISocialProvider>)[self getProvider:provider];
    
    [socialProvider like:pageName];
    if (reward) {
        [reward give];
    }
}

@end

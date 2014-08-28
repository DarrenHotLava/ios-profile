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

- (void)updateStatusWithProvider:(enum Provider)provider andStatus:(NSString *)status andReward:(Reward *)reward {
    
    id<ISocialProvider> socialProvider = (id<ISocialProvider>)[self getProvider:provider];
    
    
    // Perform update status process
    [UserProfileEventHandling postSocialActionStarted:provider withType:UPDATE_STATUS];
    [socialProvider updateStatus:status success:^{
        [UserProfileEventHandling postSocialActionFinished:provider withType:UPDATE_STATUS];
        
        if (reward) {
            [reward give];
        }
    } fail:^(NSString *message) {
        [UserProfileEventHandling postSocialActionFailed:provider withType:UPDATE_STATUS withMessage:message];
    }];
}

- (void)updateStoryWithProvider:(enum Provider)provider
                     andMessage:(NSString *)message
                        andName:(NSString *)name
                     andCaption:(NSString *)caption
                 andDescription:(NSString *)description
                        andLink:(NSString *)link
                     andPicture:(NSString *)picture
                      andReward:(Reward *)reward {

    id<ISocialProvider> socialProvider = (id<ISocialProvider>)[self getProvider:provider];
    
    // Perform update story process
    [UserProfileEventHandling postSocialActionStarted:provider withType:UPDATE_STORY];
    [socialProvider updateStoryWithMessage:message andName:name andCaption:caption
                            andDescription:description andLink:link andPicture:picture success:^{
        
        [UserProfileEventHandling postSocialActionFinished:provider withType:UPDATE_STORY];
        if (reward) {
            [reward give];
        }
    } fail:^(NSString *message) {
        [UserProfileEventHandling postSocialActionFailed:provider withType:UPDATE_STORY withMessage:message];
    }];
}

- (void)uploadImageWithProvider:(enum Provider)provider
                     andMessage:(NSString *)message
                    andFilePath:(NSString *)filePath
                      andReward:(Reward *)reward {
    
    id<ISocialProvider> socialProvider = (id<ISocialProvider>)[self getProvider:provider];
    
    // Perform upload image process
    [UserProfileEventHandling postSocialActionStarted:provider withType:UPLOAD_IMAGE];
    [socialProvider uploadImageWithMessage:message andFilePath:filePath success:^{
        
        [UserProfileEventHandling postSocialActionFinished:provider withType:UPLOAD_IMAGE];
        if (reward) {
            [reward give];
        }
    } fail:^(NSString *message) {
        [UserProfileEventHandling postSocialActionFailed:provider withType:UPLOAD_IMAGE withMessage:message];
    }];
}


//- (void)uploadImageWithProvider:(enum Provider)provider
//                     andMessage:(NSString *)message
//                    andFileName:(NSString *)fileName
//                      andBitmap:(Bitmap *)bitmap
//                 andJpegQuality:(int)jpegQuality
//                      andReward:(Reward *)reward {
//    
//    id<ISocialProvider> socialProvider = (id<ISocialProvider>)[self getProvider:provider];
//    
//    // Perform upload image process
//    [UserProfileEventHandling postSocialActionStarted:UPLOAD_IMAGE];
//    [socialProvider uploadImageWithMessage:message andFileName:fileName andBitmap:bitmap andJpegQuality:jpegQuality success:^{
//
//        [UserProfileEventHandling postSocialActionFinished:UPLOAD_IMAGE];
//        if (reward) {
//            [reward give];
//        }
//    } fail:^(NSString *message) {
//        [UserProfileEventHandling postSocialActionFailed:UPLOAD_IMAGE withMessage:message];
//    }];
//}

- (void)getContactsWith:(enum Provider)provider andReward:(Reward *)reward {
    
    id<ISocialProvider> socialProvider = (id<ISocialProvider>)[self getProvider:provider];
    
    // Perform get contacts process
    [UserProfileEventHandling postGetContactsStarted:provider withType:GET_CONTACTS];
    [socialProvider getContacts:^(NSArray *contacts) {

        [UserProfileEventHandling postGetContactsFinished:provider withType:GET_CONTACTS withContacts:contacts];
        if (reward) {
            [reward give];
        }
    } fail:^(NSString *message) {
        [UserProfileEventHandling postGetContactsFailed:provider withType:GET_CONTACTS withMessage:message];
    }];
}

- (void)getFeed:(enum Provider)provider andReward:(Reward *)reward {

    id<ISocialProvider> socialProvider = (id<ISocialProvider>)[self getProvider:provider];

    // Perform get feed process
    [UserProfileEventHandling postGetFeedStarted:provider withType:GET_FEED];
    [socialProvider getFeed:^(NSArray *feeds) {

        [UserProfileEventHandling postGetFeedFinished:provider withType:GET_FEED withContacts:feeds];
        if (reward) {
            [reward give];
        }
    } fail:^(NSString *message) {
        [UserProfileEventHandling postGetFeedFailed:provider withType:GET_FEED withMessage:message];
    }];
}



@end

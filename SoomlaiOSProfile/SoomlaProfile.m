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

#import "SoomlaProfile.h"
#import "Reward.h"
#import "AuthController.h"
#import "SocialController.h"
#import "UserProfileUtils.h"
#import "UserProfileEventHandling.h"

#import <UIKit/UIKit.h>

// if using Unity social provider this is YES
BOOL UsingExternalProvider;

@implementation SoomlaProfile

+ (void)usingExternalProvider:(BOOL)isExternal {
    
    UsingExternalProvider = isExternal;
}

+ (BOOL)isUsingExternalProvider {
    return UsingExternalProvider;
}

- (id)init {
    if (self = [super init]) {
        if (UsingExternalProvider) {
            authController = [[AuthController alloc] initWithoutLoadingProviders];
            socialController = [[SocialController alloc] initWithoutLoadingProviders];
        }
        else {
            authController = [[AuthController alloc] init];
            socialController = [[SocialController alloc] init];
        }

        [UserProfileEventHandling postProfileInitialized];
    }
    
    return self;
}

- (void)loginWithProvider:(Provider)provider {
    [self loginWithProvider:provider andReward:nil];
}

- (void)loginWithProvider:(Provider)provider andReward:(Reward *)reward {
    @try {
        [authController loginWithProvider:provider andReward:reward];
    }
    @catch (NSException *exception) {

        // TODO: implement logic like in java that will raise the exception. Currently not raised
        [socialController loginWithProvider:provider andReward:reward];
    }
}

- (void)logoutWithProvider:(Provider)provider {
    @try {
        [authController logoutWithProvider:provider];
    }
    @catch (NSException *exception) {

        // TODO: implement logic like in java that will raise the exception. Currently not raised
        [socialController logoutWithProvider:provider];
    }
}

- (BOOL)isLoggedInWithProvider:(Provider)provider {
    @try {
        return [authController isLoggedInWithProvider:provider];
    }
    @catch (NSException *exception) {
        
        // TODO: implement logic like in java that will raise the exception. Currently not raised
        return [socialController isLoggedInWithProvider:provider];
    }

}

- (UserProfile *)getStoredUserProfileWithProvider:(Provider)provider {
    @try {
        [authController getStoredUserProfileWithProvider:provider];
    }
    @catch (NSException *exception) {
        
        // TODO: implement logic like in java that will raise the exception. Currently not raised
        [socialController getStoredUserProfileWithProvider:provider];
    }
}

- (void)updateStatusWithProvider:(Provider)provider andStatus:(NSString *)status andReward:(Reward *)reward {
    [socialController updateStatusWithProvider:provider andStatus:status andReward:reward];
}

- (void)updateStoryWithProvider:(Provider)provider
                     andMessage:(NSString *)message
                        andName:(NSString *)name
                     andCaption:(NSString *)caption
                 andDescription:(NSString *)description
                        andLink:(NSString *)link
                     andPicture:(NSString *)picture
                      andReward:(Reward *)reward {
    [socialController updateStoryWithProvider:provider andMessage:message andName:name andCaption:caption
                               andDescription:description andLink:link andPicture:picture andReward:reward];
}

- (void)uploadImageWithProvider:(Provider)provider
                     andMessage:(NSString *)message
                    andFilePath:(NSString *)filePath
                      andReward:(Reward *)reward {
    [socialController uploadImageWithProvider:provider andMessage:message andFilePath:filePath andReward:reward];
}

- (void)getContactsWithProvider:(Provider)provider andReward:(Reward *)reward {
    [socialController getContactsWith:provider andReward:reward];
}

- (void)getFeedWithProvider:(Provider)provider andReward:(Reward *)reward {
    [socialController getFeed:provider andReward:reward];
}

- (void)like:(Provider)provider andPageName:(NSString *)pageName andReward:(Reward *)reward {
    [socialController like:provider andPageName:pageName andReward:reward];
}

- (void)openAppRatingPage {
    NSString* templateReviewURL = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=APP_ID";
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* reviewURL = [templateReviewURL stringByReplacingOccurrencesOfString:@"APP_ID" withString:appID];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:reviewURL]];
    
    [UserProfileEventHandling postUserRating];
}

// private

+ (SoomlaProfile*)getInstance {
    static SoomlaProfile* _instance = nil;
    
    @synchronized( self ) {
        if( _instance == nil ) {
            _instance = [[SoomlaProfile alloc ] init];
        }
    }
    
    return _instance;
}

@end

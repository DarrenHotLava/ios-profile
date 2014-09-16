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

#import "UserProfileUtils.h"

@class Reward;
@class UserProfile;
@class AuthController;
@class SocialController;

/**
 This is the main class for the SOOMLA User Profile module.  This class should be initialized once,
 after <code>Soomla.initialize()</code> is invoked.  Use this class to perform authentication and social
 actions on behalf of the user that will grant him \ her rewards in your game.
 */
@interface SoomlaProfile : NSObject {
    
    @private
    AuthController* authController;
    SocialController* socialController;
}

+ (void)usingExternalProvider:(BOOL)isExternal;
+ (BOOL)isUsingExternalProvider;

/**
 Constructor.
 
 Initializes the Profile module.  Call this method after <code>Soomla.initialize()</code>
 */
- (void)initialize;

/**
 Login to the given provider
 
 @param provider The provider to use
 */
- (void)loginWithProvider:(Provider)provider;

/**
 * Login to the given provider and grant the user a reward.
 *
 * @param provider The provider to use
 * @param reward The reward to give the user for logging in.
 *               If you want your reward to be given more than once, make it repeatable
 */
- (void)loginWithProvider:(Provider)provider andReward:(Reward *)reward;

/**
 Logout of the given provider
 
 @param provider The provider to use
 */
- (void)logoutWithProvider:(Provider)provider;

/**
 Checks if the user is logged in with given provider
 
 @param provider The provider to use
 @return YES if the user is logged-in with the given provider, NO otherwise
 */
- (BOOL)isLoggedInWithProvider:(Provider)provider;

/**
 Fetches the user's profile for the given provider from the local device storage
 
 @param provider The provider to use
 @return The user profile
 */
- (UserProfile *)getStoredUserProfileWithProvider:(Provider)provider;

/**
 Shares the given status to the user's feed and grants the user a reward.
 
 @param provider The provider to use
 @param status The text to share
 @param reward The reward to give the user
 */
- (void)updateStatusWithProvider:(Provider)provider andStatus:(NSString *)status andReward:(Reward *)reward;

/**
 Shares a story to the user's feed and grants the user a reward.
 
 @param provider The provider to use
 @param message The main text which will appear in the story
 @param name The headline for the link which will be integrated in the
 story
 @param caption The sub-headline for the link which will be
 integrated in the story
 @param description The description for the link which will be
 integrated in the story
 @param link The link which will be integrated into the user's story
 @param picture a Link to a picture which will be featured in the link
 @param reward The reward to give the user
 */
- (void)updateStoryWithProvider:(Provider)provider
                     andMessage:(NSString *)message
                        andName:(NSString *)name
                     andCaption:(NSString *)caption
                 andDescription:(NSString *)description
                        andLink:(NSString *)link
                     andPicture:(NSString *)picture
                      andReward:(Reward *)reward;

/**
 Shares a photo to the user's feed and grants the user a reward.
 
 @param provider The provider to use
 @param message A text that will accompany the image
 @param filePath The desired image's location on the device
 @param reward The reward to give the user
 */
- (void)uploadImageWithProvider:(Provider)provider
                   andMessage:(NSString *)message
                   andFilePath:(NSString *)filePath
                      andReward:(Reward *)reward;


/**
 Fetches the user's contact list and grants the user a reward.
 
 @param provider The provider to use
 @param reward The reward to grant
 */
- (void)getContactsWithProvider:(Provider)provider andReward:(Reward *)reward;

/**
Fetches the user's feed and grants the user a reward.

@param provider The provider to use
@param reward The reward to grant
*/
- (void)getFeedWithProvider:(Provider)provider andReward:(Reward *)reward;

/**
 Opens up a page to like for the user (external)
 
 @param provider The provider to like page on
 @param pageName The page to open on the provider
 @param reward The reward to grant when page is liked
 */
- (void)like:(Provider)provider andPageName:(NSString *)pageName andReward:(Reward *)reward;

/**
 Utility method to open up the market application rating page
 */
- (void)openAppRatingPage;

/**
 Retrieves the singleton instance of `SoomlaProfile`
 @return the singleton instance of `SoomlaProfile`
 */
+ (SoomlaProfile *)getInstance;

@end

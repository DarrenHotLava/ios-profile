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

#import "AuthController.h"
#import "UserProfileUtils.h"

@class Reward;

/**
 A class that loads all social providers and performs social
 actions on with them.  This class wraps the provider's social
 actions in order to connect them to user profile data and rewards.
 
 Inheritance: SocialController > AuthController > ProviderLoader
 */
@interface SocialController : AuthController

/**
 Constructor
 
 Loads all social providers
 */
- (id)init;

/**
 Shares the given status to the user's feed
 
 @param provider the provider to use
 @param status the text to share
 @param reward the reward to grant for sharing
 */
- (void)updateStatusWithProvider:(enum Provider)provider andStatus:(NSString *)status andReward:(Reward *)reward;

/**
 Shares a story to the user's feed.  This is very oriented for Facebook.
 
 @param provider
 @param message
 @param name
 @param caption
 @param description
 @param link
 @param picture
 @param reward
 */
- (void)updateStoryWithProvider:(enum Provider)provider
                     andMessage:(NSString *)message
                        andName:(NSString *)name
                     andCaption:(NSString *)caption
                 andDescription:(NSString *)description
                        andLink:(NSString *)link
                     andPicture:(NSString *)picture
                      andReward:(Reward *)reward;

/**
 Shares a photo to the user's feed.  This is very oriented for Facebook.
 
 @param provider The provider to use
 @param message A text that will accompany the image
 @param filePath The desired image's location on the device
 @param reward The reward to grant for sharing the photo
 */
- (void)uploadImageWithProvider:(enum Provider)provider
                     andMessage:(NSString *)message
                    andFilePath:(NSString *)filePath
                      andReward:(Reward *)reward;

///**
// * Shares a photo to the user's feed.  This is very oriented for Facebook.
// *
// * @param provider The provider to use
// * @param message A text that will accompany the image
// * @param fileName The desired image's file name
// * @param bitmap The image to share
// * @param jpegQuality The image's numeric quality
// * @param reward The reward to grant for sharing the photo
// */
//- (void)uploadImageWithProvider:(enum Provider)provider
//                     andMessage:(NSString *)message
//                    andFileName:(NSString *)fileName
//                      andBitmap:(Bitmap *)bitmap
//                 andJpegQuality:(int)jpegQuality
//                      andReward:(Reward *)reward;

/**
 Fetches the user's contact list
 
 @param provider The provider to use
 @param reward The reward to grant
 */
- (void)getContactsWith:(enum Provider)provider andReward:(Reward *)reward;

/**
Fetches the user's feed.

@param provider The provider to use
@param reward The reward to grant
*/
- (void)getFeed:(enum Provider)provider andReward:(Reward *)reward;


@end

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

#import "IAuthProvider.h"
#import "SocialCallbacks.h"




/**
 A provider that exposes social capabilities such as sharing, fetching user feeds, uploading images etc.
 */
@protocol ISocialProvider <IAuthProvider>

/**
 Shares the given status to the user's feed
 
 @param status the text to share
 @param success a status update success callback
 @param fail a status update failure callback
 */
- (void)updateStatus:(NSString *)status success:(socialActionSuccess)success fail:(socialActionFail)fail;

/**
 Share a story to the user's feed.  This is very oriented for Facebook.
 
 @param message
 @param name
 @param caption
 @param description
 @param link
 @param picture
 @param socialActionListener
 */
- (void)updateStoryWithMessage:(NSString *)message
                       andName:(NSString *)name
                    andCaption:(NSString *)caption
                andDescription:(NSString *)description
                       andLink:(NSString *)link
                    andPicture:(NSString *)picture
                       success:(socialActionSuccess)success
                          fail:(socialActionFail)fail;

/**
 Fetches the user's contact list
 
 @param success a contacts fetch success callback
 @param fail a contacts fetch failure callback
 */
- (void)getContacts:(contactsActionSuccess)success fail:(contactsActionFail)fail;

/**
 Fetches the user's feed
 
 @param success a contacts fetch success callback
 @param fail a contacts fetch failure callback
 */
- (void)getFeed:(feedsActionSuccess)success fail:(feedsActionFail)fail;

/**
 Shares a photo to the user's feed
 
 @param message A text that will accompany the image
 @param filePath The desired image's location on the device
 @param success an upload image success callback
 @param fail an upload image failure callback
 */
- (void)uploadImageWithMessage:(NSString *)message
                   andFilePath:(NSString *)filePath
                       success:(socialActionSuccess)success
                          fail:(socialActionFail)fail;

///**
// Share's a photo to the user's feed
// 
// @param message A text that will accompany the image
// @param fileName Where bitmap will be saved before upload
// @param bitmap Bitmap to be uploaded
// @param jpegQuality Hint to the compressor, 0-100. 0 meaning compress for small size,
//                    100 meaning compress for max quality. Some formats,
//                    like PNG which is lossless, will ignore the quality setting
// @param success an upload image success callback
// @param fail an upload image failure callback
// */
//- (void)uploadImageWithMessage:(NSString *)message
//                   andFileName:(NSString *)fileName
//                     andBitmap:()bitmap
//                andJpegQuality:(int)jpegQuality
//                       success:(socialActionSuccess)success
//                          fail:(socialActionFail)fail;

/**
 Opens up a page to like for the user (external)
 
 @param pageName The page to open on the provider
 @param reward The reward to grant when page is liked
 */
- (void)like:(NSString *)pageName;

@end

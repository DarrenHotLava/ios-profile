/*
 Copyright (C) 2012-2015 Soomla Inc.

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

#import "SoomlaGameCenter.h"
#import "UserProfile.h"
#import <GameKit/GameKit.h>

@implementation SoomlaGameCenter {
    BOOL _autoLogin;
}

const Provider currentProvider = GAME_CENTER;

/**
 Applies special initialization parameters to the provider

 @param providerParams the parameters needed by the provider to initialize
 */
- (void)applyParams:(NSDictionary *)providerParams {
    if (providerParams) {
        _autoLogin = providerParams[@"autoLogin"] != nil ? [providerParams[@"autoLogin"] boolValue] : NO;
    } else {
        _autoLogin = NO;
    }
}

/**
 Retrieves the `Provider` value of the provider it implements
 @return the `Provider` value of the provider it implements
 */
- (Provider)getProvider {
    return currentProvider;
}

/**
 Logs in with the authentication provider

 @param sucesss a login sucess callback
 @param fail a login failure callback
 @param cancel a login cancelled callback
 */
- (void)login:(loginSuccess)success fail:(loginFail)fail cancel:(loginCancel)cancel {
    [[GKLocalPlayer localPlayer] setAuthenticateHandler:^(UIViewController *viewController, NSError *error) {
        if (error != nil) {
            if (fail != nil) {
                fail(error.localizedDescription);
            }
            return;
        }
        if (viewController != nil)
        {
            if ([UIApplication sharedApplication].keyWindow.rootViewController) {
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:viewController animated:YES completion:nil];
            }
        }
        else if ([GKLocalPlayer localPlayer].isAuthenticated) {
            if (success != nil) {
                success(currentProvider);
            }
        } else {
            if (cancel != nil) {
                cancel();
            }
        }
    }];
}

/**
 Fetches the user profile from the authentication provider

 @param sucesss a fetch sucess callback
 @param fail a fetch failure callback
 */
- (void)getUserProfile:(userProfileSuccess)success fail:(userProfileFail)fail {
    NSString *playerId = [GKLocalPlayer localPlayer].playerID;
    if (playerId != nil) {
        [GKPlayer loadPlayersForIdentifiers:@[playerId] withCompletionHandler:^(NSArray *players, NSError *error) {
            if (players.count) {
                if (success != nil) {
                    success([self userProfileFromGameKitPlayer:((GKPlayer *)players[0])]);
                }
            } else {
                if (fail != nil) {
                    fail(@"Cannot read profile: playerID is incorrect.");
                }
            }
        }];
    } else {
        if (fail != nil) {
            fail(@"Cannot read profile: user ins't authenticated.");
        }
    }
}

-(UserProfile *)userProfileFromGameKitPlayer:(GKPlayer *)player {
    NSString *firstName = [[player.displayName componentsSeparatedByString:@" "] firstObject];
    NSString *lastName = [[player.displayName componentsSeparatedByString:@" "] lastObject];
    return [[UserProfile alloc] initWithProvider:currentProvider andProfileId:player.playerID andUsername:player.alias
                                        andEmail:@"" andFirstName:(firstName ? firstName : @"")
                                     andLastName:(lastName ? lastName : @"") andExtra:nil];
}

/**
 Logs out of the authentication provider

 @param sucesss a logout sucess callback
 @param fail a logout failure callback
 */
- (void)logout:(logoutSuccess)success fail:(logoutFail)fail {
    fail(@"GameCenter doesn't support logging out.");
}

/**
 Checks if the user is logged-in using the authentication provider

 @return YES if the user is already logged-in using the authentication provider,
 NO otherwise
 */
- (BOOL)isLoggedIn {
    return [GKLocalPlayer localPlayer].authenticated;
}

/**
* Return value of autoLogin setting of the provider.
* @return value of autoLogin
*/
- (BOOL)isAutoLogin {
    return _autoLogin;
}

/**
 Helper method to assist with browser-based authentication for the provider.
 Based on the URL scheme defined for the provider, it will try and handle the
 callback of browser authentication

 @param url The URL which caused the application to launch and receive a
 callback
 @param sourceApplication The bundle ID of the app that is requesting your app
 to open the URL (url).
 @param annotation A property list object supplied by the source app to
 communicate information to the receiving app.

 @return YES if the provider was able to handle the URL, NO otherwise
 */
- (BOOL)tryHandleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return NO;
}

/**
 Shares the given status to the user's feed

 @param status the text to share
 @param success a status update success callback
 @param fail a status update failure callback
 */
- (void)updateStatus:(NSString *)status success:(socialActionSuccess)success fail:(socialActionFail)fail {
    fail(@"GameCenter doesn't support status updating.");
}

/**
 Shares the given status and link to the user's feed using the provider's
 native dialog (when available)

 @param link the link to share (could be nil when not needed)
 @param success a status update success callback
 @param fail a status update failure callback
 */
- (void)updateStatusWithProviderDialog:(NSString *)link success:(socialActionSuccess)success fail:(socialActionFail)fail {
    fail(@"GameCenter doesn't support status updating.");
}

/**
 Share a story to the user's feed.  This is very oriented for Facebook.

 @param message The main text which will appear in the story
 @param name The headline for the link which will be integrated in the
 story
 @param caption The sub-headline for the link which will be
 integrated in the story
 @param description The description for the link which will be
 integrated in the story
 @param link The link which will be integrated into the user's story
 @param picture a Link to a picture which will be featured in the link
 @param socialActionListener an update story failure callback
 */
- (void)updateStoryWithMessage:(NSString *)message
                       andName:(NSString *)name
                    andCaption:(NSString *)caption
                andDescription:(NSString *)description
                       andLink:(NSString *)link
                    andPicture:(NSString *)picture
                       success:(socialActionSuccess)success
                          fail:(socialActionFail)fail {
    fail(@"GameCenter doesn't support story updating.");
}

/**
 Share a story to the user's feed.  This is very oriented for Facebook.
 Using the provider's native dialog (when available)

 @param name The headline for the link which will be integrated in the
 story
 @param caption The sub-headline for the link which will be
 integrated in the story
 @param description The description for the link which will be
 integrated in the story
 @param link The link which will be integrated into the user's story
 @param picture a Link to a picture which will be featured in the link
 @param socialActionListener an update story failure callback
 */
- (void)updateStoryWithMessageDialog:(NSString *)name
                          andCaption:(NSString *)caption
                      andDescription:(NSString *)description
                             andLink:(NSString *)link
                          andPicture:(NSString *)picture
                             success:(socialActionSuccess)success
                                fail:(socialActionFail)fail {
    fail(@"GameCenter doesn't support story updating.");
}

/**
 Fetches the user's contact list

 @param fromStart Should we reset pagination or request the next page
 @param success a contacts fetch success callback
 @param fail a contacts fetch failure callback
 */
- (void)getContacts:(bool)fromStart success:(contactsActionSuccess)success fail:(contactsActionFail)fail {
    [[GKLocalPlayer localPlayer] loadFriendPlayersWithCompletionHandler:^(NSArray *friendPlayers, NSError *error) {
        if (error == nil) {
            NSMutableArray *result = [NSMutableArray new];
            for (GKPlayer *player in friendPlayers) {
                UserProfile *parsedProfile = [self userProfileFromGameKitPlayer:player];
                if (parsedProfile) {
                    [result addObject:parsedProfile];
                }
            }
            success(result, NO);
        } else {
            fail(error.localizedDescription);
        }
    }];
}

/**
 Fetches the user's feed

 @param success a contacts fetch success callback
 @param fail a contacts fetch failure callback
 */
- (void)getFeed:(bool)fromStart success:(feedsActionSuccess)success fail:(feedsActionFail)fail {
    fail(@"GameCenter doesn't support feed.");
}


/**
 Sends an invite

 @param success a invite success callback
 @param fail a invite failure callback
 @param cancel a invite cancel callback
 */
- (void)invite:(NSString *)inviteMessage dialogTitle:(NSString *)dialogTitle success:(inviteSuccess)success
          fail:(inviteFail)fail cancel:(inviteCancel)cancel {
    fail(@"GameCenter doesn't support invitations.");
}

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
                          fail:(socialActionFail)fail {
    fail(@"GameCenter doesn't support image uploading.");
}

/**
 Shares a photo to the user's feed using image data

 @param message A text that will accompany the image
 @param fileName The desired image's location on the device
 @param imageData The desierd image's data
 @param success an upload image success callback
 @param fail an upload image failure callback
 */
- (void)uploadImageWithMessage:(NSString *)message
              andImageFileName: (NSString *)fileName
                  andImageData: (NSData *)imageData
                       success:(socialActionSuccess)success
                          fail:(socialActionFail)fail {
    fail(@"GameCenter doesn't support image uploading.");
}

/**
 Opens up a page to like for the user (external)

 @param pageId The page to open on the provider
 @param reward The reward to grant when page is liked
 */
- (void)like:(NSString *)pageId {
    NSLog(@"GameCenter doesn't support page liking.");
}

@end

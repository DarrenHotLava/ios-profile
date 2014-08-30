//
//  AppDelegate.m
//  SoomlaiOSProfileExample
//
//  Created by Gur Dotan on 6/10/14.
//  Copyright (c) 2014 Soomla. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "AppDelegate.h"
#import "Soomla.h"
#import "MuffinRushAssets.h"
#import "SoomlaStore.h"
#import "SoomlaProfile.h"
#import "VirtualItemReward.h"
#import "SoomlaUtils.h"
#import "ViewController.h"

@implementation AppDelegate

@synthesize loginReward, updateStatusReward, uploadImageReward, likeReward;

static NSString* TAG = @"SOOMLA AppDelegate";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Soomla initializeWithSecret:@"LukeSkywalker"];
    id<IStoreAssets> storeAssets = [[MuffinRushAssets alloc] init];
    [[SoomlaStore getInstance] initializeWithStoreAssets:storeAssets];

    self.loginReward = [[VirtualItemReward alloc] initWithRewardId:@"login_reward" andName:@"Login Reward" andAmount:100 andAssociatedItemId:MUFFINS_CURRENCY_ITEM_ID];
    self.updateStatusReward = [[VirtualItemReward alloc] initWithRewardId:@"update_status_reward" andName:@"Update Status Reward" andAmount:150 andAssociatedItemId:MUFFINS_CURRENCY_ITEM_ID];
    self.uploadImageReward = [[VirtualItemReward alloc] initWithRewardId:@"update_story_reward" andName:@"Update Story Reward" andAmount:250 andAssociatedItemId:MUFFINS_CURRENCY_ITEM_ID];
    self.likeReward = [[VirtualItemReward alloc] initWithRewardId:@"like_page_reward" andName:@"Like Page Reward" andAmount:350 andAssociatedItemId:MUFFINS_CURRENCY_ITEM_ID];

    // Override point for customization after application launch.
    return YES;
}


// During the Facebook login flow, your app passes control to the Facebook iOS app or Facebook in a mobile browser.
// After authentication, your app will be called back with the session information.
// Override application:openURL:sourceApplication:annotation to call the FBsession object that handles the incoming URL
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    
    
    BOOL urlWasHandled = [FBAppCall handleOpenURL:url
                                sourceApplication:sourceApplication
                                  fallbackHandler:^(FBAppCall *call) {
                                      LogDebug(TAG, ([NSString stringWithFormat:@"Unhandled deep link: %@", url]));
                                      // Here goes the code to handle the links
                                      // Use the links to show a relevant view of your app to the user
                                  }];
    
    return urlWasHandled;

    
//    return [FBSession.activeSession handleOpenURL:url];
}



							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

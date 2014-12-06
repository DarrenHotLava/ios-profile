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

#import "AppDelegate.h"
#import "Soomla.h"
#import "MuffinRushAssets.h"
#import "SoomlaStore.h"
#import "SoomlaProfile.h"
#import "VirtualItemReward.h"
#import "SoomlaUtils.h"
#import "ViewController.h"
#import "SoomlaConfig.h"
#import "Schedule.h"

@implementation AppDelegate

@synthesize loginReward, updateStatusReward, uploadImageReward, likeReward;

static NSString* TAG = @"SOOMLA AppDelegate";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    DEBUG_LOG = YES;
    
    [Soomla initializeWithSecret:@"LukeSkywalker"];
    
    id<IStoreAssets> storeAssets = [[MuffinRushAssets alloc] init];
    [[SoomlaStore getInstance] initializeWithStoreAssets:storeAssets];

    self.loginReward = [[VirtualItemReward alloc] initWithRewardId:@"login_reward" andName:@"Login Reward" andAmount:100 andAssociatedItemId:MUFFINS_CURRENCY_ITEM_ID];
    self.updateStatusReward = [[VirtualItemReward alloc] initWithRewardId:@"update_status_reward" andName:@"Update Status Reward" andAmount:150 andAssociatedItemId:MUFFINS_CURRENCY_ITEM_ID];
    self.updateStatusReward.schedule = [Schedule AnyTimeUnlimited];
    self.uploadImageReward = [[VirtualItemReward alloc] initWithRewardId:@"update_story_reward" andName:@"Update Story Reward" andAmount:250 andAssociatedItemId:MUFFINS_CURRENCY_ITEM_ID];
    self.likeReward = [[VirtualItemReward alloc] initWithRewardId:@"like_page_reward" andName:@"Like Page Reward" andAmount:350 andAssociatedItemId:MUFFINS_CURRENCY_ITEM_ID];
    
    // Override point for customization after application launch.
    return YES;
}

- (void)onEvent:(NSNotification*)notification {
    if ([notification.name isEqualToString:@"up_social_action_started"]) {
    NSDictionary* extra = notification.userInfo;

//    NSDictionary* userProfile = [extra[@"userProfile"] performSelector:@selector(toDictionary)];
    NSString* action = [NSClassFromString(@"SocialActionUtils") performSelector:@selector(actionNumberToString:) withObject:(NSNumber*)notification.userInfo[@"socialActiontype"]];
//    NSString* provider = [NSClassFromString(@"UserProfileUtils") performSelector:@selector(providerNumberToString:) withObject:(NSNumber*)extra[@"provider"]];
        NSLog(@"ASDJCASDCJASDJASDADSVJASDVJAVJ");
    }
}


// During the Facebook login flow, your app passes control to the Facebook iOS app or Facebook in a mobile browser.
// After authentication, your app will be called back with the session information.
// Override application:openURL:sourceApplication:annotation to call the FBsession object that handles the incoming URL
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    BOOL urlWasHandled = [[SoomlaProfile getInstance] tryHandleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
    
    if (urlWasHandled) {
        return urlWasHandled;
    }
    
    // do some custom handling
    return NO;
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

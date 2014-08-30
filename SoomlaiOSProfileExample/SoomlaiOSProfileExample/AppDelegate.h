//
//  AppDelegate.h
//  SoomlaiOSProfileExample
//
//  Created by Gur Dotan on 6/10/14.
//  Copyright (c) 2014 Soomla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>


@class VirtualItemReward;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    
    @private
    VirtualItemReward* loginReward;
    VirtualItemReward* updateStatusReward;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) VirtualItemReward* loginReward;
@property (strong, nonatomic) VirtualItemReward* updateStatusReward;
@property (strong, nonatomic) VirtualItemReward* uploadImageReward;
@property (strong, nonatomic) VirtualItemReward* likeReward;

@end

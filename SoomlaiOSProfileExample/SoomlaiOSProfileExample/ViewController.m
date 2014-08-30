//
//  ViewController.m
//  SoomlaiOSProfileExample
//
//  Created by Gur Dotan on 6/10/14.
//  Copyright (c) 2014 Soomla. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "ViewController.h"
#import "AppDelegate.h"
#import "SoomlaProfile.h"
#import "UserProfileEventHandling.h"
#import "SoomlaEventHandling.h"
#import "StoreEventHandling.h"
#import "SoomlaUtils.h"
#import "VirtualItemReward.h" // to avoid "incompatible type" warnings
#import "UserProfile.h"


@implementation ViewController

static NSString* TAG = @"SOOMLA ViewController";

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStarted:) name:EVENT_UP_LOGIN_STARTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFinished:) name:EVENT_UP_LOGIN_FINISHED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFailed:) name:EVENT_UP_LOGIN_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginCancelled:) name:EVENT_UP_LOGIN_CANCELLED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutFinished:) name:EVENT_UP_LOGOUT_FINISHED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currencyBalanceChanged:) name:EVENT_CURRENCY_BALANCE_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getContactsFinished:) name:EVENT_UP_GET_CONTACTS_FINISHED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getContactsFailed:) name:EVENT_UP_GET_CONTACTS_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFeedFinished:) name:EVENT_UP_GET_FEED_FINISHED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFeedFailed:) name:EVENT_UP_GET_FEED_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rewardGiven:) name:EVENT_REWARD_GIVEN object:nil];
    
    if ([[SoomlaProfile getInstance] isLoggedInWithProvider:FACEBOOK]) {
        [self showSocialUI];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)buttonTouched:(id)sender {
    
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        [[SoomlaProfile getInstance] logoutWithProvider:FACEBOOK];
    } else {
        
        // Retrieve the app delegate
        AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;

        [[SoomlaProfile getInstance] loginWithProvider:FACEBOOK andReward:appDelegate.loginReward];
    }
}

- (IBAction)shareStatusButtontouched:(id)sender {

    // Retrieve the app delegate
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;

    [[SoomlaProfile getInstance] updateStatusWithProvider:FACEBOOK andStatus:@"Test status" andReward:appDelegate.updateStatusReward];
}

- (IBAction)updateStoryButtonTouched:(id)sender {

    // Retrieve the app delegate
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    
    [[SoomlaProfile getInstance] updateStoryWithProvider:FACEBOOK
                                              andMessage:@"Message"
                                                 andName:@"Name"
                                              andCaption:@"Caption"
                                          andDescription:@"Description"
                                                 andLink:@"https://developers.facebook.com/docs/ios/share/"
                                              andPicture:@"http://i.imgur.com/g3Qc1HN.png"
                                               andReward:appDelegate.updateStatusReward];
}

- (void)loginStarted:(NSNotification*)notification {
    NSString* provider = [UserProfileUtils providerEnumToString:[notification.userInfo[DICT_ELEMENT_PROVIDER] intValue]];
    LogDebug(TAG, ([NSString stringWithFormat:@"Login started with provider: %@", provider]));
}

- (void)loginFinished:(NSNotification*)notification {
    // TODO: extract user profile object from notification
    // NSDictionary* userInfo = notification.userInfo;
    
    [self showSocialUI];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    if (appDelegate.likeReward.canGive == YES) {
        [[SoomlaProfile getInstance] like:FACEBOOK andPageName:@"The.SOOMLA.Project" andReward:appDelegate.likeReward];
    }
}

- (void)showSocialUI {
    LogDebug(TAG, @"Login Success: you are now logged in to Facebook");
    
    if ([[SoomlaProfile getInstance] isLoggedInWithProvider:FACEBOOK]) {
        [self.loginButton setTitle:@"Logout" forState:UIControlStateNormal];
    }
    
    [self.updateStatusButton setHidden:NO];
    [self.updateStoryButton setHidden:NO];
    [self.uploadImageButton setHidden:NO];
    [self.getContactsButton setHidden:NO];
    [self.getFeedButton setHidden:NO];
}

- (void)loginFailed:(NSNotification*)notification {
    LogError(TAG, ([NSString stringWithFormat:@"Login Failed: %@", notification.userInfo[DICT_ELEMENT_MESSAGE]]));
    [self.updateStatusButton setHidden:YES];
    [self.updateStoryButton setHidden:YES];
    [self.uploadImageButton setHidden:YES];
    [self.getContactsButton setHidden:YES];
}

- (void)loginCancelled:(NSNotification*)notification {
    LogDebug(TAG, @"Login Cancelled: you cancelled the login process");
    [self.updateStatusButton setHidden:YES];
    [self.updateStoryButton setHidden:YES];
    [self.uploadImageButton setHidden:YES];
    [self.getContactsButton setHidden:YES];
    [self.getFeedButton setHidden:YES];
}

- (void)logoutFinished:(NSNotification*)notification {
    [self.loginButton setTitle:@"Login with Facebook to earn 100 coins" forState:UIControlStateNormal];
    [self.updateStatusButton setHidden:YES];
    [self.updateStoryButton setHidden:YES];
    [self.uploadImageButton setHidden:YES];
    [self.getContactsButton setHidden:YES];
    [self.getFeedButton setHidden:YES];
}

- (void)currencyBalanceChanged:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    self.currencyLabel.text = [NSString stringWithFormat:@"Coins: %d", [[userInfo objectForKey:@"balance"] intValue]];
}

- (void)getContactsFinished:(NSNotification*)notification {
    NSArray* contacts = notification.userInfo[DICT_ELEMENT_CONTACTS];
    for (int i = 0; i < [contacts count]; i++)
    {
        UserProfile* current = [contacts objectAtIndex:i];
        NSLog(@"%@", [current getFullName]);
    }
}

- (void)getContactsFailed:(NSNotification*)notification {
    NSLog(@"%@ Faild: %@", notification.userInfo[DICT_ELEMENT_SOCIAL_ACTION_TYPE], notification.userInfo[DICT_ELEMENT_MESSAGE]);
}

- (void)getFeedFinished:(NSNotification*)notification {
    NSArray* feeds = notification.userInfo[DICT_ELEMENT_FEEDS];
    for (int i = 0; i < [feeds count]; i++)
    {
        NSString* current = [feeds objectAtIndex:i];
        NSLog(@"%@", current);
    }
}

- (void)getFeedFailed:(NSNotification*)notification {
    NSLog(@"%@ Faild: %@", notification.userInfo[DICT_ELEMENT_SOCIAL_ACTION_TYPE], notification.userInfo[DICT_ELEMENT_MESSAGE]);
}

- (void)rewardGiven:(NSNotification*)notification {
    NSLog(@"Reward Given: %@", [(Reward *)notification.userInfo[DICT_ELEMENT_REWARD] name]);
}


- (IBAction)uploadImageTouched:(id)sender {
    // Open the image picker and set this class as the delegate
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [imagePicker setDelegate:self];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];

    NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath =  [docDirPath stringByAppendingPathComponent:@"tmp.png"];
    NSLog (@"File Path = %@", filePath);
    // Get PNG data from following method
    NSData *myData =     UIImagePNGRepresentation(img);
    // It is better to get JPEG data because jpeg data will store the location and other related information of image.
    [myData writeToFile:filePath atomically:YES];

    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    [[SoomlaProfile getInstance] uploadImageWithProvider:FACEBOOK andMessage:@"Text photo message" andFilePath:filePath andReward:appDelegate.uploadImageReward];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)getContactsButtonTouched:(id)sender {
    [[SoomlaProfile getInstance] getContactsWithProvider:FACEBOOK andReward:nil];
}

- (IBAction)getFeedTouched:(id)sender {
    [[SoomlaProfile getInstance] getFeedWithProvider:FACEBOOK andReward:nil];
}

@end


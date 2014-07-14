//
//  ViewController.h
//  SoomlaiOSProfileExample
//
//  Created by Gur Dotan on 6/10/14.
//  Copyright (c) 2014 Soomla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface ViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *currencyLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *updateStatusButton;
@property (weak, nonatomic) IBOutlet UIButton *updateStoryButton;
@property(nonatomic, weak) IBOutlet UIButton *uploadImageButton;
@property(nonatomic, weak) IBOutlet UIButton *getContactsButton;

- (IBAction)uploadImageTouched:(id)sender;

@property(nonatomic, weak) IBOutlet UIButton *getFeedsButton;

- (IBAction)getContactsButtonTouched:(id)sender;


- (IBAction)getFeedsTouched:(id)sender;
@end

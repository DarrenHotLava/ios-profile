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

#import <UIKit/UIKit.h>

/**
 Main view of the application.
 Provides a simple implementation of an application which uses the Profile
 functionality to contact Facebook.
 */
@interface ViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *currencyLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *loginTwitterButton;
@property (weak, nonatomic) IBOutlet UIButton *loginGoogleButton;
@property (weak, nonatomic) IBOutlet UIButton *updateStatusButton;
@property (weak, nonatomic) IBOutlet UIButton *updateStoryButton;
@property(nonatomic, weak) IBOutlet UIButton *uploadImageButton;
@property(nonatomic, weak) IBOutlet UIButton *getContactsButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property(nonatomic, weak) IBOutlet UIButton *getFeedButton;

- (IBAction)buttonTouched:(id)sender;
- (IBAction)loginTwitterButtonTouched:(id)sender;
- (IBAction)loginGoogleButtonTouched:(id)sender;

- (IBAction)uploadImageTouched:(id)sender;

- (IBAction)getContactsButtonTouched:(id)sender;

- (IBAction)getFeedTouched:(id)sender;

- (IBAction)backTouched:(id)sender;
@end

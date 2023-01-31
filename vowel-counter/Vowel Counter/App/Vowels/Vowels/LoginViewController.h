//
//  ViewController.h
//  Vowels
//
//  Created by James Hickman on 8/5/14.
//  Copyright (c) 2014 NitWit Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

#import "VowelsViewController.h"
#import "MBProgressHUD.h"

@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *textFieldEmail;
@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;
@property (weak, nonatomic) IBOutlet UIButton *buttonFacebook;
@property (weak, nonatomic) IBOutlet UILabel *labelServerMode;
@property (weak, nonatomic) IBOutlet UISwitch *switchServerMode;

@property (strong,nonatomic) NSString *facebookEmail;
@property (strong,nonatomic) MBProgressHUD *progressHUD;

//UI Animations
-(void)animateElementsIn;
- (void)shakeView:(UIView*)view;
//UI Controls
- (IBAction)didTapLoginButton:(id)sender;
- (IBAction)didTapFacebookButton:(id)sender;
//Keyboard Stack
- (void)keyboardWasShown:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;
-(void)dismissKeyboard;

@end

//
//  ViewController.m
//  Vowels
//
//  Created by James Hickman on 8/5/14.
//  Copyright (c) 2014 NitWit Studios. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    if(DEBUG_MODE){
        //Preset email for quick login
        self.textFieldEmail.text = @"james.hickman@nitwitstudios.com";
    }
    
    //Add gesture recognizer to dismiss keyboard
    UITapGestureRecognizer *dismissKeyboardTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:dismissKeyboardTap];
    //Add keyboard notifications to move field into view
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    //UI Updates
    self.labelServerMode.font = [UIFont fontWithName:@"Oswald-Bold" size:16.0];
    self.textFieldEmail.alpha = 0.0;
    self.buttonLogin.alpha = 0.0;
    self.buttonFacebook.alpha = 0.0;
    self.labelServerMode.alpha = 0.0;
    self.switchServerMode.alpha = 0.0;
    [self animateElementsIn];

}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = YES;
    if(!DEBUG_MODE){
        //Clear Email
        self.textFieldEmail.text = @"";
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Animations
-(void)animateElementsIn{
    self.imageView.center = self.view.center;
    [UIView animateWithDuration:1.0
                          delay:0.5
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.imageView.frame = CGRectMake(60, 40, 200, 200);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.5 animations:^{
                             self.textFieldEmail.alpha = 1.0;
                             self.buttonLogin.alpha = 1.0;
                             self.buttonFacebook.alpha = 1.0;
                             self.labelServerMode.alpha = 1.0;
                             self.switchServerMode.alpha = 1.0;
                         
                         }];
                     }];
}
- (void)shakeView:(UIView*)view
{
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.05];
    [animation setRepeatCount:4];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake(view.center.x - 10.0f, view.center.y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake(view.center.x + 10.0f, view.center.y)]];
    [view.layer addAnimation:animation forKey:@"position"];
}

#pragma mark - UI Controls
- (IBAction)didTapLoginButton:(id)sender {
    //Validate email
    NSString *emailFilter = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailFilter];
    if([emailTest evaluateWithObject:self.textFieldEmail.text]){
        if([self.switchServerMode isOn]){
            [self performSegueWithIdentifier:@"displayServerView" sender:self];
        }else{
            [self performSegueWithIdentifier:@"displayVowelView" sender:self];
        }
    }else{
        [self shakeView:self.textFieldEmail];
    }
}
- (IBAction)didTapFacebookButton:(id)sender {
    
    if(self.progressHUD==nil){
        self.progressHUD = [[MBProgressHUD alloc] init];
    }
    //Add progress indicator, block UI Interactions
    UIWindow* currentWindow = [UIApplication sharedApplication].keyWindow;//Use keyWindow to put progress hud above navigation controller
    [currentWindow addSubview:self.progressHUD];
    self.progressHUD.userInteractionEnabled = YES;
    [self.progressHUD show:YES];
    
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state != FBSessionStateOpen
        || FBSession.activeSession.state != FBSessionStateOpenTokenExtended) {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for public_profile permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile",@"email"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             // If the session was opened successfully
             if (!error && state == FBSessionStateOpen){
                 if(DEBUG_MODE){
                     NSLog(@"Session opened");
                 }
                 [[FBRequest requestForMe] startWithCompletionHandler:
                  ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
                      if (!error) {
                          if(DEBUG_MODE){
                             NSLog(@"Facebook Email: %@", [user objectForKey:@"email"]);
                          }
                          self.facebookEmail = [user objectForKey:@"email"];
                          if([self.switchServerMode isOn]){
                              [self performSegueWithIdentifier:@"displayServerView" sender:self];
                          }else{
                              [self performSegueWithIdentifier:@"displayVowelView" sender:self];
                          }
                      }
                  }];
                 return;
             }
             if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
                 // If the session is closed
                 if(DEBUG_MODE){
                     NSLog(@"Session closed");
                 }
             }
             
             // Handle errors
             if (error){
                 if(DEBUG_MODE){
                     NSLog(@"Error");
                 }
                 // If the error requires people using an app to make an action outside of the app in order to recover
                 if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
                     if(DEBUG_MODE){
                         NSLog(@"Something went wrong");
                     }
                 } else {
                     
                     // If the user cancelled login, do nothing
                     if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                         if(DEBUG_MODE){
                             NSLog(@"User cancelled login");
                         }
                         
                         // Handle session closures that happen outside of the app
                     } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                         if(DEBUG_MODE){
                             NSLog(@"Session Error");
                             NSLog(@"Your current session is no longer valid. Please log in again.");
                         }
                         
                     } else {
                         // Show the user an error message
                         if(DEBUG_MODE){
                             NSLog(@"Something went wrong");
                         }
                     }
                 }
                 // Clear this token
                 [FBSession.activeSession closeAndClearTokenInformation];
             }
         }];
    }
    [self.progressHUD removeFromSuperview];
}

#pragma mark - Segue Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"displayVowelView"]){
        //Send user's ID to destination view controller
        VowelsViewController *vc = [segue destinationViewController];
        if(self.facebookEmail){//Check if using facebook to login
            vc.idUsers = self.facebookEmail;
        }else{
            vc.idUsers = self.textFieldEmail.text;
        }
    }
    
}

#pragma mark - Keyboard Stack
- (void)keyboardWasShown:(NSNotification *)notification
{
    //Set Scrollview size
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height);

    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardSize.height;
    if (!CGRectContainsPoint(aRect, self.textFieldEmail.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, self.textFieldEmail.frame.origin.y - (keyboardSize.height-15));
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}
- (void)keyboardWillHide:(NSNotification *)notification
{
    //Set Scrollview size
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height-50);
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}
-(void)dismissKeyboard{
    [self.textFieldEmail resignFirstResponder];
    [self.view endEditing:YES];
}


@end

//
//  VowelsViewController.h
//  Vowels
//
//  Created by James Hickman on 8/5/14.
//  Copyright (c) 2014 NitWit Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

#import "VowelsTableViewCell.h"
#import "DataManager.h"
#import "MBProgressHUD.h"
#import "SIAlertView.h"

@interface VowelsViewController : UIViewController<UITextViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonLogout;
@property (weak, nonatomic) IBOutlet UILabel *labelTotalVowels;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonReset;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonSubmit;

@property (strong,nonatomic) NSString *idUsers;
@property (strong,nonatomic) DataManager *dataManager;
@property (strong,nonatomic) NSMutableArray *results;
@property int totalVowels;

- (IBAction)didTapLogoutButton:(id)sender;
- (IBAction)didTapResetButton:(id)sender;
- (IBAction)didTapSubmitButton:(id)sender;


-(void)resetForm;
-(void)dismissKeyboard;

@end

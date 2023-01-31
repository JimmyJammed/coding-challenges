//
//  ServerViewController.h
//  Vowels
//
//  Created by James Hickman on 8/5/14.
//  Copyright (c) 2014 NitWit Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

#import "DataManager.h"
#import "MBProgressHUD.h"
#import "SIAlertView.h"
#import "SubmissionDetailsViewController.h"
#import "ServerTableViewCell.h"

@interface ServerViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonLogout;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonRefresh;
@property (weak, nonatomic) IBOutlet UILabel *labelTotalSubmissions;
@property (weak, nonatomic) IBOutlet UILabel *labelTotalVowels;
@property (weak, nonatomic) IBOutlet UILabel *labelTotalLines;
@property (weak, nonatomic) IBOutlet UILabel *labelSubmissions;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong,nonatomic) DataManager *dataManager;
@property (strong,nonatomic) MBProgressHUD *progressHUD;
@property (strong,nonatomic) NSArray *results;
@property int selectedRow;

- (IBAction)didTapLogoutButton:(id)sender;
- (IBAction)didTapRefreshButton:(id)sender;
@end

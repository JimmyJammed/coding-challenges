//
//  SubmissionDetailsViewController.h
//  Vowels
//
//  Created by James Hickman on 8/5/14.
//  Copyright (c) 2014 NitWit Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailsTableViewCell.h"
#import "DataManager.h"
#import "MBProgressHUD.h"
#import "SIAlertView.h"

@interface SubmissionDetailsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) DataManager *dataManager;
@property (strong,nonatomic) MBProgressHUD *progressHUD;
@property (strong,nonatomic) NSString *idVowels;
@property (strong,nonatomic) NSDictionary *submissionData;

@end

//
//  SubmissionDetailsViewController.m
//  Vowels
//
//  Created by James Hickman on 8/5/14.
//  Copyright (c) 2014 NitWit Studios. All rights reserved.
//

#import "SubmissionDetailsViewController.h"

@interface SubmissionDetailsViewController ()

@end

@implementation SubmissionDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if(DEBUG_MODE){
        NSLog(@"Submission Data: %@",self.idVowels);
    }
    //Init
    self.dataManager = [[DataManager alloc] init];
    self.tableView.hidden = YES;//Hide tableview until data is parsed
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//Remove empty cells from bottom of table

    //Add progress indicator, block UI Interactions
    self.progressHUD = [[MBProgressHUD alloc] init];
    UIWindow* currentWindow = [UIApplication sharedApplication].keyWindow;//Use keyWindow to put progress hud above navigation controller
    [currentWindow addSubview:self.progressHUD];
    self.progressHUD.userInteractionEnabled = YES;
    [self.progressHUD show:YES];

    //Get server data
    [self.dataManager serverRequest:@"getEntry" withData:@{@"idVowels": self.idVowels} completion:^(NSDictionary *results) {
        if(DEBUG_MODE){
            NSLog(@"Results: %@",results);
        }
        if([[results objectForKey:@"status"] boolValue]==YES){
            self.submissionData = [results objectForKey:@"response"];
            [self.tableView reloadData];
            self.tableView.hidden = NO;
        }else{
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Network Error" andMessage:@"There was a problem fetching your request.\nPlease check your internet connection and try again"];
            [alertView addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDestructive handler:nil];
            [alertView show];
        }
        [self.progressHUD removeFromSuperview];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.progressHUD = nil;
    self.dataManager = nil;
    self.submissionData = nil;
}

#pragma mark - Table View Stack
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row==3){//Mult-line
        return 80.0;
    }else{
        return 44.0;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row>2){//Mult-line
        return [self heightForCellAtIndexPath:indexPath];
    }else{
        return 44.0;
    }
    
    return 0;
}
- (CGFloat)heightForCellAtIndexPath:(NSIndexPath *)indexPath
{
    static DetailsTableViewCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"DetailsTextTableViewCell"];
    });
    
    [self configureCell:sizingCell atIndexPath:indexPath];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}
- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell
{
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds), 0.0f);
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height+16;
}
- (void)configureCell:(DetailsTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==3){
        cell.labelKey.text = @"Text";
        cell.labelMultiLineValue.adjustsFontSizeToFitWidth = NO;
        cell.labelMultiLineValue.text = [self.submissionData objectForKey:@"text"];
    }if(indexPath.row==4){
        cell.labelKey.text = @"Line Vowels";
        cell.labelMultiLineValue.adjustsFontSizeToFitWidth = NO;
        NSString *longString = @"";
        for(NSDictionary* line in [self.submissionData objectForKey:@"lineData"]){
            longString = [longString stringByAppendingString:[NSString stringWithFormat:@"Line %@ has %@ vowels.\n",[line objectForKey:@"idLines"],[line objectForKey:@"vowels"]]];
        }
        cell.labelMultiLineValue.text = longString;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier;
    if(indexPath.row>2){//Mult-line
        cellIdentifier = @"DetailsTextTableViewCell";
    }else{
        cellIdentifier = @"DetailsTableViewCell";
    }
    DetailsTableViewCell *cell = (DetailsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    //UI Updates
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.labelValue.adjustsFontSizeToFitWidth = YES;
    cell.labelKey.font = [UIFont fontWithName:@"Oswald-Bold" size:16.0];
    
    if(indexPath.row==0){
        cell.labelKey.text = @"Email";
        cell.labelValue.numberOfLines = 0;
        cell.labelValue.text = [self.submissionData objectForKey:@"idUsers"];
    }if(indexPath.row==1){
        cell.labelKey.text = @"Total Vowels";
        cell.labelValue.text = [NSString stringWithFormat:@"%@",[self.submissionData objectForKey:@"totalVowels"]];
    }if(indexPath.row==2){
        cell.labelKey.text = @"Total Lines";
        cell.labelValue.text = [NSString stringWithFormat:@"%@",[self.submissionData objectForKey:@"totalLines"]];
    }if(indexPath.row==3){
        cell.labelKey.text = @"Text";
        cell.labelMultiLineValue.adjustsFontSizeToFitWidth = NO;
        cell.labelMultiLineValue.text = [self.submissionData objectForKey:@"text"];
    }if(indexPath.row==4){
        cell.labelKey.text = @"Line Vowels";
        cell.labelMultiLineValue.adjustsFontSizeToFitWidth = NO;
        NSString *longString = @"";
        for(NSDictionary* line in [self.submissionData objectForKey:@"lineData"]){
            longString = [longString stringByAppendingString:[NSString stringWithFormat:@"Line %@ has %@ vowels.\n",[line objectForKey:@"idLines"],[line objectForKey:@"vowels"]]];
        }
        cell.labelMultiLineValue.text = longString;
    }
    
    
    return cell;
}

@end

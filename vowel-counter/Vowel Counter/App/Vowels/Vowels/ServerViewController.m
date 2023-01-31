//
//  ServerViewController.m
//  Vowels
//
//  Created by James Hickman on 8/5/14.
//  Copyright (c) 2014 NitWit Studios. All rights reserved.
//

#import "ServerViewController.h"

@interface ServerViewController ()

@end

@implementation ServerViewController

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
    
    //Inits
    self.dataManager = [[DataManager alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    //UI Updates
    self.labelTotalSubmissions.font = [UIFont fontWithName:@"Oswald-Bold" size:16.0];
    self.labelTotalVowels.font = [UIFont fontWithName:@"Oswald-Bold" size:16.0];
    self.labelTotalLines.font = [UIFont fontWithName:@"Oswald-Bold" size:16.0];
    self.labelSubmissions.font = [UIFont fontWithName:@"Oswald-Bold" size:20.0];
    self.tableView.layer.cornerRadius = 5.0;
    self.tableView.clipsToBounds = YES;
    self.tableView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:233.0/255.0 blue:206.0/255.0 alpha:1.0];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.dataManager = nil;
    self.progressHUD = nil;
    self.results = nil;
}

#pragma mark - UI Controls
- (IBAction)didTapLogoutButton:(id)sender {
    //Remove facebook session
    FBSession* session = [FBSession activeSession];
    [session closeAndClearTokenInformation];
    [session close];
    [FBSession setActiveSession:nil];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)didTapRefreshButton:(id)sender {
    if(DEBUG_MODE){
        NSLog(@"Did Tap Refresh Button");
    }
    if(self.progressHUD==nil){
        self.progressHUD = [[MBProgressHUD alloc] init];
    }
    //Add progress indicator, block UI Interactions
    UIWindow* currentWindow = [UIApplication sharedApplication].keyWindow;//Use keyWindow to put progress hud above navigation controller
    [currentWindow addSubview:self.progressHUD];
    self.progressHUD.userInteractionEnabled = YES;
    [self.progressHUD show:YES];
    
    //Send data to server
    [self.dataManager serverRequest:@"getAllEntries" withData:nil completion:^(NSDictionary *results) {
        if(DEBUG_MODE){
            NSLog(@"Results: %@",results);
        }
        if([[results objectForKey:@"status"] boolValue]==YES && [results objectForKey:@"response"]!=[NSNull null]){
            self.results = [results objectForKey:@"response"];
            self.labelTotalSubmissions.text = [NSString stringWithFormat:@"Total Submissions: %@",[results objectForKey:@"totalSubmissions"]];
            self.labelTotalVowels.text = [NSString stringWithFormat:@"Total Vowels: %@",[results objectForKey:@"totalVowels"]];
            self.labelTotalLines.text = [NSString stringWithFormat:@"Total Lines: %@",[results objectForKey:@"totalLines"]];
            [self.tableView reloadData];
        }else if([results objectForKey:@"response"]==[NSNull null]){
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"What Are You Doing?!?" andMessage:@"No entries have been submitted yet.\nPlease go back and submit an entry."];
            [alertView addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDestructive handler:nil];
            [alertView show];
        }else{
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Network Error" andMessage:@"There was a problem submitting your form.\nPlease check your internet connection and try again"];
            [alertView addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDestructive handler:nil];
            [alertView show];
        }
        [self.progressHUD removeFromSuperview];
    }];
}

#pragma mark - Table View Stack
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.results.count==0){
        return 1;
    }
    return self.results.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44.0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0;
}
-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ServerTableViewCell *headerCell = (ServerTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ServerHeaderTableViewCell"];
    headerCell.emailHeaderLabel.font = [UIFont fontWithName:@"Oswald-Bold" size:16.0];
    headerCell.vowelsHeaderLabel.font = [UIFont fontWithName:@"Oswald-Bold" size:16.0];
    headerCell.backgroundColor = [UIColor groupTableViewBackgroundColor];
    if (headerCell == nil){
        [NSException raise:@"headerView == nil.." format:@"No cells with matching CellIdentifier loaded from your storyboard"];
    }
    return headerCell;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ServerTableViewCell *cell = (ServerTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ServerTableViewCell" forIndexPath:indexPath];
    
    if(self.results.count==0){
        cell.emailLabel.font = [UIFont fontWithName:@"Oswald-Light" size:16.0];
        cell.emailLabel.text = @"Nothing to see here...";
        cell.totalVowelsLabel.text = @"";
    }else{
        cell.emailLabel.font = [UIFont fontWithName:@"Oswald-Regular" size:16.0];
        cell.totalVowelsLabel.font = [UIFont fontWithName:@"Oswald-Bold" size:20.0];
        
        NSDictionary *rowData = [self.results objectAtIndex:indexPath.row];
        cell.emailLabel.text = [rowData objectForKey:@"idUsers"];
        cell.totalVowelsLabel.text = [rowData objectForKey:@"totalVowels"];

    }
    
    //Cell UI Updates
    cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    cell.emailLabel.adjustsFontSizeToFitWidth = YES;
    cell.emailLabel.numberOfLines=0;
    cell.emailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    cell.totalVowelsLabel.adjustsFontSizeToFitWidth = YES;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
    if(self.results.count!=0){
        self.selectedRow = (int)indexPath.row;//Forward index to pass data to destination view controller
        [self performSegueWithIdentifier:@"displaySubmissionDetailsView" sender:self];
    }
}

#pragma mark - Segue Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"displaySubmissionDetailsView"]){
        //Send user's ID to destination view controller
        SubmissionDetailsViewController *vc = [segue destinationViewController];
        vc.idVowels = [[self.results objectAtIndex:self.selectedRow] objectForKey:@"idVowels"];
    }
}
@end

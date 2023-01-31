//
//  VowelsViewController.m
//  Vowels
//
//  Created by James Hickman on 8/5/14.
//  Copyright (c) 2014 NitWit Studios. All rights reserved.
//

#import "VowelsViewController.h"

@interface VowelsViewController ()

@end

@implementation VowelsViewController

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

    //Get user ID from presenting view
    if(DEBUG_MODE){
        NSLog(@"Selected User ID: %@",self.idUsers);
    }
    
    //Disable default back button for custom logout button
    [self.navigationItem setHidesBackButton:YES];
    
    //Inits
    self.results = [[NSMutableArray alloc] init];
    self.dataManager = [[DataManager alloc] init];
    //Delegates
    self.textView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    //Add gesture recognizer to dismiss keyboard
    UITapGestureRecognizer *dismissKeyboardTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    dismissKeyboardTap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:dismissKeyboardTap];
    
    //UI Updates
    self.textView.layer.cornerRadius = 5.0;
    self.tableView.layer.cornerRadius = 5.0;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Text View Delegate
-(void)textViewDidChange:(UITextView *)textView{
    if(DEBUG_MODE){
        NSLog(@"Text View Current Text: %@",textView.text);
    }

    //Lines
    NSArray* lines = [textView.text componentsSeparatedByString: @"\n"];
    
    //Vowels per line
    NSString *filter = @"[AEIOUaeiou]";
    NSError  *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:filter options:0 error:&error];
    
    //Remove deleted lines
    if(self.results.count>lines.count){
        [self.results removeObjectsInRange:NSMakeRange(lines.count-1,self.results.count-lines.count)];
    }
    
    self.totalVowels = 0;//Reset total count
    for(int i=0;i<lines.count;i++){
        NSString *lineString = [lines objectAtIndex:i];
        NSArray *matches = [regex matchesInString:lineString options:NSMatchingReportProgress range:NSMakeRange(0, lineString.length)];
        self.totalVowels += (int)matches.count;
        //Add results to stored array
        NSDictionary *lineData = @{@"idLines": [NSNumber numberWithInteger:i+1],@"vowels": [NSNumber numberWithInteger:matches.count]};
        if(self.results.count>i){//Replace existing entry
            [self.results replaceObjectAtIndex:i withObject:lineData];
        }else if(self.results.count<=i){//Add new entry
            [self.results addObject:lineData];
        }
    }

    //Reload table
    [self.tableView reloadData];
    self.labelTotalVowels.text = [NSString stringWithFormat:@"Total Vowels: %i",self.totalVowels];
}

#pragma mark - UI Controls
- (IBAction)didTapLogoutButton:(id)sender {
    if(DEBUG_MODE){
        NSLog(@"Did Tap Logout Button");
    }
    //Remove facebook session
    FBSession* session = [FBSession activeSession];
    [session closeAndClearTokenInformation];
    [session close];
    [FBSession setActiveSession:nil];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)didTapResetButton:(id)sender {
    if(DEBUG_MODE){
        NSLog(@"Did Tap Reset Button");
    }
    [self resetForm];
}

- (IBAction)didTapSubmitButton:(id)sender {
    if(DEBUG_MODE){
        NSLog(@"Did Tap Submit Button");
    }
    if([self.textView.text isEqualToString:@""]){
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"What Are You Doing?!?" andMessage:@"You need to enter some text first!\nPlease try again :-)"];
        [alertView addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDestructive handler:nil];
        [alertView show];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    //Send data to server
    [self.dataManager serverRequest:@"postEntry" withData:@{@"idUsers":self.idUsers,@"text": self.textView.text,@"totalVowels":[NSNumber numberWithInt:self.totalVowels],@"lineData":self.results} completion:^(NSDictionary *results) {
        if(DEBUG_MODE){
            NSLog(@"Results: %@",results);
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];

        if([[results objectForKey:@"status"] boolValue]==YES){
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Success!" andMessage:@"Your data has been submitted to the server."];
            [alertView addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
                [self resetForm];
            }];
            [alertView show];
        }else{
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Network Error" andMessage:@"There was a problem submitting your form.\nPlease check your internet connection and try again"];
            [alertView addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDestructive handler:nil];
            [alertView show];
        }
    }];
}

#pragma mark - Form Actions
-(void)resetForm{
    self.textView.text = @"";
    self.labelTotalVowels.text = @"Total Vowels: 0";
    [self.results removeAllObjects];
    [self.tableView reloadData];
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
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VowelsTableViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(self.results.count==0){
        cell.textLabel.font = [UIFont fontWithName:@"Oswald-Light" size:16.0];
        cell.textLabel.text = @"Nothing to see here...";
    }else{
        NSDictionary *lineData = [self.results objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont fontWithName:@"Oswald-Regular" size:16.0];
        cell.textLabel.text = [NSString stringWithFormat:@"Line %@ has %@ vowels.",[lineData objectForKey:@"idLines"],[lineData objectForKey:@"vowels"]];
    }
    
    //Cell UI Updates
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    return cell;
}

#pragma mark - Keyboard
-(void)dismissKeyboard{
    [self.textView resignFirstResponder];
    [self.view endEditing:YES];
}
@end

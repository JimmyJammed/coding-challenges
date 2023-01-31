//
//  ServerTableViewCell.h
//  Vowels
//
//  Created by James Hickman on 8/6/14.
//  Copyright (c) 2014 NitWit Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServerTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalVowelsLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *vowelsHeaderLabel;
@end

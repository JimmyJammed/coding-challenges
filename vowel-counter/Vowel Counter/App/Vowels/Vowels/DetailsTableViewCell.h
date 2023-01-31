//
//  DetailsTableViewCell.h
//  Vowels
//
//  Created by James Hickman on 8/6/14.
//  Copyright (c) 2014 NitWit Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelKey;
@property (weak, nonatomic) IBOutlet UILabel *labelValue;
@property (weak, nonatomic) IBOutlet UILabel *labelMultiLineValue;
@end

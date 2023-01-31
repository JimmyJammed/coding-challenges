//
//  DetailsTableViewCell.m
//  Vowels
//
//  Created by James Hickman on 8/6/14.
//  Copyright (c) 2014 NitWit Studios. All rights reserved.
//

#import "DetailsTableViewCell.h"

@implementation DetailsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  ArticleTableViewCell.m
//  CodingExercise
//
//  Created by James Hickman on 8/20/15.
//  Copyright (c) 2015 Hotel Tonight. All rights reserved.
//

#import "ArticleTableViewCell.h"
#import "CodingExercise-Swift.h"

@implementation ArticleTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8.0, 5.0, self.contentView.frame.size.width/2-8.0, 140.0)];
        self.thumbnailImageView.backgroundColor = [Constant lightGrayColor];
        self.thumbnailImageView.layer.cornerRadius = 5.0;
        self.thumbnailImageView.clipsToBounds = true;
        [self.contentView addSubview:self.thumbnailImageView];
        
        self.headerTextView = [[UITextView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width/2+8.0, 5.0, self.contentView.frame.size.width/2-16.0, 140.0)];
        self.headerTextView.font = [UIFont boldSystemFontOfSize:18.0];
        self.headerTextView.userInteractionEnabled = false;
        self.headerTextView.selectable = false;
        self.headerTextView.editable = false;
        [self.contentView addSubview:self.headerTextView];
        
        // Resizing Masks
        self.headerTextView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    }
    
    return self;
}

-(void)loadWithArticle:(Article *)article
{
    self.article = article;
    
    // Clear contents (when dequeing)
    self.headerTextView.text = @"";
    self.thumbnailImageView.image = [Constant logoImage];
    self.thumbnailImageView.tintColor = [UIColor blackColor];
    self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    // Set contents
    self.headerTextView.text = article.title;
    if (article.thumbnailUrl)
    {
        [self.thumbnailImageView sd_setImageWithURL:article.thumbnailUrl];
        self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
}

@end

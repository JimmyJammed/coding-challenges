//
//  ArticleTableViewCell.h
//  CodingExercise
//
//  Created by James Hickman on 8/20/15.
//  Copyright (c) 2015 Hotel Tonight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

@class Article;

@interface ArticleTableViewCell : UITableViewCell

@property(nonatomic, strong) UIImageView *thumbnailImageView;
@property(nonatomic, strong) UITextView *headerTextView;
@property(nonatomic, strong) Article *article;

-(void)loadWithArticle:(Article *)article;
@end

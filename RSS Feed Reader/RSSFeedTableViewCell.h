//
//  RSSFeedTableViewCell.h
//  RSS Feed Reader
//
//  Created by Roberto Fierro Martinez on 7/23/15.
//  Copyright (c) 2015 Roberto Fierro Martinez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RSSFeedTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *feedImageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *sourceLabel;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;

- (instancetype)initWithFrame:(CGRect)frame;

@end

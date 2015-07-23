//
//  RSSFeedTableViewCell.m
//  RSS Feed Reader
//
//  Created by Roberto Fierro Martinez on 7/23/15.
//  Copyright (c) 2015 Roberto Fierro Martinez. All rights reserved.
//

#import "RSSFeedTableViewCell.h"

@implementation RSSFeedTableViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self != nil) {
        [self setupView];
    }
    
    return self;
}

-(void)setupView {
    
    // Setup image view
    UIImage *placeholderImage = [UIImage imageNamed:@"placeholder"];
    self.feedImageView = [[UIImageView alloc] initWithImage:placeholderImage];
    
    // Setup labels
    
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.textAlignment = NSTextAlignmentJustified;
    self.titleLabel.text = nil;
    
    self.sourceLabel.numberOfLines = 1;
    self.sourceLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.sourceLabel.textAlignment = NSTextAlignmentLeft;
    self.sourceLabel.text = nil;
    
    self.descriptionLabel.numberOfLines = 6;
    self.descriptionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.descriptionLabel.textAlignment = NSTextAlignmentJustified;
    self.descriptionLabel.text = nil;
    
}

- (void)awakeFromNib {
    // Initialization code
    
    NSLog(@"tsssss");
    
    [self setupView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)prepareForReuse {
    self.feedImageView.image = nil;
    self.titleLabel.text = nil;
    self.sourceLabel.text = nil;
    self.descriptionLabel.text = nil;
}

@end

//
//  LoadingView.m
//  RSS Feed Reader
//
//  Created by Roberto Fierro Martinez on 7/19/15.
//  Copyright (c) 2015 Roberto Fierro Martinez. All rights reserved.
//

#import "LoadingView.h"
#import "AppDelegate.h"

@interface LoadingView()

@property (strong, nonatomic) UILabel *labelMessage;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@end

const CGFloat kLoadingViewAlpha = 0.7;
const CGFloat kNavigationBarHeight = 64;

@implementation LoadingView

#pragma mark Singleton Methods

static LoadingView *sharedInstance = nil;

+ (LoadingView *)sharedLoadingView {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if(self){
        
        // Setup view
        [self setFrame:[[UIScreen mainScreen] bounds]];
        [self setTranslatesAutoresizingMaskIntoConstraints:YES];
        [self setBackgroundColor:[UIColor colorWithWhite:0.8 alpha:kLoadingViewAlpha]];
        
        // Setup label message
        self.labelMessage = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:self.labelMessage];
        [self.labelMessage setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self.labelMessage setFont:[UIFont boldSystemFontOfSize:16]];
        [self.labelMessage setTextColor:[UIColor blackColor]];
        [self.labelMessage setTextAlignment:NSTextAlignmentCenter];
        [self.labelMessage setNumberOfLines:0];
        [self.labelMessage setLineBreakMode:NSLineBreakByWordWrapping];
        [self.labelMessage setText:nil];
        
        // Create loading indicator
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        [self.activityIndicatorView setTranslatesAutoresizingMaskIntoConstraints:YES];
        
        [self.activityIndicatorView setColor:[UIColor blackColor]];
        
        // Start animating
        [self.activityIndicatorView startAnimating];
        
        [self addSubview:self.activityIndicatorView];
    
        [self updateActivityIndicatorCenter];
        
        // Configuring label message constraints
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[message]-20-|" options:0 metrics:nil views:@{@"message": self.labelMessage}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[message(160)]" options:0 metrics:nil views:@{@"message": self.labelMessage}]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.labelMessage attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:0.75f constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.labelMessage attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.]];
    }
    
    return self;
}

- (void)show{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.masterNavigationController.view addSubview:self];
}

- (void)showWithMessage:(NSString* )message{
    
    [self.labelMessage setText:message];
    [self show];
}

- (void)dismiss{
    [self removeFromSuperview];
}

- (void)layoutSubviews{
    
    [self setFrame:[[UIScreen mainScreen] bounds]];
    [self needsUpdateConstraints];
    [self updateActivityIndicatorCenter];
}

-(void)updateActivityIndicatorCenter{
    // Centring loading indicator
    CGFloat xPosition = CGRectGetWidth(self.frame)/2;
    CGFloat yPosition = CGRectGetHeight(self.frame)/2;
    CGPoint point = CGPointMake(xPosition, yPosition);
    [self.activityIndicatorView setCenter:point];
}


@end

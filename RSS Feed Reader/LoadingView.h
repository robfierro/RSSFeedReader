//
//  LoadingView.h
//  RSS Feed Reader
//
//  Created by Roberto Fierro Martinez on 7/19/15.
//  Copyright (c) 2015 Roberto Fierro Martinez. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface LoadingView : UIView

+ (LoadingView *)sharedLoadingView;

- (void)show;
- (void)dismiss;
- (void)showWithMessage:(NSString *)message;

@end

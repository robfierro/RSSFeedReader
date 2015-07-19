//
//  DetailViewController.h
//  RSS Feed Reader
//
//  Created by Roberto Fierro Martinez on 7/19/15.
//  Copyright (c) 2015 Roberto Fierro Martinez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end


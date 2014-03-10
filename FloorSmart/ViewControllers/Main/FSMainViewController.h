//
//  FSMainViewController.h
//  FloorSmart
//
//  Created by Lydia on 12/23/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSMainViewController : UITabBarController

@property (nonatomic, assign) IBOutlet UIView *viewForTabbar;
@property (nonatomic, assign) IBOutlet UIButton *btnHome;
@property (nonatomic, assign) IBOutlet UIButton *btnReports;

+ (FSMainViewController *) sharedController;

- (void)selectItem:(UIButton *)btnItem;

- (IBAction)onTabItem:(id)sender;

@end

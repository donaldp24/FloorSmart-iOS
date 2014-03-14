//
//  FSMainViewController.m
//  FloorSmart
//
//  Created by Lydia on 12/23/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import "FSMainViewController.h"

@interface FSMainViewController ()

@end

@implementation FSMainViewController
@synthesize viewForTabbar, btnHome, btnReports;

+ (FSMainViewController *) sharedController
{
    __strong static FSMainViewController *sharedController = nil;
	static dispatch_once_t onceToken;
    
	dispatch_once(&onceToken, ^{
        sharedController = [[[NSBundle mainBundle] loadNibNamed:@"FSMainViewController" owner:nil options:nil] objectAtIndex:0];
	});
    
    return sharedController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self tabBar] addSubview:viewForTabbar];
    [viewForTabbar setFrame:CGRectMake(0, 0, viewForTabbar.frame.size.width, viewForTabbar.frame.size.height)];
    
    [self setSelected:1];
    [btnHome setSelected:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setSelected:(NSInteger)index
{
    if(index != [self selectedIndex] + 1)
    {
        [self setSelectedIndex:index - 1];
        return ;
    }
}

- (void)clearSelected
{
    for (int i=1; i<6; i++) {
        UIView *v = [viewForTabbar viewWithTag:i];
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)v;
            [btn setSelected:NO];
        }
    }
}

- (void)selectItem:(UIButton *)btnItem
{
    [self clearSelected];
    [btnItem setSelected:YES];
    [self setSelected:btnItem.tag];
}

- (IBAction)onTabItem:(id)sender
{
    UIButton *tabItem = (UIButton *)sender;
    [self clearSelected];
    [tabItem setSelected:YES];
    /*
    if (tabItem.tag == 5) {
        [self setSelected:3];
    } else {
        [self setSelected:tabItem.tag];
    }*/
    [self setSelected:tabItem.tag];
}

@end

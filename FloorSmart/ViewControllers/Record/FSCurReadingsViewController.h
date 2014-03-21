//
//  FSCurReadingsViewController.h
//  FloorSmart
//
//  Created by Lydia on 1/5/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSProduct.h"
#import "FSPopView.h"
#import <MessageUI/MessageUI.h>
#import "FSReading.h"

@interface FSCurReadingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) IBOutlet UITableView *tblDetal;

@property (nonatomic, assign) IBOutlet UILabel *lblJobName;
@property (nonatomic, assign) IBOutlet UILabel *lblLocName;
@property (nonatomic, assign) IBOutlet UILabel *lblProcName;

@property (nonatomic, assign) IBOutlet UIView *viewOverall;
@property (nonatomic, assign) IBOutlet UILabel *lblOverMCAVG;
@property (nonatomic, assign) IBOutlet UILabel *lblOverMCHigh;
@property (nonatomic, assign) IBOutlet UILabel *lblOverMCLow;
@property (nonatomic, assign) IBOutlet UILabel *lblOverEMCAVG;
@property (nonatomic, assign) IBOutlet UILabel *lblOverRHAVG;
@property (nonatomic, assign) IBOutlet UILabel *lblOverTempAVG;

@property (nonatomic, strong) FSLocProduct *curLocProduct;

@property (nonatomic, assign) IBOutlet UILabel *lblCurrent;
@property (nonatomic, assign) IBOutlet UILabel *lblCurRH;
@property (nonatomic, assign) IBOutlet UILabel *lblCurTemp;
@property (nonatomic, assign) IBOutlet UILabel *lblCurBattery;
@property (nonatomic, assign) IBOutlet UILabel *lblCurDepth;
@property (nonatomic, assign) IBOutlet UILabel *lblCurGravity;
@property (nonatomic, assign) IBOutlet UILabel *lblCurMaterial;
@property (nonatomic, assign) IBOutlet UILabel *lblCurMC;

- (IBAction)onBack:(id)sender;

- (void)setCurData:(FSReading *)data;
- (void)initDateTable;


@end

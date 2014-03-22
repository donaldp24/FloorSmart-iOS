//
//  FSCurReadingsViewController.m
//  FloorSmart
//
//  Created by Lydia on 1/5/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "FSCurReadingsViewController.h"
#import "FSMeasureCell.h"
#import "Global.h"
#import "DataManager.h"
#import "FSReading.h"
#import "FSReportCell.h"
#import "CommonMethods.h"
#import "GlobalData.h"
//----
#import "Defines.h"

@interface FSCurReadingsViewController ()

@end

@implementation FSCurReadingsViewController {
    NSMutableArray *arrReadingCounts;
    FSReportCell *selectedCell;
    NSMutableArray *arrOverallReadings;
    NSMutableData *receivedData;
    UIColor *infoColorOrdinal, *infoColorError, *infoColorSubscribed;
}
@synthesize tblDetal;
@synthesize lblLocName, lblProcName, lblJobName;
@synthesize viewOverall, lblOverEMCAVG, lblOverMCAVG, lblOverMCHigh, lblOverMCLow, lblOverRHAVG, lblOverTempAVG;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //-------
        receivedData = [[NSMutableData alloc] init];

        infoColorOrdinal = [UIColor colorWithRed:211.0/255.0 green:163.0/255.0 blue:51.0/255.0 alpha:1.0];
        infoColorError = [UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:66.0/255.0 alpha:1.0];
        infoColorSubscribed = [UIColor colorWithRed:40.0/255.0 green:181.0/255.0 blue:110.0/255.0 alpha:1.0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_curLocProduct) {
        FSLocation *loc = [[DataManager sharedInstance] getLocationFromID:self.curLocProduct.locProductLocID];
        if (loc == nil)
            return;
        FSJob *job = [[DataManager sharedInstance] getJobFromID:loc.locJobID];
        if (job == nil)
            return;
        
        NSString *jobName = job.jobName;
        NSString *locName = loc.locName;
        NSString *procName = self.curLocProduct.locProductName;
        
        [lblJobName setText:jobName];
        [lblLocName setText:[NSString stringWithFormat:@"Location: %@", locName]];
        [lblProcName setText:[NSString stringWithFormat:@"Product: %@", procName]];
    }
    else
    {
        [lblJobName setText:@""];
        [lblLocName setText:[NSString stringWithFormat:@"Location: %@", @""]];
        [lblProcName setText:[NSString stringWithFormat:@"Product: %@", @""]];
    }

    
    [self initDateTable];
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

//------
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initDateTable
{
    if (self.curLocProduct == nil) {
        arrOverallReadings = [[NSMutableArray alloc] init];
        [self setCurData:nil];
        [self setOverallData];
    } else {
        
        if (self.curDate == nil)
            self.curDate = [NSDate date];
        arrOverallReadings = [[DataManager sharedInstance] getReadings:self.curLocProduct.locProductID withDate:self.curDate];
        
        [self setCurData:[arrOverallReadings lastObject]];
        [self setOverallData];
        
        if ([arrOverallReadings count] > 0)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[arrOverallReadings count] - 1 inSection:0];
            [self.tblDetal scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
}

#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == tblDetal) {
        return 1;
    }
    return [arrReadingCounts count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == tblDetal) {
        return [arrOverallReadings count];
    }
    return 1;
}

- (CGFloat)tableView:( UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblDetal) {
        return 25.0f;
    }
    return 40.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblDetal) {
        FSMeasureCell *cell = [tblDetal dequeueReusableCellWithIdentifier:@"FSMeasureCell"];
        
        if(cell == nil)
        {
            cell = [FSMeasureCell sharedCell];
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setDelegate:self];
    
        if (indexPath.row % 2 == 0) {
            [cell.contentView setBackgroundColor:[UIColor colorWithRed:193.0f/255.0f green:182.0f/255.0f blue:169.0f/255.0f alpha:1.0f]];
        } else {
            [cell.contentView setBackgroundColor:[UIColor colorWithRed:164.0f/255.0f green:149.0f/255.0f blue:130.0f/255.0f alpha:1.0f]];
        }
        
        [cell setCurReading:(FSReading *)[arrOverallReadings objectAtIndex:indexPath.row]];
        
        return cell;
    }
    /* //
    FSReportCell *cell = [tblReadingDates dequeueReusableCellWithIdentifier:@"FSReportCell"];
    
    if(cell == nil)
    {
        cell = [FSReportCell sharedCell];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setDelegate:self];
    NSString *strDate = (NSString *)[arrReadingCounts objectAtIndex:indexPath.section];
    [cell setCurDate:[CommonMethods str2date:strDate withFormat:DATE_FORMAT]];
    
    return cell;
     */
    return nil;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Cell Delegate
- (void)didDisclosure:(FSReportCell *)cell
{
    /*
    if (cell.curDate != selectedCell.curDate) {
        if (selectedCell) {
            if (selectedCell.isOpened) {
                selectedCell.isOpened = !selectedCell.isOpened;
            }
        }
        selectedCell = cell;
        [self hideOverall:YES];
        return;
    }
    selectedCell = cell;
    [self setOverallData];
    if (selectedCell.isOpened) {
        [self showOverall];
    } else {
        [self hideOverall:NO];
    }
     */
}

- (void)didDelete:(FSMeasureCell *)cell
{
    /*
    if (selectedCell.isOpened) {
        [self hideOverall:NO];
        selectedCell.isOpened = NO;
    }
    if (cell) {
        [[DataManager sharedInstance] deleteReadingFromDatabase:cell.curReading];
    }
    [self initDateTable];
    [arrOverallReadings removeAllObjects];
    [tblDetal reloadData];
     */
}

- (void)setOverallData
{
    /*
    [selectedCell setIsOpened:!selectedCell.isOpened];
    CGRect frame = viewOverall.frame;
    CGRect selectedCellProcViewFrame = [selectedCell.btnDisclosure.superview convertRect:selectedCell.btnDisclosure.frame toView:self.view];
    frame.origin.y = selectedCellProcViewFrame.origin.y + 28.0f;
    [viewOverall setFrame:frame];
     */
    
    //setOverall Items
    if (arrOverallReadings == nil || [arrOverallReadings count] == 0) {

        float mcValue = 0;
        int rh = 0;
        int temp = 0;
        [lblOverMCAVG setText:[NSString stringWithFormat:@"MC Avg: %.1f%@", mcValue, @"%"]];
        [lblOverMCHigh setText:[NSString stringWithFormat:@"MC High: %ld%@", (long)mcValue, @"%"]];
        [lblOverMCLow setText:[NSString stringWithFormat:@"MC Low: %ld%@", (long)mcValue, @"%"]];
        [lblOverEMCAVG setText:[NSString stringWithFormat:@"EMC Avg: 0%@", @"%" ]];
        [lblOverRHAVG setText:[NSString stringWithFormat:@"RH Avg: %d%@", (int)rh, @"%"]];
        [lblOverTempAVG setText:[NSString stringWithFormat:@"Temp Avg: %d", (int)temp]];
    }
    else
    {
        CGFloat mcavg = [FSReading getMCAvg:arrOverallReadings];
        CGFloat mchigh = [FSReading getMCMax:arrOverallReadings];
        CGFloat mclow = [FSReading getMCMax:arrOverallReadings];
        CGFloat rhavg = [FSReading getRHAvg:arrOverallReadings];
        CGFloat tempavg = [FSReading getTempAvg:arrOverallReadings];
        CGFloat emcavg = [FSReading getEmcAvg:arrOverallReadings];
        
        GlobalData *globalData = [GlobalData sharedData];
        
        [lblOverMCAVG setText:[NSString stringWithFormat:@"MC Avg: %.1f%@", mcavg, @"%"]];
        [lblOverMCHigh setText:[NSString stringWithFormat:@"MC High: %ld%@", (long)mchigh, @"%"]];
        [lblOverMCLow setText:[NSString stringWithFormat:@"MC Low: %ld%@", (long)mclow, @"%"]];
        [lblOverEMCAVG setText:[NSString stringWithFormat:@"EMC Avg: %d%@", (int)emcavg, @"%" ]];
        [lblOverRHAVG setText:[NSString stringWithFormat:@"RH Avg:%d%@", (int)rhavg, @"%"]];
        [lblOverTempAVG setText:[NSString stringWithFormat:@"Temp Avg:%@", [globalData getDisplayTemperature:tempavg]]];
    }
    [tblDetal reloadData];
}

- (void)showOverall
{
    /*
    CGRect frame = viewOverall.frame;
    frame.size.height = 80.0f;
    [UIView animateWithDuration:0.15f animations:^{
        [viewOverall setFrame:frame];
    }completion:^(BOOL finished){
        [tblReadingDates setScrollEnabled:NO];
    }];
     */
}

- (void)hideOverall:(BOOL)next
{
    /*
    CGRect frame = viewOverall.frame;
    frame.size.height = 0.0f;
    [UIView animateWithDuration:0.15f animations:^{
        [viewOverall setFrame:frame];
    }completion:^(BOOL finished){
        [tblReadingDates setScrollEnabled:YES];
        if (next) {
            [self setOverallData];
            [self showOverall];
        }
    }];
     */
}


#pragma mark - Actions
- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setCurData:(FSReading *)data
{
    GlobalData *globalData = [GlobalData sharedData];
    if (data != nil)
    {
        if ([CommonMethods compareOnlyDate:self.curDate date2:[NSDate date]] == NSOrderedSame)
        {
            self.lblCurrent.text = [NSString stringWithFormat:@"Today(%@) Last Readings(%@)", [CommonMethods date2str:data.readTimestamp withFormat:globalData.settingDateFormat], [CommonMethods date2str:data.readTimestamp withFormat:@"HH:mm"]];
        }
        else
        {
            self.lblCurrent.text = [NSString stringWithFormat:@"Date(%@) Last Readings(%@)", [CommonMethods date2str:data.readTimestamp withFormat:globalData.settingDateFormat], [CommonMethods date2str:data.readTimestamp withFormat:@"HH:mm"]];
        }
        self.lblCurRH.text = [NSString stringWithFormat:@"RH : %.1f", data.readConvRH];
        

        self.lblCurTemp.text = [NSString stringWithFormat:@"Temp : %@", [globalData getDisplayTemperature:data.readConvTemp]];
        
        self.lblCurBattery.text = [NSString stringWithFormat:@"Battery : %ld%%", data.readBattery];
        self.lblCurDepth.text = [NSString stringWithFormat:@"Depth : %@", [FSReading getDisplayDepth:data.readDepth]];
        self.lblCurMaterial.text = [NSString stringWithFormat:@"Material : %@", [FSReading getDisplayMaterial:data.readMaterial]];
        self.lblCurGravity.text = [NSString stringWithFormat:@"Gravity : %ld", data.readGravity];
        self.lblCurMC.text = [NSString stringWithFormat:@"MC : %ld%%", data.readMC];
    }
    else
    {
        if ([CommonMethods compareOnlyDate:self.curDate date2:[NSDate date]] == NSOrderedSame)
        {
            self.lblCurrent.text = [NSString stringWithFormat:@"Today(%@) Last Readings", [CommonMethods date2str:data.readTimestamp withFormat:globalData.settingDateFormat]];
        }
        else
        {
            self.lblCurrent.text = [NSString stringWithFormat:@"Date(%@) Last Readings", [CommonMethods date2str:data.readTimestamp withFormat:globalData.settingDateFormat]];
        }
        self.lblCurRH.text = [NSString stringWithFormat:@"RH :"];
        self.lblCurTemp.text = [NSString stringWithFormat:@"Temp : "];
        self.lblCurBattery.text = [NSString stringWithFormat:@"Battery : "];
        self.lblCurDepth.text = [NSString stringWithFormat:@"Depth : "];
        self.lblCurMaterial.text = [NSString stringWithFormat:@"Material : "];
        self.lblCurGravity.text = [NSString stringWithFormat:@"Gravity : "];
        self.lblCurMC.text = [NSString stringWithFormat:@"MC : "];
    }
}

@end

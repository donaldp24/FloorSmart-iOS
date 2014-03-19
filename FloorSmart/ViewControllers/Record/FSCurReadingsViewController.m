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
@synthesize tblDetal, txtReceiveData, internalInfoLabel;
@synthesize lblLocName, lblProcName, lblJobName;
@synthesize tblReadingDates, viewOverall, lblOverEMCAVG, lblOverMCAVG, lblOverMCHigh, lblOverMCLow, lblOverRHAVG, lblOverTempAVG;

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
    
    [tblDetal setBackgroundColor:[UIColor clearColor]];
    [tblReadingDates setBackgroundColor:[UIColor clearColor]];
    
    CGRect overallFrame = viewOverall.frame;
    overallFrame.size.height = 0;
    [viewOverall setFrame:overallFrame];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_curLocProduct) {
        [self initDateTable];
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
    arrReadingCounts = [[DataManager sharedInstance] getAllReadingDates:self.curLocProduct.locProductID];
    [tblReadingDates setContentSize:CGSizeMake(tblReadingDates.frame.size.width, 40 * [arrReadingCounts count])];
    [tblReadingDates reloadData];
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
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Cell Delegate
- (void)didDisclosure:(FSReportCell *)cell
{
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
}

- (void)didDelete:(FSMeasureCell *)cell
{
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
}

- (void)setOverallData
{
    [selectedCell setIsOpened:!selectedCell.isOpened];
    CGRect frame = viewOverall.frame;
    CGRect selectedCellProcViewFrame = [selectedCell.btnDisclosure.superview convertRect:selectedCell.btnDisclosure.frame toView:self.view];
    frame.origin.y = selectedCellProcViewFrame.origin.y + 28.0f;
    [viewOverall setFrame:frame];
    
    //setOverall Items
    if (self.curLocProduct == nil) {
        arrOverallReadings = [[NSMutableArray alloc] init];

        float mcValue = 0;
        int rh = 0;
        int temp = 0;
        [lblOverMCAVG setText:[NSString stringWithFormat:@"MC Avg: %.1f%@", mcValue, @"%"]];
        [lblOverMCHigh setText:[NSString stringWithFormat:@"MC High: %.1f%@", mcValue, @"%"]];
        [lblOverMCLow setText:[NSString stringWithFormat:@"MC Low: %.1f%@", mcValue, @"%"]];
        [lblOverEMCAVG setText:[NSString stringWithFormat:@"EMC Avg: 39%@", @"%" ]];//needed
        [lblOverRHAVG setText:[NSString stringWithFormat:@"RH Avg:%d%@", (int)rh, @"%"]];
        [lblOverTempAVG setText:[NSString stringWithFormat:@"Temp Avg:%d%@", (int)temp, @"%"]];
    }
    else
    {
        arrOverallReadings = [[DataManager sharedInstance] getReadings:self.curLocProduct.locProductID withDate:selectedCell.curDate];
        FSReading *firstRow = (FSReading *)[arrOverallReadings objectAtIndex:0];//needed
        float mcValue = (float)[firstRow readMC] / 10;
        [lblOverMCAVG setText:[NSString stringWithFormat:@"MC Avg: %.1f%@", mcValue, @"%"]];
        [lblOverMCHigh setText:[NSString stringWithFormat:@"MC High: %.1f%@", mcValue, @"%"]];
        [lblOverMCLow setText:[NSString stringWithFormat:@"MC Low: %.1f%@", mcValue, @"%"]];
        [lblOverEMCAVG setText:[NSString stringWithFormat:@"EMC Avg: 39%@", @"%" ]];//needed
        [lblOverRHAVG setText:[NSString stringWithFormat:@"RH Avg:%d%@", (int)[firstRow readRH], @"%"]];
        [lblOverTempAVG setText:[NSString stringWithFormat:@"Temp Avg:%d%@", (int)[firstRow readTemp], @"%"]];
    }
    [tblDetal reloadData];
}

- (void)showOverall
{
    CGRect frame = viewOverall.frame;
    frame.size.height = 80.0f;
    [UIView animateWithDuration:0.15f animations:^{
        [viewOverall setFrame:frame];
    }completion:^(BOOL finished){
        [tblReadingDates setScrollEnabled:NO];
    }];
}

- (void)hideOverall:(BOOL)next
{
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
}


#pragma mark - Actions
- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

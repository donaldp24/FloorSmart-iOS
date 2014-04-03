//
//  FSSelectViewController.m
//  FloorSmart
//
//  Created by Donald Pae on 4/3/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "FSSelectViewController.h"
#import "DataManager.h"
#import "FSRecordViewController.h"
#import "CommonMethods.h"

@interface FSSelectViewController ()

@end

@implementation FSSelectViewController

- (id) initWithParent : (NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil parent:(id) realParent mode:(int)mode parentNode:(id)parentNode
{

   // NSString *szXibName = [ResourceManager getXibName:nibNameOrNil];
    NSString *szXibName = nibNameOrNil;
    
	self = [super initWithNibName:szXibName bundle:nibBundleOrNil];
    
    _parent = realParent;
    _curRow = 0;
    _mode = mode;
    _parentNode = parentNode;
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    CGRect rtBound = [[UIScreen mainScreen] bounds];
    CGRect rtContainer = self.viewContainer.frame;
    
    CGFloat toolbarHeight = 44;
    self.viewContainer.frame = CGRectMake(rtContainer.origin.x, rtBound.size.height - rtContainer.size.height - toolbarHeight, rtContainer.size.width, rtContainer.size.height);
    
    if (_mode == MODE_SELECT_JOB)
    {
        arrayData = [[DataManager sharedInstance] getJobs:0 searchField:@""];
        [self.lblTitle setText:@"Select a Job"];
    }
    else if (_mode == MODE_SELECT_LOCATION)
    {
        FSJob *job = (FSJob *)_parentNode;
        arrayData = [[DataManager sharedInstance] getLocations:job.jobID];
        [self.lblTitle setText:@"Select a Location"];
    }
    else if (_mode == MODE_SELECT_PRODUCT)
    {
        FSLocation *loc = (FSLocation *)_parentNode;
        arrayData = [[DataManager sharedInstance] getLocProducts:loc searchField:@""];
        [self.lblTitle setText:@"Select a Product"];
    }
    FSRecordViewController *p = (FSRecordViewController *)_parent;
    [p hideSummary];
    
    [self reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark UIPickerView related stuff

//Method to define how many columns/dials to show
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// Method to define the numberOfRows in a component using the array.
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent :(NSInteger)component
{
    return [arrayData count];
}

// Method to show the title of row for a component.
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSMutableString *str = [[NSMutableString alloc] init];
    if (arrayData.count > 0)
    {
        //AddrInfo  *addr = [addrArray objectAtIndex:row];
        
        //[str appendFormat:@"%@ %@ %@ %@", addr.receivername, addr.area1, addr.area2, addr.area3];
        
        if (_mode == MODE_SELECT_JOB)
        {
            FSJob *job = [arrayData objectAtIndex:row];
            [str appendFormat:@"%@", job.jobName];
        }
        else if (_mode == MODE_SELECT_LOCATION)
        {
            FSLocation *location = [arrayData objectAtIndex:row];
            [str appendFormat:@"%@", location.locName];
        }
        else if (_mode == MODE_SELECT_PRODUCT)
        {
            FSLocProduct *locProduct = [arrayData objectAtIndex:row];
            [str appendFormat:@"%@ (%@)", locProduct.locProductName, [FSProduct getDisplayProductType:locProduct.locProductType]];
        }
        return str;
    }
    return @"";
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40.0;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _curRow = row;
}

- (void)setCurSelected:(id)data
{
    _curSelectedData = data;
}

- (void)reloadData
{
    [self.picker reloadAllComponents];
    id data = _curSelectedData;
    if (data == nil)
        return;
    
    if (data != nil && arrayData.count > 0)
    {
        int i = 0;
        for (id item in arrayData) {
            
            if (_mode == MODE_SELECT_JOB)
            {
                FSJob *job = (FSJob *)item;
                if (job.jobID == ((FSJob *)data).jobID)
                {
                    _curRow = i;
                    [self.picker selectRow:i inComponent:0 animated:NO];
                    break;
                }
            }
            else if (_mode == MODE_SELECT_LOCATION)
            {
                FSLocation *loc = (FSLocation *)item;
                if (loc.locID == ((FSLocation *)data).locID)
                {
                    _curRow = i;
                    [self.picker selectRow:i inComponent:0 animated:NO];
                    break;
                }
            }
            else if (_mode == MODE_SELECT_JOB)
            {
                FSLocProduct *locProduct = (FSLocProduct *)item;
                if (locProduct.locProductID == ((FSLocProduct *)data).locProductID)
                {
                    _curRow = i;
                    [self.picker selectRow:i inComponent:0 animated:NO];
                    break;
                }
            }
            i++;
        }
    }
}

#pragma mark Event handlers

- (IBAction)onCancelClicked:(id)sender {
    [CommonMethods playTapSound];
    
    [self.view removeFromSuperview];
    FSRecordViewController *p = (FSRecordViewController *)_parent;
    [p showSummary];
}

- (IBAction)onDoneClicked:(id)sender {
    [CommonMethods playTapSound];
    
    FSRecordViewController *p = (FSRecordViewController *)_parent;
    if (_curRow < arrayData.count)
    {
        
        if (_mode == MODE_SELECT_JOB)
        {
            FSJob  *job = [arrayData objectAtIndex:_curRow];
            [p jobSelected:job];
            
        }
        else if (_mode == MODE_SELECT_LOCATION)
        {
            FSLocation *loc = [arrayData objectAtIndex:_curRow];
            [p locationSelected:loc];
            
        }
        else if (_mode == MODE_SELECT_PRODUCT)
        {
            FSLocProduct *locProduct = [arrayData objectAtIndex:_curRow];
            [p locProductSelected:locProduct];
            
        }
    }
    
    [self.view removeFromSuperview];
    [p showSummary];

}


@end

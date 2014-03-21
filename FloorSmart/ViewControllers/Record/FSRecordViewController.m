//
//  FSRecordViewController.m
//  FloorSmart
//
//  Created by Lydia on 12/23/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import "FSRecordViewController.h"
#import "FSJobViewController.h"
#import "Defines.h"
#import "CommonMethods.h"
#import "DataManager.h"
#import "GlobalData.h"
#import "FSCurReadingsViewController.h"
#import "FSMainViewController.h"

#import "EmulatorReadingParser.h"
#import "SensorReadingParser.h"
#import "Global.h"

@interface FSRecordViewController ()

@end

@implementation FSRecordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initMember
{
    defaultLocation = [[FSLocation alloc] init];
    defaultLocation.locID = 0;
    defaultLocation.locJobID = 0;
    defaultLocation.locName = FMD_DEFAULT_LOCATIONNAME;
    
    /*
    defaultProduct = [[FSLocProduct alloc] init];
    defaultProduct.locProductID = 0;
    defaultProduct.locProductLocID = 0;
    defaultProduct.locProductName = @DEFAULT_PRODUCTNAME;
    defaultProduct.locProductType = FSProductTypeFinished;
    defaultProduct.locProductCoverage = 0.0;
     */
    
    defaultProduct = [[FSProduct alloc] init];
    defaultProduct.productID = 0;
    defaultProduct.productName = FMD_DEFAULT_PRODUCTNAME;
    defaultProduct.productType = FSProductTypeFinished;
    defaultProduct.productDeleted = 0.0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initMember];
    
    readingVC = nil;
    
    GlobalData *globalData = [GlobalData sharedData];
    if (globalData.isSaved == YES)
    {
        selectedJob = [[DataManager sharedInstance] getJobFromID:globalData.selectedJobID];
        selectedLocation = [[DataManager sharedInstance] getLocationFromID:globalData.selectedLocID];
        selectedProduct = nil;
        selectedLocProduct = [[DataManager sharedInstance] getLocProductWithID:globalData.selectedLocProductID];
        
        if (selectedJob == nil
            || selectedLocation == nil
            || selectedLocProduct == nil)
        {
            NSLog(@"global data : jobid(%ld - %ld), locid(%ld - %ld), locproductid(%ld - %ld) ", globalData.selectedJobID, (selectedJob == nil ? 0 : selectedJob.jobID), globalData.selectedLocID, (selectedLocation == nil ? 0 : selectedLocation.locID), globalData.selectedLocProductID, (selectedLocProduct == nil ? 0 : selectedLocProduct.locProductID));
        }
        else
        {
            NSLog(@"global data : jobid(%ld - %@), locid(%ld - %@), locproductid(%ld - %@) ", selectedJob.jobID, selectedJob.jobName, selectedLocation.locID, selectedLocation.locName, selectedLocProduct.locProductID, selectedLocProduct.locProductName);
        }
        
        self.txtJob.text = selectedJob.jobName;
        self.txtLocation.text = selectedLocation.locName;
        self.txtProduct.text = selectedLocProduct.locProductName;
        
        if (globalData.settingArea == YES) //ft
        {
            self.txtCoverage.text = [NSString stringWithFormat:@"%.2f", selectedLocProduct.locProductCoverage];
        }
        else
        {
            self.txtCoverage.text = [NSString stringWithFormat:@"%.2f", [GlobalData sqft2sqm:selectedLocProduct.locProductCoverage]];
        }
        
        if ([selectedLocation.locName isEqualToString:FMD_DEFAULT_LOCATIONNAME])
            self.txtLocation.text = @"";
        if ([selectedLocProduct.locProductName isEqualToString:FMD_DEFAULT_PRODUCTNAME])
            self.txtProduct.text = @"";
        
        self.btnSave.enabled = NO;
        self.btnCancel.enabled = YES;
        //self.btnSummary.enabled = YES;
        self.txtCoverage.enabled = NO;
    }
    else
    {
        selectedJob = nil;
        selectedLocation = nil;
        selectedProduct = nil;
        selectedLocProduct = nil;
        
        self.txtJob.text = @"";
        self.txtLocation.text = @"";
        self.txtProduct.text = @"";
        self.txtCoverage.text = @"";
        
        self.btnSave.enabled = YES;
        self.btnCancel.enabled = NO;
        //self.btnSummary.enabled = NO;
        self.txtCoverage.enabled = YES;
    }
    
    if (globalData.settingArea == YES) //ft
    {
        self.lblUnitFt.hidden = NO;
        self.lblUnitM.hidden = YES;
        
        isPrevSqureFoot = YES;
    }
    else
    {
        self.lblUnitFt.hidden = YES;
        self.lblUnitM.hidden = NO;
        
        isPrevSqureFoot = NO;
    }
    
    self.txtJob.enabled = NO;
    self.txtLocation.enabled = NO;
    self.txtProduct.enabled = NO;
    
    curTextField = nil;
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    readingVC = nil;
    GlobalData *globalData = [GlobalData sharedData];
    
    BOOL isKeeped = YES;
    if (selectedJob)
    {
        FSJob *orgJob = selectedJob;
        selectedJob = [[DataManager sharedInstance] getJobFromID:selectedJob.jobID];
        if (selectedJob == nil)
        {
            isKeeped = NO;
            selectedLocation = nil;
            selectedLocProduct = nil;
            selectedProduct = nil;
            NSLog(@"don't keep - job : %ld, %@", orgJob.jobID, orgJob.jobName);
        }
    }
    if (selectedLocation)
    {
        FSLocation *orgLoc = selectedLocation;
        selectedLocation = [[DataManager sharedInstance] getLocationFromID:selectedLocation.locID];
        if (selectedLocation == nil)
        {
            isKeeped = NO;
            selectedProduct = nil;
            selectedLocProduct = nil;
            NSLog(@"don't keep - loc : %ld, %@", orgLoc.locID, orgLoc.locName);
        }
    }
    
    if (selectedProduct)
    {
        FSProduct *orgProduct = selectedProduct;
        selectedProduct = [[DataManager sharedInstance] getProductFromID:selectedProduct.productID];
        if (selectedProduct == nil) {
            isKeeped = NO;
            NSLog(@"don't keep - product : %ld, %@", orgProduct.productID, orgProduct.productName);
        }
    }
    
    if (selectedLocProduct)
    {
        FSLocProduct *orgLocProduct = selectedLocProduct;
        selectedLocProduct = [[DataManager sharedInstance] getLocProductWithID:selectedLocProduct.locProductID];
        if (selectedLocProduct == nil) {
            isKeeped = NO;
            NSLog(@"don't keep - locproduct : %ld, %@", orgLocProduct.locProductID, orgLocProduct.locProductName);
        }
    }
    
    if (isKeeped == NO)
    {
        GlobalData *globalData = [GlobalData sharedData];
        if (globalData.isSaved)
        {
            [globalData resetSavedData];
            self.btnCancel.enabled = NO;
            self.btnSave.enabled = YES;
            //self.btnSummary.enabled = NO;
        }
        
        if (selectedJob == nil) {
            self.txtJob.text = @"";
            self.txtLocation.text = @"";
            self.txtProduct.text = @"";
            self.txtCoverage.text = @"";
            selectedLocation = nil;
            selectedLocProduct = nil;
            selectedProduct = nil;
        }
        else
        {
            if (selectedLocation == nil)
            {
                selectedLocation = [[DataManager sharedInstance] getDefaultLocationOfJob:selectedJob.jobID];
                selectedLocProduct = nil;
                selectedProduct = nil;
            }
            
            if (selectedLocation != nil)
            {
                if (selectedLocProduct == nil && selectedProduct == nil)
                    selectedLocProduct = [[DataManager sharedInstance] getDefaultLocProductOfLocation:selectedLocation];
            }
        }
    }
    
    self.btnSummary.enabled = YES;
    
    // set txtcoverage
    CGFloat coverage = [self.txtCoverage.text floatValue];
    // have to convert unit
    if (isPrevSqureFoot == globalData.settingArea)
        coverage = coverage;
    else
    {
        if (globalData.settingArea == YES)
        {
            coverage = [GlobalData sqm2sqft:coverage];
            isPrevSqureFoot = YES;
        }
        else
        {
            coverage = [GlobalData sqft2sqm:coverage];
            isPrevSqureFoot = NO;
        }
    }
    
    if (globalData.settingArea == YES)
    {
        self.lblUnitFt.hidden = NO;
        self.lblUnitM.hidden = YES;
    }
    else
    {
        self.lblUnitFt.hidden = YES;
        self.lblUnitM.hidden = NO;
    }
    self.txtCoverage.text = [NSString stringWithFormat:@"%.2f", coverage];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)BeginEditing:(UITextField *)sender
{
    curTextField = sender;
}

- (IBAction)EndEditing:(UITextField *)sender
{
    curTextField = nil;
    [sender resignFirstResponder];
}

- (IBAction)onBgClicked:(id)sender
{
    if (curTextField != nil)
    {
        [curTextField resignFirstResponder];
        curTextField = nil;
    }
}


#pragma mark - Actions
- (IBAction)onSelJob:(id)sender
{
    if ([self isSelectable] == NO)
    {
        [self showAlertForNotSelectable];
        return;
    }
    FSJobViewController *vc = [[FSJobViewController alloc] initWithNibName:@"FSJobViewController" bundle:nil];
    vc.mode = MODE_RECORD;
    vc.jobSelectDelegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onSelLocation:(id)sender
{
    if ([self isSelectable] == NO)
    {
        [self showAlertForNotSelectable];
        return;
    }
    
    if (selectedJob == nil)
    {
        [CommonMethods showAlertUsingTitle:@"" andMessage:@"Please select a job"];
        return;
    }
    
    FSLocationsViewController *vc = [[FSLocationsViewController alloc] initWithNibName:@"FSLocationsViewController" bundle:nil];
    vc.mode = MODE_RECORD;
    vc.curJob = selectedJob;
    vc.locationSelectDelegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onSelProduct:(id)sender
{
    if ([self isSelectable] == NO)
    {
        [self showAlertForNotSelectable];
        return;
    }
    
    if (selectedJob == nil)
    {
        [CommonMethods showAlertUsingTitle:@"" andMessage:@"Please select a job"];
        return;
    }
    
    FSLocProductViewController *vc = [[FSLocProductViewController alloc] initWithNibName:@"FSLocProductViewController" bundle:nil];
    if (selectedLocation == nil)
        vc.curLoc = defaultLocation;
    else
        vc.curLoc = selectedLocation;
    vc.locProductSelectDelegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Job Select Delegate
- (void)jobSelected:(FSJob *)job
{
    selectedJob = job;
    selectedLocation = nil;
    selectedProduct = nil;
    selectedLocProduct = nil;
    
    self.txtJob.text = job.jobName;
    
    self.txtLocation.text = @"";
    self.txtProduct.text = @"";
    
    
    selectedLocation = [[DataManager sharedInstance] getDefaultLocationOfJob:job.jobID];
    if (selectedLocation != nil)
    {
        //selectedLocProduct = [[DataManager sharedInstance] getDefaultLocProductOfLocation:selectedLocation];
        [self locationSelected:selectedLocation];
    }
    
    defaultLocation.locJobID = job.jobID;
    
    
    
}

#pragma mark - Location Select Delegate
- (void)locationSelected:(FSLocation *)loc
{
    selectedLocation = loc;
    self.txtLocation.text = loc.locName;
    
    self.txtProduct.text = @"";
    
    selectedProduct = nil;
    selectedLocProduct = [[DataManager sharedInstance] getDefaultLocProductOfLocation:selectedLocation];
    if (selectedLocProduct != nil)
    {
        [self locProductSelected:selectedLocProduct];
    }
    
}

#pragma mark - LocProduct Select Delegate
- (void)productSelected:(FSProduct *)product
{
    selectedProduct = product;
    selectedLocProduct = nil;
    
    self.txtProduct.text = selectedProduct.productName;
}

- (void)locProductSelected:(FSLocProduct *)locProduct
{
    selectedLocProduct = locProduct;
    selectedProduct = nil;
    
    self.txtProduct.text = selectedLocProduct.locProductName;
    
    float coverage = selectedLocProduct.locProductCoverage;
    GlobalData *globalData = [GlobalData sharedData];
    
    if (globalData.settingArea == YES) //ft
        coverage = coverage;
    else
        coverage = [GlobalData sqft2sqm:coverage];
    [self.txtCoverage setText:[NSString stringWithFormat:@"%.2f", coverage]];
    
}

#pragma mark - Actions
- (IBAction)onSaveClicked:(id)sender
{
    if (curTextField != nil)
    {
        [curTextField resignFirstResponder];
    }
    
    if (selectedJob == nil)
    {
        [CommonMethods showAlertUsingTitle:@"" andMessage:@"Please select a job"];
        return;
    }
    
    GlobalData *globalData = [GlobalData sharedData];
    
    float coverage = [self.txtCoverage.text floatValue];
    if (globalData.settingArea == YES) //ft
        coverage = coverage;
    else
        coverage = [GlobalData sqm2sqft:coverage];
    
    if (selectedLocation == nil)
    {
        // add default location to this job
        defaultLocation.locJobID = selectedJob.jobID;
        defaultLocation.locName = FMD_DEFAULT_LOCATIONNAME;
        int loc_id = [[DataManager sharedInstance] addLocationToDatabase:defaultLocation];
        selectedLocation = [[DataManager sharedInstance] getLocationFromID:loc_id];
    }
    
    if (selectedLocation == nil)
    {
        [CommonMethods showAlertUsingTitle:@"" andMessage:@"Please select a location"];
        return;
    }
    
    if (selectedLocProduct) {
        selectedLocProduct.locProductCoverage = coverage;
        [[DataManager sharedInstance] updateLocProductToDatabase:selectedLocProduct];
    }
    else
    if (selectedProduct)
    {
        FSLocProduct *locProduct = [[DataManager sharedInstance] getLocProductWithProduct:selectedProduct locID:selectedLocation.locID];
        if (locProduct)
        {
            selectedLocProduct = locProduct;
            selectedLocProduct.locProductCoverage = coverage;
            [[DataManager sharedInstance] updateLocProductToDatabase:selectedLocProduct];
        }
        else
        {
            // add this selected product to locproduct list for the specific location
            int locproduct_id = [[DataManager sharedInstance] addLocProductToDatabaseWithProduct:selectedProduct locID:(long)selectedLocation.locID coverage:coverage];
            selectedLocProduct = [[DataManager sharedInstance] getLocProductWithID:locproduct_id];
        }
    }
    else
    {
        // add default product for specific location
        FSLocProduct *locProduct = [[FSLocProduct alloc] init];
        locProduct.locProductLocID = selectedLocation.locID;
        locProduct.locProductName = FMD_DEFAULT_PRODUCTNAME;
        locProduct.locProductType = FSProductTypeFinished;
        locProduct.locProductCoverage = coverage;
        locProduct.locProductID = [[DataManager sharedInstance] addLocProductToDatabase:locProduct];
        
        selectedLocProduct = [[DataManager sharedInstance] getLocProductWithID:locProduct.locProductID];
    }
    
    if (selectedLocProduct == nil)
    {
        [CommonMethods showAlertUsingTitle:@"" andMessage:@"Please select a product"];
        return;
    }
    
    self.txtCoverage.enabled = NO;
    
    
    
    [[GlobalData sharedData] setSavedData:selectedJob.jobID selectedLocID:selectedLocation.locID selectedLocProductID:selectedLocProduct.locProductID];
    
    //self.btnSummary.enabled = YES;
    self.btnCancel.enabled = YES;
    self.btnSave.enabled = NO;
    
    FSMainViewController *mainController = [FSMainViewController sharedController];
    [mainController.scanManager stopScan];
    [mainController.scanManager performSelector:@selector(startScan) withObject:nil afterDelay:2];
    
}

- (IBAction)onCancelClicked:(id)sender
{
    if (curTextField != nil)
        [curTextField resignFirstResponder];
    
    [[GlobalData sharedData] resetSavedData];
    
    //self.btnSummary.enabled = NO;
    self.btnCancel.enabled = NO;
    self.btnSave.enabled = YES;
    
    self.txtCoverage.enabled = YES;
    
}

- (IBAction)onSummaryClicked:(id)sender
{
    if (curTextField != nil)
        [curTextField resignFirstResponder];
    
    if (readingVC == nil)
    {
        readingVC = [[FSCurReadingsViewController alloc] initWithNibName:@"FSCurReadingsViewController" bundle:nil];
        [readingVC setCurLocProduct:selectedLocProduct];
        [self.navigationController pushViewController:readingVC animated:YES];
    }
    
}

- (BOOL)isSelectable
{
    GlobalData *globalData = [GlobalData sharedData];
    if (globalData.isSaved == YES)
        return NO;
    return YES;
}

- (void)showAlertForNotSelectable
{
    [CommonMethods showAlertUsingTitle:@"" andMessage:@"Cannot change selection, \n Please press 'Cancel' button to stop recording first!"];
}

- (void)saveNewData:(NSDictionary *)data
{
    if (selectedLocProduct == nil)
        return;
    FSReading *reading = [[FSReading alloc] init];
    reading.readID = 0;
    reading.readLocProductID = selectedLocProduct.locProductID;
    reading.readTimestamp = [CommonMethods str2date:[data objectForKey:kSensorDataReadingTimestampKey] withFormat:DATETIME_FORMAT];
    reading.readUuid = [data objectForKey:kSensorDataUuidKey];
    reading.readRH = (long)[[data objectForKey:kSensorDataRHKey] intValue];
    reading.readConvRH = (double)[[data objectForKey:kSensorDataConvRHKey] floatValue];
    reading.readTemp = (long)[[data objectForKey:kSensorDataTemperatureKey] intValue];
    reading.readConvTemp = (double)[[data objectForKey:kSensorDataConvTempKey] floatValue];
    reading.readBattery = (long)[[data objectForKey:kSensorDataBatteryKey] intValue];
    reading.readDepth = (long)[[data objectForKey:kSensorDataDepthKey] intValue];
    reading.readGravity = (long)[[data objectForKey:kSensorDataGravityKey] intValue];
    reading.readMaterial = (long)[[data objectForKey:kSensorDataMaterialKey] intValue];
    reading.readMC = (long)[[data objectForKey:kSensorDataMCKey] intValue];
    [[DataManager sharedInstance] addReadingToDatabase:reading];
}

- (void)showReadingView
{
    [self performSelectorOnMainThread:@selector(navigateToReadingVC) withObject:nil waitUntilDone:NO];
}

- (void)navigateToReadingVC
{
    if (readingVC == nil)
    {
        [self.navigationController popToRootViewControllerAnimated:NO];
        
        if (curTextField != nil)
            [curTextField resignFirstResponder];
        
        if (selectedLocProduct == nil)
            return;
        
        readingVC = [[FSCurReadingsViewController alloc] initWithNibName:@"FSCurReadingsViewController" bundle:nil];
        [readingVC setCurLocProduct:selectedLocProduct];
        [self.navigationController pushViewController:readingVC animated:YES];
    }
    else
    {
        [readingVC initDateTable];
    }
}

@end

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
    
    GlobalData *globalData = [GlobalData sharedData];
    if (globalData.isSaved == YES)
    {
        selectedJob = [[DataManager sharedInstance] getJobFromID:globalData.selectedJobID];
        selectedLocation = [[DataManager sharedInstance] getLocationFromID:globalData.selectedLocID];
        selectedProduct = nil;
        selectedLocProduct = [[DataManager sharedInstance] getLocProductWithID:globalData.selectedLocProductID];
        
        self.txtJob.text = selectedJob.jobName;
        self.txtLocation.text = selectedLocation.locName;
        self.txtProduct.text = selectedLocProduct.locProductName;
        self.txtCoverage.text = [NSString stringWithFormat:@"%.2f", selectedLocProduct.locProductCoverage];
        
        
        if ([selectedLocation.locName isEqualToString:FMD_DEFAULT_LOCATIONNAME])
            self.txtLocation.text = @"";
        if ([selectedLocProduct.locProductName isEqualToString:FMD_DEFAULT_PRODUCTNAME])
            self.txtProduct.text = @"";
        
        self.btnSave.enabled = NO;
        self.btnCancel.enabled = YES;
        self.btnSummary.enabled = YES;
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
        self.btnSummary.enabled = NO;
    }
    
    curTextField = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    BOOL isKeeped = YES;
    if (selectedJob)
    {
        selectedJob = [[DataManager sharedInstance] getJobFromID:selectedJob.jobID];
        if (selectedJob == nil)
        {
            isKeeped = NO;
            selectedLocation = nil;
            selectedLocProduct = nil;
            selectedProduct = nil;
        }
    }
    if (selectedLocation)
    {
        selectedLocation = [[DataManager sharedInstance] getLocationFromID:selectedLocation.locID];
        if (selectedLocation == nil)
        {
            isKeeped = NO;
            selectedProduct = nil;
            selectedLocProduct = nil;
        }
    }
    
    if (selectedProduct)
    {
        selectedProduct = [[DataManager sharedInstance] getProductFromID:selectedProduct.productID];
        if (selectedProduct == nil) {
            isKeeped = NO;
        }
    }
    
    if (selectedLocProduct)
    {
        selectedLocProduct = [[DataManager sharedInstance] getLocProductWithID:selectedLocProduct.locProductID];
        if (selectedLocProduct == nil) {
            isKeeped = NO;
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
            self.btnSummary.enabled = NO;
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
    self.txtJob.text = job.jobName;
    
    selectedLocation = [[DataManager sharedInstance] getDefaultLocationOfJob:job.jobID];
    selectedProduct = nil;
    if (selectedLocation != nil)
        selectedLocProduct = [[DataManager sharedInstance] getDefaultLocProductOfLocation:selectedLocation];
    
    defaultLocation.locJobID = job.jobID;
    
    self.txtLocation.text = @"";
    self.txtProduct.text = @"";
    
}

#pragma mark - Location Select Delegate
- (void)locationSelected:(FSLocation *)loc
{
    selectedLocation = loc;
    self.txtLocation.text = loc.locName;
    
    selectedProduct = nil;
    selectedLocProduct = [[DataManager sharedInstance] getDefaultLocProductOfLocation:selectedLocation];
    self.txtProduct.text = @"";
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
    
    double coverage = [self.txtCoverage.text doubleValue];
    
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
    
    
    
    [[GlobalData sharedData] setSavedData:selectedJob.jobID selectedLocID:selectedLocation.locID selectedLocProductID:selectedLocProduct.locProductID];
    
    self.btnSummary.enabled = YES;
    self.btnCancel.enabled = YES;
    self.btnSave.enabled = NO;
    
}

- (IBAction)onCancelClicked:(id)sender
{
    if (curTextField != nil)
        [curTextField resignFirstResponder];
    
    [[GlobalData sharedData] resetSavedData];
    
    self.btnSummary.enabled = NO;
    self.btnCancel.enabled = NO;
    self.btnSave.enabled = YES;
    
}

- (IBAction)onSummaryClicked:(id)sender
{
    if (curTextField != nil)
        [curTextField resignFirstResponder];
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

@end

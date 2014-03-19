//
//  FSLocProductViewController.m
//  FloorSmart
//
//  Created by Lydia on 12/23/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import "FSLocProductViewController.h"
#import "FSProductCell.h"
#import "FSLocProductCell.h"
#import "DataManager.h"
#import "Global.h"
#import "FSProduct.h"
#import "Defines.h"

@interface FSLocProductViewController ()
{
    NSMutableArray *arrProdcutList;
    CGFloat trasnfromHeight;
    int finishNum;
    FSProductCell *curCell;
    FSLocProductCell *curLocCell;
    UITableView *tblProcType;
}
@end

@implementation FSLocProductViewController
@synthesize isEditing = _isEditing;
@synthesize tblProducts, viewTopAdd, viewTopSearch, txtAdd, txtSearch, viewSelectType, lblSelectType, btnFinished, btnSubfloor;
@synthesize delete_alertview;

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
    
    delete_alertview.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
    [delete_alertview setHidden:YES];
    [tblProducts setBackgroundColor:[UIColor clearColor]];
    trasnfromHeight = 0;
    _isEditing = NO;
    
    CGRect selectTypeFrame = viewSelectType.frame;
    selectTypeFrame.size.height = 0;
    [viewSelectType setFrame:selectTypeFrame];
    [btnSubfloor setSelected:YES];
    [lblSelectType setText:@"Subfloor"];
    finishNum = FSProductTypeSubfloor;
    
    CGRect frameTable = CGRectMake(0, 0, 90, 0);
    tblProcType = [[UITableView alloc] initWithFrame:frameTable style:UITableViewStylePlain];
    [tblProcType setDataSource:self];
    [tblProcType setDelegate:self];
    [tblProcType setAlpha:0.8f];
    [self.view addSubview:tblProcType];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initTable];
    [tblProcType reloadData];
    
    NSString *jobName = @"";
    NSString *locName = @"";
    // set job.name
    if (self.curLoc != nil)
    {
        if (self.curLoc.locJobID != 0)
        {
            FSJob *job = [[DataManager sharedInstance] getJobFromID:self.curLoc.locJobID];
            if (job)
            {
                jobName = job.jobName;
            }
        }
        locName = self.curLoc.locName;
    }
    
    self.lblJobLocName.text = [NSString stringWithFormat:@"Location : %@.%@", jobName, locName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initTable
{
    
    [self initTableArray];
    [tblProducts reloadData];
    if ([arrProdcutList count] == 0)
    {
        [self.lblNoResult setHidden:NO];
    }
    else
    {
        [self.lblNoResult setHidden:YES];
    }
}

- (void)initTableArray
{
    if (self.switchShowMain.on)
        arrProdcutList = [[DataManager sharedInstance] getProducts:self.txtAdd.text];
    else
        arrProdcutList = [[DataManager sharedInstance] getLocProducts:self.curLoc searchField:self.txtAdd.text];
}

#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == tblProcType) {
        return 1;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == tblProcType) {
        return 2;
    }
    return [arrProdcutList count];
}

- (CGFloat)tableView:( UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblProcType) {
        return 25.0f;
    }
    return 80.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblProcType) {
        UITableViewCell *cell = [tblProcType dequeueReusableCellWithIdentifier:@"UITableViewCellIdentifier"];
        
        if(cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCellIdentifier"];
        }
        
        [cell.textLabel setTextColor:[UIColor colorWithRed:67.0f/255.0f green:36.0f/255.0f blue:6.0f/255.0f alpha:1.0f]];
        [cell.textLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [cell.textLabel setFrame:cell.frame];
        [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
        
        if (indexPath.row) {
            [cell.textLabel setText:@"Finished"];
        } else {
            [cell.textLabel setText:@"Subfloor"];
        }
        
        return cell;
    }

    if (self.switchShowMain.on)
    {
        FSProductCell *cell = [tblProducts dequeueReusableCellWithIdentifier:@"FSLocProductCell"];
        
        if(cell == nil)
        {
            cell = [FSProductCell sharedCell];
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setDelegate:self];
        [cell setCurProduct:[arrProdcutList objectAtIndex:indexPath.row]];
        return cell;
    }
    else
    {
        FSLocProductCell *cell = [tblProducts dequeueReusableCellWithIdentifier:@"FSLocProductCell"];
        
        if(cell == nil)
        {
            cell = [FSLocProductCell sharedCell];
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setDelegate:self];
        [cell setCurLocProduct:[arrProdcutList objectAtIndex:indexPath.row]];
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblProcType) {
        if (indexPath.row) {
            if (self.switchShowMain.on)
            {
                [curCell.lblEditingProcType setText:@"Finished"];
                [curCell.curProduct setProductType:FSProductTypeFinished];
            }
            else
            {
                [curLocCell.lblEditingProcType setText:@"Finished"];
                [curLocCell.curLocProduct setLocProductType:FSProductTypeFinished];
            }
        } else {
            if (self.switchShowMain.on)
            {
                [curCell.lblEditingProcType setText:@"Subfloor"];
                [curCell.curProduct setProductType:FSProductTypeSubfloor];
            }
            else
            {
                [curLocCell.lblEditingProcType setText:@"Subfloor"];
                [curLocCell.curLocProduct setLocProductType:FSProductTypeSubfloor];
            }
        }
        [self hideCombo];
    }
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - custom
- (void)showAlertAnimation
{
    [UIView animateWithDuration:0.2f animations:^{
        delete_alertview.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    }completion:^(BOOL finished){
        [UIView animateWithDuration:0.07f animations:^{
            delete_alertview.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        }completion:nil];
    }];
}

- (void)hideAlertAnimation
{
    [UIView animateWithDuration:0.1f animations:^{
        delete_alertview.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    }completion:^(BOOL finished){
        [delete_alertview setHidden:YES];
    }];
}

- (void)showSelectTypeView
{
    [viewSelectType setHidden:NO];
    [UIView animateWithDuration:0.1f animations:^{
        CGRect selectTypeFrame = viewSelectType.frame;
        selectTypeFrame.size.height = 50.0f;
        [viewSelectType setFrame:selectTypeFrame];
    }completion:nil];
}

- (void)hideSelectTypeView
{
    [UIView animateWithDuration:0.1f animations:^{
        CGRect selectTypeFrame = viewSelectType.frame;
        selectTypeFrame.size.height = 0.0f;
        [viewSelectType setFrame:selectTypeFrame];
    }completion:^(BOOL finished){
        [viewSelectType setHidden:YES];
    }];
}

#pragma mark - Cell Delegate
- (void)didEdit:(id)cell
{
    CGRect selectedCellFrame;
    if (self.switchShowMain.on)
    {
        curCell = cell;
        curLocCell = nil;
        selectedCellFrame = [curCell.superview convertRect:curCell.frame toView:self.view];
    }
    else
    {
        curLocCell = cell;
        curCell = nil;
        selectedCellFrame = [curLocCell.superview convertRect:curLocCell.frame toView:self.view];
    }
    
    
    if (selectedCellFrame.origin.y + 80 >= [[UIScreen mainScreen] bounds].size.height - 216) {
        trasnfromHeight = selectedCellFrame.origin.y + 80 - [[UIScreen mainScreen] bounds].size.height + 216;
        [UIView animateWithDuration:0.1f animations:^{
            [tblProducts setFrame:CGRectMake(tblProducts.frame.origin.x, tblProducts.frame.origin.y - trasnfromHeight, tblProducts.frame.size.width, tblProducts.frame.size.height)];
        }];
    } else {
        trasnfromHeight = 0;
    }
    
}

- (void)didDelete:(id)cell
{
    if (self.switchShowMain.on)
    {
        curCell = (FSProductCell *)cell;
        curLocCell = nil;
    }
    else
    {
        curCell = nil;
        curLocCell = (FSLocProductCell *)cell;
    }
    [self.view bringSubviewToFront:delete_alertview];
    [delete_alertview setHidden:NO];
    [self showAlertAnimation];
}

- (void)didOK:(id)cell
{
    if (self.switchShowMain.on)
    {
        curCell = (FSProductCell *)cell;
        curLocCell = nil;
        [curCell.curProduct setProductName:curCell.txtProductName.text];
        [[DataManager sharedInstance] updateProductToDatabase:curCell.curProduct];
    }
    else
    {
        curCell = nil;
        curLocCell = (FSLocProductCell *)cell;
        [curLocCell.curLocProduct setLocProductName:curLocCell.txtProductName.text];
        [[DataManager sharedInstance] updateLocProductToDatabase:curLocCell.curLocProduct];
        FSProduct *sameProduct = [[DataManager sharedInstance] getProductWithLocProduct:curLocCell.curLocProduct];
        if (sameProduct == nil)
        {
            sameProduct = [[FSProduct alloc] init];
            sameProduct.productID = 0;
            sameProduct.productName = curLocCell.curLocProduct.locProductName;
            sameProduct.productType = curLocCell.curLocProduct.locProductType;
            
            [[DataManager sharedInstance] addProductToDatabase:sameProduct];
        }
    }

    if (trasnfromHeight != 0) {
        [UIView animateWithDuration:0.1f animations:^{
            [tblProducts setFrame:CGRectMake(tblProducts.frame.origin.x, tblProducts.frame.origin.y + trasnfromHeight, tblProducts.frame.size.width, tblProducts.frame.size.height)];
        }];
    }
    [self hideCombo];
}

- (void)didCancel:(id)cell
{
    if (trasnfromHeight != 0) {
        [UIView animateWithDuration:0.1f animations:^{
            [tblProducts setFrame:CGRectMake(tblProducts.frame.origin.x, tblProducts.frame.origin.y + trasnfromHeight, tblProducts.frame.size.width, tblProducts.frame.size.height)];
        }];
    }
    [self hideCombo];
}

- (void)didCombo:(id)cell
{
    CGRect frame = tblProcType.frame;
    CGRect selectedCellProcViewFrame;
    
    if (self.switchShowMain.on)
    {
        curCell = (FSProductCell *)cell;
        curLocCell = nil;
        selectedCellProcViewFrame = [curCell.viewEditingProcType.superview convertRect:curCell.viewEditingProcType.frame toView:self.view];
    }
    else
    {
        curCell = nil;
        curLocCell = (FSLocProductCell *)cell;
        selectedCellProcViewFrame = [curLocCell.viewEditingProcType.superview convertRect:curLocCell.viewEditingProcType.frame toView:self.view];
    }
    frame.origin.x = selectedCellProcViewFrame.origin.x;
    frame.origin.y = selectedCellProcViewFrame.origin.y + 18.0f;
    [tblProcType setFrame:frame];
    if (frame.size.height == 0.0f) {
        [self showCombo];
    } else {
        [self hideCombo];
    }
}

- (void)showCombo
{
    CGRect frame = tblProcType.frame;
    frame.size.height = 50.0f;
    [UIView animateWithDuration:0.1f animations:^{
        [tblProcType setFrame:frame];
    }completion:^(BOOL finished){
        [tblProducts setScrollEnabled:NO];
    }];
}

- (void)hideCombo
{
    CGRect frame = tblProcType.frame;
    frame.size.height = 0.0f;
    [UIView animateWithDuration:0.1f animations:^{
        [tblProcType setFrame:frame];
    }completion:^(BOOL finished){
        [tblProducts setScrollEnabled:YES];
    }];
}

- (void)didDetail:(id)sender
{
    if (self.switchShowMain.on)
    {
        FSProductCell *cell = (FSProductCell *)sender;
        FSProduct *product = cell.curProduct;
        if (self.locProductSelectDelegate)
            [self.locProductSelectDelegate productSelected:product];
    }
    else
    {
        
        FSLocProductCell *cell = (FSLocProductCell *)sender;
        FSLocProduct *locProduct = cell.curLocProduct;
        if (self.locProductSelectDelegate)
            [self.locProductSelectDelegate locProductSelected:locProduct];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Action

- (IBAction)onDelete_OK:(id)sender
{
    if (self.switchShowMain.on)
    {
        [[DataManager sharedInstance] deleteProductFromDatabase:curCell.curProduct];
    }
    else
    {
        // check recording is for this product
        GlobalData *globalData = [GlobalData sharedData];
        if (globalData.isSaved && globalData.selectedLocProductID == curLocCell.curLocProduct.locProductID)
        {
            [CommonMethods showAlertUsingTitle:@"" andMessage:@"Recording is for this Product.\nPlease 'Cancel' recording first to delete this product."];
            return;
        }
        [[DataManager sharedInstance] deleteLocProductFromDatabase:curLocCell.curLocProduct];
    }
        

    [self initTable];
    [self hideAlertAnimation];
}

- (IBAction)onDelete_Cancel:(id)sender
{
    [self hideAlertAnimation];
}

- (IBAction)onSelectType:(id)sender
{
    [self.view bringSubviewToFront:viewSelectType];
    [self showSelectTypeView];
}

- (IBAction)onSelectFinished:(id)sender
{
    finishNum = FSProductTypeFinished;
    [lblSelectType setText:@"Finished"];
    [btnSubfloor setSelected:NO];
    [btnFinished setSelected:YES];
    [self hideSelectTypeView];
}

- (IBAction)onSelectSubfloor:(id)sender
{
    finishNum = FSProductTypeSubfloor;
    [lblSelectType setText:@"Subfloor"];
    [btnSubfloor setSelected:YES];
    [btnFinished setSelected:NO];
    [self hideSelectTypeView];
}

- (IBAction)onAdd:(id)sender
{
    if ([txtAdd.text isEqualToString:@""]) {
        [CommonMethods showAlertUsingTitle:@"" andMessage:@"Input Product Name to add!"];
        return;
    }
    
    if (self.switchShowMain.on)
    {
        // add product to main product list
        
        FSProduct *product = [[FSProduct alloc] init];
        product.productName = txtAdd.text;
        product.productType = finishNum;
        
        product.productID = [[DataManager sharedInstance] addProductToDatabase:product];
    }
    else
    {
        // add product for a specific location
        FSLocProduct *locProduct = [[FSLocProduct alloc] init];
        locProduct.locProductID = 0;
        locProduct.locProductLocID = 0;
        locProduct.locProductName = txtAdd.text;
        locProduct.locProductType = finishNum;
        
        // default location
        if (self.curLoc.locID == 0)
        {
            // adde default location to location table
            int loc_id = [[DataManager sharedInstance] addLocationToDatabase:self.curLoc];
            self.curLoc = [[DataManager sharedInstance] getLocationFromID:loc_id];
        }
        if (self.curLoc != nil)
        {
            locProduct.locProductLocID = self.curLoc.locID;
            [[DataManager sharedInstance] addLocProductToDatabase:locProduct];
            
            FSProduct *sameProduct = [[DataManager sharedInstance] getProductWithLocProduct:locProduct];
            if (sameProduct == nil)
            {
                sameProduct = [[FSProduct alloc] init];
                sameProduct.productID = 0;
                sameProduct.productName = locProduct.locProductName;
                sameProduct.productType = locProduct.locProductType;
                
                [[DataManager sharedInstance] addProductToDatabase:sameProduct];
            }
        }
    }
    
    [self.txtAdd resignFirstResponder];
    [self.txtAdd setText:@""];
    
    [self initTable];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[arrProdcutList count] - 1 inSection:0];
    
    [tblProducts scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (IBAction)onClose:(id)sender
{
    [txtAdd setText:@""];
    [self initTable];
}

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSearch:(id)sender
{
    [self initTable];
}

- (IBAction)onSearchCancel:(id)sender
{
    [txtSearch resignFirstResponder];
    [txtSearch setText:@""];
    
    [self initTable];
}

- (IBAction)onSwitch:(id)sender
{
    [self initTable];
}

@end
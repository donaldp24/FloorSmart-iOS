//
//  FSProductViewController.m
//  FloorSmart
//
//  Created by Lydia on 12/23/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import "FSProductViewController.h"
#import "FSProductCell.h"
#import "DataManager.h"
#import "Global.h"
#import "FSProduct.h"

@interface FSProductViewController ()
{
    NSMutableArray *arrProdcutList;
    CGFloat trasnfromHeight;
    int finishNum;
    FSProductCell *curCell;
    UITableView *tblProcType;
}
@end

@implementation FSProductViewController
@synthesize isEditing = _isEditing;
@synthesize tblProducts, btnFly, popView, viewTopAdd, viewTopSearch, txtTop, viewSelectType, lblSelectType, btnFinished, btnSubfloor;
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
    
    [popView setArrContents:[NSArray arrayWithObjects:@"Add a Product", @"Search Product", nil]];
    [popView setDelegate:self];
    CGRect popFrame = popView.frame;
    popFrame.size.height = 0;
    [popView setFrame:popFrame];
    
    CGRect selectTypeFrame = viewSelectType.frame;
    selectTypeFrame.size.height = 0;
    [viewSelectType setFrame:selectTypeFrame];
    [btnSubfloor setSelected:YES];
    [lblSelectType setText:@"Subfloor"];
    finishNum = 0;
    
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initTable
{
    arrProdcutList = [[DataManager sharedInstance] getProducts:@"" delFlag:0];
    [tblProducts setContentSize:CGSizeMake(tblProducts.frame.size.width, 80 * [arrProdcutList count])];
    [tblProducts reloadData];
}

#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == tblProcType) {
        return 1;
    }
    return [arrProdcutList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == tblProcType) {
        return 2;
    }
    return 1;
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
    FSProductCell *cell = [tblProducts dequeueReusableCellWithIdentifier:@"FSProductCell"];
    
    if(cell == nil)
    {
        cell = [FSProductCell sharedCell];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setDelegate:self];
    [cell setCurProduct:[arrProdcutList objectAtIndex:indexPath.section]];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblProcType) {
        [curCell.curProduct setProductFinished:indexPath.row];
        if (indexPath.row) {
            [curCell.lblEditingProcType setText:@"Finished"];
        } else {
            [curCell.lblEditingProcType setText:@"Subfloor"];
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

#pragma mark - PopView Delegate
- (void)didPopUpItem
{
    [UIView animateWithDuration:0.1f animations:^{
        CGRect popFrame = popView.frame;
        popFrame.size.height = 0.0f;
        [popView setFrame:popFrame];
    }completion:^(BOOL finished){
        [popView setHidden:YES];
        switch (popView.selectedNum) {
            case 0:
                [viewTopSearch setHidden:YES];
                [viewTopAdd setHidden:NO];
                [txtTop setText:@""];
                [txtTop setPlaceholder:@"Add Product"];
                break;
            case 1:
                [viewTopAdd setHidden:YES];
                [viewTopSearch setHidden:NO];
                [txtTop setText:@""];
                [txtTop setPlaceholder:@"Search Product"];
                break;
            default:
                break;
        }
    }];
}

#pragma mark - custom
- (void)showAlertAnimation
{
    [UIView animateWithDuration:0.2f animations:^{
        delete_alertview.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
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
- (void)didEdit:(FSProductCell *)cell
{
    curCell = cell;
    CGRect selectedCellFrame = [cell.superview convertRect:cell.frame toView:self.view];
    if (selectedCellFrame.origin.y + 80 >= [[UIScreen mainScreen] bounds].size.height - 216) {
        trasnfromHeight = selectedCellFrame.origin.y + 80 - [[UIScreen mainScreen] bounds].size.height + 216;
        [UIView animateWithDuration:0.1f animations:^{
            [tblProducts setFrame:CGRectMake(tblProducts.frame.origin.x, tblProducts.frame.origin.y - trasnfromHeight, tblProducts.frame.size.width, tblProducts.frame.size.height)];
        }];
    } else {
        trasnfromHeight = 0;
    }
    
}

- (void)didDelete:(FSProductCell *)cell
{
    curCell = cell;
    [self.view bringSubviewToFront:delete_alertview];
    [delete_alertview setHidden:NO];
    [self showAlertAnimation];
}

- (void)didOK:(FSProductCell *)cell
{
    [curCell.curProduct setProductName:cell.txtProductName.text];
    [[DataManager sharedInstance] updateProductToDatabase:curCell.curProduct];
//    [curProduct clear];
    if (trasnfromHeight != 0) {
        [UIView animateWithDuration:0.1f animations:^{
            [tblProducts setFrame:CGRectMake(tblProducts.frame.origin.x, tblProducts.frame.origin.y + trasnfromHeight, tblProducts.frame.size.width, tblProducts.frame.size.height)];
        }];
    }
    [self hideCombo];
}

- (void)didCancel:(FSProductCell *)cell
{
//    [curProduct clear];
    if (trasnfromHeight != 0) {
        [UIView animateWithDuration:0.1f animations:^{
            [tblProducts setFrame:CGRectMake(tblProducts.frame.origin.x, tblProducts.frame.origin.y + trasnfromHeight, tblProducts.frame.size.width, tblProducts.frame.size.height)];
        }];
    }
    [self hideCombo];
}

- (void)didCombo:(FSProductCell *)cell
{
    CGRect frame = tblProcType.frame;
    CGRect selectedCellProcViewFrame = [cell.viewEditingProcType.superview convertRect:cell.viewEditingProcType.frame toView:self.view];
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

#pragma mark - Action
- (IBAction)onFly:(id)sender
{    
    if (popView.hidden) {
        [popView setHidden:NO];
        [UIView animateWithDuration:0.1f animations:^{
            CGRect popFrame = popView.frame;
            popFrame.size.height = 60.0f;
            [popView setFrame:popFrame];
        }completion:nil];
    } else {
        [UIView animateWithDuration:0.1f animations:^{
            CGRect popFrame = popView.frame;
            popFrame.size.height = 0.0f;
            [popView setFrame:popFrame];
        }completion:^(BOOL finished){
            [popView setHidden:YES];
            
        }];
    }
}

- (IBAction)onDelete_OK:(id)sender
{
    curCell.curProduct.productDel = 1;
    [[DataManager sharedInstance] updateProductToDatabase:curCell.curProduct];
//    [curProduct clear];
    [self initTable];
    [self hideAlertAnimation];
}

- (IBAction)onDelete_Cancel:(id)sender
{
//    [curProduct clear];
    [self hideAlertAnimation];
}

- (IBAction)onSelectType:(id)sender
{
    [self.view bringSubviewToFront:viewSelectType];
    [self showSelectTypeView];
}

- (IBAction)onSelectFinished:(id)sender
{
    finishNum = 1;
    [lblSelectType setText:@"Finished"];
    [btnSubfloor setSelected:NO];
    [btnFinished setSelected:YES];
    [self hideSelectTypeView];
}

- (IBAction)onSelectSubfloor:(id)sender
{
    finishNum = 0;
    [lblSelectType setText:@"Subfloor"];
    [btnSubfloor setSelected:YES];
    [btnFinished setSelected:NO];
    [self hideSelectTypeView];
}

- (IBAction)onAdd:(id)sender
{
    if ([txtTop.text isEqualToString:@""]) {
        [CommonMethods showAlertUsingTitle:@"" andMessage:@"Input Product Name to add!"];
        return;
    }
    FSProduct *product = [[FSProduct alloc] init];
    product.productName = txtTop.text;
    product.productFinished = finishNum;
    [[DataManager sharedInstance] addProductToDatabase:product];
    [self initTable];
}

- (IBAction)onClose:(id)sender
{
    [txtTop setText:@""];
}

- (IBAction)onSearch:(id)sender
{
    arrProdcutList = [[DataManager sharedInstance] getProducts:txtTop.text delFlag:0];
    [tblProducts reloadData];
}

@end

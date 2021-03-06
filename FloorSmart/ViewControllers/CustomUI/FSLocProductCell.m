//
//  FSLocProductCell.m
//  FloorSmart
//
//  Created by Lydia on 12/25/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import "FSLocProductCell.h"
#import "FSLocProductViewController.h"
#import "Defines.h"

@implementation FSLocProductCell
@synthesize lblProductName, txtProductName, lblProductType, viewEdit, viewEditing, viewEditingProcType, lblEditingProcType;
@synthesize curLocProduct = _curLocProduct;
@synthesize delegate;

+ (FSLocProductCell *)sharedCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"FSLocProductCell" owner:nil options:nil];
    FSLocProductCell *cell = [array objectAtIndex:0];
    
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCurLocProduct:(FSLocProduct *)curLocProduct
{
    _curLocProduct = curLocProduct;
    [lblProductName setText:curLocProduct.locProductName];
    [lblProductType setText:[FSProduct getDisplayProductType:curLocProduct.locProductType]];
    self.curLocProductType = curLocProduct.locProductType;
}

#pragma mark - textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Action
- (IBAction)onEdit:(id)sender
{
    FSLocProductViewController *superController = (FSLocProductViewController *)self.delegate;
    if ([superController isEditing]) {
        return;
    }
    if([self.delegate respondsToSelector:@selector(didEdit:)])
    {
        [self.delegate performSelector:@selector(didEdit:) withObject:self];
    }
    [superController setIsEditing:YES];
    [txtProductName setText:lblProductName.text];
    [viewEdit setHidden:YES];
    [viewEditing setHidden:NO];
    [lblProductName setHidden:YES];
    [txtProductName setHidden:NO];
    [lblProductType setHidden:YES];
    [viewEditingProcType setHidden:NO];
    [lblEditingProcType setText:lblProductType.text];
    [txtProductName becomeFirstResponder];
}

- (IBAction)onDelete:(id)sender
{
    FSLocProductViewController *superController = (FSLocProductViewController *)self.delegate;
    if ([superController isEditing]) {
        return;
    }
    if([self.delegate respondsToSelector:@selector(didDelete:)])
    {
        [self.delegate performSelector:@selector(didDelete:) withObject:self];
    }
}

- (IBAction)onOK:(id)sender
{
    BOOL ret = [self.delegate didOK:self];
    if (ret)
    {
        FSLocProductViewController *superController = (FSLocProductViewController *)self.delegate;
        [superController setIsEditing:NO];
        [txtProductName resignFirstResponder];
        [txtProductName setHidden:YES];
        [lblProductName setText:[txtProductName text]];
        [txtProductName setText:@""];
        [lblProductName setHidden:NO];
        [viewEditing setHidden:YES];
        [viewEdit setHidden:NO];
        [lblProductType setText:lblEditingProcType.text];
        [lblProductType setHidden:NO];
        [viewEditingProcType setHidden:YES];
        [lblEditingProcType setText:@""];
    }
}

- (IBAction)onCancel:(id)sender
{
    if([self.delegate respondsToSelector:@selector(didCancel:)])
    {
        [self.delegate performSelector:@selector(didCancel:) withObject:self];
    }
    FSLocProductViewController *superController = (FSLocProductViewController *)self.delegate;
    [superController setIsEditing:NO];
    [txtProductName resignFirstResponder];
    [txtProductName setHidden:YES];
    [txtProductName setText:@""];
    [lblProductName setHidden:NO];
    [viewEditing setHidden:YES];
    [viewEdit setHidden:NO];
    [lblProductType setHidden:NO];
    [viewEditingProcType setHidden:YES];
    [lblEditingProcType setText:@""];
}

- (IBAction)onComboProc:(id)sender
{
    if([self.delegate respondsToSelector:@selector(didCombo:)])
    {
        [self.delegate performSelector:@selector(didCombo:) withObject:self];
    }
}

- (IBAction)onBgClick:(id)sender
{

    if([self.delegate respondsToSelector:@selector(didDetail:)])
    {
        [self.delegate performSelector:@selector(didDetail:) withObject:self];
    }

}

@end

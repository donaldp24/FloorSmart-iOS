//
//  FSRecordViewController.h
//  FloorSmart
//
//  Created by Lydia on 12/23/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSJobViewController.h"
#import "FSLocationsViewController.h"
#import "FSProductViewController.h"
#import "FSLocProductViewController.h"
#import "FSCurReadingsViewController.h"

@interface FSRecordViewController : UIViewController <UITextFieldDelegate, FSJobSelectDelegate, FSLocationSelectDelegate, FSLocProductSelectDelegate> {
    
    FSJob *selectedJob;
    FSLocation *selectedLocation;
    FSProduct *selectedProduct;
    FSLocProduct *selectedLocProduct;
    
    FSLocation *defaultLocation;
    FSProduct *defaultProduct;
    
    UITextField *curTextField;
    FSCurReadingsViewController *readingVC;
    
    BOOL isPrevSqureFoot;
}

@property (nonatomic, retain) IBOutlet UITextField *txtJob;
@property (nonatomic, retain) IBOutlet UITextField *txtLocation;
@property (nonatomic, retain) IBOutlet UITextField *txtProduct;
@property (nonatomic, retain) IBOutlet UITextField *txtCoverage;

@property (nonatomic, retain) IBOutlet UILabel *lblUnitFt;
@property (nonatomic, retain) IBOutlet UILabel *lblUnitM;

@property (nonatomic, retain) IBOutlet UIButton *btnSave;
@property (nonatomic, retain) IBOutlet UIButton *btnCancel;
@property (nonatomic, retain) IBOutlet UIButton *btnSummary;

// actions
- (IBAction)onSelJob:(id)sender;
- (IBAction)onSelLocation:(id)sender;
- (IBAction)onSelProduct:(id)sender;

// delegate methods
- (void)jobSelected:(FSJob *)job;
- (void)locationSelected:(FSLocation *)loc;
- (void)locationAdded:(FSLocation *)loc;
- (void)locProductSelected:(FSLocProduct *)locProduct;
- (void)productSelected:(FSProduct *)product;

// button actions
- (IBAction)onSaveClicked:(id)sender;
- (IBAction)onCancelClicked:(id)sender;
- (IBAction)onSummaryClicked:(id)sender;

- (BOOL)isSelectable;
- (void)showAlertForNotSelectable;

// text delegates
- (IBAction)BeginEditing:(UITextField *)sender;
- (IBAction)EndEditing:(UITextField *)sender;
- (IBAction)onBgClicked:(id)sender;

// save incoming data
- (void)saveNewData:(NSDictionary *)data;
- (void)showReadingView;
@end

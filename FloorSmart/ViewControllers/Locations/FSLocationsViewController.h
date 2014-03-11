//
//  FSLocationsViewController.h
//  FloorSmart
//
//  Created by Donald Pae on 3/11/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPopView.h"
#import "FSJob.h"
#import "FSLocationCell.h"
#import "FSLocation.h"
#import "FSLocSelCell.h"

@interface FSLocationsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, FSLocationCellDelegate, FSLocSelCellDelegate> {
    //
}

@property (nonatomic, strong) FSJob *curJob;
@property (nonatomic, strong) FSLocation *curLoc;

@property (nonatomic) BOOL isEditing;
@property (nonatomic, assign) IBOutlet UITableView *tblLoc;
@property (nonatomic, assign) IBOutlet UITableView *tblMainLoc;
@property (nonatomic, assign) IBOutlet UIButton *btnAdd;
@property (nonatomic, assign) IBOutlet UITextField *txtSearch;
@property (nonatomic, assign) IBOutlet UIView *archive_alertview;

@property (nonatomic, assign) IBOutlet UIView *viewAdd;
@property (nonatomic, assign) IBOutlet UIView *viewAddMain;

- (IBAction)onAddLoc:(id)sender;

- (IBAction)onCloseAddView:(id)sender;
- (IBAction)onSearch:(id)sender;

- (IBAction)onBack:(id)sender;
- (IBAction)onDeleteOk:(id)sender;
- (IBAction)onDeleteCancel:(id)sender;

// FSLocationCellDelegate
- (void)onEditCell:(id)sender;
- (void)onDeleteCell:(id)sender;
- (void)onEditFinishedOk:(id)sender;
- (void)onEditFinishedCancel:(id)sender;
- (BOOL)isEditing:(id)sender;
- (void)onSelectCell:(id)sender;
- (NSString *)getName:(id)sender;

// FSLocSelCellDelegate
- (void)onAddSelLoc:(id)sender;
- (NSString *)getLocName:(id)sender;

@end

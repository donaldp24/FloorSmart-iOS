//
//  FSReportViewController.h
//  FloorSmart
//
//  Created by Lydia on 12/23/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSJob.h"
#import "FSFeed.h"
#import "FSPopView.h"
#import <MessageUI/MessageUI.h>

@interface FSReportViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MFMailComposeViewControllerDelegate, UIPrintInteractionControllerDelegate>

@property (nonatomic, assign) IBOutlet UILabel *lblJob;
@property (nonatomic, assign) IBOutlet UILabel *lblLoc;
@property (nonatomic, assign) IBOutlet UILabel *lblProc;
@property (nonatomic, assign) IBOutlet UILabel *lblCover;
@property (nonatomic, assign) IBOutlet UILabel *lblMode;
@property (nonatomic, assign) IBOutlet UILabel *lblMaterial;
@property (nonatomic, assign) IBOutlet UILabel *lblSG;
@property (nonatomic, assign) IBOutlet UILabel *lblReadings;

@property (nonatomic, assign) IBOutlet UILabel *lblRecentDate;
@property (nonatomic, assign) IBOutlet UILabel *lblRecentMCAVG;
@property (nonatomic, assign) IBOutlet UILabel *lblRecentMCHigh;
@property (nonatomic, assign) IBOutlet UILabel *lblRecentMCLow;
@property (nonatomic, assign) IBOutlet UILabel *lblRecentEMCAVG;
@property (nonatomic, assign) IBOutlet UILabel *lblRecentRHAVG;
@property (nonatomic, assign) IBOutlet UILabel *lblRecentTempAVG;

@property (nonatomic, assign) IBOutlet UIView *viewEditingLoc;
@property (nonatomic, assign) IBOutlet UIView *viewEditLoc;
@property (nonatomic, assign) IBOutlet UITextField *txtAddLoc;

@property (nonatomic, assign) IBOutlet UIView *viewEditingProc;
@property (nonatomic, assign) IBOutlet UIView *viewEditProc;
@property (nonatomic, assign) IBOutlet UILabel *lblAddProc;

@property (nonatomic, assign) IBOutlet UIView *viewEditingCover;
@property (nonatomic, assign) IBOutlet UIView *viewEditCover;
@property (nonatomic, assign) IBOutlet UITextField *txtAddCover;

@property (nonatomic, assign) IBOutlet FSPopView *popView;

@property (nonatomic, strong) FSJob *curJob;
@property (nonatomic, strong) FSFeed *curFeed;

- (IBAction)onAddLoc:(id)sender;
- (IBAction)onOKLoc:(id)sender;
- (IBAction)onCancelLoc:(id)sender;

- (IBAction)onAddProc:(id)sender;
- (IBAction)onOKProc:(id)sender;
- (IBAction)onCancelProc:(id)sender;

- (IBAction)onEditCover:(id)sender;
- (IBAction)onDeleteCover:(id)sender;
- (IBAction)onOKCover:(id)sender;
- (IBAction)onCancelCover:(id)sender;

- (IBAction)onComboJob:(id)sender;
- (IBAction)onComboLoc:(id)sender;
- (IBAction)onComboProc:(id)sender;
- (IBAction)onComboAddProc:(id)sender;

- (IBAction)onReading:(id)sender;
- (IBAction)onBack:(id)sender;

@end

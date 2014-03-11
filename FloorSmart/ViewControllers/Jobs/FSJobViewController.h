//
//  FSJobViewController.h
//  FloorSmart
//
//  Created by Lydia on 12/23/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPopView.h"

@interface FSJobViewController : UIViewController <UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic) BOOL isEditing;

@property (nonatomic, assign) IBOutlet UITableView *tblJobs;

@property (nonatomic, assign) IBOutlet UIButton *btnFly;
@property (nonatomic, assign) IBOutlet FSPopView *popView;
@property (nonatomic, assign) IBOutlet UIView *viewTopAdd;
@property (nonatomic, assign) IBOutlet UIView *viewTopSearch;
@property (nonatomic, assign) IBOutlet UITextField *txtEdit;
@property (nonatomic, assign) IBOutlet UITextField *txtSearch;

@property (nonatomic, assign) IBOutlet UIView *archive_alertview;


- (void)didPopUpItem;

- (IBAction)onAdd:(id)sender;
- (IBAction)onClose:(id)sender;
- (IBAction)onSearch:(id)sender;
- (IBAction)onBtnBg:(id)sender;
- (IBAction)txtSearchChanged:(id)sender;
- (IBAction)onBtnCancel:(id)sender;


@end

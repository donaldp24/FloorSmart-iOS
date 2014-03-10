//
//  FSProductViewController.h
//  FloorSmart
//
//  Created by Lydia on 12/23/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPopView.h"

@interface FSProductViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic) BOOL isEditing;

@property (nonatomic, assign) IBOutlet UITableView *tblProducts;

@property (nonatomic, assign) IBOutlet UIButton *btnFly;
@property (nonatomic, assign) IBOutlet FSPopView *popView;
@property (nonatomic, assign) IBOutlet UIView *viewTopAdd;
@property (nonatomic, assign) IBOutlet UIView *viewTopSearch;
@property (nonatomic, assign) IBOutlet UITextField *txtTop;
@property (nonatomic, assign) IBOutlet UIView *viewSelectType;
@property (nonatomic, assign) IBOutlet UILabel *lblSelectType;
@property (nonatomic, assign) IBOutlet UIButton *btnFinished;
@property (nonatomic, assign) IBOutlet UIButton *btnSubfloor;

@property (nonatomic, assign) IBOutlet UIView *delete_alertview;

- (IBAction)onFly:(id)sender;
- (IBAction)onDelete_OK:(id)sender;
- (IBAction)onDelete_Cancel:(id)sender;
- (IBAction)onSelectType:(id)sender;
- (IBAction)onSelectFinished:(id)sender;
- (IBAction)onSelectSubfloor:(id)sender;

- (IBAction)onAdd:(id)sender;
- (IBAction)onClose:(id)sender;
- (IBAction)onSearch:(id)sender;

@end

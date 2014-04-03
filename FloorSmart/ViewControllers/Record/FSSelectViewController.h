//
//  FSSelectViewController.h
//  FloorSmart
//
//  Created by Donald Pae on 4/3/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MODE_SELECT_JOB 0
#define MODE_SELECT_LOCATION 1
#define MODE_SELECT_PRODUCT 2

@interface FSSelectViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSMutableArray *arrayData;
    int  _curRow;
    id  _parent;
    int _mode;
    id  _parentNode;
    id  _curSelectedData;
}

@property (nonatomic, strong) IBOutlet UILabel *lblTitle;
@property (nonatomic, strong) IBOutlet UIPickerView *picker;
@property (nonatomic, strong) IBOutlet UIView *viewContainer;

- (id) initWithParent : (NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil parent:(id)realParent mode:(int)mode parentNode:(id)parentNode;

- (void)setCurSelected:(id)data;

@end

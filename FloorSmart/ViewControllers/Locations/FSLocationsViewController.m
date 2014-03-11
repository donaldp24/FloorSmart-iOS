//
//  FSLocationsViewController.m
//  FloorSmart
//
//  Created by Donald Pae on 3/11/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "FSLocationsViewController.h"
#import "FSLocation.h"
#import "DataManager.h"

@interface FSLocationsViewController () {
    NSMutableArray *arrLoc;
    NSMutableArray *arrMainLoc;
    CGFloat trasnfromHeight;
}
@end

@implementation FSLocationsViewController

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
    // Do any additional setup after loading the view from its nib.
    
    arrLoc = [[DataManager sharedInstance] getFeedLocations:[self.curJob jobID]];
    arrMainLoc = [[DataManager sharedInstance] getMainLocations];
    
    [self.tblLoc setDataSource:self];
    [self.tblLoc setDelegate:self];
    [self.tblLoc setBackgroundColor:[UIColor clearColor]];
    
    [self.tblMainLoc setDataSource:self];
    [self.tblMainLoc setDelegate:self];
    
    trasnfromHeight = 0;
    
    self.archive_alertview.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
    [self.archive_alertview setHidden:YES];
    
    CGRect rt = self.viewAddMain.frame;
    self.viewAddMain.frame = CGRectMake(rt.origin.x, self.viewAdd.frame.origin.y + self.viewAdd.frame.size.height, rt.size.width, rt.size.height);
}

- (void)initTableData
{
    arrLoc = [[DataManager sharedInstance] getFeedLocations:[self.curJob jobID]];
    [self.tblLoc reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - actions

- (IBAction)onAddLoc:(id)sender
{
    [self showAddLocView];
}

- (IBAction)onCloseAddView:(id)sender
{
    [self hideAddLocView];
}

- (void) showAddLocView
{
    [self.viewAdd setHidden:NO];
    [self.viewAdd setAlpha:0];
    [self.view bringSubviewToFront:self.viewAdd];
    
    [UIView animateWithDuration:0.2f animations:^{
        self.viewAdd.alpha = 1.0f;
    }completion:^(BOOL finished){
        [UIView animateWithDuration:0.07f animations:^{
            CGRect rt = self.viewAddMain.frame;
            self.viewAddMain.frame = CGRectMake(rt.origin.x, self.viewAdd.frame.origin.y + self.viewAdd.frame.size.height - rt.size.height, rt.size.width, rt.size.height);
        }completion:nil];
    }];
}

- (void) hideAddLocView
{
    [UIView animateWithDuration:0.2f animations:^{
        self.viewAdd.alpha = 0.0f;
        CGRect rt = self.viewAddMain.frame;
        self.viewAddMain.frame = CGRectMake(rt.origin.x, self.viewAdd.frame.origin.y + self.viewAdd.frame.size.height, rt.size.width, rt.size.height);
    }completion:^(BOOL finished){
        [self.viewAdd setHidden:YES];
    }];
}


- (IBAction)onSearch:(id)sender
{
    //
}

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onDeleteOk:(id)sender
{
   
    FSFeed *feed = [[FSFeed alloc] init];
    [feed setFeedJobID:[[self.curJob jobID] integerValue]];
    [feed setFeedLocID:[[self.curLoc locID] integerValue]];
    //[feed setFeedProcID:-1];

    [[DataManager sharedInstance] deleteFeedFromDatabase:feed];
    [self initTableData];
    [self hideAlertAnimation];
}

- (IBAction)onDeleteCancel:(id)sender
{
    [self hideAlertAnimation];
}


- (void)showAlertAnimation
{
    [UIView animateWithDuration:0.2f animations:^{
        self.archive_alertview.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    }completion:^(BOOL finished){
        [UIView animateWithDuration:0.07f animations:^{
            self.archive_alertview.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        }completion:nil];
    }];
}

- (void)hideAlertAnimation
{
    [UIView animateWithDuration:0.1f animations:^{
        self.archive_alertview.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    }completion:^(BOOL finished){
        [self.archive_alertview setHidden:YES];
    }];
}

#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tblLoc)
        return [arrLoc count];
    else
        return [arrMainLoc count];
}

- (CGFloat)tableView:( UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tblLoc)
        return 60.0f;
    else
        return 40.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tblLoc)
    {
        FSLocationCell *cell = [self.tblLoc dequeueReusableCellWithIdentifier:@"FSLocationCell"];
        
        if(cell == nil)
        {
            cell = (FSLocationCell *)[FSLocationCell cellFromNibNamed:@"FSLocationCell"];
            [cell setIdentifier:@"FSLocationCell"];
        }
        cell.delegate = self;
        [cell setData:[arrLoc objectAtIndex:indexPath.row]];
        
        return cell;
    }
    else
    {
        FSLocSelCell *cell = [self.tblMainLoc dequeueReusableCellWithIdentifier:@"FSLocSelCell"];
        
        if(cell == nil)
        {
            cell = (FSLocSelCell *)[FSLocSelCell cellFromNibNamed:@"FSLocSelCell"];
            [cell setIdentifier:@"FSLocationCell"];
        }
        cell.delegate = self;
        [cell setLocData:[arrMainLoc objectAtIndex:indexPath.row]];
        
        return cell;
    }
}

#pragma mark - textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    //[self onAdd:textField];
    return YES;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - FSCellDelegate
- (void)onEditCell:(id)sender
{
    FSLocationCell *cell = (FSLocationCell *)sender;
    _curLoc = (FSLocation *)cell.data;
    CGRect selectedCellFrame = [cell.superview convertRect:cell.frame toView:self.view];
    if (selectedCellFrame.origin.y + 60 >= [[UIScreen mainScreen] bounds].size.height - 216) {
        trasnfromHeight = selectedCellFrame.origin.y + 60 - [[UIScreen mainScreen] bounds].size.height + 216;
        [UIView animateWithDuration:0.2f animations:^{
            [self.tblLoc setFrame:CGRectMake(self.tblLoc.frame.origin.x, self.tblLoc.frame.origin.y - trasnfromHeight, self.tblLoc.frame.size.width, self.tblLoc.frame.size.height)];
        }];
    } else {
        trasnfromHeight = 0;
    }
    
    self.isEditing = YES;

}

- (void)onDeleteCell:(id)sender
{
    FSLocationCell *cell = (FSLocationCell *)sender;
    self.curLoc = cell.data;
    [self.view bringSubviewToFront:self.archive_alertview];
    [self.archive_alertview setHidden:NO];
    [self showAlertAnimation];
}

- (void)onEditFinishedOk:(id)sender
{
    self.isEditing = NO;
    
    FSLocationCell *cell = (FSLocationCell *)sender;
    [self.curLoc setLocName:[cell.txtName text]];
    
    
    [[DataManager sharedInstance] updateLocToDatabase:self.curLoc];
    if (trasnfromHeight != 0) {
        [UIView animateWithDuration:0.2f animations:^{
            [self.tblLoc setFrame:CGRectMake(self.tblLoc.frame.origin.x, self.tblLoc.frame.origin.y + trasnfromHeight, self.tblLoc.frame.size.width, self.tblLoc.frame.size.height)];
        }];
    }
    [self initTableData];
}

- (void)onEditFinishedCancel:(id)sender
{
    self.isEditing = NO;
    
    if (trasnfromHeight != 0) {
        [UIView animateWithDuration:0.1f animations:^{
            [self.tblLoc setFrame:CGRectMake(self.tblLoc.frame.origin.x, self.tblLoc.frame.origin.y + trasnfromHeight, self.tblLoc.frame.size.width, self.tblLoc.frame.size.height)];
        }];
    }
}

- (BOOL)isEditing:(id)sender
{
    return self.isEditing;
}

- (void)onSelectCell:(id)sender
{
    //
}

- (NSString *)getName:(id)sender
{
    FSLocationCell *cell = (FSLocationCell *)sender;
    FSLocation *loc = (FSLocation *)cell.data;
    return loc.locName;
}

#pragma mark - FSLocSelDelegate
- (void)onAddSelLoc:(id)sender
{
    FSLocSelCell *cell = (FSLocSelCell *)sender;
    FSLocation *loc = (FSLocation *)cell.locData;

    FSFeed *feed = [[FSFeed alloc] init];
    [feed setFeedJobID:[[self.curJob jobID] integerValue]];
    [feed setFeedLocID:[[loc locID] integerValue]];
    [feed setFeedProcID:-1];
    [[DataManager sharedInstance] addFeedToDatabase:feed];
    
    [self initTableData];
    
    [self hideAddLocView];
}

- (NSString *)getLocName:(id)sender
{
    FSLocSelCell *cell = (FSLocSelCell *)sender;
    FSLocation *loc = (FSLocation *)cell.locData;
    return loc.locName;
}

@end

//
//  FSJobViewController.m
//  FloorSmart
//
//  Created by Lydia on 12/23/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import "FSJobViewController.h"
#import "FSPopContentController.h"
#import "FSJobCell.h"
#import "FSJob.h"
#import "DataManager.h"
#import "Global.h"
#import "FSArchiveJobViewController.h"
#import "FSReportViewController.h"
#import "FSMainViewController.h"

@interface FSJobViewController ()
{
    NSMutableArray *arrJobNames;
    CGFloat trasnfromHeight;
    FSJob *curJob;
}
@end

@implementation FSJobViewController
@synthesize isEditing = _isEditing;
@synthesize tblJobs, btnFly, popView, viewTopAdd, viewTopSearch, txtTop;
@synthesize archive_alertview;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    archive_alertview.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
    [archive_alertview setHidden:YES];
    [tblJobs setBackgroundColor:[UIColor clearColor]];
    trasnfromHeight = 0;
    _isEditing = NO;
    curJob = [[FSJob alloc] init];

    [popView setArrContents:[NSArray arrayWithObjects:@"Add a Job", @"Search Job", @"View Archived Jobs", nil]];
    [popView setDelegate:self];
    CGRect popFrame = popView.frame;
    popFrame.size.height = 0;
    [popView setFrame:popFrame];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initTableData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)initTableData
{
    arrJobNames = [[DataManager sharedInstance] getJobs:0 searchField:@""];
    [tblJobs setContentSize:CGSizeMake(tblJobs.frame.size.width, 60 * [arrJobNames count])];
    [tblJobs reloadData];
}

#pragma mark - textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [arrJobNames count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:( UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSJobCell *cell = [tblJobs dequeueReusableCellWithIdentifier:@"FSJobCell"];
    
    if(cell == nil)
    {
        cell = [FSJobCell sharedCell];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setDelegate:self];
    [cell setCurJob:[arrJobNames objectAtIndex:indexPath.section]];
    
    return cell;
}

#pragma mark - PopView Delegate
- (void)didPopUpItem
{
    [UIView animateWithDuration:0.2f animations:^{
        CGRect popFrame = popView.frame;
        popFrame.size.height = 0.0f;
        [popView setFrame:popFrame];
    }completion:^(BOOL finished){
        [popView setHidden:YES];
        switch (popView.selectedNum) {
            case 0:
                [viewTopSearch setHidden:YES];
                [viewTopAdd setHidden:NO];
                [self initTableData];
                [txtTop setText:@""];
                [txtTop setPlaceholder:@"Add Job"];
                break;
            case 1:
                [viewTopAdd setHidden:YES];
                [viewTopSearch setHidden:NO];
                [txtTop setText:@""];
                [txtTop setPlaceholder:@"Search Job"];
                break;
            default:
                [self navigateArchive];
                break;
        }
    }];
}

#pragma mark - custom
- (void)navigateArchive
{
    FSArchiveJobViewController *vc = [[FSArchiveJobViewController alloc] initWithNibName:@"FSArchiveJobViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showAlertAnimation
{
    [UIView animateWithDuration:0.2f animations:^{
        archive_alertview.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
    }completion:^(BOOL finished){
        [UIView animateWithDuration:0.07f animations:^{
            archive_alertview.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        }completion:nil];
    }];
}

- (void)hideAlertAnimation
{
    [UIView animateWithDuration:0.1f animations:^{
        archive_alertview.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    }completion:^(BOOL finished){
        [archive_alertview setHidden:YES];
    }];
}

#pragma mark - Cell Delegate
- (void)didEdit:(FSJobCell *)cell
{
    curJob = cell.curJob;
    CGRect selectedCellFrame = [cell.superview convertRect:cell.frame toView:self.view];
    if (selectedCellFrame.origin.y + 60 >= [[UIScreen mainScreen] bounds].size.height - 216) {
        trasnfromHeight = selectedCellFrame.origin.y + 60 - [[UIScreen mainScreen] bounds].size.height + 216;
        [UIView animateWithDuration:0.2f animations:^{
            [tblJobs setFrame:CGRectMake(tblJobs.frame.origin.x, tblJobs.frame.origin.y - trasnfromHeight, tblJobs.frame.size.width, tblJobs.frame.size.height)];
        }];
    } else {
        trasnfromHeight = 0;
    }
}

- (void)didArchive:(FSJobCell *)cell
{
    curJob = cell.curJob;
    [self.view bringSubviewToFront:archive_alertview];
    [archive_alertview setHidden:NO];
    [self showAlertAnimation];
}

- (void)didOK:(FSJobCell *)cell
{
    [curJob setJobName:[cell.txtJobName text]];
    [[DataManager sharedInstance] updateJobToDatabase:curJob];
    if (trasnfromHeight != 0) {
        [UIView animateWithDuration:0.2f animations:^{
            [tblJobs setFrame:CGRectMake(tblJobs.frame.origin.x, tblJobs.frame.origin.y + trasnfromHeight, tblJobs.frame.size.width, tblJobs.frame.size.height)];
        }];
    }
    [self initTableData];
}

- (void)didCancel:(FSJobCell *)cell
{
//    [curJob clear];
    if (trasnfromHeight != 0) {
        [UIView animateWithDuration:0.1f animations:^{
            [tblJobs setFrame:CGRectMake(tblJobs.frame.origin.x, tblJobs.frame.origin.y + trasnfromHeight, tblJobs.frame.size.width, tblJobs.frame.size.height)];
        }];
    }
}

- (void)didDetail:(FSJobCell *)cell
{
    FSMainViewController *mainController = [FSMainViewController sharedController];
    UINavigationController *nav =(UINavigationController *)[[mainController viewControllers] objectAtIndex:2];
    FSReportViewController *report = (FSReportViewController *)[[nav viewControllers] objectAtIndex:0];
    [report setCurJob:cell.curJob];
    [mainController selectItem:mainController.btnReports];
}

#pragma mark - Actions
- (IBAction)onFly:(id)sender;
{    
    if (popView.hidden) {
        [popView setHidden:NO];
        [UIView animateWithDuration:0.1f animations:^{
            CGRect popFrame = popView.frame;
            popFrame.size.height = 90.0f;
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

- (IBAction)onArchive_OK:(id)sender
{
    [curJob setJobArchived:1];
    [[DataManager sharedInstance] updateJobToDatabase:curJob];
    [self initTableData];
    [self hideAlertAnimation];
}

- (IBAction)onArchive_Cancel:(id)sender
{
//    [curJob clear];
    [self hideAlertAnimation];
}

- (IBAction)onAdd:(id)sender
{
    if ([txtTop.text isEqualToString:@""]) {
        [CommonMethods showAlertUsingTitle:@"" andMessage:@"Input Job Name to add!"];
        return;
    }
    FSJob *job = [[FSJob alloc] init];
    job.jobName = txtTop.text;
    [[DataManager sharedInstance] addJobToDatabase:job];
    [self initTableData];
}

- (IBAction)onClose:(id)sender
{
    [txtTop setText:@""];
}

- (IBAction)onSearch:(id)sender
{
    arrJobNames = [[DataManager sharedInstance] getJobs:0 searchField:txtTop.text];
    [tblJobs reloadData];
}

@end

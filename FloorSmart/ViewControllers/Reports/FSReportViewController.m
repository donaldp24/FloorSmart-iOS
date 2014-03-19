//
//  FSReportViewController.m
//  FloorSmart
//
//  Created by Lydia on 12/23/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import "FSReportViewController.h"
#import "FSMainViewController.h"
#import "FSReadingsViewController.h"
#import "DataManager.h"
#import "Global.h"

@interface FSReportViewController ()
{
    UITableView *tblJob;
    UITableView *tblLoc;
    UITableView *tblProc;
    UITableView *tblAddProc;
    NSMutableArray *arrJobs;
    NSMutableArray *arrFeeds;
    NSMutableArray *arrLoc;
    NSMutableArray *arrProc;
    NSMutableArray *arrAddProc;
    FSProduct *curAddProc;
    BOOL isEditing;
}
@end

@implementation FSReportViewController
@synthesize lblJob, lblLoc, lblProc, viewEditingLoc, viewEditLoc, txtAddLoc, viewEditingProc, viewEditProc, lblAddProc, popView;
@synthesize lblCover, viewEditCover, viewEditingCover, txtAddCover, lblMode, lblMaterial, lblSG, lblReadings;
@synthesize lblRecentDate, lblRecentEMCAVG, lblRecentMCAVG, lblRecentMCHigh, lblRecentMCLow, lblRecentRHAVG, lblRecentTempAVG;
@synthesize curJob = _curJob;
@synthesize curLocProduct = _curLocProduct;

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
    
    CGRect frameLblJob = [lblJob.superview convertRect:lblJob.frame toView:self.view];
    tblJob = [[UITableView alloc] initWithFrame:CGRectMake(frameLblJob.origin.x - 5, frameLblJob.origin.y + frameLblJob.size.height + 1, frameLblJob.size.width +40, 0) style:UITableViewStylePlain];
    [tblJob setDataSource:self];
    [tblJob setDelegate:self];
    [tblJob setAlpha:0.8f];
    [self.view addSubview:tblJob];
    
    CGRect frameLblLoc = [lblLoc.superview convertRect:lblLoc.frame toView:self.view];
    tblLoc = [[UITableView alloc] initWithFrame:CGRectMake(frameLblLoc.origin.x - 5, frameLblLoc.origin.y + frameLblLoc.size.height + 1, frameLblLoc.size.width +30, 0) style:UITableViewStylePlain];
    [tblLoc setDataSource:self];
    [tblLoc setDelegate:self];
    [tblLoc setAlpha:0.8f];
    [self.view addSubview:tblLoc];
    
    CGRect frameLblProc = [lblProc.superview convertRect:lblProc.frame toView:self.view];
    tblProc = [[UITableView alloc] initWithFrame:CGRectMake(frameLblProc.origin.x - 5, frameLblProc.origin.y + frameLblProc.size.height + 1, frameLblProc.size.width +30, 0) style:UITableViewStylePlain];
    [tblProc setDataSource:self];
    [tblProc setDelegate:self];
    [tblProc setAlpha:0.8f];
    [self.view addSubview:tblProc];
    
    CGRect frameLblAddProc = [lblAddProc.superview convertRect:lblAddProc.frame toView:self.view];
    tblAddProc = [[UITableView alloc] initWithFrame:CGRectMake(frameLblAddProc.origin.x - 5, frameLblAddProc.origin.y + frameLblAddProc.size.height + 1, frameLblAddProc.size.width +20, 0) style:UITableViewStylePlain];
    [tblAddProc setDataSource:self];
    [tblAddProc setDelegate:self];
    [tblAddProc setAlpha:0.8f];
    [self.view addSubview:tblAddProc];
    
    [popView setArrContents:[NSArray arrayWithObjects:@"Email Report", @"Print Report", nil]];
    [popView setDelegate:self];
    CGRect popFrame = popView.frame;
    popFrame.size.height = 0;
    [popView setFrame:popFrame];
    
    isEditing = NO;
    curAddProc = [[FSProduct alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [arrAddProc removeAllObjects];
    arrAddProc = [[DataManager sharedInstance] getAllProducts];
    [tblAddProc reloadData];
    
    arrJobs = [[DataManager sharedInstance] getAllJobs];
    if (!_curJob) {
        if ([arrJobs count] > 0) {
            [self setCurJob:(FSJob *)[arrJobs objectAtIndex:0]];
        } else {
            [self setCurJob:[[FSJob alloc] init]];
        }
    }
    
    [self fillFeed:nil andProc:nil];
    [tblJob reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];    
}

- (void)fillFeed:(FSLocation *)loc andProc:(FSProduct *)proc
{
    /*
    if ([[_curJob jobID] isEqualToString:@"-1"]) {
        [self setCurFeed:[[FSFeed alloc] init]];
        [self fillContent:loc andProc:proc];
        return;
    }
    
    NSInteger locID = (loc) ? [loc.locID integerValue] : -1;
    NSInteger procID = (proc) ? [proc.productID integerValue] : -1;
    arrFeeds = [[DataManager sharedInstance] getFeeds:[_curJob jobID] locID:locID procID:procID];
    if ([arrFeeds count]) {
        [self setCurFeed:(FSFeed *)[arrFeeds objectAtIndex:0]];
    } else {
        FSFeed *feed = [[FSFeed alloc] init];
        [feed setFeedJobID:[[_curJob jobID] integerValue]];
        [self setCurFeed:feed];
    }
    [self fillContent:loc andProc:proc];
     */
}

- (void)fillContent:(FSLocation *)loc andProc:(FSProduct *)proc
{
    /* //
    if ([_curFeed feedJobID] == -1) {
        [lblJob setText:@"No Job"];
        [lblLoc setText:@""];
        [lblProc setText:@""];
        [lblCover setText:@""];
        [lblMode setText:@""];
        [lblMaterial setText:@""];
        [lblSG setText:@""];
        [lblReadings setText:@""];
        [arrLoc removeAllObjects];
        [tblLoc reloadData];
        [arrProc removeAllObjects];
        [tblProc reloadData];
        return;
    }
    
    [lblJob setText:[_curJob jobName]];
    if ([[_curFeed feedID] isEqualToString:@"-1"]) {
        [lblLoc setText:@"Default"];
        [lblProc setText:@"Default"];
        [lblCover setText:@""];
        [lblMode setText:@""];
        [lblMaterial setText:@""];
        [lblSG setText:@""];
        [lblReadings setText:@""];
        [arrLoc removeAllObjects];
        [tblLoc reloadData];
        [arrProc removeAllObjects];
        [tblProc reloadData];
        return;
    }
    
    arrLoc = [[DataManager sharedInstance] getFeedLocations:[_curJob jobID]];
    arrProc = [[DataManager sharedInstance] getFeedProducts:[_curJob jobID] loc:[_curFeed feedLocID]];
     
    [tblLoc reloadData];
    [tblProc reloadData];
    if ([arrLoc count] == 0) {
        [lblLoc setText:@""];
    } else {
        [lblLoc setText:(loc) ? [loc locName] : [(FSLocation *)[arrLoc objectAtIndex:0] locName]];
    }
    if ([arrProc count] == 0) {
        [lblProc setText:@"Default"];
    } else {
        [lblProc setText:(proc) ? [proc productName] : [(FSProduct *)[arrProc objectAtIndex:0] productName]];
    }
    [self showFeedMasters];
    [self showRecentData];
     */
}

- (void)showFeedMasters
{
    /* //
    [lblCover setText:[_curFeed feedCoverage]];//needed
    NSString *str = @"";
    switch (_curFeed.feedMode) {
        case 0:
            str = @"";
            break;
        case 1:
            str = @"1/4\"";
            break;
        case 2:
            str = @"3/4\"";
            break;
        default:
            break;
    }
    [lblMode setText:str];
    switch (_curFeed.feedmaterial) {
        case 0:
            str = @"";
            break;
        case 1:
            str = @"normal";
            break;
        case 2:
            str = @"relative";
            break;
        case 3:
            str = @"concrete";
            break;
        default:
            break;
    }
    [lblMaterial setText:str];
    
    [lblSG setText:[NSString stringWithFormat:@"%.2f", (float)[_curLocProduct feedsg] / 100]];
    [lblReadings setText:[NSString stringWithFormat:@"%d", (int)[[DataManager sharedInstance] getReadingsCount:[_curFeed feedID]]]];
     */
}

- (void)showRecentData
{
    /* //
    NSMutableArray *arrRecentDates = [[DataManager sharedInstance] getAllReadingDates:[_curFeed feedID]];
    if (![arrRecentDates count]) {
        [lblRecentDate setText:@""];
        [lblRecentMCAVG setText:[NSString stringWithFormat:@"MC Avg:"]];
        [lblRecentMCHigh setText:[NSString stringWithFormat:@"MC High:"]];
        [lblRecentMCLow setText:[NSString stringWithFormat:@"MC Low:"]];
        [lblRecentEMCAVG setText:[NSString stringWithFormat:@"EMC Avg:"]];
        [lblRecentRHAVG setText:[NSString stringWithFormat:@"RH Avg:"]];
        [lblRecentTempAVG setText:[NSString stringWithFormat:@"Temp Avg:"]];
        return;
    }
    NSString *recentDate = (NSString *)[arrRecentDates objectAtIndex:0];
    NSMutableArray *arrRecentReadings = [[DataManager sharedInstance] getReadings:[_curFeed feedID] withDate:recentDate];
    [lblRecentDate setText:[_globalData convertDateToSettingsFormat:recentDate]];
    FSReading *firstRow = (FSReading *)[arrRecentReadings objectAtIndex:0];//needed
    float mcValue = (float)[firstRow readMC] / 10;
    [lblRecentMCAVG setText:[NSString stringWithFormat:@"MC Avg: %.1f%@", mcValue, @"%"]];
    [lblRecentMCHigh setText:[NSString stringWithFormat:@"MC High: %.1f%@", mcValue, @"%"]];
    [lblRecentMCLow setText:[NSString stringWithFormat:@"MC .Low: %.1f%@", mcValue, @"%"]];
    [lblRecentEMCAVG setText:[NSString stringWithFormat:@"EMC Avg: 39%@", @"%" ]];//needed
    [lblRecentRHAVG setText:[NSString stringWithFormat:@"RH Avg:%d%@", (int)[firstRow readRH], @"%"]];
    [lblRecentTempAVG setText:[NSString stringWithFormat:@"Temp Avg:%d%@", (int)[firstRow readTemp], @"%"]];//needed
     */
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == tblJob) {
        return [arrJobs count];
    } else if (tableView == tblLoc) {
        return [arrLoc count];
    } else if (tableView == tblProc) {
        return [arrProc count];
    } else if (tableView == tblAddProc) {
        return [arrAddProc count];
    } else return 0;
}

- (CGFloat)tableView:( UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 25.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tblJob dequeueReusableCellWithIdentifier:@"UITableViewCellIdentifier"];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCellIdentifier"];
    }
    
    [cell.textLabel setTextColor:lblJob.textColor];
    [cell.textLabel setFont:[UIFont systemFontOfSize:13]];
    
    if (tableView == tblJob) {
        [cell.textLabel setText:[(FSJob *)[arrJobs objectAtIndex:indexPath.row] jobName]];
    } else if (tableView == tblLoc) {
        [cell.textLabel setText:[(FSLocation *)[arrLoc objectAtIndex:indexPath.row] locName]];
    } else if (tableView == tblProc) {
        [cell.textLabel setText:[(FSProduct *)[arrProc objectAtIndex:indexPath.row] productName]];
    } else if (tableView == tblAddProc) {
        [cell.textLabel setText:[(FSProduct *)[arrAddProc objectAtIndex:indexPath.row] productName]];
    } else [cell.textLabel setText:@""];
    
    return cell;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*//
    if (tableView == tblJob) {
        [self setCurJob:(FSJob *)[arrJobs objectAtIndex:indexPath.row]];
        [self fillFeed:nil andProc:nil];
    } else if (tableView == tblLoc) {
        [self fillFeed:(FSLocation *)[arrLoc objectAtIndex:indexPath.row] andProc:nil];
    } else if (tableView == tblProc) {
        FSLocation *loc = [[DataManager sharedInstance] getLocationFromID:[_curFeed feedLocID]];
        [self fillFeed:loc andProc:(FSProduct *)[arrProc objectAtIndex:indexPath.row]];
    } else if (tableView == tblAddProc) {
        curAddProc = (FSProduct *)[arrAddProc objectAtIndex:indexPath.row];
        [lblAddProc setText:[curAddProc productName]];
    }
    
    [self hideCombo:tableView];
     */
}

#pragma mark - MFMailComposeViewControllerDelegate mothods
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    if ((result == MFMailComposeResultFailed) && (error != NULL)) {
        [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Can't send mail"];
    } else if (result == MFMailComposeResultSent) {
        [CommonMethods showAlertUsingTitle:@"Info" andMessage:@"Message Sent"];
    }
    
    [controller dismissViewControllerAnimated:YES completion:^(void){
        
    }];
}

#pragma mark - PopView Delegate
- (void)didPopUpItem
{
    /*//
    [UIView animateWithDuration:0.1f animations:^{
        CGRect popFrame = popView.frame;
        popFrame.size.height = 0.0f;
        [popView setFrame:popFrame];
    }completion:^(BOOL finished){
        [popView setHidden:YES];
        if ([_curFeed feedJobID] == -1) {
            [CommonMethods showAlertUsingTitle:@"Info" andMessage:@"No Job!"];
            return;
        }
        if ([[_curFeed feedID] isEqualToString:@"-1"]) {
            [CommonMethods showAlertUsingTitle:@"Info" andMessage:@"Add Location and Product!"];
            return;
        }
        switch (popView.selectedNum) {
            case 0:
                [self sendEmail];
                break;
            case 1:
                [self print];
                break;
            default:
                break;
        }
    }];
     */
}

#pragma mark - UIPrinterInteractionDelegate
//- (UIPrintPaper *)printInteractionController:(UIPrintInteractionController *)pic
//                                 choosePaper:(NSArray *)paperList {
//    CGSize pageSize = [self pageSizeForDocumentType:self.document.type];
//    return [UIPrintPaper bestPaperForPageSize:pageSize
//                          withPapersFromArray:paperList];
//}

#pragma mark - Custom Functions
- (void)sendEmail
{
    if(![MFMailComposeViewController canSendMail])
    {
        [CommonMethods showAlertUsingTitle:@"No Mail Accounts" andMessage:@"You don't have a Mail account configured, please configure to send email."];
        return;
    }
    
    // create an MFMailComposeViewController for sending an e-mail
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    
    // set controller's delegate to this objects
    controller.mailComposeDelegate = self;
    
    [controller setSubject:@"FloorSmart Job Overview"];
    
    [controller setMessageBody:[self getEmailBody] isHTML:YES];
    
    // show the MFMailComposeViewController
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentViewController:controller animated:YES completion:nil];
}

- (NSString *)getEmailBody
{
    /*//
    NSString *locName = [(FSLocation *)[[DataManager sharedInstance] getLocationFromID:[_curFeed feedLocID]] locName];
    NSString *procName = [(FSProduct *)[[DataManager sharedInstance] getProductFromID:[_curFeed feedProcID]] productName];
    NSString *feedMode = @"";
    switch (_curFeed.feedMode) {
        case 0:
            feedMode = @"";
            break;
        case 1:
            feedMode = @"1/4\"";
            break;
        case 2:
            feedMode = @"3/4\"";
            break;
        default:
            break;
    }
    NSString *feedMaterial = @"";
    switch (_curFeed.feedmaterial) {
        case 0:
            feedMaterial = @"";
            break;
        case 1:
            feedMaterial = @"normal";
            break;
        case 2:
            feedMaterial = @"relative";
            break;
        case 3:
            feedMaterial = @"concrete";
            break;
        default:
            break;
    }
    NSString *feedSG = [NSString stringWithFormat:@"%.2f", (float)[_curFeed feedsg] / 100];
    NSString *feedReadings = [NSString stringWithFormat:@"%d", (int)[[DataManager sharedInstance] getReadingsCount:[_curFeed feedID]]];
    
    NSString *embedHTML = [NSString stringWithFormat:@"%@%@%@", @"<html><head></head><body><p>", [NSString stringWithFormat:@"Job Name : %@\n Location : %@</p><p>Product : %@</p><p>Coverage : %@</p><p>Mode : %@</p><p>Material : %@</p><p>S.G : %@</p><p>Readings : %@", [_curJob jobName], locName, procName, [_curFeed feedCoverage], feedMode, feedMaterial, feedSG, feedReadings], @"</p></body></html>"];
    
    return embedHTML;
     */
    return @"";
}

- (void)print
{
    UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    pic.delegate = self;
    
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.jobName = @"JobOverViewPrint";
    pic.printInfo = printInfo;
    
    UIMarkupTextPrintFormatter *htmlFormatter = [[UIMarkupTextPrintFormatter alloc]
                                                 initWithMarkupText:[self getEmailBody]];
    htmlFormatter.startPage = 0;
    htmlFormatter.contentInsets = UIEdgeInsetsMake(72.0, 72.0, 72.0, 72.0); // 1 inch margins
    pic.printFormatter = htmlFormatter;
    pic.showsPageRange = YES;
    
    void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
    ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        if (!completed && error) {
            NSLog(@"Printing could not complete because of error: %@", error);
        }
    };

    [pic presentAnimated:YES completionHandler:completionHandler];
}

- (void)hideCombo:(UITableView *)tableView
{
    CGRect frameTable = tableView.frame;
    frameTable.size.height = 0.0f;
    [UIView animateWithDuration:0.1f animations:^{
        [tableView setFrame:frameTable];
    }completion:nil];
}

- (void)showCombo:(UITableView *)tableView
{
    CGRect frameTable = tableView.frame;
    frameTable.size.height = 100.0f;
    [UIView animateWithDuration:0.1f animations:^{
        [tableView setFrame:frameTable];
    }completion:nil];
}

#pragma mark - Action
- (IBAction)onComboJob:(id)sender
{
    if (isEditing) {
        return;
    }
    CGRect frameTblJob = tblJob.frame;
    if (frameTblJob.size.height == 0.0f) {
        [self showCombo:tblJob];
    } else {
        [self hideCombo:tblJob];
    }
}

- (IBAction)onComboLoc:(id)sender
{
    if (isEditing) {
        return;
    }
    CGRect frameTblLoc = tblLoc.frame;
    if (frameTblLoc.size.height == 0.0f) {
        [self showCombo:tblLoc];
    } else {
        [self hideCombo:tblLoc];
    }
}

- (IBAction)onComboProc:(id)sender
{
    if (isEditing) {
        return;
    }
    CGRect frameTblProc = tblProc.frame;
    if (frameTblProc.size.height == 0.0f) {
        [self showCombo:tblProc];
    } else {
        [self hideCombo:tblProc];
    }
}

- (IBAction)onComboAddProc:(id)sender
{
    if (!isEditing) {
        return;
    }
    CGRect frameTblAddProc = tblAddProc.frame;
    if (frameTblAddProc.size.height == 0.0f) {
        [self showCombo:tblAddProc];
    } else {
        [self hideCombo:tblAddProc];
    }
}

- (IBAction)onBack:(id)sender
{
    FSMainViewController *mainController = [FSMainViewController sharedController];
    //[mainController selectItem:mainController.btnHome];
}

- (IBAction)onReading:(id)sender
{
    /*//
    if ([_curFeed feedJobID] == -1) {
        return;
    }
    if ([[_curFeed feedID] isEqualToString:@"-1"]) {
        return;
    }
    FSReadingsViewController *vc = [[FSReadingsViewController alloc] initWithNibName:@"FSReadingsViewController" bundle:nil];
    [vc setCurFeed:_curFeed];
    [self.navigationController pushViewController:vc animated:YES];
     */
}

- (IBAction)onAddLoc:(id)sender
{
    isEditing = YES;
    [viewEditLoc setHidden:YES];
    [viewEditingLoc setHidden:NO];
    [lblLoc setHidden:YES];
    [txtAddLoc setHidden:NO];
    [txtAddLoc becomeFirstResponder];
}

- (IBAction)onOKLoc:(id)sender
{
    /*
    FSLocation *loc = [[FSLocation alloc] init];
    [loc setLocName:txtAddLoc.text];
    [[DataManager sharedInstance] addLocationToDatabase:loc];
    [loc setLocID:[NSString stringWithFormat:@"%d", [[DataManager sharedInstance] getMaxLocID]]];
    
    FSFeed *feed = [[FSFeed alloc] init];
    [feed setFeedJobID:[[_curJob jobID] integerValue]];
    [feed setFeedLocID:[[loc locID] integerValue]];
    [feed setFeedProcID:-1];
    [[DataManager sharedInstance] addFeedToDatabase:feed];
    
    isEditing = NO;
    [txtAddLoc resignFirstResponder];
    [txtAddLoc setHidden:YES];
    [txtAddLoc setText:@""];
    [lblLoc setHidden:NO];
    [viewEditingLoc setHidden:YES];
    [viewEditLoc setHidden:NO];
    
    [self fillFeed:loc andProc:nil];
     */
}

- (IBAction)onCancelLoc:(id)sender
{
    isEditing = NO;
    [txtAddLoc resignFirstResponder];
    [txtAddLoc setHidden:YES];
    [txtAddLoc setText:@""];
    [lblLoc setHidden:NO];
    [viewEditingLoc setHidden:YES];
    [viewEditLoc setHidden:NO];
}

- (IBAction)onAddProc:(id)sender
{
    /*//
    if ([_curFeed feedLocID] == -1) {
        [CommonMethods showAlertUsingTitle:@"" andMessage:@"Add a location first!"];
        return;
    }
    isEditing = YES;
    [viewEditProc setHidden:YES];
    [viewEditingProc setHidden:NO];
    [lblProc setHidden:YES];
    curAddProc = (FSProduct *)[arrAddProc objectAtIndex:0];
    [lblAddProc setText:[curAddProc productName]];
    [lblAddProc setHidden:NO];
     */
}

- (IBAction)onOKProc:(id)sender
{
    /*//
    FSFeed *feed = [[FSFeed alloc] init];
    [feed setFeedJobID:[[_curJob jobID] integerValue]];
    [feed setFeedLocID:[_curFeed feedLocID]];
    [feed setFeedProcID:[[curAddProc productID] integerValue]];
    if ([_curFeed feedProcID] == -1) {
        [feed setFeedID:[_curFeed feedID]];
        [[DataManager sharedInstance] updateFeedToDatabase:feed];
    } else {
        [[DataManager sharedInstance] addFeedToDatabase:feed];
    }
    
    FSLocation *loc = [[FSLocation alloc] init];
    [loc setLocID:[NSString stringWithFormat:@"%ld", [_curFeed feedLocID]]];
    loc = [[DataManager sharedInstance] getLocationFromID:[_curFeed feedLocID]];
    [self fillFeed:loc andProc:curAddProc];
    
    [self hideCombo:tblAddProc];
    isEditing = NO;
    [lblAddProc setHidden:YES];
    [lblAddProc setText:@""];
    [lblProc setHidden:NO];
    [viewEditingProc setHidden:YES];
    [viewEditProc setHidden:NO];
     */
}

- (IBAction)onCancelProc:(id)sender
{
    [self hideCombo:tblAddProc];
    isEditing = NO;
    [lblAddProc setHidden:YES];
    [lblAddProc setText:@""];
    [lblProc setHidden:NO];
    [viewEditingProc setHidden:YES];
    [viewEditProc setHidden:NO];
}

- (IBAction)onEditCover:(id)sender
{
    isEditing = YES;
    [viewEditCover setHidden:YES];
    [viewEditingCover setHidden:NO];
    [lblCover setHidden:YES];
    [txtAddCover setText:lblCover.text];
    [txtAddCover setHidden:NO];
    [txtAddCover becomeFirstResponder];
}

- (IBAction)onDeleteCover:(id)sender
{
    [lblCover setText:@""];
}

- (IBAction)onOKCover:(id)sender
{
    /*//
    isEditing = NO;
    [txtAddCover resignFirstResponder];
    [lblCover setText:txtAddCover.text];
    [_curFeed setFeedCoverage:[NSString stringWithFormat:@"%f", [lblLoc.text doubleValue]]];
    [txtAddCover setHidden:YES];
    [txtAddCover setText:@""];
    [lblCover setHidden:NO];
    [viewEditingCover setHidden:YES];
    [viewEditCover setHidden:NO];
     */
}

- (IBAction)onCancelCover:(id)sender
{
    isEditing = NO;
    [txtAddCover resignFirstResponder];
    [txtAddCover setHidden:YES];
    [txtAddCover setText:@""];
    [lblCover setHidden:NO];
    [viewEditingCover setHidden:YES];
    [viewEditCover setHidden:NO];
}

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

@end

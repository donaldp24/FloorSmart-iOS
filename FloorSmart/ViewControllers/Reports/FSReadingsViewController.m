//
//  FSReadingsViewController.m
//  FloorSmart
//
//  Created by Lydia on 1/5/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "FSReadingsViewController.h"
#import "FSMeasureCell.h"
#import "Global.h"
#import "DataManager.h"
#import "FSReading.h"
#import "FSReportCell.h"
//----
#import <CoreBluetooth/CoreBluetooth.h>
#import "Defines.h"

@interface FSReadingsViewController () <CBCentralManagerDelegate, CBPeripheralDelegate>

@end

@implementation FSReadingsViewController {
    NSMutableArray *arrReadingCounts;
    FSReportCell *selectedCell;
    NSMutableArray *arrOverallReadings;
    //------
    CBCentralManager *centralManager;
    CBPeripheral *discoveredPeripheral;
    NSMutableData *receivedData;
    CBUUID *characteristicUUID;
    CBUUID *serviceUUID;
    UIColor *infoColorOrdinal, *infoColorError, *infoColorSubscribed;
}
@synthesize tblDetal, txtReceiveData, internalInfoLabel, popView;
@synthesize lblLocName, lblProcName, lblJobName;
@synthesize tblReadingDates, viewOverall, lblOverEMCAVG, lblOverMCAVG, lblOverMCHigh, lblOverMCLow, lblOverRHAVG, lblOverTempAVG;
@synthesize curLocProduct = _curLocProduct;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //-------
        receivedData = [[NSMutableData alloc] init];
        characteristicUUID = [CBUUID UUIDWithString:BLUETOOTH_CHARACTERISTIC_UUID];
        serviceUUID = [CBUUID UUIDWithString:BLUETOOTH_SERVICE_UUID];
        discoveredPeripheral = nil;
        infoColorOrdinal = [UIColor colorWithRed:211.0/255.0 green:163.0/255.0 blue:51.0/255.0 alpha:1.0];
        infoColorError = [UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:66.0/255.0 alpha:1.0];
        infoColorSubscribed = [UIColor colorWithRed:40.0/255.0 green:181.0/255.0 blue:110.0/255.0 alpha:1.0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [tblDetal setBackgroundColor:[UIColor clearColor]];
    [tblReadingDates setBackgroundColor:[UIColor clearColor]];
    
    [popView setArrContents:[NSArray arrayWithObjects:@"Email Report", @"Print Report", nil]];
    [popView setDelegate:self];
    CGRect popFrame = popView.frame;
    popFrame.size.height = 0;
    [popView setFrame:popFrame];
    
    CGRect overallFrame = viewOverall.frame;
    overallFrame.size.height = 0;
    [viewOverall setFrame:overallFrame];
   

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    /*//
    if (_curFeed) {
        NSLog(@"%@, %ld, %ld, %ld", _curFeed.feedID, _curFeed.feedJobID, _curFeed.feedLocID, _curFeed.feedProcID);
        [self initDateTable];
        NSString *jobName = [(FSJob *)[[DataManager sharedInstance] getJobFromID:[_curFeed feedJobID]] jobName];
        NSString *locName = [(FSLocation *)[[DataManager sharedInstance] getLocationFromID:[_curFeed feedLocID]] locName];
        NSString *procName = [(FSProduct *)[[DataManager sharedInstance] getProductFromID:[_curFeed feedProcID]] productName];
        [lblJobName setText:jobName];
        [lblLocName setText:[NSString stringWithFormat:@"Location: %@", locName]];
        [lblProcName setText:[NSString stringWithFormat:@"Product: %@", procName]];
    }
     */
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

//------
-(void)viewWillDisappear:(BOOL)animated
{
    centralManager.delegate = nil;
    
    [self stopUsingPeripheral];
    [centralManager stopScan];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initDateTable
{
    if (self.curLocProduct == nil)
    {
        arrReadingCounts = [[NSMutableArray alloc] init];
    }
    else
    {
        /* //
        arrReadingCounts = [[DataManager sharedInstance] getAllReadingDates:[_curFeed feedID]];
        [tblReadingDates setContentSize:CGSizeMake(tblReadingDates.frame.size.width, 40 * [arrReadingCounts count])];
         */
    }
    [tblReadingDates reloadData];
 
}

#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == tblDetal) {
        return 1;
    }
    return [arrReadingCounts count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == tblDetal) {
        return [arrOverallReadings count];
    }
    return 1;
}

- (CGFloat)tableView:( UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblDetal) {
        return 25.0f;
    }
    return 40.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblDetal) {
        FSMeasureCell *cell = [tblDetal dequeueReusableCellWithIdentifier:@"FSMeasureCell"];
        
        if(cell == nil)
        {
            cell = [FSMeasureCell sharedCell];
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setDelegate:self];
    
        if (indexPath.row % 2 == 0) {
            [cell.contentView setBackgroundColor:[UIColor colorWithRed:193.0f/255.0f green:182.0f/255.0f blue:169.0f/255.0f alpha:1.0f]];
        } else {
            [cell.contentView setBackgroundColor:[UIColor colorWithRed:164.0f/255.0f green:149.0f/255.0f blue:130.0f/255.0f alpha:1.0f]];
        }
        
        [cell setCurReading:(FSReading *)[arrOverallReadings objectAtIndex:indexPath.row]];
        
        return cell;
    }
    FSReportCell *cell = [tblReadingDates dequeueReusableCellWithIdentifier:@"FSReportCell"];
    
    if(cell == nil)
    {
        cell = [FSReportCell sharedCell];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setDelegate:self];
    NSString *strDate = (NSString *)[arrReadingCounts objectAtIndex:indexPath.section];
    [cell setCurDate:[CommonMethods str2date:strDate withFormat:DATE_FORMAT]];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
    [UIView animateWithDuration:0.1f animations:^{
        CGRect popFrame = popView.frame;
        popFrame.size.height = 0.0f;
        [popView setFrame:popFrame];
    }completion:^(BOOL finished){
        [popView setHidden:YES];
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
}

#pragma mark - Cell Delegate
- (void)didDisclosure:(FSReportCell *)cell
{
    if (cell.curDate != selectedCell.curDate) {
        if (selectedCell) {
            if (selectedCell.isOpened) {
                selectedCell.isOpened = !selectedCell.isOpened;
            }
        }
        selectedCell = cell;
        [self hideOverall:YES];
        return;
    }
    selectedCell = cell;
    [self setOverallData];
    if (selectedCell.isOpened) {
        [self showOverall];
    } else {
        [self hideOverall:NO];
    }
}

- (void)didDelete:(FSMeasureCell *)cell
{
    if (selectedCell.isOpened) {
        [self hideOverall:NO];
        selectedCell.isOpened = NO;
    }
    if (cell) {
        [[DataManager sharedInstance] deleteReadingFromDatabase:cell.curReading];
    }
    [self initDateTable];
    [arrOverallReadings removeAllObjects];
    [tblDetal reloadData];
}

#pragma mark - Custom Methods
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
    
    
    [controller setMessageBody:[self getMessageBody] isHTML:YES];
    
    // show the MFMailComposeViewController
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentViewController:controller animated:YES completion:nil];
}

- (NSString *)getMessageBody
{
    /*
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
    NSString *jobName = [(FSJob *)[[DataManager sharedInstance] getJobFromID:[_curFeed feedJobID]] jobName];
    
    NSString *embedHTML = [NSString stringWithFormat:@"%@%@%@", @"<html><head></head><body><p>", [NSString stringWithFormat:@"Job Name : %@\n Location : %@</p><p>Product : %@</p><p>Coverage : %@</p><p>Mode : %@</p><p>Material : %@</p><p>S.G : %@</p><p>Readings : %@", jobName, locName, procName, [_curFeed feedCoverage], feedMode, feedMaterial, feedSG, feedReadings], @"</p></body></html>"];
    
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
                                                 initWithMarkupText:[self getMessageBody]];
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

- (void)setOverallData
{
    /*//
    [selectedCell setIsOpened:!selectedCell.isOpened];
    CGRect frame = viewOverall.frame;
    CGRect selectedCellProcViewFrame = [selectedCell.btnDisclosure.superview convertRect:selectedCell.btnDisclosure.frame toView:self.view];
    frame.origin.y = selectedCellProcViewFrame.origin.y + 28.0f;
    [viewOverall setFrame:frame];
    
    //setOverall Items
    arrOverallReadings = [[DataManager sharedInstance] getReadings:[_curFeed feedID] withDate:[CommonMethods date2str:selectedCell.curDate withFormat:DATE_FORMAT]];
    FSReading *firstRow = (FSReading *)[arrOverallReadings objectAtIndex:0];//needed
    float mcValue = (float)[firstRow readMC] / 10;
    [lblOverMCAVG setText:[NSString stringWithFormat:@"MC Avg: %.1f%@", mcValue, @"%"]];
    [lblOverMCHigh setText:[NSString stringWithFormat:@"MC High: %.1f%@", mcValue, @"%"]];
    [lblOverMCLow setText:[NSString stringWithFormat:@"MC Low: %.1f%@", mcValue, @"%"]];
    [lblOverEMCAVG setText:[NSString stringWithFormat:@"EMC Avg: 39%@", @"%" ]];//needed
    [lblOverRHAVG setText:[NSString stringWithFormat:@"RH Avg:%d%@", (int)[firstRow readRH], @"%"]];
    [lblOverTempAVG setText:[NSString stringWithFormat:@"Temp Avg:%d%@", (int)[firstRow readTemp], @"%"]];
    [tblDetal reloadData];
     */
}

- (void)showOverall
{
    CGRect frame = viewOverall.frame;
    frame.size.height = 80.0f;
    [UIView animateWithDuration:0.15f animations:^{
        [viewOverall setFrame:frame];
    }completion:^(BOOL finished){
        [tblReadingDates setScrollEnabled:NO];
    }];
}

- (void)hideOverall:(BOOL)next
{
    CGRect frame = viewOverall.frame;
    frame.size.height = 0.0f;
    [UIView animateWithDuration:0.15f animations:^{
        [viewOverall setFrame:frame];
    }completion:^(BOOL finished){
        [tblReadingDates setScrollEnabled:YES];
        if (next) {
            [self setOverallData];
            [self showOverall];
        }
    }];
}

//-----
#pragma mark - functions

-(void) scan {
    [centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];
}

-(void) stopUsingPeripheral
{
    discoveredPeripheral.delegate = nil;
    
    if (discoveredPeripheral.isConnected)
    {
        
        for (int i=0; i < discoveredPeripheral.services.count; i++)
        {
            CBService *service = discoveredPeripheral.services[i];
            
            for (int j=0; j < service.characteristics.count; j++)
            {
                CBCharacteristic *characteristic = service.characteristics[j];
                
                if ([characteristic.UUID isEqual:characteristicUUID])
                    [discoveredPeripheral setNotifyValue:NO forCharacteristic:characteristic];
            }
        }
        
        [centralManager cancelPeripheralConnection:discoveredPeripheral];
    }
    else
    {
        discoveredPeripheral = nil;
    }
    
}

-(void) showInfo:(NSString*)textInfo backGroundColor:(UIColor*)color {
    internalInfoLabel.text = textInfo;
    internalInfoLabel.backgroundColor = color;
}


-(void) showInfo:(NSString*)textInfo {
    [self showInfo:textInfo backGroundColor:infoColorOrdinal];
}


-(void) showError:(NSError*)error {
    if (error == nil)
        return;
    
    NSMutableString *errStr = [NSMutableString stringWithString: NSLocalizedString(@"Error", nil)];
    
    if (error.code)
        [errStr appendFormat:@": %ld", error.code];
    

    [errStr appendFormat:@"\n%@", error.localizedDescription];
    
    if (error.localizedFailureReason)
        [errStr appendFormat:@"\n%@", error.localizedFailureReason];
    
    if (error.localizedRecoverySuggestion)
        [errStr appendFormat:@"\n%@", error.localizedRecoverySuggestion];
    
    [self showInfo:errStr backGroundColor:infoColorError];
    
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - CBCentralManagerDelegate methods

-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    
    NSString *stateDescription;
    
    switch (central.state) {
            
        case CBCentralManagerStateUnknown:
            stateDescription = [NSString stringWithFormat:@"CBCentralManagerStateUnknown %ld ", central.state];
            break;
            
        case CBCentralManagerStateResetting:
            stateDescription = [NSString stringWithFormat:@"CBCentralManagerStateResetting %ld ", central.state];
            break;
            
        case CBCentralManagerStateUnsupported:
            stateDescription = [NSString stringWithFormat:@"CBCentralManagerStateUnsupported %ld ", central.state];
            break;
            
        case CBCentralManagerStateUnauthorized:
            stateDescription = [NSString stringWithFormat:@"CBCentralManagerStateUnauthorized %ld ", central.state];
            break;
            
        case CBCentralManagerStatePoweredOff:
            stateDescription = [NSString stringWithFormat:@"CBCentralManagerStatePoweredOff %ld ", central.state];
            break;
            
        case CBCentralManagerStatePoweredOn:
            stateDescription = [NSString stringWithFormat:@"CBCentralManagerStatePoweredOn %ld ", central.state];
            [self scan];
            break;
            
            
            
        default:
            stateDescription = [NSString stringWithFormat:@"CBCentralManager Undefined %ld ", central.state];
            
            break;
    }
    
    internalInfoLabel.text = stateDescription;
}




-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    /*//
    [centralManager stopScan];
    
    NSArray* uuidsArray = advertisementData[CBAdvertisementDataServiceUUIDsKey];
    
    //we don't use fast enumaration because we wanna be sure that the order of the elements was saved
    CBUUID* uuid1 = [uuidsArray firstObject];
    
    NSData* firstPackage = [uuid1 data];
    CBUUID* uuid2 = uuidsArray[1];
    CBUUID* uuid3 = uuidsArray[2];
    
    NSMutableData* manufactureData = [NSMutableData dataWithData:firstPackage];
    [manufactureData appendData:[uuid2 data]];
    [manufactureData appendData:[uuid3 data]];
    
    //    NSData *serialData = [manufactureData subdataWithRange:NSMakeRange(19, 6)];
    //
    //    ///since we recieved 3 2-bytes packages of serialNumber in little endian format we'll have to transform it so the string has appropriate look
    //    NSMutableString* fancySerialNumberString = [NSMutableString string];
    //
    //    for(int i=0;i<3;++i)
    //    {
    //        UInt16 temp;
    //        [serialData getBytes:&temp range:NSMakeRange(i*2, 2)];
    //        [fancySerialNumberString appendString:[NSString stringWithFormat:@"%X",temp]];
    //    }
    
    NSMutableString* outputtedString = [[NSMutableString alloc] initWithString:[manufactureData description]];
    [outputtedString appendFormat:@"\n\nFlag bytes:%@\nData length: %@\nData type: %@\nUUID: %@\nRH: %@\nTemp: %@\nMC: %@\nMode: %@\nMaterial: %@\nS.G: %@\nSerial: %@ (%@)\nBattery level: %@ (%i)",
     [manufactureData subdataWithRange:NSMakeRange(0, 3)],//flag
     [manufactureData subdataWithRange:NSMakeRange(3, 1)],//length
     [manufactureData subdataWithRange:NSMakeRange(4, 1)],//data type
     [manufactureData subdataWithRange:NSMakeRange(5, 4)],//uuid
     [manufactureData subdataWithRange:NSMakeRange(9, 2)],//rh
     [manufactureData subdataWithRange:NSMakeRange(11, 2)],//temp
     [manufactureData subdataWithRange:NSMakeRange(13, 2)],//mc
     [manufactureData subdataWithRange:NSMakeRange(15, 1)],//mode
     [manufactureData subdataWithRange:NSMakeRange(16, 1)],//material
     [manufactureData subdataWithRange:NSMakeRange(17, 1)],//sg
     //         [manufactureData subdataWithRange:NSMakeRange(19, 6)],
     //         fancySerialNumberString,
     @"0000", @"0000",//serial
     //---
     [manufactureData subdataWithRange:NSMakeRange(18, 1)],//battery
     *(UInt8*)[[manufactureData subdataWithRange:NSMakeRange(18, 1)] bytes]];//battery
    
    [txtReceiveData setText:outputtedString];
    
    FSReading *addReading = [[FSReading alloc] init];
    
    addReading.readFeedID = [[_curFeed feedID] intValue];
    
    int value = CFSwapInt16BigToHost(*(int*)([[manufactureData subdataWithRange:NSMakeRange(9, 2)] bytes]));
    value = value * 100 / 65536;
    addReading.readRH = value;

    value = CFSwapInt16BigToHost(*(int*)([[manufactureData subdataWithRange:NSMakeRange(11, 2)] bytes]));
    value = value * 100 / 65536;
    addReading.readTemp = value;
    
    value = CFSwapInt16BigToHost(*(int*)([[manufactureData subdataWithRange:NSMakeRange(13, 2)] bytes]));
    addReading.readMC = value;
    
    addReading.readDate = [CommonMethods date2str:[NSDate date] withFormat:DATE_FORMAT];
    
    value = *(UInt8*)[[manufactureData subdataWithRange:NSMakeRange(15, 1)] bytes];
    [_curFeed setFeedMode:value];
    
    value = *(UInt8*)[[manufactureData subdataWithRange:NSMakeRange(16, 1)] bytes];
    [_curFeed setFeedmaterial:value];
    
    value = *(UInt8*)[[manufactureData subdataWithRange:NSMakeRange(15, 1)] bytes];
    [_curFeed setFeedsg:value];
    
    [[DataManager sharedInstance] updateFeedToDatabase:_curFeed];
    [[DataManager sharedInstance] addReadingToDatabase:addReading];
    
    [self didDelete:nil];
    
    
//    [CommonMethods showAlertUsingTitle:@"DataInfo" andMessage:outputtedString];
     */
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [centralManager stopScan];
    
    //    NSString *infoStr = [NSString stringWithFormat:@"Connected peripheral:%@  services:%d", peripheral.name, peripheralxvcbxcvbxcvbxcvbcxcvbxcvbxvcbvxxcvbxvb.services.count];
    //    _internalInfoLabel.text = infoStr;
    
    NSString *infoStr = [NSString stringWithFormat:@"Connected peripheral:%@ ", peripheral.name];
    [self showInfo:infoStr];
    
    
    peripheral.delegate = self;
    
    // Search only for services that match our UUID
    [peripheral discoverServices: @[serviceUUID]];
}


-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self showError:error];
    [self stopUsingPeripheral];
    [self scan];
    
}


-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (error)
        [self showError:error];
    
    //    NSString *infoStr = [NSString stringWithFormat:@"disconnected peripheral:%@  services:%d", peripheral.name, peripheral.services.count];
    //    _internalInfoLabel.text = infoStr;
    
    NSString *infoStr = [NSString stringWithFormat:@"Disconnected peripheral:%@" , peripheral.name];
    [self showInfo:infoStr];
    
    discoveredPeripheral = nil;
    
    [self scan];
}





///////////////////////////////////////////////////////////////////////////////////////
#pragma mark - CBPeripheralDelegate methods

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    
    if (error)
    {
        // ShowErrorAlert(error);
        [self showError:error];
        [self stopUsingPeripheral];
        [self scan];
        
        return;
    }
    
    NSString *infoStr = [NSString stringWithFormat:@"Discovered services:%@  services:%ld", peripheral.name, peripheral.services.count];
    //    _internalInfoLabel.text = infoStr;
    [self showInfo:infoStr];
    
    
    for(CBService *cbService in peripheral.services)
        [peripheral discoverCharacteristics:@[characteristicUUID] forService:cbService];
    
}


-(void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral {
    
    // will initiate scan
    [self stopUsingPeripheral];
    [self scan];
}



-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    
    if (error)
    {
        // ShowErrorAlert(error);
        [self showError:error];
        [centralManager cancelPeripheralConnection:discoveredPeripheral];
    }
    
    else
    {
        NSString *infoStr = @"Discovered characteristics for serivice";
        //        _internalInfoLabel.text = infoStr;
        [self showInfo:infoStr];
        
        for (CBCharacteristic *characteristic in service.characteristics)
        {
            if ([characteristic.UUID isEqual:characteristicUUID])
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    
}


-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        // ShowErrorAlert(error);
        [self showError:error];
    }
    
    else if ([characteristic.UUID isEqual:characteristicUUID])
    {
        
        //        NSString *infoStr = [NSString stringWithFormat:@"Updated notification state for characteristic:%@",
        //                             characteristic.isNotifying? @"YES" : @"NO"];
        //        _internalInfoLabel.text = infoStr;
        
        
        if (characteristic.isNotifying) {
            NSString *infoStr = [NSString stringWithFormat: @"Ready for receiving info from peripheral:%@", discoveredPeripheral.name];
            [self showInfo:infoStr backGroundColor:infoColorSubscribed];
        }
        else {
            NSString *infoStr = [NSString stringWithFormat: @"Unsubscribed from peripheral:%@", discoveredPeripheral.name];
            [self showInfo:infoStr];
            [centralManager cancelPeripheralConnection:peripheral];
        }
        
        
        // [peripheral readValueForCharacteristic:characteristic];
    }
    
}


-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        // ShowErrorAlert(error);
        [self showError:error];
    }
    
    else
    {
        NSString *valueStr = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        
        if ([valueStr isEqualToString:END_OF_DATA]) {
            receivedData.length = 0;
            return;
        }
        
        [receivedData appendData:characteristic.value];
        
        NSString *receivedStr = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
        
        txtReceiveData.text = receivedStr;
    }
    
}

#pragma mark - Actions
- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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

//
//  FSMeasureCell.m
//  FloorSmart
//
//  Created by Lydia on 1/6/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "FSMeasureCell.h"
#import "Global.h"

@implementation FSMeasureCell
@synthesize btnDel, lblEMC, lblMC, lblRH, lblTemperature, lblTime;
@synthesize delegate;
@synthesize curReading = _curReading;

+ (FSMeasureCell *)sharedCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"FSMeasureCell" owner:nil options:nil];
    FSMeasureCell *cell = [array objectAtIndex:0];
    
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

- (void)setCurReading:(FSReading *)curReading
{
    _curReading = curReading;
    NSDate *curReadDate = [CommonMethods str2date:[curReading readDate] withFormat:DATE_FORMAT];
    [lblTime setText:[NSString stringWithFormat:@"%@hrs", [CommonMethods date2str:curReadDate withFormat:@"HH:mm"]]];
    [lblMC setText:[NSString stringWithFormat:@"%.1f", (float)[curReading readMC] / 10]];
    [lblEMC setText:@"7.4"];
    [lblRH setText:[NSString stringWithFormat:@"%d", (int)[curReading readRH]]];
    [lblTemperature setText:[NSString stringWithFormat:@"%d", (int)[curReading readTemp]]];
}

#pragma mark - Action
- (IBAction)onDel:(id)sender
{
    if([self.delegate respondsToSelector:@selector(didDelete:)])
    {
        [self.delegate performSelector:@selector(didDelete:) withObject:self];
    }
}

@end

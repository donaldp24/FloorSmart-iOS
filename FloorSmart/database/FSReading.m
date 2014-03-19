//
//  FSReading.m
//  FloorSmart
//
//  Created by Lydia on 1/24/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "FSReading.h"

@implementation FSReading

- (id)init
{
    self = [super init];
    if (self) {
        [self initMembers];
    }
    return self;
}

- (void)initMembers
{
    self.readID = 0;
    self.readLocProductID = 0;
    self.readTimestamp = [[NSDate alloc] init];
    self.readUuid = @"";
    self.readRH = 0;
    self.readConvRH = 0.0;
    self.readTemp = 0;
    self.readConvTemp = 0.0;
    self.readBattery = 0;
    self.readDepth = 0;
    self.readGravity = 0;
    self.readMaterial = 0;
    self.readMC = 0;
}

@end

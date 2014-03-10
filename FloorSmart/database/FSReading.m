//
//  FSReading.m
//  FloorSmart
//
//  Created by Lydia on 1/24/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "FSReading.h"

@implementation FSReading
@synthesize readID = _readID;
@synthesize readRH = _readRH;
@synthesize readTemp = _readTemp;
@synthesize readMC = _readMC;
@synthesize readDate = _readDate;

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

@end

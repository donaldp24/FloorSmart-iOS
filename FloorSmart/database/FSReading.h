//
//  FSReading.h
//  FloorSmart
//
//  Created by Lydia on 1/24/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSReading : NSObject

@property (nonatomic) long readID;
@property (nonatomic) long readLocProductID;
@property (nonatomic, retain) NSDate *readTimestamp;
@property (nonatomic, retain) NSString *readUuid;
@property (nonatomic) long readRH; //
@property (nonatomic) double readConvRH; //0-100
@property (nonatomic) long readTemp;
@property (nonatomic) double readConvTemp; //0-130
@property (nonatomic) long readBattery;
@property (nonatomic) long readDepth;
@property (nonatomic) long readGravity;
@property (nonatomic) long readMaterial;
@property (nonatomic) long readMC; //0-1000

@end


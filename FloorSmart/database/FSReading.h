//
//  FSReading.h
//  FloorSmart
//
//  Created by Lydia on 1/24/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSReading : NSObject

@property (nonatomic, retain) NSString *readID;
@property (nonatomic) NSInteger readFeedID;
@property (nonatomic) NSInteger readRH;//0-100
@property (nonatomic) NSInteger readTemp;//0-130
@property (nonatomic) NSInteger readMC;//0-1000
@property (nonatomic, retain) NSString *readDate;

@end

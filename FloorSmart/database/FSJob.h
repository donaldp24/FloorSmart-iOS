//
//  FSJob.h
//  FloorSmart
//
//  Created by Lydia on 12/29/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSJob : NSObject

@property (nonatomic, retain) NSString *jobID;
@property (nonatomic, retain) NSString *jobName;
@property (nonatomic) NSInteger jobArchived;

- (void)clear;

@end

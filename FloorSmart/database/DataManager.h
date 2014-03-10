//
//  DataManager.h
//  iHelp
//
//  Created by Lydia on 1/14/14.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSJob.h"
#import "FSLocation.h"
#import "FSProduct.h"
#import "FSLocation.h"
#import "FSFeed.h"
#import "FSReading.h"

@class FMDatabase;

@interface DataManager : NSObject {

    FMDatabase *_database;
}

+ (id)sharedInstance;

- (NSMutableArray *)getAllJobs;
- (NSMutableArray *)getJobs:(NSInteger)archiveFlag searchField:(NSString *)searchField;
- (FSJob *)getJobFromID:(NSInteger)jobID;
- (void)addJobToDatabase:(FSJob *)job;
- (void)updateJobToDatabase:(FSJob *)job;
- (void)deleteJobFromDatabase:(FSJob *)job;

- (NSMutableArray *)getAllProducts;
- (NSMutableArray *)getProducts:(NSString *)searchField delFlag:(NSInteger)delFlag;
- (NSMutableArray *)getProducts:(NSMutableArray *)arrFeeds;
- (NSMutableArray *)getFeedProducts:(NSString *)jobID loc:(NSInteger)locID;
- (FSProduct *)getProductFromID:(NSInteger)procID;
- (void)addProductToDatabase:(FSProduct *)product;
- (void)updateProductToDatabase:(FSProduct *)product;
- (void)deleteProductFromDatabase:(FSProduct *)product;

- (NSMutableArray *)getLocations:(NSMutableArray *)arrFeeds;
- (FSLocation *)getLocationFromID:(NSInteger)locID;
- (int)getMaxLocID;
- (NSMutableArray *)getFeedLocations:(NSString *)jobID;
- (void)addLocationToDatabase:(FSLocation *)loc;
- (void)updateLocToDatabase:(FSLocation *)loc;
- (void)deleteLocFromDatabase:(FSLocation *)loc;

- (NSMutableArray *)getFeeds:(NSString *)jobID locID:(NSInteger)locID procID:(NSInteger)procID;
- (void)addFeedToDatabase:(FSFeed *)feed;
- (void)updateFeedToDatabase:(FSFeed *)feed;
- (void)deleteFeedFromDatabase:(FSFeed *)feed;

- (NSMutableArray *)getAllReadingDates:(NSString *)feedID;
- (NSMutableArray *)getReadings:(NSString *)feedID withDate:(NSString *)feedDate;
- (NSInteger)getReadingsCount:(NSString *)feedID;
- (void)addReadingToDatabase:(FSReading *)reading;
- (void)updateReadingToDatabase:(FSReading *)reading;
- (void)deleteReadingFromDatabase:(FSReading *)reading;

@end

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
#define FMD_DEFAULT_LOCATIONNAME    @"Default"
#define FMD_DEFAULT_PRODUCTNAME     @"Default"

@class FMDatabase;

@interface DataManager : NSObject {

    FMDatabase *_database;
    NSString *databasePath;
}

+ (id)sharedInstance;

// job
- (NSMutableArray *)getAllJobs;
- (NSMutableArray *)getJobs:(long)archiveFlag searchField:(NSString *)searchField;
- (FSJob *)getJobFromID:(long)jobID;
- (int)addJobToDatabase:(FSJob *)job;
- (void)updateJobToDatabase:(FSJob *)job;
- (void)deleteJobFromDatabase:(FSJob *)job;

// location
- (NSMutableArray *)getLocations:(long)jobID;
- (FSLocation *)getLocationFromID:(long)locID;
- (int)addLocationToDatabase:(FSLocation *)loc;
- (void)updateLocToDatabase:(FSLocation *)loc;
- (void)deleteLocFromDatabase:(FSLocation *)loc;
- (FSLocation *)getDefaultLocationOfJob:(long)jobID;

// product
- (NSMutableArray *)getAllProducts;
- (NSMutableArray *)getProducts:(NSString *)searchField;
//- (NSMutableArray *)getProducts:(NSMutableArray *)arrFeeds;
//- (NSMutableArray *)getFeedProducts:(NSString *)jobID loc:(NSInteger)locID;
- (FSProduct *)getProductFromID:(long)procID;
- (int)addProductToDatabase:(FSProduct *)product;
- (void)updateProductToDatabase:(FSProduct *)product;
- (void)deleteProductFromDatabase:(FSProduct *)product;
- (FSProduct *)getProductWithLocProduct:(FSLocProduct *)locProduct;

// products for specific location
- (NSMutableArray *)getLocProducts:(FSLocation *)loc searchField:(NSString *)searchField;
- (FSLocProduct *)getLocProductWithID:(long)locProductID;
- (FSLocProduct *)getDefaultLocProductOfLocation:(FSLocation *)loc;
- (FSLocProduct *)getLocProductWithProduct:(FSProduct *)product locID:(long)locID;
- (int)addLocProductToDatabaseWithProduct:(FSProduct *)product locID:(long)locID coverage:(double)coverage;
- (int)addLocProductToDatabase:(FSLocProduct *)locProduct;
- (BOOL)updateLocProductToDatabase:(FSLocProduct *)locProduct;
- (BOOL)deleteLocProductFromDatabase:(FSLocProduct *)locProduct;


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

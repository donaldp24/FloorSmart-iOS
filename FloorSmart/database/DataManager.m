//
//  DataManager.m
//  iHelp
//
//  Created by Lydia on 1/14/14.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataManager.h"
#import "FMDatabase.h"
#import "Global.h"

static DataManager *sharedManager;

@implementation DataManager

+ (id)sharedInstance
{
    if (!sharedManager) {

        sharedManager = [[DataManager alloc] init];
    }

    return sharedManager;
}

- (id)init
{
    self = [super init];
    if (self) {

        if (![[NSFileManager defaultManager] fileExistsAtPath:DATABASE_PATH]) {

            [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"FloorSmart" ofType:@"db"] toPath:DATABASE_PATH error:nil];
        }
        _database = [[FMDatabase alloc] initWithPath:DATABASE_PATH];
        [_database open];
    }

    return self;
}

#pragma mark - job
- (NSMutableArray *)getJobs:(NSInteger)archiveFlag searchField:(NSString *)searchField
{
    NSMutableArray *arrJobList = [[NSMutableArray alloc] init];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM tbl_job where job_archived = '%ld' AND job_name like %@%@%@", archiveFlag, @"'%", searchField, @"%'"];
    FMResultSet *results = [_database executeQuery:sql];
    while ([results next]) {
        FSJob *job  = [[[FSJob alloc] init] autorelease];
        job.jobID       = [results stringForColumn:@"job_id"];
        job.jobName     = [results stringForColumn:@"job_name"];
        job.jobArchived = [results intForColumn:@"job_archived"];
        
        [arrJobList addObject:job];
    }
    return arrJobList;
}

- (NSMutableArray *)getAllJobs
{
    NSMutableArray *arrJobList = [[NSMutableArray alloc] init];
    FMResultSet *results = [_database executeQuery:@"SELECT * FROM tbl_job"];
    while ([results next]) {
        FSJob *job  = [[[FSJob alloc] init] autorelease];
        job.jobID       = [results stringForColumn:@"job_id"];
        job.jobName     = [results stringForColumn:@"job_name"];
        job.jobArchived = [results intForColumn:@"job_archived"];
        
        [arrJobList addObject:job];
    }
    return arrJobList;
}

- (FSJob *)getJobFromID:(NSInteger)jobID
{
    FSJob *job = [[FSJob alloc] init];
    FMResultSet *results = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM tbl_job WHERE job_id = '%ld'", jobID]];
    while ([results next]) {
        job.jobID = [results stringForColumn:@"job_id"];
        job.jobName = [results stringForColumn:@"job_name"];
        job.jobArchived = [results intForColumn:@"job_archived"];
        break;
    }
    return job;
}

- (void)addJobToDatabase:(FSJob *)job
{
    NSString *sql;
    sql = [NSString stringWithFormat:@"INSERT INTO tbl_job (job_archived, job_name) VALUES ('%ld', '%@')",job.jobArchived, job.jobName];
    [_database executeUpdate:sql];
}

- (void)updateJobToDatabase:(FSJob *)job
{
    NSString *sql;
    sql = [NSString stringWithFormat:@"update tbl_job set job_archived = '%ld' , job_name = '%@' WHERE job_id = '%@'", job.jobArchived, job.jobName, job.jobID];
    [_database executeUpdate:sql];
}

- (void)deleteJobFromDatabase:(FSJob *)job
{
    NSString *sql;
    sql = [NSString stringWithFormat:@"DELETE FROM tbl_job WHERE job_id = '%@'", job.jobID];
    [_database executeUpdate:sql];
}

#pragma mark - product
- (NSMutableArray *)getAllProducts
{
    NSMutableArray *arrProductList = [[NSMutableArray alloc] init];
    FMResultSet *results = [_database executeQuery:@"SELECT * FROM tbl_product"];
    while ([results next]) {
        
        FSProduct *product  = [[[FSProduct alloc] init] autorelease];
        product.productID = [results stringForColumn:@"product_id"];
        product.productName = [results stringForColumn:@"product_name"];
        product.productFinished = [results intForColumn:@"product_finished"];
        product.productDel = [results intForColumn:@"product_del"];
        
        [arrProductList addObject:product];
    }
    return arrProductList;
}

- (NSMutableArray *)getProducts:(NSString *)searchField delFlag:(NSInteger)delFlag
{
    NSMutableArray *arrProductList = [[NSMutableArray alloc] init];
    FMResultSet *results = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM tbl_product WHERE product_del = '%ld' AND product_name like %@%@%@", delFlag,  @"'%", searchField, @"%'"]];
    while ([results next]) {
        
        FSProduct *product  = [[[FSProduct alloc] init] autorelease];
        product.productID = [results stringForColumn:@"product_id"];
        product.productName = [results stringForColumn:@"product_name"];
        product.productFinished = [results intForColumn:@"product_finished"];
        product.productDel = [results intForColumn:@"product_del"];
        
        [arrProductList addObject:product];
    }
    return arrProductList;
}

- (NSMutableArray *)getProducts:(NSMutableArray *)arrFeeds
{
    NSMutableArray *arrProductList = [[NSMutableArray alloc] init];
    for (int i=0; i<[arrFeeds count]; i++) {
        FSFeed *feed = (FSFeed *)[arrFeeds objectAtIndex:i];
        FMResultSet *results = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM tbl_product WHERE product_id = '%ld'", [feed feedProcID]]];
        while ([results next]) {
            
            FSProduct *product  = [[[FSProduct alloc] init] autorelease];
            product.productID = [results stringForColumn:@"product_id"];
            product.productName = [results stringForColumn:@"product_name"];
            product.productFinished = [results intForColumn:@"product_finished"];
            product.productDel = [results intForColumn:@"product_del"];
            
            [arrProductList addObject:product];
        }
    }
    return arrProductList;
}

- (NSMutableArray *)getFeedProducts:(NSString *)jobID loc:(NSInteger)locID
{
    NSMutableArray *arrProcIDList = [[NSMutableArray alloc] init];
    FMResultSet *results = [_database executeQuery:[NSString stringWithFormat:@"SELECT DISTINCT feed_procid FROM tbl_feed WHERE feed_jobid = '%@' AND feed_locid = '%ld'", jobID, locID]];
    while ([results next]) {
        NSString *str = [results stringForColumn:@"feed_procid"];
        
        [arrProcIDList addObject:str];
    }
    
    NSMutableArray *arrProductList = [[NSMutableArray alloc] init];
    for (int i=0; i<[arrProcIDList count]; i++) {
        FMResultSet *results = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM tbl_product WHERE product_id = '%@'", [arrProcIDList objectAtIndex:i]]];
        while ([results next]) {
            
            FSProduct *product  = [[[FSProduct alloc] init] autorelease];
            product.productID = [results stringForColumn:@"product_id"];
            product.productName = [results stringForColumn:@"product_name"];
            product.productFinished = [results intForColumn:@"product_finished"];
            product.productDel = [results intForColumn:@"product_del"];
            
            [arrProductList addObject:product];
        }
    }
    return arrProductList;
}

- (FSProduct *)getProductFromID:(NSInteger)procID
{
    FSProduct *product = [[FSProduct alloc] init];
    FMResultSet *results = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM tbl_product WHERE product_id = '%ld'", procID]];
    while ([results next]) {
        product.productID = [results stringForColumn:@"product_id"];
        product.productName = [results stringForColumn:@"product_name"];
        product.productDel = [results intForColumn:@"product_dell"];
        product.productFinished = [results intForColumn:@"product_finished"];
        break;
    }
    return product;
}

- (void)addProductToDatabase:(FSProduct *)product
{
    NSString *sql;
    sql = [NSString stringWithFormat:@"INSERT INTO tbl_product (product_name, product_finished, product_del) VALUES ('%@', '%ld', '%ld')", product.productName, product.productFinished, product.productDel];
    [_database executeUpdate:sql];
}

- (void)updateProductToDatabase:(FSProduct *)product
{
    NSString *sql;
    sql = [NSString stringWithFormat:@"update tbl_product set product_name = '%@', product_finished = '%ld', product_del = '%ld' WHERE product_id = '%@'", product.productName, product.productFinished, product.productDel, product.productID];
    [_database executeUpdate:sql];
}

- (void)deleteProductFromDatabase:(FSProduct *)product
{
    NSString *sql;
    sql = [NSString stringWithFormat:@"DELETE FROM tbl_product WHERE product_id = '%@'", product.productID];
    [_database executeUpdate:sql];
}

#pragma mark - location
- (NSMutableArray *)getMainLocations
{
    NSMutableArray *arrLocationList = [[NSMutableArray alloc] init];
    FMResultSet *results = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM tbl_location"]];
    
    while ([results next]) {
        
        FSLocation *location  = [[[FSLocation alloc] init] autorelease];
        location.locID = [results stringForColumn:@"location_id"];
        location.locName = [results stringForColumn:@"location_name"];
        
        [arrLocationList addObject:location];
    }

    return arrLocationList;
}


- (NSMutableArray *)getLocations:(NSMutableArray *)arrFeeds
{
    NSMutableArray *arrLocationList = [[NSMutableArray alloc] init];
    for (int i=0; i<[arrFeeds count]; i++) {
        FSFeed *feed = (FSFeed *)[arrFeeds objectAtIndex:i];
        FMResultSet *results = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM tbl_location WHERE location_id = '%ld'", [feed feedLocID]]];
        while ([results next]) {

            FSLocation *location  = [[[FSLocation alloc] init] autorelease];
            location.locID = [results stringForColumn:@"location_id"];
            location.locName = [results stringForColumn:@"location_name"];

            [arrLocationList addObject:location];
        }
    }
    return arrLocationList;
}

- (NSMutableArray *)getFeedLocations:(NSString *)jobID
{
    NSMutableArray *arrLocIDList = [[NSMutableArray alloc] init];
    FMResultSet *results = [_database executeQuery:[NSString stringWithFormat:@"SELECT DISTINCT feed_locid FROM tbl_feed WHERE feed_jobid = '%@'", jobID]];
    while ([results next]) {
        NSString *str = [results stringForColumn:@"feed_locid"];
        
        [arrLocIDList addObject:str];
    }
    
    NSMutableArray *arrLocationList = [[NSMutableArray alloc] init];
    for (int i=0; i<[arrLocIDList count]; i++) {
        FMResultSet *results = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM tbl_location WHERE location_id = '%@'", [arrLocIDList objectAtIndex:i]]];
        while ([results next]) {
            
            FSLocation *location  = [[[FSLocation alloc] init] autorelease];
            location.locID = [results stringForColumn:@"location_id"];
            location.locName = [results stringForColumn:@"location_name"];
            
            [arrLocationList addObject:location];
        }
    }
    return arrLocationList;
}

- (int)getMaxLocID
{
    FMResultSet *results = [_database executeQuery:[NSString stringWithFormat:@"SELECT MAX(location_id) FROM tbl_location"]];
    while ([results next]) {
        
        return [results intForColumn:@"MAX(location_id)"];
    }
    return -1;
}

- (FSLocation *)getLocationFromID:(NSInteger)locID
{
    FSLocation *loc = [[FSLocation alloc] init];
    FMResultSet *results = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM tbl_location WHERE location_id = '%ld'", locID]];
    while ([results next]) {
        
        loc.locID = [results stringForColumn:@"location_id"];
        loc.locName = [results stringForColumn:@"location_name"];
        break;
    }
    return loc;
}

- (void)addLocationToDatabase:(FSLocation *)loc
{
    NSString *sql;
    sql = [NSString stringWithFormat:@"INSERT INTO tbl_location (location_name) VALUES ('%@')", loc.locName];
    [_database executeUpdate:sql];
}

- (void)updateLocToDatabase:(FSLocation *)loc
{
    NSString *sql;
    sql = [NSString stringWithFormat:@"update tbl_location set location_name = '%@' WHERE location_id = '%@'", loc.locName, loc.locID];
    [_database executeUpdate:sql];
}

- (void)deleteLocFromDatabase:(FSLocation *)loc
{
    NSString *sql;
    sql = [NSString stringWithFormat:@"DELETE FROM tbl_location WHERE location_id = '%@'", loc.locID];
    [_database executeUpdate:sql];
}

#pragma mark - Feed
- (NSMutableArray *)getFeeds:(NSString *)jobID locID:(NSInteger)locID procID:(NSInteger)procID
{
    NSMutableArray *arrFeedList = [[NSMutableArray alloc] init];
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT * FROM tbl_feed WHERE feed_jobid = %@", jobID];
    [sql appendString:(locID > -1) ? [NSString stringWithFormat:@" AND feed_locid = %ld", locID] : @""];
    [sql appendString:(procID > -1) ? [NSString stringWithFormat:@" AND feed_procid = %ld", procID] : @""];
    FMResultSet *results = [_database executeQuery:sql];
    while ([results next]) {
        
        FSFeed *feed = [[[FSFeed alloc] init] autorelease];
        feed.feedID = [results stringForColumn:@"feed_id"];
        feed.feedJobID = [results intForColumn:@"feed_jobid"];
        feed.feedLocID = [results intForColumn:@"feed_locid"];
        feed.feedProcID = [results intForColumn:@"feed_procid"];
        feed.feedCoverage = [results stringForColumn:@"feed_coverage"];
        feed.feedMode = [results intForColumn:@"feed_mode"];
        feed.feedmaterial = [results intForColumn:@"feed_material"];
        feed.feedsg = [results intForColumn:@"feed_sg"];
        
        [arrFeedList addObject:feed];
    }
    return arrFeedList;
}

- (void)addFeedToDatabase:(FSFeed *)feed
{
    NSString *sql;
    sql = [NSString stringWithFormat:@"INSERT INTO tbl_feed (feed_jobid, feed_locid, feed_procid, feed_coverage, feed_mode, feed_material, feed_sg) VALUES ('%ld', '%ld', '%ld', '%@', '%ld', '%ld', '%ld')",feed.feedJobID, feed.feedLocID, feed.feedProcID, feed.feedCoverage, feed.feedMode, feed.feedmaterial, feed.feedsg];
    [_database executeUpdate:sql];
}

- (void)updateFeedToDatabase:(FSFeed *)feed
{
    NSString *sql;
    sql = [NSString stringWithFormat:@"update tbl_feed set feed_jobid = '%ld', feed_locid = '%ld', feed_procid = '%ld', feed_coverage = '%@', feed_mode = '%ld', feed_material = '%ld', feed_sg = '%ld' WHERE feed_id = '%@'", feed.feedJobID, feed.feedLocID, feed.feedProcID, feed.feedCoverage, feed.feedMode, feed.feedmaterial, feed.feedsg, feed.feedID];
    [_database executeUpdate:sql];
}

- (void)deleteFeedFromDatabase:(FSFeed *)feed
{
    NSString *sql;
    sql = [NSString stringWithFormat:@"DELETE FROM tbl_feed WHERE feed_id = '%@'", feed.feedID];
    [_database executeUpdate:sql];
}

#pragma mark - Readings
- (NSMutableArray *)getAllReadingDates:(NSString *)feedID
{
    NSMutableArray *arrDates = [[NSMutableArray alloc] init];
    NSString *sql = [NSString stringWithFormat:@"SELECT DISTINCT(read_date) FROM tbl_reading WHERE read_feedid = '%@' ORDER BY read_date DESC", feedID];
    FMResultSet *results = [_database executeQuery:sql];
    while ([results next]) {
        [arrDates addObject:[results stringForColumn:@"read_date"]];
    }
    return arrDates;
}

- (NSMutableArray *)getReadings:(NSString *)feedID withDate:(NSString *)feedDate
{
    NSMutableArray *arrReadingList = [[NSMutableArray alloc] init];
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT * FROM tbl_reading WHERE read_feedid = '%@' AND read_date = '%@'", feedID, feedDate];
    FMResultSet *results = [_database executeQuery:sql];

    while ([results next]) {
        FSReading *reading = [[[FSReading alloc] init] autorelease];
        reading.readID = [results stringForColumn:@"read_id"];
        reading.readFeedID = [results intForColumn:@"read_feedid"];
        reading.readRH = [results intForColumn:@"read_rh"];
        reading.readTemp = [results intForColumn:@"read_temp"];
        reading.readMC = [results intForColumn:@"read_mc"];
        reading.readDate = [results stringForColumn:@"read_date"];
        
        [arrReadingList addObject:reading];
    }
    return arrReadingList;
}

- (NSInteger)getReadingsCount:(NSString *)feedID
{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT count(*) FROM tbl_reading WHERE read_feedid = %@", feedID];
    FMResultSet *results = [_database executeQuery:sql];
    
    while ([results next]) {
        return [results intForColumn:@"count(*)"];
    }
    return 0;
}

- (void)addReadingToDatabase:(FSReading *)reading
{
    NSString *sql;
    sql = [NSString stringWithFormat:@"INSERT INTO tbl_reading (read_feedid, read_rh, read_temp, read_mc, read_date) VALUES ('%ld', '%ld', '%ld', '%ld', '%@')",reading.readFeedID, reading.readRH, reading.readTemp, reading.readMC, reading.readDate];
    [_database executeUpdate:sql];
}

- (void)updateReadingToDatabase:(FSReading *)reading
{
    NSString *sql;
    sql = [NSString stringWithFormat:@"update tbl_reading set read_feedid = '%ld', read_rh = '%ld', read_temp = '%ld', read_mc = '%ld', read_date = '%@' WHERE read_id = '%@'", reading.readFeedID, reading.readRH, reading.readTemp, reading.readMC, reading.readDate, reading.readID];
    [_database executeUpdate:sql];
}

- (void)deleteReadingFromDatabase:(FSReading *)reading
{
    NSString *sql;
    sql = [NSString stringWithFormat:@"DELETE FROM tbl_reading WHERE read_id = '%@'", reading.readID];
    [_database executeUpdate:sql];
}

#pragma mark - life cycle
- (void)dealloc
{
    [_database close];
    [_database release];

    [super dealloc];
}

@end

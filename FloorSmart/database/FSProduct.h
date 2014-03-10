//
//  FSProduct.h
//  FloorSmart
//
//  Created by Lydia on 12/29/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSProduct : NSObject

@property (nonatomic, retain) NSString *productID;
@property (nonatomic, retain) NSString *productName;
@property (nonatomic) NSInteger productFinished;
@property (nonatomic) NSInteger productDel;

- (void)clear;

@end

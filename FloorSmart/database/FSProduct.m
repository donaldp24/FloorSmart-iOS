//
//  FSProduct.m
//  FloorSmart
//
//  Created by Lydia on 12/29/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import "FSProduct.h"

@implementation FSProduct
@synthesize productID = _productID;
@synthesize productFinished = _productFinished;
@synthesize productName = _productName;
@synthesize productDel = _productDel;

- (id)init
{
    self = [super init];
    if (self) {
        _productID = @"-1";
        _productName = @"";
        _productFinished = -1;
        _productDel = 0;
    }
    return self;
}


- (void)clear
{
    _productID = @"-1";
    _productName = @"";
    _productFinished = -1;
    _productDel = -1;
}

@end

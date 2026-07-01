//
//  NewProductBean.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 8/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSNewProductBean.h"

@implementation WSNewProductBean

@synthesize iProductId = _iProductId;
@synthesize iProductName = _iProductName;
@synthesize iProductShortName = _iProductShortName;
@synthesize iMemo = _iMemo;
@synthesize iProductType = _iProductType;
@synthesize isPlan = _isPlan;
@synthesize iStoreId = _iStoreId;
@synthesize iUpdateIdMd5 = _iUpdateIdMd5;

#pragma mark - class init & dealloc
- (id)init
{
    self = [super init];
    if (self) {
        _isPlan = YES;
    }
    return self;
}



@end

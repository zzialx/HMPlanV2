//
//  ProdManager.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSProdManager.h"


@implementation WSProdManager

static WSProdManager *sharedProdManager = nil;


+ (WSProdManager *)sharedManager
{
    if(sharedProdManager == nil)
        sharedProdManager = [[super allocWithZone:NULL] init];
    return sharedProdManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedManager];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

//- (id)retain
//{
//    return self;
//}
//
//-(NSUInteger)retainCount
//{
//    return NSUIntegerMax;
//}
//
//-(id)autorelease
//{
//    return self;
//}

@end

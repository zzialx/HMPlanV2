//
//  DictManager.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSDictManager.h"

@implementation WSDictManager

static WSDictManager* sharedDictManager = nil;


+(WSDictManager*)sharedManager
{
    if(sharedDictManager==nil)
        sharedDictManager = [[super allocWithZone:NULL]init];
    return sharedDictManager;
}

+(id)allocWithZone:(NSZone *)zone
{
    return [self sharedManager];
}

-(id)copyWithZone:(NSZone *)zone
{
    return self;
}

//-(id)retain
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

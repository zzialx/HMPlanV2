//
//  AcvtManager.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSAcvtManager.h"

@implementation WSAcvtManager

static WSAcvtManager* sharedAcvtManager = nil;


+(WSAcvtManager*)sharedManager
{
    if(sharedAcvtManager==nil)
        sharedAcvtManager = [[super allocWithZone:NULL]init];
    return sharedAcvtManager;
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

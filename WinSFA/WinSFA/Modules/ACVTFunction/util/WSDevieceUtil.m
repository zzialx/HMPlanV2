//
//  WSDevieceUtil.m
//  WinSFA
//
//  Created by winchannel on 15/4/30.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSDevieceUtil.h"

@implementation WSDevieceUtil



+(float)getOsVersionNumber{
    
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

@end

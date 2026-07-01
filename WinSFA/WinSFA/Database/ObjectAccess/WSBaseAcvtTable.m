//
//  WSBaseAcvtTable.m
//  WinSFA
//
//  Created by weida on 15/12/23.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSBaseAcvtTable.h"




@implementation WSBaseAcvtTable

static WSBaseAcvtTable *baseStoreTable = nil;

+ (WSBaseAcvtTable *)sharedTable{
    if (baseStoreTable == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            baseStoreTable = [[WSBaseAcvtTable alloc] init];
        });
    }
    return baseStoreTable;
}




@end

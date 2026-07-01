//
//  WSBaseStoreDistrule.m
//  WinSFA
//
//  Created by yang on 17/5/26.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSBaseStoreDistruleTable.h"


//数据库中各个字段
#define kKey_id              @"_id"
#define kKey_sid             @"sid"
#define kKey_drId            @"drId"
#define kKey_server_node     @"server_node"

@implementation WSBaseStoreDistruleTable

static WSBaseStoreDistruleTable *baseTable = nil;

+ (WSBaseStoreDistruleTable *)sharedTable{
    if (baseTable == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            baseTable = [[WSBaseStoreDistruleTable alloc] init];
        });
    }
    return baseTable;
}


@end

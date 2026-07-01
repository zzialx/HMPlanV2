//
//  WSBaseStoreAcvtTable.m
//  WinSFA
//
//  Created by weida on 15/12/18.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSBaseStoreAcvtTable.h"


#import "WSMappingObject.h"

//数据库中各个字段
#define kKey_id                @"_id"
#define kKey_sid               @"sid"
#define kKey_acvtID            @"acvtId"
#define kKey_uploadCount       @"uploadCount"
#define kKey_hasUploadedCount  @"hasUploadedCount"


@implementation WSBaseStoreAcvtTable


static WSBaseStoreAcvtTable *baseStoreTable = nil;

+ (WSBaseStoreAcvtTable *)sharedTable{
    if (baseStoreTable == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            baseStoreTable = [[WSBaseStoreAcvtTable alloc] init];
        });
    }
    return baseStoreTable;
}

- (NSInteger)queryUploadCountLimitWithStoreId:(NSString *)storeId acvtId:(NSString *)acvtId {
    if (storeId == nil || acvtId == nil) {
        NSLog(@"storeId or acvtId is nil");
        return NSNotFound;
    }
    NSArray *names = @[@"sid",@"acvtId"];
    NSArray *values = @[storeId,acvtId];

    NSArray *objects = [self  queryWithNames:names ArgumentsValue:values];
    return [[[objects firstObject] uploadcount] integerValue];
    
}

@end

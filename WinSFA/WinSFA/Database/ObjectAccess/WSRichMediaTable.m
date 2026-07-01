//
//  WSRichMediaTable.m
//  WinSFA
//
//  Created by huzepei on 16/8/10.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSRichMediaTable.h"
#import "WSRichItemModel.h"


@implementation WSRichMediaTable

static WSRichMediaTable *baseStoreTable = nil;

+ (WSRichMediaTable *)sharedTable{
    if (baseStoreTable == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            baseStoreTable = [[WSRichMediaTable alloc] init];
        });
    }
    return baseStoreTable;
}
// 表明写死了,后期改掉
-(NSArray *)queryTableItems
{
    NSString *sql = @"SELECT * FROM spe_richMedia AS spe;";
    NSMutableArray *temp = [self queryAndReturnInfosBySql:sql andClassName:@"WSRichItemModel"];
    return [temp copy];
}

-(NSArray *)queryTableItemsNotDownloadWithImg
{
    NSString *sql = @"SELECT * FROM spe_richMedia AS spe WHERE (spe.img_add ISNULL OR spe.img_add = '') AND spe.img_url != '';";
    NSMutableArray *temp = [self queryAndReturnInfosBySql:sql andClassName:@"WSRichItemModel"];
    return [temp copy];
}

-(NSArray *)queryTableItemsNotDownloadWithH5
{
    NSString *sql = @"SELECT * FROM spe_richMedia AS spe WHERE (spe.h5_add ISNULL OR spe.h5_add = '') AND spe.h5_url != '';";
    NSMutableArray *temp = [self queryAndReturnInfosBySql:sql andClassName:@"WSRichItemModel"];
    return [temp copy];
}

-(NSArray *)queryTableItemsNotDownloadWithH5URL
{
    NSString *sql = @"SELECT * FROM spe_richMedia WHERE spe_richMedia.h5_url != '';";
    NSMutableArray *temp = [self queryAndReturnInfosBySql:sql andClassName:@"WSRichItemModel"];
    return [temp copy];
}

-(BOOL)updateTableWithKey:(NSString *)key value:(NSString *)value ID:(NSString *)ID
{
    NSString *sql = [NSString stringWithFormat:@"UPDATE spe_richMedia SET %@ = '%@' WHERE speid = '%@';",key,value,ID];
    
    BOOL temp = [self executeUpdateWithSqls:@[sql]];
    
    return temp;
}

- (NSString *)getUpdateSQLStringWithKey:(NSString *)key value:(NSString *)value ID:(NSString *)ID
{
    return [NSString stringWithFormat:@"UPDATE spe_richMedia SET %@ = '%@' WHERE speid = '%@';",key,value,ID];
}

-(BOOL)insertWithValue:(NSArray *)values
{
    return [self insertWithArgumentsValue:values];
}

//批量更新
- (BOOL)updateTableWithValueArr:(NSArray *)valueArr ID:(NSArray *)IDArray
{
    NSMutableArray *temp = [NSMutableArray array];
    for (NSString *speid in IDArray) {
       NSString *sql = [NSString stringWithFormat:@"UPDATE spe_richMedia SET memo = '%@',h5_url = '%@',img_url = '%@', typ = '%@', name = '%@',share_url = '%@', type_ = '%@' WHERE speid = '%@';",valueArr[0],valueArr[1],valueArr[2],valueArr[3],valueArr[4],valueArr[5],valueArr[6],speid];
        [temp addObject:sql];
    }
    BOOL success = [self executeUpdateWithSqls:[temp copy]];
    return success;
}
@end

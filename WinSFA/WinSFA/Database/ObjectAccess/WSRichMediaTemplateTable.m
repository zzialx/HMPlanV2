//
//  WSRichMediaTemplateTable.m
//  WinSFA
//
//  Created by huzepei on 16/8/24.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSRichMediaTemplateTable.h"
#import "WSRichItemModel.h"
#import "WSRichMediaTemplate.h"

static WSRichMediaTemplateTable *baseStoreTable = nil;

@implementation WSRichMediaTemplateTable

+ (WSRichMediaTemplateTable *)sharedTable{
    if (baseStoreTable == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            baseStoreTable = [[WSRichMediaTemplateTable alloc] init];
        });
    }
    return baseStoreTable;
}
- (BOOL)insertTableWithStore:(WSStoreBean *)storeBean dict:(NSDictionary *)dict visitData:(NSString *)visitData
{
    BOOL succeed = '\0';
    NSString *key = dict.allKeys[0];
    succeed = [self insertWithArgumentsValue:@[@"",@"template",key,@"",storeBean.Id,@"",visitData,@""]];
    NSString *pidStr = [NSString stringWithFormat:@"SELECT spe.ID FROM spe_richMedia_template AS spe WHERE spe.name = '%@' AND spe.type = 'template';",key];
    NSMutableArray *pidArray = [self queryDatasBySql:pidStr columnArr:@[@"ID"]];
    NSString *pid = @"";
    
    if (pidArray.count > 0) {
        pid = pidArray[0];
    }

    NSArray *arr = [dict objectForKey:key];
    for (WSRichItemModel *rItem in arr) {
        
        NSData * data = [NSKeyedArchiver archivedDataWithRootObject:rItem];
        
      succeed = [self insertWithArgumentsValue:@[pid,@"demolist",rItem.name,data,storeBean.Id,storeBean.name,visitData,@""]];
    }
    return succeed;
}

-(NSArray *)queryTableForTemplate
{
    NSString * temp = @"SELECT spe.name FROM spe_richMedia_template AS spe WHERE spe.type = 'template';";
    
    NSMutableArray *pidArray = [self queryDatasBySql:temp columnArr:@[@"name"]];
    
    NSMutableArray *tempArr = [NSMutableArray array];
    for (int i = 0; i < pidArray.count; i++) {
        
        NSMutableDictionary *tempLateDict = [NSMutableDictionary dictionary];
        NSString *str = pidArray[i];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT  spe2.ID,spe2.pid,spe2.type,spe2.name,spe2.item,spe2.storeID,spe2.storeName,spe2.visitName  FROM  spe_richMedia_template AS spe1 , spe_richMedia_template AS spe2 WHERE spe1.name = '%@' AND spe1.ID = spe2.pid;",str];
        NSMutableArray *temp2 = [self queryAndReturnInfosBySql:sql andClassName:@"WSRichMediaDemoList"];
        
        for (WSRichMediaDemoList *rdl in temp2) {
            WSRichItemModel *ri = [NSKeyedUnarchiver unarchiveObjectWithData:rdl.item];
            rdl.itemModel = ri;
        }
        
        [tempLateDict setObject:temp2 forKey:str];
        [tempArr addObject:tempLateDict];
    }
    return tempArr;
}


- (NSArray *)queryTableFordemoList:(NSString *)storeID
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM spe_richMedia_template AS spe WHERE spe.type = 'demolist' AND spe.visitName = '%@' AND spe.storeID = '%@';",[WSCurrentTime currentDay],storeID];
    
    NSMutableArray *temp2 = [self queryAndReturnInfosBySql:sql andClassName:@"WSRichMediaDemoList"];
    
    for (WSRichMediaDemoList *rdl in temp2) {
        WSRichItemModel *ri = [NSKeyedUnarchiver unarchiveObjectWithData:rdl.item];
        rdl.itemModel = ri;
    }
    return temp2;
}

- (NSArray *)queryTableFordemoList:(NSString *)storeID andVisitTime:(NSString *)visitTime
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM spe_richMedia_template AS spe WHERE spe.type = 'demolist' AND spe.storeID = '%@' AND spe.visitName = '%@';",storeID,visitTime];
    
    NSMutableArray *temp2 = [self queryAndReturnInfosBySql:sql andClassName:@"WSRichMediaDemoList"];
    
    for (WSRichMediaDemoList *rdl in temp2) {
        WSRichItemModel *ri = [NSKeyedUnarchiver unarchiveObjectWithData:rdl.item];
        rdl.itemModel = ri;
    }
    return temp2;
}

- (NSArray *)queryTableForRichItem:(NSString *)storeID andVisitTime:(NSString *)visitTime{
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM spe_richMedia_template AS spe WHERE spe.type = 'demolist' AND spe.storeID = '%@' AND spe.visitName = '%@';",storeID,visitTime];
    
    NSMutableArray *temp2 = [self queryAndReturnInfosBySql:sql andClassName:@"WSRichMediaDemoList"];
    NSMutableArray * richItemArray = [[NSMutableArray alloc]initWithCapacity:temp2.count];
    for (WSRichMediaDemoList *rdl in temp2) {
        WSRichItemModel *ri = [NSKeyedUnarchiver unarchiveObjectWithData:rdl.item];
        rdl.itemModel = ri;
        [richItemArray addObject:ri];
    }
    return richItemArray;
}
-(NSArray *)queryTabledemoList
{
    NSString *sql = @"SELECT * FROM spe_richMedia_template AS spe WHERE spe.type = 'demolist';";
    
    NSMutableArray *temp2 = [self queryAndReturnInfosBySql:sql andClassName:@"WSRichMediaDemoList"];
    
    for (WSRichMediaDemoList *rdl in temp2) {
        WSRichItemModel *ri = [NSKeyedUnarchiver unarchiveObjectWithData:rdl.item];
        rdl.itemModel = ri;
    }
    return temp2;
}

-(NSArray *)queryTabledemoListNotHavePid
{
    NSString *sql = @"select * from spe_richMedia_template where type = 'demolist'";
    
    NSMutableArray *temp2 = [self queryAndReturnInfosBySql:sql andClassName:@"WSRichMediaDemoList"];
    
    //去重
    temp2 = [self DuplicateRemoval:temp2];
    
    for (WSRichMediaDemoList *rdl in temp2) {
        WSRichItemModel *ri = [NSKeyedUnarchiver unarchiveObjectWithData:rdl.item];
        rdl.itemModel = ri;
    }
    return temp2;
}

- (BOOL)insertDemoListTabWithStore:(WSStoreBean *)storeBean richMedia:(WSRichItemModel *)richItem visitData:(NSString *)visitData
{
    BOOL succeed = '\0';
    
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:richItem];
    [self deleteWithNames:@[@"name",@"storeID",@"visitName"] ArgumentsValue:@[richItem.name,storeBean.Id,visitData]];
    succeed = [self insertWithArgumentsValue:@[@"",@"demolist",richItem.name,data,storeBean.Id,storeBean.name,visitData,@""]];
    
    return succeed;
}

-(BOOL)deleteRichListWithNames:(NSArray *)names ArgumentsValue:(NSArray *)values
{
    BOOL succeed = '\0';
    
    succeed = [self deleteWithNames:names ArgumentsValue:values];
    
    return succeed;
}
- (NSArray *)queryTableForRichItem:(NSString *)storeID
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM spe_richMedia_template AS spe WHERE spe.type = 'demolist' AND spe.storeID = '%@' AND spe.pid = '';",storeID];
    
    NSMutableArray *temp2 = [self queryAndReturnInfosBySql:sql andClassName:@"WSRichMediaDemoList"];
    
    NSMutableArray *temp = [NSMutableArray array];
    for (WSRichMediaDemoList *rdl in temp2) {
        WSRichItemModel *ri = [NSKeyedUnarchiver unarchiveObjectWithData:rdl.item];
        rdl.itemModel = ri;
        [temp addObject:ri];
    }
    return temp;
}

-(NSMutableArray *)DuplicateRemoval:(NSArray *)array{ // 数组去重
    
    NSMutableDictionary  *dict = [NSMutableDictionary dictionary];
    for (WSRichMediaDemoList * object in array) {

        [dict setObject:object forKey:object.name];
    }
    NSMutableArray * planArray = [NSMutableArray arrayWithCapacity:0];
    NSArray * allkeys = [dict allKeys];
    for (NSString  *str in allkeys) {
        [planArray addObject:[dict objectForKey:str]];
    }
    
    return planArray;
}
@end

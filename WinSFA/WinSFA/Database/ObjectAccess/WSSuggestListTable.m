//
//  WSSuggestListTable.m
//  WinSFA
//
//  Created by huzepei on 16/9/9.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSuggestListTable.h"

static WSSuggestListTable *baseStoreTable = nil;

@implementation WSSuggestListTable

+ (WSSuggestListTable *)sharedTable{
    if (baseStoreTable == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            baseStoreTable = [[WSSuggestListTable alloc] init];
        });
    }
    return baseStoreTable;
}
- (BOOL)insertTableWithType:(NSString *)type  model:(WSSuggestWholesale *)suggestWho sid:(NSString *)sid withbiz_date:(NSString *)biz_date
{
    BOOL succeed = '\0';
    NSString * empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    
    succeed = [self insertWithArgumentsValue:@[suggestWho.name,type,suggestWho.item,sid,empId,biz_date]];
    
    return succeed;
}

- (BOOL)insertTableWithType:(NSString *)type  homeModel:(WSSuggestHome *)suggesthome sid:(NSString *)sid withbiz_date:(NSString *)biz_date
{
    BOOL succeed = '\0';
    NSString * empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    succeed = [self insertWithArgumentsValue:@[suggesthome.name,type,suggesthome.item,sid,empId,biz_date]];
    
    return succeed;
}
- (NSArray *)queryWithType:(NSString *)type  name:(NSString *)name sid:(NSString *)sid withbiz_date:(NSString *)biz_date className:(NSString *)className{
    
    NSString * empId = [WSAppData getObjectbyKey:APPDATA_EMPID];

     NSString *sql = [NSString stringWithFormat:@"SELECT * FROM suggest_list WHERE name = '%@' AND sid = '%@' AND type = '%@' AND biz_date = '%@' AND empid = '%@';",name,sid,type,biz_date,empId];
    NSMutableArray *temp = [self queryAndReturnInfosBySql:sql andClassName:className];

    if ([type isEqualToString:@"02"]) { //批发
        
        for (WSSuggestWholesale *sw in temp) {
            
            WSSuggestWhoModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:sw.item];
            sw.sugModel = model;
        }
        
    }else{  //用家
        
        for (WSSuggestHome *sw in temp) {
            
            WSSuggestHomeModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:sw.item];
            sw.sugHomeModel = model;
        }
    }

    return [temp copy];

}
-(BOOL)deleteSuggestWithNames:(NSArray *)names ArgumentsValue:(NSArray *)values
{
    BOOL succeed = '\0';
    
    succeed = [self deleteWithNames:names ArgumentsValue:values];
    
    return succeed;
}


- (NSArray *)queryTableForSuggestListType:(NSString *)type sid:(NSString *)sid className:(NSString *)className withbiz_date:(NSString *)biz_date{
    
    NSString * empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM suggest_list WHERE sid = '%@' AND type = '%@' AND biz_date = '%@' AND empid = '%@';",sid,type,biz_date,empId];
    
    NSMutableArray *temp = [self queryAndReturnInfosBySql:sql andClassName:className];
    
    if ([type isEqualToString:@"02"]) { //批发
        
        for (WSSuggestWholesale *sw in temp) {
            
            WSSuggestWhoModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:sw.item];
            sw.sugModel = model;
        }
        
    }else{  //用家
        
        for (WSSuggestHome *sw in temp) {
            
            WSSuggestHomeModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:sw.item];
            sw.sugHomeModel = model;
        }
    }
    
    
    return [temp copy];

}

- (NSArray *)queryTableForSuggestListType:(NSString *)type className:(NSString *)className
{
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM suggest_list WHERE type = '%@' AND sid = '0';",type];
    NSMutableArray *temp = [self queryAndReturnInfosBySql:sql andClassName:className];
    
    
    if ([type isEqualToString:@"02"]) {
        
        for (WSSuggestWholesale *sw in temp) {
            
            WSSuggestWhoModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:sw.item];
            sw.sugModel = model;
        }
        
    }else{
        
        for (WSSuggestHome *sw in temp) {
            
            WSSuggestHomeModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:sw.item];
            sw.sugHomeModel = model;
        }
    }
    

    return [temp copy];
}
@end

//
//  WSUserBehaviorDBService.m
//  WinSFA
//
//  Created by yang on 17/5/27.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSUserBehaviorDBService.h"
#import "WSUserBehaviorStatisticsTable.h"

@implementation WSUserBehaviorDBService

+ (BOOL)insertWithUserAccount:(NSString *)userAccount
               parentFuncBean:(WSFuncsBean *)parentFuncBean
              currentFuncBean:(WSFuncsBean *)currentFuncBean
                        store:(WSStoreBean *)store
                      sceneId:(NSString *)sceneId
                      eventId:(NSString *)eventId
                    startTime:(NSString *)startTime
                      endTime:(NSString *)endTime
                   eventValue:(NSString *)eventValue
                        genId:(NSString *)genId
{
    NSMutableArray *values = [NSMutableArray array];
    
    [values addObject:[(userAccount ?: [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_LAST_LOGIN]) lowercaseString] ?: [NSNull null]]; //userAccount
    [values addObject:[WSAppData getObjectbyKey:APPDATA_EMPNAME] ?: [NSNull null]]; //empName
    [values addObject:([WSAppData getObjectbyKey:APPDATA_BIZDATE] ?: [WSCurrentTime getDateStringForDevice]) ?: [NSNull null]]; //bizDate
    [values addObject:parentFuncBean.fc ?: [NSNull null]];   //parentFc
    [values addObject:parentFuncBean.name ?: [NSNull null]];  //parentFuncName
    [values addObject:currentFuncBean.fc ?: [NSNull null]];   //fc
    [values addObject:currentFuncBean.name ?: [NSNull null]];   //funcName
    [values addObject:store.Id ?: [NSNull null]]; //storeId
    [values addObject:store.code ?: [NSNull null]]; //storeCode
    [values addObject:store.name ?: [NSNull null]]; //storeName
    [values addObject:sceneId ?: [NSNull null]]; //sceneId
    [values addObject:eventId ?: [NSNull null]]; //eventId
    [values addObject:startTime ?: [NSNull null]]; //startTime
    [values addObject:endTime ?: [NSNull null]]; //endTime
    [values addObject:eventValue ?: [NSNull null]]; //eventValue
    [values addObject:genId ?: [NSNull null]]; //genId
    LogInfo(@"yihaijialiC");
    return [[WSUserBehaviorStatisticsTable sharedTable] insertWithArgumentsValue:values];
}

+ (BOOL)updateEndTime:(NSString *)endTime withGenID:(NSString *)genID {
    
    if (!endTime || !genID) {
        return NO;
    }
    
    return [[WSUserBehaviorStatisticsTable sharedTable] updateWithNames:@[@"endTime"] values:@[endTime] whereName:@[@"genId"] whereValue:@[genID]];
}

+ (BOOL)updateStartTime:(NSString *)startTime withGenID:(NSString *)genID {
    
    if (!startTime || !genID) {
        return NO;
    }
    
    return [[WSUserBehaviorStatisticsTable sharedTable] updateWithNames:@[@"startTime"] values:@[startTime] whereName:@[@"genId"] whereValue:@[genID]];
}

//_id as seq,userAccount,bizdate,sceneId,eventId,parentFc,parentFuncName,fc,funcName,storeId,startTime,endTime,eventValue
+ (NSArray *)queryDicArrayForYestoday {
    
    NSString *sql = [NSString stringWithFormat:@"select * from user_behavior_statistics where not bizdate = %@", [WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    
    return [[WSUserBehaviorStatisticsTable sharedTable] queryDicDatasBySql:sql argumentsValues:nil];
}

+ (BOOL)deleteDataForYestoday {
    
    return [[WSUserBehaviorStatisticsTable sharedTable] deleteWithNames:@[@"not bizdate"] ArgumentsValue:@[[WSAppData getObjectbyKey:APPDATA_BIZDATE]]];
}


+ (NSArray *)queryAllDicArray {
    
    NSString *sql = @"select _id,userAccount,bizdate,sceneId,eventId,parentFc,parentFuncName,fc,funcName,storeId,startTime,endTime,eventValue from user_behavior_statistics";
    
    return [[WSUserBehaviorStatisticsTable sharedTable] queryDicDatasBySql:sql argumentsValues:nil];
}

+ (BOOL)deleteDataWithIDArray:(NSArray *)idArray {
    
    if (!idArray || idArray.count == 0) {
        return YES;
    }
    
    return [[WSUserBehaviorStatisticsTable sharedTable] batchDeleteFromTableWithNames:@[@"_id"] ArgumentsValues:@[idArray]];
}


@end

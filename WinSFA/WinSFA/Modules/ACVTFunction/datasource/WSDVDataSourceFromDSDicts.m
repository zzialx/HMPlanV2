//
//  WSDVDataSourceFromDSDicts.m
//  WinSFA
//
//  Created by Alicia on 17/1/25.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSDVDataSourceFromDSDicts.h"
#import "WSBaseDictsDBService.h"
#import "WSDataSourceManager.h"
#import "WSAcvtModel.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSBaseStoreDBService.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "WSStoreOtherBean.h"

@implementation WSDVDataSourceFromDSDicts

- (NSObject *)getDataSourceFor:(NSObject<I_W_BuildInfo> *)buildInfo
{
    if ([buildInfo getDataSource] && [[buildInfo getDataSource] isEqualToString:DICTS]) {
        self.dataSourceArray = [self getDataSourceByFilter:[buildInfo getFilterCondition] andBuildInfo:buildInfo];
        BOOL isDisplayMode = [self isDisplayModeFor:buildInfo];
        if (isDisplayMode) {
            [self resetDataSourceWithQueryCount];
        }
    }
    return self.dataSourceArray;
}


- (BOOL)isDisplayModeFor:(NSObject<I_W_BuildInfo> *)buildInfo {
    NSString *displayMode = [buildInfo getDisplayMode];
    if (!displayMode || ![displayMode isEqualToString:QST_TYPE_BN]) {
        return NO;
    } else {
        return YES;
    }
}

- (void)resetDataSourceWithQueryCount {
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    
    NSString *acvtId = model.currentAcvtBean.acvtId;
    BOOL isUseStoreFilter = [WSBaseStoreDBService isUseStoreFilterQueryStoreWithAcvtId:acvtId];
    if (!isUseStoreFilter) {
        [self resetDataSourceWithQueryCountWithAcvtDis];
    } else {
        [self resetDataSourceWithQueryCountWithStoreFilter];
    }
}

- (void)resetDataSourceWithQueryCountWithAcvtDis {
    
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    
    NSString *acvtId = model.currentAcvtBean.acvtId;
    NSString *styp = model.currentFuncs.styp;
    NSString *search_objId = STORES;
    if ([model.currentFuncs.ds length] > 0) {
        search_objId = model.currentFuncs.ds;
    }
    
    WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
    NSArray *qstArray = [service queryAcvtQstDictsCountByAcvtId:acvtId filter:styp objId:search_objId];
    
    NSMutableArray *resetDicArray = [self.dataSourceArray mutableCopy];
    for (WSBaseStoreAcvtDisObject *acvtDisObj in qstArray) {
        for (WSDictBean *dicBean in resetDicArray) {
            if ([acvtDisObj.acvt_qst_answer isEqualToString:dicBean.Id] && acvtDisObj.queryCount) {
                NSString *name = dicBean.name;
                [dicBean setName:[NSString stringWithFormat:@"%@(%ld)", name, (long)acvtDisObj.queryCount]];
                break;
            }
        }
    }
    self.dataSourceArray = [resetDicArray copy];
}

- (void)resetDataSourceWithQueryCountWithStoreFilter {
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    if ([model.currentAcvtBean.qsts count] == 0) {
        return;
    }
    
    WSAcvtBean_qst *qst = model.currentAcvtBean.qsts[0];
    NSString *colName = [qst.memo stringByReplacingOccurrencesOfString:@"t" withString:@"item"];
    
    WSBaseStoreOtherDataDBService *service = [[WSBaseStoreOtherDataDBService alloc] init];
    NSArray *storeOtherDataArray = [service queryStoreFilterWithQstArray:model.currentAcvtBean.qsts];
    
    NSMutableArray *resetDicArray = [self.dataSourceArray mutableCopy];
    for (WSStoreOtherBean *otherBean in storeOtherDataArray) {
        for (WSDictBean *dicBean in resetDicArray) {
            NSString *itemValue = [otherBean valueForKey:colName];
            if ([itemValue isEqualToString:dicBean.Id] && otherBean.queryCount) {
                NSString *name = dicBean.name;
                [dicBean setName:[NSString stringWithFormat:@"%@(%ld)", name, (long)otherBean.queryCount]];
                break;
            }
        }
    }
    
    self.dataSourceArray = [resetDicArray copy];
}

@end

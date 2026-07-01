//
//  WSHighFrequencySearchDataTool.m
//  WinSFA
//
//  Created by yuanji on 2018/11/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSHighFrequencySearchDataTool.h"
#import "WSBaseStoreOtherDataDBService.h"

NSString *const WSQueryHighFrequencySearchType = @"SEARCH_PROD_HISTORY_FLAG";//定义 查询高频搜索标示
//=====================================================================================================================================

#pragma mark - 高频搜索结果数据工具
@implementation WSHighFrequencySearchDataTool

#pragma mark - 查询高频搜索数据方法 maxCount:最大数量
- (NSArray *)queryHighFrequencySearchDataWithMaxCount:(NSInteger)maxCount {
    
    NSString *needSearchProdRecord = [[NSUserDefaults standardUserDefaults] objectForKey:NEED_SEARCH_PROD_RECORD];
    if (![needSearchProdRecord isEqualToString:@"1"]) {
        return nil;
    }
    
    WSBaseStoreOtherDataDBService *dataService = [[WSBaseStoreOtherDataDBService alloc] init];
    NSArray *array = [dataService queryHighFrequencySearchDataWithType:WSQueryHighFrequencySearchType
                                                                 empId:[WSAppData getObjectbyKey:APPDATA_EMPID]
                                                              maxCount:maxCount];
    return array;
}

#pragma mark - 更新高频搜索数据方法 text:文本
- (void)updateHighFrequencySearchDataWithText:(NSString *)text {
    
    if (text && text.length > 0) {
        WSBaseStoreOtherDataDBService *dataService = [[WSBaseStoreOtherDataDBService alloc] init];
        [dataService saveHighFrequencySearchDataWithType:WSQueryHighFrequencySearchType
                                                   empId:[WSAppData getObjectbyKey:APPDATA_EMPID]
                                                    text:text];
    }
}

#pragma mark - 删除高频搜索数据方法 text:文本
- (void)deleteHighFrequencySearchDataWithText:(NSString *)text {
    
    if (text && text.length > 0) {
        WSBaseStoreOtherDataDBService *dataService = [[WSBaseStoreOtherDataDBService alloc] init];
        [dataService deleteHighFrequencySearchDataWithType:WSQueryHighFrequencySearchType
                                                     empId:[WSAppData getObjectbyKey:APPDATA_EMPID]
                                                      text:text];
    }
}

@end
//=====================================================================================================================================

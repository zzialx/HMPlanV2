//
//  WSHighFrequencySearchDataTool.h
//  WinSFA
//
//  Created by yuanji on 2018/11/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
//=====================================================================================================================================

#pragma mark - 高频搜索结果数据工具
@interface WSHighFrequencySearchDataTool : NSObject

#pragma mark - 查询高频搜索数据方法 maxCount:最大数量
- (NSArray *)queryHighFrequencySearchDataWithMaxCount:(NSInteger)maxCount;

#pragma mark - 更新高频搜索数据方法 text:文本
- (void)updateHighFrequencySearchDataWithText:(NSString *)text;

#pragma mark - 删除高频搜索数据方法 text:文本
- (void)deleteHighFrequencySearchDataWithText:(NSString *)text;

@end
//=====================================================================================================================================

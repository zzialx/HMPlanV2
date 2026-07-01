//
//  WSMutilevelMenuDataTool.h
//  WinSFA
//
//  Created by sunhf on 2018/1/17.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSBaseDictsDBService.h"

@interface WSMutilevelMenuDataTool : NSObject
{
    WSBaseDictsDBService *service;
}
@property (nonatomic, strong) NSMutableArray *defaultSelectedLevleDataArray;
@property (nonatomic, assign) NSInteger maxLevelNumber;
- (NSMutableArray *)getMutilevelMenuDataWith:(NSMutableArray *)dataSourceArray;
- (WSDictBean *)getSearchDictWithName:(NSString *)dictName withFilterStr:(NSString *)filterStr;
@end

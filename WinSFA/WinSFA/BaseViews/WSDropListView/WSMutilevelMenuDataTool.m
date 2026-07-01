//
//  WSMutilevelMenuDataTool.m
//  WinSFA
//
//  Created by sunhf on 2018/1/17.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSMutilevelMenuDataTool.h"

@implementation WSMutilevelMenuDataTool
- (id)init
{
    self = [super init];
    if (self) {
        service = [[WSBaseDictsDBService alloc] init];
    }
    return self;
}
- (NSMutableArray *)getMutilevelMenuDataWith:(NSMutableArray *)dataSourceArray
{
    WSDictBean *dictBean = dataSourceArray.firstObject;
    NSMutableArray *allDataArray = [NSMutableArray array];
    //一级菜单 系统返回
    [allDataArray addObject:dataSourceArray];
    
    WSDictBean *levelCodeMaxDictBean = [service queryDictWithTyp:dictBean.typ];
    self.maxLevelNumber = [levelCodeMaxDictBean.levelCode intValue];
    //是否是回显,如果后台下发的数据levelCode和数据库中最大的levelCode相同 是回显 回显的话需要根绝后面的倒推查询数据
    if ([levelCodeMaxDictBean.levelCode isEqualToString:dictBean.levelCode])
    {
        [self.defaultSelectedLevleDataArray removeAllObjects];
        [self.defaultSelectedLevleDataArray addObject:dictBean];
        NSMutableArray *tempArray = [NSMutableArray array];
        [tempArray addObject:dictBean];
        for (int i = (int)_maxLevelNumber-1 ; i > 0; i--) {
            WSDictBean *lastBean = [service queryDictWithID:((WSDictBean *)tempArray.firstObject).p];
           [self.defaultSelectedLevleDataArray insertObject:lastBean atIndex:0];
            NSMutableArray *lastBeanameLevelDataArray = (NSMutableArray *)[service queryDictsWithParentId:lastBean.p filter:lastBean.typ];
            [allDataArray insertObject:lastBeanameLevelDataArray atIndex:0];
            [tempArray removeAllObjects];
            [tempArray addObject:lastBean];
        }
    }
    else
    {
        //不是回显的话  默认显示2层,初始化前二层数据就可以
        //二级菜单 通过1级菜单第一个默认值查询他的子集数据
       // [allDataArray addObject:[service queryDictsWithParentId:dictBean.Id filter:dictBean.typ]];
    }
    return allDataArray;
}

//回显需要选中每个层级里需要被选中的那个
- (NSMutableArray *)defaultSelectedLevleDataArray
{
    if (!_defaultSelectedLevleDataArray) {
        _defaultSelectedLevleDataArray = [NSMutableArray array];
    }
    return _defaultSelectedLevleDataArray;
}

- (WSDictBean *)getSearchDictWithName:(NSString *)dictName withFilterStr:(NSString *)filterStr
{
//    WSDictBean *searchBean = [service queryDictWithTyp:filterStr andCod:dictName];
    WSDictBean *searchBean = [service queryDictWithName:dictName];
    return searchBean;
}

@end

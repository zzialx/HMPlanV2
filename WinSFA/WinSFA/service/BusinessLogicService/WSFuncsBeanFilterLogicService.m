//
//  WSFuncsBeanFilterService.m
//  WinSFA
//
//  Created by Stephanie on 16/8/26.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSFuncsBeanFilterLogicService.h"
#import "WSBaseAcvtDBService.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSBaseDictsDBService.h"
#import "WSFuncsBeanArray.h"

@implementation WSFuncsBeanFilterLogicService

#pragma mark - public method

+ (NSArray *)filterFuncsBean:(NSArray *)funcsBeanArray withStore:(WSStoreBean *)storeBean bizDate:(NSString *)bizDate
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:funcsBeanArray.count];
    
    //标准产品：根据门店stype过滤
    if (storeBean.styp)
    {
        for (WSFuncsBean *fb in funcsBeanArray)
        {
            if ([WSFuncsBeanFilterLogicService isFuncsBean:fb matchStyp:storeBean.styp]) {
                [array addObject:fb];
            }
        }
    }
    else
    {
        [array addObjectsFromArray:funcsBeanArray];
    }
    
    
    //联合利华，增加另一个过滤条件：
    //SFALHLH-318	【联合利华】styp中添加一个筛选条件，过滤固定的调查问卷methodVisit 中的methodVisit 问题中的值的id对应的字典项的code
    WSBaseAcvtDBService *service = [[WSBaseAcvtDBService alloc] init];
    WSAcvtBean *acvt = [service queryAcvtWithAcvtCode:VISIT_TYPE_ACVT_CODE];
    
    //新逻辑见http://192.168.1.15/jira/browse/MSTD-4015
    if (!acvt) {
        for (WSFuncsBean *funcsBean in array) {
            if ([funcsBean.opt.isTipsMenu isEqualToString:@"1"]) {
                acvt = [service queryAcvtByFilter:funcsBean.filter acvtCode:nil];
                break;
            }
        }
    }
    
    if (acvt) {
        //有methodVisit这个问卷才去过滤
        WSAcvtBean_qst *qst = [acvt getQstBeanByQstCod:VISIT_TYPE_ACVT_CODE];
        if (qst) {
            WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
            NSString *value = [service queryQstValueWithStoreId:storeBean.Id acvtId:acvt.acvtId acvtQstId:qst.acvtQstId genId:nil isMatchGenId:NO bizDate:bizDate];
            if ([value length] > 0) {
                WSBaseDictsDBService *dictService = [[WSBaseDictsDBService alloc] init];
                WSDictBean *db = [dictService queryDictWithID:value];
                if ([db.cod length] > 0) {
                    NSArray *originArray = [NSArray arrayWithArray:array];
                    [array removeAllObjects];
                    for (WSFuncsBean *fb in originArray) {
                        if ([WSFuncsBeanFilterLogicService isFuncsBean:fb matchStyp:db.cod]) {
                            [array addObject:fb];
                        }
                    }
                }
            }
        }
        //下级菜单需要去掉这个节点，这个节点是在拜访准备之前单独用弹框形式展示的。
        for (WSFuncsBean *fb in array) {
            if ([fb.filter isEqualToString:acvt.typ]) {
                [array removeObject:fb];
                break;
            }
        }
    }
    
    
    //下级菜单需要去掉isTipsMenu为1的
    for (WSFuncsBean *fb in array) {
        if ([fb.opt.isTipsMenu isEqualToString:@"1"]) {
            [array removeObject:fb];
            break;
        }
    }
    
    
    //Note: djf 如果菜单为调查问卷类型，并且此菜单对应的调查问卷无数据时，则在工作列表中自动隐藏此菜单，并且加入log中
    NSMutableArray *delArray = [NSMutableArray arrayWithCapacity:1];
    for (WSFuncsBean *fbItem in array) {
        if ([fbItem.isAcvtList isEqualToString:@"1"]) {
            NSString *className = [WSPlistHelper valueForKey:fbItem.fv withPlistName:kControllerMappingFileName];
            if (className == nil) {
                NSArray *filterArray = [service queryAcvtsByFilter:fbItem.filter acvtCode:nil];
                if (!filterArray || [filterArray count] == 0) {
                    [delArray addObject:fbItem];
                    LogInfo(@"HIDE MODLE FC:%@, FV:%@, NAME:%@: 此菜单需要配问卷才能显示。", fbItem.fc, fbItem.fv, fbItem.name);
                }
            }
        }
    }
    
    if ([delArray count] > 0) {
        [array removeObjectsInArray:delArray];
    }

    return array;
}

- (NSArray *)filterMenuTypeFuncsBean:(NSArray *)funcsBeanArray withDictsBeanArray:(NSArray *)dictsBeanArray {
    NSMutableArray *dataSource = [NSMutableArray arrayWithCapacity:dictsBeanArray.count];
    for (WSDictBean *dictBean in dictsBeanArray) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.menuType = %@", dictBean.Id];
        NSArray *funcsArray = [funcsBeanArray filteredArrayUsingPredicate:predicate];
        [dataSource addObject:funcsArray];
    }
    return [dataSource copy];
}

+ (WSFuncsBean *)getSubMenuFuncsBeanByCurrentFB:(WSFuncsBean *)currentFB {
    
    NSString *subMenuCode = currentFB.submenu;
    if (!subMenuCode || [subMenuCode length] == 0) {
        WSFuncsBean* nextfb = [currentFB.funcsArray firstObject];
        if (nextfb) {
            subMenuCode = nextfb.submenu;
        }
    }
    
    WSFuncsBean* subMenuFB = [WSFuncsBeanFilterLogicService getSubMenuFuncsBeanByFuncsCode:subMenuCode];
    
    return subMenuFB;
}

+ (WSFuncsBean*)getSubMenuFuncsBeanByFuncsCode:(NSString*)subMenuFC {
    
    if(subMenuFC == nil || [subMenuFC length] == 0) {
        return nil;
    }
    
    WSFuncsBeanArray* fbArray = [WSAppData getObjectbyKey:FUNCS];
    
    if (fbArray == nil) {
        return nil;
    }
    
    WSFuncsBean* resultFB = [fbArray getFuncsBeanFromSubFC:subMenuFC];
    
    return resultFB;
}


#pragma mark - private method

+ (BOOL)isFuncsBean:(WSFuncsBean *)funcsBean matchStyp:(NSString *)styp
{
    if ([funcsBean.fv isEqualToString:UNILEVERREADYCALLPLAN_FV]) {
        return NO;
    }
    
    if (!funcsBean.styp || [funcsBean.styp length] < 1)
    {
        return YES;
    }
    else if (styp != nil && [styp isKindOfClass:[NSString class]])
    {
        // 类型完全相等
        if ([funcsBean.styp isEqualToString:styp]) {
            return YES;
        }else  if ([styp rangeOfString:@"-"].location != NSNotFound) {
            NSArray *stypArray = [styp componentsSeparatedByString:@"-"];
            if ([stypArray count] > 0 && [funcsBean.styp isEqualToString:[stypArray firstObject]]) {
                return YES;
            }
        }
        if ([funcsBean.styp rangeOfString:@","].location != NSNotFound){
            
            NSArray *stypArray =[funcsBean.styp componentsSeparatedByString:@","];
            
            for (NSString *stypFb in stypArray) {
                // MN-873 配置兼容，忽略大小写
                if ([stypFb caseInsensitiveCompare:styp] == NSOrderedSame) {
                    return YES;
                    break;
                }
            }
        }
    }
    
    return NO;
}

@end

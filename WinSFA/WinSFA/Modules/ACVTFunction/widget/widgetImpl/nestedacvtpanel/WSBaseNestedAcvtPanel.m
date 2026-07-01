//
//  WSBaseNestedAcvtPanel.m
//  WinSFA
//
//  Created by yang on 16/1/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSBaseNestedAcvtPanel.h"
#import "I_W_BuildInfo.h"
#import "WSInterAction.h"
#import "WSEmbeddedAcvtViewController.h"
#import "WSAcvtModel.h"
#import "WSDataSourceManager.h"
#import "I_W_DisplayValue.h"
#import "WSNestedAcvtModel.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSBaseAcvtDBService.h"
#import "WSAcvtQstDisItem.h"

@interface WSBaseNestedAcvtPanel ()

@end

@implementation WSBaseNestedAcvtPanel

- (void)buildDisplayContent
{
    [super buildDisplayContent];
    
    self.deleteMD5Array = [NSMutableArray array];
    self.anNewAddMD5Array = [NSMutableArray array];
    
    _acvtDataArray = [NSMutableArray array];
    _acvtMd5Array = [NSMutableArray array];
    
    _originalValue = [xdisplayValue getDisplayValueFor:xbuildInfo];
    
    if ([_originalValue isKindOfClass:[NSString class]]) {
        NSString *s = (NSString *)_originalValue;
        id obj = [s objectFromJSONString];
        if ([obj isKindOfClass:[NSArray class]]) {
            [_acvtDataArray addObjectsFromArray:obj];
        }
        
        for (NSDictionary *dic in _acvtDataArray) {
            if ([dic objectForKey:@"id"]) {
                [_acvtMd5Array addObject:[dic objectForKey:@"id"]];
            }
        }
    }
    
    self.acvtMd5Array = [self filterDuplicatedMD5:self.acvtMd5Array]; //去重
    if ([_originalValue isKindOfClass:[NSString class]]) {
        [self loadRedisDataWithValue:(NSString *)_originalValue];
    }
}

- (NSMutableArray *)filterDuplicatedMD5:(NSMutableArray *)array
{
    if (!array) {
        return nil;
    }
    
    NSMutableArray *resultArray = [NSMutableArray array];
    for (NSString *md5 in array) {
        if (![resultArray containsObject:md5]) {
            [resultArray addObject:md5];
        }
    }
    
    return resultArray;
}

- (NSObject *)getResultPresentation
{
    return [self getResultDirectly];
}


- (void)loadRedisDataWithValue:(NSString *)value
{
    id obj = [value objectFromJSONString];
    if (![obj isKindOfClass:[NSArray class]]) {
        NSArray *redisAcvtMd5Array = [value componentsSeparatedByString:@","];
        if ([redisAcvtMd5Array count] > 0) {
            
            self.acvtMd5Array = [redisAcvtMd5Array mutableCopy];
            
            //去重
            self.acvtMd5Array = [self filterDuplicatedMD5:self.acvtMd5Array];
            
            self.acvtDataArray = [self generateAcvtDatasArray];
        }
    }
    
}

- (void)reloadCurrentWidgetWithValue:(NSObject *)value {
    if ([value isKindOfClass:[NSString class]]) {
        [self loadRedisDataWithValue:(NSString *)value];
    }
}



- (NSMutableArray *)generateAcvtDatasArray
{
    NSMutableArray *acvtDatasArray = [NSMutableArray arrayWithCapacity:self.acvtMd5Array.count];
    
    NSMutableArray *needDeleteArray = [NSMutableArray array];
    for (NSString *md5 in self.acvtMd5Array) {
        
        NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithCapacity:self.nestedAcvtBean.qsts.count];
        dataDic[@"id"] = md5;
        
        WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
        NSArray *datas = [service queryAcvtQstDatasByGenId:md5];
        
        for (WSAcvtQstDisItem *item in datas) {
            if ([item.acvtanswer length] > 0) {
                [dataDic setObject:item.acvtanswer forKey:[NSString stringWithFormat:@"%@%@", item.qsttype, item.acvtQstId]];
            }
            if([item.qsttype isEqualToString:@"AN"])
            {
                NSArray *tempArray = [self generateAcvtANDatasArray:item.acvtanswer];
                if (tempArray.count > 0) {
                    [dataDic setObject: tempArray forKey:[NSString stringWithFormat:@"%@%@", item.qsttype, item.acvtQstId]];
                }
            }
        }
        
        if ([dataDic count] == 1) {
            [needDeleteArray addObject:md5];
        }else {
            [acvtDatasArray addObject:dataDic];
        }
        
    }
    
    if ([needDeleteArray count] > 0) {
        [self.acvtMd5Array removeObjectsInArray:needDeleteArray];
    }
    
    return acvtDatasArray;
}

- (NSMutableArray *)generateAcvtANDatasArray:(NSString *)genId
{
    NSMutableArray *acvtDatasArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithCapacity:0];
    dataDic[@"id"] = genId;
    WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
    NSArray *datas = [service queryAcvtQstDatasByGenId:genId];
    
    for (WSAcvtQstDisItem *item in datas) {
        if ([item.acvtanswer length] > 0) {
            [dataDic setObject:item.acvtanswer forKey:[NSString stringWithFormat:@"%@%@", item.qsttype, item.acvtQstId]];
        }
        if([item.qsttype isEqualToString:@"AN"])
        {
            [dataDic setObject: [self generateAcvtANDatasArray:item.acvtanswer] forKey:[NSString stringWithFormat:@"%@%@", item.qsttype, item.acvtQstId]];
        }
    }
    
    if ([dataDic count] == 1) {
        //        [needDeleteArray addObject:md5];
    }else if ([dataDic count] > 0){//SFA-28754 【SFA泸州老窖】【iOS】不做修改上传门店详情问卷时，会上传多余的问题且是空值
        [acvtDatasArray addObject:dataDic];
    }
    return acvtDatasArray;
}

#pragma mark - WSEmbeddedAcvtViewControllerDelegate

- (void)embeddedAcvtController:(WSEmbeddedAcvtViewController *)controller confirmData:(NSDictionary *)dic
{
    if (!dic || [dic count] == 0) {
        return;
    }
    
    if ([[dic allKeys] count] == 1 && [[[dic allKeys] firstObject] isEqualToString:@"id"])
    {
        return;
    }
    
    NSString *md5 = [dic objectForKey:@"id"];
    
    if (!md5) {
        return;
    }
    
    self.isEmbeddedAcvtConfirmedData = YES;
    
    if ([self.acvtMd5Array containsObject:md5]) {
        for (NSDictionary *dataDic in self.acvtDataArray) {
            NSString *md5Str = [dataDic objectForKey:@"id"];
            if ([md5 isEqualToString:md5Str]) {
                [self.acvtDataArray replaceObjectAtIndex:[self.acvtDataArray indexOfObject:dataDic] withObject:dic];
                break;
            }
        }
    }else {
        [self.acvtMd5Array addObject:md5];
        [self.acvtDataArray addObject:dic];
        
        [self.anNewAddMD5Array addObject:md5];
        //        donghong SFA-25257
        if ([[xbuildInfo getAcvtMemo2] isEqualToString:@"newest"]) {
            if (self.acvtDataArray.count > 0) {
                self.acvtDataArray = [NSMutableArray arrayWithObject:[self.acvtDataArray lastObject]];
                self.acvtMd5Array = [NSMutableArray arrayWithObject:[self.acvtMd5Array lastObject]];
                self.anNewAddMD5Array = [NSMutableArray arrayWithObject:[self.anNewAddMD5Array lastObject]];
                
            }
        }

    }
}

- (void)embeddedAcvtControllerBeginToVisitStore:(WSEmbeddedAcvtViewController *)controller
{
    WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
    model.extralData = [xbuildInfo getAcvtQstId];
    
    if ([model isKindOfClass:[WSNestedAcvtModel class]]) {
        WSNestedAcvtModel *nestModel = (WSNestedAcvtModel *)model;
        nestModel.parentModel.extralData = [xbuildInfo getAcvtQstId];
    }
    
    WSInterAction  *interaction =[[WSInterAction alloc] init];
    [interaction setExecute_method:@selector(beginToVisitStore:)];
    [interaction setExecute_method_param:nil];
    [interaction setDirect_type:DIRECT_TYPE_METHOD_WITH_SINGLEPARAM];
    
    
    if ([self.delegate respondsToSelector:@selector(executeInterAction:)]) {
        [self.delegate executeInterAction:interaction];
    }
    
}


@end

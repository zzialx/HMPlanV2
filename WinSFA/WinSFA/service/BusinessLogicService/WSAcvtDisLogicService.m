//
//  WSAcvtDisLogicService.m
//  WinSFA
//
//  Created by Stephanie on 16/8/29.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSAcvtDisLogicService.h"
#import "WSBaseDictsDBService.h"
#import "WSBaseProductDBService.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSBaseStoreDBService.h"
#import "WSBaseAcvtDBService.h"
#import "WSBaseEmployeTable.h"

@implementation WSAcvtDisLogicService

+ (NSString *)getQstValuePresentationWithValueID:(NSString *)valueID qstBean:(WSAcvtBean_qst *)qstBean
{
    if (!valueID || [valueID length] == 0) {
        return valueID;
    }
    
    NSString *value = nil;
    
    if ([qstBean.qstType isEqualToString:QST_TYPE_R] || [qstBean.qstType isEqualToString:QST_TYPE_SS]) {
        
        value = [WSAcvtDisLogicService getOPTValueByID:valueID qstBean:qstBean];
        
    }else if ([qstBean.qstType isEqualToString:QST_TYPE_C]) {
        
        NSArray *array = [valueID componentsSeparatedByString:@","];
        
        NSMutableArray *valueArray = [NSMutableArray arrayWithCapacity:array.count];
        
        for (NSString *valueID in array) {
            NSString *realValue = [self getOPTValueByID:valueID qstBean:qstBean];
            if (realValue) {
                [valueArray addObject:realValue];
            }
        }
        
        if ([valueArray count] > 0) {
            value = [valueArray componentsJoinedByString:@","];
        }
        
    }else if ([qstBean.qstType isEqualToString:QST_TYPE_DV] || [qstBean.qstType isEqualToString:QST_TYPE_RD]){
        
        if (qstBean) {
            
            value = [self getDSValueByID:valueID ds:qstBean.ds filter:qstBean.filter];
            
        }
        
    }else if ([qstBean.qstType isEqualToString:QST_TYPE_CD]){
        
        NSArray *array = [valueID componentsSeparatedByString:@","];
        
        NSMutableArray *valueArray = [NSMutableArray arrayWithCapacity:array.count];
        
        for (NSString *valueID in array) {
            NSString *realValue = [self getDSValueByID:valueID ds:qstBean.ds filter:qstBean.filter];
            if (realValue) {
                [valueArray addObject:realValue];
            }
        }
        
        if ([valueArray count] > 0) {
            value = [valueArray componentsJoinedByString:@","];
        }
        
    }else {
        value = valueID;
    }
    
    return value;
}

+ (NSString *)getOPTValueByID:(NSString *)valueID qstBean:(WSAcvtBean_qst *)qstBean
{
    if (!valueID || [valueID length] == 0) {
        return valueID;
    }
    
    NSString *value = nil;
    
    for (WSAcvtBean_qst_opt* option_temp in qstBean.opt) {
        if ([option_temp.optId isEqualToString:valueID]) {
            value = option_temp.optName;
            break;
        }
    }
    
    return value;
}

+ (NSString *)getOPTValueByID:(NSString *)valueID acvtQstID:(NSString *)acvtQstID
{
    NSArray *valueIDArray = [valueID componentsSeparatedByString:@","];
    
    if (!valueID || [valueID length] == 0 || valueIDArray.count == 0 || !acvtQstID) {
        return nil;
    }
    
    NSMutableArray *nameArray = [NSMutableArray arrayWithCapacity:valueIDArray.count];
    
    WSBaseAcvtDBService *service = [[WSBaseAcvtDBService alloc] init];
    
    for (NSString *optID in valueIDArray) {
        NSString *name = [service queryOptNameByID:optID acvtQstID:acvtQstID];
        if (name) {
            [nameArray addObject:name];
        }
    }
    
    if (nameArray.count > 0) {
        return [nameArray componentsJoinedByString:@","];
    }
    return  nil;
}

+ (NSString *)getDSValueByID:(NSString *)valueID ds:(NSString *)ds filter:(NSString *)filter
{
    NSArray *valueIDArray = [valueID componentsSeparatedByString:@","];
    
    if (!valueID || [valueID length] == 0 || valueIDArray.count == 0 || !ds) {
        return nil;
    }
    
    
    NSMutableArray *nameArray = [NSMutableArray arrayWithCapacity:valueIDArray.count];
    
    for (NSString *valueIDString in valueIDArray) {
        
        NSString *value = nil;
        
        if ([ds isEqualToString:DICTS]) {
            
            if (valueIDString && [valueIDString isKindOfClass:[NSString class]]) {
                WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
                WSDictBean *db = [service queryDictWithID:valueIDString];
                value = db.name;
            }
            
        }  else if ([ds isEqualToString:@"prod"]) {
            if (valueIDString && [valueIDString isKindOfClass:[NSString class]]) {
                WSBaseProductDBService *service = [[WSBaseProductDBService alloc] init];
                WSProdBean *prod = [service queryProductByID:valueIDString];
                value = prod.name;
            }
        } else if ([ds isEqualToString:@"storeacvtdis"]) {
            if (valueIDString && [valueIDString isKindOfClass:[NSString class]] && [valueIDString length] > 0) {
                
                WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
                WSBaseStoreAcvtDisObject *disObj = [service queryServerAcvtDisObjectByGenID:valueIDString acvtQstID:filter];
                value = disObj.acvt_qst_answer;
            }
        }else if ([ds isEqualToString:@"acvtdis"]) {
            if (valueIDString && [valueIDString isKindOfClass:[NSString class]] && [valueIDString length] > 0) {
                
                WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
                WSBaseStoreAcvtDisObject *disObj = [service queryQstServerValueAcvtQstId:filter genId:valueIDString server_node:ds];
                value = disObj.acvt_qst_answer;
            }
        }else if ([ds isKindOfClass:[NSString class]] && [ds rangeOfString:STORE].location != NSNotFound){
            
            WSBaseStoreDBService *service = [[WSBaseStoreDBService alloc] init];
            value = [service queryStoreNameWithId:valueIDString];
            
        }else if ([ds isEqualToString:@"emp"]) {
            
            WSBaseEmployeTable *employeTable = [[WSBaseEmployeTable alloc] init];
            NSArray *results = [employeTable  queryColValues:@"name" withName:@[@"emp_id"] ArgumentsValue:@[[NSString stringNotNilWithValue:valueIDString]] isDistinct:YES];
            value = [results firstObject];
        }
        
        if (value) {
            [nameArray addObject:value];
        }
    }
    
    
    if (nameArray.count > 0) {
        return [nameArray componentsJoinedByString:@","];
    }
    
    return  nil;
}

@end

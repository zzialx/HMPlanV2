//
//  WSBaseModel.m
//  WinSFA
//
//  Created by yang on 15/3/31.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSBaseModel.h"
#import "WSCurrentTime.h"
#import "WSAcvtModel.h"
#import "WSCustomTimeTable.h"
#import "WSBaseStoreOtherDataDBService.h"

@implementation WSBaseModel

- (void)loadDataFromDataBase
{
    
}

- (void)createMD5With:(NSDictionary *)param
{
    NSString* acvtId=nil;
    NSString* memo=nil;
    NSString* fc=nil;
    NSString* l_dateStr=nil;
    
    if([param objectForKey:ACVT_ID]){
        acvtId=[param objectForKey:ACVT_ID];
    }
    
    if([param objectForKey:FUNCS_FC]){
        fc = [param objectForKey:FUNCS_FC];
    }else{
        fc = [self.currentFuncs.submenu length] > 0 ? self.currentFuncs.submenu: self.currentFuncs.fc;
    }
    
    if([param objectForKey:MEMO_MD5_PARAM_KEY]){
        memo = [param objectForKey:MEMO_MD5_PARAM_KEY];
    }
    
    if([param objectForKey:DATE_MD5_PARAM_KEY]){
        l_dateStr = [param objectForKey:DATE_MD5_PARAM_KEY];
    }else{
        if ([self.prepareVisitDate length] > 0 && ([self.currentFuncs.dateTyp isEqualToString:@"D"] || !self.currentFuncs.dateTyp)) {
            l_dateStr = self.prepareVisitDate;
        }else {
            l_dateStr = [WSCurrentTime getMD5TimeWithDataType:self.currentFuncs.dateTyp];
        }
    }
    
    NSString *tmpStoreId = self.currentStore.Id;
    if (self.currentStore && [self.currentStore isKindOfClass:[WSStoreBean class]] && self.currentStore.iStoreIdentify && self.currentStore.iStoreIdentify.length > 0) {
        tmpStoreId = self.currentStore.iStoreIdentify;
    }
    if ([self.currentNewStore.Id length] > 0) {
        tmpStoreId = self.currentNewStore.Id;
    }
    
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    if (self.currentSubEmpStore) {
        NSString *appendEmpId = [NSString stringWithFormat:@"@%@", self.currentSubEmpStore.Id];
        empId  = [empId stringByAppendingString:appendEmpId];
    } else if ([self isKindOfClass:[WSAcvtModel class]]) {
        WSAcvtModel *acvtModel = (WSAcvtModel *)self;
        if ([acvtModel.subEmpId length] > 0) {
            empId  = [empId stringByAppendingString: [NSString stringWithFormat:@"@%@", acvtModel.subEmpId]];
        }
    }
    NSString *date = [WSCurrentTime getDateString];
    //    YIHAIKERRY-2947
    //    益海嘉里-深圳：门店拜访模块：竞品提报：输入信息后，点击返回按钮，提示保存，保存后所有产线竞品提报都显示刚输入的信息
    BOOL isSubAcvt = NO;
    WSAcvtModel *model = nil;
    if ( [self isKindOfClass:[WSAcvtModel class]]) {
        model = (WSAcvtModel *)self;
        isSubAcvt = model.isSubAcvt;
    }
    // MSTD-7880
    //调查问卷返回时嵌套问卷的问题md5保存方式优化
    NSString *parentQstCode = model.currentAcvtBean.parentQstCode;
    if (isSubAcvt && parentQstCode.length > 0) {
        fc = parentQstCode;
    }
    WSBaseStoreOtherDataObject *otherObject = [WSBaseStoreOtherDataDBService queryAcvtGenIdWithStoreId:self.currentStore.Id withFc:fc withAcvtId:acvtId withBizDate:date withEmpId:self.currentSubEmpStore.Id];
    
    if (self.currentFuncs.opt.isSaveData_back && otherObject.item3) {
            self.md5 = otherObject.item3;
    }else{
      
        // MSTD-7485 按照安卓逻辑修改
        self.md5 = [Md5Manager getMd5ByEmpId:empId
                                     sotreId:tmpStoreId
                                     bizDate:l_dateStr
                                    funcCode:fc
                                      acvtId:acvtId
                                        memo:memo];

    }

}

- (NSDictionary*)md5Param
{
    NSMutableDictionary* md5Param = [NSMutableDictionary dictionary];
    
    if (self.currentVisitAction
        && self.currentVisitAction.module_fc
        && [self.currentVisitAction.module_fc length] > 0) {
        
//        if ([self.realParentFuncsCode length] > 0) {
//            [md5Param setValue:self.realParentFuncsCode  forKey:@"memo"];
//        }else {
//            [md5Param setValue:self.currentVisitAction.module_fc  forKey:@"memo"];
//        }
        
        // 补录数据查询需要传递module_fc
        NSString *enterDateStr = [[WSCustomTimeTable sharedTable] queueCustomEnterDateWithStoreId:self.currentStore.Id withParentFc:self.currentVisitAction.module_fc];
        if (enterDateStr) {
            LogInfo(@"补录数据:%@", enterDateStr);
            [md5Param setObject:enterDateStr forKey:DATE_MD5_PARAM_KEY];
        }
    }
    
    return md5Param;
}

- (BOOL)nativeRedis
{
    BOOL redis = YES;
//    NSString *dateType = self.currentFuncs.dateTyp;
//    if (dateType && [dateType isEqualToString:@"E"] ) {
//        redis = NO;
//    } else if (dateType && [dateType isEqualToString:@"D"]){
//        // 当天回显
//        redis = YES;
//    }else {
//        redis = YES;
//    }
    return redis;
}

- (BOOL)serverRedis
{
    // YIHAIKERRY-438 opt.isAdd参数已经扩展到可以配置调查问卷code（例如："isAdd":"xiaolrb"）
    // SFA-14603 2017-11-28 修改逻辑 原逻辑：self.currentFuncs.redis == 1
    // MSTD-7721 添加 self.isFromRealTimeData
    if ([self.currentFuncs.redis isEqualToString:@"1"] ||
        (self.currentFuncs.opt.isAdd.length > 0 && ![self.currentFuncs.opt.isAdd isEqualToString:@"N"]) ||
        self.isFromModifyStore ||
        self.isFromRealTimeData ) {
        return YES;
    }
    else{
        return NO;
    }
}

 



@end

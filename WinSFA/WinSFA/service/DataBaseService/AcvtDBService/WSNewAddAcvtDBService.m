//
//  WSNewAddAcvtDBService.m
//  WinSFA
//
//  Created by yang on 15/5/29.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSNewAddAcvtDBService.h"
#import "WSFacTable.h"
#import "WSVisitStoreAcvtDataTable.h"

@implementation WSNewAddAcvtDBService

//+ (BOOL)insertNewAddAcvtDatasToDBWithFuncs:(WSFuncsBean *)funcsBean
//                                     store:(WSStoreBean *)storeBean
//                                  acvtBean:(WSAcvtBean *)acvtBean
//                                 storeName:(NSString *)storeName
//                               qstValueDic:(NSDictionary *)qstValueDic
//                                       md5:(NSString *)md5
//{
//    BOOL insertDataToAddStroeIsSucceed =  [WSNewAddAcvtDBService insertDatasToAddStoreTableWithFuncs:funcsBean store:storeBean acvtBean:acvtBean storeName:storeName md5:md5];
//    if (!insertDataToAddStroeIsSucceed) {
//        return insertDataToAddStroeIsSucceed;
//    }
//    
//    
//    //更新所属嵌套问卷
//    BOOL updateNestedAcvtIsSucceed = [WSNewAddAcvtDBService updateNestedAcvtWithFuncs:funcsBean acvtBean:acvtBean andMd5:md5];
//    if (!updateNestedAcvtIsSucceed) {
//        return updateNestedAcvtIsSucceed;
//    }
//    return [WSNewAddAcvtDBService insertDatasToAddStoreQstTableWithStore:storeBean acvtBean:acvtBean qstValueDic:qstValueDic md5:md5];
//}
//
//+ (BOOL)insertDatasToAddStoreTableWithFuncs:(WSFuncsBean *)funcsBean
//                                      store:(WSStoreBean *)storeBean
//                                   acvtBean:(WSAcvtBean *)acvtBean
//                                  storeName:(NSString *)storeName
//                                        md5:(NSString *)md5
//{
//    NSArray* wherenames = [[NSArray alloc] initWithObjects:@"UPDATE_MD5ID", nil];
//    NSArray* wherevalues = [[NSArray alloc] initWithObjects:md5, nil];
//    NSArray* storeArray=[[WSAddStoreTable sharedTable] queryWithNames:wherenames ArgumentsValue:wherevalues];
//
//    if(storeArray.count>0){
//        
//        NSArray* setnames = [[NSArray alloc] initWithObjects:@"ACVT_ID", @"EMP_ID",@"BIZ_DATE",@"UPLOAD_DATE",@"STORE_TYPE",@"STORE_NAME",@"IS_LOCAL", nil];
//        NSMutableArray* setvalues = [[NSMutableArray alloc] init];
//        [setvalues addObject: acvtBean.acvtId];                                           // ACVT_ID
//        [setvalues addObject: [WSAppData getObjectbyKey: APPDATA_EMPID ]];
//        
////        if (self.iID && [self.iID length] > 0) {                                                     // STORE_ID
////            [setvalues addObject:[NSString stringNotNilWithValue:self.currentStore.Id]];
////        } else {
////            [setvalues addObject: [NSString stringNotNilWithValue:self.md5]];
////        }
//        
//        [setvalues addObject: [WSAppData getObjectbyKey:APPDATA_BIZDATE]];                          // BIZ_DATE
//        [setvalues addObject: [WSCurrentTime getDateTime]];                                         // UPLOAD_DATE
//        [setvalues addObject:(funcsBean.styp != nil) ? funcsBean.styp : [NSNull null] ];  //STORE_TYPE
//        [setvalues addObject:[NSString stringNotNilWithValue:storeName]];                           // STORE_NAME
//        [setvalues addObject:@"1"];                                                                  //IS_LOCAL
//        
//        LogInfo(@"update: setNames:%@, setValues:%@, whereNames:%@, whereValues:%@", setnames, setvalues, wherenames, wherevalues);
//        
//        return [[WSAddStoreTable sharedTable] updateWithNames:setnames values:setvalues whereName:wherenames whereValue:wherevalues];
//        
//        
//    }
//    
//    NSMutableArray* row = [[NSMutableArray alloc] init ];
//    [row addObject: [NSNull null]];                                                                 //SR_ID--What is it?
//    [row addObject: acvtBean.acvtId];                                                     // ACVT_ID
//    [row addObject: [WSAppData getObjectbyKey: APPDATA_EMPID ]];                                    // EMP_ID
//    [row addObject: [NSNull null]];                                                                 // RSPN_ID
//    if (storeBean.Id && [storeBean.Id length] > 0) {                                                     // STORE_ID
//        [row addObject:[NSString stringNotNilWithValue:storeBean.Id]];
//    } else {
//        [row addObject: [NSString stringNotNilWithValue:md5]];
//    }
//    [row addObject: [WSAppData getObjectbyKey:APPDATA_BIZDATE]];                                    // BIZ_DATE
//    [row addObject: [NSNumber numberWithInteger:WCDatasUploadStatusUploading]];                     // UPLOAD_FLAG
//    [row addObject: [WSCurrentTime getDateTime]];                                                   // UPLOAD_DATE
//    [row addObject: md5];                                                                 // IMG_IDX
//    [row addObject: funcsBean.fc];                                                          // FUNC_CODE
//    [row addObject: funcsBean.fv];                                                          // FUNC_VIEW
//    [row addObject: @"0"];                                                                       //IS_PLANED
//    [row addObject: [NSNull null]];                                                                 // MEMO
//    [row addObject: md5];                                                                       //update_md5id
//    [row addObject: (funcsBean.styp != nil) ? funcsBean.styp : [NSNull null] ];      //STORE_TYPE
//    [row addObject:[NSNull null]];                                                                  //ADD_TYPE
//    [row addObject:[NSString stringNotNilWithValue:storeName]];                                     //STORE_NAME
//    [row addObject:@"1"];                                                                           //IS_LOCAL
//    
//    LogInfo(@"insert: %@", row);
//    
//    return [[WSAddStoreTable sharedTable] insertWithArgumentsValue:row];
//
//}
//
//+ (BOOL)insertDatasToAddStoreQstTableWithStore:(WSStoreBean *)storeBean
//                                      acvtBean:(WSAcvtBean *)acvtBean
//                                   qstValueDic:(NSDictionary *)qstValueDic
//                                           md5:(NSString *)md5
//{
//    NSMutableArray *datas = [[NSMutableArray alloc] init];
//    
//    for(WSAcvtBean_qst* qst in acvtBean.qsts)
//    {
//        NSString *key = [NSString stringWithFormat:@"%@%@",qst.qstType, qst.acvtQstId];
//        
//        NSString *value;
//        NSString *titleType;
//        NSString *newStoreId;
//        
//        if([qst.qstType isEqualToString:QST_TYPE_BN]){
//            value = qst.defaultValue;
//            titleType = qst.isAcvtName;
//            if (storeBean) {
//                newStoreId = storeBean.Id;
//            }
//        }
//        else if ([qst.qstType isEqualToString:QST_TYPE_GE] ||
//                 [qst.qstType isEqualToString:QST_TYPE_GF] ){
//            NSDictionary *resultDic = [qstValueDic objectForKey:key];
//
//            // GE 插入数据库的是address  上传的是 areaID
//            if (resultDic) {
//                value = [resultDic JSONString];
//            }
//        }
//        else if ([qst.qstType isEqualToString:QST_TYPE_AN] ||
//                 [qst.qstType isEqualToString:QST_TYPE_AM]){
//            
//            id resultObj = [qstValueDic objectForKey:key];
//            
//            if (resultObj) {
//                if ([resultObj isKindOfClass:[NSString class]]) {
//                    value = resultObj;
//                }else if ([resultObj isKindOfClass:[NSArray class]]) {
//                    value = [resultObj JSONString];
//                }
//            }
//        }
//        else
//        {
//            value = [qstValueDic objectForKey:key];
//            titleType = qst.isAcvtName;
//            if (storeBean) {
//                newStoreId = storeBean.Id;
//            }
//        }
//        
//        if (value) {
//            NSMutableArray* qstDatas = [[NSMutableArray alloc] init];
//            [qstDatas addObject:md5];
//            [qstDatas addObject:qst.acvtQstId];
//            [qstDatas addObject:value];
//            [qstDatas addObject:value];
//            [qstDatas addObject:qst.qstType];
//            [qstDatas addObject:titleType ? titleType : [NSNull null]];
//            [qstDatas addObject:newStoreId ? newStoreId : [NSNull null]];
//            [qstDatas addObject:acvtBean.acvtId];
//            
//            [datas addObject:qstDatas];
//        }
//        
//    }
//    
//    LogInfo(@"insert: %@", datas);
//    
//    return [[WSAddStoreQstTable sharedTable] insertOrReplaceStoreQstInfo:datas];
//}
//
//+ (BOOL)updateNestedAcvtWithFuncs:(WSFuncsBean *)funcsBean acvtBean:(WSAcvtBean *)acvtBean andMd5:(NSString *)md5
//{
//    
//    for (WSAcvtBean_qst* ab_qst in acvtBean.qsts) {
//        if ([ab_qst.qstType isEqualToString:QST_TYPE_AN]
//            && ab_qst.acvtNestedId
//            && [ab_qst.acvtNestedId length] > 0) {
//            BOOL updateAcvtInfoIsSucced = [[WSFacTable sharedTable] upadteAcvtInfo:funcsBean andStoreId:md5 NestedAcvtId:[NSString stringWithValue:ab_qst.acvtNestedId]];
//            if (!updateAcvtInfoIsSucced) {
//                return updateAcvtInfoIsSucced;
//            }
//        }
//    }
//    return YES;
//}

@end

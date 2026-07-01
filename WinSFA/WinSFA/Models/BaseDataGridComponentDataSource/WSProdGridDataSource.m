//
//  WSProdGridDataSource.m
//  WinSFA
//
//  Created by Alicia on 2018/7/3.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSProdGridDataSource.h"
#import "WSFptTable.h"
#import "WSBaseProductDBService.h"
#import "WSBaseDictsDBService.h"
#import "WSBaseStoreDBService.h"
#import "WSBaseStoreProddisDBService.h"
#import "WSDataSourceManager.h"
#import "WSBaseModel.h"

@implementation WSProdGridDataSource

/*
- (NSArray *)getDataSourceByMd5:(NSString *)md5 brandId:(NSString *)brandId pType:(NSString *)pType funcs:(WSFuncsBean *)funcs store:(WSStoreBean *)store acvtId:(NSString *)acvtId qstId:(NSString *)qstId {
    
    NSArray *data = [super getDataSourceByMd5:md5 brandId:brandId pType:pType funcs:funcs store:store acvtId:acvtId qstId:qstId];
    
    // 除了分销规则外的服务器回显数据，从 WSBaseDataGridComponentDataSource 中挪过来的逻辑，应该没有用
    NSArray *unknown = [self getProdServerDatasByMd5:md5 funcs:funcs store:store];
    if ([question count] > 0) {
        NSLog(@"不知道之前调用这个做什么用，记录下这里什么时候会进入");
    }
    return data;
}
*/

- (NSArray *)getLocalDatasByMd5:(NSString *)md5 funcs:(WSFuncsBean *)funcs store:(WSStoreBean *)store qstId:(NSString *)qstId {
    NSArray *dataSource = nil;
    NSArray *dataBaseDatas = [self getDataBaseDatasByMd5:md5 funcs:funcs store:store qstId:qstId];
    if ([dataBaseDatas count] > 0) {
        NSArray *fptObjects = [[WSFptTable sharedTable] queryWithNames:@[@"IMG_IDX"] ArgumentsValue:@[[NSString stringNotNilWithValue:md5]]];
        if ([fptObjects count] > 0) {
            NSArray *prodIds = [dataBaseDatas valueForKeyPath:@"self.prod_id"];
            
            WSBaseProductDBService *baseProdctDBService = [[WSBaseProductDBService alloc] init];
            dataSource = [baseProdctDBService queryProductByIds:prodIds appendprop:funcs.opt.appendprop]; //SFA-14624 2017-11-28
        }
    }
    
    // YIHAIKERRY-4223 【IOS】添加几个产品下单保存或提交后，再次进入单据查看，产品的顺序与下单时的产品顺序不一致
    //    NSArray *resultArray = dataSource;
    
    NSMutableArray *resultArray;
    if (dataBaseDatas .count > 0) {
        resultArray = [NSMutableArray new];
        for (int i = 0; i < dataBaseDatas.count;  i++) {
            
            WSProductObject *tmpObject = [dataBaseDatas objectAtIndex:i];
            NSString *proPId = tmpObject.prod_id ;
            
            for (int j = 0; j < dataSource.count; j ++ ) {
                
                WSProdBean *tmpBean = [dataSource objectAtIndex:j];
                NSString *proId = tmpBean.Id ;
                
                if ([proId isEqualToString:proPId]) {
                    [resultArray addObject:tmpBean];
                    break;
                }
            }
            
        }
    }
    
    return resultArray;

}


- (NSArray *)getDataBaseDatasByMd5:(NSString *)md5 funcs:(WSFuncsBean *)funcs store:(WSStoreBean *)store qstId:(NSString *)qstId {
    WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
    if (model.isFromRealTimeData) {
        return nil;
    }
    
    NSArray *l_array = [[NSArray alloc] init];
    
    if (qstId) {
        l_array = [[WSFptTable sharedTable] queryAcvtDataGridPannelProductWithGenId:md5];
        
    } else if (store.Id) {
        NSString * srid;
        if ([store.srid length] > 0) {
            srid = store.srid;
        }
        NSString *title = md5;
        if (title && title.length > 0) {
            l_array = [[WSFptTable sharedTable] queryProductWithStoreId:store.Id fc:funcs.fc title:title andSrid:store.srid];
        } else {
            l_array = [[WSFptTable sharedTable] queryProductWithStoreId:store.Id fc:funcs.fc title:nil andSrid:srid];
        }
    }
    return l_array;
}

- (NSArray *)getServerDatasByMd5:(NSString *)md5 brandId:(NSString *)brandId pType:(NSString *)pType funcs:(WSFuncsBean *)funcs store:(WSStoreBean *)store qstBean:(WSAcvtBean_qst *)qstBean{
    NSString *idStr = [self getIdStrByStore:store];
    WSBaseProductDBService *baseProductDBSerice = [[WSBaseProductDBService alloc] init];
    NSArray *dataSourceNormal = [baseProductDBSerice queryProductsWithStoreId:idStr brand:brandId pType:pType params:funcs.paramArray appendprop:funcs.opt.appendprop];
    return dataSourceNormal;
}

- (NSMutableArray *)getMoreProductArrayByBrandId:(NSString *)brandId pType:(NSString *)pType funcs:(WSFuncsBean *)funcs store:(WSStoreBean *)store filterProdIdArray:(NSArray *)filterProdIdArray {
    NSString *idStr = [self getIdStrByStore:store];
    WSBaseProductDBService *baseProductDBSerice = [[WSBaseProductDBService alloc] init];
    NSArray *moreArray = [baseProductDBSerice queryMoreProductsWithStoreId:idStr brand:brandId pType:pType params:funcs.paramArray appendprop:funcs.opt.appendprop filterProdIdArray:filterProdIdArray];
    return [NSMutableArray arrayWithArray:moreArray];
}

/*
- (NSArray *)getProdServerDatasByMd5:(NSString *)md5 funcs:(WSFuncsBean *)funcs store:(WSStoreBean *)store {
    //Note: 检测是否存在funccode，如果存在返回index，index == -1标示不存在。
    NSInteger fcIndex = -1;
    NSArray* spec = [WSAppData getObjectbyKey:PRODSPECDIS];
    if (!spec || [spec count] < 1) {
        spec = [WSAppData getObjectbyKey:PRODSPEC];
    }
    NSUInteger tmp = [spec indexOfObject:@"funccode"];
    if (NSNotFound != tmp) {
        fcIndex = tmp;
    }
    WSBaseProductDBService *baseProductDBSerice = [[WSBaseProductDBService alloc] init];
    
    NSString *funcCode = nil;
    if (fcIndex > -1) {
        funcCode = funcs.fc;
    }
    NSString *storeId = store.Id ?:@"-1";
    NSString *drId = store.drId ?: @"-1";
    NSArray *dataSourceServer = [baseProductDBSerice queryRedisBrandSortProductWithFuncCode:funcCode StoreId:storeId drId:drId  genId:nil brand:funcs.filter params:funcs.paramArray isUseDistributionRules:YES appendprop:funcs.opt.appendprop];
    
    if (!dataSourceServer || dataSourceServer.count < 1) {
        if (storeId.length > 0 && [storeId isEqualToString:@"-1"]) {
            dataSourceServer = [baseProductDBSerice queryRedisBrandSortProductWithFuncCode:funcCode StoreId:storeId drId:drId  genId:nil brand:funcs.filter params:funcs.paramArray isUseDistributionRules:NO appendprop:funcs.opt.appendprop];
        }
    }
    return dataSourceServer;
}
*/


- (NSString *)getIdStrByStore:(WSStoreBean *)store {
    NSString *idStr = [store.drId length] > 0 ? store.drId : store.Id;
    if (!idStr) {
        WSBaseStoreDBService *baseStorDBService = [[WSBaseStoreDBService alloc] init];
        idStr = [baseStorDBService queryDrIdWithStoreId:@"-1"];
    }
    return idStr;
}

- (BOOL)isRedisMoreHomeByFuncs:(WSFuncsBean *)funcs {
    if ([funcs.opt.isRedisMoreHome isEqualToString:@"1"]) {
        return YES;
    }
    return NO;
}


- (NSArray *)getMoreRedisHomeDatasByMd5:(NSString *)md5 brandId:(NSString *)brandId funcs:(WSFuncsBean *)funcs store:(WSStoreBean *)store acvtId:(NSString *)acvtId qstId:(NSString *)qstId moreProductArray:(NSArray *)moreProductArray {

    NSMutableArray *prodArray = [NSMutableArray array];
    
    NSString *srid = nil;
    if ([store.srid length] > 0) {
        srid = store.srid;
    }
//    WSFptObject *fptObject = [[WSFptTable sharedTable] queryFPTWithStoreId:store.Id fc:funcs.fc title:md5 andSrid:srid];
    // PRODSPECDIS可能会有funccode
    // PRODSPECDIS 节点的服务端协议字段 sid,pid,funccode 【2014-09-28确认】
    BOOL haveFunc_code = YES;
    NSArray* spec = [WSAppData getObjectbyKey:PRODSPECDIS];
    if (!spec || [spec count] < 1) {
        haveFunc_code = NO;
        spec = [WSAppData getObjectbyKey:PRODSPEC];
    }
    
    WSBaseStoreProddisDBService *baseStoreProddisDBService = [[WSBaseStoreProddisDBService alloc] init];
    if ([self isRedisMoreHomeByFuncs:funcs]) {
        NSUInteger genidIndex = [spec indexOfObject:@"genid"];
        if(genidIndex != NSNotFound) {
            NSString *needValidateRedisValueParamColsStr = nil;
            //如果只有LNR类型的列有回显值，则不加入回显产品中。
            NSMutableArray *lnrParamArray = [NSMutableArray array];
            NSMutableArray *paramArrayWithoutLNR = [NSMutableArray array];
            for (WSFuncsBean_Param *param in funcs.paramArray) {
                if ([param.tpy isEqualToString:COL_TYPLNR] || [param.isRedisNoMoreHome isEqualToString:@"1"]) {
                    [lnrParamArray addObject:param];
                } else {
                    [paramArrayWithoutLNR addObject:param];
                }
                
                if (param.needValidateMoreProdRedisValue.length > 0 && [param.needValidateMoreProdRedisValue isEqualToString:@"1"]) {
                    if (needValidateRedisValueParamColsStr && needValidateRedisValueParamColsStr.length > 0) {
                        needValidateRedisValueParamColsStr = [NSString stringWithFormat:@"%@,%@", needValidateRedisValueParamColsStr, param.col];
                    } else {
                        needValidateRedisValueParamColsStr = [NSString stringWithFormat:@"%@", param.col];
                    }
                }
            }
            
            NSArray *proddiss = [baseStoreProddisDBService queryStoreProdDissWithStoreId:store.Id acvtId:acvtId qstId:qstId genId:md5 needValidateRedisValueParamCols:needValidateRedisValueParamColsStr];
            
            for (WSBaseStoreProdDisObject *sproddisObj in proddiss) {
                for (WSProdBean *moreProd in moreProductArray) {
                    if ([moreProd.Id isEqualToString:sproddisObj.prod_id]) {
                        //如果只有LNR类型的列有回显值，则不加入回显产品中。
                        BOOL isNeedRedis = NO;
                        if ([lnrParamArray count] > 0) {
                            isNeedRedis = [self isNeedRedisByParamArray:paramArrayWithoutLNR sproddisObj:sproddisObj isCheckGone:NO];
                        } else {
                            isNeedRedis = [self isNeedRedisByParamArray:funcs.paramArray sproddisObj:sproddisObj isCheckGone:YES];
                        }
                        if (isNeedRedis) {
                            [prodArray addObject:moreProd];

                        }
                        break;
                    }
                }
            }
        } else  {
            NSArray *baseStoreProddiss = [baseStoreProddisDBService queryStoreProdDissWithStoreId:store.Id];
            //mark:::basestorepriddis表中的store_id 就是指门店id，baseinstoreprod表中的store_id 指的是分销规则id
            for ( WSProdBean *moreProd in moreProductArray) {
                for (WSBaseStoreProdDisObject *bspDisObj in baseStoreProddiss) {
                    NSString *bspProd_id = bspDisObj.prod_id;
                    if ([bspProd_id isEqualToString:moreProd.Id]) {
                       
                        for (WSFuncsBean_Param *param  in funcs.paramArray) {
                            BOOL showServiceData = NO;
                            if ([self serverRedisWith:param]) {
                                showServiceData = YES;
                            } else {
                                LogInfo("因为更多产品的服务端数据回显功能关闭，以至于不能查找服务端下发数据，所以无法回显在首页。");
                            }
                            if ([param.tpy isEqualToString:COL_TYPLNR] || [param.isRedisNoMoreHome isEqualToString:@"1"]) {
                                showServiceData = NO;
                                LogInfo(@"更多产品的LNR采集项类型不作为回显首页的条件。");
                            }
                            
                            if (showServiceData) {
                                NSString *itemValue = nil;
                                if (haveFunc_code) {
                                    if ([bspDisObj.funccode length] > 0) {
                                        if ([bspDisObj.funccode isEqualToString:funcs.fc]) {
                                            itemValue = [bspDisObj valueForKey:param.col];
                                            itemValue = [itemValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                        }
                                    }else {
                                        itemValue = [bspDisObj valueForKey:param.col];
                                        itemValue = [itemValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                    }
                                } else if(!haveFunc_code){
                                    itemValue = [bspDisObj valueForKey:param.col];
                                    itemValue = [itemValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                }
                                if ([itemValue length] > 0
                                    && ![itemValue isEqualToString:@"null"] && (![param.gone isEqualToString:@"1"])) {
                                    [prodArray  addObject:moreProd];
                                    break;
                                }
                            }
                        }
                    }
                }
            }
            
        }
    }
    // needRepeatProd 为NO时 产品需要去重 YIHAIKERRY-4919
    prodArray = [self removeRepeatProdWith:prodArray funcs:funcs];
    
    return [prodArray copy];
}
- (NSMutableArray *)removeRepeatProdWith:(NSMutableArray *)prodArray funcs:(WSFuncsBean *)funcs {
    // YIHAIKERRY-4919 产品去重 与安卓统一逻辑  2018/11/30 zhangmin
    if (![funcs.opt.needRepeatProd isEqualToString:@"1"]) {
        NSMutableArray *tempProds = [NSMutableArray array];
        NSMutableArray *tempIds = [NSMutableArray array];
        
        for (int i = 0 ; i < prodArray.count; i ++) {
            WSProdBean *prodBean = prodArray[i];
            if (![tempIds containsObject:prodBean.Id] ) {
                [tempProds addObject:prodBean];
                [tempIds addObject:prodBean.Id];
            }
        }
        return  tempProds;
        
    }else {
        return prodArray;
    }
}


- (BOOL)isNeedRedisByParamArray:(NSArray *)paramArray sproddisObj:(WSBaseStoreProdDisObject *)sproddisObj isCheckGone:(BOOL)isCheckGone {
    BOOL isNeedRedis = NO;
    for (WSFuncsBean_Param *param in paramArray) {
        NSString *valueString = [sproddisObj valueForKey:param.col];
        valueString = [valueString stringByTrimmingWhitespace];
        
        if (isCheckGone) {
            if ([valueString length] > 0 && ![param.gone isEqualToString:@"1"]) {
                isNeedRedis = YES;
                break;
            }
        }else {
            if ([valueString length] > 0) {
                isNeedRedis = YES;
                break;
            }
        }
        
    }
    return isNeedRedis;
}
- (NSArray *)getServerRedisDatasByMd5:(NSString *)md5 brandId:(NSString *)brandId pType:(NSString *)pType funcs:(WSFuncsBean *)funcs store:(WSStoreBean *)store qstBean:(WSAcvtBean_qst *)qstBean{
    NSString *idStr = [self getIdStrByStore:store];
    WSBaseProductDBService *baseProductDBSerice = [[WSBaseProductDBService alloc] init];
    NSArray *dataSourceNormal = [baseProductDBSerice queryServerRedisProductsWithStoreId:idStr brand:brandId pType:pType params:funcs.paramArray appendprop:nil fc:funcs.fc md5:md5 store_id:store.Id];
    return dataSourceNormal;
}

@end

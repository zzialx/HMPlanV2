//
//  WSBaseDataGridComponentDataSource.m
//  WinSFA
//
//  Created by HZH on 17/3/17.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSBaseDataGridComponentDataSource.h"
#import "WSBaseDictsDBService.h"
#import "WSAcvtModel.h"
#import "WSCurrentTime.h"
#import "WSBaseStoreProdDisTable.h"
#import "WSBaseGridDataSource.h"
#import "WSProdGridDataSource.h"
#import "WSDictGridDataSource.h"
#import "WSGridWidget.h"

#define kSortSeparator @"[@]"

@implementation WSBaseDataGridComponentDataSource
@synthesize currentQst = _currentQst;
@synthesize currentTableItem = _currentTableItem;
@synthesize currentFunc = _currentFunc;
@synthesize currentStore = _currentStore;
@synthesize dataSource = _dataSource;

- (id)initWithStore:(WSStoreBean *)aStore func:(WSFuncsBean *)aFunc ownViewController:(BaseViewController *)aViewController
andCurrentTableItem:(WSTableItem *)currentTableItem {
    
    return [self initWithStore:aStore func:aFunc ownViewController:aViewController andCurrentTableItem:currentTableItem andBrandId:nil];
}

- (id)initWithStore:(WSStoreBean *)aStore func:(WSFuncsBean *)aFunc ownViewController:(BaseViewController *)aViewController
andCurrentTableItem:(WSTableItem *)currentTableItem andBrandId:(NSString *)brandId {
    
    self = [super init];
    if (self) {
        
        if (brandId.length > 0) {
            _brandId = brandId;
        }
        
        self.addedEditingProds = [[NSMutableArray alloc] init];
        self.lastSelectedSerieProdsCount = 0;
        _dataSourceCache = [NSMutableDictionary dictionary];
        _currentStore = aStore;
        _currentFunc = aFunc;
        _currentTableItem = [[WSTableItem alloc] initWithFuncsBean:_currentFunc];
        
        NSString *needSelect = self.currentTableItem.opt.needSelect;
        if (needSelect && [needSelect isKindOfClass:[NSString class]] && [needSelect length] > 0) {
            self.needSelect = YES;
        }
        
        _ownViewController = aViewController;
        _checkBoxesArrayOfHeaderView = [NSMutableArray arrayWithCapacity:1];
        _m_moreProdsCount = 0;
        
        self.md5 = [self getGridMd5];
        [self resetPTypeAndBrandId];
        [self initDataSource];
    }
    return self;
}

- (void)initDataSource {
    
    [self initBaseDataSourceNew];
    [self setupNeedShowMoreButton];
    [self sortByParam];
}

- (void)setupNeedShowMoreButton {
    
    if ([_currentTableItem.ds isEqualToString:DS_PROD] || [_currentTableItem.ds isEqualToString:DS_PRODC]) {
        
        if ([self.moreProductArray count] == 0) {
            self.isNeedShowMoreButton = NO;
        }
        else if ([self.currentTableItem.opt.isMore isEqualToString:@"0"]) {
            self.isNeedShowMoreButton = NO;
        }
        else {
            self.isNeedShowMoreButton = YES;
        }
    }
    else {
        self.isNeedShowMoreButton = NO;
    }
}

- (void)initBaseDataSourceNew {
    
    BOOL isProduct = NO;
    if ([self.currentTableItem.ds isEqualToString:DS_PROD] || [self.currentTableItem.ds isEqualToString:DS_PRODC]) {
        
        self.gridDataSource = [[WSProdGridDataSource alloc] init];
        isProduct = YES;
    }
    else if ([self.currentTableItem.ds isEqualToString:DICTS]) {
        
        self.gridDataSource = [[WSDictGridDataSource alloc] init];
    }
    
    _m_DataBaseDatas = [self.gridDataSource getDataBaseDatasByMd5:[self getGridMd5] funcs:self.currentFunc store:self.currentStore
                                                            qstId:self.currentQst.acvtQstId];
    _dataSource = [self.gridDataSource getDataSourceByMd5:[self getGridMd5] brandId:self.brandId pType:self.pType
                                                    funcs:self.currentFunc store:self.currentStore
                                                   acvtId:self.model.currentAcvtBean.acvtId qstBean:self.currentQst];
    
    if ([self.currentFunc.opt.mOrderByDis isEqualToString:@"1"]) {
        
        if (_dataSource.count == 0) {
                
            self.dataSource = nil;
            
            NSString *genIdSql = [NSString stringWithFormat:@"select bsad.acvt_qst_answer as genid from base_store_acvt_dis bsad where bsad.sid = '%@' and bsad.acvtid = '%@' and bsad.acvtqstid = '%@' and gen_id is null", self.currentStore.Id, self.model.currentAcvtBean.acvtId, self.currentQst.acvtQstId];
            NSArray *dataArray = [[WSBaseStoreProdDisTable sharedTable] queryAndReturnInfosBySql:genIdSql andClassName:@"WSBaseStoreProdDisObject"];
            WSBaseStoreProdDisObject *obj = [dataArray firstObject];
            NSString *tempGenId = obj.genid;
            
            if (!tempGenId || tempGenId.length == 0) {
                
                tempGenId = self.model.updateGenId;
                if ([self.ownViewController.currentFuncs.opt.sendRequest isEqualToString:@"remote"] && [tempGenId length] > 0) {
                    tempGenId = self.model.md5;
                }
            }

            NSArray *prouctList = [self.gridDataSource getServerRedisDatasByMd5:tempGenId brandId:self.brandId pType:self.pType funcs:self.currentFunc
                                                                          store:self.currentStore qstBean:self.currentQst];
            self.dataSource = prouctList;
        }
        
        if (!self.needSelect && isProduct) {
            
            NSArray *prodIdArray = [_dataSource valueForKeyPath:@"self.Id"];
            if ([self isNeedRepeatProd]) {
                prodIdArray = nil;
            }
            
            WSProdGridDataSource *prodGridDataSource = ((WSProdGridDataSource *)self.gridDataSource);
            self.moreProductArray = [prodGridDataSource getMoreProductArrayByBrandId:self.brandId pType:self.pType
                                                                               funcs:self.currentFunc store:self.currentStore
                                                                   filterProdIdArray:prodIdArray];
        }
        return;
    }
    
    if (!self.needSelect && isProduct) {
        
        NSArray *prodIdArray = [_dataSource valueForKeyPath:@"self.Id"];
        if ([self isNeedRepeatProd]) {
            prodIdArray = nil;
        }
        
        WSProdGridDataSource *prodGridDataSource = ((WSProdGridDataSource *)self.gridDataSource);
        self.moreProductArray = [prodGridDataSource getMoreProductArrayByBrandId:self.brandId pType:self.pType
                                                                           funcs:self.currentFunc store:self.currentStore
                                                               filterProdIdArray:prodIdArray];
    }
    
    if (isProduct && [_m_DataBaseDatas count] == 0) {
        
        NSString *tempGenId = self.model.updateGenId;
        if ([self.ownViewController.currentFuncs.opt.sendRequest isEqualToString:@"remote"] && [tempGenId length] > 0) {
            tempGenId = self.model.md5;
        }
        
        WSProdGridDataSource *prodGridDataSource = ((WSProdGridDataSource *)self.gridDataSource);
        NSArray *prodArray = [prodGridDataSource getMoreRedisHomeDatasByMd5:tempGenId brandId:self.brandId
                                                                      funcs:self.currentFunc store:self.currentStore
                                                                     acvtId:self.model.currentAcvtBean.acvtId
                                                                      qstId:self.currentQst.acvtQstId
                                                           moreProductArray:self.moreProductArray];

        if (![self isNeedRepeatProd]) {
            
            NSArray *queryRedisMoreProductIds = [prodArray valueForKeyPath:@"@distinctUnionOfObjects.Id"];
            NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"NOT (SELF.Id in %@)", queryRedisMoreProductIds];
            self.moreProductArray = [NSMutableArray arrayWithArray:[self.moreProductArray filteredArrayUsingPredicate:thePredicate]];
        }
        
        NSMutableArray *dataSource = [NSMutableArray arrayWithArray:prodArray];
        [dataSource addObjectsFromArray:self.dataSource];
        self.dataSource = (NSArray *)dataSource;
    }
}


- (void)sortByParam {
    // 根据表格param重新排序
    WSFuncsBean_Param *sortParam = [self getNewSortParam];
    if (sortParam) {
        [self reSortDataSourceWithSortParam:sortParam];
    }
}

- (WSFuncsBean_Param *)getNewSortParam {
    WSFuncsBean_Param *sortParam = nil;
    for (WSFuncsBean_Param *param in self.currentTableItem.paramArray) {
        if (param.sort > 0) {
            sortParam = param;
            break;
        }
    }
    return sortParam;
}

- (void)resetPTypeAndBrandId {
    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
    NSString *brand = _brandId;
    
    if (!brand || brand.length <= 0) {
        brand = [service queryBrandIdByFilter:self.currentTableItem.filter searchQuestion:self.currentTableItem.opt.searchQuestion];
    }
    NSString *pType = nil;
    
    // 安卓逻辑。如果filter配置为1或者2的话filter不能作为pType
    if (([brand length] == 0 || brand == nil) &&
        (![self.currentFunc.filter isEqualToString:@"1"]) && (![self.currentFunc.filter isEqualToString:@"2"])) {
        pType = self.currentTableItem.filter;
    }
    
    if (pType == nil || [pType length] == 0) {
        NSString *dsStr = self.currentTableItem.ds;
        if ([dsStr isEqualToString:DS_PRODC]) {
            pType = @"2";
        }else if ([dsStr isEqualToString:DS_PROD]) {
            pType = @"1";
        }
    }
    self.pType = pType;
}

// WRIGLEY-1546 主线 订单排序（箭牌新增排序规则）
- (void)reSortDataSourceWithSortParam:(WSFuncsBean_Param *)sortParam {
    NSInteger l_dataSourcesCount = [self.dataSource count];
    NSInteger startPosition = 0;
    if(self.m_moreProdsCount > 0)
        startPosition = l_dataSourcesCount - self.m_moreProdsCount;
    if(self.m_moreProdsCount == NONEEXIST)
        startPosition = l_dataSourcesCount;
    
    NSMutableArray *nonShowValueArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *colValueIsSortDictionay = [[NSMutableDictionary alloc] init];
    
    for (NSInteger i = startPosition; i < l_dataSourcesCount; i++) {
        NSString *showValue = nil;
        /*修改为和安卓保持一致 若查处此表格有本地数据  则不考虑服务器回显数据*/
        if ([self.m_DataBaseDatas count] > 0) {
            showValue = [self getCurrentNativeValueWith:sortParam index:i widgetCacheKey:nil];
        } else {
            if ([self.gridDataSource serverRedisWith:sortParam]) {
                //见 WSBaseGrideViewController  服务端回显注释
                if (sortParam.ids && sortParam.ids.length >0) {
                    showValue = [self getCurrentViewIdsValueWith:sortParam index:i];
                }else{
                    showValue = [self getCurrentViewServerValueWith:sortParam index:i widgetCacheKey:nil];
                }
            }
        }
        if (sortParam.col.length > 0) {
            NSObject <I_W_OptionDataItem> *bean = [self.dataSource objectAtIndex:i];
            if (showValue && showValue.length > 0) {
                [colValueIsSortDictionay setObject:bean forKey:[NSString stringWithFormat:@"%@%@%@",  [bean getDataItemID], kSortSeparator, showValue]];
            } else {
                [nonShowValueArray addObject:bean];
            }
        }
    }
    
    NSArray *dataArray = [colValueIsSortDictionay allKeys];
    if ([dataArray count] > 0) {
        NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch | NSNumericSearch |
        NSWidthInsensitiveSearch | NSForcedOrderingSearch;
        
        NSComparator sortBlock = ^(NSString *string1, NSString *string2) {
            string1 = [self getShowValueByKey:string1];
            string2 = [self getShowValueByKey:string2];
            return [string2 compare:string1 options:comparisonOptions];
        };
        
        NSArray *sortedShowValueArray = [dataArray sortedArrayUsingComparator:sortBlock];
        NSMutableArray *tempDataSourceArray = [NSMutableArray arrayWithCapacity:self.dataSource.count];
        for (NSString *key in sortedShowValueArray) {
            id bean = [colValueIsSortDictionay objectForKey:key];
            [tempDataSourceArray addObject:bean];
        }
        if ([nonShowValueArray count] > 0) {
            [tempDataSourceArray addObjectsFromArray:nonShowValueArray];
        }
        self.dataSource = [tempDataSourceArray copy];
    }
}

- (NSString *)getShowValueByKey:(NSString *)key {
    NSArray *valueArray = [key componentsSeparatedByString:kSortSeparator];
    return valueArray[1];
}

- (NSString *)getGridMd5 {
    if (!self.md5 || [self.md5 length] < 1) {
        self.md5 = [self createGridMD5];
    }
    return self.md5;
}

- (NSString *)createGridMD5 {
    NSString *newMD5 = nil;
    
    if ([self.ownViewController isKindOfClass:[WSAcvtViewController class]]) {
        WSAcvtViewController *acvtViewController = (WSAcvtViewController *)self.ownViewController;
        NSString *storeid = self.currentStore.Id;
        if ([self.currentStore isKindOfClass:[WSStoreBean class]]) {
            if (self.currentStore.iStoreIdentify != nil) {
                storeid = self.currentStore.iStoreIdentify;
            }
        }
        NSString* l_dateStr;
        if ([(WSAcvtModel *)self.ownViewController.model needSoleTime]) {
            l_dateStr = [WSCurrentTime getDateTime];
        }else {
            l_dateStr = [WSCurrentTime getMD5TimeWithDataType:self.currentFunc.dateTyp];
        }
        newMD5 = [Md5Manager getMd5ByEmpId:[WSAppData getObjectbyKey:APPDATA_EMPID]
                                   sotreId:(storeid == nil) ? @"-1" : storeid
                                   bizDate:[WSAppData getObjectbyKey:APPDATA_BIZDATE]
                                  funcCode:self.currentTableItem.mc
                                    acvtId:acvtViewController.m_currentAcvt.acvtId
                                      memo:l_dateStr];
    } else {
        newMD5 = self.ownViewController.md5;
    }
    return newMD5;
}

- (NSString *)getCurrentViewIdsValueWith:(WSFuncsBean_Param *)aParam index:(NSInteger)aIndex {
    if ([self.currentTableItem.ds isEqualToString:DS_PROD] || [self.currentTableItem.ds isEqualToString:DS_PRODC]) {
        WSProdBean *prodBean = [self.dataSource objectAtIndex:aIndex];
        NSString *value = [NSString stringWithValue:[prodBean valueForKey:aParam.ids]];
        if (value && ![value isEqualToString:@"null"]) {
            return value;
        }
    }
    return nil;
}

- (NSString *)getCurrentNativeValueWith:(WSFuncsBean_Param *)aParam index:(NSInteger)aIndex widgetCacheKey:(NSString *)widgetCacheKey {
    // 支持添加相同数据到表格，则需要获取相同数据的 index
    NSString *dataIndex = nil;
    if ([widgetCacheKey rangeOfString:kKeyRepeatProdIdSeparator].location != NSNotFound) {
        NSArray *prodArray = [widgetCacheKey componentsSeparatedByString:kKeyProdIdColSeparator];
        if ([prodArray count] > 0) {
            dataIndex = prodArray[0];
            dataIndex = [dataIndex componentsSeparatedByString:kKeyRepeatProdIdSeparator][1];
        }
    }
    NSInteger currentIndex = -1;
    NSString *showValue = nil;
    for (NSObject <I_W_OptionDataItem> *object in self.m_DataBaseDatas) {
        NSString *itemId = [object getDataItemID];
        id <I_W_OptionDataItem> data = [self.dataSource objectAtIndex:aIndex];
        NSString *dataId = [data getDataItemID];
        
        if ([itemId isEqualToString:dataId]) {
            currentIndex++;
            if ([dataIndex length] > 0 && [dataIndex integerValue] != currentIndex) {
                continue;
            }
            NSString *value = [object valueForKey:aParam.col];
            if (value && ![value isEqualToString:@"null"]) {
                showValue = value;
            }
            break;
        }
    }
    return showValue;
}

- (NSString *)getCurrentViewServerValueWith:(WSFuncsBean_Param *)aParam index:(NSInteger)aIndex widgetCacheKey:(NSString *)widgetCacheKey {
    NSString *showValue = nil;
    if ([self.gridDataSource serverRedisWith:aParam]) {
        if ([self.currentTableItem.ds isEqualToString:DS_PROD] || [self.currentTableItem.ds isEqualToString:DS_PRODC]) {
            if (widgetCacheKey && [self respondsToSelector:@selector(getDefaultDataWithParam:OthersDict:)]) {
                NSDictionary *dict = @{@"data": [self.dataSource objectAtIndex:aIndex], @"widgetKey": widgetCacheKey};
                NSString *reDisplayText = [self performSelector:@selector(getDefaultDataWithParam:OthersDict:) withObject:aParam withObject:dict];
                if ([reDisplayText isKindOfClass:[NSString class]]) {
                    showValue = reDisplayText;
                }
            } else if ([self respondsToSelector:@selector(getDefaultDataWithParam:Others:)]) {
                NSString *reDisplayText = [self performSelector:@selector(getDefaultDataWithParam:Others:) withObject:aParam withObject:[self.dataSource objectAtIndex:aIndex]];
                if ([reDisplayText isKindOfClass:[NSString class]]) {
                    showValue = reDisplayText;
                }
            }
        }else if ([self.currentTableItem.ds isEqualToString:DICTS]){
            if ([self respondsToSelector:@selector(getDefaultDataWithParam:OthersDict:)]) {
                NSDictionary *dict = @{@"data": [self.dataSource objectAtIndex:aIndex], @"widgetKey": widgetCacheKey};
                
                NSString *reDisplayText = [self performSelector:@selector(getDefaultDataWithParam:OthersDict:) withObject:aParam withObject:dict];
                if ([reDisplayText isKindOfClass:[NSString class]]) {
                    showValue = reDisplayText;
                }
            }
        }
    }
    return showValue;
}

// about more production
- (BOOL)isNeedRepeatProd {
    return [self.currentFunc.opt.needRepeatProd isEqualToString:@"1"] ? YES : NO;
}
@end


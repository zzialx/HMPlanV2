//
//  WSAcvtDataGridComponentService.m
//  WinSFA
//
//  Created by ZhengJiepeng on 13-7-29.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import "WSAcvtDataGridComponentService.h"
#import "WSAcvtDataGridComponentView.h"
#import "WSAcvtDataGridComponentDataSource.h"
#import "WSTAAcvtDataGridComponentDataSource.h"

#import "WSCurrentTime.h"
#import "WSAppData.h"
#import "WSFptTable.h"
#import "WSProdBean.h"
#import "WSFuncsBean_Param.h"
#import "WSFdtTable.h"
#import "WSCheckBox.h"
#import "WSDataSourceManager.h"
#import "WSAcvtModel.h"
#import "GetMD5byStr.h"
#import "WSAddNewAcvtModel.h"

#import "WSAddAcvtTable.h"
#import "WSGridWidget.h"

#import "WSDropListView.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSAcvtDBService.h"
#import "WSBaseDictsDBService.h"

@implementation WSAcvtDataGridComponentService

+ (BOOL)insertDataToTableWithWSAcvtDataGridComponentView:(WSAcvtDataGridComponentView *)aWSAcvtDataGridComponentView {
    WSAcvtDataGridComponentDataSource *acvtDataSource = [aWSAcvtDataGridComponentView getAcvtDataSource];
    NSString *title = nil;
    if (acvtDataSource.ownViewController.md5
        && [acvtDataSource.ownViewController.md5 length] > 0) {
        title = [acvtDataSource.ownViewController.md5 copy];
    }
    if([acvtDataSource.currentTableItem.ds isEqualToString:DS_PROD] || [acvtDataSource.currentTableItem.ds isEqualToString:DS_PRODC]) {
        
        BOOL insertProdDataIsSucceed = [WSAcvtDataGridComponentService insertProdDataWithWSAcvtDataGridComponentView:aWSAcvtDataGridComponentView andTitle:title];
        if (!insertProdDataIsSucceed) {
            return insertProdDataIsSucceed;
        }
    } else if ([acvtDataSource.currentTableItem.ds isEqualToString:@"dicts"]) {
        BOOL insertDictDataIsSucceed = [WSAcvtDataGridComponentService insertDictDataWithWSAcvtDataGridComponentView:aWSAcvtDataGridComponentView andTitle:title];
        if (!insertDictDataIsSucceed) {
            return insertDictDataIsSucceed;
        }
    }
    return YES;
}

+ (BOOL)insertDataToTableWithWSAcvtDataGridComponentDataSource:(WSAcvtDataGridComponentDataSource *)acvtDataGridViewDataSource {
    
    NSString *title = nil;
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    title = [model.md5 copy];
    if([acvtDataGridViewDataSource.currentTableItem.ds isEqualToString:DS_PROD] || [acvtDataGridViewDataSource.currentTableItem.ds isEqualToString:DS_PRODC]) {

        BOOL insertProdDataIsSucceed = [WSAcvtDataGridComponentService insertProdDataWithWSAcvtDataGridComponentDataSource:acvtDataGridViewDataSource andTitle:title];
        if (!insertProdDataIsSucceed) {
            return insertProdDataIsSucceed;
        }
    } else if ([acvtDataGridViewDataSource.currentTableItem.ds isEqualToString:@"dicts"]) {
        
        BOOL insertDictDataIsSucceed =  [WSAcvtDataGridComponentService insertDictDataWithWSAcvtDataGridComponentDataSource:acvtDataGridViewDataSource andTitle:title];
        if (!insertDictDataIsSucceed) {
            return insertDictDataIsSucceed;
        }
    }
    return YES;
}


+ (BOOL)insertProdDataWithWSAcvtDataGridComponentDataSource:(WSAcvtDataGridComponentDataSource *)acvtDataGridDataSource andTitle:(NSString *)title
{
    
    NSString *md5 = [acvtDataGridDataSource getGridMd5];
    
    NSString *fv = nil;
    if (!acvtDataGridDataSource.ownViewController) {
        WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
        fv = model.currentFuncs.fv;
    }else {
        fv = acvtDataGridDataSource.ownViewController.currentFuncs.fv;
    }
    
    NSMutableArray *fptarray = [[NSMutableArray alloc] init];
    [fptarray addObject:acvtDataGridDataSource.currentTableItem.mc];
    [fptarray addObject:fv];
    [fptarray addObject:acvtDataGridDataSource.currentStore.plan ? @"1" : @"0"];
    [fptarray addObject:@"null"];
    
    NSString *storeId = nil;
    if (acvtDataGridDataSource.currentStore.Id.length > 0) {
        storeId = acvtDataGridDataSource.currentStore.Id;
    }else{
        storeId = @"-1";
    }

    [fptarray addObject:[NSString stringNotNilWithValue:storeId]];
    [fptarray addObject:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    [fptarray addObject:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    [fptarray addObject:[NSString stringNotNilWithValue:[WSCurrentTime getDateString]]];
    [fptarray addObject:@"0"];
    [fptarray addObject:[NSString stringNotNilWithValue:md5]];
    //启用 sr_id 字段
    NSString *srid = acvtDataGridDataSource.currentStore.srid && [acvtDataGridDataSource.currentStore.srid length] > 0 ? [acvtDataGridDataSource.currentStore.srid copy] : @"null";
    [fptarray addObject:srid];
    [fptarray addObject:@"null"];
    [fptarray addObject:@"null"];
    [fptarray addObject:@"null"];
    [fptarray addObject:@"null"];
    [fptarray addObject:@"null"];
    [fptarray addObject:@"null"];
    [fptarray addObject:@"null"];
    [fptarray addObject:@"null"];
    [fptarray addObject:@"null"];
    [fptarray addObject:@"null"];
    [fptarray addObject:@"null"];
    //title 字段被征用 保存TB表格父问卷的MD5
    if (title) {
        [fptarray addObject:title];
    }else{
        [fptarray addObject:@"null"];
    }
    
    NSMutableArray *prodsArray = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < [acvtDataGridDataSource.dataSource count]; i++) {
        NSDictionary *proDictionary = [self getProdDictionaryWithDataSource:acvtDataGridDataSource atIndex:i];
        if (proDictionary) {
            [prodsArray addObject:proDictionary];
        }
        
    }
    
    return [[WSFptTable sharedTable] insertWithFptArray:fptarray product:prodsArray isClear:acvtDataGridDataSource.isClear];
}

+ (BOOL)insertDictDataWithWSAcvtDataGridComponentDataSource:(WSAcvtDataGridComponentDataSource *)acvtDataGridComponentDataSource andTitle:(NSString *)title{

    NSString *md5 = [acvtDataGridComponentDataSource getGridMd5];
    
    NSString *fv = nil;
    if (!acvtDataGridComponentDataSource.ownViewController) {
        WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
        fv = model.currentFuncs.fv;
    }else {
        fv = acvtDataGridComponentDataSource.ownViewController.currentFuncs.fv;
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:acvtDataGridComponentDataSource.currentTableItem.mc];
    [array addObject:fv];
    NSString *isPlan = acvtDataGridComponentDataSource.currentStore.plan ? @"1" : @"0";
    [array addObject:isPlan];
    [array addObject:@""];
    
    NSString *storeIdStr = nil;
    if (acvtDataGridComponentDataSource.currentStore && acvtDataGridComponentDataSource.currentStore.Id) {
        if (acvtDataGridComponentDataSource.currentQst && acvtDataGridComponentDataSource.currentQst.acvtQstId){
            storeIdStr = [NSString stringWithFormat:@"%@_%@", acvtDataGridComponentDataSource.currentStore.Id, acvtDataGridComponentDataSource.currentQst.acvtQstId];
        }else {
            storeIdStr = acvtDataGridComponentDataSource.currentStore.Id;
        }
    }else if (acvtDataGridComponentDataSource.currentQst && acvtDataGridComponentDataSource.currentQst.acvtQstId){
        storeIdStr = acvtDataGridComponentDataSource.currentQst.acvtQstId;
    }
    [array addObject:storeIdStr];
    id empid = [WSAppData getObjectbyKey:APPDATA_EMPID] ;
    [array addObject:empid];
    id bizdate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    [array addObject:bizdate];
    [array addObject:[WSCurrentTime getDateString]];
    [array addObject:@"0"];
    [array addObject:md5];
    //启用 sr_id 字段
    NSString *srid = (acvtDataGridComponentDataSource.currentStore.srid && [acvtDataGridComponentDataSource.currentStore.srid length] > 0 ) ? [acvtDataGridComponentDataSource.currentStore.srid copy] : @"null";
    [array addObject:srid];
    //memo0-mem10暂时没有使用
    if([array count] == 11){
        for (int i=0 ; i< 11; i++) {
            [array addObject:@"null"];
        }
    }else{
        LogError(@"WSFdtTable 表 插入失败，插入值的数量和字段数量不匹配，需要特殊处理！ 插入值数量 = %lu" ,(unsigned long)[array count]);
        return NO;
    }
    
    if (title) {
        [array addObject:title];
    }else{
        [array addObject:@"null"];
    }
    
    NSMutableArray *dictsArray = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < [acvtDataGridComponentDataSource.dataSource count]; i++) {
        NSDictionary *proDictionary = [self getDictDictionaryWithDataSource:acvtDataGridComponentDataSource atIndex:i];
        [dictsArray addObject:proDictionary];
    }
    
    return [[WSFdtTable sharedTable] insertWithFdtArray:array Dict:dictsArray];
}

+ (BOOL)insertProdDataWithWSAcvtDataGridComponentView:(WSAcvtDataGridComponentView *)aWSAcvtDataGridComponentView andTitle:(NSString *)title
{
//    NSDate *bef = [NSDate date];
    WSAcvtDataGridComponentDataSource *acvtDataSource = [aWSAcvtDataGridComponentView getAcvtDataSource];
    
    NSString *md5 = [acvtDataSource getGridMd5];
    
    NSMutableArray *fptarray = [[NSMutableArray alloc] init];
    [fptarray addObject:acvtDataSource.currentTableItem.mc];
    [fptarray addObject:acvtDataSource.ownViewController.currentFuncs.fv];
    [fptarray addObject:acvtDataSource.currentStore.plan ? @"1" : @"0"];
    [fptarray addObject:@"null"];
    [fptarray addObject:[NSString stringNotNilWithValue:acvtDataSource.currentStore.Id]];
    [fptarray addObject:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    [fptarray addObject:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    [fptarray addObject:[NSString stringNotNilWithValue:[WSCurrentTime getDateString]]];
    [fptarray addObject:@"0"];
    [fptarray addObject:[NSString stringNotNilWithValue:md5]];
    //启用 sr_id 字段
    NSString *srid = acvtDataSource.currentStore.srid && [acvtDataSource.currentStore.srid length] > 0 ? [acvtDataSource.currentStore.srid copy] : @"null";
    [fptarray addObject:srid];
    [fptarray addObject:@"null"];
    [fptarray addObject:@"null"];
    [fptarray addObject:@"null"];
    [fptarray addObject:@"null"];
    [fptarray addObject:@"null"];
    [fptarray addObject:@"null"];
    [fptarray addObject:@"null"];
    [fptarray addObject:@"null"];
    [fptarray addObject:@"null"];
    [fptarray addObject:@"null"];
    [fptarray addObject:@"null"];
    //title 字段被征用 保存TB表格父问卷的MD5
    if (title) {
        [fptarray addObject:title];
    }else{
        [fptarray addObject:@"null"];
    }

    NSMutableArray *prodsArray = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < [acvtDataSource.dataSource count]; i++) {
        NSDictionary *proDictionary = [self getProdDictionaryWithDataSource:acvtDataSource atIndex:i];
        if (proDictionary) {
            [prodsArray addObject:proDictionary];
        }
        
    }
    
    return [[WSFptTable sharedTable] insertWithFptArray:fptarray product:prodsArray isClear:acvtDataSource.isClear];
}

+ (NSDictionary *)getProdDictionaryWithDataSource:(WSAcvtDataGridComponentDataSource *)aWSAcvtDataGridComponentDataSource atIndex:(NSInteger)aIndex {
    BOOL currentProdHasEditing = NO;
    BOOL currentProdHasChanged = NO;
    WSProdBean *prodBean = [aWSAcvtDataGridComponentDataSource.dataSource objectAtIndex:aIndex];
    NSArray *rowViewDatas = [aWSAcvtDataGridComponentDataSource.data objectAtIndex:aIndex];
    
    NSMutableDictionary *proDictionary = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < [aWSAcvtDataGridComponentDataSource.currentTableItem.paramArray count]; i++) {
        WSFuncsBean_Param *param = [aWSAcvtDataGridComponentDataSource.currentTableItem.paramArray objectAtIndex:i];
        WSGridWidget *gridWidget = [rowViewDatas objectAtIndex:i + 1];
        UIView *view = [gridWidget getView];
        
        if([view isKindOfClass:[WSHTextField class]]) {
            WSHTextField *textField = (WSHTextField*)view;
            NSString *value = textField.text;
            if (value) {
                [proDictionary setValue:textField.text forKey:param.col];
                if ([value length] > 0) {
                    currentProdHasEditing = YES;
                }
            }else {
                /*用于删除内容上传*/
                if ([textField  respondsToSelector:@selector(isValueChange)]) {
                    if ([textField isValueChange]) {
                        [proDictionary setValue:@"" forKey:param.col];
                        currentProdHasChanged = YES;
                    }
                }
            }
        } else if ([view isKindOfClass:[WSSelectListView class]]) {
            WSSelectListView *list = (WSSelectListView *)view;
            NSArray *valueArray = nil;
            
            if (list.selectMode == WSSelectListViewSelectModeSingleSelection) {
                NSString *value = [NSString string];
                if(list.selectedIndex>-1){
                    value = [list.content objectAtIndex:list.selectedIndex];
                    if ([value length] > 0) {
                        valueArray = [NSArray arrayWithObject:value];
                    }
                }
            }
            else if (list.selectMode == WSSelectListViewSelectModeMultipleChoice) {
                valueArray = [[list getSelectedContentString] componentsSeparatedByString:@","];
            }
            
            
            WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
            NSArray *filterArray = [service queryDictsForAcvtGridWithFilter:param.filter];
            
            NSMutableArray *dictIdArray = [NSMutableArray array];
            for (NSString *value in valueArray) {
                for (WSDictBean *db in filterArray)
                {
                    if ([db.name isKindOfClass:[NSString class]] && [db.name isEqualToString:value]) {
                        [dictIdArray addObject:db.Id];
                        break;
                    }
                }
            }
            
            if ([dictIdArray count] > 0) {
                [proDictionary setObject:[dictIdArray componentsJoinedByString:@","] forKey:param.col];
            }
            else if ([valueArray count] > 0) {
                [proDictionary setObject:[valueArray componentsJoinedByString:@","] forKey:param.col];
            }else if ([valueArray count] == 0) {
                if ([list respondsToSelector:@selector(isValueChange)]) {
                    if ([list isValueChange]) {
                        [proDictionary setValue:@"-1" forKey:param.col];
                    }
                }
            }
            
        }else if ([view isKindOfClass:[WSDropListView class]]){
            WSDropListView *list = (WSDropListView *)view;
            NSString *value = [list getResultDirectly];
            
            if (value) {
                [proDictionary setValue:value forKey:param.col];
                if ([value length] > 0) {
                    currentProdHasEditing = YES;
                }
            }else {
                /*用于删除内容上传*/
                if ([list  respondsToSelector:@selector(isValueChange)]) {
                    if ([list isValueChange]) {
                        [proDictionary setValue:@"" forKey:param.col];
                        currentProdHasChanged = YES;
                    }
                }
            }
        } else {
            NSString *value = [gridWidget getDBValue];
            if ([value length] > 0) {
                [proDictionary setValue:value forKey:param.col];
            }
        }
        
    }
    if (currentProdHasEditing) {
        
        BOOL isFoundProd = NO;
        for (NSInteger i = 0; i < [aWSAcvtDataGridComponentDataSource.addedEditingProds count] > 0; i++) {
            WSProdBean *tmpProdBean = [aWSAcvtDataGridComponentDataSource.addedEditingProds objectAtIndex:i];
            if (tmpProdBean.Id && prodBean.Id && [tmpProdBean.Id isEqualToString:prodBean.Id]) {
                [aWSAcvtDataGridComponentDataSource.addedEditingProds replaceObjectAtIndex:i withObject:prodBean];
                isFoundProd = YES;
                break;
            }
        }
        if (!isFoundProd) {
            [aWSAcvtDataGridComponentDataSource.addedEditingProds addObject:prodBean];
        }

    }
    else {
    
        /*对于选择品牌或者系列对应产品  如过没有编辑则词条数据不插入数据库*/
        if (aWSAcvtDataGridComponentDataSource.needSelect) {
            
            if (currentProdHasChanged) {
                for (NSInteger i = 0; i < [aWSAcvtDataGridComponentDataSource.addedEditingProds count] > 0; i++) {
                    WSProdBean *tmpProdBean = [aWSAcvtDataGridComponentDataSource.addedEditingProds objectAtIndex:i];
                    if (tmpProdBean.Id && prodBean.Id && [tmpProdBean.Id isEqualToString:prodBean.Id]) {
                        [aWSAcvtDataGridComponentDataSource.addedEditingProds removeObject:tmpProdBean];
                        break;
                    }
                }
            }else {
                 proDictionary = nil;
            }
        }
    }
    // MSTD-6863 按照安卓的逻辑如果没有数据的时候不上传
    if (proDictionary && [[proDictionary allKeys] count] == 0) {
        proDictionary = nil;
    } else {
        [proDictionary setValue:[aWSAcvtDataGridComponentDataSource getGridMd5] forKey:@"IDX"];
        [proDictionary setValue:prodBean.Id forKey:@"PROD_ID"];
    }
    
    return proDictionary;
}

+ (BOOL)insertDictDataWithWSAcvtDataGridComponentView:(WSAcvtDataGridComponentView *)aWSAcvtDataGridComponentView andTitle:(NSString *)title {
    WSAcvtDataGridComponentDataSource *acvtDataSource = [aWSAcvtDataGridComponentView getAcvtDataSource];
    
    NSString *md5 = [acvtDataSource getGridMd5];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:acvtDataSource.currentTableItem.mc];
    [array addObject:acvtDataSource.ownViewController.currentFuncs.fv];
    NSString *isPlan = acvtDataSource.currentStore.plan ? @"1" : @"0";
    [array addObject:isPlan];
    [array addObject:@""];

    NSString *storeIdStr = nil;
    if (acvtDataSource.currentStore && acvtDataSource.currentStore.Id) {
        if (acvtDataSource.currentQst && acvtDataSource.currentQst.acvtQstId){
            storeIdStr = [NSString stringWithFormat:@"%@_%@", acvtDataSource.currentStore.Id, acvtDataSource.currentQst.acvtQstId];
        }else {
            storeIdStr = acvtDataSource.currentStore.Id;
        }
    }else if (acvtDataSource.currentQst && acvtDataSource.currentQst.acvtQstId){
        storeIdStr = acvtDataSource.currentQst.acvtQstId;
    }
    [array addObject:storeIdStr];
    id empid = [WSAppData getObjectbyKey:APPDATA_EMPID];
    [array addObject:empid];
    id bizdate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    [array addObject:bizdate];
    [array addObject:[WSCurrentTime getDateString]];
    [array addObject:@"0"];
    [array addObject:md5];
    //启用 sr_id 字段
    NSString *srid = (acvtDataSource.currentStore.srid && [acvtDataSource.currentStore.srid length] > 0 ) ? [acvtDataSource.currentStore.srid copy] : @"null";
    [array addObject:srid];
    //memo0-mem10暂时没有使用
    if([array count] == 11){
        for (int i=0 ; i< 11; i++) {
            [array addObject:@"null"];
        }
    }else{
        LogError(@"WSFdtTable 表 插入失败，插入值的数量和字段数量不匹配，需要特殊处理！ 插入值数量 = %lu" ,(unsigned long)[array count]);
        return NO;
    
    }

    if (title) {
        [array addObject:title];
    }else{
        [array addObject:@"null"];
    }
    
    NSMutableArray *dictsArray = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < [acvtDataSource.dataSource count]; i++) {
        NSDictionary *proDictionary = [self getDictDictionaryWithDataSource:acvtDataSource atIndex:i];
        [dictsArray addObject:proDictionary];
    }
    
    return [[WSFdtTable sharedTable] insertWithFdtArray:array Dict:dictsArray];
}

+ (NSDictionary *)getDictDictionaryWithDataSource:(WSAcvtDataGridComponentDataSource *)aWSAcvtDataGridComponentDataSource atIndex:(NSInteger)aIndex {
    WSDictBean *dictBean = [aWSAcvtDataGridComponentDataSource.dataSource objectAtIndex:aIndex];
    NSArray *rowViewDatas = [aWSAcvtDataGridComponentDataSource.data objectAtIndex:aIndex];
    
    NSMutableDictionary *proDictionary = [[NSMutableDictionary alloc] init];
    [proDictionary setValue:[aWSAcvtDataGridComponentDataSource getGridMd5] forKey:@"IDX"];
    [proDictionary setValue:dictBean.Id forKey:@"DICT_ID"];
    for (int i = 0; i < [aWSAcvtDataGridComponentDataSource.currentTableItem.paramArray count]; i++) {
        WSFuncsBean_Param *param = [aWSAcvtDataGridComponentDataSource.currentTableItem.paramArray objectAtIndex:i];
        WSGridWidget *gridWidget = [rowViewDatas objectAtIndex:i + 1];
        UIView *view = [gridWidget getView];
       
        if ([view isKindOfClass:[WSSelectListView class]]){
            WSSelectListView *selectListView = (WSSelectListView *)view;
            if (selectListView.selectedIndex > 0) {
                NSString *selectStr = [selectListView.content objectAtIndex:selectListView.selectedIndex];
                [proDictionary setValue:selectStr forKey:param.col];
            }
        } else {
            NSString *value = [gridWidget getDBValue];
            if (value) {
                [proDictionary setValue:value forKey:param.col];
            }
        }
       
    }
    return proDictionary;
}


/*对于调查问卷问题作为列的表格 每一行相当于新增一个问卷 和安卓一致*/
+(BOOL)insertTATableDataToDBWithTAPanel:(WSTAAcvtDataGridViewPanel *)taPanel {
    
    NSObject *value = [taPanel getResultDirectly];

    
    WSAddNewAcvtModel *acvtModel = (WSAddNewAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    
    WSTAAcvtDataGridComponentDataSource *dataSource = (WSTAAcvtDataGridComponentDataSource *)taPanel.dataGridView.dataSource;
    for (NSInteger i = 0; i < [dataSource.data count]; i++) {
        
        WSAcvtBean_qst_opt *opt = (WSAcvtBean_qst_opt *)[dataSource.dataSource objectAtIndex:i];
        /*
         调查问卷问题作为列的表格 md5 为 acvtMode.md5加上 opt.optId生成
         */
        NSString *rowMd5 =[NSString md5:[NSString stringWithFormat:@"%@%@",acvtModel.md5,opt.optId]];
        
        if ([self checkAcvtExistOrNotWith:rowMd5]) {
            
            WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
            [service deleteLocalDataWithGenId:rowMd5];
        }
        
        // 直接从[taPanel getResultDirectly]中获取每一行的控件值（对应每行的MD5值）
        NSDictionary *rowValueDic = nil;
        
        for (NSDictionary *dic in (NSArray *)value) {
            if ([[dic objectForKey:@"id"] isEqualToString:rowMd5]) {
                rowValueDic = dic;
            }
        }
        
        BOOL rowHasValue = NO;
        NSMutableDictionary *row_json_data = [self getTATableRowDiconaryWith:dataSource atIndex:i andValueDic:rowValueDic];
        if ([[row_json_data allKeys] count]> 0) {
            rowHasValue = YES;
        }
        
        [row_json_data setObject:[NSString stringNotNilWithValue:rowMd5] forKey:@"id"];
        
        
         /*表格的行填写了数据则插入数据库，不填写则不插入*/
        if (rowHasValue) {
//            BOOL isSucceed = [[WSAddAcvtTable sharedTable] insertWithArgumentsValue:values];
            
            BOOL isSucceed = [WSAcvtDBService insertAcvtDatasToDBWithStore:acvtModel.currentStore newStoreBean:acvtModel.currentNewStore acvtBean:dataSource.relationAcvtBean qstValueDic:row_json_data qstValueDicKeyType:WSAcvtQstValueDicKeyTypeAcvtqstID funcCod:acvtModel.currentFuncs.fc md5:rowMd5];
            
            if (!isSucceed) {
                LogInfo(@"TA表格插入失败--%@",row_json_data);
                return isSucceed;
            }
        } else {
            LogInfo(@"此行对应的列没值，不进行插入工作");
        }
    }
    return YES;
}




+ (NSMutableDictionary *)getTATableRowDiconaryWith:(WSTAAcvtDataGridComponentDataSource *)dataSouce atIndex:(NSInteger)index andValueDic:(NSDictionary *)valueDic{

    NSMutableDictionary *rowDictionary = [NSMutableDictionary dictionary];
    for (NSInteger i = 0; i < [dataSouce.currentTableItem.paramArray count]; i++) {
        WSFuncsBean_Param *param = [dataSouce.currentTableItem.paramArray objectAtIndex:i];
        
        NSString *key = [NSString stringWithFormat:@"%@%@",param.tpy,param.mappingAcvtQstId];
        NSString *value = [valueDic objectForKey:key];
        if (value && [value length] > 0) {
            [rowDictionary setValue:value forKey:[NSString stringWithFormat:@"%@",param.mappingAcvtQstId]];
        }
    }
    return rowDictionary;
}

+ (BOOL)checkAcvtExistOrNotWith:(NSString *)md5 {
    BOOL exist = NO;
//    NSArray *names = [NSArray arrayWithObjects:@"MD5", nil];
//    NSArray *values = [NSArray arrayWithObjects:[NSString stringNotNilWithValue:md5], nil];
    
//    NSArray *queryResult = [[WSAddAcvtTable sharedTable] queryWithNames:names ArgumentsValue:values];
    
    WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
    NSArray *queryResult = [service queryAcvtQstDatasByGenId:md5];
    
    if ([queryResult count] > 0) {
        exist = YES;
    }
    return exist;
}

+ (BOOL)updateTATableUploadFlagWith:(NSArray *)widgets acvtNewStoreId:(NSString *)newsid {
    
    //！！问卷数据库表重构，与Android保持一致逻辑，去除WSAddStoreTable、WSAddAcvtTable、WSFacTable表，统一使用visit_store_acvt_data，不知道以下代码的具体用处，遇见问题时请根据实际情况修改
    
//    for ( WSWidget *widget in widgets) {
//        if ([widget isKindOfClass:[WSTAAcvtDataGridViewPanel class]]) {
//            WSTAAcvtDataGridViewPanel *taPanel = (WSTAAcvtDataGridViewPanel *)widget;
//            WSTAAcvtDataGridComponentDataSource *componentDataSource = (WSTAAcvtDataGridComponentDataSource *)taPanel.dataGridView.dataSource;
//            for (NSInteger i = 0; i < [componentDataSource.dataSource count]; i++) {
//                WSAcvtBean_qst_opt *qst_opt = [componentDataSource.dataSource objectAtIndex:i];
//                NSString *updateMd5 = [NSString md5:[NSString stringWithFormat:@"%@%@",[componentDataSource  getGridMd5],qst_opt.optId]];
//                [[WSAddAcvtTable sharedTable] updateWithNames:@[@"upload_flag"/*,@"acvt_newStoreid"*/] values:@[@"1"/*,newsid*/] whereName:@[@"md5"] whereValue:@[updateMd5]];
//            }
//            
//        }
//    }
    return YES;
}

@end

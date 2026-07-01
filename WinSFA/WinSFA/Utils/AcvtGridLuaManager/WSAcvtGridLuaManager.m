//
//  WSAcvtGridLuaManager.m
//  WinSFA
//
//  Created by Alicia on 2018/10/17.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSAcvtGridLuaManager.h"
#import "WSGridWidget.h"
#import "WSLuaScript.h"
#import "WSGridDropListView.h"
#import "WSFptTable.h"
#import "YYModel.h"
#import "NSDictionary+Additional.h"
#import "NSArray+SQL.h"


@interface WSAcvtGridLuaManager ()

@property (nonatomic, strong) WSAcvtDataGridComponentDataSource *dataSource;

@end

@implementation WSAcvtGridLuaManager

- (instancetype)initWithDataSource:(WSAcvtDataGridComponentDataSource *)dataSource {
    self = [super init];
    if (self) {
        _dataSource = dataSource;
    }
    return self;
}

#pragma mark - callGridMethodWithParams

// 获取表格产品名称及id拼接的字符串
- (NSString *)getGridRowIdAndNameArrayWithRowId:(NSString *)rowId col:colName param:(NSString *)qstCode {
    return [self getGridRowIdAndNameByQstCode:qstCode isIgnoreName:NO];
}

// 获取表格产品id转换字符串数组方法 qstCode:问题编码
- (NSString *)getGridRowIdArrayWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)qstCode {
    return [self getGridRowIdAndNameByQstCode:qstCode isIgnoreName:YES];
}

- (NSString *)getGridCellKeyAndValueArrayWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)paramStr {
    BOOL isNeedRepeatProd = [self.dataSource isNeedRepeatProd];
    NSMutableDictionary *prodIdDictionary = [NSMutableDictionary dictionary];
    
    NSString *namesAndIds = @"";
    if (rowId.length > 0) {
        NSArray *rowArray = [rowId componentsSeparatedByString:@","];
        for (NSString *tempRowId in rowArray) {
            NSArray *colArray = [colName componentsSeparatedByString:@","];
            for (NSString *tempColName in colArray) {
                namesAndIds = [self getNamesAndIdsWithColName:tempColName param:paramStr andRowId:tempRowId andOriginNameAndIdsStr:namesAndIds];
            }
        }
    } else {
        for (NSInteger i = 0 ; i < [self.dataSource.dataSource count]; i++) {
            NSObject <I_W_OptionDataItem> *object = self.dataSource.dataSource[i];
            NSString *tempRowId = [object getDataItemID];
            if (isNeedRepeatProd) {
                tempRowId = [WSGridWidget getGridWidgetKeyByRowId:tempRowId col:nil dictionary:prodIdDictionary];
            }
            
            NSArray *colArray = [colName componentsSeparatedByString:@","];
            for (NSString *tempColName in colArray) {
                namesAndIds = [self getNamesAndIdsWithColName:tempColName param:paramStr andRowId:tempRowId andOriginNameAndIdsStr:namesAndIds];
            }
        }
    }
    return namesAndIds;
}


- (NSString *)getValueWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)param {
    NSMutableString *valueStr = [NSMutableString string];
    NSArray *paramColArray = [colName componentsSeparatedByString:@","];
    for (int i = 0; i < paramColArray.count; ++i) {
        NSString *subParamCol = [paramColArray objectAtIndex:i];
        if (valueStr.length > 0) {
            [valueStr appendFormat:@"[#]%@",[self.dataSource getValueWithRowId:rowId col:subParamCol param:param]];
        } else {
            [valueStr appendString:[self.dataSource getValueWithRowId:rowId col:subParamCol param:param]];
        }
    }
    return valueStr;
}

- (NSString *)getValuePresentationWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)param {
    WSGridWidget *gridWidget = [self.dataSource getGridWidgetByRowId:rowId col:colName];
    return [gridWidget getValuePresentation];
}


- (NSString *)getColNameWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)param {
    if ([colName length] == 0) {
        LogError(@"paramCol is nil ");
        return @"";
    }
    for (NSInteger i = 0; i < [self.dataSource.currentTableItem.paramArray count]; i++) {
        WSFuncsBean_Param *param = self.dataSource.currentTableItem.paramArray[i];
        if ([param.col isEqualToString:colName]) {
            return param.name;
        }
    }
    return nil;
}

- (NSString *)getFillRowCountWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)param {
    // TODO: TEST
    NSInteger count = 0;
    WSGridWidget *gridWidget = [self.dataSource getGridWidgetByKey:kGridGroupText];
    for (NSString *key in [gridWidget getGridWidgetAllKeys]) {
        WSGridWidget *widget = [gridWidget getGridWidgetByKey:key];
        if ([colName isEqualToString:[widget m_col]] && [[widget getValue] length] > 0) {
            count++;
            break;
        }
    }
    return [NSString stringWithFormat:@"%ld",count];
}

- (void)setValueWithRowId:(NSString *)rowId col:(NSString *)paramCol param:(NSString *)value {
    [self.dataSource setValueWithRowId:rowId col:paramCol param:value];
}

- (NSString *)gridViewHasValueWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)param {
    // TODO: TEST
    NSArray *allKeys = [self.dataSource getGridWidgetAllKeys];
    for (NSString *key in allKeys) {
        WSGridWidget *gridWidget = [self.dataSource getGridWidgetByKey:key];
        NSString *value = [gridWidget getValue];
        if ([value length] > 0) {
            return @"1";
        }
    }
    return @"0";
}

- (void)setMaxValueWithRowId:(NSString *)rowId col:(NSString *)paramCol param:(NSString *)value {
    WSGridWidget *gridWidget = [self.dataSource getGridWidgetByRowId:rowId col:paramCol];
    [gridWidget setMaxValue:value];
}

- (void)setMinValueWithRowId:(NSString *)rowId col:(NSString *)paramCol param:(NSString *)value {
    WSGridWidget *gridWidget = [self.dataSource getGridWidgetByRowId:rowId col:paramCol];
    [gridWidget setMinValue:value];
}

- (void)setReadOnlyWithRowId:(NSString *)rowId col:(NSString *)paramCol param:(NSString *)value {
    [self.dataSource setReadOnlyWithRowId:rowId col:paramCol param:value];
}

- (void)setReadonlyWithRowId:(NSString *)rowId col:(NSString *)paramCol param:(NSString *)value {
    [self.dataSource setReadOnlyWithRowId:rowId col:paramCol param:value];
}


- (NSString *)checkRowRequireWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)param {
    NSArray *paramColArray = [colName componentsSeparatedByString:@","];
    if (!paramColArray || [paramColArray count] == 0) {
        LogError(@"paramCol is nil ");
        return @"";
    }
    BOOL isNeedRepeatProd = [self.dataSource isNeedRepeatProd];
    NSMutableDictionary *prodIdDictionary = [NSMutableDictionary dictionary];
    
    NSString *result = @"";
    for (NSInteger i = 0; i < [self.dataSource.dataSource count]; i++) {
        id <I_W_OptionDataItem> object = self.dataSource.dataSource[i];
        if ([object respondsToSelector:@selector(isDataItemRequired)]) {
            BOOL isRequired = [object isDataItemRequired];
            if (isRequired) {
                NSString *rowId = [object getDataItemID];
                if (isNeedRepeatProd) {
                    rowId = [WSGridWidget getGridWidgetKeyByRowId:rowId col:nil dictionary:prodIdDictionary];
                }
                
                for (NSString *paramCol in paramColArray) {
                    NSString *value = [self getValueWithRowId:rowId col:paramCol param:nil];
                    if ([value length] == 0) {
                        return [NSString stringWithFormat:@"%@:%@【%@】", NSLocalizedString(@"not_input_label", nil), [object getDataItemName], [self getColNameWithRowId:nil col:paramCol param:nil]];
                    }
                }
            }
        }
    }
    return result;
}

- (void)setTextColorWithRowId:(NSString *)rowId col:(NSString *)paramCol param:(NSString *)colorHexString {
    WSGridWidget *gridWidget = [self.dataSource getGridWidgetByRowId:rowId col:paramCol];
    [gridWidget setTextColorHexString:colorHexString];
}

// MMSH-3279 新增通过脚本设置产品表格第一列产品名称的颜色值
- (void)setItemTitleColorWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)param {
    // param是类似：8,FF00FF00|9,FF00FF00|的Id和色值拼接的字符串
    NSArray *tempParamSegArray1 = [param componentsSeparatedByString:@"|"];
    for (NSString *tempSegStr in tempParamSegArray1) {
        if (tempSegStr.length > 0) {
            NSArray *tempParamSegArray2 = [tempSegStr componentsSeparatedByString:@","];
            if (tempParamSegArray2.count > 1) {
                NSString *prodIdStr = [tempParamSegArray2 objectAtIndex:0];
                NSString *colorHexStr = [tempParamSegArray2 objectAtIndex:1];
                
                UIView *view = [self getGridFirstColViewWithRowId:prodIdStr dataSource:self.dataSource];
                if ([view isKindOfClass:[UILabel class]] && colorHexStr.length > 0) {
                    UILabel *label = (UILabel *)view;
                    label.textColor = [UIColor colorWithHexString:colorHexStr];
                }
            }
        }
    }
}
- (void)setItemTitleBackgroundColorWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)param {
    // param是类似：8,FF00FF00|9,FF00FF00|的Id和色值拼接的字符串
    NSArray *tempParamSegArray1 = [param componentsSeparatedByString:@"|"];
    for (NSString *tempSegStr in tempParamSegArray1) {
        if (tempSegStr.length > 0) {
            NSArray *tempParamSegArray2 = [tempSegStr componentsSeparatedByString:@","];
            if (tempParamSegArray2.count > 1) {
                NSString *prodIdStr = [tempParamSegArray2 objectAtIndex:0];
                NSString *colorHexStr = [tempParamSegArray2 objectAtIndex:1];
                
                UIView *view = [self getGridFirstColViewWithRowId:prodIdStr dataSource:self.dataSource];
                [view setBackgroundColor:[UIColor colorWithHexString:colorHexStr]];
            }
        }
    }
}
//MMSH-7433   新增通过脚本设置 产品表格第一列产品名称 的前面添加一个必分销标示符号
- (void)addTitleStartFlagWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)param {
    // param是类似：|14059,|14062,必|14064,必|14102,|14069,必| 的Id和flag拼接的字符串
    NSArray *tempParamSegArray1 = [param componentsSeparatedByString:@"|"];
    for (NSString *tempSegStr in tempParamSegArray1) {
        if (tempSegStr.length > 0) {
            NSArray *tempParamSegArray2 = [tempSegStr componentsSeparatedByString:@","];
            if (tempParamSegArray2.count > 1) {
                NSString *prodIdStr = [tempParamSegArray2 objectAtIndex:0];
                NSString *flagStr = [tempParamSegArray2 objectAtIndex:1]; //必
                
                UIView *view = [self getGridFirstColViewWithRowId:prodIdStr dataSource:self.dataSource];
                
                WSProdBean *productBean = [self getProdBeanWithPid:prodIdStr];
                
                if ([view isKindOfClass:[UILabel class]] && flagStr.length > 0 && productBean) {
                    UILabel *label = (UILabel *)view;
                    
                    label.text = [NSString stringWithFormat:@"%@%@",flagStr,productBean.name];
                    NSLog(@"----label.text = %@", label.text);
                }
            }
        }
        
    }

    
}
-(WSProdBean*)getProdBeanWithPid:(NSString*)pid
{
    for(WSProdBean* pb in self.dataSource.dataSource)
    {
        NSString* prodid = [NSString stringWithValue:pb.Id];
        if([prodid isEqualToString:pid])
        {
            return pb;
        }
    }
    return nil;
}

//玛氏 是否校验必填  优先级高于以前的标准校验  和 安卓统一
- (void)setRequestWithRowId:(NSString *)rowId col:(NSString *)paramCol param:(NSString *)param {
    WSGridWidget *gridWidget = [self.dataSource getGridWidgetByRowId:rowId col:paramCol];
    BOOL isReq = [param isEqualToString:@"true"];
    [gridWidget setRequest:isReq];
}

- (NSString *)getRowNameByProdIdWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)param {
    for (NSInteger i = 0; i < [self.dataSource.dataSource count]; i++) {
        NSObject <I_W_OptionDataItem> *object = self.dataSource.dataSource[i];
        NSString *itemId = [object getDataItemID];
        if ([itemId isEqualToString:rowId]) {
            return [object getDataItemName];
        }
    }
    return nil;
}

// SFA-20985 获取促销活动赠品
- (NSString *)getPromotionGiftWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)sql {
    if ([sql length] == 0) {
        LogError(@"参数错误");
        return @"";
    }
    if ([sql rangeOfString:@"#"].location != NSNotFound) {
        NSRange range = [sql rangeOfString:@"#"]; //现获取要截取的字符串位置
        NSString *result = @"";

        if (![sql hasSuffix:@"#"]) {
          result = [sql substringFromIndex:range.location+1]; //截取字符串
        }
     
        NSArray *array = [result componentsSeparatedByString:@","];
        NSString *str = @"";
        if(result && result.length > 0)
        {
            str = [NSString stringWithFormat:@"and pinfo.item16 not %@",[array getInSqlString]];
        }
        sql = [sql stringByReplacingOccurrencesOfString:@"$prod$" withString:str];
        
        range = [sql rangeOfString:@"#"];
        sql = [sql substringToIndex:range.location];


    }
        

    NSString *result = @"";
    // YIHAIKERRY-4119 iOS 12
    WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
    NSArray *arr = [sqliteUtil queryDicDatasBySql:sql argumentsValues:nil];
    if ([arr count] > 0) {
        for (NSDictionary *dict in arr) {
            NSString *freeSku = dict[@"item6"];
            //SFA-25650 freeSku为null 导致
            if ([freeSku isKindOfClass:[NSString class]] && [freeSku length] > 0) {
                NSString *freeAmount = dict[@"item7"];
                NSString *freeAmountUnit = dict[@"item8"];
                NSString *freeSkuName = dict[@"item11"];
//        SFA-26379        董宏 赠送规则不满足 不返回对应赠送信息
                if([freeAmount integerValue]==0)
                continue;
                result = [result stringByAppendingFormat:@"%@,%@,%@,%@|", freeSku, freeSkuName, freeAmount, freeAmountUnit];
                
                if ([dict objectForKey:@"item18"]) {
                    NSString *giftUnit = dict[@"item18"];
                    NSString *giftUnitCol = dict[@"item19"];
                    result = [result stringByAppendingFormat:@"%@,%@,%@,%@|", freeSku, freeSkuName, giftUnit, giftUnitCol];
                }
            }
        }
    }
    return result;
}

- (NSString *)getCurrentTabOperationRowIdWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)param {
    return [self.dataSource getCurrentTabOpRowId];
}

- (NSString *)computeColSumWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)param {
    NSString *result;
    double sum = [self getSumByColName:colName];
    if (sum > 0) {
        result = [NSString stringWithFormat:@"%lf",sum];;
    } else {
        result = @"0";
    }
    return result;
}

#pragma mark - AcvtDataGridViewPanel Lua method

// 获取表格产品key及值拼接的字符串 （"rowId,value|rowId,value"）
- (NSString *)getGridCellKeyAndValueArrayByColName:(NSString *)colName {
    return [self getGridCellKeyAndValueArrayWithRowId:nil col:colName param:nil];
}

// MN-338 获取已经显示的表格项 ID
- (NSString *)getSelectedProductId {
    if ([self.dataSource.dataSource count] == 0) {
        return nil;
    }
    
    NSMutableArray *prodIds = [NSMutableArray array];
    for (NSInteger i = 0; i < [self.dataSource.dataSource count]; i++) {
        NSObject <I_W_OptionDataItem> *object = self.dataSource.dataSource[i];
        [prodIds addObject:[NSString stringNotNilWithValue:[object getDataItemID]]];
    }
    NSString *result = [prodIds componentsJoinedByString:@","];
    return result;
}

- (void)setSelectedProductId:(NSString *)params {
    NSArray *idArray = [params componentsSeparatedByString:@","];
    
    NSMutableArray *tempArray = [self.dataSource.moreProductArray mutableCopy];
    for (NSObject <I_W_OptionDataItem> *object in self.dataSource.moreProductArray) {
        NSString *objectId = [object getDataItemID];
        if ([idArray containsObject:objectId]) {
            [tempArray removeObject:object];
        }
    }
    self.dataSource.moreProductArray = [tempArray mutableCopy];
}

- (NSString *)getTableColValueByProId:(NSString *)prodId col:(NSString *)parmCol {
    return [self getValueWithRowId:prodId col:parmCol param:nil];
}

- (void)setTableColValueFromDataSourceByProId:(NSString *)prodId textValue:(NSString *)value col:(NSString *)paramCol {
    [self setValueWithRowId:prodId col:paramCol param:value];
}

// 通过dependFc，storeid找产品表格中dependItem列的回显，设置给当前问卷qstCode问题的item列上
- (void)setTableColValueFromDataSourceByOtherTableCol:(NSString *)otherTableParmCol funcCode:(NSString *)funcCode acvtQstCode:(NSString *)acvtQstCode {
    // TODO:Test
    NSArray *prodObjectsArray = [[WSFptTable sharedTable] queryProductWithStoreId:self.dataSource.self.currentStore.Id fc:funcCode title:nil andSrid:self.dataSource.currentStore.srid];
    for (WSProductObject *prodObj in prodObjectsArray) {
        NSString *prodId = prodObj.prod_id;
        NSDictionary *dic = [NSDictionary dictionaryWithJsonString:[prodObj yy_modelToJSONString]];
        NSString *value = [dic objectForKey:otherTableParmCol];
        
        WSGridWidget *gridWidget = [self.dataSource getGridWidgetByRowId:prodId col:otherTableParmCol];
        [gridWidget setValue:value];
    }
}

- (double)getSumByColName:(NSString *)colName {
    double sum = 0;
    NSArray *allKeys = [self.dataSource getGridWidgetAllKeys];
    for (NSString *key in allKeys) {
        NSArray *keyArray = [key componentsSeparatedByString:@"_"];
        if ([keyArray count] == 2) {
            NSString *col = keyArray[1];
            if ([col isEqualToString:colName]) {
                WSGridWidget *widget = [self.dataSource getGridWidgetByKey:key];
                sum += [widget getSum];
            }
        }
    }
    return sum;
}

- (NSString *)getColMaxValueInTableByItem:(NSString *)itemCol {
    // 计算列的最大值
    if (self.dataSource.data && [self.dataSource.data count] > 0) {
        NSMutableArray *columnValues = [NSMutableArray array];
        WSGridWidget *gridWidget = [self.dataSource getGridWidgetByKey:kGridGroupText];
        for (NSString *key in [gridWidget getGridWidgetAllKeys]) {
            WSGridWidget *widget = [gridWidget getGridWidgetByKey:key];
            NSString *value = [widget getValue];
            if ([itemCol isEqualToString:[widget m_col]] && [value length] > 0) {
                [columnValues addObject:value];
            }
        }
        /*计算values中的最大值*/
        if ([columnValues count] > 0) {
            NSNumber *maxValue=[columnValues valueForKeyPath:@"@max.floatValue"];
            return [NSString stringWithFormat:@"%@",[maxValue stringValue]];
        }
    }
    return nil;
}

- (double)getSumByExpression:(NSString *)tableExpression {
    if (self.dataSource.data && [self.dataSource.data count] > 0) {
        double sum = 0;
        for (NSArray *rowViews in self.dataSource.data) {
            NSString *tempExpression = [tableExpression copy];
            for (WSGridWidget *gridWidget in rowViews) {
                NSString *m_col = gridWidget.m_col;
                NSString *viewValue = nil;
                NSString *className = [gridWidget className];
                if ([className isEqualToString:@"WSGridTextField"] ||
                    [className isEqualToString:@"WSGridNumberTextField"] ||
                    [className isEqualToString:@"WSGridLNRLabel"] ) {

                    viewValue = [gridWidget getValue];
                }
                
                if (tempExpression && [tempExpression length] > 0 && [tempExpression rangeOfString:[NSString stringWithFormat:@"{%@}",m_col]].location != NSNotFound) {
                    if ([viewValue length] > 0) {
                        tempExpression = [tempExpression stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}",m_col] withString:viewValue];
                    } else {
                        tempExpression = [tempExpression stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}",m_col] withString:@"0.00"];
                    }
                }
                if ([tempExpression rangeOfString:@"{"].location == NSNotFound && [tempExpression rangeOfString:@"}"].location == NSNotFound) {
                    NSString *tempExpressionValue = [[WSLuaScript getInstance] arithmeticExpressions:tempExpression];
                    sum += [tempExpressionValue doubleValue];
                    break;
                }
            }
        }
        return sum;
    }
    return 0;
}

/*计算某列的某几个产品的和*/
- (NSString *)computeRowAndColSumWith:(NSString *)prodNames item:(NSString *)columnItem {
    NSArray *names = [prodNames componentsSeparatedByString:@","];
    if (self.dataSource.data && [self.dataSource.data count] > 0) {
        NSMutableArray *prdColumnValues = [NSMutableArray array];
        for (NSInteger i = 0; i < [self.dataSource.data count]; i++) {
            NSArray *rowViews = self.dataSource.data[i];
            for (NSInteger j = 0; j < [rowViews count]; j++) {
                
                UILabel *prodNameLabel = (UILabel *)[rowViews firstObject];
                NSString *prodName = prodNameLabel.text;
                
                WSGridWidget *gridWidget = rowViews[j];
                UIView *view = [gridWidget getView];
                if ([view isKindOfClass:[WSHTextField class]]) {
                    WSHTextField *textField = (WSHTextField *)view;
                    if (textField.m_col && columnItem
                        && [textField.m_col isEqualToString:columnItem]
                        && [names containsObject:prodName]) {
                        [prdColumnValues addObject:[textField getTextValue]];
                    }
                }
            }
        }
        NSNumber *sum = [prdColumnValues valueForKeyPath:@"@sum.floatValue"];
        return [NSString stringWithFormat:@"%@",[sum stringValue]];
    }
    return nil;
}

- (void)setColDefaultValueWithColName:(NSString *)colName index:(NSInteger)index {
    NSInteger colIndex = NSNotFound;
    for (WSFuncsBean_Param *param in self.dataSource.currentTableItem.paramArray) {
        if ([param.col isEqualToString:colName]) {
            colIndex = [self.dataSource.currentTableItem.paramArray indexOfObject:param];
            break;
        }
    }
    if (colIndex != NSNotFound) {
        for (NSArray *viewArray in self.dataSource.data) {
            WSGridWidget *gridWidget = viewArray[colIndex + 1];
            if ([gridWidget isKindOfClass:[WSGridDropListView class]]) {
                [(WSGridDropListView *)gridWidget setDefaultValue];
            }
        }
    }
}

- (void)setMaxMinValue:(NSString *)params {
    //  prod_id,391@ord_min,3|prod_id,406@ord_min,2|
    NSArray *prodsArray = [params componentsSeparatedByString:@"|"];
    for (NSString *paramString in prodsArray) {
        NSArray *paramArray = [paramString componentsSeparatedByString:@"@"];
        if (paramArray.count > 1) {
            NSString *rowId = [paramArray[0] componentsSeparatedByString:@","][1];
            NSString *colName = [[paramArray[1] componentsSeparatedByString:@","][0] componentsSeparatedByString:@"_"][0];
            NSString *methodName = [[paramArray[1] componentsSeparatedByString:@","][0] componentsSeparatedByString:@"_"][1];
            NSString *param = [paramArray[1] componentsSeparatedByString:@","][1];
            if ([methodName isEqualToString:@"min"]) {
                [self setMinValueWithRowId:rowId col:colName param:param];
                
            } else if ([methodName isEqualToString:@"max"]) {
                 [self setMaxValueWithRowId:rowId col:colName param:param];
            }
        }
    }
}
#pragma mark - Private Method

// isIgnoreName 为 NO 时（"rowId,rowName|rowId,rowName"），isIgnoreName 也 YES 时 ("rowId,rowId")
-(NSString *)getGridRowIdAndNameByQstCode:(NSString *)qstCode isIgnoreName:(BOOL)isIgnoreName {
    WSAcvtDataGridComponentDataSource *dataSource = self.dataSource;
    
    NSString *namesAndIds = @"";
    
    BOOL isNeedRepeatProd = [dataSource isNeedRepeatProd];
    NSMutableDictionary *prodIdDictionary = [NSMutableDictionary dictionary];
    
    for (NSInteger i = 0; i < [dataSource.dataSource count]; i++) {
        NSObject <I_W_OptionDataItem> *object = self.dataSource.dataSource[i];
        NSString *itemId =  [object getDataItemID];
        if (isNeedRepeatProd) {
            //YIHAIKERRY-4322 删除产品时，直接取panel的widgetKey，不根据rowid生成了key
            if (dataSource.data.count  == dataSource.dataSource.count ) {
                NSArray *widgets = dataSource.data[i];
                WSGridWidget *widget = [widgets lastObject];
                NSString * widgetKey = widget.widgetKey; //eg：73#pid#1_gofa
                NSArray * arr = [widgetKey componentsSeparatedByString:kKeyProdIdColSeparator]; //字符串按照【分隔成数组
                itemId = [arr firstObject];
            } else {
                itemId = [WSGridWidget getGridWidgetKeyByRowId:itemId col:nil dictionary:prodIdDictionary];
            }
        }
        // 备注 ：统一处理 立白微信分享图片不显示商品名称（SFA-25123）、预售订单没有库存超额提示（SFA-25123）、单价修改不显示（SFA-27087）
        //SFA-25123|SFA-25125
        if (i == [dataSource.dataSource count] - 1) {
            namesAndIds = [namesAndIds stringByAppendingFormat:@"%@", itemId];
            if (!isIgnoreName) {
                //SFA-27087
                namesAndIds = [namesAndIds stringByAppendingFormat:@",%@|", [object getDataItemName]];
            }
        } else {
            namesAndIds = [namesAndIds stringByAppendingFormat:@"%@,", itemId];
            if (!isIgnoreName) {
                namesAndIds = [namesAndIds stringByAppendingFormat:@"%@|", [object getDataItemName]];
            }
        }
    }
    return namesAndIds;
}


- (UIView *)getGridFirstColViewWithRowId:(NSString *)rowId dataSource:(WSAcvtDataGridComponentDataSource *)dataSource {
    if ([dataSource.dataSource count] == 0 || !dataSource.data || [dataSource.data count] == 0) {
        return nil;
    }
    
    NSMutableArray *prodIds = [NSMutableArray array];
    for (NSInteger i = 0; i < [dataSource.dataSource count]; i++) {
        NSObject <I_W_OptionDataItem> *object = dataSource.dataSource[i];
        NSString *itemId = [object getDataItemID];
        if ([itemId length] > 0) {
            [prodIds addObject:itemId];
        }else {
            [prodIds addObject:[NSString stringNotNilWithValue:itemId]];
        }
    }
    NSInteger prodIdIndex = [prodIds indexOfObject:rowId];
    if (prodIdIndex == NSNotFound) {
        LogInfo(@"Run Lua Script Error: Not Found rowId:%@", rowId);
        return nil;
    }
    
    //MN-718 2018-02-24
    if (prodIdIndex >= [dataSource.data count]) {
        return nil;
    }
    NSArray *rowViews = dataSource.data[prodIdIndex];
    UIView *view = rowViews[0];
    return view;
}



- (NSString *)getNamesAndIdsWithColName:(NSString *)colName param:(NSString *)paramStr andRowId:(NSString *)rowId andOriginNameAndIdsStr:(NSString *)originNameAndIdsStr  {
    WSAcvtDataGridComponentDataSource *dataSource = self.dataSource;
    NSString *namesAndIds = originNameAndIdsStr;
    
    BOOL isNeedRepeatProd = [dataSource isNeedRepeatProd];
    NSMutableDictionary *dictionary = nil;
    if (isNeedRepeatProd) {
        dictionary = [NSMutableDictionary dictionary];
    }
//    //SFA-27338 donghong  这个先注释掉，会影响多处脚本的结果值，后续再根据参数来加
//    for (WSProdBean *prodBean in dataSource.dataSource) {
//        if ([prodBean.Id isEqualToString:rowId]) {
//            namesAndIds = [namesAndIds stringByAppendingFormat:@"%@_productName,%@|", rowId, prodBean.name];
//            continue;
//        }
//    }
    
    for (NSInteger j = 0; j < [dataSource.currentTableItem.paramArray count]; j++) {
        WSFuncsBean_Param *param = dataSource.currentTableItem.paramArray[j];
        
        NSString *key = [WSGridWidget getGridWidgetKeyByRowId:rowId col:param.col dictionary:dictionary];
        if (param.col.length > 0 && [colName isEqualToString:param.col]) {
            NSString *value = [self getValueWithRowId:rowId col:param.col param:nil];
            if (paramStr.length > 0 && [paramStr isEqualToString:@"notBlank"]) {
                if (value.length > 0) {
                    namesAndIds = [namesAndIds stringByAppendingFormat:@"%@,%@|", key, value];
                }
            } else {
                namesAndIds = [namesAndIds stringByAppendingFormat:@"%@,%@|", key, value];
            }
        }
        //MN-904 2018-03-03
        else if(!colName || colName.length <= 0) {
            if (param.col.length > 0) {
                NSString *value = [self getValueWithRowId:rowId col:param.col param:nil];
                namesAndIds = [namesAndIds stringByAppendingFormat:@"%@,%@|", key, value];
            }
        }
    }
    return namesAndIds;
}



@end

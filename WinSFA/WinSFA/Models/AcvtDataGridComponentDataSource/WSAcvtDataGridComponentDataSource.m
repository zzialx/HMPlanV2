//
//  WSDataGridComponentDataSource.m
//  WinSFA
//
//  Created by ZhengJiepeng on 13-7-24.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import "WSAcvtDataGridComponentDataSource.h"
#import "WSStoreBean_prod.h"
#import "WSProdBeanArray.h"
#import "WSProdBean.h"
#import "WSDictBean.h"
#import "WSAppData.h"
#import "WSAcvtViewController.h"
#import "UILabel+Additional.h"
#import "WSLuaScript.h"
#import "WSInterAction.h"
#import "WidgetConstant.h"
#import "WSFuncsBeanArray.h"
#import <math.h>
#import "WSDataSourceManager.h"
#import "WSAcvtModel.h"
#import "WSBaseProductDBService.h"
#import "WSBaseDictsDBService.h"
#import "WSBaseStoreProddisDBService.h"
#import "WSGridImageHeaderView.h"
#import "WSDataSourceFromDSDicts.h"
#import "WSDataSourceFromDSStoreAcvtDisAndAcvtDis.h"
#import "WSBaseOptionDataItem.h"
#import "WSLuaExecutorManager.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "WSSingleSelectAndSearchViewController.h"
#import "NSString+ServerUrl.h"
#import "WSAcvtDataGridComponentService.h"
#import "WSNRLabel.h"
#import "WSDropListView.h"
#import "WCURLUILabel.h"
#import "WSGridWidgetGroup.h"
#import "WSGridWidgetFactory.h"
#import "WSGridCheckBoxAll.h"
#import "WSAcvtDataGridViewPanel.h"
#import "WSSetResultExecutor.h"

#define GRID_INIT_LUA_FUNCTION              @"function initGridValue("
#define GRID_INIT_LUA_FUNTION_SETVALUE      @"function setValue("
#define GRID_COMPUTE_LUA_FUNCTION           @"function computeSumToTarget("
#define GRID_VALIDATE_LUA_FUNCTION          @"function onCheck("
#define GRID_ADD_PRODUCT_LUA_FUNCTION       @"function addProduct("
#define GRID_DELETE_PRODUCT_LUA_FUNCTION    @"function delete("
#define GRID_BEFORE_JUMP_LUA_FUNCTION       @"function beforeJump("
#define CellTextFont                        [UIFont fontWithName:@"Helvetica-Light" size:DATAGRID_TITLE_FONTSIZE]
#define kLeftTitleFont                      ([UIFont fontForKey:@"GridLeftTitleFont"] ?:CellTextFont)

@interface WSAcvtDataGridComponentDataSource () <singleSelectAndSearchDelegate, WSDropListViewDelegate, UIActionSheetDelegate, WSGridWidgetDelegate> {
    
    BOOL isInitView;
}

@property (nonatomic, assign) BOOL isInNewAcvt;
@property (nonatomic, strong) WSDropListView *currentSelectListView;
@property (nonatomic, assign) BOOL isExecutingExepComputeWhenInit;
@property (nonatomic, strong) NSMutableDictionary *executedExepDictionaryWhenInit;
@property (nonatomic, strong) NSString *currentTabOpRowId;
@property (nonatomic, strong) WSGridWidget *widgetRoot;
@property (nonatomic, strong) WSFuncsBean *tbFuncsBean;
@property (nonatomic, strong) NSMutableDictionary *widgetKeyDictionary;

@end

@implementation WSAcvtDataGridComponentDataSource

@synthesize isValueChange = _isValueChange;

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (id)initWithQst:(WSAcvtBean_qst *)aQst store:(WSStoreBean *)aStore func:(WSFuncsBean *)aFunc ownViewController:(WSAcvtViewController *)aViewController isInNewAcvt:(BOOL)isInNewAcvt {
    
    WSFuncsBeanArray *newfba = [WSAppData getObjectbyKey:FUNCS];
    WSFuncsBean *tbFuncsBean = [newfba getHideFuncsBeanWithFC:aQst.mc];
    if (tbFuncsBean) {
        self.acvtTypeDataSourceTool = [[WSAcvtGridWithDsAcvtDataSoureTools alloc] initWithFuncs:tbFuncsBean Store:aStore];
        self.currentTableItem = [[WSTableItem alloc] initWithFuncsBean:tbFuncsBean];
        self.tbFuncsBean = tbFuncsBean;
    }
    
    self.currentQst = aQst;
    if ([[aQst getMumx] intValue] != 0) {
        self.rightTableShowType = WSDataGridComponentRightTableColumnMaxShowType;
        self.rightTableShowColOrRowMaxValue = [[aQst getMumx] intValue];
    }
    
    self.model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    self = [super initWithStore:aStore func:tbFuncsBean ownViewController:aViewController andCurrentTableItem:self.currentTableItem];
    if (self) {
        
        _formulaDictionary = [[NSMutableDictionary alloc] init];
        _maxValueFormulaDictionary = [[NSMutableDictionary alloc] init];
        _isInNewAcvt = isInNewAcvt;
        _prod_cacheDataMDictionary = [[NSMutableDictionary alloc] init];
        _prod_cacheDataDictKeysArray = [[NSMutableArray alloc] init];
        
        [self initDataSource];
        
        self.titles = [self columnsDatasOfTitles];
        [self colunmViewWidth];
        isInitView = YES;
        
        if ([self.currentTableItem.ds isEqualToString:DS_ACVT]) { // 用工具类SourceTool中的数据
            self.dataSource = self.acvtTypeDataSourceTool.m_dataSources;
            self.prod_cacheDataMDictionary = self.acvtTypeDataSourceTool.acvtGrid_cacheDataMDictionary;
        }
        
        self.data = [self grideViewData];
        [self setProdViewReadOnlyByProductCol];
        isInitView = NO;
    }
    return self;
}

- (void)refreshCurrentTableItem {
    
    if (self.tbFuncsBean) {
        self.currentTableItem = [[WSTableItem alloc] initWithFuncsBean:self.tbFuncsBean];
    }
}

- (void)initDataSource {
    
    [super initDataSource];
    
    if (!self.widgetKeyDictionary) {
        self.widgetKeyDictionary  = [[NSMutableDictionary alloc] init];
    }
    else {
        [self.widgetKeyDictionary removeAllObjects];
    }
}

- (NSMutableArray *)columnsDatasOfTitles {
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSString *firstTitle = NSLocalizedString(@"default_left_attach_header_label", nil);
    if ([self.currentFunc.opt.name isKindOfClass:[NSString class]]) {
        firstTitle = self.currentFunc.opt.name;
    }
    else if ([self.currentFunc.opt.title isKindOfClass:[NSString class]]) {
        firstTitle = self.currentFunc.opt.title;
    }
    
    if (self.currentTableItem.name && [self.currentTableItem.name isKindOfClass:[NSString class]]) {
        firstTitle = self.currentTableItem.name;
    }
    else if (self.currentTableItem.opt.name && [self.currentTableItem.opt.name isKindOfClass:[NSString class]]) {
        firstTitle = self.currentTableItem.opt.name;
    }
    [array addObject:firstTitle];
    
    for (WSFuncsBean_Param *param in self.currentTableItem.paramArray) {
        [array addObject:param.name];
    }
    return array;
}

- (void)colunmViewWidth {
    
    if (!self.columnWidth) {
        self.columnWidth = [[NSMutableArray alloc] init];
    }
    else {
        [self.columnWidth removeAllObjects];
    }
    
    NSInteger paramCount = [self.currentTableItem.paramArray count];
    CGFloat detailSizeWidth = DETAILSIZEWIDTH;
    NSString *fwol = nil;
    if (self.currentTableItem.fCharNum) {
        fwol = [NSString stringWithFormat:@"%ld", (long)([self.currentTableItem.fCharNum integerValue]) * (long)detailSizeWidth];
    }
    if (paramCount > 1) {
        
        if (fwol.integerValue <= 0) {
            fwol = SHORT_COLUMN_WIDTH;
        }
    }
    else {
        
        if (fwol.integerValue <= 0) {
            fwol = DEFAULT_COLUM_WIDTH;
        }
    }
    
    if (fwol) {
        
        if ([self isShowThumbnail]) {
            fwol = [[NSNumber numberWithInteger:[fwol integerValue] + kGridImageHeaderViewImageWith] stringValue];
        }
        [self setColumnWidth:fwol paramCount:paramCount];
    }
}

- (void)setColumnWidth:(NSString *)a_Width paramCount:(NSInteger)a_paramCount {
    
    NSString *firstColumWidth = a_Width;
    [self.columnWidth addObject:firstColumWidth];
    
    for (int i = 0; i < a_paramCount; i++) {
        
        WSFuncsBean_Param *fb = nil;
        NSInteger unitValue = UNIT_WIDTH_DEFAULT;
        
        fb = [self.currentTableItem.paramArray objectAtIndex:i];
        if (fb.charNum.integerValue > 0) {
            
            if ([fb.tpy isEqualToString:@"N"] || [fb.tpy isEqualToString:@"CHT"] || [fb.tpy isEqualToString:@"R"] || [fb.tpy isEqualToString:@"D"] || [fb.tpy isEqualToString:@"P"] ||
                [fb.tpy isEqualToString:@"DT"] || [fb.tpy isEqualToString:@"SD"] || [fb.tpy isEqualToString:COL_TYPCHECKBOXALL]) { //数字 标点 按钮 中文  单位字符的宽度
                unitValue = UINIT_WIDTH_OTHER;
            }
            else if ([fb.tpy isEqualToString:@"C"]) { //选项框
                unitValue = 5.0f;
            }
            else if ([fb.tpy isEqualToString:@"T"]) { //字母 单位字符的宽度
                unitValue = UINIT_WIDTH_T;
            }
            else if ([fb.tpy isEqualToString:@"B"]) { //按钮
                unitValue = UINIT_WIDTH_B;
            }
            
            if ([fb.tpy isEqualToString:COL_TYPCHECKBOXALL]) {
                [self.columnWidth addObject:[NSString stringWithFormat:@"%ld_%ld", (long)(fb.charNum.integerValue - 2) * unitValue, 2 * (long)unitValue]];
            }
            else {
                [self.columnWidth addObject:[NSString stringWithFormat:@"%ld", (long)fb.charNum.integerValue * unitValue]];
            }
        }
        else if (fb.wcol > 0) {
            
            if ([fb.tpy isEqualToString:COL_TYPCHECKBOXALL]) {
                [self.columnWidth addObject:[NSString stringWithFormat:@"%ld_%ld", (long)fb.wcol, (long)fb.wcol]];
            }
            else {
                [self.columnWidth addObject:[NSString stringWithFormat:@"%ld", (long)fb.wcol]];
            }
        }
        else {
            
            if ([fb.tpy isEqualToString:COL_TYPCHECKBOXALL]) {
                [self.columnWidth addObject:[NSString stringWithFormat:@"%@_%@", a_Width,a_Width]];
            }
            else {
                [self.columnWidth addObject:a_Width];
            }
        }
    }
}

- (NSString *)getProdIdsStrByData:(NSArray *)dataArray prodIdsStr:(NSString *)prodIdsStr {
    
    for (NSInteger i = 0; i < dataArray.count; i ++) {
        WSProdBean *prodBean = [dataArray objectAtIndex:i];
        if ([prodIdsStr rangeOfString:[NSString stringWithFormat:@"'%@',", prodBean.Id]].location == NSNotFound) {
            prodIdsStr = [NSString stringWithFormat:@"%@'%@',", prodIdsStr, prodBean.Id];
        }
    }
    
    if ([[prodIdsStr substringWithRange:NSMakeRange(prodIdsStr.length - 1, 1)] isEqualToString:@","]) {
        prodIdsStr = [prodIdsStr substringWithRange:NSMakeRange(0, prodIdsStr.length - 1)];
    }
    return prodIdsStr;
}

- (void)setMoreProdsDefaultColValueCacheDicForCurrentAcvtGrid {
    
    if ([self.currentTableItem.paramArray count] < 1) {
        return;
    }
    
    NSString *prodIdsStr =  [self getProdIdsStrByData:self.moreProductArray prodIdsStr:@""];
    prodIdsStr = [self getProdIdsStrByData:self.dataSource prodIdsStr:prodIdsStr];
    if (prodIdsStr.length > 0) {
        [self setProductDefautValueForCacheDic];
        [self setProductRedisByProdIds:prodIdsStr];
    }
}

- (void)setProductRedisByProdIds:(NSString *)prodIds {
    
    NSArray *prodDisObjectsArray = [self getProdRedisArrayWithProdIds:prodIds];
    if (prodDisObjectsArray && prodDisObjectsArray.count > 0) {
        
        for (WSBaseStoreProdDisObject *bspdo in prodDisObjectsArray) {
            for (WSFuncsBean_Param *aParam in self.currentTableItem.paramArray) {
                
                NSString *colValue = [bspdo valueForKey:aParam.col];
                NSString *cacheKey = [WSGridWidget getGridWidgetKeyByRowId:bspdo.prod_id col:aParam.col];
                [self setProdCacheWithKey:cacheKey value:colValue];
            }
        }
    }
}

- (NSArray *)getProdRedisArrayWithProdIds:(NSString *)prodIds {
    
    WSBaseStoreProddisDBService *proddisDBService = [[WSBaseStoreProddisDBService  alloc] init];
    NSString *redisGridMd5 = [self.model getAcvtDisValueByAcvtQstId:self.currentQst.acvtQstId];
    NSArray *prodDisObjectsArray = [proddisDBService queryStoreProdDissWithGenId:redisGridMd5 storeId:self.currentStore.Id prodIds:prodIds];
    return prodDisObjectsArray;
}

- (NSMutableArray *)grideViewData {
    
    if ([self.currentTableItem.paramArray count] < 1) {
        return nil;
    }
    
    NSInteger l_dataSourcesCount = [self.dataSource count];
    NSInteger startPosition = 0;
    if (self.m_moreProdsCount > 0) {
        startPosition = l_dataSourcesCount - self.m_moreProdsCount;
    }
    if (self.m_moreProdsCount == NONEEXIST) {
        startPosition = l_dataSourcesCount;
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if (self.data) {
        [array addObjectsFromArray:self.data];
    }
    
    NSMutableDictionary *widgetKeyDictionary = nil;
    if ([self isNeedRepeatProd]) {
        widgetKeyDictionary = self.widgetKeyDictionary;
    }
    for (NSInteger i = startPosition; i < l_dataSourcesCount; i++) {
        
        NSMutableArray *rowWidgetArray = [[NSMutableArray alloc] initWithCapacity:[self.titles count]];
        
        if(!_formulaStringArray){
            _formulaStringArray = [NSMutableArray arrayWithCapacity:1];
        }
        
        if (!_maxValueFormulas) {
            _maxValueFormulas = [NSMutableArray arrayWithCapacity:10];
        }
        
        UIView *firstColView = [self firstColumnDataWithIndex:i];
        [rowWidgetArray addObject:firstColView];
        
        int j = 0;
        for (WSFuncsBean_Param *param in self.currentTableItem.paramArray) {
            
            WSGridWidget *gridWidget = [self viewFromParamNew:param atRowIndex:i atColumn:j widgetKeyDictionary:widgetKeyDictionary];
            UIView *view = [gridWidget getView];
            if (view && gridWidget) {
                [self addGroupWidget:gridWidget];
            }
            
            if ([param.tpy isEqualToString:COL_TYPDT] || [param.tpy isEqualToString:COL_TYPSD]) {
                [gridWidget setValue:[self setGrideViewDataKindofSelectListParam:param Data:[self.dataSource objectAtIndex:i] withRow:i]];
            }
            
            if (self.isReturn) {
                [self getCurrentViewValueWith:param index:i widgetCacheKey:gridWidget.widgetKey isReturn:YES];
            }
            NSString *showValue = [self getCurrentViewValueWith:param index:i widgetCacheKey:gridWidget.widgetKey];
            
            [gridWidget setValue:showValue];
            
            j++;
            [rowWidgetArray addObject:gridWidget];
        }
        
        [self setFormulaValue:rowWidgetArray row:i];
        
        [array addObject:rowWidgetArray];
    }
    
    for (int n = 0; n < [array count]; n++) {
        
        NSArray *viewArray = [array objectAtIndex:n];
        for (int m = 0; m < [viewArray count]; m++) {
            
            id obj = [viewArray objectAtIndex:m];
            if (obj != nil && [obj respondsToSelector:@selector(startObservingEntity)]) {
                [obj startObservingEntity];
            }
        }
    }
    return array;
}

- (void)addGroupWidget:(WSGridWidget *)gridWidget {
    
    NSString *groupName = gridWidget.groupName;
    WSGridWidget *widgetGroup = [self.widgetRoot getGridWidgetByKey:groupName];
    if (!widgetGroup) {
        widgetGroup = [self createWidgetGroupWithType:groupName];
    }

    [widgetGroup add:gridWidget];
    [self.widgetRoot add:widgetGroup];
    [self.widgetRoot add:gridWidget];
}

- (void)setProdViewReadOnlyByProductCol {
    
    NSInteger dataSourcesCount = self.dataSource.count;
    if (dataSourcesCount == 0) {
        return;
    }
    
    WSBaseStoreOtherDataDBService *service = [[WSBaseStoreOtherDataDBService alloc] init];
    NSArray *otherDataArray = [service queryProductColWithFC:self.currentFunc.fc storeId:self.currentStore.Id];
    if ([otherDataArray count] > 0) {
        
        for (NSInteger i = 0; i < dataSourcesCount; i++) {
            
            if ([self.currentTableItem.ds isEqualToString:DS_PROD] || [self.currentTableItem.ds isEqualToString:DS_PRODC]) {
                
                WSProdBean *prodBean = [self.dataSource objectAtIndex:i];
                NSString *rowId = prodBean.Id;
                NSMutableArray *colArray = [NSMutableArray array];
                
                for (WSBaseStoreOtherDataObject *otherObject in otherDataArray) {
                    if ([otherObject.item2 isEqualToString:rowId]) {
                        [colArray addObject:otherObject.item3];
                    }
                }
                
                for (NSString *col in colArray) {
                    [self setReadOnlyWithRowId:rowId col:col param:@"true"];
                }
            }
            else {
                break;
            }
        }
    }
}

- (void)setFormulaValue:(NSArray *)rowWidgetArray row:(NSInteger)i {
    
    for (NSString *formulaString in self.formulaStringArray) {
        
        if (formulaString && [formulaString length] > 0) {
            
            NSString *newFormulaString = [NSString stringWithString:formulaString];
            for (WSGridWidget *gridWidget in rowWidgetArray) {
                
                if (![gridWidget isKindOfClass:[WSGridWidget class]]) {
                    continue;
                }
                
                UIView *view = [gridWidget getView];
                if ([view isKindOfClass:[WSHTextField class]]) {
                    
                    WSHTextField *listenerView = (WSHTextField *)view;
                    if ([formulaString rangeOfString:[NSString stringWithFormat:@"{%@}",listenerView.m_col]].length > 0) {
                        
                        NSString *key = [NSString stringWithFormat:@"{%ldrow:%dcolumn}",(long)i,listenerView.iColumn];
                        UIView *originView = [self.formulaDictionary objectForKey:key];
                        if (originView && originView != listenerView) {
                            
                            [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:originView];
                            [self.formulaDictionary removeObjectForKey:key];
                        }
                        
                        if (![self.formulaDictionary objectForKey:key]) {
                            
                            [self.formulaDictionary  setValue:listenerView forKey:key];
                            [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:listenerView];
                            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:listenerView];
                        }
                        newFormulaString = [newFormulaString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}",listenerView.m_col] withString:key];
                    }
                }
                else if ([view isKindOfClass:[WSNRLabel class]]) {
                    
                    WSNRLabel *listenerView = (WSNRLabel *)view;
                    if ([formulaString rangeOfString:[NSString stringWithFormat:@"{%@}",listenerView.m_col]].length > 0) {
                        
                        NSString *key = [NSString stringWithFormat:@"{%ldrow:%ldcolumn}",(long)i,(long)listenerView.iColumn];
                        UIView *originView = [self.formulaDictionary objectForKey:key];
                        if (originView && originView != listenerView) {
                            [self.formulaDictionary removeObjectForKey:key];
                        }
                        
                        if (![self.formulaDictionary objectForKey:key]) {
                            [self.formulaDictionary  setValue:listenerView forKey:key];
                        }
                        newFormulaString = [newFormulaString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}",listenerView.m_col] withString:key];
                    }
                }
            }
            
            id objectTemp = [self.formulaDictionary objectForKey:formulaString];
            [self.formulaDictionary setValue:objectTemp forKey:newFormulaString];
            [self.formulaDictionary removeObjectForKey:formulaString];
        }
    }
    
    for (NSString *maxFormula in  self.maxValueFormulas) {
        
        if (maxFormula && [maxFormula length] > 0) {
            
            NSString *newMaxFormula  = [NSString stringWithString:maxFormula];
            for (WSGridWidget *gridWidget in rowWidgetArray) {
                
                if (![gridWidget isKindOfClass:[WSGridWidget class]]) {
                    continue;
                }
                
                UIView *view = [gridWidget getView];
                if ([view isKindOfClass:[WSHTextField class]]) {
                    
                    WSHTextField *listenerView = (WSHTextField *)view;
                    if ([newMaxFormula rangeOfString:[NSString stringWithFormat:@"{%@}",listenerView.m_col]].length > 0) {
                        
                        NSString *key = [NSString stringWithFormat:@"{%ldrow:%dcolumn}",(long)i,listenerView.iColumn];
                        if (![self.maxValueFormulaDictionary objectForKey:key]) {
                            
                            [self.maxValueFormulaDictionary  setValue:listenerView forKey:key];
                            [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:listenerView];
                            
                            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:listenerView];
                        }
                        newMaxFormula = [newMaxFormula stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}",listenerView.m_col] withString:key];
                    }
                }
                else if ([view isKindOfClass:[WSNRLabel class]]) {
                    
                    WSNRLabel *listenerView = (WSNRLabel *)view;
                    if ([newMaxFormula rangeOfString:[NSString stringWithFormat:@"{%@}",listenerView.m_col]].length > 0) {
                        
                        NSString *key = [NSString stringWithFormat:@"{%ldrow:%ldcolumn}",(long)i,(long)listenerView.iColumn];
                        if (![self.maxValueFormulaDictionary objectForKey:key]) {
                            [self.maxValueFormulaDictionary  setValue:listenerView forKey:key];
                        }
                        newMaxFormula = [newMaxFormula stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}",listenerView.m_col] withString:key];
                    }
                }
            }
            
            id objectTemp = [self.maxValueFormulaDictionary objectForKey:maxFormula];
            [self.maxValueFormulaDictionary setValue:objectTemp forKey:newMaxFormula];
            [self.maxValueFormulaDictionary removeObjectForKey:maxFormula];
        }
    }
    
    [self.maxValueFormulas removeAllObjects];
    [self.formulaStringArray removeAllObjects];
}

- (WSGridWidget *)viewFromParamNew:(WSFuncsBean_Param *)aParam atRowIndex:(NSInteger)aIndex atColumn:(NSInteger)aColumn widgetKeyDictionary:(NSMutableDictionary *)widgetKeyDictionary {
    
    WSGridWidget *gridWidget = [[WSGridWidgetFactory shareInstance] createGridWidgetByParam:aParam rowIndex:aIndex columnIndex:aColumn];
    if (!gridWidget) {
        return nil;
    }
    
    gridWidget.delegate = self;
    UIView *gridView = [gridWidget getView];
    if (!gridView) {
        return nil;
    }
    
    id<I_W_OptionDataItem> bean = [self.dataSource objectAtIndex:aIndex];
    gridWidget.prodName  = [bean getDataItemName];
    gridWidget.rowId = [bean getDataItemID];
    gridWidget.funcsBean = self.tbFuncsBean;
    gridWidget.store = self.currentStore;
    gridWidget.widgetKey = [WSGridWidget getGridWidgetKeyByRowId:[bean getDataItemID] col:gridWidget.param.col dictionary:widgetKeyDictionary];
    
    if ([gridWidget isSupportDepend]) {
        [self setDependedInfoWith:(id<WSValidateData>)gridView withParam:aParam withRow:aIndex andColumn:aColumn];
    }
    
    if ([aParam.tpy isEqualToString:COL_TYPDT] || [aParam.tpy isEqualToString:COL_TYPSD]) {
        [self setGridViewDataSourceKindOfSelectList:(WSDropListView *)gridView param:aParam Data:[self.dataSource objectAtIndex:aIndex] withRow:aIndex];
    }
    
    [self setFormula:gridWidget param:aParam];
    return gridWidget;
}

- (void)setFormula:(WSGridWidget *)gridWidget param:(WSFuncsBean_Param *)aParam {
    
    if (![[gridWidget groupName] isEqualToString:kGridGroupText]) {
        return;
    }
    
    if (aParam.value && [aParam.value length] > 0 && [aParam.value rangeOfString:@"function"].location == NSNotFound) {
        
        NSString *originalKey = [NSString stringWithFormat:@"%@value%@", gridWidget.rowId, aParam.value];
        [self.formulaDictionary  setObject:[gridWidget getView] forKey:originalKey];
        
        NSString *formulaString = [originalKey copy];
        [self.formulaStringArray addObject:formulaString];
    }
}

- (WSGridWidget *)getGridWidgetByRowId:(NSString *)rowId col:(NSString *)col {
    
    if ([rowId length] == 0 || [col length] == 0) {
        return nil;
    }
    
    return [self.widgetRoot getGridWidgetByKey:[WSGridWidget getGridWidgetKeyByRowId:rowId col:col]];
}

- (WSGridWidget *)getGridWidgetByKey:(NSString *)key {
    
    if ([key length] == 0) {
       return nil;
    }
    
    return [self.widgetRoot getGridWidgetByKey:key];
}

- (NSArray *)getGridWidgetAllKeys {
    
    return [self.widgetRoot getGridWidgetAllKeys];
}

- (NSString *)getCacheKeyByBean:(id <I_W_OptionDataItem>)bean param:(WSFuncsBean_Param *)aParam {
    
    return [WSGridWidget getGridWidgetKeyByRowId:[bean getDataItemID] col:aParam.col];
}

- (void)setProdCacheWithKey:(NSString *)cacheKey value:(NSString *)showValue {
    
    if ([NSString stringNotNilWithValue:showValue].length > 0 && [NSString stringNotNilWithValue:cacheKey].length > 0) {
        
        [_prod_cacheDataMDictionary setObject:[NSString stringNotNilWithValue:showValue] forKey:cacheKey];
        if ([_prod_cacheDataDictKeysArray indexOfObject:cacheKey] == NSNotFound) {
            [_prod_cacheDataDictKeysArray addObject:cacheKey];
        }
    }
}

- (NSString *)getCurrentViewValueWith:(WSFuncsBean_Param *)aParam index:(NSInteger)aIndex widgetCacheKey:(NSString *)widgetCacheKey {
    
    return [self getCurrentViewValueWith:aParam index:aIndex widgetCacheKey:widgetCacheKey isReturn:NO];
}

- (NSString *)getCurrentViewValueWith:(WSFuncsBean_Param *)aParam index:(NSInteger)aIndex widgetCacheKey:(NSString *)widgetCacheKey isReturn:(BOOL)isReturn {
    
    id<I_W_OptionDataItem> bean = [self.dataSource objectAtIndex:aIndex];
    
    NSString *showValue = nil;
    if (aParam.idefault) {
        showValue = aParam.idefault;
    }
    
    NSString *cacheKey = [self getCacheKeyByBean:bean param:aParam];
    if ([_prod_cacheDataMDictionary.allKeys containsObject:cacheKey] && !isReturn) {
        showValue = [_prod_cacheDataMDictionary objectForKey:cacheKey];
    }
    else {
             
        if ([self.m_DataBaseDatas count] > 0) {
            showValue = [self getCurrentNativeValueWith:aParam index:aIndex widgetCacheKey:widgetCacheKey];
        }
        else {
            
            NSString *disValue = nil;
            NSString *serverDisValue = [self getCurrentViewServerValueWith:aParam index:aIndex widgetCacheKey:widgetCacheKey];
            if (aParam.ids && aParam.ids.length > 0) {
                disValue = [self getCurrentViewIdsValueWith:aParam index:aIndex];
            }

            if (serverDisValue && serverDisValue.length > 0) {
                if (aParam.ids && aParam.col && aParam.name) {
                    if ([aParam.col isEqualToString:@"pri"] && [aParam.ids isEqualToString:@"price"] &&[aParam.name isEqualToString:@"基准价格"]) {
                        if ([serverDisValue isEqualToString:@"0"]) {
                            serverDisValue = disValue;
                        }
                    }
                }
                disValue = serverDisValue;
            }
                 
            if (aParam.idefault && aParam.idefault.length > 0 && !isReturn) {
                showValue = aParam.idefault;
            }
            else {
                showValue = [_prod_cacheDataMDictionary objectForKey:cacheKey];
            }
            showValue = disValue.length > 0 && ![disValue isEqualToString:@"0"] ? disValue : showValue;
        }
        
        if (isReturn && !showValue && showValue.length < 1) {
            return @"";
        }
        [self setProdCacheWithKey:widgetCacheKey value:showValue];
    }
    
    return showValue;
}

- (BOOL)maxValueIsFormula:(NSString *)validatedString {
    
    if ([validatedString rangeOfString:@"{"].location != NSNotFound && [validatedString rangeOfString:@"}"].location != NSNotFound) {
        return YES;
    }
    return NO;
}

-(NSInteger)getProdspecRedisIndexbyParam:(WSFuncsBean_Param*)param {
    
    NSString *paramRedis = nil;
    if (param.redis && [param.redis isEqualToString:@"0"]) {
        return NSNotFound;
    }
    
    if (param.redis && [param.redis isEqualToString:@"1"]) {
        paramRedis = param.col;
    }
    else if (param.redis && [param.redis length] > 0) {
        paramRedis = param.redis;
    }
    
    NSArray* spec = [WSAppData getObjectbyKey:PRODSPECDIS];
    if ([spec count] == 0) {
        spec = [WSAppData getObjectbyKey:PRODSPEC];
    }
    
    for (NSInteger i =0;i < [spec count]; i++) {
        
        NSString *specIndexString  = [spec objectAtIndex:i];
        specIndexString = [specIndexString stringByTrimmingWhitespace];
        if (specIndexString &&[specIndexString isEqualToString:paramRedis]) {
            return i;
        }
    }
    return NSNotFound;
}

- (NSUInteger)getProdSpecIndexWithContent:(NSString*)content {
    
    if ([content length] == 0) {
        return NSNotFound;
    }
    
    NSArray* spec = [WSAppData getObjectbyKey:PRODSPECDIS];
    if ([spec count] == 0) {
        spec = [WSAppData getObjectbyKey:PRODSPEC];
    }
    
    NSArray *ps = spec;
    if (ps) {
        return [ps indexOfObject:content];
    }
    return NSNotFound;
}

- (NSString*)getDefaultDataWithParam:(WSFuncsBean_Param*)aParam OthersDict:(NSDictionary *)dict {
    
    id <I_W_OptionDataItem> data = [dict objectForKey:@"data"];
    NSString *widgetKey = [dict objectForKey:@"widgetKey"];
    NSString *repeateIndex = @"0";
    if ([widgetKey rangeOfString:kKeyRepeatProdIdSeparator].location != NSNotFound) {
        
        NSArray *prodArray = [widgetKey componentsSeparatedByString:kKeyProdIdColSeparator];
        if ([prodArray count] > 0) {
            repeateIndex = prodArray[0];
            repeateIndex = [repeateIndex componentsSeparatedByString:kKeyRepeatProdIdSeparator][1];
        }
    }
    
    if ([data isKindOfClass:[WSProdBean class]]) {
        return [self getDefaultDataWithParam:aParam prodBean:data repeateIndex:[repeateIndex integerValue]];
    }
    else if ([data isKindOfClass:[WSDictBean class]]) {
        return [self getDefaultDataWithParam:aParam dictBean:data repeateIndex:[repeateIndex integerValue]];
    }
    else {
        return nil;
    }
}

- (NSString*)getDefaultDataWithParam:(WSFuncsBean_Param*)aParam prodBean:(WSProdBean*)aProd repeateIndex:(NSInteger)repeateIndex {
    
    WSBaseStoreProddisDBService *proddisDBService = [[WSBaseStoreProddisDBService  alloc] init];
    NSString *colForParam =  ([aParam.redis length] > 0 && ![aParam.redis isEqualToString:@"1"] && ![aParam.redis isEqualToString:@"0"])? aParam.redis:aParam.col;
    NSString *redisGridMd5 = [self.model getAcvtDisValueByAcvtQstId:self.currentQst.acvtQstId];
    NSString *redis = [proddisDBService queryStoreProdRedisValueWithGenId:redisGridMd5 storeId:self.currentStore.Id prodId:aProd.Id paramCol:colForParam repeateIndex:repeateIndex];
    return redis;
}

- (NSString*)getDefaultDataWithParam:(WSFuncsBean_Param*)aParam dictBean:(WSDictBean*)aDict repeateIndex:(NSInteger)repeateIndex {
    
    NSString *redisGridMd5 = [self.model getAcvtDisValueByAcvtQstId:self.currentQst.acvtQstId];
    NSString *tempStoreId = self.currentStore.Id.length > 0 ? self.currentStore.Id : @"-1";
    WSBaseDictsDBService *baseDictsDBService = [[WSBaseDictsDBService alloc] init];
    NSString *redis =  [baseDictsDBService queryAcvtDictsGridRedisWithStoreId:tempStoreId qst:self.currentQst param:aParam dict:aDict andGenId:redisGridMd5 repeateIndex:repeateIndex];
    if ([redis length] > 0) {
        return redis;
    }
    return nil;
}

- (UIView *)firstColumnDataWithIndex:(NSInteger)aIndex {
    
    id<I_W_OptionDataItem> bean = [self.dataSource objectAtIndex:aIndex];
    NSString *titleText = [self getDataNameWithData:bean];
    NSString *titleDescText = nil;
    if ([bean respondsToSelector:@selector(getDataItemDescName)]) {
        titleDescText = [bean getDataItemDescName];
    }
    
    NSString *prodId = nil;
    NSString *imgUrl = nil;
    if ([bean respondsToSelector:@selector(getDataItemUrl)]) {
        prodId = [bean getDataItemID];
        NSString *url = [bean getDataItemUrl];
        if ([url length] > 0) {
            imgUrl = [url buildupUrl];
        }
    }
    
    UIView *titleView = nil;
    UILabel *textLabel = nil;
    if ([self isShowThumbnail]) {
        
        WSGridImageHeaderView *l_title_view = [[WSGridImageHeaderView alloc] initWithFrame:CGRectMake(0, 0, 0, DATAGRID_CELL_HEIGHT_DEFAULT)];
        textLabel = l_title_view.textLabel;
        l_title_view.productID = prodId;
        l_title_view.imageURL = imgUrl;
        titleView = l_title_view;
    }
    else {
        
        WCURLUILabel *l_title_view = [[WCURLUILabel alloc] initWithFrame:CGRectMake(0, 0, 0, DATAGRID_CELL_HEIGHT_DEFAULT)];
        l_title_view.detailText = titleDescText;
        l_title_view.productID = prodId;
        l_title_view.iImageURL = imgUrl;
        textLabel = l_title_view;
        titleView = l_title_view;
    }
    
    textLabel.numberOfLines = 0;
    textLabel.text = titleText;
    return titleView;
}

- (NSString *)getDataNameWithData:(id <I_W_OptionDataItem>)bean {
    
    BOOL isRequired = NO;
    if ([bean respondsToSelector:@selector(isDataItemRequired)]) {
        isRequired = [bean isDataItemRequired];
    }
    
    if (isRequired) {
        return [NSString stringWithFormat:@"%@*", [bean getDataItemName]];
    }
    else {
        return [bean getDataItemName];
    }
}

- (BOOL)productShouldShow:(WSStoreBean_prod *)aS_product {

    if (![self productSpecMatchTheParams:aS_product]) {
        return NO;
    }

    if (![self matchPType:aS_product]) {
        return NO;
    }
 
    if (![self matchBrand:aS_product]) {
        return NO;
    }
    return YES;
}

- (BOOL)matchBrand:(WSStoreBean_prod *)aS_product {
    
    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
    NSString *brandId = [service queryBrandIdByFilter:self.currentTableItem.filter searchQuestion:self.currentTableItem.opt.searchQuestion];
    WSProdBeanArray *productBeanArray = [WSAppData getObjectbyKey:PRODS];
    WSProdBean *productBean = [productBeanArray getProdWithPid:aS_product.pid];
    
    if ([productBean.brand isEqualToString:brandId]) {
        return YES;
    }
    return NO;
}

- (BOOL)matchPType:(WSStoreBean_prod *)aS_product {
    
    WSProdBeanArray *productBeanArray = [WSAppData getObjectbyKey:PRODS];
    WSProdBean *productBean = [productBeanArray getProdWithPid:aS_product.pid];
    if ([self.currentTableItem.ds isEqualToString:DS_PRODC] && [productBean.pTyp isEqualToString:@"2"]) {
        return YES;
    }
    else if ([self.currentTableItem.ds isEqualToString:DS_PROD] && [productBean.pTyp isEqualToString:@"1"]) {
        return YES;
    }
    return NO;
}

- (BOOL)productSpecMatchTheParams:(WSStoreBean_prod *)aS_product {
    
    BOOL isMatch = YES;
    for (WSFuncsBean_Param *param in self.currentTableItem.paramArray) {
        
        NSInteger index = [param specIndex];
        if (index > 0) {
            
            NSString *productParamResult = [aS_product.item objectAtIndex:index];
            if (![productParamResult isEqualToString:@"1"]) {
                isMatch = NO;
                break;
            }
        }
    }
    return isMatch;
}

- (NSString *)getGridMd5 {
    
    return [self generateGridMd5WithAcvtGenid:self.model.md5];
}

- (NSString *)generateGridMd5WithAcvtGenid:(NSString *)genid {
    
    if ([genid length] > 0) {
        return  [Md5Manager getMd5ByEmpId:genid sotreId:self.currentTableItem.mc bizDate:nil funcCode:nil acvtId:nil memo:nil];
    }
    return  [self createGridMD5];
}

- (NSDictionary *)getAcvtViewForGridDictionaryByIndexPath:(NSIndexPath *)indexPath isReadOnly:(BOOL)isReadOnly {
    
    if(self.data.count <= indexPath.row) {
        return nil;
    }
    
    NSString *productId;
    NSString *productName;
    NSMutableDictionary *pushDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSArray *rowData = [self.data objectAtIndex:indexPath.row];
    
    for(int column = 1; column < rowData.count; ++column) {
        
        if (self.currentTableItem.paramArray.count > column - 1) {
            
            WSGridWidget *gridWidget = rowData[column];
            NSString *widgetKey = [gridWidget widgetKey];
            if (!productId) {
                productId = [[widgetKey componentsSeparatedByString:kKeyProdIdColSeparator] objectAtIndex:0];
            }
            if (!productName) {
                productName = gridWidget.prodName;
            }
            
            WSFuncsBean_Param *param = [self.currentTableItem.paramArray objectAtIndex:column - 1];
            NSString *vaule = nil;
            if (self.prod_cacheDataMDictionary && [self.prod_cacheDataMDictionary objectForKey:widgetKey]) {
                vaule = [self.prod_cacheDataMDictionary objectForKey:widgetKey];
            }
            else {
                vaule = [self getValueWithRowId:productId col:param.col param:nil];
            }
            [pushDictionary setObject:(vaule.length <= 0 ? @"" : vaule) forKey:param.col];
        
            if (![param.isHidden isEqualToString:@"1"]) {
                
                if (isReadOnly){
                    param.readonly = 1;
                }
                else {
                    WSFuncsBean_Param *localParam = [self.currentFunc.paramArray objectAtIndex:column-1];
                    param.readonly = localParam.readonly;
                }
            }
        }
    }
    
    [pushDictionary setObject:(productId.length > 0 ? productId :@"" ) forKey:@"prodId"];
    [pushDictionary setObject:(productName.length > 0 ? productName :@"" ) forKey:@"prodName"];
    
    return [pushDictionary copy];
}

- (void)setDependedInfoWith:(id<WSValidateData>)aProtocal withParam:(WSFuncsBean_Param *)aParam withRow:(NSInteger)aRow andColumn:(NSInteger)aColumn {
    
    if (aProtocal != nil && [aProtocal respondsToSelector:@selector(setNotificationPrefix:andRow:andColumn:andDataType:)]) {
        
        if (aParam.iDependon != nil && [aParam.iDependon length] > 0) {
            
            for (int i = 0; i < [self.currentTableItem.paramArray count]; i++) {
                
                @autoreleasepool {
                    WSFuncsBean_Param *param = [self.currentTableItem.paramArray objectAtIndex:i];
                    if (param.col != nil && [param.col isEqualToString:aParam.iDependon]) {
                        
                        NSString *prefix = [NSString stringWithFormat:@"%@-%@", self.currentQst.mc, aParam.iDependon];
                        [aProtocal setNotificationPrefix:prefix andRow:(int)aRow andColumn:i andDataType:WSValidateDataDependOtherData];
          
                        id<I_W_OptionDataItem> bean = [self.dataSource objectAtIndex:aRow];
                        NSString *rowId = [bean getDataItemID];
                        NSString *cellKey = [WSGridWidget getGridWidgetKeyByRowId:rowId col:aParam.iDependon];
                        NSString *dependCellValue = [_prod_cacheDataMDictionary objectForKey:cellKey] ;
                        if (!dependCellValue || [dependCellValue isEqualToString:@"0"]) {
                            
                            if ([aProtocal isKindOfClass:[UIView class]]) {
                                UIControl *control = (UIControl *)aProtocal;
                                [control setEnabled:NO];
                            }
                        }
                    }
                }
            }
        }
        else {
            
            BOOL bfind = NO;
            for (int i = 0; i < [self.currentTableItem.paramArray count] && !bfind; i++) {
                
                WSFuncsBean_Param *param = [self.currentTableItem.paramArray objectAtIndex:i];
                if (param.iDependon != nil && [param.iDependon length] > 0 && [param.iDependon isEqualToString:aParam.col]) {
                    
                    NSString *prefix = [NSString stringWithFormat:@"%@-%@", self.currentQst.mc, param.iDependon];
                    [aProtocal setNotificationPrefix:prefix andRow:(int)aRow andColumn:(int)aColumn andDataType:WSValidateDataIsDepended];
                    bfind = YES;
                }
            }
        }
    }
}

-(void)addHeaderUI:(NSMutableArray *)arrayUI {
    
    for (id checkBoxObj in arrayUI) {
        
        if ([checkBoxObj isKindOfClass:[WSGridCheckBoxAll class]]) {
            
            WSGridCheckBoxAll *widgetCheckAll = (WSGridCheckBoxAll *)checkBoxObj;
            [self addGroupWidget:widgetCheckAll];
            
            WSCheckBox *checkButton = (WSCheckBox *)[widgetCheckAll getView];
            widgetCheckAll.delegate = self;

            WSFuncsBean_Param *param = widgetCheckAll.param;
            NSInteger countPro = [self.dataSource count];
            for (id <I_W_OptionDataItem> objTemp in self.dataSource) {
                
                for (NSObject <I_W_OptionDataItem> *item in self.m_DataBaseDatas) {
                    
                    NSString *idString = [item getDataItemID];
                    NSString *colString = [item valueForKey:param.col];
                    if ([[objTemp getDataItemID] isEqualToString:idString] && [colString isEqualToString:@"1"]) {
                        countPro = countPro - 1;
                    }
                }
            }
            
            if (countPro < 1) {
                [checkButton setSelected:YES];
            }
        }
    }
}

- (void)setIsValueChange:(BOOL)isValueChange {
    
    _isValueChange = isValueChange;
    [[NSNotificationCenter defaultCenter] postNotificationName:WSAcvtDataGridComponentDataSource_NOTIFY_ISVALUECHANGE object:nil];
}

- (void)pushMoreProducts {
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveMoreProducts:) name:RECEIVEMORE object:nil];
    MoreProductViewController *moreProductView = [[MoreProductViewController  alloc] initWithProductArray:self.moreProductArray title:self.currentFunc.name];
    [self.ownViewController.navigationController pushViewController:moreProductView animated:YES];
}

- (void)receiveMoreProducts:(id)sender {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:RECEIVEMORE object:nil];
    
    NSArray *l_receiveProducts = (NSArray *)[sender object];
    [self addMoreProduct:l_receiveProducts];
    
    if ([self.delegate respondsToSelector:@selector(acvtDataGridComponentDataSource:addedMoreProductWithCount:)]) {
        [self.delegate acvtDataGridComponentDataSource:self addedMoreProductWithCount:self.m_moreProdsCount];
    }
}

- (void)addMoreProduct:(NSArray *)moreProductArray {
    
    if ([moreProductArray count] > 0) {
        self.m_moreProdsCount = [moreProductArray count];
    }
    else {
        self.m_moreProdsCount = -1;
    }
    
    NSMutableArray *newDataSource = [NSMutableArray arrayWithArray:self.dataSource];
    [newDataSource addObjectsFromArray:moreProductArray];
    self.dataSource = newDataSource;
    
    self.data = [self grideViewData];
    [self setProdViewReadOnlyByProductCol];
    
    if (![self isNeedRepeatProd]) {
        
        for (WSProdBean *prodBeanAdded in moreProductArray) {
            for (WSProdBean *prodBean in self.moreProductArray) {
                
                if ([prodBeanAdded.Id isEqualToString:prodBean.Id]) {
                    [self.moreProductArray removeObject:prodBean];
                    break;
                }
            }
        }
    }
    
    if ([moreProductArray count] > 0) {
        
        NSMutableArray *moreProdIdArray = [NSMutableArray arrayWithCapacity:moreProductArray.count];
        for (WSProdBean *prodBeanAdded in moreProductArray) {
            [moreProdIdArray addObject:[prodBeanAdded Id]];
        }
        self.currentTabOpRowId = [moreProdIdArray componentsJoinedByString:@","];
    }
    
    if (moreProductArray.count > 0) {
        
        NSMutableArray *tempDataSource = [NSMutableArray arrayWithArray:self.dataSource];
        NSMutableArray *tempMoreDataSource = [NSMutableArray array];
        NSMutableArray *tempData = [NSMutableArray arrayWithArray:self.data];
        NSMutableArray *tempMoreData = [NSMutableArray array];
        
        for (int i = 0; i < moreProductArray.count; ++i) {
            
            [tempMoreDataSource addObject:[tempDataSource lastObject]];
            [tempDataSource removeLastObject];
            [tempMoreData addObject:[tempData lastObject]];
            [tempData removeLastObject];
        }
        
        NSMutableArray *newDataSource = [NSMutableArray arrayWithArray:tempMoreDataSource];
        [newDataSource addObjectsFromArray:tempDataSource];
        self.dataSource = newDataSource;
        
        NSMutableArray *newData = [NSMutableArray arrayWithArray:tempMoreData];
        [newData addObjectsFromArray:tempData];
        self.data = newData;
    }
}

- (void)delMoreProduct:(NSArray *)removedArray {
    
    if ([self isNeedRepeatProd]) {
        return;
    }

    if ([removedArray count] > 0) {
        
        for (NSInteger i =0 ; i < [removedArray count]; i++) {
            [self.moreProductArray insertObject:removedArray[i] atIndex:i];
        }
    }
}

- (void)resetGridDataView:(NSArray *)receiveProducts {
    
    [self addMoreProduct:receiveProducts];
    
    if (self.m_moreProdsCount > 0) {
        [self showToast:[NSString stringWithFormat:NSLocalizedString(@"add_product_success", nil),(long)self.m_moreProdsCount]];
    }
    else {
        [self showToast:NSLocalizedString(@"no_add_product", nil)];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(acvtDataGridComponentDataSource:addedMoreProductWithCount:)]) {
        [self.delegate acvtDataGridComponentDataSource:self addedMoreProductWithCount:[receiveProducts count]];
    }
}

- (void)reloadDataSourceWith:(NSArray *)prods changeSerieLinkHeadViewTitleWith:(NSString *)brandSerieName {
    
    self.dataSource = prods;
    [self.data removeAllObjects];
    
    self.m_moreProdsCount = 0;
    self.data = [self grideViewData];
    [self setProdViewReadOnlyByProductCol];
    
    if ([self.delegate respondsToSelector:@selector(acvtDataGridComponentDataSource:addedSelectedProductWithCount: changeSerieLinkHeadTitle:)]) {
        NSInteger count = [self.dataSource count];
        [self.delegate acvtDataGridComponentDataSource:self addedSelectedProductWithCount:count changeSerieLinkHeadTitle:brandSerieName];
    }
    self.lastSelectedSerieProdsCount = [prods count];
}

- (void)reloadDataSourceForDeletedAfter {
    
    [self.data removeAllObjects];
    self.data = [self grideViewData];
    
    if ([self.delegate respondsToSelector:@selector(acvtDataGridComponentDataSource:addedSelectedProductWithCount: changeSerieLinkHeadTitle:)]) {

        NSInteger count = [self.dataSource count] - self.lastSelectedSerieProdsCount;
        [self.delegate acvtDataGridComponentDataSource:self addedSelectedProductWithCount:count changeSerieLinkHeadTitle:@"(所有产品)"];
    }
    self.lastSelectedSerieProdsCount = [self.dataSource count];
}

- (void)resetDataSource  {
    
    self.m_moreProdsCount = 0;
    [self.addedEditingProds removeAllObjects];
    [self.data removeAllObjects];
    [self initDataSource];
    [self colunmViewWidth];
    self.data = [self grideViewData];
    [self setProdViewReadOnlyByProductCol];
}

- (void)deleteProdsCache:(NSArray *)prods {
    
    if ([prods count] == 0) {
        return;
    }
   
    BOOL isShowInv = NO;
    NSArray *paramArr =self.currentFunc.paramArray;
    for (int i = 0; i < paramArr.count; i ++) {
        
        WSFuncsBean_Param *param = paramArr[i];
        if ([param.name isEqualToString:@"库存"]&& [param.col isEqualToString:@"inv"]) {
            isShowInv = YES;
            break;
        }
    }
    
    BOOL isNeedSearchDefaultProdDis = NO;
    if ((self.currentTableItem.opt.hNewStyleProdSelect.length > 0 && [self.currentTableItem.opt.hNewStyleProdSelect isEqualToString:@"1"] &&
         [self.currentTableItem.opt.isAddProductStyle isEqualToString:@"acvtList"]) || isShowInv) {
        isNeedSearchDefaultProdDis = YES;
    }
    
    for (WSProdBean *prodBean in prods) {
        
        NSString *pid = prodBean.Id;
        NSArray *tempDictArray = [self.prod_cacheDataDictKeysArray copy];
        for (NSString *keyStr in tempDictArray) {
 
            if ([keyStr hasPrefix:[NSString stringWithFormat:@"%@_", pid]]) {
                [self.prod_cacheDataDictKeysArray removeObject:keyStr];
            }
        }
        
        for (NSString *keyStr in [self.prod_cacheDataMDictionary allKeys]) {
         
            if ([keyStr hasPrefix:[NSString stringWithFormat:@"%@_", pid]]) {
                [_prod_cacheDataMDictionary removeObjectForKey:keyStr];
            }
        }
        for (NSString *keyStr in [self.widgetRoot getGridWidgetAllKeys]) {
  
            if ([keyStr hasPrefix:[NSString stringWithFormat:@"%@_", pid]]) {
                [self.widgetRoot removeGridWidgetByKey:keyStr];
            }
        }
    }
    
    if (isNeedSearchDefaultProdDis) {
        NSString *prodIds = [self getProdIdsStrByData:prods prodIdsStr:@""];
        [self setProductRedisByProdIds:prodIds];
    }
}

- (void)deleteDatasAtIndexSet:(NSIndexSet *)indexSet {
    
    [self.data removeObjectsAtIndexes:indexSet];
  
    for (NSInteger i = 0; i < self.data.count; i++) {
        
        NSArray *rowArray = self.data[i];
        for (NSInteger j = 1; j < [rowArray count]; j++) {
            
            WSGridWidget *gridWidget = rowArray[j];
            [gridWidget setIRow:i];
            [gridWidget setIColumn:j - 1];
            [self setFormula:gridWidget param:gridWidget.param];
            
            id<WSValidateData> view = (id<WSValidateData>)[gridWidget getView];
            if ([view respondsToSelector:@selector(setIRow:)]) {
                [view setIRow:(int)i];
            }
            
            if ([view respondsToSelector:@selector(setIColumn:)]) {
                [view setIColumn:(int)j - 1];
            }
        }
        [self setFormulaValue:rowArray row:i];
    }
}

- (BOOL)needShowScanButton {
    
    WSBaseProductDBService *baseProdctDBService = [[WSBaseProductDBService alloc] init];
    BOOL isMoreProdsContainsBarcode = [baseProdctDBService queryHasBarcodeProductList];
    NSString *isScan = self.currentTableItem.opt.isScan;
    NSString *mServerObjIdForScan = [self.currentQst getAcvtMemo2];
    
    if ((isMoreProdsContainsBarcode || mServerObjIdForScan.length > 0) && [isScan isEqualToString:@"1"]) {
        return YES;
    }
    return NO;
}

- (void)loadLuaScriptWhenInit {
    
    [self loadLuaScriptForInit];
    [self loadLuaScriptForSetValue];
}

- (BOOL)loadValidateLuaScript {
    
    if (![self.currentQst.getReadOnly boolValue] && ![self.currentQst.getIsHidden boolValue]) {
        
        NSString *luaScript = [WSLuaExecutorManager getSubLuaScriptWith:self.currentQst.script ByFuntionName:GRID_VALIDATE_LUA_FUNCTION];
        if ([luaScript length] > 0) {
            
            LogInfo(@"TB scriptStr = %@" ,luaScript);
            if ([self.delegate respondsToSelector:@selector(executeLuaScript:funcName:)]) {
                [self.delegate executeLuaScript:self.currentQst.script funcName:GRID_VALIDATE_LUA_FUNCTION];
            }
            return YES;
        }
    }
    return NO;
}

- (void)loadGridPramLuaScript:(NSString *)scriptString {
    
    if (isInitView) {
        return;
    }
    
    if ([scriptString length] > 0) {
        LogInfo(@"TB scriptStr = %@" ,scriptString);
        if ([self.delegate respondsToSelector:@selector(executeGridParamLuaScript:)]) {
            [self.delegate executeGridParamLuaScript:scriptString];
        }
    }
}

- (void)loadGridPramLuaScript:(NSString *)scriptString  funcName:(NSString *)funcName {
    
    if (isInitView) {
        return;
    }
    
    NSString *script;
    if ([funcName length] > 0) {
        script = [WSLuaExecutorManager getSubLuaScriptWith:scriptString ByFuntionName:funcName];
    }
    else {
        script = scriptString;
    }
    
    if ([script length] > 0) {
        LogInfo(@"TB scriptStr = %@", script);
        if ([self.delegate respondsToSelector:@selector(executeLuaScript:funcName:)]) {
            [self.delegate executeLuaScript:script funcName:funcName];
        }
    }
}

- (void)loadLuaScriptWithFuncName:(NSString *)funcName {
    
    if (isInitView) {
        return;
    }
    
    NSString *script;
    if ([funcName length] > 0) {
        script = [WSLuaExecutorManager getSubLuaScriptWith:self.currentQst.script ByFuntionName:funcName];
    }
    else {
        script = self.currentQst.script;
    }
    
    if ([script length] > 0) {
        LogInfo(@"TB scriptStr = %@", script);
        if ([self.delegate respondsToSelector:@selector(executeLuaScript:funcName:)]) {
            [self.delegate executeLuaScript:self.currentQst.script funcName:funcName];
        }
    }
}

- (void)loadLuaScriptForInit {
    
    [self loadLuaScriptWithFuncName:GRID_INIT_LUA_FUNCTION];
}

- (void)loadLuaScriptForSetValue {
    
    [self loadLuaScriptWithFuncName:GRID_INIT_LUA_FUNTION_SETVALUE];
}

- (void)loadLuaScriptToCompute {
    
    [self loadLuaScriptWithFuncName:GRID_COMPUTE_LUA_FUNCTION];
}

- (void)loadLuaScriptToAddProduct {
    
    [self loadLuaScriptWithFuncName:GRID_ADD_PRODUCT_LUA_FUNCTION];
}

- (void)loadLuaScriptToDelProductWithDelProds:(NSArray *)prods {
    
    NSArray *prodsIdArray = [prods valueForKeyPath:@"Id"];
    self.resultCheck = [prodsIdArray componentsJoinedByString:@","];
    [self loadLuaScriptWithFuncName:GRID_DELETE_PRODUCT_LUA_FUNCTION];
}

- (void)loadQstLuaScriptWithFilter {
    
    if ([self.currentQst.script length] == 0) {
        return;
    }
    
    NSArray *notRunFuncNameArray = @[@"checkProductValidateInTable", @"onCheck", @"addNewRowWithId",@"initGridValue",@"delete",@"addProduct"];
    NSArray *scriptArray = [WSLuaExecutorManager getFilterArrayScriptWith:self.currentQst.script filterFuncNameArray:notRunFuncNameArray];
    self.resultCheck = @"changeValue";
    for (NSString *script in scriptArray) {
        if ([self.delegate respondsToSelector:@selector(executeLuaScript:funcName:)]) {
            [self.delegate executeLuaScript:script funcName:nil];
        }
    }
    self.resultCheck = @"";
}

- (NSString *)getValueWithWidget:(WSGridWidget *)gridWidget {
    
    NSString *result = [gridWidget getValue];
    if (!result) {
        result = @"";
    }
    return result;
}

- (NSString *)getValueWithWidgetKey:(NSString *)widgetKey {
    
    WSGridWidget *gridWidget = [self.widgetRoot getGridWidgetByKey:widgetKey];
    return [self getValueWithWidget:gridWidget];
}

- (NSString *)getValueWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)param {
    
    WSGridWidget *gridWidget = [self getGridWidgetByRowId:rowId col:colName];
    return [self getValueWithWidget:gridWidget];
}

- (NSString *)getParamWidgetValueWithRowId:(NSString *)rowId col:(NSString *)paramCol widgetCacheKey:(NSString *)widgetCacheKey {
    
    WSFuncsBean_Param *aParam = nil;
    NSInteger aIndex = -1;
    
    for (NSInteger i = 0; i < [self.currentTableItem.paramArray count]; i++) {
        WSFuncsBean_Param *param = self.currentTableItem.paramArray[i];
        NSString *tmpCol = param.col;
        if ([tmpCol length] > 0 && [tmpCol isEqualToString:paramCol]) {
            aParam = param;
            break;
        }
    }
    
    for (NSInteger i = 0; i < self.dataSource.count; i ++) {
        id<I_W_OptionDataItem> tempBean = [self.dataSource objectAtIndex:i];
        NSString *beanId = [tempBean getDataItemID];
        if ([rowId isEqualToString:beanId]) {
            aIndex = i;
            break;
        }
    }
    if (aIndex == -1) {
        LogError(@"找不到控件");
        return @"";
    }
    
    NSString *showValue = nil;
    if ([aParam.tpy isEqualToString:COL_TYPNUM] || [aParam.tpy isEqualToString:COL_TYPTEXT] || [aParam.tpy isEqualToString:COL_TYPCHT] || [aParam.tpy isEqualToString:COL_TYPCHTS] ||
        [aParam.tpy isEqualToString:COL_TYPL]) {
        showValue = [self getCurrentViewValueWith:aParam index:aIndex widgetCacheKey:widgetCacheKey];
    }
    else if ([aParam.tpy isEqualToString:COL_TYPDT] || [aParam.tpy isEqualToString:COL_TYPSD]){
        showValue = [self setGrideViewDataKindofSelectListParam:aParam Data:[self.dataSource objectAtIndex:aIndex] withRow:aIndex];
    }
    return showValue;
}

- (void)setValueWithRowId:(NSString *)rowId col:(NSString *)paramCol param:(NSString *)value {
    
    WSGridWidget *gridWidget = [self getGridWidgetByRowId:rowId col:paramCol];
    [gridWidget setValue:value];
}

- (void)setReadOnlyWithRowId:(NSString *)rowId col:(NSString *)paramCol param:(NSString *)param {
    
    BOOL readOnly = [param isEqualToString:@"true"];
    WSGridWidget *gridWidget = [self getGridWidgetByRowId:rowId col:paramCol];
    [gridWidget setReadonly:readOnly];
}

- (void)setTextColorWithRowId:(NSString *)rowId col:(NSString *)paramCol colorHexString:(NSString *)colorHexString {
    
     UIView *view = [self getViewWithRowId:rowId col:paramCol];
     if (!view) {
         return;
     }
     
     if ([view isKindOfClass:[WSHTextField class]]) {
         WSHTextField *textField = (WSHTextField *)view;
         textField.textColor = [UIColor colorWithHexString:colorHexString];
   
     }
}
- (UIView *)getViewWithRowId:(NSString *)rowId col:(NSString *)paramCol{
 
    return [self getViewWithRowId:rowId col:paramCol rowIdNumber:nil];
}

-(UIView *)getViewWithRowId:(NSString *)rowId col:(NSString *)paramCol rowIdNumber:(NSString*)rowIdNumber {
    
    if ([self.dataSource count] == 0 || !self.data || [self.data count] == 0) {
        return nil;
    }
    
    if ([rowId isKindOfClass:[NSNumber class]]) {
        rowId = [NSString stringWithFormat:@"%@",rowId];
    }
    if ([rowId length] == 0 || [paramCol length] == 0) {
        return nil;
    }

    NSMutableArray *prodIds = [NSMutableArray array];
    for (NSInteger i = 0; i < [self.dataSource count]; i++) {
        
        NSObject <I_W_OptionDataItem> *object = self.dataSource[i];
        NSString *itemId = [object getDataItemID];
        if ([self isNeedRepeatProd]) {
            
            itemId = [object getCacheKeyID];
            if ([itemId length] > 0) {
                [prodIds addObject:itemId];
            }
            else {
                [prodIds addObject:[NSString stringNotNilWithValue:itemId]];
            }
        }
        else {
            
            if ([itemId isKindOfClass:[NSNumber class]]) {
                itemId = [NSString stringWithFormat:@"%@",itemId];
            }
            
            if ([itemId length] > 0) {
                [prodIds addObject:itemId];
            }
            else {
                [prodIds addObject:[NSString stringNotNilWithValue:itemId]];
            }
        }
    }
    
    NSInteger prodIdIndex = [prodIds indexOfObject:rowId];
    if ([self isNeedRepeatProd] && prodIdIndex == NSNotFound) {
        
        for (NSInteger i = 0; i < prodIds.count; i++) {
            if ([prodIds[i] rangeOfString:rowId].location != NSNotFound) {
                prodIdIndex = i;
            }
        }
    }
    
    if (prodIdIndex == NSNotFound) {
        
        LogInfo(@"Run Lua Script Error: Not Found rowId:%@", rowId);
        return nil;
    }

    NSMutableArray *paramCols = [NSMutableArray array];
    for (NSInteger i = 0; i < [self.currentTableItem.paramArray count]; i++) {
        
        WSFuncsBean_Param *param = self.currentTableItem.paramArray[i];
        NSString *tmpCol = param.col;
        if ([tmpCol length] > 0) {
            [paramCols addObject:tmpCol];
        }
        else {
            [paramCols addObject:[NSString stringNotNilWithValue: tmpCol]];
        }
    }
    
    NSInteger colIndex = [paramCols indexOfObject:paramCol];
    if (colIndex == NSNotFound) {
        LogInfo(@"Run Lua Script Error: Not Found paramCol:%@", paramCol);
        return nil;
    }

    if (prodIdIndex >= [self.data count]) {
        return nil;
    }
    
    NSArray *rowViews = self.data[prodIdIndex];
    UIView *view = rowViews[colIndex+1];
    return view;
}

- (void)saveTableDataToDB {
    
    [self deleteTableDataFromDB:nil];
    [WSAcvtDataGridComponentService insertDataToTableWithWSAcvtDataGridComponentDataSource:(WSAcvtDataGridComponentDataSource*)self];
}

- (void)deleteTableDataFromDB:(NSArray *)prodIds {
    
    if ([self.currentTableItem.ds isEqualToString:DS_PROD] || [self.currentTableItem.ds isEqualToString:DS_PRODC]) {
        [[WSProductTable sharedTable] deleteProductWithGenId:[self getGridMd5] prodIds:prodIds];
    }
}

- (NSString *)getCurrentTabOpRowId {
    
    return self.currentTabOpRowId ? self.currentTabOpRowId : @"";
}

- (void)initTableDataAndCellData:(NSString *)param {
    
    [self.prod_cacheDataMDictionary removeAllObjects];
    [self.data removeAllObjects];
    
    NSMutableArray *allProdIds = [NSMutableArray array];
    NSMutableArray *dataSource = [NSMutableArray array];
    
    if ([param length] > 0) {
        
        NSArray *prodArr = [param componentsSeparatedByString:@"|"];
        for (NSString *item in prodArr) {
            
            if ([item length] == 0) {
                break;
            }
            
            NSArray *itemArr = [item componentsSeparatedByString:@","];
            if ([itemArr count] > 3) {
                
                NSString *prodId = itemArr[0];
                NSString *cellValue = itemArr[2];
                NSString *colName = itemArr[3];
                NSString *cellKey = [WSGridWidget getGridWidgetKeyByRowId:prodId col:colName];
                if (![allProdIds containsObject:prodId]) {
                    
                    NSString *prodName = itemArr[1];
                    WSProdBean *prodBean = [[WSProdBean alloc] init];
                    prodBean.name = prodName;
                    prodBean.prodName = prodName;
                    prodBean.Id = prodId;
                    [dataSource addObject:prodBean];
                    [allProdIds addObject:prodId];
                }
                
                NSString *oldCellValue = [self.prod_cacheDataMDictionary objectForKey:cellKey];
                if (oldCellValue && [oldCellValue floatValue] > 0) {
                    
                    CGFloat fOldValue = [oldCellValue floatValue] + [cellValue floatValue];
                    cellValue = [NSString stringWithFormat:@"%lf", fOldValue];
                }
                
                [self.prod_cacheDataMDictionary setObject:cellValue forKey:cellKey];
            }
        }
        
        self.m_moreProdsCount = 0;
    }

    self.dataSource = dataSource;
    self.data = [self grideViewData];
    [self setProdViewReadOnlyByProductCol];
    
    for (NSString *prodId in allProdIds) {
        for (WSFuncsBean_Param *fParam in self.currentTableItem.paramArray) {
            
            NSString *keyStr =  [WSGridWidget getGridWidgetKeyByRowId:prodId col:fParam.col dictionary:[self getGridWidgetDictionary]];
            NSString *valueStr = [self.prod_cacheDataMDictionary objectForKey:keyStr];
            if (valueStr && valueStr.length > 0) {
                [self setValueWithRowId:prodId col:fParam.col param:valueStr];
            }
        }
    }
    
    [self loadLuaScriptToAddProduct];
}

- (NSMutableDictionary *)getGridWidgetDictionary {
    
    BOOL isNeedRepeatProd = [self isNeedRepeatProd];
    NSMutableDictionary *dictionary = nil;
    if (isNeedRepeatProd) {
        dictionary = [NSMutableDictionary dictionary];
    }
    return dictionary;
}

- (void)runColumLuaScriptByWidgetKey:(NSString *)widgetKey {
    
    NSString *value = [self getValueWithWidgetKey:widgetKey];
    NSArray *keyArray = [widgetKey componentsSeparatedByString:kKeyProdIdColSeparator];
    if ([keyArray count] != 2) {
        LogError(@"WidgetKey 格式错误");
        return;
    }
    
    NSString *itemId = [keyArray objectAtIndex:0];
    NSString *col = [keyArray objectAtIndex:1];
    NSString *sid = @"";
    if (self.currentStore && [self.currentStore.Id length] > 0) {
        sid = self.currentStore.Id;
    }
    
    self.resultCheck = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", itemId,LUA_SEPARATOR, self.md5, LUA_SEPARATOR,sid, LUA_SEPARATOR,value];
    for (WSFuncsBean_Param *param  in self.currentTableItem.paramArray) {
        
        if ([param.col isEqualToString:col]) {
            
            NSString *paramValue = param.value;
            if ([param.value length] > 0 && [paramValue rangeOfString:@"function"].location != NSNotFound) {
                if (!self.isExecutingExepComputeWhenInit) {
                    [self loadGridPramLuaScript:param.value];
                }
            }
        }
    }

    self.currentTabOpRowId = itemId;
    [self loadQstLuaScriptWithFilter];
}

- (void)dataSourceRunScriptWithParam:(WSFuncsBean_Param *)param WidgetKey:(NSString *)widgetKey luaFunctionName:(NSString *)functionName result:(NSString *)result
              scanListViewController:(WSScanListViewController *)scanListViewController {
    
    NSArray *keyArray = [widgetKey componentsSeparatedByString:kKeyProdIdColSeparator];
    if ([keyArray count] != 2) {
        LogError(@"WidgetKey 格式错误");
        return;
    }
    
    NSString *itemId = [keyArray objectAtIndex:0];
    NSString *col = [keyArray objectAtIndex:1];
    NSString *paramValue = param.value;
    if ([param.value length] > 0 && [paramValue rangeOfString:@"function"].location != NSNotFound) {
        
        if (!self.isExecutingExepComputeWhenInit) {
            if ([param.value rangeOfString:functionName].location != NSNotFound) {
                if (scanListViewController) {
                    if ([self.delegate isKindOfClass:[WSAcvtDataGridViewPanel class]]) {
                        
                        WSAcvtDataGridViewPanel *gridPanel  = (WSAcvtDataGridViewPanel *)self.delegate;
                        gridPanel.scanListViewController = scanListViewController;
                    }
                }
                
                if (result) {
                    self.resultCheck = result;
                }
                else {
                    self.resultCheck = [NSString stringWithFormat:@"@#%@@#%@", itemId,col];
                }
                
                [self loadGridPramLuaScript:param.value funcName:functionName];
            }
            
            [WSSetResultExecutor sharedInstance].luaScript = param.value;
        }
    }
    self.resultCheck = @"";
}

- (void)runAllColumsLuaScriptWhenValueChanged {
    
    if ([self.formulaDictionary count] > 0) {
        
        NSArray *tfArray = [self.formulaDictionary allValues];
        for (NSObject *obj in tfArray) {
            
            NSArray *keysArray = [self.formulaDictionary allKeys];
            NSString *elementKey = [self getFormulaElementKeyForObject:obj];
            if (elementKey && [elementKey length] > 0) {
                
                for (NSString *item in keysArray) {
                    if (([item rangeOfString:@"value"].length > 0)&&([item rangeOfString:elementKey].length > 0)) {
                        
                        BOOL isNeedCompute = YES;
                        if (self.isExecutingExepComputeWhenInit) {

                            NSNumber *isExist = [self.executedExepDictionaryWhenInit objectForKey:item];
                            if (isExist) {
                                isNeedCompute = NO;
                            }
                        }

                        id tempText = [self.formulaDictionary objectForKey:item];
                        if ([tempText isKindOfClass:[WSHTextField  class]]) {
                            
                            WSHTextField *tempTextField = (WSHTextField *) tempText;
                            if (isNeedCompute && tempTextField.isValueChange) {
                                [self updateValueInTextFiled:[self.formulaDictionary objectForKey:item] formulaString:item];
                            }
                        }
                        else {
                            
                            if (isNeedCompute) {
                                [self updateValueInTextFiled:[self.formulaDictionary objectForKey:item] formulaString:item];
                            }
                        }
                        
                        if (self.isExecutingExepComputeWhenInit) {
                            [self.executedExepDictionaryWhenInit setObject:@1 forKey:item];
                        }
                    }
                }
            }
        }
    }
}

- (void)textFieldTextDidChange:(id)sender {
   
    if ([sender isKindOfClass:[NSNotification class]]) {
        
        NSNotification *notification = (NSNotification *)sender;
        if ((notification.object && [notification.object isKindOfClass:[WSHTextField class]]) || [notification.object isKindOfClass:[WSNRLabel class]]) {
            [self textDidChangeForTextField:notification.object];
        }
        else {
            [self textDidChangeForTextField:nil];
        }
    }
 
    if ([sender isKindOfClass:[NSNotification class]]) {
        
        WSHTextField *currentClickTextField = [sender object];
        NSString *widgetKey = [currentClickTextField gridWidgetKey];
        [self runColumLuaScriptByWidgetKey:widgetKey];
    }
    
    if ([self.delegate respondsToSelector:@selector(acvtDataGridComponentDataSource:didChange:)]) {
        [self.delegate acvtDataGridComponentDataSource:self didChange:sender];
    }
}

- (void)textDidChangeForTextField:(WSHTextField *)textFiled {
    
    if (textFiled) {
        
        WSHTextField *tempTextField = textFiled;
        if ([self.formulaDictionary count] > 0) {
            
            NSArray *tfArray = [self.formulaDictionary allValues];
            if ([tfArray containsObject:tempTextField]) {
                
                NSString *elementKey = [self getFormulaElementKeyForObject:tempTextField];
                if (elementKey && [elementKey length] > 0) {
                    
                    NSArray *keysArray = [self.formulaDictionary allKeys];
                    for (NSString *item in keysArray) {
                        
                        if (([item rangeOfString:@"value"].length > 0)&&([item rangeOfString:elementKey].length > 0)) {
                    
                            BOOL isNeedCompute = YES;
                            if (self.isExecutingExepComputeWhenInit) {

                                NSNumber *isExist = [self.executedExepDictionaryWhenInit objectForKey:item];
                                if (isExist) {
                                    isNeedCompute = NO;
                                }
                            }
  
                            if (isNeedCompute) {
                                [self updateValueInTextFiled:[self.formulaDictionary objectForKey:item] formulaString:item];
                            }
                            
                            if (self.isExecutingExepComputeWhenInit) {
                                [self.executedExepDictionaryWhenInit setObject:@1 forKey:item];
                            }
                        }
                    }
                }
            }
        }
        
        if (!self.isExecutingExepComputeWhenInit) {
            [self loadLuaScriptToCompute];
        }
    }
}

- (NSString *)getFormulaElementKeyForObject:(id)obj {
    
    NSArray *formularArrayForObj = [self.formulaDictionary allKeysForObject:obj];
    NSString *elementKey = nil;
    for (NSString *formular in formularArrayForObj) {
        
        if ([formular rangeOfString:@"value"].location == NSNotFound && [formular rangeOfString:@"max"].location == NSNotFound) {
            elementKey = formular;
            break;
        }
    }
    
    return elementKey;
}

- (NSString *)stringByReplaceingOccurrentOfBrace:(NSString *)calString {
    
    NSError *error;
    NSString *pattern = @"\\{(.*?)\\}";
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *checkingResults = [regular matchesInString:calString options:0 range:NSMakeRange(0, calString.length)];
    NSMutableArray *matchs = [NSMutableArray array];
    
    for (NSTextCheckingResult *matchResult in checkingResults) {
        NSRange matchRange = [matchResult range];
        NSString *matchString = [calString substringWithRange:matchRange];
        [matchs addObject:matchString];
    }
    
    for (NSInteger i = 0; i < [matchs count]; i++) {
        NSString *matchString = [matchs objectAtIndex:i];
        calString = [calString stringByReplacingOccurrencesOfString:matchString withString:[NSString stringWithFormat:@"%f",0.0]];
    }
    return calString;
}

- (void)updateValueInTextFiled:(UIView *)textFiled formulaString:(NSString *)formulaString {
    
    NSString *key = formulaString;
    NSRange range = [key rangeOfString:@"value"];
    if (NSNotFound != range.location) {
        
        NSString *calString = [key substringFromIndex:(range.location + range.length)];
        NSArray *keysArray = [self.formulaDictionary allKeys];
        for (NSString *item in keysArray) {
            
            if (!([item rangeOfString:@"value"].length > 0) && [calString rangeOfString:item].length > 0) {
                
                id tempText = [self.formulaDictionary objectForKey:item];
                NSString *textValue = nil;
                if ([tempText isKindOfClass:[WSHTextField  class]]) {
                  
                    WSHTextField *textField = (WSHTextField *)tempText;
                    textValue = [textField getTextValue];
                }
                else if ([tempText isKindOfClass:[UITextField  class]]) {
                   
                    UITextField *textField = (UITextField *)tempText;
                    textValue = textField.text;
                }
                else if ([tempText isKindOfClass:[WSNRLabel class]]) {
                    WSNRLabel *label = (WSNRLabel *)tempText;
                    textValue = label.text;
                }
                
                if ([textValue length] > 0) {
                    calString  = [calString stringByReplacingOccurrencesOfString:item withString:[NSString stringWithFormat:@"%f" ,textValue.doubleValue]];
                }
            }
        }
        
        NSString *result = [self stringByReplaceingOccurrentOfBrace:calString];
        if ([result rangeOfString:@"{"].location != NSNotFound) {
            
            if ([textFiled isKindOfClass:[UITextField class]]) {
                ((UITextField *)textFiled).text = @"";
                return;
            }
            else if ([textFiled isKindOfClass:[WSNRLabel class]]) {
                ((WSNRLabel *)textFiled).text = @"";
            }
        }
        
        NSString *value = [[WSLuaScript getInstance] arithmeticExpressions:result];
        if ([textFiled isKindOfClass:[WSHTextField  class]]) {
            
            WSHTextField * wstextfield = (WSHTextField *)textFiled;
            if (([wstextfield.m_min length] > 0 && ([value floatValue] < [wstextfield.m_min floatValue])) || ([wstextfield.m_max length] > 0 && ([value floatValue] > [wstextfield.m_max floatValue]))) {
                wstextfield.text = nil;
            }
            else {
               
                if ([value floatValue] != 0.0) {
                    wstextfield.text = value;
                }
                else{
                    wstextfield.text = nil;
                }
            }
            
            NSString *elementKey = [self getFormulaElementKeyForObject:wstextfield];
            if (elementKey && [elementKey length] > 0) {
                [self textDidChangeForTextField:wstextfield];
            }
        }
    }
}

- (BOOL)updateMaxInTextField:(UITextField *)textField tip:(NSString *)tip replacementString:(NSString *)string {
    
    BOOL willUpdate = YES;
    NSString *key = [[self.maxValueFormulaDictionary allKeysForObject:textField] firstObject];
    NSString *rangeString = @"max";
    NSArray *keysArray = keysArray = [self.maxValueFormulaDictionary allKeys];
    NSRange range = [key rangeOfString:rangeString];
    NSString *calString = [key substringFromIndex:(range.location + range.length)];

    BOOL formulaError = NO;
    for (NSString *item in keysArray)  {
        
        if (!([item rangeOfString:rangeString].length > 0) && [calString rangeOfString:item].length > 0 ) {
            
            id tempView = [self.maxValueFormulaDictionary objectForKey:item];
            if ([tempView isKindOfClass:[WSHTextField  class]]) {
                
                WSHTextField *textField = (WSHTextField *)tempView;
                if (textField.text && [[textField getTextValue] length] > 0) {
                    calString  = [calString stringByReplacingOccurrencesOfString:item withString:[NSString stringWithFormat:@"%f" , [textField getTextValue].doubleValue]];
                }
                else{
                    formulaError = YES;
                }
            }
            else if ([tempView isKindOfClass:[UITextField  class]]) {
                
                UITextField *textField = (UITextField *)tempView;
                if (textField.text && [textField.text length] > 0) {
                    calString  = [calString stringByReplacingOccurrencesOfString:item withString:[NSString stringWithFormat:@"%f" ,textField.text.doubleValue]];
                }
                else{
                    formulaError = YES;
                }
            }
            else if ([tempView isKindOfClass:[WSNRLabel class]]) {
                
                WSNRLabel *label = (WSNRLabel *)tempView;
                if (label.text && [label.text length] > 0) {
                    calString  = [calString stringByReplacingOccurrencesOfString:item withString:[NSString stringWithFormat:@"%f" ,label.text.doubleValue]];
                }
                else{
                    formulaError = YES;
                }
            }
        }
    }
    
    NSString *result = [self stringByReplaceingOccurrentOfBrace:calString];
    if ([result rangeOfString:@"{"].location != NSNotFound) {
        textField.text = @"";
        return NO;
    }
    
    NSString *paramName = nil;
    NSInteger textFieldInColumn = [(WSHTextField *)textField iColumn];
    if (textFieldInColumn < [self.currentTableItem.paramArray count]) {
        WSFuncsBean_Param *param = [self.currentTableItem.paramArray objectAtIndex:textFieldInColumn];
        paramName = param.name;
    }
    
    NSString *value = [[WSLuaScript getInstance] arithmeticExpressions:result];
    NSString *alterTitle = [NSString stringWithFormat:@"%@最大只能输入%@",paramName,value];
    NSString *validatedString = [NSString stringWithFormat:@"%@%@",textField.text,string];
    if (([validatedString floatValue] > [value floatValue]) && [value floatValue] > 0) {
        
        if (tip && [tip length] > 0) {
            [self performSelector: @selector(showMaxAlterWith:) withObject:tip afterDelay:0.1];
        }
        else {
            [self showMaxAlterWith:alterTitle];
            willUpdate = NO;
        }
    }
    return willUpdate;
}

- (void)showMaxAlterWith:(NSString *)alterTitle {
    
    NSString *destructiveTitle = [NSString stringWithFormat:NSLocalizedString(@"confirm", nil)];
    UIAlertController *alterController = [UIAlertController alertControllerWithTitle:alterTitle message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *destructiveAction = [UIAlertAction actionWithTitle:destructiveTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
    }];
    [alterController addAction:destructiveAction];
    [self.ownViewController presentViewController:alterController animated:YES completion:nil];
}

- (void)showAlertView:(NSString*)aMsg {
    
    if (aMsg && ![aMsg isEqualToString:@""]) {
        [MBProgressHUD showHUDAddedTo:self.ownViewController.view withText:[NSString stringWithFormat:NSLocalizedString(@"not_filled", nil),aMsg] tips:nil tapTarget:nil
                               action:nil type:MBProgressHUDMessageTypeFailed];
    }
}

- (void)showToast:(NSString *)message {
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:message tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
}

- (void)setGridViewDataSourceKindOfSelectList:(WSDropListView *)list param:(WSFuncsBean_Param *)aParam Data:(id)aData withRow:(NSInteger)aIndex {
    
    if ([aParam.tpy isEqualToString:COL_TYPDT] || [aParam.tpy isEqualToString:COL_TYPSD]) {
        
        NSString *dataSourceCacheKey = [NSString stringWithFormat:@"%@%@", aParam.ids, aParam.filter];
        NSMutableArray *dataSourceArray = self.dataSourceCache[dataSourceCacheKey];
        if (!dataSourceArray) {
            
            dataSourceArray = [self getDropListRedisByParam:aParam parentId:nil data:aData];
            if ([aParam.tpy isEqualToString:COL_TYPDT]) {
                
                if ([dataSourceArray count] > 0) {
                    
                    WSBaseOptionDataItem *cancelItem = [[WSBaseOptionDataItem alloc] init];
                    cancelItem.itemID = kCancelItemId;
                    cancelItem.itemName = kCancelItemName;
                    if (aParam.readonly != 1) {
                        [dataSourceArray insertObject:cancelItem atIndex:[dataSourceArray count]];
                    }
                }
            }
            
            if (dataSourceCacheKey && dataSourceCacheKey.length > 0 && dataSourceArray) {
                [self.dataSourceCache setObject:dataSourceArray forKey:dataSourceCacheKey];
            }
        }
        
        list.dataSourceArray = dataSourceArray;
        
        if ([aParam isRealtime]) {
            
            list.searchObjId = aParam.ids;
            list.searchStoreId = self.currentStore.Id;
            list.selectType = WSDropListViewTypeServerSearchBarShow;

            WSBaseStoreOtherDataDBService *dbService = [[WSBaseStoreOtherDataDBService alloc] init];
            NSArray *dataArray = [dbService queryWithType:aParam.ids];
            if ([dataArray count] > 0) {
                
                NSMutableArray *tempDataArray = [NSMutableArray array];
                for (WSBaseStoreOtherDataObject *dataObject in dataArray) {
                    WSBaseOptionDataItem *dataItem = [[WSBaseOptionDataItem alloc] init];
                    dataItem.itemID = dataObject.item1;
                    dataItem.itemName = dataObject.item2;
                    [tempDataArray addObject:dataItem];
                }
                list.dataSourceArray = tempDataArray;
            }
        }
    }
}

- (NSMutableArray *)getDropListRedisByParam:(WSFuncsBean_Param *)aParam parentId:(NSString *)parentId data:(id)aData {
    
    NSMutableArray *dataSourceArray = [[NSMutableArray alloc] init];
    if ([aParam.ids isEqualToString:@"storeacvtdis,acvtdis"]) {
        
        WSDataSourceFromDSStoreAcvtDisAndAcvtDis *dsObj = [[WSDataSourceFromDSStoreAcvtDisAndAcvtDis alloc] init];
        dsObj.parentSelectedItemID = parentId;
        dataSourceArray = [[dsObj getDataSourceByFilter:aParam.filter storeID:self.currentStore.Id] mutableCopy];
    }
    else if ([aParam.ids isEqualToString:@"prod"]) {
        
        WSBaseProductDBService *service = [[WSBaseProductDBService alloc] init];
        dataSourceArray = (NSMutableArray *)[service queryProductsWithCondition:aParam.filter];
    }
    else if ([aParam.ids isEqualToString:@"promotion:pinfo"] && [aData isKindOfClass:[WSProdBean class]]) {
        
        WSProdBean *prodBean = (WSProdBean *)aData;
        WSBaseStoreOtherDataDBService *dbService = [[WSBaseStoreOtherDataDBService alloc] init];
        dataSourceArray = (NSMutableArray *)[dbService queryWithType:aParam.ids withItem16:prodBean.Id];
    }
    else {
        
        WSDataSourceFromDSDicts *dsObj = [[WSDataSourceFromDSDicts alloc] init];
        dsObj.parentSelectedItemID = parentId;
        dataSourceArray = [[dsObj getDataSourceByFilter:aParam.filter] mutableCopy];
    }
    return dataSourceArray;
}

- (NSString *)setGrideViewDataKindofSelectListParam:(WSFuncsBean_Param *)aParam Data:(id)aData withRow:(NSInteger)aIndex {
    
    NSString *showValue = nil;
    if ([aParam.tpy isEqualToString:COL_TYPDT] || [aParam.tpy isEqualToString:COL_TYPSD]) {
        
        if ([aParam.tpy isEqualToString:COL_TYPDT]) {
            
            if ([self.gridDataSource serverRedisWith:aParam]) {
                
                if ([self respondsToSelector:@selector(getDefaultDataWithParam:Others:)]) {
                    showValue = [self performSelector:@selector(getDefaultDataWithParam:Others:) withObject:aParam withObject:aData];
                }
            }
            
            BOOL isNewStyleProdSelectWithAcvtList = self.currentTableItem.opt.hNewStyleProdSelect.length > 0 && [self.currentTableItem.opt.hNewStyleProdSelect isEqualToString:@"1"] &&
                                                    [self.currentTableItem.opt.isAddProductStyle isEqualToString:@"acvtList"] && _isInNewAcvt;
            if (!isNewStyleProdSelectWithAcvtList) {
                
                NSString *l_quary_value = [self getDatasFromDataBase:aParam Data:aData];
                if (l_quary_value && [l_quary_value length] > 0) {
                    showValue = l_quary_value;
                }
                else if ([self.m_DataBaseDatas count] > 0) {
                    showValue = l_quary_value;
                }
            }
        }
        else if ([aParam.tpy isEqualToString:COL_TYPSD]) {
        
            if ((aParam.readonly != 1) || !aParam.redis) {
                showValue = [self getDatasFromDataBase:aParam Data:aData];
            }
        }
    }
    
    return showValue;
}

- (NSString*)getDatasFromDataBase:(WSFuncsBean_Param*)aParam Data:(id <I_W_OptionDataItem>)aData {
    
    NSString *value = nil;
    for (NSObject <I_W_OptionDataItem> *tempData in self.m_DataBaseDatas) {
        if ([[tempData getDataItemID] isEqualToString:[aData getDataItemID]]) {
            value = [tempData valueForKey:aParam.col];
        }
    }
    
    if (value != nil && ![value isEqualToString:@"null"]) {
        return value;
    }
    return nil;
}

- (WSGridDataSourceReplaceStatus)getTextFieldReplaceStatus:(WSHTextField *)textField replacementString:(NSString *)string columnTip:(NSString *)textFieldColumnTip {
 
    if ([self.maxValueFormulaDictionary count] > 0) {
        
        NSArray *mfArray = [self.maxValueFormulaDictionary allValues];
        if ([mfArray containsObject:textField]) {
            
            NSArray *keysArray = [self.maxValueFormulaDictionary allKeys];
            NSString *col = [[self.maxValueFormulaDictionary allKeysForObject:textField] firstObject];
            if (col && [col length] > 0) {
                
                for (NSString *item in keysArray)  {
                    
                    if (([item rangeOfString:@"max"].length > 0)&&([item rangeOfString:col].length > 0)) {
                        
                        BOOL willReplace  =  [self updateMaxInTextField:[self.maxValueFormulaDictionary objectForKey:item]tip:textFieldColumnTip replacementString:string];
                        if (willReplace) {
                            return WSGridDataSourceReplaceStatusYES;
                        }
                        else {
                            return WSGridDataSourceReplaceStatusNo;
                        }
                    }
                }
            }
        }
    }
    
    return WSGridDataSourceReplaceStatusNone;
}

- (void)reloadSubViewsValueWith:(NSString *)qstValueGenId dis:(NSArray *)dis {
    
    NSInteger fcIndex = [self getProdSpecIndexWithContent:@"funccode"];
    NSUInteger genIdIndex = [self getProdSpecIndexWithContent:@"genid"];
    NSString *redis = nil;
    for (NSInteger i = 0; i < [self.data count]; i++) {
        
        NSArray *rowViews = self.data[i];
        NSObject<I_W_OptionDataItem> * object = self.dataSource[i];
        NSString *objectId = [object getDataItemID];
        
        for (NSInteger j = 0 ; j < [self.currentTableItem.paramArray count]; j++) {
            
            WSFuncsBean_Param *param = self.currentTableItem.paramArray[j];
            NSInteger parmIndex = [self getProdspecRedisIndexbyParam:param];
            WSGridWidget *gridWidget =  rowViews[j+1];
            UIView *view = [gridWidget getView];
            for (NSInteger m = 0 ; m < [dis count]; m++) {
                
                BOOL findStoreId = NO;
                NSDictionary *disDic = dis[m];
                NSArray *pArray = [disDic[@"p"] componentsSeparatedByString:@","];
                NSString *storeId = [pArray objectAtIndex:0];
                NSString *pId = [pArray objectAtIndex:1];
                NSString *genId = nil;
                
                if (genIdIndex != NSNotFound) {
                    if ([pArray count] > genIdIndex) {
                        genId = pArray[genIdIndex];
                    }
                }
                
                if (![storeId isEqualToString:@"-1"]) {
                    if ([storeId isEqualToString:self.currentStore.Id]
                        &&[objectId isEqualToString:pId]) {
                        findStoreId = YES;
                    }
                }
                else {
                    if ([objectId isEqualToString:pId]) {
                        findStoreId = YES;
                    }
                }
                
                if (findStoreId && [genId length] > 0) {
                    
                    if ([qstValueGenId length] > 0) {
                        if ([genId isEqualToString:qstValueGenId]) {
                            findStoreId = YES;
                        }
                        else {
                            findStoreId = NO;
                        }
                    }
                }
                
                NSString *funcode = nil;
                if (-1 != fcIndex && pArray.count > fcIndex) {
                    funcode = [pArray objectAtIndex:fcIndex];
                }
               
                if (findStoreId) {
                    
                    if (fcIndex > -1 && ([funcode isEqualToString:self.currentQst.mc] || [funcode isEqualToString:self.currentFunc.fc])) {
                        if (parmIndex != NSNotFound) {
                            redis = [pArray objectAtIndex:parmIndex];
                        }
                    }
                    else if (fcIndex == -1 && !funcode) {
                        
                        if (parmIndex != NSNotFound) {
                            redis = [pArray objectAtIndex:parmIndex];
                        }
                    }
                }
            }
            
            if ([redis length] > 0) {
                
                if ([view isKindOfClass:[WSHTextField class]]) {
                    WSHTextField *textField = (WSHTextField *)view;
                    textField.text = redis;
                }
                else if ([view isKindOfClass:[WSNRLabel class]]) {
                    WSNRLabel *nrLabel = (WSNRLabel *)view;
                    nrLabel.text =redis;
                }
            }
        }
    }
}

- (void)setReadonly:(BOOL)readonly isInitFisrt:(BOOL)isFirst {
    
    NSArray *allKeys = [self.widgetRoot getGridWidgetAllKeys];
    for (NSString *key in allKeys) {
        
        WSGridWidget *widget = [self.widgetRoot getGridWidgetByKey:key];
        if ([widget isKindOfClass:[WSGridWidget class]]) {
            [widget setReadonly:readonly];
        }
    }
}

- (void)popupDropListViewDidAppear:(WSDropListView *)dropListView {
    
    if (self.ownViewController) {
        
        self.currentSelectListView = dropListView;
        WSSingleSelectAndSearchViewController *ssvc = [[WSSingleSelectAndSearchViewController alloc]init];
        ssvc.selectedDelegate = self;
        [ssvc setItemArray:dropListView.dataSourceArray];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:ssvc];
        [self.ownViewController presentViewController:nc animated:YES completion:nil];
    }
}

- (void)singleSelectAndSearchView:(WSSingleSelectAndSearchViewController *)singleSelectAndSearchView didSelectedItem:(id<I_W_OptionDataItem>)item {
    
    self.currentSelectListView.selectedItem = item;
}

- (void)setDefautValueForUnit {
    
    if (![self.currentTableItem.opt.jumpToInput isEqualToString:@"1"]) {
        return;
    }
    
    NSMutableArray *unitCols = [NSMutableArray new];
    for (WSFuncsBean_Param * param in self.currentTableItem.paramArray) {
        if ([param.ids isEqualToString:@"dicts"] && [param.filter isEqualToString:@"prodUnit"]) {
            [unitCols addObject:param.col];
        }
    }
    
    if (unitCols.count > 0) {
        
        WSBaseStoreOtherDataDBService *service = [[WSBaseStoreOtherDataDBService alloc] init];
        NSArray *otherDataArray = [service queryProductUnit];
        NSString *tempProdId = @"";
        NSString *tempProdUnit = @"";
        NSString *prodId = @"";
        NSString *col = @"";
        int i = 0;
        for (WSBaseStoreOtherDataObject *otherObject in otherDataArray) {
            
            tempProdId = otherObject.item1;
            tempProdUnit = otherObject.item2;
            if ([prodId isEqualToString:tempProdId]) {
                i++;
            }
            else {
                prodId = tempProdId;
                i = 0;
            }
            
            if (i < unitCols.count) {
                col = unitCols[i];
                [self setValueWithRowId:prodId col:col param:tempProdUnit];
                [_prod_cacheDataMDictionary setObject:tempProdUnit forKey:[WSGridWidget getGridWidgetKeyByRowId:prodId col:col dictionary:[self getGridWidgetDictionary]]];
            }
        }
    }
}

- (void)setProductDefautValueForCacheDic {
    
    for (WSProdBean *prod in self.moreProductArray) {
        for (WSFuncsBean_Param *aParam in self.currentTableItem.paramArray) {
            
            NSString *colValue = nil;
            if ([aParam.ids length] > 0) {
                colValue = [prod valueForKey:aParam.ids];
            }
            else if (aParam.idefault.length > 0 && ![aParam.idefault isEqualToString:@"0"]){
                colValue = aParam.idefault;
            }
            NSString *cacheKey = [WSGridWidget getGridWidgetKeyByRowId:prod.Id col:aParam.col];
            [self setProdCacheWithKey:cacheKey value:colValue];
        }
    }
}

- (NSString *)dataSourceGetGridMd5 {
    
    return [self getGridMd5];
}

- (NSString *)dataSourceGetGridMc {
    
    return self.currentTableItem.mc;
}

- (WSGridWidget *)dataSourceGetGroupViewByType:(NSString *)type {
    
    return [self.widgetRoot getGridWidgetByKey:type];
}

- (void)dataSourceSetIsValueChanged:(BOOL)isValueChanged {
    
    [self setIsValueChange:isValueChanged];
}

- (void)dataSourcePopDropListView:(WSBaseDropListView *)dropListView {
    
    [self popupDropListViewDidAppear:dropListView];
}

- (UIViewController *)dataSourceGetController {
    
    return self.ownViewController;
}

- (void)dataSourceInterActionPhotoGalleryWithGridWidget:(WSGridWidget *)widget dic:(NSMutableDictionary *)dic {
    
    WSInterAction *interAction = [[WSInterAction alloc] init];
    [interAction setAcvt_qust_id:self.currentQst.acvtQstId];
    [interAction setDirect_type:DIRECT_TYPE_PUSH];
    [interAction setExecute_class:@"WSPhotoGalleryViewController"];
    [interAction setExcute_class_delegate:widget];
    
    NSObject <I_W_OptionDataItem> *item = self.dataSource[widget.iRow];
    NSString *title = [item getDataItemName];
    if ([title length] > 0) {
        [interAction setExecute_class_param_title:title];
    }
    
    if (self.currentStore.name) {
        [dic setObject:self.currentStore.name forKey:@"storeName"];
    }
    [interAction setExecute_class_param:dic];
    
    if ([self.delegate respondsToSelector:@selector(executeInterAction:)]) {
        [self.delegate executeInterAction:interAction];
    }
}

- (void)dataSourceRunScriptWithWidgetKey:(NSString *)widegetKey {
    
    [self runColumLuaScriptByWidgetKey:widegetKey];
}

- (void)dataSourceDidChange:(NSObject *)object {
    
    if ([self.delegate respondsToSelector:@selector(acvtDataGridComponentDataSource:didChange:)]) {
        [self.delegate acvtDataGridComponentDataSource:self didChange:object];
    }
}

- (WSGridDataSourceReplaceStatus)dataSourceReplaceStatus:(WSHTextField *)textField replacementString:string columnTip:columnTip {
    
    WSGridDataSourceReplaceStatus replaceStatus = [self getTextFieldReplaceStatus:textField replacementString:string columnTip:columnTip];
    return replaceStatus;
}

- (void)dataSourceTextFieldDidChanged:(WSHTextField *)textField {
    
    [self textDidChangeForTextField:textField];
}

- (NSMutableArray *)dataSourceGetDropListRedisByParam:(WSFuncsBean_Param *)param parentId:(NSString *)parentId {
    
    return [self getDropListRedisByParam:param parentId:parentId data:nil];
}

- (WSGridWidget *)widgetRoot {
    
    if (!_widgetRoot) {
        _widgetRoot = [[WSGridWidgetGroup alloc] initWithParam:nil rowIndex:0 columnIndex:0];
    }
    return _widgetRoot;
}

- (WSGridWidget *)createWidgetGroupWithType:(NSString *)type {
    
    WSFuncsBean_Param *param = [[WSFuncsBean_Param alloc] init];
    param.tpy = type;
    return [[WSGridWidgetGroup alloc] initWithParam:param rowIndex:0 columnIndex:0];
}

@end

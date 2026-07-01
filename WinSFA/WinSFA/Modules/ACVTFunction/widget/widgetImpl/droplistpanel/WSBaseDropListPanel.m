//
//  WSBaseDropListPanel.m
//  WinSFA
//
//  Created by yang on 15-3-19.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSBaseDropListPanel.h"
#import "I_W_BuildInfo.h"
#import "I_W_DataSource.h"
#import "WidgetConstant.h"
#import "WSSelectListView.h"
#import "WSDropListView.h"
#import "WSInterAction.h"
#import "WSStoreBeans.h"

#import "WSBaseOptionDataItem.h"

#import "I_W_DisplayValue.h"

#import "WSDropListView.h"
#import "WSDropListButtonView.h"
#import "WSDropListHorizontalScrollButtonView.h"

#define kSelectFirst  @"default_first"

@interface WSBaseDropListPanel ()

@property (nonatomic, assign) BOOL isButtonMode;    // 是否显示成按钮样式
@property (nonatomic, strong) NSArray *scriptValidateDataSource;    // 脚本设置的有效数据源

@end

@implementation WSBaseDropListPanel {

}

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _needRiseSelectionChange = YES;
        _showRedisValueAfterExcuteLuaSript = YES;
        self.needCheckValueChange = YES;
        
        return self;
    }
    return nil;
}

-(NSMutableArray *)subWidgetArray{
    if (!_subWidgetArray) {
        _subWidgetArray = [[NSMutableArray alloc]init];
    }
    return _subWidgetArray;
}
-(void)buildDisplayContent{
    
    [super buildDisplayContent];
    

    BOOL orientition = NO;
    if ([xbuildInfo getOrientation] && [[xbuildInfo getOrientation] isEqualToString:@"1"]) {
        orientition = YES;
    }
    
    CGRect dropListFrame = [self getDropListViewFrameByOrientation:orientition];
    
    if (!orientition) {
        UIView *seperateLineView  = [[UIView alloc] initWithFrame:CGRectMake(SEPERATE_PADDING_Left, dropListFrame.origin.y - MAIN_CELL_SEPERATOR_HEIGHT, dropListFrame.size.width - MAIN_CELL_PADDING, MAIN_CELL_SEPERATOR_HEIGHT)];
        [seperateLineView setBackgroundColor:DETAIL_SEPERATE_LINE_COLOR];
        [self addSubview:seperateLineView];
    }
    NSString *displayMode = [xbuildInfo getDisplayMode];
    
    if ([displayMode length] == 0 || [displayMode isEqualToString:QST_DISPLAYMODE_MULTIMENU]) {
        WSDropListView *listView = [[WSDropListView alloc] initWithFrame:dropListFrame];
        
        if ([displayMode isEqualToString:QST_DISPLAYMODE_MULTIMENU]) {
            if ([xbuildInfo getGroupName].length > 0) {
                listView.isInGroup = YES;
            }
        }
        
        self.dropListView = listView;
        
        if (orientition) {
            CGRect labelFrame = self.titleLabel.frame;
            [self.titleLabel setFrame:CGRectMake(labelFrame.origin.x, (self.frame.size.height - labelFrame.size.height)/2 , labelFrame.size.width, labelFrame.size.height)];
        }
        
        
        self.isButtonMode = NO;
        
        
    } else if ([displayMode isEqualToString:QST_DISPLAYMODE_BN] || [displayMode isEqualToString:QST_DISPLAYMODE_LABEL]) {
  
//        YIHAIKERRY-2024
//        SFA 益海嘉里深圳【IOS】，门店列表页面右上角筛选条件中，各字段高度不一致。（如图）
        WSDropListButtonView *dropListButtonView = [[WSDropListButtonView alloc] initWithFrame:CGRectMake(MAIN_CELL_PADDING,self.titleLabel.bottom, self.width - 2 * MAIN_CELL_PADDING, 0)];
        
        
        if ([displayMode isEqualToString:QST_DISPLAYMODE_LABEL]) {
            [dropListButtonView setButtonStyle:WSDropListButtonFit];
        }
        
        self.dropListView = dropListButtonView;
        self.isButtonMode = YES;
        
    } else if ([displayMode isEqualToString:QST_DISPLAYMODE_HORIZONTAL_SCROLL]){
        [self removeAllSubviews];
        WSDropListHorizontalScrollButtonView *dropListButtonView = [[WSDropListHorizontalScrollButtonView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0)];
        
        self.dropListView = dropListButtonView;
        self.isButtonMode = YES;
    } else {
        LogError(@"不支持的显示模式");
        return;
    }
    
    
    self.dropListView.tag = [[xbuildInfo getAcvtQstId] intValue];
    self.dropListView.filterStr = [xbuildInfo getFilterCondition];
    
    self.dropListView.layer.cornerRadius = 5.0f;
    
    self.dropListView.dropListDelegate = self;
    
    if ([[xbuildInfo getAcvtMemo] isEqualToString:@"1"]) {
        self.dropListView.isScrollToBottomToEnableButton = YES;
    }
    
    if ([[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
        
        [self setSourceTableReadOnly:YES];
    }
    
    if ([[xbuildInfo getMumx] integerValue] > 0) {
        self.dropListView.maxNum = [[xbuildInfo getMumx] integerValue];
    }
    
    [self addSubview:self.dropListView];
    
    
    self.dropListView.dataSourceArray = [self getDataSource];
    if (!self.isButtonMode) {
        
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.dropListView.origin.y + MAIN_CELL_HEIGHT)];
        
    } else if ([self.dropListView isKindOfClass:[WSDropListButtonView class]]) {
        
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.dropListView.height + self.titleLabel.height)];
    }else if ([self.dropListView isKindOfClass:[WSDropListHorizontalScrollButtonView class]]) {
        
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.dropListView.height)];
    }
    
    [self.dropListView flushTable];
}

- (NSArray *)getDataSource{
    
    
    if (self.parentWidget) {
        // MN-1776 跟安卓效果一致，父级没有选择子级不能显示暂无选项
        if (![self.parentWidget getSelectedItemID]) {
            [self.dropListView setIsParentSelected:NO];
            //YIHAIKERRY-3838  2018/8/20 父级没有选择，子级为空，同时要把xdataSource.dataSourceArray中清除掉，保证dataSource一样，不然[self.dropListView setSelectedItem:[xdataSource.dataSourceArray firstObject]];这句代码的执行，导致还是会显示数据。
            xdataSource.dataSourceArray = nil;
            return nil;
        } else {
            [self.dropListView setIsParentSelected:YES];
        }
    }
    
    if ([[self.parentWidget getSelectedItemID] length] > 0) {
        [xdataSource setParentSelectedItemID:[self.parentWidget getSelectedItemID]];
    }
    
    NSMutableArray *dataSource = [NSMutableArray arrayWithArray:(NSArray *)[xdataSource getDataSourceFor:xbuildInfo]];
    
    if ([dataSource count] > 0) {
        if (!self.isButtonMode) {
            // 非必填加上取消选项
            if (![[xbuildInfo getISRequire] isEqualToString:@"1"]) {
                WSBaseOptionDataItem *cancelItem = [[WSBaseOptionDataItem alloc] init];
                cancelItem.itemID = kCancelItemId;
                cancelItem.itemName = kCancelItemName;
                [dataSource addObject:cancelItem];
            }
        }
    }
    
    return dataSource;
    
}

- (void)layoutSubviews {
    if (!self.isButtonMode) {
        BOOL orientition = NO;
        if ([xbuildInfo getOrientation] && [[xbuildInfo getOrientation] isEqualToString:@"1"]) {
            orientition = YES;
        }
        self.dropListView.frame = [self getDropListViewFrameByOrientation:orientition];
    }
}

- (CGRect)getDropListViewFrameByOrientation:(BOOL)orientation {
    CGFloat originX;
    CGFloat originY;
    CGFloat width = self.width;
    if (orientation ) {
        originX = self.titleLabel.right;
        if ([xbuildInfo getReadOnly] && [[xbuildInfo getIsHideQstName] boolValue]) {
            originX = 0;
        }
        originY = 0;
        width -= originX;
    } else {
        originX = 0;
        originY = self.titleLabel.bottom;
    }
    
    return CGRectMake(originX, originY, width, MAIN_CELL_HEIGHT);
}

-(void)loadValidator:(NSObject<I_W_Validate> *)validateobjin{
    
    [super loadValidator:validateobjin];
    
}

- (void)loadComputeResult:(WSInterAction *)interAction{
    
    if ([interAction.execute_result conformsToProtocol:@protocol(I_W_OptionDataItem)]) {
        [self.dropListView setSelectedItem:(NSObject<I_W_OptionDataItem> *)interAction.execute_result];
    }
}

- (NSObject *)getResultDirectly {
    return [self.dropListView getResultDirectly];
}

- (NSObject *)getResultPresentation {
    return [self.dropListView getResultPresentation];
}

- (void)updateWidgetOpts:(NSString *)conditions {
    
    if ([[xbuildInfo getDataSource] isEqualToString:@"store"]) {
        if ([conditions length] > 0 && [conditions rangeOfString:@","].location != NSNotFound) {
            
            
            
            NSArray *conditionsArray = [conditions componentsSeparatedByString:@","];
            if ([conditionsArray count] == 1) {
                
            }else if ([conditionsArray count] >= 2) {
                NSString *hospitalId = [conditionsArray firstObject];
                if ([hospitalId length] > 0) {
                    BOOL hasDepartment_id = YES;
                    for (NSInteger i=1; i < [conditionsArray count]; i++) {
                        NSString *condition = conditionsArray[i];
                        if ([condition length] > 0) {
                        }else {
                            hasDepartment_id = NO;
                        }
                    }
                    
                    if (hasDepartment_id) {
                        
                        if (_allStores == nil) {
                            WSStoreBeans *storeBeans = [WSAppData getObjectbyKey:STORES];
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.noteName == %@",STORES];
                            _allStores = [storeBeans.storesArray filteredArrayUsingPredicate:predicate];
                            
                            if ([[xbuildInfo getFilterCondition] length] > 0) {
                                _allStores = [_allStores filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.styp == %@",[xbuildInfo getFilterCondition]]];
                            }
                        }
                         NSArray *departments = [conditionsArray subarrayWithRange:NSMakeRange(1, [conditionsArray count]-1)];
                        NSPredicate *hosPredicate = [NSPredicate predicateWithFormat:@"self.pid == %@ and self.departmentId in %@",hospitalId,departments];
                        NSArray *hosStores = [_allStores filteredArrayUsingPredicate:hosPredicate];
                        self.dropListView.dataSourceArray = hosStores;
                        [self.dropListView flushTable];
                        
                        
                        /*若上次选中的选项不在这次更新的数据源中则清空*/
                        NSArray *items = self.dropListView.selectedItemArray;
                        if ([items count] > 0) {
                            NSArray *itemIds = [items valueForKeyPath:@"@distinctUnionOfObjects.Id"];
                            NSArray *filters = [hosStores filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.Id in %@",itemIds]];
                            if ([filters count] == 0) {
                                self.dropListView.selectedItemArray = [@[] mutableCopy];
                                if ([self.dropListView.dropListDelegate respondsToSelector:@selector(dropListViewDidChangeSelect:)]) {
                                    [self.dropListView.dropListDelegate dropListViewDidChangeSelect:self.dropListView];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

- (void)setValidDataSourceFromScript:(NSString *)validDataSource
{
    // SFA-13561 新增如果为空默认加载所有选项
    if (validDataSource && validDataSource.length > 0) {
        NSArray *dataSourceArray = [[NSArray alloc] init];
        
        // SFA-13561 新增脚本添加以"@#"分割多个选项的字符串
        if ([validDataSource rangeOfString:@"@#"].location != NSNotFound) {
            dataSourceArray = [validDataSource componentsSeparatedByString:@"@#"];
        }else {
            dataSourceArray = [validDataSource componentsSeparatedByString:@","];
        }
        
        NSMutableArray *newDataSource = [[NSMutableArray alloc] init];
        //MN-3263 2018-07-14(修改遍历顺序)
        for (NSObject<I_W_OptionDataItem> *item in xdataSource.dataSourceArray) {
            for (NSString *dataName in dataSourceArray) {
                if ([dataName isEqualToString:[item getDataItemName]]) {
                    [newDataSource addObject:item];
                    break;
                }
            }
        }
        self.dropListView.dataSourceArray = newDataSource;
        //SFA-21988 【SFA泸州老窖】【iOS】留样中假仿冒特征显示不可选
        //为了防止出现重复数据由原来的下发的name 改为id 不能直接使用上面的dataSourceArray 因为查出的数据不对上面是根据父级的id查询，现在是根据id查询
        if (newDataSource.count == 0) {
            
            WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
            self.scriptValidateDataSource = [service queryDictsWithIDs:dataSourceArray];
            
            //SFA-23002 【SFA泸州老窖】【iOS】假仿冒特征没有根据产品筛选
            // 如果没有数据会插入一个任意数据
            if ([self.scriptValidateDataSource count] == 0) {
                WSDictBean *dictBean = [[WSDictBean alloc] init];
                [newDataSource addObject:dictBean];
                self.scriptValidateDataSource = newDataSource;
            }
            
        }else{
            if ([newDataSource count] == 0) {
                WSDictBean *dictBean = [[WSDictBean alloc] init];
                [newDataSource addObject:dictBean];
            }
            self.scriptValidateDataSource = newDataSource;
        }
        
    } else {
        
        self.scriptValidateDataSource = nil;
    }
    
    // SFA-21980 刷新数据
    [self refreshDataSource];
}

- (void)setCurrentValueWithPresentation:(NSString *)valuePresentation
{
    NSArray *validValueArray = [valuePresentation componentsSeparatedByString:@","];
    NSMutableArray *valueIDArray = [[NSMutableArray alloc] init];
    for (NSString *dataName in validValueArray) {
        for (NSObject<I_W_OptionDataItem> *item in xdataSource.dataSourceArray) {
            if ([dataName isEqualToString:[item getDataItemName]] ||
                [dataName isEqualToString:[item getDataItemID]]) {
                [valueIDArray addObject:[item getDataItemID]];
                break;
            }
        }
    }
    
    // YIHAIKERRY-2109 去掉 “当选择项为默认项时，有回显显示回显的内容”的逻辑，以下逻辑是 2016.05.26 LEEMANPAPER-223 添加，不太合理所以屏蔽
    /*
    //当选择项为默认项时，有回显显示回显的内容
    if (_showRedisValueAfterExcuteLuaSript) {
        if ([valuePresentation isEqualToString:@""] && _originalValue ) {
            [valueIDArray removeAllObjects];
            if ([_originalValue isKindOfClass:[NSArray class]]) {
                NSArray *displayArray = (NSArray *)_originalValue;
                if (displayArray.count > 0) {
                    [valueIDArray addObjectsFromArray:(NSArray *)_originalValue];
                }

            } else if([_originalValue isKindOfClass:[NSString class]]){
                NSString *disPlay = (NSString *)_originalValue;
                if ([disPlay length]>0) {
                    [valueIDArray addObject:_originalValue];
                }
            }
        }
    }
     */
    
    _showRedisValueAfterExcuteLuaSript = NO;
    _needRiseSelectionChange = NO;
    
    if ([self.delegate respondsToSelector:@selector(currentLuaExecuteIsFromAcvt)] && [self.delegate currentLuaExecuteIsFromAcvt]) {
        _needRiseSelectionChange = YES;
    }
    //    董宏  YIHAIKERRY-3084 临时加入 todo
    if(valueIDArray.count==0&&validValueArray.count>0)
    {
        valueIDArray = [NSMutableArray arrayWithArray:validValueArray];
    }

    [self.dropListView setUpSelectionByItemIDArray:valueIDArray];
    _needRiseSelectionChange = YES;
    
    [self reloadSubWidgetDateSource];
}

- (void)setReadonly:(NSString *)isReadonly
{
   
    [super setReadonly:isReadonly];
    
    if ([[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
        [self setSourceTableReadOnly:YES];
    }else {
        [self setSourceTableReadOnly:NO];
    }
    
}

- (void)setFilter:(NSString *)filter
{
    [super setFilter:filter];
    
    [self setCurrentValueWithPresentation:@""];
//    [self removeAllSubviews];
//    [self buildDisplayContent];
    
    [self refreshDataSource];
}

- (void)setEmpId:(NSString *)empId{
    
    if (empId.length < 1) {
        return ;
    }


    //区分是人为触发还是 回显脚本触发
    if ([xdataSource getTempEmpId] == nil ) {
        [xdataSource setTempEmpId:empId];
        [self initDataForCascadeRelation:YES];
        _showRedisValueAfterExcuteLuaSript = YES;

    }
    
    if ([xdataSource getTempEmpId].length > 0 && ![[xdataSource getTempEmpId] isEqualToString:empId]) {
        
        [xdataSource setTempEmpId:empId];
        [self cleanSelectionAndRefreshDataSource];
    }
    
    [self selectFirstObject];
}

- (void)setRequest:(NSString *)isRequest
{
    [super setRequest:isRequest];
    
    if ([[xbuildInfo getISRequire] isEqualToString:@"1"]) {
        NSMutableArray *array = [self.dropListView.dataSourceArray mutableCopy];
        id<I_W_OptionDataItem> item = [array lastObject];
        if ([[item getDataItemID] isEqualToString:kCancelItemId] && [[item getDataItemName] isEqualToString:kCancelItemName]) {
            [array removeLastObject];
            self.dropListView.dataSourceArray = array;
        }
    }else{
        NSMutableArray *array = [self.dropListView.dataSourceArray mutableCopy];
        id<I_W_OptionDataItem> item = [array lastObject];
        if (![[item getDataItemID] isEqualToString:kCancelItemId]) {
            WSBaseOptionDataItem *cancelItem = [[WSBaseOptionDataItem alloc] init];
            cancelItem.itemID = kCancelItemId;
            cancelItem.itemName = kCancelItemName;
            [array addObject:cancelItem];
            self.dropListView.dataSourceArray = array;
        }
    }
}

- (void)selectFirstObject {
    // 如果数据源仅有一项（不包括没有默认选项时添加的@""）且为必填则直接选中该选项
    BOOL isRequiredOnlyOne =  [[xbuildInfo getISRequire] isEqualToString:@"1"] && [xdataSource.dataSourceArray count] == 1;
    // 默认值为 default_first 并且没有选中值的时候，选中第一个
    BOOL isSelectFirst = [[xbuildInfo getDefaultValue] isEqualToString:kSelectFirst] && !self.dropListView.selectedItem;
    if (isSelectFirst || isRequiredOnlyOne) {
        self.needCheckValueChange = NO;
        [self.dropListView setSelectedItem:[xdataSource.dataSourceArray firstObject]];
        self.needCheckValueChange = YES;
    }
}

- (void)widgetDidLoadFinish
{
    self.isExecuteLuacript = NO;
    
    [self selectFirstObject];
    
    // SFA-22615 值变化的时候需要在初始化后走脚本
    //问题加载完成后若无必要不执行脚本，如果安卓执行可以去掉这个屏蔽
//    if (self.isValueChangedToRunScript) {
//        if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)])
//            [self.delegate executeLuaScript:xbuildInfo widget:self];
//    }
    self.isExecuteLuacript = YES;
}

- (void)widgetDidExecutedAllInitScript
{
    _showRedisValueAfterExcuteLuaSript = NO;
}

- (void)refreshDataSource
{
    //设置是否可点击，父节点没有选择子节点不允许选择
    if (self.parentWidget) {
        if ([self.parentWidget getSelectedItemID]) {
            if ([[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
                [self setSourceTableReadOnly:YES];
            }else {
                [self setSourceTableReadOnly:NO];
            }
        }else {
            [self setSourceTableReadOnly:YES];
        }
    }
    
    NSArray *dataSource = [self getDataSource];
    
    // SFA-21907 脚本设置的数据源和原本的数据源取交集
    if ([dataSource count] > 0 && [self.scriptValidateDataSource count] > 0) {
        NSMutableArray *validDataSource = [NSMutableArray arrayWithCapacity:[dataSource count]];
        
        //MN-3263 2018-07-14(修改遍历顺序)
        for (WSDictBean *validItem in self.scriptValidateDataSource) {
            for (NSObject<I_W_OptionDataItem> *item in dataSource) {
                //SFA-21988 【SFA泸州老窖】【iOS】留样中假仿冒特征显示不可选
                if ([[item getDataItemID] isEqualToString:[validItem getDataItemID]]) {
                    [validDataSource addObject:item];
                    break;
                }
            }
        }
        dataSource = [validDataSource copy];
    }
    
    self.dropListView.dataSourceArray = dataSource;
  
    // SFA-18587 重置选中项
    if (self.dropListView.selectMode == WSDropListViewSelectModeSingleSelection) {
        BOOL isSelect = NO;
        NSObject<I_W_OptionDataItem> *selectedItem = [self.dropListView selectedItem];
        for (NSObject<I_W_OptionDataItem> *item in dataSource) {
            if ([[item getDataItemID] isEqualToString:[selectedItem getDataItemID]]) {
                [self.dropListView setSelectedItem:item];
                isSelect = YES;
                break;
            }
        }
        if (!isSelect) {
            [self.dropListView setSelectedItem:nil];
        }
    } else if (self.dropListView.selectMode == WSDropListViewSelectModeMultipleChoice) {
        
        NSArray *selectedArray = [self.dropListView selectedItemArray];
        NSMutableArray *selectedTempArray = [NSMutableArray arrayWithCapacity:selectedArray.count];
        for (NSObject<I_W_OptionDataItem> *item in dataSource) {
            for (NSObject<I_W_OptionDataItem> *selectedItem in selectedArray) {
                if ([[item getDataItemID] isEqualToString:[selectedItem getDataItemID]]) {
                    [selectedTempArray addObject:item];
                }
            }
        }
        if ([selectedTempArray count] > 0) {
            [self.dropListView setSelectedItemArray:selectedTempArray];
        } else {
            [self.dropListView setSelectedItemArray:nil];
        }
    }
    
    [self.dropListView flushTable];
    
    
    [self selectFirstObject];
    
    // MN-1587  2018-4-08
    if(self.dropListView.dataSourceArray.count <= 0)
        [self setSourceTableReadOnly:YES];
    else
        [self setSourceTableReadOnly:[[xbuildInfo getReadOnly] isEqualToString:@"1"]];

}

- (void)cleanSelection
{
    self.dropListView.selectedItem = nil;
    [self.dropListView.selectedItemArray removeAllObjects];
}

#pragma mark - WSDropListViewDelegate
- (void)dropListViewDidChangeSelect:(WSDropListView *)dropListView
{
    if (!_needRiseSelectionChange) {
        return;
    }
    
    if (self.needCheckValueChange) {
        [self checkValueChange];
    }
    //SFA-18600
//    self.resultCheck = [self.dropListView getResultPresentation];
    
    NSObject * currentValue = [self getDisplayValuePresentation];
    
    BOOL isneedReloadSub = NO; //当前的值变化了，才更新子控件的数据
    if (![_resultCheck isEqual:currentValue]) {
        isneedReloadSub = YES;
    }
    
    _resultCheck = currentValue;

    if(self.isExecuteLuacript){
        if ([xbuildInfo getLuaScript] && [[xbuildInfo getLuaScript] length] > 0) {
            if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
                [self.delegate executeLuaScript:xbuildInfo widget:self];
            }
        }
    }else{
        LogInfo(@"widgetDidLoadFinish or buildDisplayContent 不执行脚本");
    }
    
    if (isneedReloadSub) { // YIHAIKERRY-3803  当前的值变化了，才更新子控件的数据
        [self reloadSubWidgetDateSource];
    }

    self.isValueChangedToRunScript = YES;
}

- (void)dropListViewDidAppear:(WSDropListView *)dropListView
{
    
}

- (void)popupDropListViewDidAppear:(WSDropListView *)dropListView
{
    
    WSInterAction  *interaction =[[WSInterAction alloc] init];
    
    [interaction setAcvt_qust_id:[xbuildInfo  getAcvtQstId]];
    
    [interaction setExecute_class:@"WSSingleSelectAndSearchViewController"];
    
    [interaction setDirect_type:DIRECT_TYPE_PRESENT];
    
    if ([self.dropListView.dataSourceArray count] > 1) {
        [interaction setExecute_class_param:self.dropListView.dataSourceArray];
    }else {
        [interaction setExecute_class_param:xdataSource.dataSourceArray];
    }
    
    if ([delegate respondsToSelector:@selector(executeInterAction:)]) {
        [delegate executeInterAction:interaction];
    }
}

- (void)setSelectedNum:(NSString *)limit {
    [self.dropListView setLimitNum:limit];
}

- (void)setSourceTableReadOnly:(BOOL)readOnly {
    
    [self.dropListView setSourceTableReadOnly:readOnly];
    if (readOnly) {
        self.titleLabel.textColor = PanelTextFieldColorReadonly;
        self.backgroundColor = MAIN_CELL_DISABLE_COLOR;
    } else {
        
        self.titleLabel.textColor = [UIColor colorForKey:@"AcvtViewPanelText"] ? : DETAIL_TEXT_COLOR;//DETAIL_TEXT_COLOR;
        [self setTitleContent:self.titleLabel.text];
        self.backgroundColor = [UIColor whiteColor];
    }
}


#pragma mark - for I_CascadeRelation

- (NSString *)getQstID
{
    return [xbuildInfo getQstId];
}

- (NSString *)getParentQstID
{
    return [xbuildInfo getParentQuestionId];
}

- (NSString *)getSelectedItemID
{
    return [self.dropListView getResultDirectly];
}

- (NSArray *)getSelectedItemArray
{
    return self.dropListView.selectedItemArray;
}
// SFA-25765 donghong
-(NSString *)getDataCount
{
    return [NSString stringWithFormat:@"%ld",self.dropListView.dataSourceArray.count];
}

- (void)initDataForCascadeRelation:(BOOL)isRefreshSelf
{
    if (isRefreshSelf) {
        [self refreshDataSource];
    }
    
    //根据WSDVDropListPanel父级与子级关联之后回显的数据
    if (self.dropListView.selectMode == WSDropListViewSelectModeSingleSelection) {
        NSString *selectItemID = (NSString *)[xdisplayValue getDisplayValueFor:xbuildInfo];
        if (selectItemID) {
            [self.dropListView setUpSelectionByItemIDArray:@[selectItemID]];
            _originalValue = selectItemID;
        }
    }else{
        NSArray *selectItemIDArray = (NSArray *)[xdisplayValue getDisplayValueFor:xbuildInfo];
        if (selectItemIDArray && [selectItemIDArray isKindOfClass:[NSArray class]] && selectItemIDArray.count >0) {
           
            [self.dropListView setUpSelectionByItemIDArray:selectItemIDArray];
            _originalValue = selectItemIDArray;
        }
    }
    //递归初始化子节点数据源
//    if (self.subWidget) {
//        [self.subWidget initDataForCascadeRelation:YES];
//    }
    if (self.subWidgetArray.count > 0) {
        for (id<I_CascadeRelation>subWidget in self.subWidgetArray) {
            [subWidget initDataForCascadeRelation:YES];
        }
    }
}
- (NSString*)getMemo{
    
    return [self.dropListView getSelectItemMemo];
}
- (void)cleanSelectionAndRefreshDataSource
{
    // 数据尚未初始化时不需要清空
    if (self.dropListView.dataSourceArray) {
        [self cleanSelection];
    }
    
    [self refreshDataSource];
    [self reloadSubWidgetDateSource];
}

#pragma -mark MN-1633  刷新子控件的数据源
-(void)reloadSubWidgetDateSource{
    //    if (self.subWidget) {
    //        [self.subWidget cleanSelectionAndRefreshDataSource];
    //    }
    
    if (self.subWidgetArray.count > 0) {
        for (id<I_CascadeRelation>subWidget in self.subWidgetArray) {
            [subWidget cleanSelectionAndRefreshDataSource];
        }
    }
}
-(void)addSubWidgetObject:(id<I_CascadeRelation>)object{
    [self.subWidgetArray addObject:object];
}

-(NSArray *)getAllSubWidget{
   return self.subWidgetArray;
}

- (void)setNewDataSourceFromScript:(NSString *)param {
    
    if (param && param.length > 0) {
        NSArray *paramArray = [param componentsSeparatedByString:@","];
        if (paramArray && paramArray.count > 0) {
            NSMutableArray *dictBeanArray = [[NSMutableArray alloc] initWithCapacity:paramArray.count];
            for (int i = 0; i < paramArray.count; ++i) {
                NSString *element = [paramArray objectAtIndex:i];
                WSDictBean *dictBean = [[WSDictBean alloc] init];
                dictBean.Id = ((element.length > 0) ? element : @"");
                dictBean.name = ((element.length > 0) ? element : @"");
                [dictBeanArray addObject:dictBean];
            }
            self.dropListView.dataSourceArray = dictBeanArray;
        }
    }
}

@end

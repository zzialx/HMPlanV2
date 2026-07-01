//
//  WSAcvtDataGridViewPanel.m
//  WinSFA
//
//  Created by yang on 15/4/13.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSAcvtDataGridViewPanel.h"
#import "DataGridComponent.h"
#import "WSAcvtDataGridComponentDataSource.h"
#import "WSAcvtModel.h"
#import "WSDataSourceManager.h"
#import "I_W_BuildInfo.h"
#import "I_W_DataSource.h"
#import "WSInterAction.h"
#import "WSAcvtDataGridComponentService.h"
#import "WidgetConstant.h"
#import "WSMessageCenter.h"
#import "WSMessageObject.h"
#import "I_Lua_Target_Operator.h"
#import "WSStringValueChangeChecker.h"
#import "WSBaseStoreTable.h"
#import "WSBaseProductDBService.h"
#import "WSFuncsBeanArray.h"
#import "WSSpecialAcvtViewController.h"
#import "WSAcvtViewController.h"
#import "WSAcvtViewForGridPanel.h"
#import "UIView+Additions.h"
#import "WSAcvtDataGridHttpService.h"
#import "YYModel.h"
#import "WSGridStringValueChangeChecker.h"
#import "WSCameraAuthHelper.h"
#import "WSAcvtGridLuaManager.h"
#import "WSStatisticsManager.h"

#define SELECT_MORE_PRODUCT_CONTROLLER   @"MoreProductViewController"
#define SCAN_MORE_PRODUCT_CONTROLLER     @"WSScanListViewController"
#define TREE_NODE_SELECT_MORE_PRODUCT_CONTROLLER   @"WSNewAddProdsWithSeriesViewController"
#define kMoreButtonTitleColor   ([UIColor colorForKey:@"MoreProductButtonTitleColor"] ? [UIColor colorForKey:@"MoreProductButtonTitleColor"] : [UIColor blueColor])

#define kViewGap 15
#define kGapBtnsTop 24.0
#define kGapBetweenBtns 10.0
#define kGapBtnLeft 15

static const CGFloat kExpendViewWH = 36;
static const CGFloat kTitleHeight = MAIN_CELL_HEIGHT;

@interface WSAcvtDataGridViewPanel ()

@property (nonatomic, strong) UIButton *moreButton;             //更多按键
@property (nonatomic, strong) UIButton *scanButton;             //扫描按键
@property (nonatomic, strong) UIButton *deleteButton;           //删除按键
@property (nonatomic, strong) UIView *titleView;                //标题视图(表格连体的滚动时会消失)
@property (nonatomic, strong) UIButton *expendButton;           //折叠按键(表格连体的滚动时会消失)
@property (nonatomic, strong) UIButton *steadyViewExpendButton; //不变的标题视图(独立的视图 在表格头视图消失后 显示在页面固定位置)
@property (nonatomic, strong) UIView *steadyTitleView;          //不变的折叠按键(独立的视图 在表格头视图消失后 显示在页面固定位置)

@property (nonatomic, strong) WSAcvtBean_qst *currentQst;
@property (nonatomic, strong) WSTableItem *currentTableItem;
@property (nonatomic, assign) BOOL isFirstInit;
@property (nonatomic, assign) BOOL isExcutingLuaScript;
@property (nonatomic, strong) WSAcvtViewForGridPanel *acvtViewForGridPanel;
@property (nonatomic, strong) UIView *gridFrameView;
@property (nonatomic, strong) UILabel *gridViewBottomLine;

@end

@implementation WSAcvtDataGridViewPanel

#pragma mark - 配置显示内容方法
- (void)buildDisplayContent {
    
    _isExcutingLuaScript = NO;
    WSAcvtDataGridComponentDataSource *dataSource = (WSAcvtDataGridComponentDataSource *)[xdataSource getDataSourceFor:xbuildInfo];
    if ([[xbuildInfo getMumx] intValue] != 0) {
        dataSource.rightTableShowType = WSDataGridComponentRightTableColumnMaxShowType; //设置表格右侧显示格式
        dataSource.rightTableShowColOrRowMaxValue = [[xbuildInfo getMumx] intValue];
    }
    [self createDataGrid:dataSource];
}

#pragma mark - 创建表格数据方法
- (void)createDataGrid:(WSAcvtDataGridComponentDataSource *)dataSource {
    
    //YIHAIKERRY-4990
    [self removeAllSubviews];
    [self.gridFrameView removeAllSubviews];
    self.gridFrameView = nil;
    [self.dataGridView removeAllSubviews];
    self.dataGridView = nil;
    
    UIColor *bgColor = [UIColor colorForKey:@"GridBackgroundColor"];
    if (!bgColor) {
        bgColor = [UIColor whiteColor];
    }
    [self setBackgroundColor:bgColor];

    CGFloat gridFramePadding = 0;
    CGFloat gridFrameWidth = self.width - 2 * gridFramePadding;
    self.gridFrameView = [[UIView alloc] initWithFrame:CGRectMake(gridFramePadding, self.frame.origin.y, gridFrameWidth, self.height)];
    [self.gridFrameView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:self.gridFrameView];
    
    WSFuncsBean *tbFuncsBean = nil;
    WSFuncsBeanArray * newfba = [WSAppData getObjectbyKey:FUNCS];
    for (WSFuncsBean *funcs in newfba.hidefuncsArray) {
        if ([funcs.fc isEqualToString:[(WSAcvtBean_qst *)xbuildInfo mc]] ) {
            tbFuncsBean = funcs;
            break;
        }
    }
    if (tbFuncsBean) {
        self.currentTableItem = [[WSTableItem alloc] initWithFuncsBean:tbFuncsBean];
    } else {
        [self setWidgetHidden:@"1"];
        return;
    }
    
    self.isAddedMoreProduct = NO;
    self.isFirstInit = YES;
    self.xvalueChangeChecker = [[WSGridStringValueChangeChecker alloc] init];

    BOOL firstLoadIsExtended = YES;
    if (self.currentTableItem.maxRow != nil && ([self.currentTableItem.maxRow integerValue] < dataSource.dataSource.count)) {
        firstLoadIsExtended = NO;
    }
   
    BOOL isExtend = YES;
    if ([dataSource.currentQst.getIsHideQstName isEqualToString:@"1"]) {
        isExtend = NO;
    }
    
    dataSource.delegate = self;
    
    float height = 0;
    if (isExtend) {
        height = kTitleHeight;
    }
    
    CGFloat topGap = 0;
    if (isExtend) {
        topGap += kTitleHeight;
    }

    CGFloat padding = 0;
    CGFloat width = self.bounds.size.width - 2 * padding;
    WSAcvtDataGridComponentView *comView = [[WSAcvtDataGridComponentView alloc] initWithFrame: CGRectMake(padding, topGap, width, 0) data:dataSource];
    [comView setNeedsLayout];
    comView.delegate = self;
    comView.isAllowedExtend = isExtend;
    comView.isExtendedView = firstLoadIsExtended;
    comView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    comView.tag = [[xbuildInfo getAcvtQstId] integerValue];
    [dataSource addHeaderUI:comView.checkBoxArray]; //将表头控件视图句柄交给表头数据源
    [self.gridFrameView addSubview:comView];
    self.dataGridView = comView;
    height += comView.height;
    
    [self createMoveTitleViewWithOffsetY:0.0f];
    self.expendButton.selected = firstLoadIsExtended;
    
    if ([self isExtendGridView:isExtend]) {
        [comView redrawGridViewWithHeightForLayout:[comView getHeaderHeight]];
        height = [comView getHeaderHeight] + topGap;
    }
    
    CGFloat buttonHeight = 0;
    if (dataSource.isNeedShowMoreButton) {
        [self createMoreButtonWithFuncBean:tbFuncsBean];
        buttonHeight = [comView attachedViewsHeight];
    }
    if ([dataSource needShowScanButton]) {
        [self createScanButton];
         buttonHeight = [comView attachedViewsHeight];
    }
    if (comView.dataSource.needSelect || [comView.dataSource.currentTableItem.opt.deleteButton isEqualToString:@"1"]) {
        [self createDeleteButton];
        buttonHeight = [comView attachedViewsHeight];
    }
    
    if (!comView.isExtendedView) {
        [self setAttachedViewsEnable:NO];
    } else {
        height += buttonHeight + kGapBtnsTop * 2;
    }

    height += MAIN_CELL_PADDING;
    
    if ([[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
        [self setReadonly:[xbuildInfo getReadOnly]];
    }
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, height);
    
    self.isFirstInit = NO;
    [self createSteadyTableHeadView];
    self.acvtGridSteadyTableHeadView.hidden = YES;
    
    [((WSAcvtDataGridComponentDataSource *)self.dataGridView.dataSource) setDefautValueForUnit];
    
    if (self.currentTableItem.opt.hNewStyleProdSelect.length > 0 && ([self.currentTableItem.opt.hNewStyleProdSelect isEqualToString:@"1"] ||[self.currentTableItem.opt.hNewStyleProdSelect isEqualToString:@"2"])) {
        [self doDefaultActionWhenDataSourceIsEmptyWithDataGridComponent:dataSource];
    }
}

- (UILabel *)gridViewBottomLine{
    if (_gridViewBottomLine == nil) {
        _gridViewBottomLine = [[UILabel alloc] initWithFrame:CGRectZero];
        _gridViewBottomLine.backgroundColor = MAIN_TINT_COLOR;
    }
    return _gridViewBottomLine;
}

// 初始化更多产品的回显cache数组
- (void)doDefaultActionWhenDataSourceIsEmptyWithDataGridComponent:(WSAcvtDataGridComponentDataSource *)dataGridDataSource {
    NSMutableDictionary *tempProdCacheDataMDictionary = nil;
    NSMutableArray *tempProdCacheDataDictKeysArray = nil;
    
    WSAcvtDataGridComponentDataSource *productDataSource = (WSAcvtDataGridComponentDataSource *)dataGridDataSource;
    if (/*productDataSource.dataSource.count <= 0 &&*/ productDataSource.moreProductArray.count > 0) {
        NSArray *orginDataSource = productDataSource.dataSource;
        NSMutableArray *dataMArray = [NSMutableArray arrayWithArray:productDataSource.dataSource];
        [dataMArray addObjectsFromArray:productDataSource.moreProductArray];
        productDataSource.dataSource = [NSArray arrayWithArray:dataMArray];
        NSArray *orginDataBaseDatas = productDataSource.m_DataBaseDatas;
        productDataSource.m_DataBaseDatas = nil;
        
//        productDataSource.dataSource = [NSArray arrayWithArray:productDataSource.moreProductArray];
//        productDataSource.data = [productDataSource getGrideViewData];
        // 优化上一句，调用新的轻量级设置全部更多产品已有参数值，可节省10s的时间
        [productDataSource setMoreProdsDefaultColValueCacheDicForCurrentAcvtGrid];
        productDataSource.isReturn = YES;
        [productDataSource setDefautValueForUnit];
        tempProdCacheDataMDictionary = productDataSource.prod_cacheDataMDictionary;
        productDataSource.prod_cacheDataDictKeysArray = [NSMutableArray arrayWithArray:productDataSource.prod_cacheDataMDictionary.allKeys];
        tempProdCacheDataDictKeysArray = productDataSource.prod_cacheDataDictKeysArray;
        
        productDataSource.dataSource = orginDataSource;
        productDataSource.m_DataBaseDatas = orginDataBaseDatas;
    }
    
    // 表格产品多的情况下此处耗时太多，暂时注释掉
    [productDataSource resetDataSource];
    productDataSource.isReturn = NO;
    productDataSource.prod_cacheDataMDictionary = tempProdCacheDataMDictionary;
    productDataSource.prod_cacheDataDictKeysArray = tempProdCacheDataDictKeysArray;
}

- (BOOL)isExtendGridView:(BOOL)isExtend {
    if (isExtend && !self.dataGridView.isExtendedView && ([[self getAcvtDataSource].data count] > 0 || [self getAcvtDataSource].moreProductArray.count > 0)) {
        return YES;
    } else {
        return NO;
    }
}

- (void)layoutSubviews {
    BOOL isExtend = YES;
    if ([[xbuildInfo getIsHideQstName] isEqualToString:@"1"]) {
        isExtend = NO;
    }
    float height = 0;
    if (isExtend) {
        height = kTitleHeight;
    }
    
    self.dataGridView.frame = CGRectMake(self.dataGridView.frame.origin.x, self.dataGridView.frame.origin.y, self.dataGridView.frame.size.width, self.dataGridView.frame.size.height);
    // SFA-19555 立白项目，如果有签名时，屏幕会旋转，屏幕的宽高会交换，计算表格删除添加扫描按钮时会按照gridFrameView的宽度计算按钮frame,所以在此处需要提前设置好gridFrameView的宽度。
    CGFloat padding = 0;
    CGFloat gridFrameWidth = self.width - 2 * padding;
    self.gridFrameView.width = gridFrameWidth;
    if ([self isExtendGridView:isExtend]) {
        height += [self.dataGridView getHeaderHeight];
    }else{
        CGFloat brandViewHeight = 0.0;
        if (self.dataGridView.dataSource.needSelect) {
            brandViewHeight = 44.0;
        }
        
        CGFloat dataGridViewHeight = self.dataGridView.frame.size.height > self.dataGridView.rightTableView.contentSize.height + brandViewHeight ? self.dataGridView.frame.size.height : self.dataGridView.rightTableView.contentSize.height + brandViewHeight;
        [self.dataGridView reDrawGridViewWithHeight:dataGridViewHeight];
        height += self.dataGridView.frame.size.height;
    }
    
    if (self.dataGridView.dataSource.needSelect || [self.dataGridView.dataSource.currentTableItem.opt.deleteButton isEqualToString:@"1"]) {
        if (self.isAddedMoreProduct) {
            if (![[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
                [self attachedViewsEnableShow:YES];
                [self.gridFrameView addSubview:self.deleteButton];
            } else {
                [self attachedViewsEnableShow:NO];
            }
        } else if (self.deleteButton) {
            if (![[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
                [self attachedViewsEnableShow:YES];
            } else {
                [self attachedViewsEnableShow:NO];
            }
        }
    }
    
    if ([self getAcvtDataSource].isNeedShowMoreButton) {
        if (![[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
            if (self.isAddedMoreProduct && self.moreButton != nil) {
                [self.gridFrameView addSubview:self.moreButton];
            }
        }
    }
    
    if ([[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
        [self setAttachedViewsEnable:NO];
    } else {
        [self setAttachedViewsEnable:YES];
    }
    
    BOOL isReset = [self isResetButtonsLayoutWithSelfCurrentHeight:height + kGapBtnsTop];
    if (isReset) {
        CGFloat buttonHeight = [self.dataGridView attachedViewsHeight];
        height += buttonHeight + kGapBtnsTop * 2;
    }

    [self setupSteadyTableHeadView:self.acvtGridSteadyTableHeadView];

    /*
     *2017-01-15 Added By HZH.
     *
     *iOS SDK Release Notes for iOS 9
     *在iOS 9中,当layoutIfNeeded发送到一个视图和满足以下所有条件(不常见),我们应用fitting-size约束在UILayoutPriorityFittingSizeLevel(宽/高= 0),而不是所需的尺寸约束(宽/高要求匹配当前大小);
     *如果发送layoutIfNeeded视图在这些条件下在iOS 9中,你必须确保你有足够的约束建立顶层视图的大小(通常,但并非总是,是接收机)或您必须添加临时尺寸约束的顶层视图布局尺寸你想要发送layoutIfNeeded之前,和之后删除它们;
     *
     */
    if ([[UIDevice currentDevice] systemVersionByFloat] >= 9.000000) {
        //MN-1027 2018-03-07
        CGFloat drawHeight = self.superview.frame.size.height + height - self.frame.size.height;
        drawHeight = (drawHeight <= 0.0f) ? self.frame.size.height : drawHeight;
        self.superview.frame = CGRectMake(self.superview.frame.origin.x, self.superview.frame.origin.y, self.superview.frame.size.width, drawHeight);
    }
    self.gridFrameView.frame = CGRectMake(padding, 0, gridFrameWidth, height);
    
    // SFA-25287
    if ([[xbuildInfo getDisplayMode] isEqualToString:@"iconBtn"]){
        [self.gridFrameView addSubview:self.gridViewBottomLine];
        self.gridViewBottomLine.frame = CGRectMake(0, self.gridFrameView.height - 1, gridFrameWidth, 1);
        
    }

    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
    [self.superview setNeedsLayout];
}

#pragma mark - 删除产品确认方法
- (void)deleteProdConfirm:(BOOL)isLongPressMode {
    
    NSMutableIndexSet *mutableIndexSet = [NSMutableIndexSet indexSet];
    for (NSString *index in self.dataGridView.mutableSelectionSet) {
        [mutableIndexSet addIndex:[index integerValue]];
    }
    
    [self.dataGridView deleteProdsWithIndex:[mutableIndexSet copy] andSelectionSet:self.dataGridView.mutableSelectionSet];
    [self.dataGridView.mutableSelectionSet removeAllObjects];
    self.dataGridView.isSelecting = NO;
    [self.dataGridView allowsMultipleSelection:NO];
    
    if (!isLongPressMode) {
        [self.dataGridView resetTableFrameByIsSelection:self.dataGridView.isSelecting];
    }
    
    if ([self.dataGridView.dataSource.addedEditingProds count] > 0) {
        isEdited = YES;
    } else {
        isEdited = NO;
    }

    [[WSStatisticsManager sharedInstance] insertAddProductSenceEventWithID:EVENT_BUTTON_CLICK parentFuncBean:self.currentTableItem.funcsBean.iParentFuncsBean currentFuncBean:self.currentTableItem.funcsBean store:self.store eventValue:NSLocalizedString(@"delete_label",nil) startTime:[WSCurrentTime getTimeMillisStringForDevice] endTime:nil genId:[WSStatisticsManager getGenId]];

    [self checkValueChange];
}

- (void)addMoreProducts:(NSArray *)moreProducts {
    if ([moreProducts count] < 1) {
        return;
    }
    self.isAddedMoreProduct = YES;
    WSAcvtDataGridComponentDataSource *dataSource = [self getAcvtDataSource];
    [dataSource addMoreProduct:moreProducts];
  
//    SFA-21680  SFA-24691 合并代码
    //    SFA-立白-Ios-预设订单模板页面添加产品之后点击返回无提示
    if (dataSource.addedEditingProds.count < dataSource.dataSource.count) {
        [dataSource.addedEditingProds addObjectsFromArray:moreProducts];
    }

    [self resetViewWithDataSource:dataSource];
    [self reloadGridDataWithMoreProdsArray:moreProducts];
    
    // TODO ----
    if (dataSource.addedEditingProds.count > 0) {
        isEdited = YES;
    } else {
        isEdited = NO;
    }
    [self checkValueChange];
}

//YIHAIKERRY-3903 zhaodanyang
- (void)setRequest:(NSString *)isRequest{
    
    [super setRequest:isRequest];

    [self createMoveTitleViewWithOffsetY:0];
    [self createSteadyTableHeadView];
    self.acvtGridSteadyTableHeadView.hidden = YES;
    [self setupSteadyTableHeadView:self.acvtGridSteadyTableHeadView];
}

- (void)resetViewWithDataSource:(WSAcvtDataGridComponentDataSource *)dataSource {
    CGRect newFrame = self.dataGridView.frame;
    if ([dataSource.data count] > 0) {
        // SFA-9909 如果添加更多产品之后返回之前页面表格是闭合状态，则需要强制展开
        if (!self.dataGridView.isExtendedView) {
            [self extendComView];
        }
    }
    
    WSAcvtDataGridComponentView *comView = [[WSAcvtDataGridComponentView alloc] initWithFrame:newFrame data:dataSource];
    comView.delegate = self;
    comView.isAllowedExtend = self.dataGridView.isAllowedExtend;
    comView.isExtendedView = self.dataGridView.isExtendedView;
    comView.tag = self.dataGridView.tag;
    comView.deletedProds = self.dataGridView.deletedProds;
    if (self.dataGridView.popupView) {
        comView.popupView = self.dataGridView.popupView;
        [self.dataGridView removeFromSuperview];
        self.dataGridView.popupView = nil;
    }
    
    // TODO SFA-22234  SFA-立白-IOS-退货申请-添加产品后，赠品表格的删除按钮不显示了
    if (_isAddedMoreProduct) {
        [self.deleteButton removeFromSuperview];
    }
    [self.dataGridView removeFromSuperview];
    self.dataGridView = comView;
    
    [self createSteadyTableHeadView];
    
    [self.gridFrameView addSubview:comView];
    [self setNeedsLayout];
    
    if (!dataSource.isNeedShowMoreButton) {
        [self.moreButton removeFromSuperview];
        self.moreButton = nil;
    }
    if (!dataSource.needShowScanButton) {
        [self.scanButton removeFromSuperview];
        self.scanButton = nil;
    }

    [dataSource addHeaderUI:comView.checkBoxArray];

    //执行初始化的脚本
    if (!_isExcutingLuaScript) {
        // 同步安卓逻辑，initGridValue应该只是初始化时候调用一遍
//        [dataSource loadLuaScriptForInit];
        //执行计算相关的脚本
        [dataSource loadLuaScriptToCompute];
        // YIHAIKERRY-3857 SFA 益海嘉里-传统渠道【提单】选择产品后，应收金额显示为0（统一安卓逻辑，添加新产品回到此页面，表格数据改变，调用setValue脚本)
        [dataSource loadLuaScriptForSetValue];
    }
    
    if ([self.viewController isKindOfClass:[WSAcvtViewController class]]) {
        WSAcvtViewController *acvtVC = (WSAcvtViewController *)self.viewController;
        [acvtVC resetSteadyViewHiddenOrNot];
    }
    
    [((WSAcvtDataGridComponentDataSource *)self.dataGridView.dataSource) setDefautValueForUnit];
//    在调用这个方法 应该重新走他的状态方法 todo 正常应该在初始化单元格控制 SFA-21359 董宏
    if ([[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
        [self setReadonly:[xbuildInfo getReadOnly]];
    }
}

- (void)reloadGridDataWithMoreProdsArray:(NSArray *)moreProdsArray {
    NSMutableArray *arrProds = [NSMutableArray arrayWithCapacity:0];
    for (WSProdBean *prodBean in moreProdsArray) {
        for (WSFuncsBean_Param *fParam in self.currentTableItem.paramArray) {
            NSString *keyStr = [NSString stringWithFormat:@"%@_%@", prodBean.Id, fParam.col];
            NSString *valueStr = [[self getAcvtDataSource].prod_cacheDataMDictionary objectForKey:keyStr];
            if (valueStr && valueStr.length > 0) {
                [[self getAcvtDataSource] setValueWithRowId:prodBean.Id col:fParam.col param:valueStr];
            }
        }
        [arrProds addObject:prodBean.Id];
    }
//    董宏 SFA-26379
    WSAcvtDataGridComponentDataSource *dataSource = (WSAcvtDataGridComponentDataSource *)self.dataGridView.dataSource;
    dataSource.resultCheck = [arrProds componentsJoinedByString:@","];
    [[self getAcvtDataSource] loadLuaScriptToAddProduct];
}

- (void)addMoreProductsFromScan:(NSArray *)moreProducts {
    [self addMoreProducts:moreProducts];
    
    NSString *message;
    SHOW_MESSAGE_TYPE type;
    WSAcvtDataGridComponentDataSource *dataSource = [self getAcvtDataSource];
    if (moreProducts.count > 0) {
        message = [NSString stringWithFormat:NSLocalizedString(@"add_product_success", nil), (long)dataSource.m_moreProdsCount];
        type = MESSAGE_TYPE_AUTO_HIDE_DONE;
    } else {
        message = NSLocalizedString(@"no_add_product", nil);
        type = MESSAGE_TYPE_AUTO_HIDE_FAILED;
        return;
    }
    WSMessageObject *messageobject =[[WSMessageObject alloc] init];
    [messageobject setMessageId:@""];
    [messageobject setMessageType:type];
    [messageobject setDisplayTitle:@""];
    [messageobject setDisplayMessage:message];
    [[WSMessageCenter shareInstance] showMessageView:messageobject];
}

- (void)loadComputeResult:(WSInterAction *)interAction {
    [self addMoreProdsWithParam:[interAction execute_result] andVCName:[interAction execute_class]];
}

- (void)addMoreProdsWithParam:(id)param andVCName:(NSString *)VCName {
    if ([VCName isEqualToString:SELECT_MORE_PRODUCT_CONTROLLER]) {
        if ([param isKindOfClass:[NSArray class]]) {
            [self addMoreProducts:(NSArray *)param];
        }
    } else if ([VCName isEqualToString:TREE_NODE_SELECT_MORE_PRODUCT_CONTROLLER]) {

        [self deleteExistProdsWhenAddingMoreProdsIsSingleSelectedType];

        if ([param isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resultDic = (NSDictionary *)param;
            
            NSArray *selectedMoreProductsArray = (NSArray *)[resultDic objectForKey:@"selectedProds"];
            NSDictionary *prodKeyValueCacheDataDic = (NSDictionary *)[resultDic objectForKey:@"prodKeyValueCacheData"];
            
            for (NSString *cacheKey in prodKeyValueCacheDataDic.allKeys) {
                [[self getAcvtDataSource].prod_cacheDataMDictionary setObject:[prodKeyValueCacheDataDic objectForKey:cacheKey] forKey:cacheKey];
            }
            
            [self addMoreProducts:selectedMoreProductsArray];
            
            if ([[self getAcvtDataSource] isNeedRepeatProd]) {
                [[self getAcvtDataSource] deleteProdsCache:selectedMoreProductsArray];
            }
            
        } else if ([param isKindOfClass:[NSArray class]]) {
            
            [self addMoreProducts:(NSArray *)param];
        }
    } else if ([VCName isEqualToString:SCAN_MORE_PRODUCT_CONTROLLER]) {
        if ([param isKindOfClass:[NSArray class]]) {
            //YIHAIKERRY-3135 2018-06-19
            WSAcvtDataGridComponentDataSource *dataSource = [self getAcvtDataSource];
            NSMutableDictionary *prod_cacheDataMDictionary = dataSource.prod_cacheDataMDictionary;
            NSArray *prodArray = (NSArray *)param;
            for(int i = 0; i < prodArray.count; ++i) {
                WSProdBean *prod = [prodArray objectAtIndex:i];
                NSString *prodJsonStr = [prod yy_modelToJSONString];
                NSDictionary *prodDic = [NSJSONSerialization JSONObjectWithData:[prodJsonStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:NULL];
                
                WSAcvtBean *acvtBean = [[WSAcvtBean alloc] initAcvtBeanWithTableItem:dataSource.currentTableItem withItemId:[prod getDataItemID] withItemName:[prod getDataItemName]  withLuaScript:nil];
                for (WSAcvtBean_qst *qst in acvtBean.qsts) {
                    if (qst.qstId.length > 0 && ([qst.qstId isEqualToString:@"prodId"] || [qst.qstId isEqualToString:@"prodSource"]))
                        continue;
                    
                    NSString *dsStr = ([qst.ds isEqualToString:@"barcode"]) ? @"barcod" : qst.ds;
                    if (dsStr.length > 0 && [prodDic.allKeys containsObject:dsStr]) {
                        NSString *keyStr = [NSString stringWithFormat:@"%@_%@", prod.Id, qst.qstId];
                        NSString *valueStr = [prodDic objectForKey:dsStr];
                        if(valueStr.length > 0)
                            [prod_cacheDataMDictionary setObject:valueStr forKey:keyStr];
                    }
                }
            }
            [self addMoreProductsFromScan:(NSArray *)param];
        }else if ([param isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *results = (NSDictionary *)param;
            NSString *prodId = [NSString stringWithFormat:@"%@",results[@"id"]];
            NSString *prodName = results[@"name"];
            NSDictionary *disData = results[@"data"];
            
            WSProdBean *prod =  [[WSProdBean alloc]init];
            prod.Id = prodId;
            prod.name = prodName;
            NSArray *prodArray = [[NSArray alloc]initWithObjects:prod, nil];
    
            WSAcvtDataGridComponentDataSource *dataSource = [self getAcvtDataSource];
            NSMutableDictionary *prod_cacheDataMDictionary = dataSource.prod_cacheDataMDictionary;
            
            NSArray *allKeys = [disData allKeys];
            for (NSString *key in allKeys) {  //处理回显数据
                
                for (WSFuncsBean_Param *fParam in self.currentTableItem.paramArray) {
                    if ([fParam.name isEqualToString:key]) {
                        
                        NSString *keyStr = [NSString stringWithFormat:@"%@_%@",  prod.Id, fParam.col];
                        NSDictionary *valueDic = [disData objectForKey:key];
                        NSString *valueStr = [valueDic objectForKey:@"val"];
                        if(valueStr.length > 0){
                            [prod_cacheDataMDictionary setObject:valueStr forKey:keyStr];
                        }
                        
                        break;
                    }
                    
                }
                
            }
            
            [self addMoreProductsFromScan:(NSArray *)prodArray];
            
        }
    }
}

// YIHAIKERRY-2722 添加产品是单选模式下删除表格中之前选中的产品
- (void)deleteExistProdsWhenAddingMoreProdsIsSingleSelectedType {
    if ([self getAcvtDataSource].currentQst.mlen.length > 0 && [[self getAcvtDataSource].currentQst.mlen isEqualToString:@"1"]) {
        NSMutableIndexSet *mutableIndexSet = [NSMutableIndexSet indexSet];
        NSMutableSet *mutableSet = [NSMutableSet set];
        for (NSInteger i = 0; i < [self getAcvtDataSource].dataSource.count; i ++) {
            [mutableIndexSet addIndex:i];
            [mutableSet addObject:[NSString stringWithFormat:@"%ld", i]];
        }
        [self.dataGridView deleteProdsWithIndex:[mutableIndexSet copy] andSelectionSet:mutableSet];
    }
}

//SFA-20488 2018-05-28 为了配合安卓逻辑(不应该在TB表格实现 脚本那应该调用getCurrentValue方法)
- (NSObject *)getCurrentValuePresentation {
    if (self.hidden == YES) {
        return nil;
    } else {
        return [self getResultDirectly];
    }
}
//SFA-27318  donghong  返回表格的答案
- (NSString *)getServerGenId
{
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    NSString * redisValue =  [model getAcvtDisValueByStore:model.currentStore acvtQstId:[self.xbuildInfo getAcvtQstId]];
    return redisValue;
}

//SFA-21064 2018-06-21 TB类型默认返回genid
- (NSObject *)getResultPresentation {
    // SFA-22206 没有数据的时候返回空
    NSInteger dataCount = [[self getAcvtDataSource].dataSource count];
    if (dataCount == 0) {
        return nil;
    }
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    return model.md5;
}

- (NSObject *)getResultDirectly {
    if ([[self getAcvtDataSource].currentTableItem.ds isEqualToString:DS_ACVT]) {
        return [[self getAcvtDataSource].acvtTypeDataSourceTool getResultDirectly];
    }
    
    NSString * md5 = [(WSAcvtDataGridComponentDataSource *)[self getAcvtDataSource] md5];
    NSString *postData = nil;
    if (md5 && md5.length > 0) {
        BOOL isIgnoreNullValue = ([(WSAcvtDataGridComponentDataSource *)[self getAcvtDataSource] currentFunc].nullvalue == 1) ? NO : YES;
        
        postData = [WSAcvtDataGridHttpService getAcvtGridJsonDataWithDataSource:[self getAcvtDataSource] acvtMD5:[WSDataSourceManager sharedInstance].currentActiveModel.md5 tableMD5:md5 isIgnoreNullValue:isIgnoreNullValue];
    }
    if (!postData) {
        return nil;
    } else {
        return [(WSAcvtDataGridComponentDataSource *)[self getAcvtDataSource] md5];
    }
}

- (void)delProd:(NSString *)params {
    NSMutableArray *deletedProdsMArray = [[NSMutableArray alloc] init];
    
    WSAcvtDataGridComponentDataSource *acvtDataSource = [self getAcvtDataSource];
    
    NSMutableArray * mArray = [NSMutableArray arrayWithCapacity:[acvtDataSource.dataSource count]];
    [mArray addObjectsFromArray:acvtDataSource.dataSource];
    NSMutableIndexSet *mutableIndexSet = [[NSMutableIndexSet alloc] init];
    NSMutableSet *mSet = [[NSMutableSet alloc] init];
    
    if ([params isEqualToString:@"all"]) {
        for (NSInteger i = 0; i < mArray.count; i ++) {
            [mutableIndexSet addIndex:i];
            [mSet addObject:[NSString stringWithFormat:@"%ld", (long)i]];
        }
    } else if ([params rangeOfString:@","].location != NSNotFound) {
        NSString *delProdIdsStr = params;
        if (![[delProdIdsStr substringWithRange:NSMakeRange(0, 1)] isEqualToString:@","]) {
            delProdIdsStr = [NSString stringWithFormat:@",%@", delProdIdsStr];
        }
        for (NSInteger i = 0; i < mArray.count; i ++) {
            WSProdBean *prodBean = [mArray objectAtIndex:i];
            if ([delProdIdsStr rangeOfString:[NSString stringWithFormat:@",%@,", prodBean.Id]].location != NSNotFound) {
                [mutableIndexSet addIndex:i];
                [mSet addObject:[NSString stringWithFormat:@"%ld", (long)i]];
            }
        }
    }
    
    NSArray *removedArray = [mArray objectsAtIndexes:mutableIndexSet];
    [deletedProdsMArray addObjectsFromArray:removedArray];
    [mArray removeObjectsAtIndexes:mutableIndexSet];
    [acvtDataSource deleteProdsCache:deletedProdsMArray];
    acvtDataSource.dataSource = mArray;
    
    // 不必重新加载整个表格，直接删除对应行即可，这样节省资源且能保留其他行已填写的数据
    [acvtDataSource deleteDatasAtIndexSet:mutableIndexSet];
    [self.dataGridView.leftTableView reloadData];
    [self.dataGridView.rightTableView reloadData];
    [self dataGridComponent:self.dataGridView deleteProds:mSet];
    [acvtDataSource loadLuaScriptToCompute];
}

// param----1,52泸州老窖绝版老酒500ml*6|2,42泸州老窖金奖特曲名酒纪念/品鉴用酒500ml*6|4,52泸州老窖特曲酒750ml*4|
- (void)addGridRows:(NSString *)params {
    if ([params rangeOfString:@"|"].location != NSNotFound) {
        
        WSAcvtDataGridComponentDataSource *acvtDataSource = [self getAcvtDataSource];
        
        NSMutableArray *dataSource = [NSMutableArray array];
        NSArray *prodIdAndItemStrs = [params componentsSeparatedByString:@"|"];
        for (NSInteger i = 0; i < [prodIdAndItemStrs count]; i++) {
            
            WSProdBean *prodBean = [[WSProdBean alloc] init];
            NSString *paramNameAndValues = prodIdAndItemStrs[i];
            if ([paramNameAndValues length] > 0) {
                NSArray *nameAndValues = [paramNameAndValues componentsSeparatedByString:@","];
                
                for (NSInteger m = 0; m < [nameAndValues count]; m++) {
                    NSString *var_id = [nameAndValues firstObject];
                    NSString *var_name = [nameAndValues lastObject];
                    prodBean.Id = var_id;
                    prodBean.name = var_name;
                }
            }
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Id == %@", prodBean.Id];
            NSArray *filteredArray = [acvtDataSource.dataSource filteredArrayUsingPredicate:predicate];
            if (filteredArray.count == 0) {
                if (prodBean.Id.length > 0 && prodBean.name.length > 0) {
                    [dataSource addObject:prodBean];
                }
            }
        }
        
        if ([dataSource count] > 0) {
            _isExcutingLuaScript = YES;
            [self addMoreProducts:dataSource];
        }
    }
}

- (void)widgetDidLoadFinish {
    //    表格初始化脚本的时候 如果该表格隐藏 不执行脚本的初始化 董宏 MN-2654
    [self executionTheLuaScript];
}

////重写这个方法是因为问卷上设置了问题不隐藏但是没有执行脚本的问题
////暂时注释掉 和安卓对过逻辑 执行setWidgetHidden不应该出发脚本
//- (void)setWidgetHidden:(NSString *)isHidden {
//    [super setWidgetHidden:isHidden];
//    [self executionTheLuaScript];
//}

#pragma mark - LuaMethod
- (void)performClickButton:(id)sender {
    if (self.moreButton) {
        [self moreButtonAction:self.moreButton];
    }
}

#pragma mark - DataGridComponentDelegate
- (void)acvtDataGridComponentDataSource:(WSAcvtDataGridComponentDataSource *)dataSource didChange:(NSObject *)object {
    if (object) {
        [self  checkValueChange];
    }
}

- (void)dataGridComponent:(DataGridComponent *)dataGridComponent insertHasBeenEditingProds:(BOOL)insert {
    if (insert) {
        [WSAcvtDataGridComponentService insertDataToTableWithWSAcvtDataGridComponentDataSource:[self getAcvtDataSource]];
    }
}

#pragma mark - WSAcvtDataGridComponentDataSourceDelegate
- (void)acvtDataGridComponentDataSource:(WSAcvtDataGridComponentDataSource *)dataSource addedMoreProductWithCount:(NSInteger)count{
    //不再需要，已通过其他方式处理
}

- (void)acvtDataGridComponentDataSource:(WSAcvtDataGridComponentDataSource *)dataSource addedSelectedProductWithCount:(NSInteger)count changeSerieLinkHeadTitle:(NSString *)title {
    CGRect newFrame = CGRectMake(self.dataGridView.frame.origin.x, self.dataGridView.frame.origin.y, self.dataGridView.frame.size.width,  0);
    WSAcvtDataGridComponentView *comView = [[WSAcvtDataGridComponentView alloc] initWithFrame:newFrame data:dataSource];
    [comView.serieLinkHeadView changeHeadLableText:title];
    [comView.steadySerieLinkHeadView changeHeadLableText:title];
    
    // 改变品牌列表的统计
    [self.dataGridView.popupView redisplayWith:dataSource.addedEditingProds];
    comView.popupView = self.dataGridView.popupView;
    comView.popupView.delegate = comView;
    comView.popupView.selectedBrandIndex = self.dataGridView.popupView.selectedBrandIndex;
    comView.delegate = self;
    comView.deletedProds = self.dataGridView.deletedProds;
    comView.isAllowedExtend = YES;
    comView.isExtendedView = self.dataGridView.isExtendedView;
    comView.tag = self.dataGridView.tag;
    
    [comView setShowSerieLinkHeadView:self.dataGridView.showSerieLinkHeadView];
    
    if (comView.dataSource.needSelect ||
        [comView.dataSource.currentTableItem.opt.deleteButton isEqualToString:@"1"]) {
        CGFloat deleteButtonHeight = [comView attachedViewsHeight];
        self.deleteButton.frame = CGRectMake(kGapBtnLeft, comView.frame.size.height + (DATAGRID_CELL_HEIGHT_DEFAULT - deleteButtonHeight)/2 + 2, self.gridFrameView.size.width - 20, deleteButtonHeight);
        [self attachedViewsEnableShow:YES];
        [self.deleteButton removeFromSuperview];
    }
    
    [self.dataGridView removeFromSuperview];
    self.dataGridView = nil;
    self.dataGridView = comView;
    
    [self createSteadyTableHeadView];
    
    // SFA 项目 SFA-5621  每次选择系列  只有在选择全部产品的情况下 才允许多选，删除。
    if (comView.popupView.selectedBrandIndex == 0) {
        [self.gridFrameView addSubview:self.deleteButton];
        [comView allowsMultipleSelection:YES];
    }else{
         [comView allowsMultipleSelection:NO];
    }
    // 每次选择系列的时候让按钮自动展开
    if (!self.expendButton.selected) {
        [self.expendButton sendActionsForControlEvents:UIControlEventTouchUpInside];
//        [self extendComView];
    }
    
    [self.gridFrameView addSubview:comView];
    
    // SFA-15911 解决选择系列之后父视图未更新frame导致显示不全的问题
    [self layoutSubviews];

    [self executeLuaScript:[xbuildInfo getLuaScript] funcName:nil];
    [self.viewController beginAppearanceTransition:YES animated:NO];
    [self.viewController endAppearanceTransition];
    [((WSAcvtDataGridComponentDataSource *)self.dataGridView.dataSource) setDefautValueForUnit];
}

#pragma mark - 推出代理方法 indexPath:路径
- (void)dataGridComponent:(DataGridComponent *)dataGridComponent pushIndexPath:(NSIndexPath *)indexPath {
    WSAcvtDataGridComponentDataSource *productDataSource = (WSAcvtDataGridComponentDataSource *)dataGridComponent.dataSource;
    NSDictionary *pushDictionary = [productDataSource getAcvtViewForGridDictionaryByIndexPath:indexPath
                                                                                   isReadOnly:[[self getReadonly] boolValue]];
    
    WSTableItem *tableItem = productDataSource.currentTableItem;
    
    NSString *prodId = [pushDictionary objectForKey:@"prodId"];
    NSString *prodName = [pushDictionary objectForKey:@"prodName"];
    
    if (_acvtViewForGridPanel) {
        [_acvtViewForGridPanel removeFromSuperview];
        _acvtViewForGridPanel = nil;
    }
    
    NSString *qstLuaScript = [xbuildInfo getLuaScript];
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    _acvtViewForGridPanel = [[WSAcvtViewForGridPanel alloc] initWithAcvtBean:tableItem withItemId:prodId withItemName:prodName withDisplayValue:pushDictionary withLuaScript:qstLuaScript andCurrentStore:model.currentStore andCurrentSubEmpStore:model.currentSubEmpStore andIsReadOnly:[[self getReadonly] boolValue]];

    // MSTD-7309   YIHAIKERRY-2890 董宏 放在window上 防止编辑导致con出现偏移
    [[self viewController].view addSubview:_acvtViewForGridPanel];
    
    __weak typeof(self)weakSelf = self;
    _acvtViewForGridPanel.reloadGridView = ^(NSDictionary *dict, NSString *rowId) {
        NSArray *allkeys = [dict allKeys];
        for (NSString * key in allkeys) {
            [[weakSelf getAcvtDataSource] setValueWithRowId:rowId col:key param:[dict objectForKey:key]];
            NSString *valueStr = [dict objectForKey:key];
            if (valueStr.length > 0 && rowId.length > 0) {
                [productDataSource.prod_cacheDataMDictionary setObject:valueStr forKey:[NSString stringWithFormat:@"%@_%@", rowId, key]];
            } else if (valueStr.length <= 0 && rowId.length > 0){
                [productDataSource.prod_cacheDataMDictionary removeObjectForKey:[NSString stringWithFormat:@"%@_%@", rowId, key]];
            }
        }
        [weakSelf executeLuaScript:qstLuaScript funcName:nil];
    };
    
    [_acvtViewForGridPanel show];
}

/*删除产品后重新设置views的位置*/
- (void)dataGridComponent:(DataGridComponent *)dataGridComponent deleteProds:(NSSet *)prods {
    if ([prods count] > 0) {
        CGFloat deleteProdsHeight = 0.0;
        for (NSString *prodIndex in prods) {
            NSInteger prodIndexInteger = [prodIndex integerValue];
            if ([[self.dataGridView.cellHeightDic allKeys] containsObject:[NSNumber numberWithInteger:prodIndexInteger]]) {
                NSNumber *cellHeightNumberValue = [self.dataGridView.cellHeightDic objectForKey:[NSNumber numberWithInteger:prodIndexInteger]];
                deleteProdsHeight += [cellHeightNumberValue floatValue];
            }
        }
        
        CGFloat y_offset = deleteProdsHeight;
        CGRect originRect = self.dataGridView.frame;
        originRect.size.height -= y_offset;
        self.dataGridView.frame = originRect;
        
        // YIHAIKERRY-67  删除产品后调整DataGridView的高度
        [self.dataGridView reDrawGridViewWithHeight:originRect.size.height];
        [self setNeedsLayout];
    }
}

- (void)dataGridComponent:(DataGridComponent *)dataGridComponent ExtendGridView:(BOOL)isExtend{
    self.expendButton.selected = isExtend;
    self.steadyViewExpendButton.selected = isExtend;
    self.dataGridView.isExtendedView = self.expendButton.selected;
    [self.dataGridView expendView];
}

- (void)reloadCurrentWidgetWithValue:(NSObject *)value dis:(NSArray *)dis {
    [(WSAcvtDataGridComponentDataSource *)self.dataGridView.dataSource  reloadSubViewsValueWith:(NSString *)value dis:dis];
}

- (void)reloadCurrentWidgetWithValue:(NSObject *)value{

    [self buildDisplayContent];
}

- (void)setStoreId:(NSString *)storeId{
    NSArray *stores = [NSArray array];
    if (storeId.length > 0) {
        stores = [[WSBaseStoreTable sharedTable] queryWithNames:@[@"store_Id"] ArgumentsValue:@[storeId]];
        if (stores.count > 0) {
            WSBaseStoreObject *baseStoreObject = [stores firstObject];
            WSStoreBean  *tempStoreBean = [[WSStoreBean alloc]initstoreWithBaseStoreObject:baseStoreObject isPlan:YES];
            WSAcvtDataGridComponentDataSource *dataSource = (WSAcvtDataGridComponentDataSource *)self.dataGridView.dataSource;
            [dataSource setCurrentStore:tempStoreBean];
            [dataSource resetDataSource];
            
            [self createDataGrid:dataSource];
        }
    }
}

#pragma mark WSAcvtDataGridComponentDataSourceDelegate Methods
- (void)findAcvtQstViewByName:(NSString *)qstName value:(NSString *)value {
    if (!qstName || [qstName length] < 1) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(reloadWidgetWithName:andValue:)]) {
        [self.delegate reloadWidgetWithName:qstName andValue:value];
    }
}

- (void)executeInterAction:(WSInterAction *)interaction {
    if ([self.delegate respondsToSelector:@selector(executeInterAction:)]) {
        [self.delegate executeInterAction:interaction];
    }
}

# pragma mark - Lua Script
- (void)executionTheLuaScript {
    if (self.hidden) {
        return;
    }
    NSString *luaScript = [xbuildInfo getLuaScript];
    if ([luaScript length] > 0) {
        [[self getAcvtDataSource] loadLuaScriptWhenInit];
    }
}

- (void)executeLuaScript:(NSString *)luaScript funcName:(NSString *)funcName {
    WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
    if ([model isKindOfClass:[WSAcvtModel class]]) {
        
        if (luaScript && [luaScript length] > 0) {
            if ([self.delegate respondsToSelector:@selector(executeLuaScript:script:funcName:widget:)]) {
                [self.delegate executeLuaScript:xbuildInfo script:luaScript funcName:funcName widget:self];
            }
        }
    }
}
//特殊处理lua脚本提示方法 tip:提示
- (BOOL)specialHandleLuaTip:(NSString *)tip {
    if (self.scanListViewController) {
        if ([tip containsString:@"setResult@"]) {
            NSArray *array = [tip componentsSeparatedByString:@"setResult@"];
            [self.scanListViewController getReturnDataFromLuaTip:[array lastObject]];
            //去掉了手动输入条码的判断逻辑
            return YES;
        }
        [self.scanListViewController getReturnDataFromLuaTip:tip];
        
        return YES;
    }
    return NO;
}

- (void)executeGridParamLuaScript:(NSString *)luaScript {
    if ([luaScript length] > 0) {
        if ([self.delegate respondsToSelector:@selector(executeGridParamLuaScript:widget:)]) {
            [self.delegate executeGridParamLuaScript:luaScript widget:self];
        }
    }
}

- (NSString *)callGridMethodWithParams:(NSString *)params {
    NSArray *paramArray = [params componentsSeparatedByString:@"[@]"];
    if ([paramArray count] > 2) {
        NSString *rowId = paramArray[0];
        NSString *colName = paramArray[1];
        NSString *methodName = paramArray[2];
        NSString *paramStr;
        
        if ([paramArray count] > 3) {
            paramStr = paramArray[3];
        }
        return [self callGridMethodWithRowId:rowId col:colName methodName:methodName param:paramStr];
        
    } else if ([paramArray count] == 1) {
        if ([params isEqualToString:@"saveTableDataToDB"]) {
            [[self getAcvtDataSource] saveTableDataToDB];
        }
    }
    return nil;
}

- (NSString *)callGridMethodWithRowId:(NSString *)rowId col:(NSString *)colName methodName:(NSString *)methodName param:(NSString *)param {
    if ([methodName rangeOfString:@":"].location != NSNotFound) {
        // 例如 setReadonly: 的方式调用 去掉 :
        methodName = [methodName componentsSeparatedByString:@":"][0];
    }
    NSString *result = @"";
    NSInvocation *invocation = [self invokeMethodName:methodName rowId:rowId col:colName param:param];
    if (invocation) {
        if ([methodName hasPrefix:@"set"]) {
            return nil;
        }
         __autoreleasing NSObject *obj = nil;
        [invocation getReturnValue:&obj];
        if ([obj isKindOfClass:[NSString class]]) {
            result = (NSString *)obj;
        }
        return result;
    }
    if ([methodName isEqualToString:@"setValue"] || [methodName isEqualToString:@"setReadonly"] || [methodName isEqualToString:@"setRequest"]) {
        /*
         * SFA-9720 之前不支持逗号分隔传多个参数的脚本方法，现已与安卓统一部分方法（setValue和setReadonly），加入了多个参数脚本的支持。
         * lua脚本示例：callGridMethodByRowIdAndCol(rowId.."@luaExtra", "col2,col3,col4", "setReadonly:", "true[#]true[#]true");
         */
        NSArray *paramArray = [param componentsSeparatedByString:@"[#]"];
        NSArray *paramColArray = [colName componentsSeparatedByString:@","];
        for (int i = 0; i < paramColArray.count; i++) {
            NSString *subParamCol = [paramColArray objectAtIndex:i];
            NSString *paramValue = ((paramArray.count > i) ? [paramArray objectAtIndex:i] : @"");
            [self invokeMethodName:methodName rowId:rowId col:subParamCol param:paramValue];
        }
        
    }  else if ([methodName isEqualToString:@"setValueArray"]) {
        NSArray *paramArray = [param componentsSeparatedByString:@"[@#]"];
        for (int i = 0; i < paramArray.count; ++i) {
            NSArray *paramColArray = [paramArray[i] componentsSeparatedByString:@","];
            NSArray *subParamCol = [[paramColArray firstObject] componentsSeparatedByString:@"_"];
            NSString *paramValue = ([paramColArray lastObject] ? [paramColArray lastObject] : @"");
            [[self getAcvtDataSource] setValueWithRowId:[subParamCol firstObject] col:[subParamCol lastObject] param:paramValue];
        }
    } else if ([methodName isEqualToString:@"setBackgroundColor"]) {
        [self.dataGridView setBackgroundColorWithRowId:rowId col:colName value:param];
        
    }  else if ([methodName isEqualToString:@"addGridRows"]) {
        [self addGridRows:param];
        
    }else if ([methodName isEqualToString:@"getLocalKeyAndValue"]) {
        NSString *storeId =[NSString stringNotNilWithValue:[self getAcvtDataSource].currentStore.Id] ;
        
        WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
        NSString *replaceStr =[NSString stringWithFormat:@"select prod_id,%@ from visit_dist_rule_item vdri join visit_dist_rule vdr on vdr._id = vdri.main_id where vdr.store_id='%@' and vdr.func_code='%@'",colName,storeId,param] ;
        
        NSArray *dicts = [sqliteUtil queryDicDatasBySql:replaceStr argumentsValues:nil];
        NSString *bigColName = [colName uppercaseString];
        for (NSInteger i = 0; i < [dicts count]; i++) {
            NSDictionary *dictioanry = dicts[i];
            NSString *key = [NSString stringWithFormat:@"%@_%@",dictioanry[@"PROD_ID"],colName];
            NSString *colValue = dictioanry[colName];
            colValue = colValue? colValue : dictioanry[bigColName];
            result = [result stringByAppendingFormat:@"%@,%@",key,colValue];
            result = [result stringByAppendingFormat:@"|"];
        }
        return result;
    }else if ([methodName isEqualToString:@"getProdIdByName"]) {
        WSAcvtDataGridComponentDataSource *dataSource = [self getAcvtDataSource];
        NSString *namesAndIds = @"";
        for (NSInteger i = 0; i < [dataSource.dataSource count]; i++) {
            NSObject <I_W_OptionDataItem> *object = dataSource.dataSource[i];
            NSString *itemName =  [object getDataItemName];
            if ([itemName isEqualToString:param]) {
                namesAndIds = [object getDataItemID];
                break;
            }
        }
        LogInfo(@"考勤显示的id=====%@===%@",param,namesAndIds);
        return namesAndIds;
        
    }else {
        LogError(@"该方法暂不支持");
    }
    return result;
}

- (NSInvocation *)invokeMethodName:(NSString *)methodName rowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)param {
    NSInvocation *invocation = nil;
    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%@WithRowId:col:param:", methodName]);
    NSMethodSignature *signature = [[WSAcvtGridLuaManager class] instanceMethodSignatureForSelector:sel];
    if (signature) {
        WSAcvtDataGridComponentDataSource *dataSource = [self getAcvtDataSource];
        WSAcvtGridLuaManager *luaManager = [[WSAcvtGridLuaManager alloc] initWithDataSource:dataSource];
        invocation = [NSInvocation invocationWithMethodSignature:signature];
        invocation.target = luaManager;
        invocation.selector = sel;
        
        [invocation setArgument:&rowId atIndex:2];
        [invocation setArgument:&colName atIndex:3];
        [invocation setArgument:&param atIndex:4];
        [invocation invoke];
    }
    return invocation;
}

- (NSString *)getDataCount {
    NSInteger count = 0;
    if ([[[self getAcvtDataSource] dataSource] count] > 0) {
        count = [[[self getAcvtDataSource] dataSource] count];
    }
    return [NSString stringWithFormat:@"%ld",count];
}

- (NSObject *)getResultExecuteCheck{
    WSAcvtDataGridComponentDataSource *dataSource = (WSAcvtDataGridComponentDataSource *)self.dataGridView.dataSource;
    return dataSource.resultCheck;
}

- (void)setReadonly:(NSString *)isReadonly {
    [super setReadonly:isReadonly];
    
    isReadonly = [self changeReadonly:isReadonly];
    if ([isReadonly isEqualToString:@"1"]) {
        self.moreButton.enabled = NO;
        self.scanButton.enabled = NO;
        self.deleteButton.enabled = NO;
        
        [self.dataGridView setReadonly:YES isInitFisrt:self.isFirstInit];
        
        // MENGNIU-1143 与安卓统一逻辑：若表格问题只读且无数据则直接隐藏不显示
        // MN-1518 添加hiddenEmpty=0时依旧显示表格的逻辑，即便表格无数据
        if ((!self.dataGridView.dataSource.data || self.dataGridView.dataSource.data.count <= 0) &&
            !([((WSBaseDataGridComponentDataSource *)self.dataGridView.dataSource).currentFunc.hiddenEmpty isEqualToString:@"0"])) {
            self.hidden = YES;
            self.frame = CGRectZero;
            [self.superview layoutSubviews];
        } else {
            self.hidden = NO;
        }
    } else {
        //YIHAIKERRY-4004
        //备注：安卓逻辑，不是只读的话不隐藏,（感觉不太合适不加任何判断条件，如果对其他有影响，可以继续完善）
        self.hidden = NO;
        self.moreButton.enabled = YES;
        self.scanButton.enabled = YES;
        self.deleteButton.enabled = YES;
        [self.dataGridView setReadonly:NO isInitFisrt:self.isFirstInit];
        
        //YIHAIKERRY-3096 2018-06-12
        [self setNeedsLayout];
    }
}

- (void)setHideTableHeader:(NSString *)isHide {
    BOOL isHideTableHeader = NO;
    if (isHide.length > 0 && [isHide boolValue]) {
        isHideTableHeader = YES;
    }
    [self.dataGridView setHideTableHeader:isHide];
}

/*prod_id,20@item9,13@|prod_id,21@item9,12@|*/
- (void)addProd:(NSString *)prodMap {
    if ([prodMap rangeOfString:@"|"].location != NSNotFound) {
        
        WSAcvtDataGridComponentDataSource *acvtDataSource = [self getAcvtDataSource];
        
        NSMutableArray *dataSource = [NSMutableArray array];
        NSArray *prodIdAndItemStrs = [prodMap componentsSeparatedByString:@"|"];
        for (NSInteger i = 0; i < [prodIdAndItemStrs count]; i++) {
            
            WSProdBean *prodBean = [[WSProdBean alloc] init];
            NSString *prodIdAndItemStr = prodIdAndItemStrs[i];
            /*prod_id,20@item9,13*/
            if ([prodIdAndItemStr length] > 0) {
                NSArray *prodIdAndItems = [prodIdAndItemStr componentsSeparatedByString:@"@"];
                for (NSInteger j = 0; j < [prodIdAndItems count]; j++) {
                    NSString *paramNameAndValues = prodIdAndItems[j];
                    
                    if ([paramNameAndValues length] > 0) {
                        NSArray *nameAndValues = [paramNameAndValues componentsSeparatedByString:@","];
                        
                        for (NSInteger m = 0; m < [nameAndValues count]; m++) {
                            NSString *var_name = [nameAndValues firstObject];
                            NSString *var_value = [nameAndValues lastObject];
                            if ([var_name isEqualToString:@"prod_id"]) {
                                prodBean.Id = var_value;
                            }else if ([var_name isEqualToString:@"name"]) {
                                prodBean.name = var_value;
                            }
                        }
                    }
                }
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Id == %@", prodBean.Id];
                NSArray *filteredArray = [acvtDataSource.dataSource filteredArrayUsingPredicate:predicate];
                if (filteredArray.count == 0) {
                    [dataSource addObject:prodBean];
                }
            }
        }
        if ([dataSource count] > 0) {
            _isExcutingLuaScript = YES;
            [self addMoreProducts:dataSource];
            //           SFA-18485假表头需要隐藏  滑动才会显示 董宏 张昊
            self.acvtGridSteadyTableHeadView.hidden = YES;
        }
    }
}

- (void)setTableColValueByProId:(NSString *)prodId textValue:(NSString *)text  col:(NSString *)parmCol {
    WSAcvtGridLuaManager *luaManager = [[WSAcvtGridLuaManager alloc] initWithDataSource:[self getAcvtDataSource]];
    [luaManager setTableColValueFromDataSourceByProId:prodId textValue:text col:parmCol];
}

- (void)setTableColByOtherTableCol:(NSString *)otherTableParmCol funcCode:(NSString *)funcCode  acvtQstCode:(NSString *)acvtQstCode {
    WSAcvtGridLuaManager *luaManager = [[WSAcvtGridLuaManager alloc] initWithDataSource:[self getAcvtDataSource]];
    [luaManager setTableColValueFromDataSourceByOtherTableCol:otherTableParmCol funcCode:funcCode acvtQstCode:acvtQstCode];
}

- (void)initTableDataAndCellData:(NSString *)param {
    WSAcvtDataGridComponentDataSource *dataSource = [self getAcvtDataSource];
    [dataSource initTableDataAndCellData:param];
    [self resetViewWithDataSource:dataSource];
}

// MSTD-7990 脚本转发到 WSAcvtGridLuaManager 执行
- (BOOL)respondsToSelector:(SEL)aSelector {
    BOOL isRespondsToSelctor = [super respondsToSelector:aSelector];
    if (isRespondsToSelctor) {
        return YES;
    }
    WSAcvtGridLuaManager *luaManager = [[WSAcvtGridLuaManager alloc] init];
    return [luaManager respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    WSAcvtGridLuaManager *luaManager = [[WSAcvtGridLuaManager alloc] initWithDataSource:[self getAcvtDataSource]];
    if ([luaManager respondsToSelector:aSelector]) {
        return luaManager;
    }
    return [super forwardingTargetForSelector:aSelector];
}










//=================================================================================================================================================================
//2019-01-10新表格样式整理-----工具部分

#pragma mark - 获取问卷表格数据源方法
- (WSAcvtDataGridComponentDataSource *)getAcvtDataSource {
    
    WSAcvtDataGridComponentDataSource *acvtDataSource = nil;
    if ([self.dataGridView.dataSource isKindOfClass:[WSAcvtDataGridComponentDataSource class]]) {
        acvtDataSource = (WSAcvtDataGridComponentDataSource *)self.dataGridView.dataSource;
    }
    return acvtDataSource;
}

#pragma mark - 获取问卷表格问题id方法
- (NSString *)acvtDataGridQstId {
    
    NSString *qstId = nil;
    WSAcvtDataGridComponentDataSource *acvtDataSource = nil;
    if ([self.dataGridView.dataSource isKindOfClass:[WSAcvtDataGridComponentDataSource class]]) {
        acvtDataSource = (WSAcvtDataGridComponentDataSource *)self.dataGridView.dataSource;
        qstId = acvtDataSource.currentQst.acvtQstId;
    }
    return qstId;
}

#pragma mark - 获取是否横向绘制样式
- (BOOL)getIsTransverseDrawStyle {
    
    if ([[xbuildInfo getDisplayMode] isEqualToString:QST_DISPLAYMODE_ROW_LIST_VERTICAL]) {
        return YES;
    }
    return NO;
}

//=================================================================================================================================================================
//2019-01-10新表格样式整理-----头视图部分

#pragma mark - 创建展开按键方法
- (UIButton *)createExpandButton {
    
    UIImage *checkImage = [UIImage imageNamed:@"brand_checked"];
    UIImage *uncheckImage = [UIImage imageNamed:@"brand_unchecked"];
    UIButton *expendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [expendButton setImage:uncheckImage forState:UIControlStateNormal];
    [expendButton setImage:checkImage forState:UIControlStateSelected];
    CGFloat expendButtonWH = 20.0f;
    expendButton.frame = CGRectMake((kExpendViewWH - expendButtonWH) * 0.5, (kExpendViewWH - expendButtonWH) * 0.5, expendButtonWH, expendButtonWH);
    [expendButton addTarget:self action:@selector(extendComView) forControlEvents:UIControlEventTouchUpInside];
    return expendButton;
}

#pragma mark -  展开按键响应方法
- (void)extendComView {
    
    self.expendButton.selected = !self.expendButton.selected;
    self.steadyViewExpendButton.selected = self.expendButton.selected;
    [self.dataGridView expendView];
}

#pragma mark - 创建标题视图方法
- (UIView *)createTitleViewWithOffsetY:(CGFloat)offsetY expandButton:(UIButton *)expandButton {
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, self.gridFrameView.size.width, kTitleHeight)];
    [titleView setBackgroundColor:([xbuildInfo getBgColor] ? [UIColor colorWithHexString:[xbuildInfo getBgColor]] : [UIColor whiteColor])];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(MAIN_CELL_PADDING, 0,
                                                                    CGRectGetMaxX(titleView.frame) - kExpendViewWH - MAIN_CELL_PADDING - MAIN_PADDING, kTitleHeight)];
    [titleLabel setFont:PanelTextFieldFont];
    [titleLabel setTextColor:PanelTextFieldColor];
    NSString *titlecontent;
    if ( [[xbuildInfo  getISRequire] isKindOfClass:[NSString class]] && [[xbuildInfo  getISRequire] isEqualToString:@"1"]) {
        titlecontent = [NSString stringWithFormat:@"%@*",[xbuildInfo getQuestName]];
    } else {
        titlecontent = [xbuildInfo getQuestName];
    }
    [self setLabel:titleLabel titleContent:titlecontent];
    [titleView addSubview:titleLabel];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame)+ MAIN_PADDING, (kTitleHeight - kExpendViewWH) / 2,
                                                           kExpendViewWH, kExpendViewWH)];
    view.userInteractionEnabled = YES;
    [titleView addSubview:view];
    UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(extendComView)];
    [view addGestureRecognizer:gesture];
    [view addSubview:expandButton];
    
    return titleView;
}

#pragma mark - 设置标题方法
- (void)setLabel:(UILabel *)titleLabel titleContent:(NSString *)titleContent {
    
    NSRange range = [titleContent rangeOfString:@"*"];
    if (range.location != NSNotFound && [[xbuildInfo getISRequire] isEqualToString:@"1"]) {
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:titleContent];
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
        titleLabel.attributedText = string;
    } else {
        titleLabel.text = titleContent;
    }
}

#pragma mark - 创建横向绘制样式头视图方法
- (UIView *)createTransverseDrawStyleHeadViewWithOffsetY:(CGFloat)offsetY {
    
    WSFuncsBean *tbFuncsBean = ((WSBaseDataGridComponentDataSource *)self.dataGridView.dataSource).currentFunc;
    
    CGFloat x = 0.0f;
    CGFloat y = offsetY;
    CGFloat w = CGRectGetWidth(self.gridFrameView.frame);
    CGFloat h = kTitleHeight;
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, self.gridFrameView.size.width, kTitleHeight)];
    [titleView setBackgroundColor:[UIColor whiteColor]];
    
    x = MAIN_PADDING;
    y = (kTitleHeight - 20.0f) / 2;
    w = 20.0f;
    h = 20.0f;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView sd_setImageWithURL:[NSURL URLWithString:[WSHttpURLHelper getImageCompleteURL:tbFuncsBean.icon]] placeholderImage:[UIImage imageNamed:@"place_holder"]];
    [titleView addSubview:imageView];
    
    NSString *buttonTitle = ((tbFuncsBean.buttonName.length > 0) ? tbFuncsBean.buttonName : NSLocalizedString(@"more_product_label", nil));
    CGSize buttonTitleSize = [buttonTitle ws_sizeWithFont:[UIFont systemFontOfSize:UI_Font] constrainedToWidth:CGFLOAT_MAX lineBreakMode:NSLineBreakByCharWrapping];
    x = CGRectGetWidth(self.gridFrameView.frame) - MAIN_PADDING - (buttonTitleSize.width + MAIN_PADDING);
    y = (kTitleHeight - (buttonTitleSize.height + MAIN_PADDING / 2)) / 2;
    w = buttonTitleSize.width + MAIN_PADDING;
    h = buttonTitleSize.height + MAIN_PADDING / 2;
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(x, y, w, h);
    [addButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [addButton setTitle:buttonTitle forState:UIControlStateNormal];
    [self setButtonStyle:addButton];
    [titleView addSubview:addButton];
    
    NSString *titlecontent;
    if ([[xbuildInfo getISRequire] isKindOfClass:[NSString class]] && [[xbuildInfo getISRequire] isEqualToString:@"1"]) {
        titlecontent = [NSString stringWithFormat:@"%@*", [xbuildInfo getQuestName]];
    } else {
        titlecontent = [xbuildInfo getQuestName];
    }
    x = CGRectGetMaxX(imageView.frame) + MAIN_PADDING;
    y = 0.0f;
    w = CGRectGetMinX(addButton.frame) - CGRectGetMaxX(imageView.frame) - (MAIN_PADDING * 2);
    h = kTitleHeight;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel setFont:[UIFont systemFontOfSize:UI_Font]];
    [titleLabel setTextColor:MAIN_TEXT_COLOR];
    [self setLabel:titleLabel titleContent:titlecontent];
    [titleView addSubview:titleLabel];
    
    return titleView;
}

#pragma mark - 创建移动标题视图方法(paneln内的上半部分表头<eg:折叠按键-标题>)
- (void)createMoveTitleViewWithOffsetY:(CGFloat)offsetY {
    
    [self.expendButton removeFromSuperview];
    self.expendButton = nil;
    
    [self.titleView removeAllSubviews];
    [self.titleView removeFromSuperview];
    self.titleView = nil;
    
    if ([self.getAcvtDataSource.currentQst.getIsHideQstName isEqualToString:@"1"]) {
        return;
    }
    
    //YIHAIKERRY-4990
    if ([self getIsTransverseDrawStyle]) {
        self.titleView = [self createTransverseDrawStyleHeadViewWithOffsetY:offsetY];
        [self.gridFrameView addSubview:self.titleView];
        return;
    }
    
    self.expendButton = [self createExpandButton];
    self.titleView = [self createTitleViewWithOffsetY:offsetY expandButton:self.expendButton];
    [self.gridFrameView addSubview:self.titleView];
}

#pragma mark - 创建固定标题视图方法(paneln内的上半部分表头<eg:折叠按键-标题>)
- (void)createFixedTitleViewWithOffsetY:(CGFloat)offsetY {
    
    [self.steadyViewExpendButton removeFromSuperview];
    self.steadyViewExpendButton = nil;
    
    [self.steadyTitleView removeAllSubviews];
    [self.steadyTitleView removeFromSuperview];
    self.steadyTitleView = nil;
    
    if ([self.getAcvtDataSource.currentQst.getIsHideQstName isEqualToString:@"1"]) {
        return;
    }
    
    //YIHAIKERRY-4990
    if ([self getIsTransverseDrawStyle]) {
        self.steadyTitleView = [self createTransverseDrawStyleHeadViewWithOffsetY:offsetY];
        [self.gridFrameView addSubview:self.steadyTitleView];
        return;
    }
    
    self.steadyViewExpendButton = [self createExpandButton];
    self.steadyTitleView = [self createTitleViewWithOffsetY:offsetY expandButton:self.steadyViewExpendButton];
    [self.gridFrameView addSubview:self.steadyTitleView];
}

#pragma mark - 创建固定的表视图
- (void)createSteadyTableHeadView {
    
    [self.acvtGridSteadyTableHeadView removeAllSubviews];
    [self.acvtGridSteadyTableHeadView removeFromSuperview];
    self.acvtGridSteadyTableHeadView = nil;
    
    self.acvtGridSteadyTableHeadView = [self getSteadyTableHeadView];
}

#pragma mark - 获取问卷表格固定头视图方法 说明:表格头视图为2部分(paneln内的为上半部分<eg:折叠按键-标题> 问卷表格内的为下半部分<eg:产品名称-数量-金额>)
- (UIView *)getSteadyTableHeadView {
    
    if ([self getIsTransverseDrawStyle]) {
        
        [self createFixedTitleViewWithOffsetY:0];
        
        CGFloat steadyTableHeadViewHeight = self.steadyTitleView.frame.size.height;
        UIView *steadyTableHeadView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.gridFrameView.size.width, steadyTableHeadViewHeight)];
        CGRect steadyTableHeadViewOriginFrame = self.steadyTitleView.frame;
        steadyTableHeadViewOriginFrame.origin.y = 0.0f;
        self.steadyTitleView.frame = steadyTableHeadViewOriginFrame;
        [steadyTableHeadView addSubview:self.steadyTitleView];
        return steadyTableHeadView;
    }

    [self createFixedTitleViewWithOffsetY:0];
    [self.steadyViewExpendButton setSelected:[self.expendButton isSelected]];
    
    CGFloat padding = 0;
    CGFloat width = self.gridFrameView.size.width - 2 * padding;
    UIView *steadyTableHeadView = nil;
    if ([self.getAcvtDataSource.currentQst.getIsHideQstName isEqualToString:@"1"]) {
        CGFloat steadyTableHeadViewHeight = self.dataGridView.steadyTableHeadView.frame.size.height;
        steadyTableHeadView = [[UIView alloc] initWithFrame:CGRectMake(padding, 0.0f, width, steadyTableHeadViewHeight)];
        CGRect steadyTableHeadViewOriginFrame = self.dataGridView.steadyTableHeadView.frame;
        steadyTableHeadViewOriginFrame.origin.y = 0.0f;
        self.dataGridView.steadyTableHeadView.frame = steadyTableHeadViewOriginFrame;
        [steadyTableHeadView addSubview:self.dataGridView.steadyTableHeadView];
    } else {
        CGFloat steadyTableHeadViewHeight = self.steadyTitleView.frame.size.height + self.dataGridView.steadyTableHeadView.frame.size.height;
        steadyTableHeadView = [[UIView alloc] initWithFrame:CGRectMake(padding, 0, width, steadyTableHeadViewHeight)];
        steadyTableHeadView.backgroundColor = [UIColor lightGrayColor];
        [steadyTableHeadView addSubview:self.steadyTitleView];
        CGRect steadyTableHeadViewOriginFrame = self.dataGridView.steadyTableHeadView.frame;
        steadyTableHeadViewOriginFrame.origin.y = self.steadyTitleView.frame.size.height;
        self.dataGridView.steadyTableHeadView.frame = steadyTableHeadViewOriginFrame;
        [steadyTableHeadView addSubview:self.dataGridView.steadyTableHeadView];
    }

    return steadyTableHeadView;
}

#pragma mark - 设置问卷表格固定头视图到指定界面显示方法
- (void)setupSteadyTableHeadView:(UIView *)tableHeadView {
    
    UIViewController *currentVC = self.viewController;
    if ([currentVC isKindOfClass:[WCBaseViewController class]]) {
        WCBaseViewController *baseVC = (WCBaseViewController *)currentVC;
        [self addTableHeadView:tableHeadView toViewController:baseVC];
    } else if ([currentVC isKindOfClass:[WSSpecialAcvtViewController class]]) {
        WSSpecialAcvtViewController *sacvtVC = (WSSpecialAcvtViewController *)currentVC;
        WSAcvtViewController *acvtVC = (WSAcvtViewController *)sacvtVC.m_AcvtViewController;
        [self addTableHeadView:tableHeadView toViewController:acvtVC];
    }
}

#pragma mark - 添加固定头视图到视图管理器方法
- (void)addTableHeadView:(UIView *)tableHeadView toViewController:(WCBaseViewController *)vc {
    
    CGRect tabHeadViewFrame = tableHeadView.frame;
    if (vc.storeNameLabel) {
        tabHeadViewFrame.origin.y = vc.storeNameLabel.bottom;
    }
    tableHeadView.frame = tabHeadViewFrame;
    if (![vc.view.subviews containsObject:tableHeadView]) {
        [vc.view addSubview:tableHeadView];
    }
}

//=================================================================================================================================================================
//2019-01-10新表格样式整理-----交互按键部分

#pragma mark - 设置删除/更多/扫描按钮的布局方法
- (BOOL)isResetButtonsLayoutWithSelfCurrentHeight:(CGFloat)height {
    
    //YIHAIKERRY-4990
    if ([self getIsTransverseDrawStyle]) {
        return NO;
    }

    if ([[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
        return NO; // 表格只读时不显示按钮
    }
    
    CGFloat buttonCount = 0;
    if ([self getAcvtDataSource].isNeedShowMoreButton) {
        buttonCount++;
    }
    if ([self getAcvtDataSource].needShowScanButton) {
        buttonCount++;
    }
    if (self.dataGridView.dataSource.needSelect || [self.dataGridView.dataSource.currentTableItem.opt.deleteButton isEqualToString:@"1"]) {
        buttonCount++;
    }
    if (buttonCount == 0) {
        return NO;
    }
    
    CGFloat offsetX = kGapBtnLeft;
    CGFloat buttonWidth = (self.gridFrameView.size.width - kGapBtnLeft * 2 - kGapBetweenBtns * (buttonCount - 1)) / buttonCount;
    CGFloat buttonHeight = [self.dataGridView attachedViewsHeight];

    if ([self getAcvtDataSource].isNeedShowMoreButton) {
        self.moreButton.frame = CGRectMake(offsetX, height, buttonWidth, buttonHeight);
        offsetX += kGapBetweenBtns + buttonWidth;
    }
    if ([self getAcvtDataSource].needShowScanButton ) {
        self.scanButton.frame = CGRectMake(offsetX, height, buttonWidth, buttonHeight);
        offsetX += kGapBetweenBtns + buttonWidth;
    }
    if (self.dataGridView.dataSource.needSelect || [self.dataGridView.dataSource.currentTableItem.opt.deleteButton isEqualToString:@"1"]) {
        self.deleteButton.frame = CGRectMake(offsetX, height, buttonWidth, buttonHeight);
        offsetX += kGapBetweenBtns + buttonWidth;
    }
    
    return YES;
}

#pragma mark - 设置按键样式方法
- (void)setButtonStyle:(UIButton *)button {
    
    [button setBackgroundImage:[UIImage createImageWithColor:MAIN_TINT_COLOR] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage createImageWithColor:[MAIN_TINT_COLOR colorWithAlphaComponent:ALPHA_DISABLED]] forState:UIControlStateDisabled];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [button.titleLabel setFont:[UIFont systemFontOfSize:UI_Font]];
    button.layer.cornerRadius = 2.0f;
    button.clipsToBounds = YES;
}

#pragma mark - 设置附加视图是否启动方法(更多按键/扫描按键)
- (void)setAttachedViewsEnable:(BOOL)isEnable {
    
    WSAcvtDataGridComponentDataSource *dataSource = [self getAcvtDataSource];
    if (dataSource.isNeedShowMoreButton) {
        BOOL isReadonly = [[xbuildInfo getReadOnly] isEqualToString:@"1"];
        [self setButton:self.moreButton isEnable:isEnable isReadonly:isReadonly];
        [self setButton:self.scanButton isEnable:isEnable isReadonly:isReadonly];
    }
}

#pragma mark - 设置按键属性方法(是否隐藏/是否启用)
- (void)setButton:(UIButton *)button isEnable:(BOOL)isEnable isReadonly:(BOOL)isReadonly {
    
    if (!button) {
        return;
    }
    
    button.hidden = !isEnable;
    button.enabled = isEnable;
    if (isEnable && isReadonly) {
        button.enabled = NO;
    }
}

#pragma mark - 附加视图启用显示方法(针对删除按键操作)
- (void)attachedViewsEnableShow:(BOOL)isEnable {
    
    if (self.dataGridView.dataSource.needSelect || [self.dataGridView.dataSource.currentTableItem.opt.deleteButton isEqualToString:@"1"]) {
        if (self.deleteButton) {
            self.deleteButton.hidden = !isEnable;
            self.deleteButton.enabled = isEnable;
        }
    }
}

#pragma mark - 获取moreButton方法
- (UIButton *)moreButton {
    
    if (!_moreButton) {
        _moreButton = [[UIButton alloc] init];
        [_moreButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self setButtonStyle:_moreButton];
    }
    return _moreButton;
}

#pragma mark - 创建更多按键方法
- (void)createMoreButtonWithFuncBean:(WSFuncsBean *)tbFuncsBean {
    
    NSString *buttonName = (tbFuncsBean.buttonName.length > 0) ? tbFuncsBean.buttonName : NSLocalizedString(@"more_product_label", nil);
    [self.moreButton setTitle:buttonName forState:UIControlStateNormal];
    [self.gridFrameView addSubview:self.moreButton];
    
    if ([[xbuildInfo getDisplayMode] isEqualToString:@"iconBtn"]) {
        [self.moreButton setTitleColor:kMoreButtonTitleColor forState:UIControlStateNormal];
        [self.moreButton setImage:[UIImage imageNamed:@"btn_add"] forState:UIControlStateNormal];
        self.moreButton.imageEdgeInsets = UIEdgeInsetsMake(self.moreButton.imageView.top, self.moreButton.imageView.left, self.moreButton.imageView.bottom, kGapBetweenBtns);
    }
}

#pragma amrk - 更多按键响应方法
- (void)moreButtonAction:(id)sender {

    [[self getAcvtDataSource] setMoreProdsDefaultColValueCacheDicForCurrentAcvtGrid];
    [[self getAcvtDataSource] refreshCurrentTableItem];
    
    WSInterAction *interaction = [[WSInterAction alloc] init];
    [interaction setAcvt_qust_id:[xbuildInfo  getAcvtQstId]];
    
    if (INTERFACE_IS_PAD) {
        [interaction setDirect_type:DIRECT_TYPE_POPOVER];
    } else {
        [interaction setDirect_type:DIRECT_TYPE_PUSH];
    }
    
    if ([self getAcvtDataSource].currentTableItem.opt.prodtrees && [self getAcvtDataSource].currentTableItem.opt.prodtrees.length > 0) {
        [interaction setExecute_class:TREE_NODE_SELECT_MORE_PRODUCT_CONTROLLER];
        [interaction setExecute_class_param:[self getAcvtDataSource]];
    } else {
        [interaction setExecute_class:SELECT_MORE_PRODUCT_CONTROLLER];
        [interaction setExecute_class_param:[self getAcvtDataSource].moreProductArray];
    }
    
    [interaction setExecute_class_param_title:NSLocalizedString(@"more_product_label", nil)];
    [interaction setInner_param:self.dataGridView.dataSource.currentTableItem.opt];
    if ([delegate respondsToSelector:@selector(executeInterAction:)]) {
        [delegate executeInterAction:interaction];
    }
}

#pragma mark - 获取scanButton方法
- (UIButton *)scanButton {
    
    if (!_scanButton) {
        _scanButton = [[UIButton alloc] init];
        [_scanButton setTitle:NSLocalizedString(@"scan", nil) forState:UIControlStateNormal];
        [_scanButton addTarget:self action:@selector(scanButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self setButtonStyle:_scanButton];
    }
    return _scanButton;
}

#pragma mark - 创建扫描按键方法
- (void)createScanButton {

    [self.gridFrameView addSubview:self.scanButton];
    
    if ([[xbuildInfo getDisplayMode] isEqualToString:@"iconBtn"]) {
        [self.scanButton setTitleColor:MAIN_TINT_COLOR forState:UIControlStateNormal];
        [self.scanButton setBackgroundImage:nil forState:UIControlStateNormal];
        [self.scanButton setImage:[UIImage imageNamed:@"btn_scan"] forState:UIControlStateNormal];
        self.scanButton.imageEdgeInsets = UIEdgeInsetsMake(self.scanButton.imageView.top, self.scanButton.imageView.left, self.scanButton.imageView.bottom, kGapBetweenBtns);
        self.scanButton.layer.cornerRadius = 2.0f;
        UIColor *borColor = MAIN_TINT_COLOR;
        self.scanButton.layer.borderColor = borColor.CGColor;
        self.scanButton.layer.borderWidth = 1.0f;
    }
}

// SFA-29916 SFA 【Diageo】 跨区货物扫码需求
- (BOOL)executeScanLua{
    
    NSString *luaScript = [xbuildInfo getLuaScript];
    if (luaScript && [luaScript length] > 0) {
        if ([luaScript containsString:@"function onScanClick("]) {
            if ([self.delegate respondsToSelector:@selector(executeLuaScript:script:funcName:widget:)]) {
                
                [self.delegate executeLuaScript:xbuildInfo script:luaScript funcName:@"function onScanClick(" widget:self];
                if ([WSLuaExecutorManager shareInstance].isErrorFromScript) {
                    return NO;
                }
            }
        }
    }
    
    return YES;
}
//#pragma mark - 扫描按键响应方法
- (void)scanButtonAction:(id)sender {

    if (![self executeScanLua]) {
        return;
    }
    
    BOOL isMoreProdsContainsBarcode = NO;
    WSAcvtDataGridComponentDataSource *dataSource = [self getAcvtDataSource];
    WSBaseProductDBService *baseProdctDBService = [[WSBaseProductDBService alloc] init];
    
    NSString * mServerObjIdForScan = [xbuildInfo getAcvtMemo2];  //SFA-29916配置了条码节点，扫描时，实时请求条码产品信息

    NSArray *productsList = [baseProdctDBService queryHasBarcodeProductListByIsLimitOne:NO
                                                                                  pType:dataSource.pType
                                                                                    sid:dataSource.model.currentStore.Id
                                                                              disRuleId:dataSource.model.currentStore.drId  appendprop:dataSource.currentFunc.opt.appendprop];
    if ((productsList && productsList.count > 0) || mServerObjIdForScan.length > 0 ) {
        isMoreProdsContainsBarcode = YES;
    }
    
    if (isMoreProdsContainsBarcode) {
        WSCameraAuthHelper *cameraHelper = [[WSCameraAuthHelper alloc] init];
        [cameraHelper authCameraWithBlock:^(BOOL isOK) {
            if (isOK) {
                WSInterAction *interaction = [[WSInterAction alloc] init];
                [interaction setAcvt_qust_id:[xbuildInfo getAcvtQstId]];
                [interaction setExecute_class:SCAN_MORE_PRODUCT_CONTROLLER];
                [interaction setDirect_type:DIRECT_TYPE_PRESENT];
                
                WSAcvtDataGridComponentDataSource *dataSource = [self getAcvtDataSource];
                NSString *needRepeatProd = dataSource.currentFunc.opt.needRepeatProd;
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:2];

                if (![needRepeatProd isEqualToString:@"1"]) {
                    [dic setObject:dataSource.dataSource forKey:PARAM_KEY_VISIBLE_PRODUCTS];
                }
                [dic setObject:productsList forKey:PARAM_KEY_ALL_PRODUCTS];
                [interaction setExecute_class_param:dic];
                [interaction setInner_param:xbuildInfo];

                if ([delegate respondsToSelector:@selector(executeInterAction:)]) {
                    [delegate executeInterAction:interaction];
                }
            }
        }];
    } else {
        BlockAlertView *blockAlertView = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"no_barcode", nil)];
        [blockAlertView addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:nil];
        [blockAlertView show];
    }
    
    [[WSStatisticsManager sharedInstance] insertAddProductSenceEventWithID:EVENT_BUTTON_CLICK
                                                            parentFuncBean:self.currentTableItem.funcsBean.iParentFuncsBean
                                                           currentFuncBean:self.currentTableItem.funcsBean store:self.store
                                                                eventValue:NSLocalizedString(@"scan", nil)
                                                                 startTime:[WSCurrentTime getTimeMillisStringForDevice]
                                                                   endTime:nil genId:[WSStatisticsManager getGenId]];
}

#pragma mark - 获取deleteButton方法
- (UIButton *)deleteButton {
    
    if (!_deleteButton) {
        _deleteButton = [[UIButton alloc] init];
        [_deleteButton setTitle:NSLocalizedString(@"delete_label", nil) forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteProds:) forControlEvents:UIControlEventTouchUpInside];
        [self setButtonStyle:_deleteButton];
    }
    return _deleteButton;
}

#pragma mark - 创建删除按键
- (void)createDeleteButton {
    
    [self attachedViewsEnableShow:YES];
    [self.gridFrameView addSubview:self.deleteButton];
}

#pragma mark - 删除按键响应方法
- (void)deleteProds:(id)sender {
    
    if ([[self getDataCount] integerValue] == 0) {
        return; //SFA益海嘉里YIHAIKERRY-3538 SFA 益海嘉里-传统渠道【200家门店列表】【IOS】新增提单或订单，点击删除按钮，下单产品的“信息详情”和“金额”栏位能够滑动
    }
    
    BOOL isShowOrHideSelection = [self.dataGridView isShowOrHideSelection];
    if (isShowOrHideSelection) {
        return;
    }
    
    if (!self.dataGridView.isExtendedView) {
        if ([self.dataGridView.delegate respondsToSelector:@selector(dataGridComponent:deleteProds:)]) {
            [self.dataGridView.delegate dataGridComponent:self.dataGridView ExtendGridView:self.dataGridView.isExtendedView];
        }
        return;
    }
    
    if(self.dataGridView.dataSource.needSelect){
        //回显品牌系列模式的产品时候，此时无self.popupView 没有选中所有产品页面时候不能删除产品
        if (!self.dataGridView.popupView || self.dataGridView.popupView.selectedBrandIndex != 0) {
            NSString *TakePhotoString = NSLocalizedString(@"select_fill_delete", nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:TakePhotoString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return;
        }
    }
    
    //对应表格 选择按钮出来 再走 最低下的 是否选择 提示对应判断 没出来 应该走这个判断去显示选择按钮 MENGNIU-1259 董宏
    if(!self.dataGridView.isAllowEdit) {
        [self.dataGridView allowsMultipleSelection:YES];
        return;
    }
    
    //品牌系列模式 需要有删除按钮
    if ([self.dataGridView.dataSource.currentTableItem.opt.deleteButton isEqualToString:@"1"] || self.dataGridView.dataSource.needSelect) {
        [self deleteProdAlertscheck:NO];
    }
}

#pragma mark - 删除产品警告检查方法
- (void)deleteProdAlertscheck:(BOOL)isLongPressMode {
    
    if (isLongPressMode) {
        [self deleteProdConfirm:isLongPressMode];
        return;
    }
    
    if ([self.dataGridView.mutableSelectionSet count] > 0) {
        __weak __typeof(self) weakSelf = self;
        NSString *stringcontent = [NSString stringWithFormat:@"确认要删除(%lu)个产品？" , (unsigned long)[self.dataGridView.mutableSelectionSet count]];
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(stringcontent,stringcontent)];
        [alert addButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:nil];
        [alert addButtonWithTitle:NSLocalizedString(@"confirm_label", nil) block:^{
            [weakSelf deleteProdConfirm:isLongPressMode];
        }];
        [alert show];
    } else {
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow
                             withText:NSLocalizedString(@"请选中要删除的产品!", nil)
                                 tips:nil
                            tapTarget:nil
                               action:nil
                                 type:MBProgressHUDMessageTypeFailed autoHideTime:1.0f];
    }
}

#pragma mark - 长按删除回调方法
- (void)longPressDeleteCallback {
    
    [self deleteProdAlertscheck:YES];
}

@end

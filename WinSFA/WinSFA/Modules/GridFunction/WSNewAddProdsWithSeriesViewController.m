//
//  WSNewAddProdsWithSeriesViewController.m
//  WinSFA
//
//  Created by HZH on 2017/9/16.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSNewAddProdsWithSeriesViewController.h"
#import "WSHeaderSearchView.h"
#import "WSNewAddProdsWithSeriesLeftTableViewCell.h"
#import "WSNewAddProdsWithSeriesRightTableViewCell.h"
#import "WSNewAddProdsWithSeriesModel.h"
#import "WSInterAction.h"
#import "WSBaseDictsDBService.h"
#import "WSProdBeanArray.h"
#import "WSAcvtDataGridComponentDataSource.h"
#import "WSBaseProductDBService.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "WSProdHttpService.h"
#import "WSDictBean+child.h"
#import "WSAcvtVCManager.h"
#import "WSAcvtDataGridViewPanel.h"
#import "WSNewAddAcvtViewController.h"
#import "WSNextStepFuncsViewController.h"
#import "WSFptTable.h"
#import "WSEmptySearchView.h"
#import "WSMV_LISTViewController.h"
#import "WSCustomAlertView.h"
#import "WSDataSourceManager.h"
#import "WSRegularTool.h"
#import "WSFuncsBeanArray.h"
#import "WSHighFrequencySearchDataTool.h"
#import "WSHighFrequencySearchResultView.h"
#import "WSStatisticsManager.h"
#define k_SearchHeaderViewDefaultHeight 44.0f
#define kScaleOfLeftTableViewToScreenWidth  0.25
#define kLeftTableViewTag 5911
#define kRightTableViewTag 5912
#define kSearchTableViewTag 5913
#define kLeftTableCellTextSize 14.0
#define kGridCellTextdDefaultFont          ([UIFont fontForKey:@"WorkFlowSectionHeaderViewTitle"] ? [UIFont fontForKey:@"WorkFlowSectionHeaderViewTitle"] : [UIFont fontWithName:@"PingFangSC-Medium" size:kLeftTableCellTextSize])
#define kCollectedFileTitleColor        ([UIColor colorForKey:@"WorkFlowSectionHeaderViewTitle"] ? [UIColor colorForKey:@"WorkFlowSectionHeaderViewTitle"] : kGridCellTextColor)
#define kCollectedFileTitleFont           ([UIFont fontForKey:@"WorkFlowSectionHeaderViewTitle"] ? [UIFont fontForKey:@"WorkFlowSectionHeaderViewTitle"] : [UIFont boldSystemFontOfSize:14])
#define hToolBarHeight 48.0
#define hCodeLabelFontSize 12.0
#define hToolBarBtnWidth 80.0
#define kLeftHeaderHeight 54.0
#define kHighFrequencySearchMaxCount 10 //高频搜索最大数量

NSString *const WSProdsOrdertempletMark = @"ordertemplet";//产品模版标示
NSString *const WSProdsLastOrderMark = @"lastorder";//最近三次订单

typedef enum
{
    WSNewAddProdsSelectedTypeDefaultNone = 0,
    WSNewAddProdsSelectedTypeSingle = 1,        //单选模式
    WSNewAddProdsSelectedTypeMultiple,          //多选模式
}
WSNewAddProdsSelectedType;

@interface WSNewAddProdsWithSeriesViewController () <UITableViewDelegate, UITableViewDataSource, WSNewAddProdsWithSeriesLeftTableViewCellDelegate,  WSNewAddProdsWithSeriesRightTableViewCellDelegate>
{
    BOOL _isAllChecked;
    UITableView *_leftTableView;
    UITableView *_rightTableView;
    UITableView *_searchTableView;
    NSInteger _lastSelectedLeft1LevelTableViewCellIndex;
    NSInteger _lastSelectedLeft2LevelTableViewCellIndex;
    NSInteger _currentRightTableSelectedProdsCount;
    NSInteger _currentSearchTableSelectedProdsCount;
}

@property (nonatomic, strong) UIView *headerSearchView;
@property (nonatomic, strong) NSMutableArray *iSourceProductsArray;
@property (nonatomic, strong) NSMutableArray *iSourceProductsAllIdsArray;
@property (nonatomic, strong) NSMutableArray *allSearchDataArray;
@property (nonatomic, strong) NSMutableArray *allProdsDataMArray;
@property (nonatomic, strong) NSMutableArray *iSelectedProducts; //选中的产品prodBean数组
@property (nonatomic, strong) NSMutableArray *rightTableDataSourceMArray;
@property (nonatomic, strong) NSMutableArray *left1LevelBrandCellMArray; //左边一级组头数组
@property (nonatomic, strong) NSMutableArray *left2LevelBrandCellMArray; //左边展开的二级cell数组
@property (nonatomic, copy) NSString *prodTopTreeNodeIds;
@property (nonatomic, strong) NSArray *firstLevelProdGroupDictsArray;
@property (nonatomic, strong) NSArray *secondLevelProdGroupDictsArray;
@property (nonatomic, strong) NSArray *selectedSecondLevelProdGroupProdsArray;
@property (nonatomic, strong) NSMutableArray *allProdGroupCacheArray;
@property (nonatomic, strong) UIButton *allCheckBtn;
@property (nonatomic, strong) WSSearchBar       *ownSearchBar;
@property (nonatomic, strong) NSArray *needAddEditParamsArray;
@property (nonatomic, strong) NSMutableDictionary *prodKeyValueCacheDataDic;
@property (nonatomic, strong) NSMutableDictionary *originProdKeyValueCacheDataDic;
@property (nonatomic, strong) WSBaseDataGridComponentDataSource *dataGridComponentDataSource;
@property (nonatomic, strong) WSProdHttpService *service;
@property (nonatomic, strong) NSMutableArray *realTimeDataArray;
@property (nonatomic, copy) NSString *titleName;
@property (nonatomic, assign) HNewAddProdsWithSeriesDisplayStyle rightCellDisplayStyle;
@property (nonatomic, strong) NSMutableArray *collectedProdsModelMArray;
@property (nonatomic, assign) BOOL isShowCollectProdsFlag;
@property (nonatomic, strong) UILabel *totalCountLabel;
@property (nonatomic, assign) WSNewAddProdsSelectedType newAddProdsSelectedType;
@property (nonatomic, copy) NSString *lastCheckedProdPosition;
@property (nonatomic, strong) WSEmptySearchView *emptySerchView;
@property (nonatomic, strong) NSMutableDictionary *specialAllSelectDic;     //特殊全选字典
@property (nonatomic, strong) NSMutableDictionary *specialOriginalDataDic;  //特殊原始数据字典
@property (nonatomic, assign) BOOL isShowInvLabel;//cell中是否显示库存这行。 SFA-21330 SFA-21324
@property (nonatomic, strong) WSCustomAlertView *customAlertView;
@property (nonatomic, strong) WSFuncsBean *currentQstFuncs;

@property (nonatomic, strong) WSHighFrequencySearchDataTool *highFrequencySearchDataTool;       //高频搜索工具
@property (nonatomic, strong) WSHighFrequencySearchResultView *highFrequencySearchResultView;   //高频搜索结果视图
@property (nonatomic, assign) CGFloat currentKeyboardHeight;                                    //当前键盘高度
@property (nonatomic, copy) NSString *searchBarCancelText;//搜索框取消文本
@property (nonatomic,copy) NSMutableArray *saleButtonProdIDArray; // 需要显示促销详情按钮的产品id数组
- (void)keyboardWillShow:(NSNotification *)notification; //键盘显示监听方法
- (void)keyboardWillHide:(NSNotification *)notification; //键盘消失监听方法

@end
//===================================================================================================================================================================

#pragma mark - 新添加产品视图管理器 延展(工具)
@interface WSNewAddProdsWithSeriesViewController (Tools)

#pragma mark - 初始化特殊全选字典方法 dictBean:组件 index:索引
- (void)initSpecialAllSelectDicWithDictBean:(WSDictBean *)dictBean index:(NSInteger)index;

#pragma mark - Handle处理特殊全选方法 left1Index:左边组索引 left2Index:组内类别索引
- (BOOL)handleSpecialAllSelectWithLeft1Index:(NSInteger)left1Index left2Index:(NSInteger)left2Index;

#pragma mark - 获取二级产品数据方法 pId:父级id dtyp:类型
- (NSArray *)getSecondLevelProdGroupDictsWithParentId:(NSString *)pId dtyp:(NSString *)dtyp;

#pragma mark - 查询组内产品数据方法 genid:唯一标示 appendprop:附加信息 sid:门店id moreProdType:更多产品类型
- (NSArray *)queryGroupProductsWithGenid:(NSString *)genid appendprop:(NSString *)appendprop sid:(NSString *)sid moreProdType:(NSString *)moreProdType;

- (void)setSpecialOriginalDataWithGenId:(NSString *)genid serverData:(NSArray *)serverData;

#pragma mark - 搜索完毕后的页面数据方法
- (void)searchCompleteHandleViewData;
//遍历品牌(从新计算左边抽屉的右上角数量以及每个条目的数量)
- (void)refreshLeftUI;

#pragma mark - 初始化收藏产品数据模型方法
- (void)initCollectedProdsModelData;

#pragma mark - 同步rightTable的选中状态到allProdsDataMArray中。 righttable的选中状态要同步到searchtable中去
- (void)updateRightStateToSearchTable;

#pragma mark - 搜索文本变换检查方法 text:文本 isBegin:是否开始编辑
- (void)searchBarTextChangeCheckupWithText:(NSString *)text isBegin:(BOOL)isBegin;

#pragma mark - 显示高频搜索结果视图方法
- (void)showHighFrequencySearchResultView;

#pragma mark - 隐藏高频搜索结果视图方法
- (void)hideHighFrequencySearchResultView;

#pragma mark - 初次加载数据方法
- (void)firstLoadData;

@end
//===================================================================================================================================================================

#pragma mark - 新添加产品视图管理器 延展(实现WSHighFrequencySearchResultViewDelegate代理协议)
@interface WSNewAddProdsWithSeriesViewController (highFrequencySearchResultViewDelegate) <WSHighFrequencySearchResultViewDelegate>

@end
//===================================================================================================================================================================

#pragma mark - 新添加产品视图管理器 延展(实现UISearchBarDelegate代理协议)
@interface WSNewAddProdsWithSeriesViewController (searchBarDelegate) <UISearchBarDelegate>

@end
//===================================================================================================================================================================

#pragma mark - 添加新产品视图管理器
@implementation WSNewAddProdsWithSeriesViewController

#pragma mark - 获取highFrequencySearchDataTool方法
- (WSHighFrequencySearchDataTool *)highFrequencySearchDataTool {
    if (!_highFrequencySearchDataTool) {
        _highFrequencySearchDataTool = [[WSHighFrequencySearchDataTool alloc] init];
    }
    return _highFrequencySearchDataTool;
}

#pragma mark - 获取highFrequencySearchResultView方法
- (WSHighFrequencySearchResultView *)highFrequencySearchResultView {
    if (!_highFrequencySearchResultView) {
        _highFrequencySearchResultView = [[WSHighFrequencySearchResultView alloc] initWithFrame:CGRectZero];
        _highFrequencySearchResultView.delegate = self;
    }
    return _highFrequencySearchResultView;
}

#pragma mark - 重写init方法
- (instancetype)init {
    return [self initWithDataGridComponentDataSource:nil title:nil];
}

#pragma mark - 自定义初始化方法 dataSource:数据源 titleName:标题
- (instancetype)initWithDataGridComponentDataSource:(WSBaseDataGridComponentDataSource *)dataSource title:(NSString *)titleName
{
    self = [super init];
    if (self) {
        _dataGridComponentDataSource = dataSource;
        _titleName = titleName;

        _isAllChecked = NO;
        _isShowCollectProdsFlag = NO;
        
        _lastSelectedLeft1LevelTableViewCellIndex = -1;
        _lastSelectedLeft2LevelTableViewCellIndex = -1;
        _currentRightTableSelectedProdsCount = 0;
        _currentSearchTableSelectedProdsCount = 0;
        
        _selectedSecondLevelProdGroupProdsArray = [[NSArray alloc] init];
        _iSelectedProducts = [[NSMutableArray alloc] init];
        _allProdGroupCacheArray = [[NSMutableArray alloc] init];
        _rightTableDataSourceMArray = [[NSMutableArray alloc] init];
        _allSearchDataArray = [[NSMutableArray alloc] init];
        _allProdsDataMArray = [[NSMutableArray alloc] init];
        _collectedProdsModelMArray = [[NSMutableArray alloc] init];
        _left1LevelBrandCellMArray = [[NSMutableArray alloc] init];
        _left2LevelBrandCellMArray = [[NSMutableArray alloc] init];
        _saleButtonProdIDArray = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - 重写viewDidLoad方法
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"pull_to_refresh_refreshing_label", nil) tips:nil tapTarget:self action:nil];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = (_titleName.length > 0) ? _titleName : NSLocalizedString(@"more_product_label", nil);
    
    if ([self.executeParam.execute_class_param isKindOfClass:[WSAcvtDataGridComponentDataSource class]]) {
        self.dataGridComponentDataSource = (WSAcvtDataGridComponentDataSource *)self.executeParam.execute_class_param;
    }
    
    if ([self.dataGridComponentDataSource.currentTableItem.opt.isAddProductStyle isEqualToString:@"list"]) {
        self.rightCellDisplayStyle = HNewAddProdsWithSeriesDisplayStyleGridView;
    }
    else if ([self.dataGridComponentDataSource.currentTableItem.opt.isAddProductStyle isEqualToString:@"acvtList"]) {
        self.rightCellDisplayStyle = HNewAddProdsWithSeriesDisplayStyleAcvtView;
    }
    else {
        self.rightCellDisplayStyle = HNewAddProdsWithSeriesDisplayStyleDefault;
    }
    
    if (self.dataGridComponentDataSource.currentQst.mlen.length > 0) {
        NSInteger maxSelectedProdsNum = [self.dataGridComponentDataSource.currentQst.mlen integerValue];
        if (maxSelectedProdsNum == 1) {
            self.newAddProdsSelectedType = WSNewAddProdsSelectedTypeSingle;
        }
        else if (maxSelectedProdsNum > 1) {
            self.newAddProdsSelectedType = WSNewAddProdsSelectedTypeMultiple;
        }
    }
    
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
    
        if (weakSelf.dataGridComponentDataSource.currentTableItem.opt.refreshNodeName.length > 0) {
            
            weakSelf.service  = [[WSProdHttpService alloc] init];
            weakSelf.service.objID = weakSelf.dataGridComponentDataSource.currentTableItem.opt.refreshNodeName;
            [self.service getProdsDataWithCompletionBlock:^(NSArray *array,NSError *error) {
                weakSelf.realTimeDataArray = (NSMutableArray *)array;
                [weakSelf firstLoadData];
                [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
            }];
            return;
        }
        
        [weakSelf firstLoadData];
        [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    });
}

#pragma mark - 重写viewWillAppear:方法
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - 重写viewWillDisappear:方法
- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - 初始化数据源方法
- (void)initDataSource
{

    WSAcvtDataGridComponentDataSource *acvtDataGridComponentDataSource = (WSAcvtDataGridComponentDataSource *)_dataGridComponentDataSource;
    if(acvtDataGridComponentDataSource.moreProductArray.count > 0)
    {
        // YIHAIKERRY-3515 要求去掉 YIHAIKERRY-3089 的修改
        //YIHAIKERRY-3089 2018-06-12 修改逻辑 清除产品内expirydate为0的数据(为0代表禁用产品/过期产品)
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"expirydate != %@", @"0"];
//        NSMutableArray *resultArray = [[NSMutableArray alloc] initWithArray:[acvtDataGridComponentDataSource.moreProductArray filteredArrayUsingPredicate:predicate]];
//        _iSourceProductsArray = [[NSMutableArray alloc] initWithArray:resultArray];
        _iSourceProductsArray = acvtDataGridComponentDataSource.moreProductArray;

        _iSourceProductsAllIdsArray = [[NSMutableArray alloc] initWithArray:[_iSourceProductsArray valueForKeyPath:@"Id"]];
    }
    
    
    [self initNeedAddEditParamsArrayWithAllParamsArray:acvtDataGridComponentDataSource.currentFunc.paramArray];
    
    _prodKeyValueCacheDataDic = [[NSMutableDictionary alloc] init];
    if ([acvtDataGridComponentDataSource isKindOfClass:[WSAcvtDataGridComponentDataSource class]])
        _prodKeyValueCacheDataDic = acvtDataGridComponentDataSource.prod_cacheDataMDictionary;
    else if (acvtDataGridComponentDataSource)
        _prodKeyValueCacheDataDic = acvtDataGridComponentDataSource.dataSourceCache;
    _originProdKeyValueCacheDataDic = [[NSMutableDictionary alloc] initWithDictionary:_prodKeyValueCacheDataDic];
    
    _prodTopTreeNodeIds = [self getProdTopTreeNodeIdsWithOptProdTreesString:acvtDataGridComponentDataSource.currentTableItem.opt.prodtrees];
    _firstLevelProdGroupDictsArray = [self getFirstLevelProdGroupDicts];
    
    [self setAllProdGroupCacheArray];
    
    for (int i = 0; i < [_firstLevelProdGroupDictsArray count]; i ++)
    {
        WSDictBean *firstLevelProdGroupDict = [_firstLevelProdGroupDictsArray objectAtIndex:i];
        WSNewAddProdsWithSeriesLeftTableViewCell *cell = [[WSNewAddProdsWithSeriesLeftTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.leftTableViewCellStyle = WSNewAddProdsWithSeries1LevelLeftTableViewCell;
        cell.delegate = self;
        cell.titleLabel.text = firstLevelProdGroupDict.name;
        [cell setIsChecked:NO];
        [_left1LevelBrandCellMArray addObject:cell];
        
        [self initSpecialAllSelectDicWithDictBean:firstLevelProdGroupDict index:i]; //SFA-21316
    }
    
    [self initCollectedProdsModelData];
}

- (void)initNeedAddEditParamsArrayWithAllParamsArray:(NSArray *)paramsArray
{
    NSMutableArray *needAddEditParamsMArray = [[NSMutableArray alloc] init];
    
    if (paramsArray && paramsArray.count > 0) {
        for (WSFuncsBean_Param *param in paramsArray) {
            if (param.AddEdit && param.AddEdit.length > 0 && [param.AddEdit isEqualToString:@"1"]) {
                [needAddEditParamsMArray addObject:param];
            }
        }
    }
    
    _needAddEditParamsArray = [NSArray arrayWithArray:needAddEditParamsMArray];
}

- (NSString *)getProdTopTreeNodeIdsWithOptProdTreesString:(NSString *)optProdTreesString
{
    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
    
    NSArray *allProdTreesDictsArray = [service queryDictWithType:optProdTreesString];
    
    NSMutableString *prodTopTreeNodeIdsString = [[NSMutableString alloc] init];
    
    if (allProdTreesDictsArray && allProdTreesDictsArray.count > 0) {
        for (WSDictBean *dict in allProdTreesDictsArray) {
            if (dict.p == nil || dict.p.length <= 0) {
                [prodTopTreeNodeIdsString appendString:[NSString stringWithFormat:@"%@,", dict.Id]];
            }
        }
        
        NSRange lastCharacterRange = NSMakeRange(prodTopTreeNodeIdsString.length - 1, 1);
        
        if ([[prodTopTreeNodeIdsString substringWithRange:lastCharacterRange] isEqualToString:@","]) {
            [prodTopTreeNodeIdsString deleteCharactersInRange:lastCharacterRange];
        }
        
        return prodTopTreeNodeIdsString;
    }
    
    return @"";
    
}

- (void)initSourceProductsAllIdsArray
{
    _iSourceProductsAllIdsArray = [[NSMutableArray alloc] init];

    if (_iSourceProductsArray && _iSourceProductsArray.count > 0) {
        for (WSProdBean *prodBean in _iSourceProductsArray) {
            [_iSourceProductsAllIdsArray addObject:prodBean.Id];
        }
    }

}
#pragma mark- 获取当前问题对应的菜单
- (WSFuncsBean *)currentQstFuncs
{
    if (!_currentQstFuncs) {
        //备注：直接从缓存中取的原因是入库的时候存了本地一份
        WSFuncsBeanArray * fba = [WSAppData getObjectbyKey:FUNCS];
        _currentQstFuncs = [fba getHideFuncsBeanWithFC:_dataGridComponentDataSource.currentQst.mc];
    }
    return _currentQstFuncs;
}

- (void)setAllProdGroupCacheArray
{
    //SFA-25691
    NSString *appendprop = self.dataGridComponentDataSource.currentFunc.opt.appendprop;
    
    [_allProdGroupCacheArray removeAllObjects];
    NSMutableArray *secondLevelProdGroupDictsArray = nil;

    for (int i = 0; i < [_firstLevelProdGroupDictsArray count]; i ++) {
        NSMutableArray *prodCacheMArray = [[NSMutableArray alloc] init];
        
        WSDictBean *firstLevelProdGroupDict = [_firstLevelProdGroupDictsArray objectAtIndex:i];
        //促销专栏
        BOOL  isShowSaleInfoButton = [self isShowSalesButtonWithfirstLevelName:firstLevelProdGroupDict.name];

        if (firstLevelProdGroupDict.childArray.count> 0) {
            secondLevelProdGroupDictsArray = firstLevelProdGroupDict.childArray;
        }else{
            secondLevelProdGroupDictsArray = [NSMutableArray arrayWithArray:[self getSecondLevelProdGroupDictsWithParentId:firstLevelProdGroupDict.Id
                                                                                                                      dtyp:firstLevelProdGroupDict.dtyp]];
        }
        
        for (WSDictBean *secondLevelProdGroupDict in secondLevelProdGroupDictsArray)
        {
            WSBaseProductDBService *baseProductDBService = [[WSBaseProductDBService alloc] init];
            NSArray *secondLevelProdGroupProdsArray = nil;
            if (firstLevelProdGroupDict.childArray.count> 0)
            {
                secondLevelProdGroupProdsArray = secondLevelProdGroupDict.childArray;
            }
            else
            {
                //SFA-20430 2018-05-28 增加分销规则逻辑(需要门店ID与类型)
                NSString *sid = self.dataGridComponentDataSource.currentStore.Id;
                NSString *moreProdType = self.dataGridComponentDataSource.currentTableItem.opt.moreProdType;
                
                //SFA-21064 2018-06-22 增加模版筛选
                if([firstLevelProdGroupDict.dtyp isEqualToString:WSProdsOrdertempletMark])
                    secondLevelProdGroupProdsArray = [self queryGroupProductsWithGenid:secondLevelProdGroupDict.Id appendprop:appendprop
                                                                                   sid:sid moreProdType:moreProdType];
                else if([firstLevelProdGroupDict.dtyp isEqualToString:@"promotion"] || [firstLevelProdGroupDict.dtyp isEqualToString:WSProdsLastOrderMark]) {
                    secondLevelProdGroupProdsArray = [baseProductDBService queryProductsWithGenid:secondLevelProdGroupDict.Id appendprop:appendprop
                                                                                              sid:sid moreProdType:moreProdType needStoreID:YES];
                    if ([firstLevelProdGroupDict.dtyp isEqualToString:WSProdsLastOrderMark]) {
                        [self setSpecialOriginalDataWithGenId:secondLevelProdGroupDict.Id serverData:secondLevelProdGroupProdsArray];
                    }
                } else
                {
                    //SFA-21545
                    NSMutableArray *groupProdsArray = [[NSMutableArray alloc] init];
                    for(WSProdBean* prodBean in self.iSourceProductsArray)
                    {
                        if(prodBean.prodtrees == nil || prodBean.prodtrees.length <= 0)
                            continue;
                        
                        NSArray *prodtreesArray = [prodBean.prodtrees componentsSeparatedByString:@","];
                        if([prodtreesArray containsObject:secondLevelProdGroupDict.Id])
                            [groupProdsArray addObject:prodBean];
                    }
                    secondLevelProdGroupProdsArray = (NSArray *)groupProdsArray;
                    
//                    secondLevelProdGroupProdsArray = [baseProductDBService queryProductsWithProdtreeId:secondLevelProdGroupDict.Id appendprop:appendprop
//                                                                                                   sid:sid moreProdType:moreProdType];
                }
            }
            
            NSArray *secondLevelProdGroupProdModelsArray = [self getNewAddProdsWithSeriesModelArrayWithProdBeanArray:secondLevelProdGroupProdsArray andIsCollected:NO andIsShowSaleButton:isShowSaleInfoButton];
            
            if (secondLevelProdGroupProdModelsArray && secondLevelProdGroupProdModelsArray.count > 0) {
                
                [prodCacheMArray addObject:secondLevelProdGroupProdModelsArray];
            }
            
        }
         [_allProdGroupCacheArray addObject:prodCacheMArray];
    }
    
    _secondLevelProdGroupDictsArray = secondLevelProdGroupDictsArray;

//    NSLog(@"---------_allProdGroupCacheArray.count = %ld", _allProdGroupCacheArray.count);
}

- (NSArray *)getNewAddProdsWithSeriesModelArrayWithProdBeanArray:(NSArray *)prodBeanArray andIsCollected:(BOOL)isCollected andIsShowSaleButton :(BOOL) isShowSaleButton
{
    if (prodBeanArray == nil || prodBeanArray.count <= 0) {
        return [[NSArray alloc] init];
    }
    
    NSArray *bsodArray = [WSBaseStoreOtherDataDBService queryProdSpecImg];
    NSMutableDictionary *bsodDic = [[NSMutableDictionary alloc] init];
    for (WSBaseStoreOtherDataObject *bsod in bsodArray) {
        if ([bsod.item1 length] > 0) {
            NSString *item2 = bsod.item2 ? bsod.item2 : @"";
            [bsodDic setObject:item2 forKey:bsod.item1];
        }
    }
    
    NSMutableArray *newAddProdsWithSeriesModelArray = [[NSMutableArray alloc] init];
    
    for (WSProdBean *prodBean in prodBeanArray) {
        
        WSNewAddProdsWithSeriesModel *rightTableModel = [[WSNewAddProdsWithSeriesModel alloc] init];
        rightTableModel.prodTypeImageUrls = [bsodDic objectForKey:prodBean.imgType];
        rightTableModel.prodBean = prodBean;
        rightTableModel.displayString = prodBean.name;
        rightTableModel.isChecked = NO;
        rightTableModel.isFolded = YES;
        rightTableModel.isCollected = isCollected;
        rightTableModel.cellRealHeight = 80.0;
        
        if (isShowSaleButton) {
            if (![_saleButtonProdIDArray containsObject:prodBean.Id]) {
                [_saleButtonProdIDArray addObject:prodBean.Id];
            }
        }
        
        if (_iSourceProductsAllIdsArray && _iSourceProductsAllIdsArray.count > 0) {
            if ([_iSourceProductsAllIdsArray containsObject:rightTableModel.prodBean.Id]) {
                [newAddProdsWithSeriesModelArray addObject:rightTableModel];
                
                BOOL isAlreadyExist = NO;
                for (NSInteger i = 0; i < _allProdsDataMArray.count; i ++) {
                    WSNewAddProdsWithSeriesModel *tempRightTableModel = [_allProdsDataMArray objectAtIndex:i];
                    if ([tempRightTableModel.prodBean.Id isEqualToString:rightTableModel.prodBean.Id]) {
                        isAlreadyExist = YES;
                        [_allProdsDataMArray replaceObjectAtIndex:i withObject:rightTableModel];
                        break;
                    }
                }
                
                if (!isAlreadyExist)
                    [_allProdsDataMArray addObject:rightTableModel];
            }
        }

    }
    
    return newAddProdsWithSeriesModelArray;
}

- (void)setupSubviews
{
    NSString *searchTag = self.currentFuncs.opt.searchTag;
    if ((!searchTag || [searchTag length]== 0) && self.currentFuncs.opt.searchQuestion) {
        searchTag = self.currentFuncs.opt.searchQuestion;
        
    }
    
    UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"add_label", nil) style:UIBarButtonItemStylePlain target:self action:@selector(addBarButtonItemClicked:)];
    
    self.navigationItem.rightBarButtonItem = addBarButtonItem;
    
    float height = 0.0;
//    float xoffset = 0.0;
//    float width = self.view.bounds.size.width - xoffset;
    
    _headerSearchView = [self getTableHeaderView];
    
    if (_headerSearchView) {
        height = CGRectGetHeight(_headerSearchView.frame);
        [self.view addSubview:_headerSearchView];
    }
    CGFloat toolbarHeight = 26;
    UIView *checkToolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, _headerSearchView.frame.origin.y + _headerSearchView.frame.size.height, SCREEN_WIDTH, toolbarHeight)];
    checkToolBarView .backgroundColor = [UIColor colorWithHexString:@"0xf2f2f2"];
    
     UIImage *noCheckImage = [UIImage imageNamed:@"icn_nocheck"];
    _allCheckBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *checkBtnTitle = NSLocalizedString(@"check_all", nil);
    UIFont *checkBtnFont = [UIFont fontWithName:@"PingFangSC-Medium" size:14.0];
    CGFloat checkBtnHeight = 20;
    CGSize checkBtnSize = [checkBtnTitle ws_sizeWithFont:checkBtnFont constrainedToHeight:checkBtnHeight];
    CGFloat checkBtnWidth = checkBtnSize.width + noCheckImage.size.width + MAIN_TEXT_IMG_PADDING;
    [_allCheckBtn setFrame:CGRectMake(SCREEN_WIDTH - checkBtnWidth - MAIN_BIG_PADDING, (toolbarHeight - checkBtnHeight) / 2, checkBtnWidth, checkBtnHeight)];
    [_allCheckBtn setTitleColor:kGridCellTextColor forState:UIControlStateNormal];
    [_allCheckBtn setTitle:checkBtnTitle forState:UIControlStateNormal];
    _allCheckBtn.titleLabel.font = checkBtnFont;
    [_allCheckBtn addTarget:self action:@selector(allCheckBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [_allCheckBtn setImage:noCheckImage forState:UIControlStateNormal];
//    [_allCheckBtn setImage:[UIImage imageNamed:@"icn_check"] forState:UIControlStateSelected];
//    [allCheckBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -noCheckImage.size.width, 0, noCheckImage.size.width)];
//    [allCheckBtn setImageEdgeInsets:UIEdgeInsetsMake(0, allCheckBtn.titleLabel.bounds.size.width, 0, -allCheckBtn.titleLabel.bounds.size.width)];
    
    // 同步安卓逻辑，问卷模式下隐藏全选按钮，要不脚本跑太多页面会卡顿
    if ([self.dataGridComponentDataSource.currentTableItem.opt.isAddProductStyle isEqualToString:@"acvtList"]) {
        
    }else
        [checkToolBarView addSubview:_allCheckBtn];
    
    [self.view addSubview:checkToolBarView];
    
    CGFloat toolBarHeight = 0.0;
    
    if (self.dataGridComponentDataSource.currentTableItem.opt.hNewStyleProdSelect.length > 0 &&  [self.dataGridComponentDataSource.currentTableItem.opt.hNewStyleProdSelect isEqualToString:@"1"] && [self.dataGridComponentDataSource.currentTableItem.opt.isAddProductStyle isEqualToString:@"acvtList"] && self.newAddProdsSelectedType != WSNewAddProdsSelectedTypeSingle){
        toolBarHeight = hToolBarHeight;
    }
    
    UIView *tableBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0, checkToolBarView.frame.origin.y + checkToolBarView.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT - checkToolBarView.frame.origin.y - checkToolBarView.frame.size.height - 64.0 - toolBarHeight)];
    tableBackgroundView.backgroundColor = [UIColor whiteColor];
    
    _leftTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH * kScaleOfLeftTableViewToScreenWidth, tableBackgroundView.frame.size.height) style:UITableViewStyleGrouped];
    _leftTableView.showsVerticalScrollIndicator = NO;
    _leftTableView.backgroundColor = [UIColor colorWithHexString:@"0xf2f2f2"];
    _leftTableView.tag = kLeftTableViewTag;
    _leftTableView.delegate = self;
    _leftTableView.dataSource = self;
    
    [tableBackgroundView addSubview:_leftTableView];
    
    _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, tableBackgroundView.frame.size.height) style:UITableViewStyleGrouped];
    
    _searchTableView.backgroundColor = [UIColor whiteColor];
    _searchTableView.tag = kSearchTableViewTag;
    _searchTableView.delegate = self;
    _searchTableView.dataSource = self;
    _searchTableView.hidden = YES;
    
    if (self.rightCellDisplayStyle == HNewAddProdsWithSeriesDisplayStyleAcvtView) {
        UIView *collectedFileBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH * kScaleOfLeftTableViewToScreenWidth, 60.0)];
        collectedFileBgView.backgroundColor = kGridCellColor;
        
        NSString *imgName = [self.dataGridComponentDataSource.currentFunc.opt.isCollectionStyle isEqualToString:FUNCS_OPT_IS_COLLECTION_IMG]?@"icon_star_small":@"icon_star_checked";
        
        UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 22.5, 15.0, 15.0)];
        [starImageView setImage:[UIImage imageNamed:imgName]];
        [starImageView setContentMode:UIViewContentModeCenter];
        
        [collectedFileBgView addSubview:starImageView];
        
        UILabel *collectedFileTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 0.0, collectedFileBgView.frame.size.width - 30.0, collectedFileBgView.frame.size.height)];
        collectedFileTitleLabel.numberOfLines = 2;
        collectedFileTitleLabel.font = kCollectedFileTitleFont;
        collectedFileTitleLabel.textColor = kCollectedFileTitleColor;
        collectedFileTitleLabel.text = NSLocalizedString(@"收藏夹", nil);
        
        [collectedFileBgView addSubview:collectedFileTitleLabel];
        
        UITapGestureRecognizer *singleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showCollectedProducts:)];
        
        [collectedFileBgView addGestureRecognizer:singleTapGR];
        
        CGRect leftTableViewFrame = _leftTableView.frame;
        leftTableViewFrame.origin.y = collectedFileBgView.frame.size.height;
        leftTableViewFrame.size.height = leftTableViewFrame.size.height - collectedFileBgView.frame.size.height;
        _leftTableView.frame = leftTableViewFrame;
        
        [tableBackgroundView addSubview:collectedFileBgView];
        
        if (self.dataGridComponentDataSource.currentTableItem.opt.hNewStyleProdSelect.length > 0 &&  [self.dataGridComponentDataSource.currentTableItem.opt.hNewStyleProdSelect isEqualToString:@"1"] && [self.dataGridComponentDataSource.currentTableItem.opt.isAddProductStyle isEqualToString:@"acvtList"] && self.newAddProdsSelectedType != WSNewAddProdsSelectedTypeSingle) {
//            董宏 YIHAIKERRY-2799 在有提交的时候按钮不显示 与安卓逻辑同
            self.navigationItem.rightBarButtonItem = nil;
            [self setupToolBarView];
        }

        //        CGRect tableBackgroundViewFrame = tableBackgroundView.frame;
        //        tableBackgroundViewFrame.size.height = tableBackgroundViewFrame.size.height - hToolBarHeight;
        //        tableBackgroundView.frame = tableBackgroundViewFrame;
        
        
    }
    
    _rightTableView = [[UITableView alloc] initWithFrame:CGRectMake(_leftTableView.frame.size.width, 0, SCREEN_WIDTH - _leftTableView.frame.size.width, tableBackgroundView.frame.size.height) style:UITableViewStyleGrouped];
    
    _rightTableView.backgroundColor = [UIColor clearColor];
    _rightTableView.tag = kRightTableViewTag;
    _rightTableView.delegate = self;
    _rightTableView.dataSource = self;
    
    [tableBackgroundView addSubview:_rightTableView];
    
    [self.view addSubview:tableBackgroundView];
    
    _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, tableBackgroundView.frame.size.height) style:UITableViewStyleGrouped];
    
    _searchTableView.backgroundColor = [UIColor whiteColor];
    _searchTableView.tag = kSearchTableViewTag;
    _searchTableView.delegate = self;
    _searchTableView.dataSource = self;
    _searchTableView.hidden = YES;
    
    [tableBackgroundView addSubview:_searchTableView];
    
    [self.view addSubview:self.highFrequencySearchResultView];
}

- (void)setupToolBarView
{
    UIView *toolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - hToolBarHeight - 64, self.view.frame.size.width, hToolBarHeight)];
    toolBarView.backgroundColor = [UIColor whiteColor];
    
    _totalCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 10 - hToolBarBtnWidth, hToolBarHeight - 20)];
    [_totalCountLabel setTextColor:DETAIL_TEXT_COLOR];
    [_totalCountLabel setFont:[UIFont systemFontOfSize:14]];
    //
    [self setTotalCountLabelTextContent:[NSString stringWithFormat:@"合计:  ¥ 0.00"]];
    
    UIButton *orderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [orderBtn setFrame:CGRectMake(self.view.frame.size.width - hToolBarBtnWidth, 0, hToolBarBtnWidth, hToolBarHeight)];
    orderBtn.backgroundColor = kSubmitAndTotalAcountColor;
    orderBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    
    [orderBtn setTitle:@"提交" forState:UIControlStateNormal];
    [orderBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [orderBtn addTarget:self action:@selector(orderBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [toolBarView addSubview:_totalCountLabel];
    [toolBarView addSubview:orderBtn];
    
    [self.view addSubview:toolBarView];
}

// YIHAIKERRY-3127
- (void)addNOSeacrchResultView
{
    self.emptySerchView = [[WSEmptySearchView alloc] initWithFrame:CGRectMake(self.view.origin.x, self.view.bounds.origin.y + _headerSearchView.height, self.view.width, self.view.height - _headerSearchView.height)];
    self.emptySerchView.backgroundColor = [UIColor whiteColor];
    self.emptySerchView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.emptySerchView];
}

- (void)resetTotalCount:(NSString *)totalCountStr
{
    [self setTotalCountLabelTextContent:[NSString stringWithFormat:@"总计:  ¥ %@", totalCountStr]];
}

- (void)setTotalCountLabelTextContent:(NSString *)textContent
{
    NSMutableAttributedString *hintString = [[NSMutableAttributedString alloc] initWithString:textContent];
    //获取要调整颜色的文字位置,调整颜色
    NSRange range1 = [[hintString string] rangeOfString:@":"];
    NSRange range2 = NSMakeRange(range1.location + 1, textContent.length - range1.location - 1);
    [hintString addAttribute:NSForegroundColorAttributeName value:kSubmitAndTotalAcountColor range:range2];
    
    _totalCountLabel.attributedText = hintString;
}

- (void)orderBtnClicked:(id)sender
{
    [self checkAndGotoNextViewController];
}

- (void)viewDidLayoutSubviews {
    if(INTERFACE_IS_PAD){
        CGRect rect=CGRectMake(0.0, 0.0, self.view.bounds.size.width, 44.0);
        rect.size.width/=2;
        self.ownSearchBar.frame=rect;
        self.ownSearchBar.centerX=self.view.bounds.size.width/2;
    }
}

- (UIView *)getTableHeaderView {
    WSSearchBar *searchBar = [[WSSearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 44.0) isResetTextField:NO isResetBackgroundColor:NO isTop:NO isNotAutoresizingFlexible:YES];
    self.ownSearchBar = searchBar;
    self.ownSearchBar.searchBar.delegate = self;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    if (INTERFACE_IS_PHONE){
        [headerView setBackgroundColor:MAIN_SEARCH_BG_COLOR];
    }
    [headerView addSubview:self.ownSearchBar];
    
    self.ownSearchBar.searchBar.placeholder = NSLocalizedString(@"query_more_sku_hint_label", nil);
    UITextField * searchField = [self.ownSearchBar.searchBar valueForKey:@"_searchField"];
    if (searchField) {
        if ([UIColor colorForKey:@"SearchBarplaceholder"]) {
            [searchField setValue:[UIColor colorForKey:@"SearchBarplaceholder"] forKeyPath:@"_placeholderLabel.textColor"];
        }
        if ([UIFont fontForKey:@"SearchBarplaceholder"]) {
            [searchField setValue:[UIFont fontForKey:@"SearchBarplaceholder"] forKeyPath:@"_placeholderLabel.font"];
        }
        if ([UIColor colorForKey:@"AddProdSearchBarTextFieldBackgroundColor"]) {
            searchField.backgroundColor = [UIColor colorForKey:@"AddProdSearchBarTextFieldBackgroundColor"];
        }
    }
    if ([UIColor colorForKey:@"AddProdSearchBarBackgroundColor"]) {
        self.ownSearchBar.backViewColor = [UIColor colorForKey:@"AddProdSearchBarBackgroundColor"];
    }
    
    return headerView;
}

- (void)allCheckBtnClicked
{
    // 20170916 Need Cache policy, remember all checked_prods, To be continued ...
    // 20170920 Already finished.
    
    _isAllChecked = !_isAllChecked;
    
    if (_searchTableView.hidden) {
        // 已加入对收藏夹产品全选和取消全选的逻辑
        if (_isShowCollectProdsFlag) {
            NSArray *prodsModelMArray = [NSArray arrayWithArray:_collectedProdsModelMArray];
            [self setAllIsCheck:_isAllChecked dataArray:prodsModelMArray tableView:_rightTableView isCollectedProdsNowShow:YES];
            
        } else {
            if (_lastSelectedLeft1LevelTableViewCellIndex >= 0 && _lastSelectedLeft2LevelTableViewCellIndex >= 0) {
                NSArray *prodCacheMArray = [_allProdGroupCacheArray objectAtIndex:_lastSelectedLeft1LevelTableViewCellIndex];
                NSArray *prodsModelMArray = [prodCacheMArray objectAtIndex:_lastSelectedLeft2LevelTableViewCellIndex];
                [self setAllIsCheck:_isAllChecked dataArray:prodsModelMArray tableView:_rightTableView isCollectedProdsNowShow:NO ];
            }
        }
        
        [self refreshFirstLevelBadgeCount];

    } else {
        [self setAllIsCheck:_isAllChecked dataArray:_allSearchDataArray tableView:_searchTableView isCollectedProdsNowShow:YES];
    }
}


- (void)setAllIsCheck:(BOOL)isAllCheck dataArray:(NSArray *)dataArray tableView:(UITableView *)tableView isCollectedProdsNowShow:(BOOL)isCollectedProdsNowShow {
    // YIHAIKERRY-3515 全选的情况下，部分产品可能禁用，全选需要失效
    BOOL isAllValid = YES;
    if (dataArray.count > 0) {
        
        for (NSInteger i = 0; i < dataArray.count; i++) {
            
            WSNewAddProdsWithSeriesModel *rightTableModel = dataArray[i];
            
            // SFA-20520 全选没有设置index 会导致数据混乱
            rightTableModel.secondTypeIndex = i;
            BOOL isCheck = [self isCheckValid:rightTableModel isChecked:isAllCheck];
            if (!isCheck) {
                isAllValid = NO;
            }
            rightTableModel.isChecked = isCheck;
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Id = %@", rightTableModel.prodBean.Id];
            NSArray *array = [_iSelectedProducts filteredArrayUsingPredicate:predicate];
            
            if (isAllCheck) {
                if (isCheck && array.count <= 0) {
                    [_iSelectedProducts addObject:rightTableModel.prodBean];
                }
            } else {
                if(array.count > 0){
                    [_iSelectedProducts removeObjectsInArray:array];
                }
            }
            
            [self synchronizeCollectedProdsAndOtherProdsCheckedStatusWithRightTableModel:rightTableModel andIsCollectedProdsNowShow:isCollectedProdsNowShow];

        }

        //SFA-21339 搜索表视图状态时 无需刷新其它表视图(标准模式下的表视图)
        if(tableView != _searchTableView)
            [self refresh2LevelLeftTableWithProdsModelMArray:dataArray];

        [tableView reloadData];
        
        if (isAllCheck && isAllValid) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            //SFA-21380 SFA-立白-IOS-搜索添加产品时全选光标没有定位在第一个产品的数量列
            [self setGridBecomeFirstResponderWithTableView:tableView indexPath:indexPath];
        }
    }
    
    if (isAllCheck && isAllValid) {
        [_allCheckBtn setImage:[UIImage imageNamed:@"icn_check"] forState:UIControlStateNormal];
    } else {
        [_allCheckBtn setImage:[UIImage imageNamed:@"icn_nocheck"] forState:UIControlStateNormal];
    }
    
}



// SFA-20258 设置表格第一个编辑框焦点
- (void)setGridBecomeFirstResponderWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    if (!self.dataGridComponentDataSource.currentFunc.opt.isSetFocus) {
        return;
    }
    
    NSInteger rows = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    if (rows < 1) {
        return;
    }
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        WSNewAddProdsWithSeriesRightTableViewCell *cell = (WSNewAddProdsWithSeriesRightTableViewCell *)[tableView  cellForRowAtIndexPath:indexPath];
        if (cell) {
            [cell setGridBecomeFirstResponder];
        }
    });
}


// 选择收藏夹或者品牌下的产品时，同步另一个组的产品选中状态
- (void)synchronizeCollectedProdsAndOtherProdsCheckedStatusWithRightTableModel:(WSNewAddProdsWithSeriesModel *)rightTableModel andIsCollectedProdsNowShow:(BOOL)IsShow
{
    if (!IsShow) {
        // SFA-21418 搜索模式下不需要刷新品类，否则崩溃
        if (_searchTableView.hidden){
            for (NSInteger i = 0; i < _allProdGroupCacheArray.count; i ++) {
                NSArray *prodCacheMArray = [_allProdGroupCacheArray objectAtIndex:i];
                
                for (NSInteger j = 0; j < prodCacheMArray.count; j ++) {
                    NSArray *prodsModelMArray = [prodCacheMArray objectAtIndex:j];
                    
                    for (NSInteger k = 0; k < prodsModelMArray.count; k ++) {
                        WSNewAddProdsWithSeriesModel *tempRightTableModel = [prodsModelMArray objectAtIndex:k];
                        if ([tempRightTableModel.prodBean.Id isEqualToString:rightTableModel.prodBean.Id]) {
                            tempRightTableModel.isChecked = rightTableModel.isChecked;
                        }
                    }
                }
            }
        }
    }else{
        for (WSNewAddProdsWithSeriesModel *collectedRightTableModel in _collectedProdsModelMArray) {
            if ([collectedRightTableModel.prodBean.Id isEqualToString:rightTableModel.prodBean.Id]) {
                collectedRightTableModel.isChecked = rightTableModel.isChecked;
                break;
            }
        }
    }
    
    // 如果是搜索状态页面，则此方法isShow默认传YES，然后再同步一遍NO状态的逻辑
    if (!_searchTableView.hidden){
        for (WSNewAddProdsWithSeriesModel *collectedRightTableModel in _collectedProdsModelMArray) {
            if ([collectedRightTableModel.prodBean.Id isEqualToString:rightTableModel.prodBean.Id]) {
                collectedRightTableModel.isChecked = rightTableModel.isChecked;
                break;
            }
        }
    }
    
    //遍历品牌(从新计算左边抽屉的右上角数量以及每个条目的数量)
    [self refreshLeftUI];
    
}

- (void)addBarButtonItemClicked:(id)sender
{
    NSLog(@"addBarButtonItemClicked");
    

    [self checkAndGotoNextViewController];
}


- (void)checkAndGotoNextViewController
{
    [self postReceiveMoreNotificationAndSendSelectedProducts];
    
    if ([_addProdsJumpStyle isEqualToString:@"2"]) {
        //WSNewAddAcvtViewController *currentNeedShowNewAddAcvtVC = (WSNewAddAcvtViewController *)[[WSAcvtVCManager sharedInstance] currentActiveNotShownNewAddAcvtVC];
        //WSAcvtDataGridViewPanel *currentAcvtDataGridViewPanel = [[WSAcvtVCManager sharedInstance] currentActiveAcvtDataGridViewPanel];
        WSNewAddAcvtViewController *currentNeedShowNewAddAcvtVC = (WSNewAddAcvtViewController *)[[WSAcvtVCManager sharedInstance] getAcvtViewController];
        WSAcvtDataGridViewPanel *currentAcvtDataGridViewPanel = (WSAcvtDataGridViewPanel *)[[WSAcvtVCManager sharedInstance] getAcvtDataGridViewPanel];
        NSDictionary *resultDic = [NSDictionary dictionaryWithObjectsAndKeys:self.iSelectedProducts, @"selectedProds", _prodKeyValueCacheDataDic, @"prodKeyValueCacheData", nil];
        
        [currentAcvtDataGridViewPanel addMoreProdsWithParam:resultDic andVCName:[self className]];
        
        [self gotoViewController:currentNeedShowNewAddAcvtVC];
        
    }else{
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    if(self.iSelectedProducts.count > 0){
        
        //SFA-26499  用于监听买赠、特价类目产品是否被添加
        for (WSProdBean *prodBean in self.iSelectedProducts) {
            if (prodBean.parentLevelName.length > 0 && ([prodBean.parentLevelName containsString:@"买赠"] || [prodBean.parentLevelName containsString:@"特价"]) ) {
                
                [[WSStatisticsManager sharedInstance] insertAddProductSenceEventWithID:EVENT_TABLE_ADD_PRODUCT_CAT parentFuncBean:self.currentQstFuncs.iParentFuncsBean currentFuncBean:self.currentQstFuncs store:self.currentStore eventValue:prodBean.parentLevelName startTime:[WSCurrentTime getTimeMillisStringForDevice] endTime:nil genId:[WSStatisticsManager getGenId]];

            }
            else{
                [[WSStatisticsManager sharedInstance] insertAddProductSenceEventWithID:EVENT_TABLE_ADD_CLICK parentFuncBean:self.currentQstFuncs.iParentFuncsBean currentFuncBean:self.currentQstFuncs store:self.currentStore eventValue:NSLocalizedString(@"add_label", nil) startTime:[WSCurrentTime getTimeMillisStringForDevice] endTime:nil genId:[WSStatisticsManager getGenId]];
            }
        }
    }
}

// MN-2527
- (void)gotoViewController:(WSNewAddAcvtViewController *)controller
{
    BOOL isNextFuncs = NO;
    
    //MN-2821 增加opt.refresh逻辑判断
    if([self.currentFuncs.opt.refresh isEqualToString:FUNCS_OPT_REFRESH])
    {
        NSInteger count = [self.navigationController.viewControllers count];
        if (count > 2)
        {
            UIViewController *lastVC =  self.navigationController.viewControllers[count - 2];
            
            if ([lastVC respondsToSelector:@selector(addOtherControllerToView:)]) {
                WSNextStepFuncsViewController *nextStepFuncsVC = (WSNextStepFuncsViewController *)lastVC;
                lastVC = [nextStepFuncsVC addOtherControllerToView:controller];
            }
            
            //SFA 项目SFA-23397 达利（ios）-拜访-进店-订单管理-分为订单和汇总打印，样式不对
            if ([lastVC isKindOfClass:[WSMV_LISTViewController class]]) {
                [self.navigationController popViewControllerAnimated:YES];
                WSMV_LISTViewController *mvListVC = (WSMV_LISTViewController *)lastVC;
                [mvListVC addControllerToCurrentTab:controller];
                isNextFuncs = YES;
            }
        }
    }
    
    if (!isNextFuncs)
    {
        [self.navigationController pushViewController:controller animated:YES];
        [controller initializationBackItemAction];
    }
}



- (void)postReceiveMoreNotificationAndSendSelectedProducts
{
    [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVEMORE object:self.iSelectedProducts];
    
    [self resetProdKeyValueCacheDataDicAndCleanNotCheckedItemsWithIsCleanAll:NO];
    
    if (self.wcBaseViewdelegate && [self.wcBaseViewdelegate respondsToSelector:@selector(callBackWhenFinishTask:)]) {
        // SFA-13283 新增添加产品带入某些列值，所以此处扩展成产品数组和所填列值的字典对象，而非之前的只传产品数组
        NSDictionary *resultDic = [NSDictionary dictionaryWithObjectsAndKeys:self.iSelectedProducts, @"selectedProds", _prodKeyValueCacheDataDic, @"prodKeyValueCacheData", nil];
        self.executeParam.execute_result = resultDic;
        [self.wcBaseViewdelegate callBackWhenFinishTask:self.executeParam];
        
//        [_prodKeyValueCacheDataDic removeAllObjects];
    }
}

- (void)showCollectedProducts:(id)sender
{
    NSLog(@"showCollectedProducts");
    
    _isShowCollectProdsFlag = YES;
    
    [self checkAndSetCollectProdsAllCheckedStatus];
    
    [_rightTableView reloadData];
}

- (void)checkAndSetCollectProdsAllCheckedStatus
{
    BOOL isAllChecked = NO;
    
    for (WSNewAddProdsWithSeriesModel *collectedRightTableModel in _collectedProdsModelMArray) {
        if (collectedRightTableModel.isChecked) {
            
            isAllChecked = YES;
        }
    }
    
    _isAllChecked = isAllChecked;
    
    if (_isAllChecked) {
        [_allCheckBtn setImage:[UIImage imageNamed:@"icn_check"] forState:UIControlStateNormal];
    }else{
        [_allCheckBtn setImage:[UIImage imageNamed:@"icn_nocheck"] forState:UIControlStateNormal];
    }
}

- (void)didSelectedCell:(WSNewAddProdsWithSeriesLeftTableViewCell *)cell
{
    
    _isShowCollectProdsFlag = NO;

    if (cell.leftTableViewCellStyle == WSNewAddProdsWithSeries1LevelLeftTableViewCell) {
        //MN-4318
        _isAllChecked = NO;
        [_allCheckBtn setImage:[UIImage imageNamed:@"icn_nocheck"] forState:UIControlStateNormal];
        
        NSInteger currentSelectedIndex = [_left1LevelBrandCellMArray indexOfObject:cell];
        
        cell.isChecked = !cell.isChecked;
        
        [_left2LevelBrandCellMArray removeAllObjects];
        [_rightTableDataSourceMArray removeAllObjects];
        
        //SFA-27149
         [[WSStatisticsManager sharedInstance] insertAddProductSenceEventWithID:EVENT_TABLE_ADD_LEVEL1_CLICK parentFuncBean:self.currentQstFuncs.iParentFuncsBean currentFuncBean:self.currentQstFuncs store:self.currentStore eventValue:cell.titleLabel.text startTime:[WSCurrentTime getTimeMillisStringForDevice] endTime:nil genId:[WSStatisticsManager getGenId]];
        
        if (cell.isChecked) {
            WSDictBean *currentFirstLevelProdGroupDict = [_firstLevelProdGroupDictsArray objectAtIndex:currentSelectedIndex];
            
            _secondLevelProdGroupDictsArray = [self getSecondLevelProdGroupDictsWithParentId:currentFirstLevelProdGroupDict.Id dtyp:currentFirstLevelProdGroupDict.dtyp];

            NSArray *prodCacheMArray = [_allProdGroupCacheArray objectAtIndex:currentSelectedIndex];
            if (prodCacheMArray.count > 0) {
                for (int i = 0; i < [_secondLevelProdGroupDictsArray count]; i ++) {
                    
                    WSDictBean *secondLevelProdGroupDict = [_secondLevelProdGroupDictsArray objectAtIndex:i];
                    
                    NSArray *prodsModelMArray = [prodCacheMArray objectAtIndex:i];
                    
                    WSNewAddProdsWithSeriesLeftTableViewCell *cell = [[WSNewAddProdsWithSeriesLeftTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.leftTableViewCellStyle = WSNewAddProdsWithSeries2LevelLeftTableViewCell;
                    cell.titleLabel.text = [NSString stringWithFormat:@"%@%@", secondLevelProdGroupDict.name, [self getProdCountStringWithNewAddProdsWithSeriesModelArray:prodsModelMArray]];
                    
                    cell.delegate = self;
                    [cell setIsChecked:NO];
                    if (![[self getProdCountStringWithNewAddProdsWithSeriesModelArray:prodsModelMArray] isEqualToString:@"(0/0)"]) {
                        [_left2LevelBrandCellMArray addObject:cell];
                    }
                }

            }
        }
        
        if (_lastSelectedLeft1LevelTableViewCellIndex >= 0 && _lastSelectedLeft1LevelTableViewCellIndex != [_left1LevelBrandCellMArray indexOfObject:cell]) {
            WSNewAddProdsWithSeriesLeftTableViewCell *leftHeaderViewCell = (WSNewAddProdsWithSeriesLeftTableViewCell *)[_left1LevelBrandCellMArray objectAtIndex:_lastSelectedLeft1LevelTableViewCellIndex];
            leftHeaderViewCell.isChecked = NO;
            
        }
        
        _lastSelectedLeft1LevelTableViewCellIndex = [_left1LevelBrandCellMArray indexOfObject:cell];
        _lastSelectedLeft2LevelTableViewCellIndex = -1;
        [_leftTableView reloadData];
        [_rightTableView reloadData];
    }
    else if (cell.leftTableViewCellStyle == WSNewAddProdsWithSeries2LevelLeftTableViewCell)
    {
        NSInteger currentSelectedIndex = [_left2LevelBrandCellMArray indexOfObject:cell];
        cell.isChecked = YES;
        NSString *eventValue = nil;
        
        if ([cell.titleLabel.text containsString:@"("]) {
            NSArray *array = [cell.titleLabel.text componentsSeparatedByString:@"("];
            eventValue = [array firstObject];
        }
        else{
            eventValue = cell.titleLabel.text;
        }
        
        [[WSStatisticsManager sharedInstance] insertAddProductSenceEventWithID:EVENT_TABLE_ADD_LEVEL2_CLICK parentFuncBean:self.currentQstFuncs.iParentFuncsBean currentFuncBean:self.currentQstFuncs store:self.currentStore eventValue:eventValue startTime:[WSCurrentTime getTimeMillisStringForDevice] endTime:nil genId:[WSStatisticsManager getGenId]];
        
        if (_lastSelectedLeft2LevelTableViewCellIndex >= 0 && _lastSelectedLeft2LevelTableViewCellIndex != currentSelectedIndex)
        {
            WSNewAddProdsWithSeriesLeftTableViewCell *leftHeaderViewCell = (WSNewAddProdsWithSeriesLeftTableViewCell *)[_left2LevelBrandCellMArray objectAtIndex:_lastSelectedLeft2LevelTableViewCellIndex];
            leftHeaderViewCell.isChecked = NO;
            
        }
        _lastSelectedLeft2LevelTableViewCellIndex = currentSelectedIndex;
        
        [_leftTableView reloadData];
        [_rightTableDataSourceMArray removeAllObjects];
        [_rightTableView reloadData];
        
        if (_lastSelectedLeft1LevelTableViewCellIndex >= 0 && _lastSelectedLeft2LevelTableViewCellIndex >= 0)
        {
            NSArray *prodCacheMArray = [_allProdGroupCacheArray objectAtIndex:_lastSelectedLeft1LevelTableViewCellIndex];
            NSArray *prodsModelMArray = [prodCacheMArray objectAtIndex:_lastSelectedLeft2LevelTableViewCellIndex];
            
            //SFA-21316
            if([self handleSpecialAllSelectWithLeft1Index:_lastSelectedLeft1LevelTableViewCellIndex left2Index:_lastSelectedLeft2LevelTableViewCellIndex])
            {
                _isAllChecked = YES;
                [self setAllIsCheck:_isAllChecked dataArray:prodsModelMArray tableView:_rightTableView isCollectedProdsNowShow:NO];
                [self refreshFirstLevelBadgeCount];
                [self getProdCountStringWithNewAddProdsWithSeriesModelArray:prodsModelMArray];
            }
            else
            {
                [self getProdCountStringWithNewAddProdsWithSeriesModelArray:prodsModelMArray];
                
                if (prodsModelMArray && prodsModelMArray.count > 0)
                {
                    if (_currentRightTableSelectedProdsCount == prodsModelMArray.count){
                        [_allCheckBtn setImage:[UIImage imageNamed:@"icn_check"] forState:UIControlStateNormal];
                        // SFA-21336 赵丹阳
                        _isAllChecked = YES;
                    }
                    else
                    {
                        [_allCheckBtn setImage:[UIImage imageNamed:@"icn_nocheck"] forState:UIControlStateNormal];
                        // SFA-21336 赵丹阳
                        _isAllChecked = NO;
                    }
                }
            }
        }
    }
}

- (NSString *)getProdCountStringWithNewAddProdsWithSeriesModelArray:(NSArray *)newAddProdsWithSeriesModelArray
{
    if (newAddProdsWithSeriesModelArray && newAddProdsWithSeriesModelArray.count > 0) {
        NSInteger selectedProdsCount = 0;
        
        for (WSNewAddProdsWithSeriesModel *rightTableModel in newAddProdsWithSeriesModelArray) {
            if (rightTableModel.isChecked) {
                selectedProdsCount ++;
            }
        }
        _currentRightTableSelectedProdsCount = selectedProdsCount;
        return [NSString stringWithFormat:@"(%ld/%ld)", selectedProdsCount, newAddProdsWithSeriesModelArray.count];
    }else{
        return @"(0/0)";
    }
}

- (void)setSecondLevelProdGroupCellDataWithParentId:(NSString *)firstLevelProdGroupDictId
{
    
}

- (void)backAction
{
    [self.view endEditing:YES]; //SFA-25324
    
    //SFA-24136
    [self backPromptWithFuncs:self.currentQstFuncs addBlock:^{
         [self checkAndGotoNextViewController];
    } confirmBlock:^{
        [super backAction];
        [self resetProdKeyValueCacheDataDicAndCleanNotCheckedItemsWithIsCleanAll:YES];

    } cancelBlock:^{

    } iSelectedProducts:self.iSelectedProducts];
}

- (void)backPromptWithFuncs:(WSFuncsBean *)funcs addBlock:(void (^)())addBlock confirmBlock:(void (^)())confirmBlock cancelBlock:(void (^)())cancelBlock iSelectedProducts:(NSMutableArray *)iSelectedProducts {
    if (funcs.opt.backDialog_tip.length > 0 && iSelectedProducts.count > 0) {
        //SFA-25721
        NSMutableArray *buttons = [NSMutableArray arrayWithObjects:NSLocalizedString(@"cancel_label", nil),NSLocalizedString(@"back_label", nil),NSLocalizedString(@"add_label", nil), nil];
        WSCustomAlertView *customAlertView = [[WSCustomAlertView alloc] initWithFrame:self.view.bounds buttonsTitle:buttons message:funcs.opt.backDialog_tip];
        [self.view addSubview:customAlertView];
         customAlertView.selectButtonBlock = ^(UIButton *button,NSInteger tag) {
             switch (tag) {
                 case 0: // 取消
                      cancelBlock();
                     break;
                 case 1://确定
                     confirmBlock();
                     break;
                 case 2: // 添加
                     addBlock();
                     break;
                 default:
                     break;
             }
        };
    } else {
        confirmBlock();
    }
}

// MN-1458 新增返回清除未勾选产品填写过的数值，若之后需要保留用户上次填写则去除此方法调用即可
// isCleanAll=YES 清除所有; isCleanAll=NO 只清除未勾选
- (void)resetProdKeyValueCacheDataDicAndCleanNotCheckedItemsWithIsCleanAll:(BOOL)isCleanAll
{
    NSMutableDictionary *tempProdKeyValueCacheDataMDic = [[NSMutableDictionary alloc] initWithDictionary:_originProdKeyValueCacheDataDic];
    //    donghong  MN-2411 产品信息 替换又问题  不应该检索原始的key
    if (!isCleanAll) {
        for (WSProdBean *prodBean in self.iSelectedProducts) {
            for (WSFuncsBean_Param *param in self.dataGridComponentDataSource.currentTableItem.paramArray) {
                NSString *prodCacheKey = [NSString stringWithFormat:@"%@_%@", prodBean.Id, param.col];
                if (/*![_originProdKeyValueCacheDataDic objectForKey:prodCacheKey] && */[_prodKeyValueCacheDataDic objectForKey:prodCacheKey]) {
                    [tempProdKeyValueCacheDataMDic setObject:[_prodKeyValueCacheDataDic objectForKey:prodCacheKey] forKey:prodCacheKey];
                }
            }
        }
    }
    
    _prodKeyValueCacheDataDic = tempProdKeyValueCacheDataMDic;
    
    if ([self.dataGridComponentDataSource isKindOfClass:[WSAcvtDataGridComponentDataSource class]]) {
        WSAcvtDataGridComponentDataSource *acvtDataGridComponentDataSource = (WSAcvtDataGridComponentDataSource *)self.dataGridComponentDataSource;
        acvtDataGridComponentDataSource.prod_cacheDataMDictionary = _prodKeyValueCacheDataDic;
    }
    
}

#pragma mark --- UITableViewDelegate and UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.tag == kLeftTableViewTag) {
        return _firstLevelProdGroupDictsArray.count;
    }else if (tableView.tag == kRightTableViewTag) {
        return 1;
    }else if (tableView.tag == kSearchTableViewTag) {
        return 1;
    }
    else
        return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == kLeftTableViewTag) {
        if (section == _lastSelectedLeft1LevelTableViewCellIndex) {
            if (_left2LevelBrandCellMArray && _left2LevelBrandCellMArray > 0) {
                return _left2LevelBrandCellMArray.count;
            }else
                return 0;
        }else
            return 0;
    }else if (tableView.tag == kRightTableViewTag) {
        
        NSArray *prodsModelMArray = nil;
        
        if (_isShowCollectProdsFlag) {
            prodsModelMArray = [NSArray arrayWithArray:_collectedProdsModelMArray];
        }else{
            if (_lastSelectedLeft1LevelTableViewCellIndex >= 0 && _lastSelectedLeft2LevelTableViewCellIndex >= 0) {
                NSArray *prodCacheMArray = [_allProdGroupCacheArray objectAtIndex:_lastSelectedLeft1LevelTableViewCellIndex];
                
                prodsModelMArray = [prodCacheMArray objectAtIndex:_lastSelectedLeft2LevelTableViewCellIndex];
                
            }
        }
        
        
        
        if (prodsModelMArray && prodsModelMArray > 0) {
            return prodsModelMArray.count;
        }
        
        return 0;

    }else if (tableView.tag == kSearchTableViewTag) {
        if (_allSearchDataArray && _allSearchDataArray.count > 0) {
            return _allSearchDataArray.count;
        }else
            return 0;
    }
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == kLeftTableViewTag) {
        CGFloat left2LevelCellHeight = 44.0;
        WSNewAddProdsWithSeriesLeftTableViewCell *cell = nil;
        
        if (_left2LevelBrandCellMArray && _left2LevelBrandCellMArray.count > 0 && [[_left2LevelBrandCellMArray objectAtIndex:indexPath.row] isKindOfClass:[WSNewAddProdsWithSeriesLeftTableViewCell class]]) {
            cell = (WSNewAddProdsWithSeriesLeftTableViewCell *)[_left2LevelBrandCellMArray objectAtIndex:indexPath.row];
            CGSize tempTitleStringSize = [cell.titleLabel.text ws_sizeWithFont:kGridCellTextdDefaultFont constrainedToWidth:(_leftTableView.frame.size.width - 20.0) lineBreakMode:NSLineBreakByCharWrapping];
            
            if (tempTitleStringSize.height > 44.0) {
                left2LevelCellHeight = tempTitleStringSize.height;
            }
            
        }
        
        return left2LevelCellHeight;
    }else if (tableView.tag == kRightTableViewTag) {
        CGFloat rightCellHeight = 44.0;

        NSArray *prodsModelMArray = nil;
        
        if (_isShowCollectProdsFlag) {
            prodsModelMArray = [NSArray arrayWithArray:_collectedProdsModelMArray];
        }else{
            if (_lastSelectedLeft1LevelTableViewCellIndex >= 0 && _lastSelectedLeft2LevelTableViewCellIndex >= 0) {
                NSArray *prodCacheMArray = [_allProdGroupCacheArray objectAtIndex:_lastSelectedLeft1LevelTableViewCellIndex];
                
                prodsModelMArray = [prodCacheMArray objectAtIndex:_lastSelectedLeft2LevelTableViewCellIndex];
                
            }
        }
        
        
        if (prodsModelMArray && prodsModelMArray.count > 0) {
            WSNewAddProdsWithSeriesModel *rightTableModel = (WSNewAddProdsWithSeriesModel *)[prodsModelMArray objectAtIndex:indexPath.row];
            CGSize tempTitleStringSize = [rightTableModel.displayString ws_sizeWithFont:[UIFont fontWithName:@"PingFangSC-Medium" size:kLeftTableCellTextSize] constrainedToWidth:(_rightTableView.frame.size.width - 40.0) lineBreakMode:NSLineBreakByCharWrapping];
            
            if (self.rightCellDisplayStyle == HNewAddProdsWithSeriesDisplayStyleAcvtView) {
                rightCellHeight = rightTableModel.cellRealHeight;
            }else{
                tempTitleStringSize.height += 23;

                if (tempTitleStringSize.height > 44.0) {
                    rightCellHeight = tempTitleStringSize.height;
                }
                
                if (rightTableModel.prodTypeImageUrls && rightTableModel.prodTypeImageUrls.length > 0) {
                    rightCellHeight = rightCellHeight + 30.0;
                }
                
                if (_needAddEditParamsArray && _needAddEditParamsArray.count > 0 && rightTableModel.isChecked) {
                  //  rightCellHeight = rightCellHeight + 90.0;
                    //SFA-24166  IOS：SFA立白【经销商】订单添加产品优化需求——添加产品页面数量子数量优化
                    rightCellHeight = rightCellHeight + 51;
                }
            }
            
            
        }
        
        
        NSLog(@"******************  rightCellHeight = %.1f", rightCellHeight);
        
        return rightCellHeight;
    }else if (tableView.tag == kSearchTableViewTag) {
        CGFloat searchCellHeight = 44.0;

        if (_allSearchDataArray && _allSearchDataArray.count > 0) {
            WSNewAddProdsWithSeriesModel *rightTableModel = (WSNewAddProdsWithSeriesModel *)[_allSearchDataArray objectAtIndex:indexPath.row];
            
            CGSize tempTitleStringSize = [rightTableModel.displayString ws_sizeWithFont:[UIFont fontWithName:@"PingFangSC-Medium" size:kLeftTableCellTextSize] constrainedToWidth:(_rightTableView.frame.size.width - 40.0) lineBreakMode:NSLineBreakByCharWrapping];
            
            if (self.rightCellDisplayStyle == HNewAddProdsWithSeriesDisplayStyleAcvtView) {
                searchCellHeight = rightTableModel.cellRealHeight;
            }else{
                tempTitleStringSize.height += 23;

                if (tempTitleStringSize.height > 44.0) {
                    searchCellHeight = tempTitleStringSize.height;
                }
                
                if (rightTableModel.prodTypeImageUrls && rightTableModel.prodTypeImageUrls.length > 0) {
                    searchCellHeight = searchCellHeight + 30.0;
                }
                
                if (_needAddEditParamsArray && _needAddEditParamsArray.count > 0 && rightTableModel.isChecked) {
//                    searchCellHeight = searchCellHeight + 90.0;
                    //SFA-24166  IOS：SFA立白【经销商】订单添加产品优化需求——添加产品页面数量子数量优化
                    searchCellHeight = searchCellHeight + 51;

                }
            }

        }

        return searchCellHeight;
    }
    else
        return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == kLeftTableViewTag) {
        return kLeftHeaderHeight;
    }else if (tableView.tag == kRightTableViewTag) {
        return 0.01;
    }else
        return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == kLeftTableViewTag) {
        UIView *leftHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH * kScaleOfLeftTableViewToScreenWidth, kLeftHeaderHeight)];
        leftHeaderView.backgroundColor = [UIColor lightGrayColor];
        
        WSNewAddProdsWithSeriesLeftTableViewCell *leftHeaderViewCell = (WSNewAddProdsWithSeriesLeftTableViewCell *)[_left1LevelBrandCellMArray objectAtIndex:section];
        [leftHeaderViewCell setFrame:CGRectMake(0, 0, SCREEN_WIDTH * kScaleOfLeftTableViewToScreenWidth, kLeftHeaderHeight)];
        
        return leftHeaderViewCell;
    }else if (tableView.tag == kRightTableViewTag) {
        return nil;
    }else
        return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == kLeftTableViewTag) {
        
        WSNewAddProdsWithSeriesLeftTableViewCell *cell = nil;
        
        if (_left2LevelBrandCellMArray && _left2LevelBrandCellMArray.count > 0 && [[_left2LevelBrandCellMArray objectAtIndex:indexPath.row] isKindOfClass:[WSNewAddProdsWithSeriesLeftTableViewCell class]]) {
            cell = (WSNewAddProdsWithSeriesLeftTableViewCell *)[_left2LevelBrandCellMArray objectAtIndex:indexPath.row];
        }
        
        return cell;
    } else if (tableView.tag == kRightTableViewTag || tableView.tag == kSearchTableViewTag) {
        
        WSNewAddProdsWithSeriesRightTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if (cell == nil) {
            static NSString *reueserId;
            if (tableView.tag == kRightTableViewTag) {
                reueserId = @"cellForRightTable";
            } else if (tableView.tag == kSearchTableViewTag) {
                reueserId = @"cellForSearchTable";
            }
            cell = [[WSNewAddProdsWithSeriesRightTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reueserId];
            
            cell.displayStyle = self.rightCellDisplayStyle;

            CGRect cellFrame = cell.frame;
             if (tableView.tag == kRightTableViewTag) {
                cellFrame.size.width = SCREEN_WIDTH * (1.0 - kScaleOfLeftTableViewToScreenWidth);
             } else if (tableView.tag == kSearchTableViewTag) {
                cellFrame.size.width = SCREEN_WIDTH;
             }
                 
            [cell setFrame:cellFrame];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        WSNewAddProdsWithSeriesModel *rightTableModel = nil;
      
        if (tableView.tag == kRightTableViewTag) {
             NSArray *prodsModelMArray = nil;
            
            if (_isShowCollectProdsFlag) {
                prodsModelMArray = [NSArray arrayWithArray:_collectedProdsModelMArray];
            }else{
                if (_lastSelectedLeft1LevelTableViewCellIndex >= 0 && _lastSelectedLeft2LevelTableViewCellIndex >= 0) {
                    NSArray *prodCacheMArray = [_allProdGroupCacheArray objectAtIndex:_lastSelectedLeft1LevelTableViewCellIndex];
                    
                    prodsModelMArray = [prodCacheMArray objectAtIndex:_lastSelectedLeft2LevelTableViewCellIndex];
                    
                }
            }
            
            if (prodsModelMArray && prodsModelMArray.count > 0){
                
                rightTableModel = (WSNewAddProdsWithSeriesModel *)[prodsModelMArray objectAtIndex:indexPath.row];
                
                if(_lastSelectedLeft1LevelTableViewCellIndex < self.firstLevelProdGroupDictsArray.count){
                    WSDictBean *currentFirstLevelProdGroupDict = [self.firstLevelProdGroupDictsArray objectAtIndex:_lastSelectedLeft1LevelTableViewCellIndex];
                    if([currentFirstLevelProdGroupDict.dtyp isEqualToString:WSProdsOrdertempletMark] ||
                       [currentFirstLevelProdGroupDict.dtyp isEqualToString:WSProdsLastOrderMark]){
                        if(_lastSelectedLeft2LevelTableViewCellIndex < self.secondLevelProdGroupDictsArray.count){
                            WSDictBean *secondLevelProdGroupDict = [self.secondLevelProdGroupDictsArray objectAtIndex:_lastSelectedLeft2LevelTableViewCellIndex];
                            NSMutableDictionary *dic = [self.specialOriginalDataDic objectForKey:secondLevelProdGroupDict.Id];
                            //SFA-23456
//                        for(WSFuncsBean_Param *param in self.needAddEditParamsArray){
                            for (NSString *key in [dic allKeys]) {
                                // SFA-23962 会出现重复产品，所以屏蔽该判断
                                //                                if (![[self.prodKeyValueCacheDataDic allKeys] containsObject:key]) {
                                NSString *itemValue = [dic objectForKey:key];
                                [self.prodKeyValueCacheDataDic setObject:[NSString stringNotNilWithValue:itemValue] forKey:key];
                                //                                }
                            }
                            //                        }
                        }
                    }
                }
            }
        } else if (tableView.tag == kSearchTableViewTag) {
            rightTableModel = (WSNewAddProdsWithSeriesModel *)[_allSearchDataArray objectAtIndex:indexPath.row];
        }
            
        cell.indexPath = indexPath;
        cell.prodKeyValueCacheDataDic = _prodKeyValueCacheDataDic;
        cell.cellDelegate = self;
        cell.currentStore = self.currentStore;
        cell.currentTableItem = _dataGridComponentDataSource.currentTableItem;
        cell.luaScriptString = _dataGridComponentDataSource.currentQst.getLuaScript;
        cell.secondTypeIndex = rightTableModel.secondTypeIndex;
        cell.prodBean = rightTableModel.prodBean;
        cell.prodTypeImageUrls = rightTableModel.prodTypeImageUrls;
        cell.allNeedParamsArray = _dataGridComponentDataSource.currentFunc.paramArray;
        //            cell.isFolded = rightTableModel.isFolded;
        
        cell.titleLabel.text = rightTableModel.displayString;
        //            if(_prodKeyValueCacheDataDic.count>0)
        //SFA-21330 SFA-21324 IOS-要货申请添加产品页面不显示库存 IOS-退货申请添加产品时不需要显示库存字段
        if(self.isShowInvLabel)
        {
            NSString *strInventory = [_prodKeyValueCacheDataDic objectForKey:[NSString stringWithFormat:@"%@_inv",rightTableModel.prodBean.Id]];
            cell.inventoryLabel.text = [NSString stringWithFormat:@"库存：%@",strInventory ? strInventory : @"0"];
        }
        cell.needAddEditParamsArray = _needAddEditParamsArray;
        cell.isChecked = rightTableModel.isChecked;
        //SFA-25558
        if ([_saleButtonProdIDArray containsObject:rightTableModel.prodBean.Id] ) {
            [cell.salesButton setHidden:NO];
        }
        else{
            [cell.salesButton setHidden:YES];

        }
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        NSString *collectedProdIdsString = [userDefaults objectForKey:ALL_COLLECTED_PRODIDS];
        
        if (collectedProdIdsString && collectedProdIdsString.length > 0) {
            if ([collectedProdIdsString rangeOfString:[NSString stringWithFormat:@",%@,", rightTableModel.prodBean.Id]].location != NSNotFound) {
                rightTableModel.isCollected = YES;
            }else{
                rightTableModel.isCollected = NO;
            }
        }
        
        rightTableModel.cellRealHeight = cell.cellRealHeight;
        
        cell.rightTableModel = rightTableModel;
        
        if (cell.prodTypeImageUrls && cell.prodTypeImageUrls.length > 0) {
            CGRect cellFrame = cell.frame;
            cellFrame.size.height = cellFrame.size.height + 30.0;
            [cell setFrame:cellFrame];
        }
        
        if (cell.isChecked && cell.needAddEditParamsArray.count > 0) {
            CGRect cellFrame = cell.frame;
            cellFrame.size.height = cellFrame.size.height + 51.0;
            [cell setFrame:cellFrame];
        }
        
        if (cell.displayStyle == HNewAddProdsWithSeriesDisplayStyleAcvtView) {
            CGRect cellFrame = cell.frame;
            cellFrame.size.height = rightTableModel.cellRealHeight;
            [cell setFrame:cellFrame];
        }
        
        return cell;
    }
    else
        return nil;
}
//SFA-24187  IOS：SFA立白【经销商】订单添加产品搜索—滑动查询搜索结果键盘收起需求
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView.tag == kSearchTableViewTag) {
        [self.ownSearchBar.searchBar resignFirstResponder];
    }
}
- (void)needRefreshTotalPrice
{
    [self refreshToolbarTotalLabelText];
}

- (void)needUpdateCell:(WSNewAddProdsWithSeriesRightTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    [self refreshToolbarTotalLabelText];
    
    NSArray *prodsModelMArray = nil;
    
    if (_searchTableView.hidden){
        if (_isShowCollectProdsFlag) {
            prodsModelMArray = [NSArray arrayWithArray:_collectedProdsModelMArray];
        }else{
            if (_lastSelectedLeft1LevelTableViewCellIndex >= 0 && _lastSelectedLeft2LevelTableViewCellIndex >= 0) {
                NSArray *prodCacheMArray = [_allProdGroupCacheArray objectAtIndex:_lastSelectedLeft1LevelTableViewCellIndex];
                
                prodsModelMArray = [prodCacheMArray objectAtIndex:_lastSelectedLeft2LevelTableViewCellIndex];
                
            }
        }
    }else{
        if (_allSearchDataArray && _allSearchDataArray.count > 0) {
            prodsModelMArray = [NSArray arrayWithArray:_allSearchDataArray];
        }
    }
    
    if (prodsModelMArray && prodsModelMArray.count > 0) {
        WSNewAddProdsWithSeriesModel *rightTableModel = (WSNewAddProdsWithSeriesModel *)[prodsModelMArray objectAtIndex:indexPath.row];
        //        rightTableModel.isFolded = cell.isFolded;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        NSString *collectedProdIdsString = [userDefaults objectForKey:ALL_COLLECTED_PRODIDS];
        
        if (rightTableModel.isCollected) {
            if (collectedProdIdsString && collectedProdIdsString.length > 0) {
                if ([collectedProdIdsString rangeOfString:[NSString stringWithFormat:@",%@,", rightTableModel.prodBean.Id]].location == NSNotFound) {
                    collectedProdIdsString = [NSString stringWithFormat:@"%@%@,", collectedProdIdsString, rightTableModel.prodBean.Id];
                    
                    [_collectedProdsModelMArray addObject:rightTableModel];
                }
            }else{
                collectedProdIdsString = [NSString stringWithFormat:@",%@,", rightTableModel.prodBean.Id];
                [_collectedProdsModelMArray addObject:rightTableModel];
            }
        }else{
            if (collectedProdIdsString && collectedProdIdsString.length > 0) {
                NSRange subStrRange = [collectedProdIdsString rangeOfString:[NSString stringWithFormat:@",%@,", rightTableModel.prodBean.Id]];
                if (subStrRange.location != NSNotFound) {
                    NSMutableString *mString = [NSMutableString stringWithString:collectedProdIdsString];
                    [mString replaceCharactersInRange:subStrRange withString:@","];
                    collectedProdIdsString = [NSString stringWithFormat:@"%@", mString];
                }
                
                WSNewAddProdsWithSeriesModel *rTempTableModel = nil;
                
                for (WSNewAddProdsWithSeriesModel *rTableModel in _collectedProdsModelMArray) {
                    WSProdBean *prodB = rTableModel.prodBean;
                    if ([prodB.Id isEqualToString:rightTableModel.prodBean.Id]) {
                        rTempTableModel = rTableModel;
                        break;
                    }
                }
                
                if (rTempTableModel) {
                    [_collectedProdsModelMArray removeObject:rTempTableModel];
                }
                
                //                NSLog(@"_collectedProdsModelMArray = %@", _collectedProdsModelMArray);
            }else{
                
            }
        }
        
        
        [userDefaults setObject:collectedProdIdsString forKey:ALL_COLLECTED_PRODIDS];
        
        [userDefaults synchronize];
        
        
    }
    
    if (_isShowCollectProdsFlag) {
        [_rightTableView reloadData];
    }else{
        // YIHAIKERRY-3540  用UITableViewRowAnimationAutomatic 刷新单行 cell不显示 改为：UITableViewRowAnimationNone
        if (_searchTableView.hidden) {
            [_rightTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
        }else{
            [_searchTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    
    
}

- (void)refreshToolbarTotalLabelText
{
    CGFloat totalOrderPrice = 0.0;
    for (WSProdBean *prodBean in self.iSelectedProducts) {
        NSString *distValueStr;
//        distValueStr = [_prodKeyValueCacheDataDic objectForKey:[NSString stringWithFormat:@"%@_dist", prodBean.Id]];
        if (distValueStr && distValueStr.length > 0 && [distValueStr floatValue] != 0) {
            totalOrderPrice += [distValueStr floatValue];
        }else{
            NSString *ordValueStr = [_prodKeyValueCacheDataDic objectForKey:[NSString stringWithFormat:@"%@_ord", prodBean.Id]];
            if (ordValueStr && ordValueStr.length > 0 && [ordValueStr floatValue] != 0) {
                totalOrderPrice += [ordValueStr floatValue];
            }
        }
    }
    
    [self resetTotalCount:[NSString stringWithFormat:@"%.2f", totalOrderPrice]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == kRightTableViewTag || tableView.tag == kSearchTableViewTag) {
        
        NSArray *dataArray = nil;
        BOOL isCollectedProdsNowShow = NO;
        WSNewAddProdsWithSeriesModel *rightTableModel;
        
        if (tableView.tag == kRightTableViewTag) {
            
            [self refreshDataModelCheckedStatusAndBrandCheckedProdsCountWithNowCheckedIndex:indexPath.row];
        
            if (_isShowCollectProdsFlag) {
                dataArray = [NSArray arrayWithArray:_collectedProdsModelMArray];
            } else {
                if (_lastSelectedLeft1LevelTableViewCellIndex >= 0 && _lastSelectedLeft2LevelTableViewCellIndex >= 0) {
                    NSArray *prodCacheMArray = [_allProdGroupCacheArray objectAtIndex:_lastSelectedLeft1LevelTableViewCellIndex];
                    
                    dataArray = [prodCacheMArray objectAtIndex:_lastSelectedLeft2LevelTableViewCellIndex];
                }
            }
            
            if (dataArray && dataArray.count > 0) {
               
                if (_isShowCollectProdsFlag) {
                    isCollectedProdsNowShow = YES;
                } else {
                    isCollectedProdsNowShow = NO;
                }
                
                //SFA 项目SFA-21185 SFA-立白-IOS-添加赠品时，显示的赠品数量比勾选的赠品数量少1
                rightTableModel = (WSNewAddProdsWithSeriesModel *)[dataArray objectAtIndex:indexPath.row];
                rightTableModel.secondTypeIndex = indexPath.row;
            
                rightTableModel.isChecked = [self isCheckValid:rightTableModel isChecked:!rightTableModel.isChecked];
                
                // SFA-21335 SFA-立白-IOS-添加产品页面，产品列表下的产品一个一个都选择了的话，全选按钮也应该自动勾选
                NSInteger selectedProdsCount = 0;
                for (WSNewAddProdsWithSeriesModel *rightTableModel in dataArray) {
                    if (rightTableModel.isChecked) {
                        selectedProdsCount ++;
                    }
                }
                _currentSearchTableSelectedProdsCount = selectedProdsCount;
                
                NSString *eventId = nil;
                
                if (!_isShowCollectProdsFlag) {
                    WSDictBean *secondLevelProdGroupDict = [_secondLevelProdGroupDictsArray objectAtIndex:_lastSelectedLeft2LevelTableViewCellIndex];
                    
                    WSNewAddProdsWithSeriesLeftTableViewCell *cell = [_left2LevelBrandCellMArray objectAtIndex:_lastSelectedLeft2LevelTableViewCellIndex];
                    cell.titleLabel.text = [NSString stringWithFormat:@"%@%@", secondLevelProdGroupDict.name, [self getProdCountStringWithNewAddProdsWithSeriesModelArray:dataArray]];
                    
                    eventId = secondLevelProdGroupDict.name;
                }else{
                    [self checkAndSetCollectProdsAllCheckedStatus];
                }
                
                if (rightTableModel.isChecked) {
                    
                    if([eventId containsString:@"买赠"] || [eventId containsString:@"特价"]){
                        rightTableModel.prodBean.parentLevelName = eventId;
                    }
                }
            }
            
        }
        else if (tableView.tag == kSearchTableViewTag)
        {
            dataArray = _allSearchDataArray;
            
            //SFA-21341
            rightTableModel = (WSNewAddProdsWithSeriesModel *)[dataArray objectAtIndex:indexPath.row];
            rightTableModel.isChecked = [self isCheckValid:rightTableModel isChecked:!rightTableModel.isChecked];
            rightTableModel.secondTypeIndex = indexPath.row;
            
            [self resetCurrentSearchTableSelectedProdsCount];
        }

        [self synchronizeCollectedProdsAndOtherProdsCheckedStatusWithRightTableModel:rightTableModel andIsCollectedProdsNowShow:isCollectedProdsNowShow];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Id = %@", rightTableModel.prodBean.Id];
        NSArray *array = [_iSelectedProducts filteredArrayUsingPredicate:predicate];
        
        if (rightTableModel.isChecked) {
            if(array.count <= 0){
                [_iSelectedProducts addObject:rightTableModel.prodBean];
            }
            
            [self setGridBecomeFirstResponderWithTableView:tableView indexPath:indexPath];
            
        }else{
            if(array.count  > 0){
                [_iSelectedProducts removeObjectsInArray:array];
            }
        }
        
        
        if (tableView.tag == kRightTableViewTag) {
            if (!_isShowCollectProdsFlag) {
                [self setCheckButtonImageWithDataArray:dataArray];
            }
            
            [self refreshFirstLevelBadgeCount];  //刷新左边组的数量
            
        } else if (tableView.tag == kSearchTableViewTag) {
            [self setCheckButtonImageWithDataArray:dataArray];
        }
        
        
        [self refreshToolbarTotalLabelText];
        
        //SFA-21341 to do 暂时刷新全部 xcode8打包有问题  SFA-21351
//        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [tableView reloadData];
    }
    
    self.lastCheckedProdPosition = [NSString stringWithFormat:@"%ld@#%ld@#%ld", _lastSelectedLeft1LevelTableViewCellIndex, _lastSelectedLeft2LevelTableViewCellIndex, indexPath.row];
}
- (void)needUpdateCellHeight
{
    //只更新高度不更新内容
    if (_searchTableView.hidden) {
        [_rightTableView beginUpdates];
        [_rightTableView endUpdates];
    }else{
        [_searchTableView beginUpdates];
        [_searchTableView endUpdates];
    }
}

// YIHAIKERRY-3515 校验产品是否无效
- (BOOL)isCheckValid:(WSNewAddProdsWithSeriesModel *)model isChecked:(BOOL)isChecked {
    if (!isChecked) {
        return NO;
    }
    if ([model.prodBean.expirydate isEqualToString:@"0"]) {
        NSString *tips = [NSString stringWithFormat:@"%@ %@", model.prodBean.name, NSLocalizedString(@"select_product_fail_tip", nil)];
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tips tips:nil tapTarget:nil action:nil
                                 type:MBProgressHUDMessageTypeFailed];
        return NO;
    }
    return YES;
    
}

- (void)setCheckButtonImageWithDataArray:(NSArray *)dataArray {
    if (dataArray && dataArray.count > 0) {
        if (_currentSearchTableSelectedProdsCount == dataArray.count) {
            [_allCheckBtn setImage:[UIImage imageNamed:@"icn_check"] forState:UIControlStateNormal];
        }else
            [_allCheckBtn setImage:[UIImage imageNamed:@"icn_nocheck"] forState:UIControlStateNormal];
    }
}

// 单选模式下清除上次选中数据模型的选中状态，并更新品牌下选中产品的数量显示
- (void)refreshDataModelCheckedStatusAndBrandCheckedProdsCountWithNowCheckedIndex:(NSInteger)index
{
    if (self.newAddProdsSelectedType == WSNewAddProdsSelectedTypeSingle) {
        if (self.lastCheckedProdPosition.length > 0) {
            NSArray *cIndexArray = [self.lastCheckedProdPosition componentsSeparatedByString:@"@#"];
            if (cIndexArray.count == 3) {
                NSInteger lastCheckedProdLeft1LevelCellIndex = [[cIndexArray objectAtIndex:0] integerValue];
                NSInteger lastCheckedProdLeft2LevelCellIndex = [[cIndexArray objectAtIndex:1] integerValue];
                NSInteger lastCheckedProdRightCellIndex = [[cIndexArray objectAtIndex:2] integerValue];
                
                if (lastCheckedProdLeft1LevelCellIndex == _lastSelectedLeft1LevelTableViewCellIndex && lastCheckedProdLeft2LevelCellIndex == _lastSelectedLeft2LevelTableViewCellIndex && lastCheckedProdRightCellIndex == index) {
                    
                }else{
                    WSNewAddProdsWithSeriesModel *lastCheckedRightTableModel = [[[_allProdGroupCacheArray objectAtIndex:lastCheckedProdLeft1LevelCellIndex] objectAtIndex:lastCheckedProdLeft2LevelCellIndex] objectAtIndex:lastCheckedProdRightCellIndex];
                    lastCheckedRightTableModel.isChecked = NO;
                    
                    WSDictBean *secondLevelProdGroupDict = [_secondLevelProdGroupDictsArray objectAtIndex:lastCheckedProdLeft2LevelCellIndex];
                    
                    WSNewAddProdsWithSeriesLeftTableViewCell *cell = [_left2LevelBrandCellMArray objectAtIndex:lastCheckedProdLeft2LevelCellIndex];
                    cell.titleLabel.text = [NSString stringWithFormat:@"%@%@", secondLevelProdGroupDict.name, [self getProdCountStringWithNewAddProdsWithSeriesModelArray:[[_allProdGroupCacheArray objectAtIndex:lastCheckedProdLeft1LevelCellIndex] objectAtIndex:lastCheckedProdLeft2LevelCellIndex]]];
                    
                    [_iSelectedProducts removeObject:lastCheckedRightTableModel.prodBean];
                }
                
            }
            
        }
    }
}

- (void)refreshFirstLevelBadgeCount
{
    // 单选模式下不用更新BadgeCount
    if (self.newAddProdsSelectedType == WSNewAddProdsSelectedTypeSingle) {
        return ;
    }
    
    if (_lastSelectedLeft1LevelTableViewCellIndex >= 0) {
        WSNewAddProdsWithSeriesLeftTableViewCell *leftHeaderViewCell = (WSNewAddProdsWithSeriesLeftTableViewCell *)[_left1LevelBrandCellMArray objectAtIndex:_lastSelectedLeft1LevelTableViewCellIndex];
        [leftHeaderViewCell setBadgeLabelText:[self getCurrentFirstLevelCellBadgeCount]];
    }
}

- (NSString *)getCurrentFirstLevelCellBadgeCount
{
    NSArray *prodCacheMArray = [_allProdGroupCacheArray objectAtIndex:_lastSelectedLeft1LevelTableViewCellIndex];
    
    NSMutableArray *selectProdIdsArray = [NSMutableArray array];
    
    for (NSArray *prodsModelMArray in prodCacheMArray) {
        for (WSNewAddProdsWithSeriesModel *rightTableModel in prodsModelMArray) {
            if (rightTableModel.isChecked && ![selectProdIdsArray containsObject:rightTableModel.prodBean.Id] ) {
                [selectProdIdsArray addObject:rightTableModel.prodBean.Id];
            }
        }
    }
    
    return [NSString stringWithFormat:@"%ld", selectProdIdsArray.count];
}

- (void)resetCurrentSearchTableSelectedProdsCount
{
    if (_allSearchDataArray && _allSearchDataArray.count > 0) {
        NSInteger selectedProdsCount = 0;
        
        for (WSNewAddProdsWithSeriesModel *rightTableModel in _allSearchDataArray) {
            if (rightTableModel.isChecked) {
                selectedProdsCount ++;
            }
        }
        _currentSearchTableSelectedProdsCount = selectedProdsCount;
    }
}

- (NSArray *)searchUnitbyString:(NSString *)search{
    
    if (search == nil) {
        return nil;
    }
    
    //去除字符串两边的空格
    search = [search stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //只有空格 不作为
    if ([search isEqualToString:@""]) {
        return nil;
    }
    
    NSArray *searchArray = [search componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (searchArray != nil) {
        NSMutableString *format = [NSMutableString stringWithCapacity:4];
        int i = 0;
        NSMutableArray *formatArray = [[NSMutableArray alloc] initWithCapacity:4];
        for (NSString *item in searchArray) {
            if (![item isEqualToString:@""]) {
                
                if (i == 0) {
                    [format appendString:@"(SELF.prodBean.name contains[cd] %@)"];
                    [formatArray addObject:item];
                }else{
                    [format appendString:@" OR (SELF.prodBean.name contains[cd] %@)"];
                    [formatArray addObject:item];
                }
                //SFA-24984
                //备注：79码是门店编码69码是条形码
                if (!self.currentQstFuncs.opt.isCancelSearchCode) {
                    [format appendString:@" OR (SELF.prodBean.cod contains[cd] %@)"];
                    [formatArray addObject:item];
                }
                
                [format appendString:@" OR (SELF.prodBean.barcod contains[cd] %@)"];
                [formatArray addObject:item];
                
                i++;
            }
            
        }
        
        if ([formatArray count] > 0) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:format argumentArray:formatArray];
            
            NSArray * tempArray = _allProdsDataMArray;
            NSArray *proArray = [tempArray filteredArrayUsingPredicate:predicate];
            if ([proArray count] > 0) {
                // SFA-13289 产品按类型排序
                proArray = [self orderAllProdsByImgtypeWithRightTableModelArray:proArray];
                
                return proArray;
            }
        }
    }
    return nil;
}

- (void)refresh2LevelLeftTableWithProdsModelMArray:(NSArray *)prodsModelMArray
{
    
    
    WSDictBean *secondLevelProdGroupDict = [_secondLevelProdGroupDictsArray objectAtIndex:_lastSelectedLeft2LevelTableViewCellIndex];
    
    WSNewAddProdsWithSeriesLeftTableViewCell *leftViewCell = (WSNewAddProdsWithSeriesLeftTableViewCell *)[_left2LevelBrandCellMArray objectAtIndex:_lastSelectedLeft2LevelTableViewCellIndex];
    
    leftViewCell.titleLabel.text = [NSString stringWithFormat:@"%@%@", secondLevelProdGroupDict.name, [self getProdCountStringWithNewAddProdsWithSeriesModelArray:prodsModelMArray]];
}

- (NSArray *)orderAllProdsByImgtypeWithRightTableModelArray:(NSArray *)rightTableModelArray
{
    NSMutableArray *prodIdsMArray = [[NSMutableArray alloc] init];
    
    if (rightTableModelArray && rightTableModelArray.count > 0) {
        for (WSNewAddProdsWithSeriesModel *rightTableModel in rightTableModelArray) {
            if (rightTableModel.prodBean.Id != nil && rightTableModel.prodBean.Id.length > 0) {
                [prodIdsMArray addObject:rightTableModel.prodBean.Id];
            }
        }
    
    }
    
    WSBaseProductDBService *baseProdDBService = [[WSBaseProductDBService alloc] init];
    NSArray *orderedProdsArray = [baseProdDBService queryProductByIds:prodIdsMArray andIsOrderByImgtype:YES];
    
    NSMutableArray *rightTableModelTempMArray = [NSMutableArray arrayWithArray:rightTableModelArray];
    NSMutableArray *orderedRightTableModelTempMArray = [[NSMutableArray alloc] init];
    
    for (WSProdBean *prod in orderedProdsArray) {
        for (WSNewAddProdsWithSeriesModel *rightTableModel in rightTableModelTempMArray) {
            if (rightTableModel.prodBean.Id && rightTableModel.prodBean.Id.length > 0 ) {
                if ([rightTableModel.prodBean.Id isEqualToString:prod.Id]) {
                    [orderedRightTableModelTempMArray addObject:rightTableModel];
                    [rightTableModelTempMArray removeObject:rightTableModel];
                    break;
                }
            }
        }
    }
    
    return orderedRightTableModelTempMArray;
}

- (NSArray *)getFirstLevelProdGroupDicts
{
    if (self.service) {
        return _realTimeDataArray;
    }else{
        WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
        NSArray *firstLevelProdGroupDicts = [service queryDictsWithIDsString:_prodTopTreeNodeIds];
        return firstLevelProdGroupDicts;
    }
    return nil;

}

- (void)gridWidgetValueChangeWithWidget:(WSWidget *)widget andDataGridModel:(WSDataGridPartModel *)model
{
    WSNewAddProdsWithSeriesModel *rightTableModel = nil;
    if (_allSearchDataArray && _allSearchDataArray.count > 0) {
        rightTableModel = (WSNewAddProdsWithSeriesModel *)[_allSearchDataArray objectAtIndex:model.point_n];
    }
    
    if (!rightTableModel) {
        if (_lastSelectedLeft1LevelTableViewCellIndex >= 0 && _lastSelectedLeft2LevelTableViewCellIndex >= 0) {
            NSArray *prodCacheMArray = [_allProdGroupCacheArray objectAtIndex:_lastSelectedLeft1LevelTableViewCellIndex];
            
            NSArray *prodsModelMArray = [prodCacheMArray objectAtIndex:_lastSelectedLeft2LevelTableViewCellIndex];
            
            if (prodsModelMArray && prodsModelMArray.count > 0) {
                rightTableModel = (WSNewAddProdsWithSeriesModel *)[prodsModelMArray objectAtIndex:model.point_n];
            }
        }
    }

    if (rightTableModel) {
        WSProdBean *prodBean = rightTableModel.prodBean;
        
        WSFuncsBean_Param *colParam = [_needAddEditParamsArray objectAtIndex:model.point_y - 1];
        
        NSString *itemKeyStr = [NSString stringWithFormat:@"%@_%@", prodBean.Id, colParam.col];
        
        NSString * value = (NSString *)[widget getResultDirectly];
        
        //    NSLog(@"================ gridWidgetValueChangeWithWidget value = %@", value);
        
        [_prodKeyValueCacheDataDic setObject:[NSString stringNotNilWithValue:value] forKey:itemKeyStr];
        
//        NSLog(@"+++++++++++++++++++++++gridWidgetValueChange _prodKeyValueCacheDataDic = \n %@", _prodKeyValueCacheDataDic);
    }

}
#pragma mark - 右边cell中库存这一行的显示和隐藏的判断
-(void)getCellInvLabelIsShow {
    self.isShowInvLabel = NO;
    NSArray *paramArr =self.dataGridComponentDataSource.currentFunc.paramArray;
    for (int i = 0; i < paramArr.count; i ++) {
        WSFuncsBean_Param *param = paramArr[i];
        if ([param.name isEqualToString:@"库存"]&& [param.col isEqualToString:@"inv"]) {
            self.isShowInvLabel = YES;
            break;
        }
    }
}
//判断促销详情按钮 de 显示或隐藏。 yes显示 no隐藏
- (BOOL)isShowSalesButtonWithfirstLevelName :(NSString *)name {
    if (name.length > 0 &&[self.dataGridComponentDataSource.currentFunc.opt.remoteOrderProductInfo isEqualToString:name]) {
        return YES;
    }else {
        return NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 键盘显示监听方法
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    self.currentKeyboardHeight = keyboardRect.size.height;
}

#pragma mark - 键盘消失监听方法
- (void)keyboardWillHide:(NSNotification *)notification {
    self.currentKeyboardHeight = 0.0f;
}

@end
//===================================================================================================================================================================

#pragma mark - 新添加产品视图管理器 延展(工具)
@implementation WSNewAddProdsWithSeriesViewController (Tools)

#pragma mark - 初始化特殊全选字典 dictBean:组件 index:索引
- (void)initSpecialAllSelectDicWithDictBean:(WSDictBean *)dictBean index:(NSInteger)index
{
    if(_specialAllSelectDic == nil)
        _specialAllSelectDic = [[NSMutableDictionary alloc] init];
    
    if([dictBean.dtyp isEqualToString:WSProdsOrdertempletMark] ||
       [dictBean.dtyp isEqualToString:WSProdsLastOrderMark])
        [_specialAllSelectDic setObject:[[NSMutableArray alloc] init] forKey:[NSString stringWithFormat:@"%ld", index]];
}

#pragma mark - Handle处理特殊全选方法 left1Index:左边组索引 left2Index:组内类别索引
- (BOOL)handleSpecialAllSelectWithLeft1Index:(NSInteger)left1Index left2Index:(NSInteger)left2Index
{
    NSString *left1Key = [NSString stringWithFormat:@"%ld", left1Index];
    NSMutableArray *left1Array = [self.specialAllSelectDic objectForKey:left1Key];
    if(left1Array != nil)
    {
        NSString *left2Element = [NSString stringWithFormat:@"%ld", left2Index];
        if([left1Array containsObject:left2Element] == NO)
        {
            [left1Array addObject:left2Element];
            return YES;
        }
    }
    return NO;
}

#pragma mark - 获取二级产品数据方法 pId:父级id dtyp:类型
- (NSArray *)getSecondLevelProdGroupDictsWithParentId:(NSString *)pId dtyp:(NSString *)dtyp
{
    //SFA-25691
    NSString *appendprop = self.dataGridComponentDataSource.currentFunc.opt.appendprop;

    NSMutableArray *secondLevelProdGroupDictsArray = nil;
    if (self.service)
    {
        for (WSDictBean *bean in _realTimeDataArray)
        {
            if ([bean.Id isEqualToString:pId])
                secondLevelProdGroupDictsArray = bean.childArray;
        }
    }
    else
    {
        WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
        secondLevelProdGroupDictsArray = [NSMutableArray arrayWithArray:[service queryDictWithPid:pId]];
    }
    
    NSMutableIndexSet *noneProdsDictsIndexSet = [[NSMutableIndexSet alloc] init];
    for (int i = 0; i < [secondLevelProdGroupDictsArray count]; i ++)
    {
        WSDictBean *secondLevelProdGroupDict = [secondLevelProdGroupDictsArray objectAtIndex:i];
        
        WSBaseProductDBService *baseProductDBService = [[WSBaseProductDBService alloc] init];
        NSArray *secondLevelProdGroupProdsArray = nil;
        if (secondLevelProdGroupDict.childArray.count> 0)
            secondLevelProdGroupProdsArray = secondLevelProdGroupDict.childArray;
        else
        {
            //SFA-20430 2018-05-28 增加分销规则逻辑(需要门店ID与类型)
            NSString *sid = self.dataGridComponentDataSource.currentStore.Id;
            NSString *moreProdType = self.dataGridComponentDataSource.currentTableItem.opt.moreProdType;
            
            //SFA-21064 2018-06-22 增加模版筛选
            if([dtyp isEqualToString:WSProdsOrdertempletMark]) {
                secondLevelProdGroupProdsArray = [self queryGroupProductsWithGenid:secondLevelProdGroupDict.Id appendprop:appendprop
                                                                               sid:sid moreProdType:moreProdType];
            }
            else if([dtyp isEqualToString:@"promotion"] || [dtyp isEqualToString:WSProdsLastOrderMark]) {
                secondLevelProdGroupProdsArray = [baseProductDBService queryProductsWithGenid:secondLevelProdGroupDict.Id appendprop:appendprop
                                                                                          sid:sid moreProdType:moreProdType needStoreID:YES];
                
                if ([dtyp isEqualToString:WSProdsLastOrderMark]) {
                    [self setSpecialOriginalDataWithGenId:secondLevelProdGroupDict.Id serverData:secondLevelProdGroupProdsArray];
                }
            }
            else
            {
                //SFA-21545
                NSMutableArray *groupProdsArray = [[NSMutableArray alloc] init];
                for(WSProdBean* prodBean in self.iSourceProductsArray)
                {
                    if(prodBean.prodtrees == nil || prodBean.prodtrees.length <= 0)
                        continue;
                    
                    NSArray *prodtreesArray = [prodBean.prodtrees componentsSeparatedByString:@","];
                    if([prodtreesArray containsObject:secondLevelProdGroupDict.Id])
                        [groupProdsArray addObject:prodBean];
                }
                secondLevelProdGroupProdsArray = (NSArray *)groupProdsArray;
                
//                secondLevelProdGroupProdsArray = [baseProductDBService queryProductsWithProdtreeId:secondLevelProdGroupDict.Id appendprop:appendprop
//                                                                                               sid:sid moreProdType:moreProdType];
            }
        }
        
        NSArray *secondLevelProdGroupProdModelsArray = [self getNewAddProdsWithSeriesModelArrayWithProdBeanArray:secondLevelProdGroupProdsArray andIsCollected:NO andIsShowSaleButton:NO];
        
        if (secondLevelProdGroupProdModelsArray && secondLevelProdGroupProdModelsArray.count > 0)
            continue;

        [noneProdsDictsIndexSet addIndex:i];
    }
    
    [secondLevelProdGroupDictsArray removeObjectsAtIndexes:noneProdsDictsIndexSet];
    return [NSArray arrayWithArray:secondLevelProdGroupDictsArray];
}

#pragma mark - 查询组内产品数据方法 genid:唯一标示 appendprop:附加信息 sid:门店id moreProdType:更多产品类型
- (NSArray *)queryGroupProductsWithGenid:(NSString *)genid appendprop:(NSString *)appendprop sid:(NSString *)sid moreProdType:(NSString *)moreProdType
{
    WSBaseProductDBService *baseProductDBService = [[WSBaseProductDBService alloc] init];
    NSMutableDictionary *specialDataDic = [[NSMutableDictionary alloc] init];
    
    if(_specialOriginalDataDic == nil)
        _specialOriginalDataDic = [[NSMutableDictionary alloc] init];
    
    NSArray *fptObjects = [[WSFptTable sharedTable] queryAcvtDataGridPannelProductWithGenId:genid];
    if(fptObjects.count > 0){
        
        NSMutableArray *newProdIds = [[NSMutableArray alloc] init];
        for(WSProductObject *productObject in fptObjects){
            if([self.iSourceProductsAllIdsArray containsObject:productObject.prod_id]){
                [newProdIds addObject:productObject.prod_id];
                
                for(WSFuncsBean_Param *param in self.needAddEditParamsArray){
                    NSString *itemKeyStr = [NSString stringWithFormat:@"%@_%@", productObject.prod_id, param.col];
                    NSString *itemValue = [productObject valueForKey:param.col];
                    if ([itemValue length] > 0) {
                        [specialDataDic setObject:itemValue forKey:itemKeyStr];
                    }
                }
            }
        }
        
        NSMutableArray *newProd = [[NSMutableArray alloc] init];
        if(newProdIds.count > 0){
            NSArray *array = [baseProductDBService queryProductByIds:newProdIds appendprop:appendprop sid:sid moreProdType:moreProdType];
            [newProd addObjectsFromArray:array];
        }
        
        [self.specialOriginalDataDic setObject:specialDataDic forKey:genid];
        return newProd;
    }
    else{
        NSArray *serverData = [baseProductDBService queryProductsWithGenid:genid appendprop:appendprop sid:sid moreProdType:moreProdType];
        NSMutableArray *newProd = [[NSMutableArray alloc] init];
        
        for(WSProdBean *prodBean in serverData){
            if([self.iSourceProductsAllIdsArray containsObject:prodBean.Id]){
                [newProd addObject:prodBean];
                for(WSFuncsBean_Param *param in self.needAddEditParamsArray){
                    NSString *itemKeyStr = [NSString stringWithFormat:@"%@_%@", prodBean.Id, param.col];
                    NSString *itemValue = [prodBean valueForKey:param.col];
                    if ([itemValue length] > 0) {
                        [specialDataDic setObject:itemValue forKey:itemKeyStr];
                    }
                }
            }
        }
        
        [self.specialOriginalDataDic setObject:specialDataDic forKey:genid];
        return newProd;
    }
}


- (void)setSpecialOriginalDataWithGenId:(NSString *)genid serverData:(NSArray *)serverData {
    if(_specialOriginalDataDic == nil)
        _specialOriginalDataDic = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *specialDataDic = [[NSMutableDictionary alloc] init];
    
    for(WSProdBean *prodBean in serverData){
        for(WSFuncsBean_Param *param in self.needAddEditParamsArray){
            NSString *itemKeyStr = [NSString stringWithFormat:@"%@_%@", prodBean.Id, param.col];
            NSString *itemValue = [prodBean valueForKey:param.col];
            //SFA-25615
            if (itemValue.length > 0) {
                [specialDataDic setObject:itemValue forKey:itemKeyStr];
            }
        }
    }
    
    [self.specialOriginalDataDic setObject:specialDataDic forKey:genid];
}

#pragma mark - 搜索完毕后的页面数据方法
- (void)searchCompleteHandleViewData
{
    //遍历产品组 让模型的选中状态一致
    for (int i = 0; i < _allProdGroupCacheArray.count; ++i) {           //第一层((全部产品组)
        NSArray *oneArray = [_allProdGroupCacheArray objectAtIndex:i];
        for (int j = 0; j < oneArray.count; ++j) {                      //第二层(全部产品组第一层)
            NSArray *twoArray = [oneArray objectAtIndex:j];
            for (int k = 0; k < twoArray.count; ++k) {                  //第三层(每层的产品)
                WSNewAddProdsWithSeriesModel *model = [twoArray objectAtIndex:k];
                model.isChecked = NO;
                for (int l = 0; l < _iSelectedProducts.count; ++l) {   //第四层(选中的产品)
                    WSProdBean *prodBean = [_iSelectedProducts objectAtIndex:l];
                    if ([model.prodBean.Id isEqualToString:prodBean.Id]) {
                        model.isChecked = YES;
                    }
                }
            }
        }
    }
    
    //遍历品牌(从新计算左边抽屉的右上角数量以及每个条目的数量)
    [self refreshLeftUI];
    
    [_leftTableView reloadData];
    [_rightTableView reloadData];  //这个不能去掉，不然可能闪退
}

//刷新左边数据   //遍历品牌(从新计算左边抽屉的右上角数量以及每个条目的数量)
- (void)refreshLeftUI {
    if (self.newAddProdsSelectedType != WSNewAddProdsSelectedTypeSingle) {
        
        for (int i = 0; i < _left1LevelBrandCellMArray.count; ++i) {
            WSNewAddProdsWithSeriesLeftTableViewCell *leftHeaderViewCell = [_left1LevelBrandCellMArray objectAtIndex:i];
            NSArray *prodCacheMArray = [_allProdGroupCacheArray objectAtIndex:i];

            NSMutableArray *selectProdIdsArray = [NSMutableArray array];
        
            for (int j = 0; j <prodCacheMArray.count; ++j) {
                NSArray *prodsModelMArray = [prodCacheMArray objectAtIndex:j];
                
                NSInteger titleCount = 0;
                for (int k = 0; k < prodsModelMArray.count; ++k) {
                    WSNewAddProdsWithSeriesModel *rightTableModel = [prodsModelMArray objectAtIndex:k];
                    if (rightTableModel.isChecked) {
                        titleCount++;
                        
                        if (![selectProdIdsArray containsObject:rightTableModel.prodBean.Id]) {
                            [selectProdIdsArray addObject:rightTableModel.prodBean.Id];
                        }
                        
                    }
                }
                
                if (!_isShowCollectProdsFlag && _lastSelectedLeft1LevelTableViewCellIndex == i) {
                    if (_left2LevelBrandCellMArray.count > j && _secondLevelProdGroupDictsArray.count > j) {
                        WSDictBean *dictBean = [_secondLevelProdGroupDictsArray objectAtIndex:j];
                        WSNewAddProdsWithSeriesLeftTableViewCell *cell = [_left2LevelBrandCellMArray objectAtIndex:j];
                        
                        NSString *count = [NSString stringWithFormat:@"(%ld/%ld)", titleCount, prodsModelMArray.count];
                        cell.titleLabel.text = [NSString stringWithFormat:@"%@%@", dictBean.name, count];
                    }
                }
            }
            leftHeaderViewCell.badgeLabelText = [NSString stringWithFormat:@"%ld", selectProdIdsArray.count];
        }
    }
    
}

#pragma mark - 同步rightTable的选中状态到allProdsDataMArray中。 righttable的选中状态要同步到searchtable中去
- (void)updateRightStateToSearchTable {
    
    //遍历搜索的产品组 让模型的选中状态一致
    for (NSInteger i = 0; i < _allProdsDataMArray.count; i ++) {
        WSNewAddProdsWithSeriesModel *model = [_allProdsDataMArray objectAtIndex:i];
        model.isChecked = NO;
        for (int l = 0; l < _iSelectedProducts.count; ++l) {
            WSProdBean *prodBean = [_iSelectedProducts objectAtIndex:l];
            if ([model.prodBean.Id isEqualToString:prodBean.Id]) {
                model.isChecked = YES;
            }
        }
        
    }
}

#pragma mark - 初始化收藏产品数据模型方法
- (void)initCollectedProdsModelData
{
    NSMutableArray *collectedProdMArray = [[NSMutableArray alloc] init];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *collectedProdIdsString = [userDefaults objectForKey:ALL_COLLECTED_PRODIDS];
    
    if (collectedProdIdsString && collectedProdIdsString.length > 0) {
        for (WSProdBean *prodBean in _iSourceProductsArray) {
            if (([collectedProdIdsString rangeOfString:[NSString stringWithFormat:@",%@,", prodBean.Id]].location) != NSNotFound) {
                [collectedProdMArray addObject:prodBean];
            }
        }
    }
    
    NSArray *collectedProdsModelArray = [self getNewAddProdsWithSeriesModelArrayWithProdBeanArray:collectedProdMArray andIsCollected:YES andIsShowSaleButton:NO];
    _collectedProdsModelMArray = [NSMutableArray arrayWithArray:collectedProdsModelArray];
}

#pragma mark - 搜索文本变换检查方法 text:文本 isBegin:是否开始编辑
- (void)searchBarTextChangeCheckupWithText:(NSString *)text isBegin:(BOOL)isBegin {
    
    if (isBegin) {
        if (!text || text.length <= 0) {
            [self showHighFrequencySearchResultView];
        } else {
            [self hideHighFrequencySearchResultView];
        }
    } else {
        if (text && [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0) {
            [self.highFrequencySearchDataTool updateHighFrequencySearchDataWithText:text];
        }
        [self hideHighFrequencySearchResultView];
    }
}

#pragma mark - 显示高频搜索结果视图方法
- (void)showHighFrequencySearchResultView {
    
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *searchResultArray = [weakSelf.highFrequencySearchDataTool queryHighFrequencySearchDataWithMaxCount:kHighFrequencySearchMaxCount];
        if (searchResultArray.count > 0) {
            
            NSMutableArray *titleArray = [[NSMutableArray alloc] initWithArray:[searchResultArray valueForKey:@"item1"]];
            CGFloat x = MAIN_PADDING;
            CGFloat y = CGRectGetMaxY(weakSelf.headerSearchView.frame);
            CGFloat w = (CGRectGetMinX(weakSelf.allCheckBtn.frame) - x - MAIN_PADDING);
            CGFloat h = CGRectGetHeight(weakSelf.view.frame) - y - weakSelf.currentKeyboardHeight - MAIN_PADDING;
            CGFloat elementHeight = searchResultArray.count *  weakSelf.highFrequencySearchResultView.elementHeight;
            h = (elementHeight <= h) ? elementHeight : h;
            
            weakSelf.highFrequencySearchResultView.frame = CGRectMake(x, y, w, h);
            weakSelf.highFrequencySearchResultView.hidden = NO;
            [weakSelf.highFrequencySearchResultView updateViewWithDataArray:titleArray];
        }
    });
}

#pragma mark - 隐藏高频搜索结果视图方法
- (void)hideHighFrequencySearchResultView {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.highFrequencySearchResultView.frame = CGRectZero;
        self.highFrequencySearchResultView.hidden = YES;
    });
}

@end
//===================================================================================================================================================================

#pragma mark - 新添加产品视图管理器 延展(实现WSHighFrequencySearchResultViewDelegate代理协议)
@implementation WSNewAddProdsWithSeriesViewController (highFrequencySearchResultViewDelegate)

#pragma mark - 删除点击代理
- (void)deleteClickAtText:(NSString *)text {
    
    if (text && text.length > 0) {
        [self.highFrequencySearchDataTool deleteHighFrequencySearchDataWithText:text];
        
        NSInteger count = [self.highFrequencySearchResultView getSearchElementCount];
        CGRect rect = self.highFrequencySearchResultView.frame;
        rect.size.height = count * self.highFrequencySearchResultView.elementHeight;
        self.highFrequencySearchResultView.frame = rect;
    }
}

#pragma mark - 选择点击代理
- (void)selectClickAtText:(NSString *)text {
    
    if (text && text.length > 0) {
        self.ownSearchBar.searchBar.text = text;
        [self searchBarSearchButtonClicked:self.ownSearchBar.searchBar];

        UIButton *cancelBtn = [self.ownSearchBar.searchBar valueForKey:@"cancelButton"];
        cancelBtn.enabled = YES;
    }
}

@end
//===================================================================================================================================================================

#pragma mark - 新添加产品视图管理器 延展(实现UISearchBarDelegate代理协议)
@implementation WSNewAddProdsWithSeriesViewController (searchBarDelegate)

#pragma mark - 结束编辑
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    
    //SFA-24180
    NSString *text = (searchBar.text.length > 0) ? searchBar.text : self.searchBarCancelText;
    [self searchBarTextChangeCheckupWithText:text isBegin:NO];
    self.searchBarCancelText = @"";
    
    return YES;
}

#pragma mark - 开始编辑
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    [self searchBarTextChangeCheckupWithText:searchBar.text isBegin:YES]; //SFA-24180
    
    [searchBar setShowsCancelButton:YES animated:YES];
    _searchTableView.hidden = NO;
    
    [self updateRightStateToSearchTable]; //YIHAIKERRY-4185
    
    if (IOS7_OR_LATER){
        for(id cc in [[[searchBar subviews] objectAtIndex:0] subviews]){
            if([cc isKindOfClass:[UIButton class]])
            {
                UIButton *btn = (UIButton *)cc;
                NSString *CancelString = NSLocalizedString(@"cancel_label",nil);
                [btn setTitle:CancelString  forState:UIControlStateNormal];
                if(INTERFACE_IS_PAD){
                    [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                    [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
                }
                break;
            }
        }
    } else {
        for(id cc in [searchBar subviews]) {
            if([cc isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton *)cc;
                NSString *CancelString = NSLocalizedString(@"cancel_label",nil);
                [btn setTitle:CancelString  forState:UIControlStateNormal];
                if(INTERFACE_IS_PAD) {
                    [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                    [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
                }
                break;
            }
        }
    }
    
    [_searchTableView reloadData];
}

#pragma mark - 取消响应
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    self.searchBarCancelText = searchBar.text;//SFA-24180
    searchBar.text = @"";
    [self.emptySerchView removeFromSuperview];// YIHAIKERRY-3127
    
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    [_allCheckBtn setImage:[UIImage imageNamed:@"icn_nocheck"] forState:UIControlStateNormal];
    [self searchCompleteHandleViewData]; //YIHAIKERRY-3886
    _searchTableView.hidden = YES;
    
    // SFA-26799 业务员下单过程中出现闪退现象(点击取消需要清除搜索出的数据，不然回正常页面再操作就会引起崩溃)
     [_allSearchDataArray removeAllObjects];
}

#pragma mark - 文本变化
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    [self searchBarTextChangeCheckupWithText:searchBar.text isBegin:YES]; //SFA-24180
    
    NSString *searchString = [self getConversionSearchString:searchBar.text];
    _allSearchDataArray = [NSMutableArray arrayWithArray:[self searchUnitbyString:searchString.length
                                                          > 0 ? searchString:searchBar.text]];
    [self resetCurrentSearchTableSelectedProdsCount];
    
    if (_allSearchDataArray.count > 0 && _currentSearchTableSelectedProdsCount == _allSearchDataArray.count) {
        [_allCheckBtn setImage:[UIImage imageNamed:@"icn_check"] forState:UIControlStateNormal];
        _isAllChecked = YES;
    }else {
        [_allCheckBtn setImage:[UIImage imageNamed:@"icn_nocheck"] forState:UIControlStateNormal];
        _isAllChecked = NO;
    }
    
    // YIHAIKERRY-3127
    [self.emptySerchView removeFromSuperview];
    if (self.allSearchDataArray.count < 1 && searchBar.text.length > 0) {
        [self addNOSeacrchResultView];
    }
    [_searchTableView reloadData];
}

#pragma mark - 搜索响应
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    
    NSString *searchString = [self getConversionSearchString:searchBar.text];
    _allSearchDataArray = [NSMutableArray arrayWithArray:[self searchUnitbyString:searchString.length
                                                          > 0 ? searchString:searchBar.text]];
    [self resetCurrentSearchTableSelectedProdsCount];
    
    if (_allSearchDataArray.count > 0 && _currentSearchTableSelectedProdsCount == _allSearchDataArray.count) {
        [_allCheckBtn setImage:[UIImage imageNamed:@"icn_check"] forState:UIControlStateNormal];
    } else {
        [_allCheckBtn setImage:[UIImage imageNamed:@"icn_nocheck"] forState:UIControlStateNormal];
    }
    
    // YIHAIKERRY-3127
    [self.emptySerchView removeFromSuperview];
    if (self.allSearchDataArray.count < 1 && searchBar.text.length >0) {
        [self addNOSeacrchResultView];
    }
    
    [_searchTableView reloadData];
}

- (NSString *)getConversionSearchString:(NSString *)inputString{
    // SFA-24175 订单添加产品搜索—模糊搜索功能需求
    NSString *needWeightConversion = [[NSUserDefaults standardUserDefaults] objectForKey:NEED_WEIGHT_CONVERSION];
    if ([needWeightConversion isEqualToString:@"1"]) {
        WSRegularTool *regTool = [[WSRegularTool alloc] init];
        return [regTool getFactorArrayWithInputString:inputString];
    }
    return @"";
}

#pragma mark - 初次加载数据方法
- (void)firstLoadData {
    
    [self initDataSource];
    [self setupSubviews];
    [self showCollectedProducts:nil];
    [self getCellInvLabelIsShow];
    
    if(_dataGridComponentDataSource.currentFunc.opt.prodtree_checked_name && _dataGridComponentDataSource.currentFunc.opt.prodtree_checked_name.length>0) {
        for (WSNewAddProdsWithSeriesLeftTableViewCell *cell in _left1LevelBrandCellMArray) {
            if ([cell.titleLabel.text isEqualToString:_dataGridComponentDataSource.currentFunc.opt.prodtree_checked_name]) {
                [self didSelectedCell:cell];
                if (_left2LevelBrandCellMArray.count>0) {
                    [self didSelectedCell:(WSNewAddProdsWithSeriesLeftTableViewCell*)[_left2LevelBrandCellMArray firstObject]];
                }
            }
        }
    }
}

@end
//===================================================================================================================================================================

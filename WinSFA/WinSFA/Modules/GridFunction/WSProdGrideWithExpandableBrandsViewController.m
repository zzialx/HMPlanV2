//
//  WSProdGrideWithExpandableBrandsViewController.m
//  WinSFA
//
//  Created by HZH on 2017/7/16.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSProdGrideWithExpandableBrandsViewController.h"
#import "WSDataGridComponentView.h"
#import "WSRequestHelper.h"
#import "WSStoreInfoViewController.h"
#import "WSImagePathTable.h"
#import "WSInoutStoreTable.h"
#import "PureLayout.h"
#import "WSFuncsBeanFilterLogicService.h"
#import "NSString+ServerUrl.h"
#import "WSProdGrideWithExpandableBrandsRightTableViewCell.h"
#import "WSProdGrideWithExpandableBrandsLeftTableViewCell.h"
#import "WSDataGridRightTableModel.h"
#import "WSBaseDictsDBService.h"
#import "WSBaseProductDBService.h"
#import "WSWidget.h"
#import "WSJSONBuilder.h"
#import "WSFptTable.h"
#import "WSMappingObject.h"
#import "YYModel.h"
#import "WSHOrderRelationView.h"
#import "WSBaseStoreProdDisTable.h"
#import "WSImageBrowserView.h"
#import "WSHOrderRelationViewController.h"
#import "WSNumberTextFiledPanel.h"

#define kTemplateButtonTag 5888

#define kHeaderImageViewLeftSpace 15
#define kHeaderImageViewCodeSpace 10

#define kHeaderImageViewWH  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 75 : 88)
#define kHeaderIconPadding  4

#define kHeaderViewMinHeight (_isInThinMode ? (INTERFACE_IS_PHONE ? 90 : 147) : kHeaderImageViewWH + 30)
#define STORE_NAV_BUTTON_WIDHT 70
#define STORE_NAV_BUTTON_MIN_WIDTH 36
#define STORE_NAV_BUTTON_HEGIHT 18
#define NAV_BUTTON_RIGTHT_SPACE  20

#define NAV_BUTTON_TOP_SPACE  22

#define kView_Height 15

#define kTopTipKey      @"TopTip"

#define kDetaiTextFont  [UIFont systemFontOfSize:13]

#define kScaleOfLeftTableViewToScreenWidth  0.30

#define kLeftTableViewTag 5901
#define kRightTableViewTag 5902

#define kToolBarView_Height 50

#define kLeftTableCellTextSize 14.0

#define kLeftTableCellHeight 40.0


@interface WSProdGrideWithExpandableBrandsViewController () <UITableViewDelegate, UITableViewDataSource>
{
    WSFuncsBean *_showTemplateFuncsBean;
    UIView *_headerView;

    BOOL _isInThinMode;
    UITableView *_leftTableView;
    UITableView *_rightTableView;
    NSMutableArray *_leftTableDataSource;
    NSMutableArray *_rightTableDataSource;
    UILabel *_totalCountLabel;
    UIScrollView *_bgScrollView;
    CGFloat _bgScrollViewContentHeight;
    CGFloat _leftTableViewContentHeight;
    CGFloat _rightTableViewContentHeight;
    NSString *_totalCountStr;
    WSHOrderRelationView *_orderRelationView;
    UIView *_prodGridView;
    NSInteger _lastSelectedLeftTableViewCellIndex;
    BOOL _isFirstLoad;
    NSMutableArray *keyArray;//需要计算总价的item的key集合
    NSMutableArray *valueArray;//需要计算总价的item的value集合
}

@property (nonatomic, strong) NSArray *funcBeanArray;
@property (nonatomic, strong) NSMutableDictionary *prodKeyValueCacheDataDic;
@property (nonatomic, assign) BOOL insertFptIsSucceed;
@property (nonatomic, strong) WSFptObject *fptObject;
@property (nonatomic, strong) NSMutableArray *leftTableViewCellArray;


@end

@implementation WSProdGrideWithExpandableBrandsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.currentFuncs.name;
//    WSDataGridComponentView *gridView = [[WSDataGridComponentView alloc] initWithFrame:self.view.bounds];
//    
//    [self.view addSubview:gridView];
    keyArray = [NSMutableArray array];
    valueArray = [NSMutableArray array];
    _prodKeyValueCacheDataDic = [[NSMutableDictionary alloc] init];
    _totalCountStr = @"0";
    _isFirstLoad = YES;
    _isInThinMode = NO;
    NSString *isUsePhotos = [[NSUserDefaults standardUserDefaults]objectForKey:USE_STORE_PHOTOS];
    if ((INTERFACE_IS_PAD && self.currentFuncs.wfcol > 0 && self.currentFuncs.wfcol < 300) || [isUsePhotos isEqualToString:@"0"]) {
        _isInThinMode = YES;
    }
    self.funcBeanArray = [WSFuncsBeanFilterLogicService filterFuncsBean:self.currentFuncs.funcsArray withStore:self.currentStore bizDate:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];

    for (WSFuncsBean *funcsBean in self.funcBeanArray) {
        if ([funcsBean.fv isEqualToString:UNILEVERORDERTEMPLATE_FV]) {
            _showTemplateFuncsBean = funcsBean;
            break;
        }
    }
    
    [self initDataSource];
    [self setupSubviews];
    
}

- (void)initDataSource
{
    
    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
    NSArray *filterProdTypeArray = [service queryDictsWithIDsString:self.currentFuncs.filter];
    
    _leftTableDataSource = [[NSMutableArray alloc] initWithArray:filterProdTypeArray];
    _leftTableViewCellArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < _leftTableDataSource.count; i ++) {
        WSProdGrideWithExpandableBrandsLeftTableViewCell *cell = [[WSProdGrideWithExpandableBrandsLeftTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [cell setIsChecked:NO];
        [_leftTableViewCellArray addObject:cell];
    }
    
//    _leftTableDataSource = [[NSMutableArray alloc] initWithObjects:@"调味油",@"面粉",@"植物油",@"食用油",@"大米",@"米粉",@"小米",@"黄豆", nil];
//    NSMutableArray *brandArray = [[NSMutableArray alloc] initWithObjects:@"元宝",@"金龙鱼",@"YGY", nil];
    
    _rightTableDataSource = [[NSMutableArray alloc] init];
    
//    for (NSString *typeStr in brandArray) {
//        WSDataGridRightTableModel *dataGridRightTableModel = [[WSDataGridRightTableModel alloc] init];
//        NSString *typeAndBrandStr = [NSString stringWithFormat:@"%@-%@", typeStr, [_leftTableDataSource firstObject]];
//        
//        dataGridRightTableModel.title = typeAndBrandStr;
//        dataGridRightTableModel.isExPanded = NO;
//        
//        [_rightTableDataSource addObject:dataGridRightTableModel];
//    }
    
//    _leftTableDataSource = [NSMutableArray arrayWithArray:[self getFilterHasProdsBrandTypeWithTypeArray:_leftTableDataSource]];
    
    [self initProdCacheDic];
    [self calculateTotalCountWhenFirstShow];
    
    if (!_leftTableDataSource || _leftTableDataSource.count == 0) {
        return;
    }
    
    WSDictBean *typeDictBean = (WSDictBean *)[_leftTableDataSource objectAtIndex:0];
    
    NSArray *brandArray = [service queryDictWithPid:typeDictBean.Id];
    
    //        NSMutableArray *brandArray = [[NSMutableArray alloc] initWithObjects:@"元宝",@"金龙鱼",@"YGY", nil];
    
    for (WSDictBean *dictBean in brandArray) {
        WSDataGridRightTableModel *dataGridRightTableModel = [[WSDataGridRightTableModel alloc] init];
        NSString *typeAndBrandStr = [NSString stringWithFormat:@"%@", dictBean.name];
        
        dataGridRightTableModel.topTypeIndex = 0;
        dataGridRightTableModel.firstColWidth = self.currentFuncs.wfcol;
        dataGridRightTableModel.title = typeAndBrandStr;
        dataGridRightTableModel.isExPanded = NO;
        dataGridRightTableModel.prodTypeDic = dictBean;
        
        WSBaseProductDBService *baseProductDBSerice = [[WSBaseProductDBService alloc] init];
        NSArray *prodsArray = [baseProductDBSerice queryBrandSortProductsWithStoreId:self.currentStore.drId brand:dataGridRightTableModel.prodTypeDic.Id params:nil appendprop:self.currentFuncs.opt.appendprop];
        
        // 获取服务器相对应品类的产品回显值
//        [self setProdCacheDicWithProdDisDataBaseDatasFromServerWithProdsArray:prodsArray];
        
        dataGridRightTableModel.gridColParamArray = self.currentFuncs.paramArray;
        dataGridRightTableModel.prodsArray = prodsArray;
        dataGridRightTableModel.prodKeyValueCacheDataDic = _prodKeyValueCacheDataDic;
        
        if (prodsArray && prodsArray.count > 0) {
            [_rightTableDataSource addObject:dataGridRightTableModel];
        }
        
    }
    
}

- (NSArray *)getFilterHasProdsBrandTypeWithTypeArray:(NSArray *)typeArray
{
    NSMutableArray *hasProdsBrandMTypeArray = [[NSMutableArray alloc] init];
    
    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
    
    for (WSDictBean *typeDictBean in typeArray) {
        
        NSArray *brandArray = [service queryDictWithPid:typeDictBean.Id];
        
        if (brandArray && brandArray.count > 0) {
            [hasProdsBrandMTypeArray addObject:typeDictBean];
        }
    }

    return hasProdsBrandMTypeArray;
}

- (void)initProdCacheDic
{
    // 服务器回显部分
    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];

    for (WSDictBean *typeDictBean in _leftTableDataSource) {
        
        NSArray *brandArray = [service queryDictWithPid:typeDictBean.Id];
        
        for (WSDictBean *dictBean in brandArray) {
            
            WSBaseProductDBService *baseProductDBSerice = [[WSBaseProductDBService alloc] init];
            NSArray *prodsArray = [baseProductDBSerice queryBrandSortProductsWithStoreId:self.currentStore.drId brand:dictBean.Id params:nil appendprop:self.currentFuncs.opt.appendprop];
            
            // 获取服务器相对应品类的产品回显值
            [self setProdCacheDicWithProdDisDataBaseDatasFromServerWithProdsArray:prodsArray];
            
        }

    }
    
    // YIHAIKERRY-1428 E 每次上传均不覆盖
    if (![self.currentFuncs.dateTyp isEqualToString:@"E"])
    {
        // 本地回显部分
        NSArray *fptProdsMArray = [self getProdDataBaseDatas];
        
        for (WSProductObject *prodObject in fptProdsMArray) {
            
            for (WSFuncsBean_Param *param in self.currentFuncs.paramArray) {
                NSString *valueStr =  [prodObject performSelector:NSSelectorFromString(param.col)];
                
                if (valueStr && valueStr.length > 0 && ![valueStr isEqualToString:@"null"]) {
                    NSString *key = [NSString stringWithFormat:@"%@_%@", prodObject.prod_id, param.col];
                    
                    [_prodKeyValueCacheDataDic setObject:valueStr forKey:key];
                }
                
                //            NSLog(@"++++++++WSProductObject valueStr = %@", valueStr);
            }
        }
        
        NSLog(@"_prodKeyValueCacheDataDic = %@", _prodKeyValueCacheDataDic);
    }

}

- (NSArray *)getProdDataBaseDatas {
    NSArray *l_array = [[NSArray alloc]init];
    
    
    if (self.currentStore.Id) {
        NSString * srid;
        if (self.currentStore
            && self.currentStore.srid
            && [self.currentStore.srid length] > 0) {
            
            srid = self.currentStore.srid;
        }
        

        l_array = [[WSFptTable sharedTable] queryProductWithStoreId:self.currentStore.Id fc:self.currentFuncs.fc title:nil andSrid:srid];
        
    }
    
    return l_array;
}

- (void)setProdCacheDicWithProdDisDataBaseDatasFromServerWithProdsArray:(NSArray *)prodsArray {
    
    for (WSProdBean *prod in prodsArray) {
        for (WSFuncsBean_Param *param in self.currentFuncs.paramArray) {
            if (param.redis.length > 0 && ![param.redis isEqualToString:@"0"]) {
//                NSString *valueStr =  [prodObject performSelector:NSSelectorFromString(param.col)];
                NSString *valueStr = [self getRedisFromServerWithParam:param data:prod];
                
                if (valueStr && valueStr.length > 0 && ![valueStr isEqualToString:@"null"]) {
                    NSString *key = [NSString stringWithFormat:@"%@_%@", prod.Id, param.col];
                    
                    [_prodKeyValueCacheDataDic setObject:valueStr forKey:key];
                }

            }
        }
    }

}

- (NSString *)getRedisFromServerWithParam:(WSFuncsBean_Param *)param data:(id)data {
    
    // 需要回显的值
    __block NSString *redis = nil;
    NSString *currenProdId = nil;
    if ([data isKindOfClass:[WSProdBean class]]) {
        currenProdId = [(WSProdBean *)data Id];
    }
    
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
    
    WSBaseStoreProdDisTable *baseStoreProdDisTable = [WSBaseStoreProdDisTable sharedTable];
    NSArray *names = @[@"store_id",@"prod_id" ];
    NSArray *values = @[[NSString stringNotNilWithValue:self.currentStore.Id],[NSString stringNotNilWithValue:currenProdId]];
//    if (fcIndex != -1) {
//        names = @[@"store_id",@"prod_id",@"funccode"];
//        values= @[[NSString stringNotNilWithValue:self.currentStore.Id],[NSString stringNotNilWithValue:currenProdId],[NSString stringNotNilWithValue:self.currentFuncs.fc]];
//    }
    NSArray *prods = [baseStoreProdDisTable queryWithNames:names ArgumentsValue:values];
    WSBaseStoreProdDisObject *baseStoreProdDisObject = [prods firstObject];
    /*要判断这个object是否有param.col那个字段然后取值*/
    NSString *colName = ([param.redis length] > 0 && ![param.redis isEqualToString:@"1"] && ![param.redis isEqualToString:@"0"])? param.redis : param.col;
    BOOL hasColProperty = [self getVariableWithClass:[baseStoreProdDisObject class] varName:colName];
    if (hasColProperty) {
        redis = [baseStoreProdDisObject valueForKey:colName];
    }else {
        NSLog(@"baseStoreProdDisObject is no property %@",colName);
    }
    
    
    return redis;
}


- (void)setupSubviews
{
    
//    _bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - kToolBarView_Height - 44)];
//    [_bgScrollView addSubview:[self getTableHeaderView]];
    [self.view addSubview:[self getTableHeaderView]];
//    _bgScrollView.delegate = self;
    
//    _leftTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _headerView.frame.origin.y + _headerView.frame.size.height, SCREEN_WIDTH * kScaleOfLeftTableViewToScreenWidth, _bgScrollView.frame.size.height - _headerView.frame.size.height) style:UITableViewStylePlain];
    
    _prodGridView = [[UIView alloc] initWithFrame:CGRectMake(0, _headerView.frame.origin.y + _headerView.frame.size.height, SCREEN_WIDTH, self.view.frame.size.height - _headerView.frame.size.height - kToolBarView_Height)];
    
//    _leftTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH * kScaleOfLeftTableViewToScreenWidth, _prodGridView.frame.size.height) style:UITableViewStyleGrouped];
    _leftTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 80.0, _prodGridView.frame.size.height) style:UITableViewStyleGrouped];
    _leftTableView.showsVerticalScrollIndicator = NO;
    
//    _leftTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//    _leftTableView.contentSize = CGSizeMake(_leftTableView.frame.size.width, 0);
    _leftTableViewContentHeight = _leftTableView.contentSize.height;
//    _leftTableView.scrollEnabled = NO;
    _leftTableView.tag = kLeftTableViewTag;
    _leftTableView.delegate = self;
    _leftTableView.dataSource = self;
    
    [_prodGridView addSubview:_leftTableView];
    
//    _rightTableView = [[UITableView alloc] initWithFrame:CGRectMake(_leftTableView.frame.size.width, _headerView.frame.origin.y + _headerView.frame.size.height, SCREEN_WIDTH - _leftTableView.frame.size.width, _bgScrollView.frame.size.height - _headerView.frame.size.height) style:UITableViewStyleGrouped];
    
    _rightTableView = [[UITableView alloc] initWithFrame:CGRectMake(_leftTableView.frame.size.width, 0, SCREEN_WIDTH - _leftTableView.frame.size.width, _prodGridView.frame.size.height) style:UITableViewStyleGrouped];

    _rightTableView.backgroundColor = [UIColor clearColor];
//    _rightTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    _rightTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//    _rightTableView.contentSize = CGSizeMake(_rightTableView.frame.size.width, 44 * 10 * 3 + 80 * 3);
    _rightTableViewContentHeight = _rightTableView.contentSize.height;
//    _rightTableView.scrollEnabled = NO;
    _rightTableView.tag = kRightTableViewTag;
    _rightTableView.delegate = self;
    _rightTableView.dataSource = self;
    [_prodGridView addSubview:_rightTableView];
    
//    [_bgScrollView addSubview:_rightTableView];
//    [self.view addSubview:_rightTableView];
    [self.view addSubview:_prodGridView];
    
    CGFloat bgViewHeight = _leftTableView.frame.size.height > _rightTableView.frame.size.height ? _leftTableView.frame.size.height : _rightTableView.frame.size.height;
    
    _bgScrollView.contentSize = CGSizeMake(_bgScrollView.frame.size.width, bgViewHeight + _headerView.frame.size.height + 50);
    
    _bgScrollViewContentHeight = _bgScrollView.contentSize.height;
    
//    [self.view addSubview:_bgScrollView];
    
    
    UIView *toolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - kToolBarView_Height - 64, SCREEN_WIDTH, kToolBarView_Height)];
    toolBarView.backgroundColor = [UIColor whiteColor];
    
    _totalCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH * (1.0 - kScaleOfLeftTableViewToScreenWidth), kToolBarView_Height - 20)];
    
    [self setTotalCountLabelTextContent:[NSString stringWithFormat:@"总计:  ¥ %@", _totalCountStr]];
    
    UIButton *orderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [orderBtn setFrame:CGRectMake(_totalCountLabel.frame.size.width, 0, SCREEN_WIDTH - _totalCountLabel.frame.size.width, kToolBarView_Height)];
    orderBtn.backgroundColor = MAIN_TINT_COLOR;
    
    [orderBtn setTitle:@"下单" forState:UIControlStateNormal];
    [orderBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [orderBtn addTarget:self action:@selector(orderBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [toolBarView addSubview:_totalCountLabel];
    [toolBarView addSubview:orderBtn];
    
    [self.view addSubview:toolBarView];
    
//    _orderRelationView = [[WSHOrderRelationView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) andFuncsBean:self.currentFuncs andDataCache:_prodKeyValueCacheDataDic];
    
}

- (void)setTotalCountLabelTextContent:(NSString *)textContent
{
    NSMutableAttributedString *hintString = [[NSMutableAttributedString alloc] initWithString:textContent];
    //获取要调整颜色的文字位置,调整颜色
    NSRange range1 = [[hintString string] rangeOfString:@":"];
    NSRange range2 = NSMakeRange(range1.location + 1, textContent.length - range1.location - 1);
    [hintString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range2];
    
    _totalCountLabel.attributedText = hintString;
}

#pragma mark - 下单点击
- (void)orderBtnClicked:(id)sender
{
    [self.view endEditing:YES];
    
    //YIHAIKERRY-1381 测试特殊要求  非得要在点击下单时候再判断是否有不符合填写规则的, 这种逻辑有问题,如果用户不按照规则已经填写了好几十条商品,就会不停的提示,用户要反复去找之前填写的商品,用户体验很不好,已经和测试说明,但是测试一意孤行
    if (_prodKeyValueCacheDataDic && _prodKeyValueCacheDataDic.allKeys.count > 0)
    {
        BOOL isPriceBlank = NO;
        BOOL isDiscountNotLowerThanPrice = NO;
        BOOL isValidateSuccess = NO;

        NSMutableArray *prodIdStrMArray = [[NSMutableArray alloc] init];
        
        for (NSString *key in _prodKeyValueCacheDataDic.allKeys) {
            
            NSArray *keySegStr = [key componentsSeparatedByString:@"_"];
            NSString *prodIdStr = [keySegStr firstObject];
            //            NSString *colStr = [keySegStr lastObject];
            if ([prodIdStrMArray containsObject:prodIdStr])
            {
            }
            else
            {
                /*对应列值得所需要的key*/
                NSString *item2Key;//数量
                NSString *item3Key;//单价
                NSString *item7Key;//折扣价
                NSString *item8Key;//折扣率
                NSString *item9Key;//折扣数量

                for (int i = 0; i < self.currentFuncs.paramArray.count; i ++) {
                    
                    WSFuncsBean_Param *colParam = [self.currentFuncs.paramArray objectAtIndex:i];
                    
                    if ([colParam.col isEqualToString:@"item2"])
                    {
                        item2Key = [NSString stringWithFormat:@"%@_%@", prodIdStr, colParam.col];
                    }

                    if ([colParam.col isEqualToString:@"item3"])
                    {
                        item3Key = [NSString stringWithFormat:@"%@_%@", prodIdStr, colParam.col];
                    }
                    
                    if ([colParam.col isEqualToString:@"item7"])
                    {
                        item7Key = [NSString stringWithFormat:@"%@_%@", prodIdStr, colParam.col];
                    }
                    
                    if ([colParam.col isEqualToString:@"item8"])
                    {
                        item8Key = [NSString stringWithFormat:@"%@_%@", prodIdStr, colParam.col];
                    }

                    if ([colParam.col isEqualToString:@"item9"])
                    {
                        item9Key = [NSString stringWithFormat:@"%@_%@", prodIdStr, colParam.col];
                    }
                }
                
                [prodIdStrMArray addObject:prodIdStr];
                
                //折扣价大于单价 重置折扣价 并提示
                NSString *item3ValueStr = [_prodKeyValueCacheDataDic objectForKey:item3Key];
                NSString *item7ValueStr = [_prodKeyValueCacheDataDic objectForKey:item7Key];
                NSString *item9ValueStr = [_prodKeyValueCacheDataDic objectForKey:item9Key];
                NSString *item2ValueStr = [_prodKeyValueCacheDataDic objectForKey:item2Key];
                NSString *item8ValueStr = [_prodKeyValueCacheDataDic objectForKey:item8Key];

                if (item7ValueStr.length <= 0) {
                    item7ValueStr = @"0";
                }
                
                if (item8ValueStr.length <= 0) {
                    item8ValueStr = @"0";
                }

                if (item9ValueStr.length <= 0) {
                    item9ValueStr = @"0";
                }
                
                if (item2ValueStr.length <= 0) {
                    item2ValueStr = @"0";
                }

                
                if ((item3ValueStr.length <= 0 || [item3ValueStr floatValue] == 0) && ([item7ValueStr floatValue] != 0 || [item9ValueStr floatValue] != 0 || [item8ValueStr floatValue] != 0))
                {
                    isPriceBlank = isPriceBlank || YES;
                    isValidateSuccess = isValidateSuccess || NO;
                    
                    //                        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:@"请填写单价!" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                    //                        return;
                }else if ((item3ValueStr.length <= 0 || [item3ValueStr floatValue] == 0) && ([item7ValueStr floatValue] == 0 && [item9ValueStr floatValue] == 0 && [item8ValueStr floatValue] == 0)) {
                    isValidateSuccess = isValidateSuccess || NO;
                    isDiscountNotLowerThanPrice = isDiscountNotLowerThanPrice || NO;
                    
                    //                        return;
                }
                else if ([item3ValueStr floatValue] <= [item7ValueStr floatValue])
                {
                    isPriceBlank = isPriceBlank || NO;
                    isDiscountNotLowerThanPrice = isDiscountNotLowerThanPrice || YES;
                    isValidateSuccess = isValidateSuccess || NO;
                    
                    //                         [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:@"折扣价不能大于或等于单价，请修改！" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                    //                        return;
                }else if ([item9ValueStr floatValue] == 0 && [item2ValueStr floatValue] == 0) {
                    if (item3ValueStr.length <= 0 || [item3ValueStr floatValue] == 0) {
                        isPriceBlank = isPriceBlank || YES;
                    }
                    isValidateSuccess = isValidateSuccess || NO;
                    isDiscountNotLowerThanPrice = isDiscountNotLowerThanPrice || NO;
                    //                        return;
                }
                else{
                    if (item3ValueStr.length <= 0 || [item3ValueStr floatValue] == 0) {
                        isPriceBlank = isPriceBlank || YES;
                    }
                    isDiscountNotLowerThanPrice = isDiscountNotLowerThanPrice || NO;
                    isValidateSuccess = isValidateSuccess || YES;
                }
                
            }
        }
        
        if (isPriceBlank) {
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:@"请填写单价!" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return;
        }
        
        if (isDiscountNotLowerThanPrice) {
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:@"折扣价不能大于或等于单价，请修改！" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return;
        }
        
        if (!isValidateSuccess) {
            return;
        }
        
    }else{
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:@"请填写单价!" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }

    // 跳页方式
    WSHOrderRelationViewController *orderRelationVC = [[WSHOrderRelationViewController alloc] initWithFuncs:self.currentFuncs Store:self.currentStore];
    orderRelationVC.dataCacheDic = _prodKeyValueCacheDataDic;
    orderRelationVC.navPreViewController = self;
    orderRelationVC.totalCountStr = _totalCountStr;
    orderRelationVC.prodFirstLevelTypesArray = [NSArray arrayWithArray:_leftTableDataSource];
    
    [self.navigationController pushViewController:orderRelationVC animated:YES];
    
    // 非跳页方式
//    if (_prodKeyValueCacheDataDic && _prodKeyValueCacheDataDic.allKeys.count > 0) {
//        [_orderRelationView removeFromSuperview];
//        [self.view addSubview:_orderRelationView];
//        
//        [UIView animateWithDuration:1.0 animations:^{
//            
//            _orderRelationView.funcsBean = self.currentFuncs;
//            _orderRelationView.dataCacheDic = _prodKeyValueCacheDataDic;
//            [_orderRelationView resetTotalCount:_totalCountStr];
//            [_orderRelationView resetDataSource];
//            
//            [_orderRelationView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//            
//        } completion:^(BOOL finished) {
//            
//        }];
//    }else{
//        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"还没有填报任何数据无法完成下单", nil)];
//        
//        [alert addButtonWithTitle:NSLocalizedString(@"确定", nil) block:^{
//            
//        }];
//        
//        [alert show];
//
//    }

}

- (void)storeInfoHasArrived:(id)sender{
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    //add by 王东艳 2012-02-23 for 解开禁用的按钮
    self.navigationController.navigationBar.userInteractionEnabled=YES;
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:NOTIFY_STOREINFO object:nil];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    
    if (error) {
        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    } else {
        NSDictionary *responsedic = [info objectFromJSONString];
        
        NSString *objIdString = STOREINFO_UPDATE;
        
        NSArray *sInfo = [responsedic objectForKey:objIdString];
        NSDictionary *dic = [sInfo objectAtIndex:0];
        NSArray * storeInfo = [dic objectForKey:@"storeInfo"];
        for (NSDictionary * dict in storeInfo) {
//            NSString * phoneNumber = [dict objectForKey:@"col2"];
//            if ([phoneNumber isPhoneNumber]) {
//                NSString * nameAndPhoneNumber = [NSString stringWithFormat:@"%@:%@",dict[@"col1"],phoneNumber];
//                [self.linktelArray addObject:nameAndPhoneNumber];
//            }
        }
    }
}

- (UIView *)getTableHeaderView
{
    CGFloat autoHeight = 0.0;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kHeaderViewMinHeight)];
    UITapGestureRecognizer * showStoreInfoGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showStoreInfoViewController)];
    [headerView addGestureRecognizer:showStoreInfoGesture];
    
    headerView.backgroundColor = [UIColor colorForKey:@"WorkFlowTitleViewBackgroudColor"];
    
    UIFont *storeNameFont = [UIFont boldSystemFontOfSize:15];
    
    BOOL isPhoneMode;
//    NSString *menuType = self.currentFuncs.menuType;
    NSString *menuType = nil;
    if (menuType && menuType.length > 0) {
        isPhoneMode = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(storeInfoHasArrived:)
                                                     name:NOTIFY_STOREINFO
                                                   object:nil];
        
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:@"正在更新数据" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeWaiting];
        
        [[WSRequestHelper shareInstance] appGetStoreInfobyStoreId:self.currentStore.Id notifyName:NOTIFY_STOREINFO styp:self.currentStore.styp];
        
    } else {
        isPhoneMode = NO;
    }
    
    UIImageView *storeImageView;
    if (!isPhoneMode) {
        if (!_isInThinMode) {
            storeImageView = [UIImageView newAutoLayoutView];
            storeImageView.tag = 10002;
            storeImageView.contentMode = UIViewContentModeScaleAspectFill;
            storeImageView.clipsToBounds = YES;
            
            NSString *detectFc = self.moduleFC;
            if (self.input_reflect_code && [self.input_reflect_code length]>0) {
                
                if (![self.moduleFC isEqualToString:self.input_reflect_code]) {
                    detectFc = self.input_reflect_code;
                    
                }
            }
            
            NSString *local_image = [[WSInoutStoreTable sharedTable]getStoreLocalImageWithStore:self.currentStore andOtherParam:nil andParamType:EParameterType_NULL];
            // MSTD-3636 与安卓逻辑保持一致，优先显示服务器回显照片
            if ([self.currentStore.storeImg length] > 0){
                if ([self.currentStore.storeImg rangeOfString:@"."].location != NSNotFound) {
                    [[WSRequestHelper shareInstance] downloadImageWithUrl:[WSHttpURLHelper getImageCompleteURL:self.currentStore.storeImg] imageView:storeImageView placeholderImage:[UIImage imageNamed:@"place_holder"]];
                    
                }else{
                    // 如果storeImg 是 IMG_IDX  则取本地图片的最后一张  SFA 项目 SFA-5467
                    NSArray * imagePathArray = [[WSImagePathTable sharedTable]queryWithImageIDX:self.currentStore.storeImg];
                    if (imagePathArray.count) {
                        WSImagePathObject * object = [imagePathArray lastObject];
                        if ([object.img_path rangeOfString:@"@"].location != NSNotFound) {
                            
                            NSString * url = [[object.img_path componentsSeparatedByString:@"@"] lastObject];
                            [[WSRequestHelper shareInstance] downloadImageWithUrl:[WSHttpURLHelper getImageCompleteURL:url] imageView:storeImageView placeholderImage:[UIImage imageNamed:@"place_holder"]];
                            
                        }else{
                            UIImage * image = [[SDImageCache sharedImageCache] imageFromKey:object.img_path fromDisk:YES];
                            if (image) {
                                storeImageView.image = image;
                            }else{
                                storeImageView.image = [UIImage imageForName:@"place_holder"];
                                
                            }
                            
                        }
                    }
                }
                
            }
            else if (local_image && local_image.length >0 && ![local_image isEqualToString:@"null"]) {
                UIImage *localImage =[[SDImageCache sharedImageCache]imageFromKey:local_image fromDisk:YES];
                storeImageView.image = localImage;
            }else{
                storeImageView.image = [UIImage imageForName:@"place_holder"];
            }
            storeImageView.userInteractionEnabled = YES;
            UITapGestureRecognizer * showStoreImageView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showStoreImageView:)];
            [storeImageView addGestureRecognizer:showStoreImageView];
            
            [headerView addSubview:storeImageView];
            
            [storeImageView autoSetDimension:ALDimensionWidth toSize:kHeaderImageViewWH];
            [storeImageView autoSetDimension:ALDimensionHeight toSize:kHeaderImageViewWH];
            [storeImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kHeaderImageViewLeftSpace];
            [storeImageView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:headerView];
            //        [storeImageView autoAlignAxisToSuperviewAxis:ALAxisVertical];
            //        [storeImageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20];
        }
    }
    
    UIFont *naviButtonFont = [UIFont systemFontOfSize:11];
    BOOL isShowNaviButton = YES;
    NSString *naviDis = self.currentFuncs.opt.naviDis;
    NSInteger navidisNum = [naviDis integerValue];
    
    if (naviDis && naviDis.length > 0) {
        NSInteger caculateNum = navidisNum >> 1;
        // 是否显示距离与导航 按钮 按二进制位数算，如果 2 位为 1 隐藏 ，或者配置为0页隐藏
        if (navidisNum == 0 || (caculateNum % 2) == 1 ) {
            isShowNaviButton = NO;
        }else{
            navidisNum = 1; // 如果没有配置，则导航图片，距离都显示
        }
    }
    //    if ([naviDis length] > 0 && ([naviDis isEqualToString:@"0"]|| [naviDis isEqualToString:@"2"])) {
    //        isShowNaviButton = NO;
    //    }
    // 导航按钮是否有图片
    BOOL isHaveNavButtonImage =  YES;
    // 按位右移3位，如果等于1  则导航图标隐藏，按钮只显示距离 ，没有导航功能  （具体看WSFuncsBean_opt 中naviDis 参数解释）
    if (navidisNum << 3 == 1) {
        isHaveNavButtonImage = NO;
    }
    
    CGFloat storeNavWidth;
    if ([self.currentStore.distance length] > 0 && isShowNaviButton) {
        if (isHaveNavButtonImage) {
            storeNavWidth = [self.currentStore.distance ws_sizeWithFont:naviButtonFont constrainedToWidth:CGFLOAT_MAX].width + 20;
        }else{
            storeNavWidth = [self.currentStore.distance ws_sizeWithFont:naviButtonFont constrainedToWidth:CGFLOAT_MAX].width ;
        }
        
    } else {
        storeNavWidth = 0;
    }
    
    CGFloat nameWidth = 0;
    if (_isInThinMode) {
        nameWidth = (CGFloat)self.currentFuncs.wfcol;
    }else {
        CGFloat totalWidth = self.view.width;
        if (INTERFACE_IS_PAD) {
            totalWidth = SPLITVIEW_LEFT_DEFAULT_WIDTH;
            if (self.currentFuncs.wfcol > 0) {
                totalWidth = (CGFloat)self.currentFuncs.wfcol;
            }
        }
        nameWidth = totalWidth - kHeaderImageViewWH - storeNavWidth - kHeaderImageViewLeftSpace - kHeaderImageViewLeftSpace/2 - kView_Height;
    }
    
    CGSize size = [self.currentStore.name ws_sizeWithFont:storeNameFont constrainedToWidth:nameWidth lineBreakMode:NSLineBreakByCharWrapping];
    
    autoHeight += size.height;
    
    //    UILabel *storeNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(storeImageView.right + kHeaderImageViewLeftSpace, 26, headerView.width - (storeImageView.right + kHeaderImageViewLeftSpace + 5), size.height)];
    UILabel *storeNameLabel = [UILabel newAutoLayoutView];
    storeNameLabel.text = self.currentStore.name;
    
    //    if (isInThinMode) {
    //        storeNameLabel.numberOfLines = 1;
    //    }else {
    // 20160926 Changed By HZH. [名称需显示完全可换行]
    //        storeNameLabel.numberOfLines = 2;
    storeNameLabel.numberOfLines = 0;
    //    }
    
    storeNameLabel.font = storeNameFont;
    storeNameLabel.backgroundColor = [UIColor clearColor];
    storeNameLabel.textColor = [UIColor blackColor];
    storeNameLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [headerView addSubview:storeNameLabel];
    UIColor *titleColor = [UIColor colorForKey:@"WorkFlowTitleViewTitleColor"];
    if (titleColor) {
        storeNameLabel.textColor = titleColor;
    }
    
    if (!self.currentStore.distance || [self.currentStore.distance length] == 0) {
        // 大于0时，不使用宽度限制，设置 storeNameLabel 和 navButton 距离，避免两者重叠
        if (_isInThinMode) {
            [storeNameLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:headerView withOffset:-20];
        }else {
            [storeNameLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:headerView withOffset:-(kHeaderImageViewWH + kHeaderImageViewLeftSpace * 2 + 5)];
        }
    }
    
    if (_isInThinMode || isPhoneMode) {
        [storeNameLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:15];
    }else {
        [storeNameLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:storeImageView withOffset:kHeaderImageViewLeftSpace];
    }
    
    [storeNameLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20];
    autoHeight += 20;
    
    if ([self.currentStore.distance length] > 0) {
        UIButton *navButton = [UIButton newAutoLayoutView];
        
        [headerView addSubview:navButton];
        
        
        
        [navButton autoSetDimension:ALDimensionWidth toSize:storeNavWidth];
        
        [navButton setTitleColor:MAIN_TINT_COLOT forState:UIControlStateNormal];
        [navButton setTitle:self.currentStore.distance forState:UIControlStateNormal];
        if (isHaveNavButtonImage) {
            
            [navButton setImage:[UIImage imageForName:@"mapNav"] forState:UIControlStateNormal];
            [navButton addTarget:self action:@selector(navButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [navButton.titleLabel setFont:naviButtonFont];
        [navButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kView_Height];
        [navButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:NAV_BUTTON_TOP_SPACE];
        [navButton autoSetDimension:ALDimensionHeight toSize:STORE_NAV_BUTTON_HEGIHT];
        
        
        [storeNameLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:navButton withOffset:-kHeaderImageViewLeftSpace/2];
        
        if (!isShowNaviButton) {
            navButton.hidden = YES;
        }
    }
    
    UIFont *storeIDFont = [UIFont systemFontOfSize:13];
    CGSize storeIDSize = [self.currentStore.code ws_sizeWithFont:storeIDFont constrainedToWidth:CGFLOAT_MAX];
    
    autoHeight += storeIDSize.height;
    
    
    //    UILabel *storeIDLabel = [[UILabel alloc] initWithFrame:CGRectMake(storeNameLabel.left, storeNameLabel.bottom + 10, storeIDSize.width, storeIDSize.height)];
    UILabel *storeIDLabel = [UILabel newAutoLayoutView];
    storeIDLabel.text = self.currentStore.code;
    storeIDLabel.font = storeIDFont;
    storeIDLabel.backgroundColor = [UIColor clearColor];
    storeIDLabel.textColor = [UIColor colorWithHexString:@"#6b6b6b"];
    [headerView addSubview:storeIDLabel];
    if (!INTERFACE_IS_PHONE) {
        [storeIDLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:storeNameLabel];
    }
    
    
    if (_isInThinMode) {
        [storeIDLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:storeNameLabel withOffset:18];
        autoHeight += 18;
        
    }else {
        [storeIDLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:storeNameLabel withOffset:5];
        autoHeight += 5;
        
    }
    
    if (INTERFACE_IS_PHONE) {
        
        UIImageView * codeImageView = [UIImageView newAutoLayoutView];
        codeImageView.image = [UIImage imageNamed:@"info_bianma_icon"];
        [headerView addSubview:codeImageView];
        
        [codeImageView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:storeNameLabel];
        [storeIDLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:codeImageView];
        
        CGFloat codeImageViewWidth = kView_Height - 3;
        [codeImageView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:storeIDLabel];
        [codeImageView autoSetDimension:ALDimensionWidth toSize:codeImageViewWidth];
        [codeImageView autoSetDimension:ALDimensionHeight toSize:kView_Height - 3];
        
        //        [codeImageView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:storeIDLabel];
        
        UIView *lastView = storeIDLabel;
        
        CGFloat labelPadding = kView_Height/4;
        NSLayoutConstraint * storeAddrLabelTopContraint;
        NSLayoutConstraint * storeAddrImageTopContraint;
        NSLayoutConstraint * isPlanImgViewLeftContraint;
        NSLayoutConstraint * imgScrollViewLeftContraint;
        UILabel *storeAddrLabel ;
        UIImageView * addImageView;
        if (self.currentStore.addr.length > 0) {
            
            addImageView = [UIImageView newAutoLayoutView];
            addImageView.image = [UIImage imageNamed:@"info_dizhi_icon"];
            storeAddrLabel = [UILabel newAutoLayoutView];
            storeAddrLabel.numberOfLines = 0;
            storeAddrLabel.text = self.currentStore.addr;
            storeAddrLabel.font = storeIDFont;
            storeAddrLabel.backgroundColor = [UIColor clearColor];
            storeAddrLabel.textColor = [UIColor colorWithHexString:@"#6b6b6b"];
            [headerView addSubview:addImageView];
            [headerView addSubview:storeAddrLabel];
            storeAddrLabelTopContraint =   [storeAddrLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:storeIDLabel withOffset:labelPadding];
            [storeAddrLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:addImageView];
            [storeAddrLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:2*NAV_BUTTON_RIGTHT_SPACE];
            
            CGFloat labelWidth = self.view.width - codeImageViewWidth - labelPadding;
            if (storeImageView) {
                labelWidth -= (kHeaderImageViewWH + kHeaderImageViewLeftSpace * 2);
            }
            if (INTERFACE_IS_PHONE) {
                if (!isPhoneMode && ![self.currentFuncs.isStoreInfo isEqualToString:@"0"]) {
                    labelWidth -= 25;
                }
            }
            CGSize addrSize = [self.currentStore.addr ws_sizeWithFont:storeIDFont constrainedToWidth:labelWidth];
            autoHeight += labelPadding + addrSize.height;
            
            storeAddrImageTopContraint = [addImageView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:storeIDLabel withOffset:labelPadding];
            [addImageView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:storeNameLabel];
            [addImageView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:codeImageView];
            [addImageView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:codeImageView];
            
            lastView = storeAddrLabel;
            
            
            
        }
        
        if ([self.currentStore.last_date length] > 0) {
            
            UIImageView * lastDateImageView = [UIImageView newAutoLayoutView];
            lastDateImageView.image = [UIImage imageNamed:@"info_date_icon"];
            UILabel *storeLastDateLabel = [UILabel newAutoLayoutView];
            storeLastDateLabel.numberOfLines = 0;
            NSString *dateValue = [NSString stringWithFormat:NSLocalizedString(@"最近拜访:%@", nil),self.currentStore.last_date] ;
            storeLastDateLabel.text = dateValue;
            storeLastDateLabel.font = storeIDFont;
            storeLastDateLabel.backgroundColor = [UIColor clearColor];
            storeLastDateLabel.textColor = [UIColor colorWithHexString:@"#6b6b6b"];
            [headerView addSubview:lastDateImageView];
            [headerView addSubview:storeLastDateLabel];
            [storeLastDateLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lastView withOffset:labelPadding];
            [storeLastDateLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:lastDateImageView];
            CGFloat rightPadding = 2*NAV_BUTTON_RIGTHT_SPACE;
            [storeLastDateLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:rightPadding];
            
            CGFloat labelWidth = self.view.width - codeImageViewWidth - labelPadding;
            if (storeImageView) {
                labelWidth -= kHeaderImageViewWH + kHeaderImageViewLeftSpace * 2;
            }
            if (INTERFACE_IS_PHONE) {
                if (!isPhoneMode && ![self.currentFuncs.isStoreInfo isEqualToString:@"0"]) {
                    labelWidth -= 25;
                }
            }
            CGSize dateSize = [dateValue ws_sizeWithFont:storeIDFont constrainedToWidth:labelWidth];
            autoHeight += labelPadding + dateSize.height;
            
            [lastDateImageView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lastView withOffset:labelPadding];
            [lastDateImageView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:storeNameLabel];
            [lastDateImageView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:codeImageView];
            [lastDateImageView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:codeImageView];
            
            lastView = storeLastDateLabel;
            
            
        }
        if ([self.currentStore.last_transaction length] > 0) {
            
            UIImageView * lastTransactionImageView = [UIImageView newAutoLayoutView];
            lastTransactionImageView.image = [UIImage imageNamed:@"info_date_icon"];
            UILabel *storeLastTransactionLabel = [UILabel newAutoLayoutView];
            storeLastTransactionLabel.numberOfLines = 0;
            NSString *lastTransactionValue = [NSString stringWithFormat:NSLocalizedString(@"最近交易:%@", nil),self.currentStore.last_transaction] ;
            storeLastTransactionLabel.text = lastTransactionValue;
            storeLastTransactionLabel.font = storeIDFont;
            storeLastTransactionLabel.backgroundColor = [UIColor clearColor];
            storeLastTransactionLabel.textColor = [UIColor colorWithHexString:@"#6b6b6b"];
            [headerView addSubview:lastTransactionImageView];
            [headerView addSubview:storeLastTransactionLabel];
            [storeLastTransactionLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lastView withOffset:labelPadding];
            [storeLastTransactionLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:lastTransactionImageView];
            CGFloat rightPadding = 2*NAV_BUTTON_RIGTHT_SPACE;
            [storeLastTransactionLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:rightPadding];
            
            CGFloat labelWidth = self.view.width - codeImageViewWidth - labelPadding;
            if (storeImageView) {
                labelWidth -= kHeaderImageViewWH + kHeaderImageViewLeftSpace * 2;
            }
            if (INTERFACE_IS_PHONE) {
                if (!isPhoneMode && ![self.currentFuncs.isStoreInfo isEqualToString:@"0"]) {
                    labelWidth -= 25;
                }
            }
            CGSize dateSize = [lastTransactionValue ws_sizeWithFont:storeIDFont constrainedToWidth:labelWidth];
            autoHeight += labelPadding + dateSize.height;
            
            [lastTransactionImageView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lastView withOffset:labelPadding];
            [lastTransactionImageView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:storeNameLabel];
            [lastTransactionImageView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:codeImageView];
            [lastTransactionImageView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:codeImageView];
            
            
        }
        
        UIImageView * isPlanImgView = [UIImageView newAutoLayoutView];
        if (self.currentStore.plan) {
            isPlanImgView.image = [UIImage imageNamed:@"point_plan_icon"];
            [headerView addSubview:isPlanImgView];
            isPlanImgViewLeftContraint = [isPlanImgView autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:storeIDLabel withOffset:kHeaderImageViewLeftSpace];
            [isPlanImgView autoSetDimension:ALDimensionHeight toSize:kView_Height];
            [isPlanImgView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:storeIDLabel];
            [isPlanImgView autoSetDimension:ALDimensionWidth toSize:(kView_Height + 5)];
        }
        UIScrollView * imgScrollView = [UIScrollView newAutoLayoutView];
        //        imgScrollView.backgroundColor = [UIColor redColor];
        [headerView addSubview:imgScrollView];
        if (self.currentStore.plan) {
            [imgScrollView autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:isPlanImgView];
        }else{
            imgScrollViewLeftContraint = [imgScrollView autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:storeIDLabel];
            
        }
        [imgScrollView autoSetDimension:ALDimensionHeight toSize:kView_Height];
        
        [imgScrollView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:storeIDLabel];
        
        [imgScrollView autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:headerView withOffset:-20 - 26 - kHeaderImageViewLeftSpace];
        
        
        if (self.currentStore.attri && self.currentStore.attri.length > 0) {
            NSArray * storeImgs = [self.currentStore.attri componentsSeparatedByString:@","];
            CGFloat imgX = 0;
            for (int i = 0; i < storeImgs.count; i++) {
                
                imgX = i * (kView_Height + 5) + (i + 1) *kHeaderIconPadding;
                UIImageView * imgView = [[UIImageView alloc]initWithFrame:CGRectMake(imgX  , 0, kView_Height + 5, kView_Height)];
                //                imgView.image = [UIImage scaledImageForName:[NSString stringWithFormat:@"%@@2x",storeImgs[i]] ofType:@"png"];

                [[WSRequestHelper shareInstance] downloadImageWithUrl:[storeImgs[i] buildupUrl] imageView:imgView];
                
                //                imgView.backgroundColor = [UIColor blackColor];
                [imgScrollView addSubview:imgView];
                imgScrollView.contentSize = CGSizeMake(imgX, 0);
            }
            
        }
        
        if ([self.currentFuncs.opt.isCode isEqualToString:@"0"]) {
            codeImageView.hidden = YES;
            storeIDLabel.hidden = YES;
            if ((self.currentStore.attri && self.currentStore.attri.length > 0) || self.currentStore.plan) {
                if (self.currentStore.plan) {
                    [isPlanImgViewLeftContraint autoRemove];
                    isPlanImgViewLeftContraint = [isPlanImgView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:storeNameLabel];
                }else{
                    [imgScrollViewLeftContraint autoRemove];
                    imgScrollViewLeftContraint = [imgScrollView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:storeNameLabel];
                }
                
            }else{
                [storeAddrImageTopContraint autoRemove];
                [storeAddrLabelTopContraint autoRemove];
                storeAddrLabelTopContraint = [storeAddrLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:storeNameLabel withOffset:labelPadding];
                storeAddrImageTopContraint = [addImageView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:storeNameLabel withOffset:labelPadding];
                
            }
        }
    }
    
    UIButton *infoButton = [UIButton newAutoLayoutView];
    if (INTERFACE_IS_PHONE) {
        if (isPhoneMode) {
            [infoButton setBackgroundImage:[UIImage scaledImageForName:@"tel" ofType:@"png"] forState:UIControlStateNormal];
            [headerView addSubview:infoButton];
            
            [infoButton autoSetDimension:ALDimensionWidth toSize:20];
            [infoButton autoSetDimension:ALDimensionHeight toSize:20];
            
            
            [infoButton autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:storeIDLabel withOffset:5];
            
            [infoButton autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:headerView withOffset:-kView_Height];
            
            [infoButton addTarget:self action:@selector(callAction:) forControlEvents:UIControlEventTouchUpInside];
            
        } else if (![self.currentFuncs.isStoreInfo isEqualToString:@"0"]) {
//            [infoButton setBackgroundImage:[UIImage scaledImageForName:@"arrow_right" ofType:@"png"] forState:UIControlStateNormal];
            [headerView addSubview:infoButton];
            
            [infoButton autoSetDimension:ALDimensionWidth toSize:20];
            [infoButton autoSetDimension:ALDimensionHeight toSize:20];
            [infoButton autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:storeIDLabel withOffset:5];
            [infoButton autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:headerView withOffset:-kView_Height];
        }
        
    }else {
        //        UIButton *infoButton = [[UIButton alloc] initWithFrame:CGRectMake(storeNameLabel.left, storeIDLabel.bottom + 10, 70, 25)];
        [infoButton setImage:[UIImage imageNamed:@"map_button"] forState:UIControlStateNormal];
        infoButton.backgroundColor = [UIColor clearColor];
        [headerView addSubview:infoButton];
        [infoButton addTarget:self action:@selector(showStoreMapViewController) forControlEvents:UIControlEventTouchUpInside];
        
        
        CGFloat imageWH;
        
        [infoButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:storeNameLabel];
        
        if (_isInThinMode) {
            [infoButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:storeIDLabel withOffset:17];
            
            imageWH = 35;
            
        }else {
            [infoButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:storeIDLabel withOffset:5];
            autoHeight +=10;
            // [infoButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:storeImageView withOffset:0];
            
            // MSTD-3681 图片太大会遮挡文字
            imageWH = 24;
        }
        
        [infoButton autoSetDimension:ALDimensionWidth toSize:imageWH];
        [infoButton autoSetDimension:ALDimensionHeight toSize:imageWH];
        autoHeight += imageWH;
        
        
        
    }
    
    if (_showTemplateFuncsBean) {
        UIButton *lastbutton;
        UIView *leftPinEdgeView;
        if ([infoButton superview]) {
            leftPinEdgeView = infoButton;
        }else if ([storeImageView superview]) {
            leftPinEdgeView = storeImageView;
        }else {
            leftPinEdgeView = headerView;
        }
        
        for (WSFuncsBean *funcsBean in _showTemplateFuncsBean.funcsArray) {
            UIButton *button = [UIButton newAutoLayoutView];
            
            [button setImage:[UIImage imageNamed:funcsBean.fv] forState:UIControlStateNormal];
            button.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [button autoSetDimension:ALDimensionWidth toSize:35];
            [button autoSetDimension:ALDimensionHeight toSize:35];
            
            button.tag = kTemplateButtonTag + [_showTemplateFuncsBean.funcsArray indexOfObject:funcsBean];
            [headerView addSubview:button];
            [button addTarget:self action:@selector(showTemplateButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            
            
            if (_isInThinMode) {
                [button autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:infoButton];
                if (lastbutton) {
                    [button autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:lastbutton withOffset:30];
                }else {
                    [button autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:leftPinEdgeView withOffset:30];
                }
            }else {
                [button autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:20];
                if (lastbutton) {
                    [button autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:lastbutton withOffset:20];
                }else {
                    [button autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:leftPinEdgeView withOffset:25];
                }
            }
            
            lastbutton = button;
        }
    }
    
    autoHeight += 20;
    
    UIColor *bottomLineColor = [UIColor colorForKey:@"WorkFlowTitleViewBottomLineColor"];
    if (bottomLineColor) {
        UIView *line = [UIView newAutoLayoutView];
        line.backgroundColor = bottomLineColor;
        [headerView addSubview:line];
        [line autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:headerView];
        [line autoSetDimension:ALDimensionHeight toSize:1];
        [line autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    }
    
    [headerView setFrame:CGRectMake(0, 0, self.view.width, MAX(kHeaderViewMinHeight, autoHeight))];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _headerView = headerView;
    return headerView;
}


- (void)showStoreInfoViewController
{
    
}


-(void)showStoreImageView:(UITapGestureRecognizer *)gesture{
    _headerView.userInteractionEnabled = NO;
    UIImageView * imageView = (UIImageView *)(gesture.view);
    
    if (imageView) {
        [self scaleImageWithImageArray:@[imageView.image] index:0];
    }
    
}

- (void)scaleImageWithImageArray:(NSArray *)array index:(NSInteger)index
{
    WSAppDelegate *delegate = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
    UIView *rootView = delegate.window.rootViewController.view;
    if(INTERFACE_IS_PAD){
        UIViewController *topVC = kApplicationWinddow.rootViewController;
        if ([topVC isKindOfClass:[UINavigationController class]]) {
            topVC = ((UINavigationController *)topVC).visibleViewController;
        }else if (topVC.presentedViewController) {
            while (topVC.presentedViewController) {
                topVC = topVC.presentedViewController;
            }
        }
        
        rootView=topVC.view;
    }
    
    WSImageBrowserView * view = [[WSImageBrowserView alloc]initWithFrame:INTERFACE_IS_PAD ? CGRectMake(0, 0, BROWSERVC_WIDTH, BROWSERVC_HEIGNT) : kApplicationWinddow.bounds andImage:array andImageIndex:index];
    
    UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchShowImageViewEnd:)];
    [view addGestureRecognizer:gesture];
    if (INTERFACE_IS_PAD) {
        view.frame = CGRectMake((BROWSERVC_WIDTH - view.width)/2,view.size.height, view.size.width, view.size.height);
    } else {
        view.frame = CGRectMake(view.origin.x,rootView.size.height, view.size.width, rootView.size.height);
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        view.top = INTERFACE_IS_PAD?0:20;
    } completion:^(BOOL finished) {
        
    }];
    [rootView addSubview:view];
    
    if (INTERFACE_IS_PAD) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    
}

- (void)touchShowImageViewEnd:(UITapGestureRecognizer *)gesture {
    _headerView.userInteractionEnabled = YES;
    
    [UIView animateWithDuration:0.25 animations:^{
        gesture.view.top = gesture.view.height;
    } completion:^(BOOL finished) {
        [gesture.view removeFromSuperview];
    }];
    if (INTERFACE_IS_PAD) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == kLeftTableViewTag) {
        return kLeftTableCellHeight;
    }else if (tableView.tag == kRightTableViewTag){
//        WSProdGrideWithExpandableBrandsRightTableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
//        cell.itemCellHeight = 80.0;

        WSDataGridRightTableModel *dataModel = _rightTableDataSource[indexPath.row];
        
        if (dataModel.isExPanded) {
            
            if (dataModel.prodsArray.count > 0) {
//                return 80 + 44*(dataModel.prodsArray.count + 1) + 10;
                return 80 + dataModel.gridComViewHeight + 5;
            }else{
                return 80;
            }
            
        }else
            return 80;
        
    }else
        return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == kLeftTableViewTag) {
        return 0.1;
    }else if (tableView.tag == kRightTableViewTag){
        return 0.1;
    }else
        return 0.1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == kLeftTableViewTag) {
        return _leftTableDataSource.count;
    }else if (tableView.tag == kRightTableViewTag){
        return _rightTableDataSource.count;
    }else
        return 0;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView.tag == kLeftTableViewTag) {
        
        WSProdGrideWithExpandableBrandsLeftTableViewCell *cell = nil;
        
        if ([[_leftTableViewCellArray objectAtIndex:indexPath.row] isKindOfClass:[WSProdGrideWithExpandableBrandsLeftTableViewCell class]]) {
            cell = (WSProdGrideWithExpandableBrandsLeftTableViewCell *)[_leftTableViewCellArray objectAtIndex:indexPath.row];
        }
        
        UIColor *color = [UIColor whiteColor]; // 通过RGB来定义自己的颜色
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = color;
        
        WSDictBean *typeDictBean = (WSDictBean *)[_leftTableDataSource objectAtIndex:indexPath.row];
        
        cell.titleLabel.text = typeDictBean.name;
        
        return cell;

    }else if (tableView.tag == kRightTableViewTag){
        static NSString * reueserId = @"cellForRightTable";
        WSProdGrideWithExpandableBrandsRightTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (cell == nil) {
            cell = [[WSProdGrideWithExpandableBrandsRightTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reueserId];
        }
        
        WSDataGridRightTableModel *dataModel = _rightTableDataSource[indexPath.row];
        
//        WSBaseProductDBService *baseProductDBSerice = [[WSBaseProductDBService alloc] init];
//        NSArray *prodsArray = [baseProductDBSerice queryBrandSortProductsWithStoreId:self.currentStore.drId brand:dataModel.prodTypeDic.Id params:nil];
//        
//        dataModel.gridColParamArray = self.currentFuncs.paramArray;
//        dataModel.prodsArray = prodsArray;
        
        cell.frame = CGRectMake(0, 0, tableView.frame.size.width, cell.frame.size.height);
//        cell.contentView.backgroundColor = [UIColor colorWithRed:252.0/255.0 green:252.0/255.0 blue:252.0/255.0 alpha:1.0];
        cell.contentView.backgroundColor = [UIColor whiteColor];
//        cell.titleLabel.text = _rightTableDataSource[indexPath.row];
        cell.titleLabel.text = dataModel.title;
        NSString * urlString = [WSHttpURLHelper getImageCompleteURL:dataModel.prodTypeDic.col1];
        
        [[WSRequestHelper shareInstance] downloadImageWithUrl:urlString imageView:cell.itemImageView placeholderImage:[UIImage imageNamed:@"place_holder"]];
        
//        if (!cell.indicatorImageOpenedOrClosed) {
//            cell.indicatorImageOpenedOrClosed = YES;
//
//        }
        
        cell.dataGridComponentView = nil;
        
        [cell.dataGridComponentView removeFromSuperview];
        
        cell.dataGridComponentView = [self getRightTableDataGridViewWithCell:cell andDataModel:dataModel];
        
        if (dataModel.isExPanded) {
            cell.dataGridComponentView.hidden = NO;
            cell.indicatorImageOpenedOrClosed = NO;
        }else{
            cell.dataGridComponentView.hidden = YES;
            cell.indicatorImageOpenedOrClosed = YES;
        }
        
        return cell;

    }else
        return nil;
}

- (WSDataGridComponentView *)getRightTableDataGridViewWithCell:(WSProdGrideWithExpandableBrandsRightTableViewCell *)cell andDataModel:(WSDataGridRightTableModel *)dataModel
{
    WSDataGridComponentView *gridView = nil;
    
    if (dataModel.prodsArray.count > 0) {
//        gridView = [[WSDataGridComponentView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 44*(dataModel.prodsArray.count + 1)) andDataModel:dataModel];
        
        gridView = [[WSDataGridComponentView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, dataModel.gridComViewHeight + 5) andDataModel:dataModel];

    }else{
        gridView = [[WSDataGridComponentView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width,0) andDataModel:dataModel];
    }

    return gridView;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView.tag == kLeftTableViewTag) {
        
//        [_leftTableFrontLineView removeFromSuperview];
        
        [self setCellHighlightStateWithTableView:tableView andSelectedRowAtIndexPath:indexPath];
        
        WSDictBean *typeDictBean = (WSDictBean *)[_leftTableDataSource objectAtIndex:indexPath.row];
        
        WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
        
        NSArray *brandArray = [service queryDictWithPid:typeDictBean.Id];
        
//        NSMutableArray *brandArray = [[NSMutableArray alloc] initWithObjects:@"元宝",@"金龙鱼",@"YGY", nil];
        
        [_rightTableDataSource removeAllObjects];
        
        for (WSDictBean *dictBean in brandArray) {
            WSDataGridRightTableModel *dataGridRightTableModel = [[WSDataGridRightTableModel alloc] init];
            NSString *typeAndBrandStr = [NSString stringWithFormat:@"%@", dictBean.name];
            
            dataGridRightTableModel.topTypeIndex = indexPath.row;
            dataGridRightTableModel.firstColWidth = self.currentFuncs.wfcol;
            dataGridRightTableModel.title = typeAndBrandStr;
            dataGridRightTableModel.isExPanded = NO;
            dataGridRightTableModel.prodTypeDic = dictBean;
            
            WSBaseProductDBService *baseProductDBSerice = [[WSBaseProductDBService alloc] init];
            NSArray *prodsArray = [baseProductDBSerice queryBrandSortProductsWithStoreId:self.currentStore.drId brand:dataGridRightTableModel.prodTypeDic.Id params:nil appendprop:self.currentFuncs.opt.appendprop];
            
            // 获取服务器相对应品类的产品回显值
//            [self setProdCacheDicWithProdDisDataBaseDatasFromServerWithProdsArray:prodsArray];
            
            dataGridRightTableModel.gridColParamArray = self.currentFuncs.paramArray;
            dataGridRightTableModel.prodsArray = prodsArray;
            dataGridRightTableModel.prodKeyValueCacheDataDic = _prodKeyValueCacheDataDic;

            
            if (prodsArray && prodsArray.count > 0) {
                [_rightTableDataSource addObject:dataGridRightTableModel];
            }
        }
//        for (NSString *typeStr in brandArray) {
//            NSString *typeAndBrandStr = [NSString stringWithFormat:@"%@-%@", typeStr, [_leftTableDataSource objectAtIndex:indexPath.row]];
//            [_rightTableDataSource addObject:typeAndBrandStr];
//        }
        [_rightTableView reloadData];
        [self resetSubviewsFrame];
        _lastSelectedLeftTableViewCellIndex = indexPath.row;
    }else if (tableView.tag == kRightTableViewTag){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        WSProdGrideWithExpandableBrandsRightTableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        
        WSDataGridRightTableModel *dataModel = _rightTableDataSource[indexPath.row];
        dataModel.isExPanded = !dataModel.isExPanded;
        
        dataModel.secondTypeIndex = indexPath.row;
        
        if (dataModel.isExPanded) {
            cell.dataGridComponentView.hidden = NO;
            cell.indicatorImageOpenedOrClosed = NO;
        }else{
            cell.dataGridComponentView.hidden = YES;
            cell.indicatorImageOpenedOrClosed = YES;
        }
        
//        NSArray *indexPaths = [NSArray arrayWithObjects:indexPath, nil];
//
//        //刷新
//        [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        
        [tableView reloadData];
        
//        _leftTableViewContentHeight = _leftTableView.contentSize.height;
//        _rightTableViewContentHeight = _rightTableView.contentSize.height;

//        _leftTableViewContentHeight = _leftTableView.frame.size.height;
//        _rightTableViewContentHeight = _rightTableView.frame.size.height;
        
        [self resetSubviewsFrame];
    }else
        ;
}

- (void)setCellHighlightStateWithTableView:(UITableView *)tableView andSelectedRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[_leftTableViewCellArray objectAtIndex:indexPath.row] isKindOfClass:[WSProdGrideWithExpandableBrandsLeftTableViewCell class]]) {
        WSProdGrideWithExpandableBrandsLeftTableViewCell *selectedCell = (WSProdGrideWithExpandableBrandsLeftTableViewCell *)[_leftTableViewCellArray objectAtIndex:indexPath.row];

        [selectedCell setIsChecked:YES];

    }

    if (_lastSelectedLeftTableViewCellIndex != indexPath.row) {
        if ([[_leftTableViewCellArray objectAtIndex:_lastSelectedLeftTableViewCellIndex] isKindOfClass:[WSProdGrideWithExpandableBrandsLeftTableViewCell class]]) {
            WSProdGrideWithExpandableBrandsLeftTableViewCell *cell = (WSProdGrideWithExpandableBrandsLeftTableViewCell *)[_leftTableViewCellArray objectAtIndex:_lastSelectedLeftTableViewCellIndex];
            [cell setIsChecked:NO];
        }
    }

}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == kLeftTableViewTag && _isFirstLoad) {
        if([indexPath row] == ((NSIndexPath *)[[tableView indexPathsForVisibleRows] lastObject]).row){
            //end of loading
            //for example [activityIndicator stopAnimating];
            
            NSIndexPath *firstSelectedCellIndexPath =[NSIndexPath indexPathForRow:0 inSection:0];
            [self tableView:_leftTableView didSelectRowAtIndexPath:firstSelectedCellIndexPath];
            _isFirstLoad = NO;
        }
    }
    
}

- (void)gridWidgetValueChangeWithWidget:(WSWidget *)widget andDataGridModel:(WSDataGridPartModel *)model
{
    WSDataGridRightTableModel *dataModel = _rightTableDataSource[model.point_n];
    
    WSProdBean *prodBean = [dataModel.prodsArray objectAtIndex:model.point_x - 1];
    WSFuncsBean_Param *colParam = [dataModel.gridColParamArray objectAtIndex:model.point_y - 1];
    
    NSString *itemKeyStr = [NSString stringWithFormat:@"%@_%@", prodBean.Id, colParam.col];
    
    NSString * value = (NSString *)[widget getResultDirectly];
    if ([colParam.col isEqualToString:@"item8"] && [value floatValue] > 1.0) {
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:@"折扣率不能超过1" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        WSNumberTextFiledPanel *textFielditem8 = (WSNumberTextFiledPanel *)widget;
        textFielditem8.textField.text = @"";
        return;
    }
    
    [self calculateTotalCountWithItemKey:itemKeyStr andOldValue:[_prodKeyValueCacheDataDic objectForKey:itemKeyStr] andNewValue:[NSString stringWithFormat:@"%@", value] andDataGridModel:model andWSProdBean:prodBean andWSDataGridRightTableModel:dataModel];
    
    if (value.length == 0 && [colParam.tpy isEqualToString:COL_TYPNUM]) {
//        value = @"0";
    }
    [_prodKeyValueCacheDataDic setObject:[NSString stringNotNilWithValue:value] forKey:[NSString stringWithFormat:@"%@_%@", prodBean.Id, colParam.col]];
    
    NSString *item2Value;//数量
    NSString *item3Value;//单价
    NSString *item7Value;//折扣价
    NSString *item9Value;//折扣数量
    
    
    item2Value = [_prodKeyValueCacheDataDic objectForKey:[NSString stringWithFormat:@"%@_item2", prodBean.Id]];
    item3Value = [_prodKeyValueCacheDataDic objectForKey:[NSString stringWithFormat:@"%@_item3", prodBean.Id]];
    item7Value = [_prodKeyValueCacheDataDic objectForKey:[NSString stringWithFormat:@"%@_item7", prodBean.Id]];
    item9Value = [_prodKeyValueCacheDataDic objectForKey:[NSString stringWithFormat:@"%@_item9", prodBean.Id]];
    
    BOOL isNeedDeleteFromCache = NO;
    
    if (item2Value.length <= 0 && item3Value.length <= 0 && item7Value.length <= 0 && item9Value.length <= 0) {
        isNeedDeleteFromCache = YES;
    }
    
    if (isNeedDeleteFromCache) {
        for (WSFuncsBean_Param *fbColParam in dataModel.gridColParamArray) {
            NSString *itemKey = [NSString stringWithFormat:@"%@_%@", prodBean.Id, fbColParam.col];
            [_prodKeyValueCacheDataDic removeObjectForKey:itemKey];
        }
    }

    NSLog(@"+++++++++++++++++++++++gridWidgetValueChange _prodKeyValueCacheDataDic = \n %@", _prodKeyValueCacheDataDic);
    
    [self setTotalCountLabelTextContent:[NSString stringWithFormat:@"总计:  ¥ %@", _totalCountStr]];
}

- (void)calculateTotalCountWithItemKey:(NSString *)key andOldValue:(NSString *)oldValue andNewValue:(NSString *)newValue andDataGridModel:(WSDataGridPartModel *)model andWSProdBean:(WSProdBean *)prodBean andWSDataGridRightTableModel:(WSDataGridRightTableModel *)dataModel
{
    NSString *currentValueStr = oldValue;
    [keyArray removeAllObjects];
    [valueArray removeAllObjects];
    /*对应列值得所需要的key*/
    // YIHAIKERRY-1427 益海嘉里-上海：订单：订单确认页面缺少“上次单价”
    NSString *item1Key;//上次单价
    NSString *item2Key;//数量
    NSString *item3Key;//单价
    NSString *item8Key;//折扣率
    NSString *item7Key;//折扣价
    NSString *item9Key;//折扣数量
    
    NSMutableArray *valueNeedCalculateColNameStrArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.currentFuncs.paramArray.count; i ++) {
        WSFuncsBean_Param *colParam = [self.currentFuncs.paramArray objectAtIndex:i];
        
        if ([colParam.col isEqualToString:@"item1"])
        {
            item1Key = [NSString stringWithFormat:@"%@_%@", prodBean.Id, colParam.col];
        }
        
        if ([colParam.col isEqualToString:@"item2"])
        {
            item2Key = [NSString stringWithFormat:@"%@_%@", prodBean.Id, colParam.col];
            [keyArray addObject:item2Key];
        }
        
        if ([colParam.col isEqualToString:@"item3"])
        {
            item3Key = [NSString stringWithFormat:@"%@_%@", prodBean.Id, colParam.col];
            [keyArray addObject:item3Key];
        }
        
        if ([colParam.col isEqualToString:@"item8"])
        {
            item8Key = [NSString stringWithFormat:@"%@_%@", prodBean.Id, colParam.col];
        }
        
        if ([colParam.col isEqualToString:@"item7"])
        {
            item7Key = [NSString stringWithFormat:@"%@_%@", prodBean.Id, colParam.col];
            [keyArray addObject:item7Key];
        }
        
        if ([colParam.col isEqualToString:@"item9"])
        {
            item9Key = [NSString stringWithFormat:@"%@_%@", prodBean.Id, colParam.col];
            [keyArray addObject:item9Key];
        }
        [valueNeedCalculateColNameStrArray addObject:colParam.col];
    }
    
    //解析发生改变的空间的key
    NSArray *keySegStr = [key componentsSeparatedByString:@"_"];
    NSString *prodIdStr = [keySegStr firstObject];
    NSString *colStr = [keySegStr lastObject];
    
    if ([valueNeedCalculateColNameStrArray containsObject:colStr])
    {
        WSNumberTextFiledPanel *textFielditem3;
        WSNumberTextFiledPanel *textFielditem7;
        WSNumberTextFiledPanel *textFielditem8;
        for (WSNumberTextFiledPanel *textField in dataModel.gridColWidgetArray) {
            if ([[textField.xbuildInfo getColKey] isEqualToString: item3Key]) {
                textFielditem3 = textField;
            }
            if ([[textField.xbuildInfo getColKey] isEqualToString: item7Key]) {
                textFielditem7 = textField;
            }
            if ([[textField.xbuildInfo getColKey] isEqualToString: item8Key]) {
                textFielditem8 = textField;
            }
        }
        
        if ([colStr isEqualToString:@"item2"] || [colStr isEqualToString:@"item3"] || [colStr isEqualToString:@"item7"] ||[colStr isEqualToString:@"item9"])
        {
            [self setViewArrayWithIsResetValue:YES];

            //获得发生改变的子总价 因为是两套价格  所以要区分 是正常还是折扣  价格改变 就要取 数量 同理相反  如果折扣价格改变 就要取折扣数量 同意相反
            if ([colStr isEqualToString:@"item2"])
            {
                colStr = @"item3";
            }
            else if ([colStr isEqualToString:@"item3"])
            {
                //折扣价大于单价 重置折扣价 并提示
                if (([newValue floatValue] < [[_prodKeyValueCacheDataDic objectForKey:item7Key] floatValue]) && [[_prodKeyValueCacheDataDic objectForKey:item7Key] floatValue] != 0)
                {
                    [self resetTextFielWithCurrentTextField:textFielditem7 andRelationTextField:textFielditem8 fromItem3:YES];
                    //更新缓存字典里的数据信息
                    [self resetValueWithValue:textFielditem7.textField.text andItemKey:item7Key];
                  //  return;
                }
                
                //折扣率= 折扣价/单价
                CGFloat item8Value = [[_prodKeyValueCacheDataDic objectForKey:item7Key] floatValue]/[newValue floatValue];
                [self setDiscountRateTextWithText:item8Value andRelationTextField:textFielditem8 andItemKey:item8Key];
                
                colStr = @"item2";
            }
            else if ([colStr isEqualToString:@"item7"])
            {
                if ([[_prodKeyValueCacheDataDic objectForKey:item3Key] floatValue] == 0)
                {
                    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:@"请填写单价!" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                }
                
                //折扣价大于单价 重置折扣价 并提示
                if (([newValue floatValue] > [textFielditem3.textField.text floatValue]) &&[[_prodKeyValueCacheDataDic objectForKey:item3Key] floatValue] != 0)
                {
                    [self resetTextFielWithCurrentTextField:textFielditem7 andRelationTextField:textFielditem8 fromItem3:NO];
                    //  YIHAIKERRY-1556 益海嘉里-上海：订单：总计金额与产品金额不一致
                    // return;
                }
                //折扣率= 折扣价/单价
                CGFloat item8Value = [newValue floatValue]/[[_prodKeyValueCacheDataDic objectForKey:item3Key] floatValue];
                [self setDiscountRateTextWithText:item8Value andRelationTextField:textFielditem8 andItemKey:item8Key];
                
                colStr = @"item9";
            }
            else if ([colStr isEqualToString:@"item9"])
            {
                colStr = @"item7";
            }
            NSString *relationColValueStr = [_prodKeyValueCacheDataDic objectForKey:[NSString stringWithFormat:@"%@_%@", prodIdStr, colStr]];
            
            if (!currentValueStr || [currentValueStr isEqualToString:@""])
            {
                currentValueStr = @"0";
            }
            
            if (!relationColValueStr || [relationColValueStr isEqualToString:@""])
            {
                relationColValueStr = @"0";
            }
            
            [self calcTotalCountByChangeCol:colStr prodIdStr:prodIdStr relationColValueStr:relationColValueStr oldValue:currentValueStr newValue:newValue];
        }
        else if ([colStr isEqualToString:@"item8"] && [newValue floatValue] <= 1)
        {
            [self setViewArrayWithIsResetValue:YES];

            //如果单价有值 根据单价 和 折扣率 计算折扣价
            if ([textFielditem3.textField.text floatValue] > 0)
            {
                NSString *item7OldValue = [_prodKeyValueCacheDataDic objectForKey:[NSString stringWithFormat:@"%@_%@", prodIdStr, @"item7"]];

                CGFloat item7Value = [textFielditem3.textField.text floatValue]*[newValue floatValue];
                [self setTextFieldTextWithText:item7Value andRelationTextField:textFielditem7 andItemKey:item7Key];
                
                NSString *relationColValueStr = [_prodKeyValueCacheDataDic objectForKey:[NSString stringWithFormat:@"%@_%@", prodIdStr, @"item9"]];
                NSString *item7NewValue = [_prodKeyValueCacheDataDic objectForKey:[NSString stringWithFormat:@"%@_%@", prodIdStr, @"item7"]];
                
                [self calcTotalCountByChangeCol:@"item7" prodIdStr:prodIdStr relationColValueStr:relationColValueStr oldValue:item7OldValue newValue:item7NewValue];

            }
            else
            {
                NSString *item3OldValue = [_prodKeyValueCacheDataDic objectForKey:[NSString stringWithFormat:@"%@_%@", prodIdStr, @"item3"]];

                //如果单价没有值 根据 折扣价 和 折扣率 计算单价
                CGFloat item3Value = [textFielditem7.textField.text floatValue]/[newValue floatValue];
                [self setTextFieldTextWithText:item3Value andRelationTextField:textFielditem3 andItemKey:item3Key];
                
                NSString *relationColValueStr = [_prodKeyValueCacheDataDic objectForKey:[NSString stringWithFormat:@"%@_%@", prodIdStr, @"item2"]];
                NSString *item3NewValue = [_prodKeyValueCacheDataDic objectForKey:[NSString stringWithFormat:@"%@_%@", prodIdStr, @"item3"]];
                
                [self calcTotalCountByChangeCol:@"item3" prodIdStr:prodIdStr relationColValueStr:relationColValueStr oldValue:item3OldValue newValue:item3NewValue];

            }
        }
        
        NSString *itemValue = [_prodKeyValueCacheDataDic objectForKey:item8Key];
        
        if (!itemValue || [itemValue isEqualToString:@""])
        {
            itemValue = @"0";
            [_prodKeyValueCacheDataDic setObject:itemValue forKey:item8Key];
        }
        
        //如果没有上次单价给上次单价设置默认值
        NSString *item1Value = [_prodKeyValueCacheDataDic objectForKey:item1Key];
        
        if (!item1Value || [item1Value isEqualToString:@""])
        {
            item1Value = @"0";
            [_prodKeyValueCacheDataDic setObject:item1Value forKey:item1Key];
        }
    }
}

- (void)setViewArrayWithIsResetValue:(BOOL)isResetValue {
    for (NSString *itemKey in keyArray) {
        
        NSString *itemValue = [_prodKeyValueCacheDataDic objectForKey:itemKey];
        
        if (!itemValue || [itemValue isEqualToString:@""])
        {
//            itemValue = @"0";
        }
        if (isResetValue) {
            [_prodKeyValueCacheDataDic setObject:[NSString stringNotNilWithValue:itemValue] forKey:itemKey];
        }
        [valueArray addObject:[NSString stringNotNilWithValue:itemValue]];
    }
}

// YIHAIKERRY-1592 item8 变化需要重新计算价格
- (void)calcTotalCountByChangeCol:(NSString *)colStr
                        prodIdStr:(NSString *)prodIdStr
              relationColValueStr:(NSString *)relationColValueStr
                         oldValue:(NSString *)oldValue
                         newValue:(NSString *)newValue {
    
    //total所有订单的总价
//    double total = [_totalCountStr doubleValue];
    
    // YIHAIKERRY-2107 加入兼容超出double类型所表示的数值
    NSDecimalNumber *totalPrice = [NSDecimalNumber decimalNumberWithString:_totalCountStr];
    
    double prodTotal = 0.0;//每一个商品的的折扣总价+正常总价
    
    //子总价=子数量*子单价   每相邻的两个object 一个是子数量 一个是子单价 作为一个计算单位,所以valueArray的count除以2  就是一共有多少个需要计算的 子总价 所有子总价的和就是当前产品的总价
    for (int i = 0; i < valueArray.count/2; i++) {
        prodTotal += [[valueArray objectAtIndex:i*2] doubleValue] *[[valueArray objectAtIndex:i*2+1] doubleValue];
    }
    
    
    //全局旧的总价 减掉当前商品的旧的总价
//    total -= prodTotal;
    totalPrice = [totalPrice decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f", prodTotal]]];
    
    //当前商品 减掉 旧的正常总价/旧的折扣总价  +(加上) 改变后的 新的正常总价/新的折扣总价 ===  等于发生改变后的当前商品总价
    prodTotal -= [relationColValueStr doubleValue] * [oldValue doubleValue];
    prodTotal += [relationColValueStr doubleValue] * [newValue doubleValue];
    
    //全局总价 加上当前商品当前的总价
//    total += prodTotal;
    
    totalPrice = [totalPrice decimalNumberByAdding:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f", prodTotal]]];
    
//    _totalCountStr = [NSString stringWithFormat:@"%.2f", total];
    _totalCountStr = [self notRounding:[NSString stringWithFormat:@"%@", totalPrice] afterPoint:2];
}

// 处理NSDecimalNumber类型总价的小数位显示
-(NSString *)notRounding:(NSString*)price afterPoint:(NSInteger)position
{
    
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
    
    NSDecimalNumber *ouncesDecimal;
    
    NSDecimalNumber *roundedOunces;

    //    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:price];
    
    ouncesDecimal = [[NSDecimalNumber alloc] initWithString:price];
    
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    
    //    return roundedOunces;// 整数的不带小数点
    
    NSString* string = [NSString stringWithFormat:@"%@",roundedOunces];
    
    if ([string rangeOfString:@"."].length==0) {
        
        string=  [string stringByAppendingString:@".00"];

    }else{
        
        NSRange range = [string rangeOfString:@"."];
        
        if (string.length-range.location-1==2) {

        }else{
            string=   [string stringByAppendingString:@"0"];
        }
    }

    return string;//整数.00格式
}

//更新价格
- (void)setTextFieldTextWithText:(CGFloat)textStr andRelationTextField:(WSNumberTextFiledPanel *)relationTextField andItemKey:(NSString *)itemKey
{
    if (textStr > 0)
    {
        relationTextField.textField.text = [NSString stringWithFormat:@"%.2f", textStr];
    }
    else
    {
        relationTextField.textField.text = @"";
    }
    [self resetValueWithValue:relationTextField.textField.text andItemKey:itemKey];
}

//更新折扣率数值
- (void)setDiscountRateTextWithText:(CGFloat)textStr andRelationTextField:(WSNumberTextFiledPanel *)relationTextField andItemKey:(NSString *)itemKey
{
    if (textStr >= 0 && textStr <=1)
    {
        relationTextField.textField.text = [NSString stringWithFormat:@"%.4f", textStr];
    }
    else
    {
        relationTextField.textField.text = @"";
    }
    [self resetValueWithValue:relationTextField.textField.text andItemKey:itemKey];
}

- (void)resetTextFielWithCurrentTextField:(WSNumberTextFiledPanel *)currentTextField andRelationTextField:(WSNumberTextFiledPanel *)relationTextField fromItem3:(BOOL)isItem3
{
    //修改单价时候  要是单价大于折扣不提示
    if (!isItem3)
    {
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:@"折扣价不能大于单价" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
    
//    currentTextField.textField.text = @"";
//    relationTextField.textField.text = @"";
    //更新缓存字典里的数据信息
    [self resetValueWithValue:currentTextField.textField.text andItemKey:[currentTextField.xbuildInfo getColKey]];
    [self resetValueWithValue:relationTextField.textField.text andItemKey:[relationTextField.xbuildInfo getColKey]];
}

- (void)resetValueWithValue:(NSString *)value andItemKey:(NSString *)itemKey
{
    [_prodKeyValueCacheDataDic setObject:[NSString stringNotNilWithValue:value] forKey:itemKey];
}

- (void)doHideHeaderViewUp
{
    CGRect headerViewFrame = _headerView.frame;
    headerViewFrame.origin.y = - headerViewFrame.size.height;
    [_headerView setFrame:headerViewFrame];
    
    CGRect prodGrideViewFrame = _prodGridView.frame;
    prodGrideViewFrame.origin.y = 0;
    [_prodGridView setFrame:prodGrideViewFrame];
    
}

- (void)doShowHeaderViewDown
{
    CGRect headerViewFrame = _headerView.frame;
    headerViewFrame.origin.y = 0;
    [_headerView setFrame:headerViewFrame];
    
    CGRect prodGrideViewFrame = _prodGridView.frame;
    prodGrideViewFrame.origin.y = headerViewFrame.size.height;
    [_prodGridView setFrame:prodGrideViewFrame];
}

- (void)calculateTotalCountWhenFirstShow
{
    NSMutableArray *prodIdStrMArray = [[NSMutableArray alloc] init];
    
    NSMutableArray *valueNeedCalculateColNameStrArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.currentFuncs.paramArray.count - 1; i ++) {
        WSFuncsBean_Param *colParam = [self.currentFuncs.paramArray objectAtIndex:i];
        if (![colParam.col isEqualToString:@"item1"] && ![colParam.col isEqualToString:@"item8"]) {
            [valueNeedCalculateColNameStrArray addObject:colParam.col];
        }
    }
    
    for (NSString *key in _prodKeyValueCacheDataDic.allKeys) {
        NSArray *keySegStr = [key componentsSeparatedByString:@"_"];
        NSString *prodIdStr = [keySegStr firstObject];
        NSString *colStr = [keySegStr lastObject];
        
        if ([valueNeedCalculateColNameStrArray containsObject:colStr]) {
            if ([prodIdStrMArray containsObject:prodIdStr]) {
                
            }else{
                NSString *currentColValueStr = [_prodKeyValueCacheDataDic objectForKey:[NSString stringWithFormat:@"%@_%@", prodIdStr, colStr]];
                
//                for ( WSFuncsBean_Param *colParam in self.currentFuncs.paramArray) {
                for (int i = 0; i < self.currentFuncs.paramArray.count - 1; i ++) {
                    WSFuncsBean_Param *colParam = [self.currentFuncs.paramArray objectAtIndex:i];
                    if (![colStr isEqualToString:colParam.col]) {
                        colStr = colParam.col;
                        break;
                    }
                }
                
                
                NSString *relationColValueStr = [_prodKeyValueCacheDataDic objectForKey:[NSString stringWithFormat:@"%@_%@", prodIdStr, colStr]];
                
                if (!currentColValueStr || [currentColValueStr isEqualToString:@""]) {
                    currentColValueStr = @"0";
                }
                
                if (!relationColValueStr || [relationColValueStr isEqualToString:@""]) {
                    relationColValueStr = @"0";
                }
                
                double total = [_totalCountStr doubleValue];
                
                total += [relationColValueStr floatValue] * [currentColValueStr floatValue];
                
                _totalCountStr = [NSString stringWithFormat:@"%.2f", total];
            }
            
            [prodIdStrMArray addObject:prodIdStr];
        }

    }
    
    NSLog(@"+++++++++++++++++++++++++_totalCountStr = %@", _totalCountStr);
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:_bgScrollView]) {

//        [self resetSubviewsFrame];
        
//        NSLog(@"@@@@@@@@@");
    }
}

- (void)viewDidLayoutSubviews
{
//    NSLog(@"@@@@@@@@@");

}

- (void)resetSubviewsFrame
{
/*
    if (_rightTableView.frame.size.height < _rightTableViewContentHeight) {
        CGRect rightTableFrame = _rightTableView.frame;
        rightTableFrame.size.height = _rightTableViewContentHeight;
        
        _rightTableView.frame = rightTableFrame;
    }else{
        _rightTableViewContentHeight = _rightTableView.contentSize.height;
        
        CGRect rightTableFrame = _rightTableView.frame;
        rightTableFrame.size.height = _rightTableViewContentHeight;
        
        _rightTableView.frame = rightTableFrame;
    }
    
    if (_leftTableView.frame.size.height < _leftTableViewContentHeight) {
        CGRect leftTableFrame = _leftTableView.frame;
        leftTableFrame.size.height = _leftTableViewContentHeight;
        
        _leftTableView.frame = leftTableFrame;
    }else{
        _leftTableViewContentHeight = _leftTableView.contentSize.height;
        CGRect leftTableFrame = _leftTableView.frame;
        leftTableFrame.size.height = _leftTableViewContentHeight;
        
        _leftTableView.frame = leftTableFrame;
    }
    
    CGFloat maxContentSizeHeight = _leftTableViewContentHeight > _rightTableViewContentHeight ? _leftTableViewContentHeight : _rightTableViewContentHeight;
    
    if (maxContentSizeHeight + _headerView.frame.size.height > _bgScrollViewContentHeight) {
        _bgScrollViewContentHeight = maxContentSizeHeight + _headerView.frame.size.height;
    }
    
    if (_bgScrollView.contentSize.height < _bgScrollViewContentHeight) {
        CGSize bgScrollViewSize = _bgScrollView.contentSize;
        bgScrollViewSize.height = _bgScrollViewContentHeight;
        
        _bgScrollView.contentSize = bgScrollViewSize;
    }
*/
}

- (void)upload
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    //上传前判断

    if (_prodKeyValueCacheDataDic == nil || _prodKeyValueCacheDataDic.allKeys.count == 0) {
        NSString* title = NSLocalizedString(@"页面无产品", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    //    }
    
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"正在上传...", nil)  tips:NSLocalizedString(@"请稍等", nil) tapTarget:self action:nil];
    
    [self performSelector:@selector(doUpload) withObject:nil afterDelay:0.01];
    
}

- (void)doUpload
{
    
    NSDate *before = [NSDate date];
    if (![self uploadDatas]) {
        [self showDBErrorTipAndHidAllHud];
        return;
    }
    
    NSDate *after2 = [NSDate date];
    LogInfo(@"uploadDatas耗时：%f秒", [after2 timeIntervalSinceDate:before]);
    
//    if (![self uploadPhotos]) {
//        [self showDBErrorTipAndHidAllHud];
//        return;
//    }
    [super uploadVisitAction];
    NSDate *after3 = [NSDate date];
    LogInfo(@"uploadPhotos耗时：%f秒", [after3 timeIntervalSinceDate:after2]);
    
    LogInfo(@"doUpload耗时：%f秒", [after3 timeIntervalSinceDate:before]);
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    NSString *tip = NSLocalizedString(@"已进入上传队列", nil);
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tip tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
    
    [self backToParent];
}

-(BOOL)uploadDatas{
//    LogTrace();
//    
//    // Get other view info
//    
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    
    
    BOOL hasPhoto = NO;
    
    NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
//
    NSString *postData =[WSJSONBuilder buildProdGrideDataByFc:self.currentFuncs.fc fv:self.currentFuncs.fv isPhoto:hasPhoto dataArray:[self getRequestParamArray] Store:self.currentStore md5:self.md5 memo:nil otherInfo:nil];
    
    
    BOOL insertPhotoDataIsSucceed = [self insertUploadData:postData URL:URL_UPLOAD MD5:self.md5 IsPhoto:hasPhoto NotifyName:notifyID];
    
    if (!insertPhotoDataIsSucceed) {
        return insertPhotoDataIsSucceed;
    }
    _insertFptIsSucceed = YES;
    [self insertProdDataWithIsAlterDB:YES];
    if (!_insertFptIsSucceed) {
        return NO;
    }
    
    [uploadMgr postRequestAcvtData:postData
                        notifyName:notifyID
                               md5:self.md5
              isSynchronizeRequest:NO];
    
    return YES;
}

- (NSArray *)getRequestParamArray
{
    NSMutableArray *paramArray = [[NSMutableArray alloc] init];
    
//    [self addRelationParamColValueToCacheDic];
    
    NSArray *allKeyArray = [_prodKeyValueCacheDataDic allKeys];
    
    for (NSString *key in allKeyArray) {
        NSArray *array = [key componentsSeparatedByString:@"_"];
        NSString *prodId = [array firstObject];
        
        NSMutableArray *tempParamKeyMArray = [[NSMutableArray alloc] init];
        
        for (NSString *key in allKeyArray) {
            if ([key hasPrefix:prodId]) {
                [tempParamKeyMArray addObject:key];
            }
        }
        
        NSMutableDictionary *tempParamMDic = [[NSMutableDictionary alloc] init];
        
        for (NSString *key in tempParamKeyMArray) {
            NSArray *array = [key componentsSeparatedByString:@"_"];
            NSString *prodId = [array firstObject];
            
            [tempParamMDic setObject:[NSString stringWithFormat:@"%@@null", prodId] forKey:@"prodId"];
            NSString *itemValueStr = [_prodKeyValueCacheDataDic objectForKey:key];
            if (itemValueStr.length > 0) {
                [tempParamMDic setObject:itemValueStr forKey:[array lastObject]];
            }
        }
        
        if ([paramArray containsObject:tempParamMDic]) {
            
        }else
            [paramArray addObject:tempParamMDic];
        
    }
    
    
    
    return paramArray;
}

// 益海嘉里个性化需求，关联单价与上次单价的值并上传入库
- (void)addRelationParamColValueToCacheDic
{
    NSArray *allKeyArray = [_prodKeyValueCacheDataDic allKeys];
    
    for (NSString *key in allKeyArray) {
        NSArray *array = [key componentsSeparatedByString:@"_"];
        NSString *prodId = [array firstObject];
        NSString *colName = [array lastObject];
        
        NSString *relationParamColKey = nil;
        
        for (WSFuncsBean_Param *param in self.currentFuncs.paramArray) {
            
            if ([param.col isEqualToString:colName]) {
                if (param.ids && param.ids.length > 0) {
                    relationParamColKey = [NSString stringWithFormat:@"%@_%@", prodId, param.ids];
                    [_prodKeyValueCacheDataDic setObject:[_prodKeyValueCacheDataDic objectForKey:key] forKey:relationParamColKey];
                }
            }
            break;
        }
    }
}


-(void)insertProdDataWithIsAlterDB:(BOOL)isAlterDB
{
    if(!([self.currentFuncs.ds isEqualToString:DS_PROD] || [self.currentFuncs.ds isEqualToString:DS_PRODC]))
        return;
    NSMutableArray *proValues=[[NSMutableArray alloc]init];
    //产品数量
    
    NSInteger prodCount = [[self getRequestParamArray] count];
    
    
    for(int i = 0 ; i < prodCount; i++)
    {

        NSString *allColsInTableStr = @"IDX,PROD_ID,DIST,PRI,INV,AGING,DISP,SDISP,CMPT,OOS,MTD,ORD,GOFA,OTHERDICTS,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,ITEM10,ITEM11,ITEM12,ITEM13,ITEM14,ITEM15,ITEM16,ITEM17,ITEM18,ITEM19,ITEM20,ITEM21,ITEM22,ITEM23,ITEM24,ITEM25,ITEM26,ITEM27,ITEM28,ITEM29,ITEM30,ITEM31,ITEM32,ITEM33,ITEM34,ITEM35,ITEM36,ITEM37,ITEM38,ITEM39,ITEM40,ITEM41,ITEM42,ITEM43,ITEM44,ITEM45,ITEM46,ITEM47,ITEM48,ITEM49,ITEM50";
        
        NSString *allColsInTableLowStr = [allColsInTableStr lowercaseString];
        
        NSArray *allColsInTableArray = [allColsInTableLowStr componentsSeparatedByString:@","];
        
        NSDictionary *paramDic = [[self getRequestParamArray] objectAtIndex:i];
        
        
        for (int j = 0 ; j < [[paramDic allKeys] count]; j++) {
            NSMutableArray* prodRow = [[NSMutableArray alloc] init];
            BOOL isInsert = NO;
            //idx
            [prodRow addObject:self.md5];
            
            NSArray *prodStrSegArray = [[paramDic objectForKey:@"prodId"] componentsSeparatedByString:@"@"];
            
            //prod_id
            [prodRow addObject:[NSString stringNotNilWithValue:[prodStrSegArray firstObject]]];
            
            NSString *key = [[paramDic allKeys] objectAtIndex:j];
            
            if ([allColsInTableArray containsObject:key]) {
                NSInteger index = [allColsInTableArray indexOfObject:key];
                
                if (index > 0) {
                    //ui的行
                    for(int m = 0 ; m < 62 ; m++)
                    {
                        [prodRow addObject:@"null"];
                    }
                    
                    [prodRow removeObjectAtIndex:index];
                    [prodRow insertObject:[paramDic objectForKey:key] atIndex:index];
                    isInsert = YES;
                }
                
                if (isInsert) {
                    [proValues addObject:prodRow];
                }

            }
            
            
        }
        
        
    }
    
    //fpt
    NSString *title = @"null";
    NSNumber* isPlan = [NSNumber numberWithBool:self.currentStore.plan];
    NSMutableArray *fptValues = [[NSMutableArray alloc] init];
    
    // FUNC_CODE
    NSString *fc = self.currentFuncs.fc;
    fc = [fc isKindOfClass:[NSString class]] ? fc : @"null";
    [fptValues addObject:fc];
    
    // FUNC_VIEW
    NSString *fv = self.currentFuncs.fv;
    fv = [fv isKindOfClass:[NSString class]] ? fv : @"null";
    [fptValues addObject:fv];
    
    // IS_PLANED
    NSString *isPlane = [isPlan stringValue];
    isPlane = [isPlane isKindOfClass:[NSString class]] ? isPlane : @"null";
    [fptValues addObject:isPlane];
    
    // ORG_ID
    [fptValues addObject:@"null"];
    
    // STORE_ID
    NSString *storeid = ((self.currentStore != nil) ? self.currentStore.Id : @"");
    storeid = [storeid isKindOfClass:[NSString class]] ? storeid : @"null";
    [fptValues addObject:storeid];
    
    // EMP_ID
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    empId = [empId isKindOfClass:[NSString class]] ? empId : @"null";
    [fptValues addObject:empId];
    
    // BIZ_DATE
    NSString *bizDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    bizDate = [bizDate isKindOfClass:[NSString class]] ? bizDate : @"null";
    [fptValues addObject:bizDate];
    
    // UPLOAD_DATE
    NSString *uploadDate = [WSCurrentTime getDateString];
    uploadDate = [uploadDate isKindOfClass:[NSString class]] ? uploadDate : @"null";
    [fptValues addObject:uploadDate];
    
    // UPLOAD_FLAG
    [fptValues addObject:@"0"];
    
    // IMG_IDX
    NSString *md5 = self.md5;
    md5 = [md5 isKindOfClass:[NSString class]] ? md5 : @"null";
    [fptValues addObject:md5];
    
    NSString *srid = @"null";
    if (self.currentStore
        && self.currentStore.srid
        && [self.currentStore.srid length] > 0) {
        srid = [self.currentStore.srid copy];
    }
    // SR_ID
    [fptValues addObject:srid];
    

    NSString *memo = @"null";

    [fptValues addObject:memo];
    
    // MEMO1 ~ MEMO10
    for (int i = 0; i < 10; i++) {
        NSString *memoi = @"null";
        [fptValues addObject:memoi];
    }
    
    //title
    [fptValues addObject:title];
    
    //title
    
    if (isAlterDB) {
        BOOL insertFptDataIsSucceed = [[WSFptTable sharedTable] insertWithFptArray:fptValues product:proValues isClear:NO];
        if (!insertFptDataIsSucceed) {
            _insertFptIsSucceed = insertFptDataIsSucceed;
        }
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self addKeyboardNotificationObserver];
    

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self removeKeyboardNotificationObserver];
}

- (void)addKeyboardNotificationObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardNotificationObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"keyboardWillShown" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"keyboardWillHidden" object:nil];
}

#pragma mark - keyboard show and hiden
-(void) keyboardWillShown:(NSNotification *) aNotification
{
    NSString *infoName = [aNotification name];
    NSDictionary* info = [aNotification userInfo];
    //kbSize即为键盘尺寸 (有width, height)
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;//得到键盘的高度
    
    [self doHideHeaderViewUp];

    if ([infoName isEqualToString:UIKeyboardWillShowNotification]) {
        CGRect prodGrideViewFrame = _prodGridView.frame;
        prodGrideViewFrame.size.height = self.view.frame.size.height - kbSize.height;
        
        [_prodGridView setFrame:prodGrideViewFrame];
        
        [self resetProdGrideViewSubviewsFrame];
    }
    
}

-(void)keyboardWillHidden:(NSNotification *) notif
{
    NSString *name = [notif name];
    
    [self doShowHeaderViewDown];
    
    if ([name isEqualToString:UIKeyboardWillHideNotification]) {
        CGRect prodGrideViewFrame = _prodGridView.frame;
        prodGrideViewFrame.size.height = self.view.frame.size.height - _headerView.frame.size.height - kToolBarView_Height;
        
        [_prodGridView setFrame:prodGrideViewFrame];
        
        [self resetProdGrideViewSubviewsFrame];
    }
}

- (void)resetProdGrideViewSubviewsFrame
{
    CGRect leftTableViewFrame = _leftTableView.frame;
    leftTableViewFrame.size.height = _prodGridView.frame.size.height;
    [_leftTableView setFrame:leftTableViewFrame];
    
    CGRect rightTableViewFrame = _rightTableView.frame;
    rightTableViewFrame.size.height = _prodGridView.frame.size.height;
    [_rightTableView setFrame:rightTableViewFrame];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

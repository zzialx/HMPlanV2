//
//  WSHOrderRelationView.m
//  WinSFA
//
//  Created by HZH on 2017/7/23.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSHOrderRelationView.h"
#import "WSHOrderCellModel.h"
#import "WSBaseProductDBService.h"
#import "WSHOrderTableViewCell.h"
#import "WSProdGrideWithExpandableBrandsViewController.h"
#import "WSHOrderRelationViewController.h"
#import "WSBaseDictsDBService.h"

#define hToolBarHeight 50.0
#define hCodeLabelHeaderViewHeight 0.0
#define hCodeLabelFontSize 12.0
#define hToolBarBtnWidth 80.0

@interface WSHOrderRelationView () <UITableViewDelegate, UITableViewDataSource>
{
    UIScrollView *_backgroundScrollView;
    UITableView *_tableView;
    NSMutableArray *_dataArray;
    UILabel *_codeLabel;
    UILabel *_totalCountLabel;
    NSMutableArray *keyArray;//需要计算总价的item的key集合
    NSMutableArray *valueArray;//需要计算总价的item的value集合
    NSMutableArray *itemArray;//顶部item集合
    CGFloat tableViewWidth;//tableView最终的宽度
}

@end

@implementation WSHOrderRelationView

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupViews];

        return self;
    }
    
    return nil;
}

- (id)initWithFrame:(CGRect)frame andFuncsBean:(WSFuncsBean *)funcsBean andDataCache:(NSDictionary *)dataCacheDic
{
    self = [super initWithFrame:frame];
    if (self) {
        
        keyArray = [NSMutableArray array];
        valueArray = [NSMutableArray array];
        itemArray = [NSMutableArray array];
        _funcsBean = funcsBean;
        _dataCacheDic = dataCacheDic;
        
        [self resetDataSource];
        [self setupViews];
        
        return self;
    }
    
    return nil;
}

- (void)resetDataSource
{
    [itemArray removeAllObjects];
    //过滤需要显示的title
    for (WSFuncsBean_Param *param in _funcsBean.paramArray) {
        if (![param.col isEqualToString:@"item1"]) {
            [itemArray addObject: param];
        }
        else
        {
           // YIHAIKERRY-1427 益海嘉里-上海：订单：订单确认页面缺少“上次单价”
            [itemArray insertObject:param atIndex:0];
        }
    }
    tableViewWidth = 10+(SCREEN_WIDTH - 60 - 150) + (itemArray.count +1)*50;

    _dataArray = [[NSMutableArray alloc] init];
    
    NSMutableArray *valueNeedCalculateColNameStrArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < _funcsBean.paramArray.count - 1; i ++) {
        WSFuncsBean_Param *colParam = [_funcsBean.paramArray objectAtIndex:i];
        [valueNeedCalculateColNameStrArray addObject:colParam.col];
    }
    
    NSMutableDictionary *dataCacheMDic = [[NSMutableDictionary alloc] initWithDictionary:_dataCacheDic];

    if (_dataCacheDic && _dataCacheDic.allKeys.count > 0) {
        
        NSMutableArray *prodIdStrMArray = [[NSMutableArray alloc] init];
        
        for (NSString *key in _dataCacheDic.allKeys) {
            
            NSArray *keySegStr = [key componentsSeparatedByString:@"_"];
            NSString *prodIdStr = [keySegStr firstObject];
            NSString *colStr = [keySegStr lastObject];
            
            if ([valueNeedCalculateColNameStrArray containsObject:colStr]) {
                if ([prodIdStrMArray containsObject:prodIdStr]) {
                    
                }else{
                    
                    /*对应列值得所需要的key*/
                    NSString *item2Key;//数量
                    NSString *item3Key;//单价
                    NSString *item8Key;//折扣率
                    NSString *item7Key;//折扣价
                    NSString *item9Key;//折扣数量
                    
                    double prodTotal = 0.0;//每一个商品的的折扣总价+正常总价
                    [keyArray removeAllObjects];
                    [valueArray removeAllObjects];
                    
                    for (int i = 0; i < _funcsBean.paramArray.count ; i ++) {
                        
                        //                for ( WSFuncsBean_Param *colParam in _funcsBean.paramArray) {
                        WSFuncsBean_Param *colParam = [_funcsBean.paramArray objectAtIndex:i];
                        
                        if ([colParam.col isEqualToString:@"item2"])
                        {
                            item2Key = [NSString stringWithFormat:@"%@_%@", prodIdStr, colParam.col];
                            [keyArray addObject:item2Key];
                        }
                        
                        if ([colParam.col isEqualToString:@"item3"])
                        {
                            item3Key = [NSString stringWithFormat:@"%@_%@", prodIdStr, colParam.col];
                            [keyArray addObject:item3Key];
                        }
                        
                        if ([colParam.col isEqualToString:@"item8"])
                        {
                            item8Key = [NSString stringWithFormat:@"%@_%@", prodIdStr, colParam.col];
                            [keyArray addObject:item8Key];
                        }
                        
                        if ([colParam.col isEqualToString:@"item7"])
                        {
                            item7Key = [NSString stringWithFormat:@"%@_%@", prodIdStr, colParam.col];
                            [keyArray addObject:item7Key];
                        }
                        
                        if ([colParam.col isEqualToString:@"item9"])
                        {
                            item9Key = [NSString stringWithFormat:@"%@_%@", prodIdStr, colParam.col];
                            [keyArray addObject:item9Key];
                        }
                    }
                    
                    for (NSString *itemKey in keyArray) {
                        WSFuncsBean_Param *colParam = nil;
                        
                        for (int i = 0; i < _funcsBean.paramArray.count ; i ++) {
                            NSArray *separateKeyStrArray = [itemKey componentsSeparatedByString:@"_"];
                            colParam = [_funcsBean.paramArray objectAtIndex:i];
                            if ([[separateKeyStrArray lastObject] isEqualToString:colParam.col]) {
                                
                                break;
                            }
                            
                        }

                        NSString *itemValue = [_dataCacheDic objectForKey:itemKey];
                        
                        if (!itemValue || [itemValue isEqualToString:@""])
                        {
                            itemValue = @"0";
                        }
                        
                        if (colParam.pcs.length > 0 && [colParam.pcs intValue] > 0) {
                            float itemFloatValue = [itemValue floatValue];
                            NSString *formatStirng = [NSString stringWithFormat:@"%%.%df", [colParam.pcs intValue]];
                            itemValue = [NSString stringWithFormat:formatStirng,itemFloatValue];
                        }

                        [valueArray addObject:itemValue];
                        [dataCacheMDic setObject:itemValue forKey:itemKey];
                    }
                    
                    //某一个商品  子总价=子数量*子单价   每相邻的两个object 一个是子数量 一个是子单价 作为一个计算单位,所以valueArray的count除以2  就是一共有多少个需要计算的 子总价 所有子总价的和就是当前产品的总价
//                    for (int i = 0; i < valueArray.count/2; i++) {
//                        prodTotal += [[valueArray objectAtIndex:i*2] floatValue] *[[valueArray objectAtIndex:i*2+1] floatValue];
//                    }
                    
                    // 金额=单价X数量+折扣价X折扣数
                    prodTotal = [[valueArray objectAtIndex:0] doubleValue] * [[valueArray objectAtIndex:1] doubleValue] + [[valueArray objectAtIndex:2] doubleValue] * [[valueArray objectAtIndex:4] doubleValue];
                    
                    NSString *totalCountStr = [NSString stringWithFormat:@"%.2f", prodTotal];
                    
                    NSMutableArray *paramValueMArray = [[NSMutableArray alloc] init];
                    
                    for ( WSFuncsBean_Param *colParam in _funcsBean.paramArray) {
                        if ([[dataCacheMDic allKeys] containsObject:[NSString stringWithFormat:@"%@_%@", prodIdStr, colParam.col]]) {
                            // YIHAIKERRY-1427 益海嘉里-上海：订单：订单确认页面缺少“上次单价”
                            if ([colParam.col isEqualToString:@"item1"]) {
                                [paramValueMArray insertObject:[dataCacheMDic objectForKey:[NSString stringWithFormat:@"%@_%@", prodIdStr, colParam.col]] atIndex:0];
                            }
                            else
                            {
                                [paramValueMArray addObject:[dataCacheMDic objectForKey:[NSString stringWithFormat:@"%@_%@", prodIdStr, colParam.col]]];
                            }
                        }
                    }
                    
                    WSHOrderCellModel *orderCellModel = [[WSHOrderCellModel alloc] init];
                    
                    orderCellModel.paramValueArray = paramValueMArray;
                    orderCellModel.totalStr = totalCountStr;
                    orderCellModel.prodBean = [self getProdBeanWithId:prodIdStr];
                    
                    BOOL needShowProdIfSumIsZero = [[_dataCacheDic objectForKey:item3Key] floatValue] != 0 && [[_dataCacheDic objectForKey:item9Key] floatValue] != 0;

                    // 第二页去除单价*数量=金额为空的产品
                    if ([totalCountStr floatValue] != 0 || needShowProdIfSumIsZero){
                        [_dataArray addObject:orderCellModel];
                    }
                    
                    [prodIdStrMArray addObject:prodIdStr];
                    
                }
            }
        }
    }

    [self reSortDataWithKnownRules];
    
    [_tableView reloadData];
}

// YIHAIKERRY-243 益海嘉里（上海）：订单确认页面需按照产品品类，品牌，产品名称进行排序
- (void)reSortDataWithKnownRules
{
    
    // 1.取出所有填写产品对应的系列seriesDic
    NSMutableArray *seriesDicMArray = [[NSMutableArray alloc] init];
    
    for (WSHOrderCellModel *model in _dataArray) {
        WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
        WSDictBean *prodSeriesDic = [service queryDictWithID:model.prodBean.series];
        
        BOOL isContainsSameDic = NO;
        
        for (WSDictBean *dic in seriesDicMArray) {
            if ([dic.Id isEqualToString:prodSeriesDic.Id]) {
                isContainsSameDic = YES;
                break;
            }
        }
        
        if (!isContainsSameDic) {

            [seriesDicMArray addObject:prodSeriesDic];
        }
    }

    // 2.系列seriesDic按系列名称进行排序
    NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch | NSNumericSearch |
    NSWidthInsensitiveSearch | NSForcedOrderingSearch;
    NSComparator sort = ^(WSDictBean *obj1,WSDictBean *obj2){
        NSRange range = NSMakeRange(0,obj1.name.length);
        return [obj1.name compare:obj2.name options:comparisonOptions range:range];
    };
    
    NSArray *sortedSeriesDicMArray = [seriesDicMArray sortedArrayUsingComparator:sort];
    
    // 3.seriesDic按系列顺序取出产品，每个系列并按名称进行排序
    NSMutableArray *reSortWithBrandMArray = [[NSMutableArray alloc] init];
    
    for (WSDictBean *dic in sortedSeriesDicMArray) {
        NSMutableArray *subReSortWithBrandMArray = [[NSMutableArray alloc] init];
        
        for (WSHOrderCellModel *model in _dataArray) {
            
            if ([model.prodBean.series isEqualToString:dic.Id]) {
                [subReSortWithBrandMArray addObject:model];
            }
        }
        
        NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch | NSNumericSearch |
        NSWidthInsensitiveSearch | NSForcedOrderingSearch;
        NSComparator sort = ^(WSHOrderCellModel *obj1,WSHOrderCellModel *obj2){
            NSRange range = NSMakeRange(0,obj1.prodBean.name.length);
            return [obj1.prodBean.name compare:obj2.prodBean.name options:comparisonOptions range:range];
        };
        
        NSArray *sortedWithProdNameSeriesDicMArray = [subReSortWithBrandMArray sortedArrayUsingComparator:sort];
        
        [reSortWithBrandMArray addObject:sortedWithProdNameSeriesDicMArray];
    }
    
    // 4.typeDic按品类顺序加入系列排序好的产品数组，组织成最后排好序的三维数组
    NSMutableArray *reSortTempMArray = [NSMutableArray arrayWithCapacity:[_prodFirstLevelTypesArray count]];
    
    for (WSDictBean *typeDic in _prodFirstLevelTypesArray) {
        
        NSMutableArray *subReSortTempMArray = [[NSMutableArray alloc] init];
        
        for (NSArray *subReSortWithBrandMArray in reSortWithBrandMArray) {
            
            if (subReSortWithBrandMArray && subReSortWithBrandMArray.count > 0) {
                
                WSHOrderCellModel *model = (WSHOrderCellModel *)[subReSortWithBrandMArray firstObject];
                WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
                WSDictBean *prodTypeDic = [service queryDictWithID:model.prodBean.series];

                if ([prodTypeDic.p isEqualToString:typeDic.Id]) {
                    [subReSortTempMArray addObject:subReSortWithBrandMArray];
                }

            }
        }
        
        [reSortTempMArray addObject:subReSortTempMArray];
    }
    
//    NSLog(@"------------reSortTempMArray = %@", reSortTempMArray);
    
    // 5.最后从排好序的三维数组里面取出所有产品
    NSMutableArray *finalSortedMArray = [[NSMutableArray alloc] init];
    
    for (NSArray *subReSortArray in reSortTempMArray) {
        for (NSArray *reSortWithBrandMArray in subReSortArray) {
            for (WSHOrderCellModel *model in reSortWithBrandMArray) {
                [finalSortedMArray addObject:model];
            }
        }
    }
    
    _dataArray = finalSortedMArray;
}

- (WSProdBean *)getProdBeanWithId:(NSString *)prodId
{
    WSBaseProductDBService *baseProductDBSerice = [[WSBaseProductDBService alloc] init];

    return [baseProductDBSerice queryProductByID:prodId];
}

- (void)setupViews
{
    CGRect scrollViewFrame = self.frame;
    scrollViewFrame.size.height = self.frame.size.height - hToolBarHeight;
    _backgroundScrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
    _backgroundScrollView.bounces = NO;
    _backgroundScrollView.showsHorizontalScrollIndicator = NO;
    _backgroundScrollView.contentSize = CGSizeMake(tableViewWidth, scrollViewFrame.size.height);
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, tableViewWidth, scrollViewFrame.size.height) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_backgroundScrollView addSubview:_tableView];
    [self addSubview:_backgroundScrollView];
    
    UIView *toolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - hToolBarHeight - 64, self.frame.size.width, hToolBarHeight)];
    toolBarView.backgroundColor = [UIColor whiteColor];
    
    _totalCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.frame.size.width - 10 - hToolBarBtnWidth*2, hToolBarHeight - 20)];
//
    [self setTotalCountLabelTextContent:[NSString stringWithFormat:@"总计:  ¥ 0.00"]];
    
    UIButton *orderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [orderBtn setFrame:CGRectMake(self.frame.size.width - hToolBarBtnWidth, 0, hToolBarBtnWidth, hToolBarHeight)];
    orderBtn.backgroundColor = [UIColor colorWithHexString:@"#fc0d1b"];
    orderBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    
    [orderBtn setTitle:@"确定下单" forState:UIControlStateNormal];
    [orderBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [orderBtn addTarget:self action:@selector(orderBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setFrame:CGRectMake(self.frame.size.width - hToolBarBtnWidth*2, 0, hToolBarBtnWidth, hToolBarHeight)];
    cancelBtn.backgroundColor = [UIColor colorWithHexString:@"#4fc377"];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    
    [cancelBtn setTitle:@"返回修改" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [toolBarView addSubview:_totalCountLabel];
    [toolBarView addSubview:orderBtn];
    [toolBarView addSubview:cancelBtn];
    
    [self addSubview:toolBarView];
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
    [hintString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range2];
    
    _totalCountLabel.attributedText = hintString;
}

- (void)orderBtnClicked:(id)sender
{
    
    if ([self.viewController isKindOfClass:[WSHOrderRelationViewController class]]) {
        WSHOrderRelationViewController *vc = (WSHOrderRelationViewController *)self.viewController;
        
        [vc doOrderAction];
    }
    
//    if ([self.viewController isKindOfClass:[WSProdGrideWithExpandableBrandsViewController class]]) {
//        WSProdGrideWithExpandableBrandsViewController *vc = (WSProdGrideWithExpandableBrandsViewController *)self.viewController;
//        
//        [vc upload];
//    }
}

- (void)cancelBtnClicked:(id)sender
{
    [self.viewController.navigationController popViewControllerAnimated:YES];
    
//    [UIView animateWithDuration:1.0 animations:^{
    
//        [self setFrame:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
//        [self removeFromSuperview];
        
//    } completion:^(BOOL finished) {
//        
//    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WSHOrderCellModel *orderCellModel = (WSHOrderCellModel *)[_dataArray objectAtIndex:indexPath.row];
    NSString *nameStr = orderCellModel.prodBean.name;
    
    CGSize prodNameSize = [nameStr ws_sizeWithFont:[UIFont systemFontOfSize:UI_Font] constrainedToWidth:self.frame.size.width - 170 lineBreakMode:NSLineBreakByCharWrapping];
    
    if (prodNameSize.height > 50) {
        return prodNameSize.height;
    }else
        return 50.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 24.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableViewWidth, 24.0)];
    UILabel *nameTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10 , hCodeLabelHeaderViewHeight, SCREEN_WIDTH - 60 - 150, headerView.height)];
    nameTitleLabel.font = [UIFont systemFontOfSize:hCodeLabelFontSize];
    nameTitleLabel.text = @"产品名称";
    nameTitleLabel.textColor = [UIColor darkGrayColor];
    [headerView addSubview:nameTitleLabel];
    
    for (int i = 0; i < itemArray.count; i++) {
        WSFuncsBean_Param *param = itemArray[i];
        UILabel *paramTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameTitleLabel.right+i*50, hCodeLabelHeaderViewHeight, 50, headerView.height)];
        paramTitleLabel.textAlignment = NSTextAlignmentCenter;
        paramTitleLabel.font = [UIFont systemFontOfSize:hCodeLabelFontSize];
        paramTitleLabel.text = param.name;
        paramTitleLabel.textColor = [UIColor darkGrayColor];
        [headerView addSubview: paramTitleLabel];
    }
    
    UILabel *totalTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(tableViewWidth-50, hCodeLabelHeaderViewHeight, 50, headerView.height)];
    totalTitleLabel.textAlignment = NSTextAlignmentCenter;
    totalTitleLabel.numberOfLines = 0;
    totalTitleLabel.font = [UIFont systemFontOfSize:hCodeLabelFontSize];
    totalTitleLabel.text = @"金额";
    totalTitleLabel.textColor = [UIColor darkGrayColor];
    [headerView addSubview:totalTitleLabel];
    
    _codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, hCodeLabelHeaderViewHeight)];
    _codeLabel.font = [UIFont systemFontOfSize:hCodeLabelFontSize];
    _codeLabel.textColor = [UIColor lightGrayColor];
    _codeLabel.backgroundColor = [UIColor colorWithHexString:@"0xf1f1f1"];
    
    headerView.backgroundColor = [UIColor colorWithHexString:@"0xf1f1f1"];
    
    //    [headerView addSubview:_codeLabel];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * reueserId = @"cellForLeftTable";
    WSHOrderTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:reueserId];
    if (cell == nil) {
        cell = [[WSHOrderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reueserId withTableViewWidth:tableViewWidth];
    }
    WSHOrderCellModel *orderCellModel = (WSHOrderCellModel *)[_dataArray objectAtIndex:indexPath.row];
    cell.orderCellModel = orderCellModel;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
 
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

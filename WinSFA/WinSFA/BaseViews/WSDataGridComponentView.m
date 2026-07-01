//
//  WSDataGridComponentView.m
//  WinSFA
//
//  Created by HZH on 2017/7/16.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSDataGridComponentView.h"
#import "WSDataGridCollectionViewCell.h"
#import "WSDataGridCollectionViewFlowLayout.h"
#import "WSAcvtBean_qst.h"
#import "YYModel.h"
#import "WSDataGridPartModel.h"
#import "WSNumberTextFiledPanel.h"

static NSString *const cellId = @"cellId";
static NSString *const headerId = @"headerId";
static NSString *const footerId = @"footerId";

@interface WSDataGridComponentView ()
{
    UIScrollView *_bgScrollView;
}
@property (nonatomic, strong) UICollectionViewFlowLayout *customLayout;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSMutableArray *colArray;

@end


@implementation WSDataGridComponentView

- (id)initWithFrame:(CGRect)aRect{
    self = [super initWithFrame:aRect];
    if(self != nil){
//        self.backgroundColor = [UIColor lightGrayColor];
       
//        [self setupDataGridUIWithFrame:aRect];
    }
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.size.width, self.size.height);
    
    return self;
}

- (id)initWithFrame:(CGRect)aRect andDataModel:(WSDataGridRightTableModel *)dataModel
{
    self = [super initWithFrame:aRect];
    if(self != nil){
//        self.backgroundColor = [UIColor lightGrayColor];
        
        self.dataModel = dataModel;
        _dataModel.gridColWidgetArray = [NSMutableArray array];
        self.colArray = [NSMutableArray array];
        // 大屏幕手机如果右边表格的右边有空白，则统一将空白宽度加到第一列产品名称上
        CGFloat rightSpaceWidth = aRect.size.width - (_dataModel.firstColWidth + [self getAllColsTotalWidth]);
        
        if (rightSpaceWidth > 0) {
            _dataModel.firstColWidth = _dataModel.firstColWidth + rightSpaceWidth;
        }
        
        [self setupDataGridUIWithFrame:aRect andDataModel:dataModel];
    }
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.size.width, self.size.height);
    
    return self;
}

-(void)setupDataGridUIWithFrame:(CGRect)aRect andDataModel:(WSDataGridRightTableModel *)dataModel
{
    
    const NSInteger numberOfTableViewRows = dataModel.prodsArray.count + 1;
    const NSInteger numberOfCollectionViewCells = dataModel.gridColParamArray.count + 1;
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:numberOfTableViewRows];
    
    for (NSInteger tableViewRow = 0; tableViewRow < numberOfTableViewRows; tableViewRow++)
    {
        NSMutableArray *innerArray = [NSMutableArray arrayWithCapacity:numberOfCollectionViewCells];
        
        for (NSInteger collectionViewItem = 0; collectionViewItem < numberOfCollectionViewCells; collectionViewItem++)
        {
            WSDataGridPartModel *dataGridPartModel = [[WSDataGridPartModel alloc] init];
            
            dataGridPartModel.point_m = dataModel.topTypeIndex;
            dataGridPartModel.point_n = dataModel.secondTypeIndex;
            WSFuncsBean_Param *param;
            if (collectionViewItem > 0) {
                param = [dataModel.gridColParamArray objectAtIndex:collectionViewItem - 1];
            }
            
            if (tableViewRow == 0) {
                
                CGFloat itemWidth = 0.0;
//                CGFloat itemHeight = 44.0;
                
                NSString *itemNameStr = @"";
                
                if (collectionViewItem == 0) {
                    if (!dataModel.isNeedHideFirstColAndKeepBlank) {
                        itemNameStr = @"产品名称";
                    }
                    itemWidth = _dataModel.firstColWidth;
                }
                else
                {
                    itemNameStr = param.name;
                    itemWidth = [self getItemWidthWithParam:param];
                    //                    itemNameStr = @"单价(元)";
                }
                
                //                    if (collectionViewItem == 1){
                //                    WSFuncsBean_Param *param = [dataModel.gridColParamArray objectAtIndex:collectionViewItem - 1];
                //                    itemNameStr = param.name;
                //                    itemWidth = [self getItemWidthWithParam:param];
                ////                    itemNameStr = @"单价(元)";
                //                }else if (collectionViewItem == 2){
                //                    WSFuncsBean_Param *param = [dataModel.gridColParamArray objectAtIndex:collectionViewItem - 1];
                //                    itemNameStr = param.name;
                //                    itemWidth = [self getItemWidthWithParam:param];
                ////                    itemNameStr = @"数量";
                //                }

                NSString *jsonStr = [NSString stringWithFormat:@"{\"is_req\":0,\"acvtId\":\"FORMACVT@10\",\"qstId\":\"@2648@30197@memo10@5655@10\",\"qstCod\":\"memo10\",\"qstName\":\"%@\",\"readonly\":0,\"sort\":20,\"qstType\":\"L\",\"orientation\":1,\"acvtQstId\":\"@2648@30197@memo10@5655@10\"}", itemNameStr];
                WSAcvtBean_qst *acvtQst = [WSAcvtBean_qst yy_modelWithJSON:jsonStr];
                acvtQst.hiddenBottomline = @"1";
                
                dataGridPartModel.widgetType = @"dataHeadWidget";
                dataGridPartModel.acvtQst = acvtQst;
                dataGridPartModel.width = itemWidth;
//                dataGridPartModel.height = itemHeight;
                dataGridPartModel.height = 44.0;
                dataGridPartModel.hideTopLine = NO;
                dataGridPartModel.hideLeftLine = YES;
                
            }
            
            else if (tableViewRow != 0 && collectionViewItem == 0) {
                
                CGFloat itemWidth = _dataModel.firstColWidth;
                CGFloat itemHeight = 44.0;
                
                CGFloat cellRealHeight = [[_dataModel.gridComViewCellHeightArray objectAtIndex:tableViewRow - 1] floatValue];
                
                itemHeight = cellRealHeight;
                
                WSProdBean *prodBean = [dataModel.prodsArray objectAtIndex:tableViewRow - 1];
                NSString *itemStr = @"";
                
                if (!dataModel.isNeedHideFirstColAndKeepBlank) {
                    itemStr = prodBean.name;
                }
                
                
                NSString *jsonStr = [NSString stringWithFormat:@"{\"is_req\":0,\"acvtId\":\"FORMACVT@10\",\"qstId\":\"@2648@30197@memo10@5655@10\",\"qstCod\":\"memo10\",\"qstName\":\"%@\",\"readonly\":0,\"sort\":20,\"qstType\":\"L\",\"orientation\":1,\"acvtQstId\":\"@2648@30197@memo10@5655@10\"}", itemStr];
                
//                NSString *jsonStr = @"{\"is_req\":0,\"acvtId\":\"FORMACVT@10\",\"qstId\":\"@2648@30197@memo10@5655@10\",\"qstCod\":\"memo10\",\"qstName\":\"元宝\",\"readonly\":0,\"sort\":20,\"qstType\":\"L\",\"orientation\":1,\"acvtQstId\":\"@2648@30197@memo10@5655@10\"}";
                WSAcvtBean_qst *acvtQst = [WSAcvtBean_qst yy_modelWithJSON:jsonStr];
                acvtQst.hiddenBottomline = @"1";
                
                dataGridPartModel.acvtQst = acvtQst;
                dataGridPartModel.width = itemWidth;
                dataGridPartModel.height = itemHeight;
                dataGridPartModel.hideTopLine = NO;
                dataGridPartModel.hideLeftLine = YES;
                
            }
            else if (tableViewRow != 0 && collectionViewItem != 0) {
//                NSString *jsonStr = @"{\"qstType\":\"N\",\"is_req\":\"0\",\"isCoverNewId\":\"0\",\"acvtId\":50054,\"confirmPageShow\":\"0\",\"ishidden\":\"0\",\"qstCod\":\"memo16\",\"acvtQstId\":67067,\"qstName\":\"连锁店数量：\",\"mnum\":99999,\"hideQstName\":0,\"orientation\":1,\"isSupperLocalPhoto\":\"0\",\"qstId\":73082,\"mlen\":99999,\"isDefaultClick\":\"0\",\"isAcvtName\":\"0\",\"readonly\":\"0\",\"dlen\":2,\"is_not_water_mark\":\"0\",\"snum\":0,\"hideQstOptName\":0,\"isShowSplitLine\":\"0\"}";
                
//                NSString *jsonStr = @"{\"is_req\":0,\"acvtId\":\"FORMACVT@10\",\"qstId\":\"@2648@30197@memo10@5655@10\",\"qstCod\":\"memo10\",\"qstName\":\"元宝\",\"readonly\":0,\"sort\":20,\"qstType\":\"L\",\"orientation\":1,\"acvtQstId\":\"@2648@30197@memo10@5655@10\"}";
                
                WSProdBean *prodBean = [dataModel.prodsArray objectAtIndex:tableViewRow - 1];
                
                CGFloat itemWidth = 0.0;
                CGFloat itemHeight = 44.0;

                WSFuncsBean_Param *param = [dataModel.gridColParamArray objectAtIndex:collectionViewItem - 1];
                itemWidth = [self getItemWidthWithParam:param];
                
                CGFloat cellRealHeight = [[_dataModel.gridComViewCellHeightArray objectAtIndex:tableViewRow - 1] floatValue];
                
                itemHeight = cellRealHeight;
                
                WSAcvtBean_qst *acvtQst = [[WSAcvtBean_qst alloc] init];
                acvtQst.colKey = [NSString stringWithFormat:@"%@_%@", prodBean.Id, param.col];
                acvtQst.hiddenBottomline = @"1";
                acvtQst.qstName = param.name;
                acvtQst.qstType = @"N";
                acvtQst.is_req = @"0";
                acvtQst.acvtQstId = @"110111";
                acvtQst.qstId = @"210111";
                acvtQst.mlen = @"999999";
                acvtQst.mnum = @"999999";
                acvtQst.orientation = @"1";
                acvtQst.qstCod = @"memo21";
                acvtQst.dlen = param.pcs;
                
                NSString *keyStr = [NSString stringWithFormat:@"%@_%@", prodBean.Id, param.col];
                NSString *valueStr = [[dataModel prodKeyValueCacheDataDic] objectForKey:keyStr];
                
                
                
                if (valueStr && valueStr.length > 0 && ![valueStr isEqualToString:@"null"]) {
                    dataGridPartModel.valueStr = valueStr;
                }
                
                dataGridPartModel.acvtQst = acvtQst;
                dataGridPartModel.width = itemWidth;
                dataGridPartModel.height = itemHeight;
                dataGridPartModel.hideTopLine = NO;
                dataGridPartModel.hideLeftLine = NO;
            }
            
            dataGridPartModel.point_x = tableViewRow;
            dataGridPartModel.point_y = collectionViewItem;
            
            [innerArray addObject:dataGridPartModel];
        }
        
        [mutableArray addObject:innerArray];
    }
    
    
    
    
    self.dataArray = [NSArray arrayWithArray:mutableArray];
    
    [self loadCollectionView];

}

- (CGFloat)getItemWidthWithParam:(WSFuncsBean_Param *)param
{
    
    if (param.wcol > 0 ) {
        return param.wcol;
    }else{
        if (param.charNum && param.charNum.length > 0 && [param.charNum integerValue] > 0) {
            return [param.charNum integerValue] * DETAILSIZEWIDTH;
        }
    }
    
    return 0.0;
}

- (void)loadCollectionView
{
    
    _bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, _dataModel.gridComViewHeight + 5)];
    
    _customLayout = [[WSDataGridCollectionViewFlowLayout alloc] init]; // 自定义的布局对象
    //    _customLayout.sectionInset = UIEdgeInsetsMake(10, 10, 9, 10);
//    _customLayout.itemSize = CGSizeMake(44, 44);
    //    _customLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _customLayout.minimumInteritemSpacing = 0;
    _customLayout.minimumLineSpacing = 0;
    
//    _customLayout.sectionHeadersPinToVisibleBounds = NO;
    
    CGFloat collectionViewHeight = 0.0;
    
    if (_dataModel.prodsArray.count > 0) {
        collectionViewHeight = _dataModel.gridComViewHeight + 5;
    }
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, _dataModel.firstColWidth + [self getAllColsTotalWidth] + 100, collectionViewHeight) collectionViewLayout:_customLayout];
//    _collectionView.contentSize = CGSizeMake(_dataModel.firstColWidth + [self getAllColsTotalWidth] + 100, self.frame.size.height);
    _collectionView.contentSize = CGSizeMake(_dataModel.firstColWidth + [self getAllColsTotalWidth] + 100, collectionViewHeight);

    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    
//    scrollView.contentSize = _collectionView.contentSize;
    
    [_bgScrollView addSubview:_collectionView];
    
    [self addSubview:_bgScrollView];
    
    // 注册cell、sectionHeader、sectionFooter
    [_collectionView registerClass:[WSDataGridCollectionViewCell class] forCellWithReuseIdentifier:cellId];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerId];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerId];
}

- (CGFloat)getAllColsTotalWidth
{
    CGFloat allColsTotalWidth = 0.0;
    for (WSFuncsBean_Param *param in _dataModel.gridColParamArray) {
        allColsTotalWidth += [self getItemWidthWithParam:param];;
    }
    
    return allColsTotalWidth;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSLog(@"----------WSDataGridComponentView.frame.size.width = %.1f   height = %.1f", self.frame.size.width, self.frame.size.height);
    NSLog(@"----------scrollview.frame.size.width = %.1f   height = %.1f", self.frame.size.width, self.frame.size.height);
    NSLog(@"----------WSDataGridComponentView.contentSize.width = %.1f   height = %.1f", _collectionView.contentSize.width, _collectionView.contentSize.height);
    NSLog(@"----------WSDataGridComponentView.frame.size.width = %.1f   height = %.1f", _collectionView.frame.size.width, _collectionView.frame.size.height);
    _bgScrollView.contentSize = CGSizeMake(_dataModel.firstColWidth + [self getAllColsTotalWidth], _dataModel.gridComViewHeight + 5);
    
}

- (void)setGridBecomeFirstResponder {
    // SFA-20258 鉴于现在控件都是写死的情况下，所以焦点也写死使用 IndexPath 1-1
    if (_dataArray.count > 1) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
        WSDataGridCollectionViewCell *cell = (WSDataGridCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
        [cell setTextFieldBecomeFirstResonder];
    }
}


#pragma mark ---- UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _dataArray.count;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *innerArray = (NSArray *)[_dataArray objectAtIndex:section];
    
    return innerArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WSDataGridCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    NSArray *innerArray = (NSArray *)[_dataArray objectAtIndex:indexPath.section];
    
    WSDataGridPartModel *dataGridModel = [innerArray objectAtIndex:indexPath.row];
    
    cell.model = dataGridModel;
    if (![_dataModel.gridColWidgetArray containsObject:[cell getWidget]] && [[cell getWidget] isKindOfClass:[WSNumberTextFiledPanel class]])
    {
        [_dataModel.gridColWidgetArray  addObject:[cell getWidget]];
    }
//    cell.backgroundColor = itemBackgroundColor;
    
    return cell;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionReusableView* reusableView;
    
    if (kind == UICollectionElementKindSectionHeader) {
        reusableView=[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerId forIndexPath:indexPath];
    }else if (kind == UICollectionElementKindSectionFooter) {
        reusableView=[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:footerId forIndexPath:indexPath];

    }
    
    reusableView.backgroundColor = [UIColor clearColor];
    
    return reusableView;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
//    if (section == 0) {
//        return CGSizeMake(self.frame.size.width, 1);
//    }else{
//        return CGSizeMake(self.frame.size.width, 1);
//    }
//}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
//        return CGSizeMake(_dataModel.firstColWidth, 44.0f);
        if (indexPath.row == 0) {
            return CGSizeMake(_dataModel.firstColWidth, 44.0f);
            
        }else{
            //        return CGSizeMake(100, 44.0f);
            WSFuncsBean_Param *param = [_dataModel.gridColParamArray objectAtIndex:indexPath.row - 1];
            return CGSizeMake([self getItemWidthWithParam:param], 44.0f);
        }
    }else{
        CGFloat cellRealHeight = [[_dataModel.gridComViewCellHeightArray objectAtIndex:indexPath.section - 1] floatValue];
        
        if (indexPath.row == 0) {
            //        return CGSizeMake(104.0f, 44.0f);
            return CGSizeMake(_dataModel.firstColWidth, cellRealHeight);
            
        }else{
            //        return CGSizeMake(100, 44.0f);
            WSFuncsBean_Param *param = [_dataModel.gridColParamArray objectAtIndex:indexPath.row - 1];
            return CGSizeMake([self getItemWidthWithParam:param], cellRealHeight);
        }
    }

}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (scrollView == self.collectionView)
//    {
//        CGFloat sectionHeaderHeight = 200; //sectionHeaderHeight
//        if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0) {
//            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
//        } else if (scrollView.contentOffset.y > sectionHeaderHeight) {
//            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
//        }
//    }
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

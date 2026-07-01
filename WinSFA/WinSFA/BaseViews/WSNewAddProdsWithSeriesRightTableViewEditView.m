//
//  WSNewAddProdsWithSeriesRightTableViewEditView.m
//  WinSFA
//
//  Created by zhangmin on 2018/11/7.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSNewAddProdsWithSeriesRightTableViewEditView.h"

#import "WSEditCollectionViewCell.h"
#import "WSEditCellBaseView.h"


#import "WSDataGridCollectionViewFlowLayout.h"
#import "WSAcvtBean_qst.h"
#import "YYModel.h"
#import "WSDataGridPartModel.h"
#import "WSNumberTextFiledPanel.h"



static NSString *const cellId = @"cellId";
static NSString *const headerId = @"headerId";
static NSString *const footerId = @"footerId";

@interface WSNewAddProdsWithSeriesRightTableViewEditView ()
{
    UIScrollView *_bgScrollView;
}
@property (nonatomic, strong) UICollectionViewFlowLayout *customLayout;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSMutableArray *colArray;

@end


@implementation WSNewAddProdsWithSeriesRightTableViewEditView

- (id)initWithFrame:(CGRect)aRect{
    self = [super initWithFrame:aRect];
    if(self != nil){
    }
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.size.width, self.size.height);
    
    return self;
}

- (id)initWithFrame:(CGRect)aRect andDataModel:(WSDataGridRightTableModel *)dataModel
{
    self = [super initWithFrame:aRect];
    if(self != nil){
        
        UIImageView * greyImage = [[UIImageView alloc]initWithFrame:CGRectMake(45, 0, 12, 6)];
        greyImage.image = [UIImage imageNamed:@"arrow_grey"];
        [self addSubview:greyImage];
        
        self.backgroundColor = [UIColor whiteColor];
        self.dataModel = dataModel;
        _dataModel.gridColWidgetArray = [NSMutableArray array];
        self.colArray = [NSMutableArray array];

        [self setupDataGridUIWithFrame:aRect andDataModel:dataModel];
    }
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.size.width, self.size.height);
    
    return self;
}

-(void)setupDataGridUIWithFrame:(CGRect)aRect andDataModel:(WSDataGridRightTableModel *)dataModel
{
    
    const NSInteger numberOfTableViewRows = dataModel.prodsArray.count;
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
            
            
            if ( collectionViewItem == 0) {
                
                CGFloat itemWidth = _dataModel.firstColWidth;
                CGFloat itemHeight = 44.0;
    
                CGFloat cellRealHeight = [[_dataModel.gridComViewCellHeightArray objectAtIndex:tableViewRow ] floatValue];
                
                itemHeight = cellRealHeight;
                
                WSProdBean *prodBean = [dataModel.prodsArray objectAtIndex:tableViewRow ];
                NSString *itemStr = @"";
                
                if (!dataModel.isNeedHideFirstColAndKeepBlank) {
                    itemStr = prodBean.name;
                }
                
                
                NSString *jsonStr = [NSString stringWithFormat:@"{\"is_req\":0,\"acvtId\":\"FORMACVT@10\",\"qstId\":\"@2648@30197@memo10@5655@10\",\"qstCod\":\"memo10\",\"qstName\":\"%@\",\"readonly\":0,\"sort\":20,\"qstType\":\"L\",\"orientation\":1,\"acvtQstId\":\"@2648@30197@memo10@5655@10\"}", itemStr];
                
                WSAcvtBean_qst *acvtQst = [WSAcvtBean_qst yy_modelWithJSON:jsonStr];
                acvtQst.hiddenBottomline = @"1";
                
                dataGridPartModel.acvtQst = acvtQst;
                dataGridPartModel.width = itemWidth;
                dataGridPartModel.height = itemHeight;
                dataGridPartModel.hideTopLine = NO;
                dataGridPartModel.hideLeftLine = YES;
                
            }
            else if ( collectionViewItem != 0) {
                
                
                WSProdBean *prodBean = [dataModel.prodsArray objectAtIndex:tableViewRow ];
                
                CGFloat itemWidth = 0.0;
                CGFloat itemHeight = 30;
                
                WSFuncsBean_Param *param = [dataModel.gridColParamArray objectAtIndex:collectionViewItem - 1];
                itemWidth = [self getItemWidthWithParam:param];
                
                CGFloat cellRealHeight = [[_dataModel.gridComViewCellHeightArray objectAtIndex:tableViewRow] floatValue];
                
                itemHeight = cellRealHeight;
                
                //88
                WSAcvtBean_qst *acvtQst = [[WSAcvtBean_qst alloc] initAcvtQstWithFuncsParam:param withAcvtId:[prodBean getDataItemID]];

                NSString *keyStr = [NSString stringWithFormat:@"%@_%@", prodBean.Id, param.col];
                NSString *valueStr = [[dataModel prodKeyValueCacheDataDic] objectForKey:keyStr];

                if (!valueStr || valueStr.length == 0 ) {
                    if (![acvtQst.qstType isEqualToString:@"N"] && ![acvtQst.defaultValue isEqualToString:@"0"]) {
                        // SFA-25311 todo SFA-立白-IOS-预设订单模板添加产品页面勾选产品，不应有默认值0 和安卓统一逻辑。数量这个框-在添加产品里面 以后设置默认值 将无效
                        valueStr = acvtQst.defaultValue;
                    }
                    
                }

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
            //添加产品页面编辑框 统一以右边talbeview的宽度来 设置子cell的宽度
            float rightTableWidth = SCREEN_WIDTH * 0.75;
            float widthPercent = [param.widthPercent floatValue];
            return widthPercent *(rightTableWidth-10) ;

        }
    }
    
    return 0.0;
}

- (void)loadCollectionView
{
    CGFloat topMargin = 6;
    CGFloat collectionViewHeight = _dataModel.gridComViewHeight - topMargin  ;

    _bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, topMargin, self.frame.size.width, collectionViewHeight )];
    _bgScrollView.backgroundColor = [UIColor colorWithHexString:@"0xeaebed"];
    
    _customLayout = [[WSDataGridCollectionViewFlowLayout alloc] init]; // 自定义的布局对象
    _customLayout.minimumInteritemSpacing = 0;
    _customLayout.minimumLineSpacing = 0;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, _dataModel.firstColWidth + [self getAllColsTotalWidth] + 100, collectionViewHeight ) collectionViewLayout:_customLayout];
    _collectionView.contentSize = CGSizeMake(_dataModel.firstColWidth + [self getAllColsTotalWidth] + 100, collectionViewHeight );
    
    _collectionView.backgroundColor = [UIColor colorWithHexString:@"0xeaebed"];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    
    [_bgScrollView addSubview:_collectionView];
    
    [self addSubview:_bgScrollView];
    
    // 注册cell
    [_collectionView registerClass:[WSEditCollectionViewCell class] forCellWithReuseIdentifier:cellId];
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
    _bgScrollView.contentSize = CGSizeMake(_dataModel.firstColWidth + [self getAllColsTotalWidth], _dataModel.gridComViewHeight + 5);
}

- (void)setGridBecomeFirstResponder {
    // SFA-24166 鉴于现在控件都是写死的情况下，所以焦点也写死使用 IndexPath 0-1
    if (_dataArray.count == 1) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        WSEditCollectionViewCell *cell = (WSEditCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
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
    WSEditCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    NSArray *innerArray = (NSArray *)[_dataArray objectAtIndex:indexPath.section];

    WSDataGridPartModel *dataGridModel = [innerArray objectAtIndex:indexPath.row];
    // SFA-27764 立白特殊处理。N类型的忽略默认值
    if ([[dataGridModel.acvtQst getAcvtQstType] isEqualToString:@"N"]) {
        dataGridModel.acvtQst.defaultValue = @"";
    }

    cell.model = dataGridModel;
    if (![_dataModel.gridColWidgetArray containsObject:[cell getWidget]] && [[cell getWidget] isKindOfClass:[WSNumberTextFiledPanel class]])
    {
        [_dataModel.gridColWidgetArray  addObject:[cell getWidget]];
    }

    return cell;
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{

        CGFloat cellRealHeight = [[_dataModel.gridComViewCellHeightArray objectAtIndex:indexPath.section] floatValue];
        
        if (indexPath.row == 0) {
            return CGSizeMake(_dataModel.firstColWidth, cellRealHeight);
            
        }else{
            WSFuncsBean_Param *param = [_dataModel.gridColParamArray objectAtIndex:indexPath.row - 1];
            return CGSizeMake([self getItemWidthWithParam:param], cellRealHeight);

        }

}

@end



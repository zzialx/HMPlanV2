//
//  WSOptionCollectionView.m
//  WinSFA
//
//  Created by wangzhiwei on 2018/1/23.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSOptionCollectionView.h"
#import "WSOptionCollectionViewCell.h"
@interface WSOptionCollectionViewCell()

@end
@implementation WSOptionCollectionView 
static NSString *const cellId = @"WSOptionCollectionViewCell";
- (instancetype)initWithFrame:(CGRect)frame andDataItems:(NSArray *)dataItems row:(NSInteger)row col:(NSInteger)col
{
    self = [super initWithFrame:frame];
    
    if (self) {

        self.dataItems=dataItems;
        return self;
    }
    
    return nil;
}


- (void)loadCollectionView
{


    //1.初始化layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //设置collectionView滚动方向
    //    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;


    //2.初始化collectionView
//    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
//    [self addSubview:_collectionView];
//    self.backgroundColor = [UIColor clearColor];

    //3.注册collectionViewCell
    //注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
    [self registerClass:[WSOptionCollectionViewCell class] forCellWithReuseIdentifier:cellId];


    //4.设置代理
    self.delegate = self;
    self.dataSource = self;

    //注册headerView  此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致  均为reusableView
    //    [mainCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"reusableView"];



}




#pragma mark collectionView代理方法
//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    
    return self.dataItems.count;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[self.dataItems objectAtIndex:section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    WSOptionCollectionViewCell *cell = (WSOptionCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
//    cell.isMultiseriate=_isMultiseriate;
//    NSObject<I_W_OptionDataItem> * dataItem =[[self.dataItems objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    NSString *optId = [dataItem getDataItemID];
//    cell.dataItem=dataItem;
//    NSInteger index =(indexPath.section*2)+indexPath.row;
//    cell.iconImageView.tag=index;
//    cell.button.tag=index;
   
    return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat w = (SCREEN_WIDTH/2)-86-(178/2);
    return CGSizeMake(90, 130);
}

//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 20;
}


//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 15;
}


#pragma mark -- 将数组拆分成固定长度
/**
 *  将数组拆分成固定长度的子数组
 *
 *  @param array 需要拆分的数组
 *
 *  @param subSize 指定长度
 *
 */
- (NSArray *)splitArray: (NSArray *)array withSubSize : (int)subSize{
    //  数组将被拆分成指定长度数组的个数
    unsigned long count = array.count % subSize == 0 ? (array.count / subSize) : (array.count / subSize + 1);
    //  用来保存指定长度数组的可变数组对象
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    //利用总个数进行循环，将指定长度的元素加入数组
    for (int i = 0; i < count; i ++) {
        //数组下标
        int index = i * subSize;
        //保存拆分的固定长度的数组元素的可变数组
        NSMutableArray *arr1 = [[NSMutableArray alloc] init];
        //移除子数组的所有元素
        [arr1 removeAllObjects];
        
        int j = index;
        //将数组下标乘以1、2、3，得到拆分时数组的最大下标值，但最大不能超过数组的总大小
        while (j < subSize*(i + 1) && j < array.count) {
            [arr1 addObject:[array objectAtIndex:j]];
            j += 1;
        }
        //将子数组添加到保存子数组的数组中
        [arr addObject:[arr1 copy]];
    }
    
    return [arr copy];
}



@end

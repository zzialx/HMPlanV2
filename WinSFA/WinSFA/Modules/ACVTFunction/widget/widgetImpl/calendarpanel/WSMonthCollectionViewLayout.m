//
//  WSMonthCollectionViewLayout.m
//  WinSFA
//
//  Created by heju on 15/4/21.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSMonthCollectionViewLayout.h"



#define MONTH_COLLECTION_VIEW_WIDTH (1024.0f - 200.0f -  (INTERFACE_IS_PHONE ? 0 : 15))
#define MONTH_COLLECTION_VIEW_HEIGHT (768.0f - 64.0f - 50.0f)
#define MONTH_COLLECTION_VIEW_SECTION_LEFT_MARGIN 10.0f
#define MONTH_COLLECTION_VIEW_SECTION_RIGHT_MARGIN 10.0f
#define MONTH_COLLECTION_VIEW_SECTION_TOP_MARGIN 0.0f
#define MONTH_COLLECTION_VIEW_SECTION_WIDTH (MONTH_COLLECTION_VIEW_WIDTH - (MONTH_COLLECTION_VIEW_SECTION_LEFT_MARGIN + MONTH_COLLECTION_VIEW_SECTION_RIGHT_MARGIN))

#define MONTH_COLLECTION_HEAD_VIEW_HEIGNT 43.0f
#define MONTH_COLLECTION_HEAD_VIEW_WIDTH MONTH_COLLECTION_VIEW_SECTION_WIDTH

#define MONTH_COLLECTION_VIEW_CELL_COLUM 7
#define MONTH_COLLECTION_VIEW_CELL_WIDTH  (MONTH_COLLECTION_VIEW_SECTION_WIDTH/MONTH_COLLECTION_VIEW_CELL_COLUM)


@implementation WSMonthCollectionViewLayout

/*
 返回内容大小，用于判断是否需要加快滑动
 */

-(CGSize)collectionViewContentSize
{
    CGSize tmpSize = CGSizeMake(MONTH_COLLECTION_VIEW_WIDTH, MONTH_COLLECTION_VIEW_HEIGHT);
    
    return tmpSize;
}



#pragma mark - UICollectionViewLayout
/*
  为每一个Item生成布局特性
 */
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    float x = MONTH_COLLECTION_VIEW_SECTION_LEFT_MARGIN + (indexPath.row%MONTH_COLLECTION_VIEW_CELL_COLUM)*MONTH_COLLECTION_VIEW_CELL_WIDTH;
    float y = MONTH_COLLECTION_VIEW_SECTION_TOP_MARGIN + MONTH_COLLECTION_HEAD_VIEW_HEIGNT + (indexPath.row/MONTH_COLLECTION_VIEW_CELL_COLUM)*self.cellHeight;
    if (indexPath.row == 0) {
        NSLog(@"0--%f",y);
    }
    if ( indexPath.row == 7) {
        NSLog(@"7--%f",y);
    }
    attributes.frame = CGRectMake(x, y, MONTH_COLLECTION_VIEW_CELL_WIDTH, self.cellHeight);
    return attributes;
}

/*
    UICollectionElementKindSectionHeader布局
 */

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes2 = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
    float x = MONTH_COLLECTION_VIEW_SECTION_LEFT_MARGIN;
    float y = MONTH_COLLECTION_VIEW_SECTION_TOP_MARGIN;
    attributes2.frame = CGRectMake(x, y, MONTH_COLLECTION_HEAD_VIEW_WIDTH, MONTH_COLLECTION_HEAD_VIEW_HEIGNT);
    return attributes2;
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *arr = [super layoutAttributesForElementsInRect:rect];
    if ([arr count] > 0) {
        return arr;
    }
    
    NSMutableArray *attributes = [NSMutableArray array];
    NSInteger sections = [self.collectionView numberOfSections];
    for (NSInteger i =0; i<sections; i++) {
        NSInteger currentCellCount = [self.collectionView numberOfItemsInSection:i];
        for (NSInteger j=0; j < currentCellCount; j++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
            if (j == 0) {
                [attributes addObject:[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath]];
            }
            [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
            
        }
    }
    return attributes;
}

@end

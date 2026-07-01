//
//  WSDropListButtonLayout.m
//  WinSFA
//
//  Created by Alicia on 2018/3/21.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSDropListButtonLayout.h"

@interface WSDropListButtonLayout()

@property (nonatomic, strong) NSArray *attrArray;

@end

@implementation WSDropListButtonLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}


- (void)prepareLayout {
    [super prepareLayout];
    
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:self.itemFrameArray.count];
    for (int i = 0; i < self.itemFrameArray.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        [tempArray addObject:attributes];
    }
    
    self.attrArray = tempArray;
}


- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attrArray;
}


- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    NSString *frameString = self.itemFrameArray[indexPath.row];
    attr.frame = CGRectFromString(frameString);
    return attr;
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.collectionView.size.width, self.collectionView.size.height);
}



@end

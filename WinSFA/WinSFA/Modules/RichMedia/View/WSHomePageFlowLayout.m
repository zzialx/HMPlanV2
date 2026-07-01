//
//  WSHomePageFlowLayout.m
//  WinSFA
//
//  Created by zhiqing on 16/8/30.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSHomePageFlowLayout.h"

@implementation WSHomePageFlowLayout
-(void)prepareLayout{
    [super prepareLayout];
    
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return YES;
    
}

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect{
    
    // 计算出整体的中心点x的值
    CGFloat centerX = self.collectionView.contentOffset.x + self.collectionView.bounds.size.width * 0.5;
    NSArray  *arrayAttrs = [super layoutAttributesForElementsInRect:rect];
    
    for (UICollectionViewLayoutAttributes * attr in arrayAttrs) {
        
        // 获取每个cell的中心点的x
        CGFloat cell_centerX = attr.center.x;
        
        // 计算两个中心点的x值的偏移
        CGFloat distance = ABS(cell_centerX - centerX);
        
        // 缩放系数
        CGFloat factor = 0.005;
        
        // 记录缩放比
        CGFloat scale = 1/(1 + distance* factor);
        
        attr.size = CGSizeMake(self.itemSize.width * 1.5, self.itemSize.height * 1.5);
        if (IOS7_OR_LATER) {
            attr.transform = CGAffineTransformMakeScale(scale, scale);
        }else{
            attr.transform3D = CATransform3DMakeScale(scale, scale, 1.0);
        }
       
    }
    
    
    return arrayAttrs;
    
}

@end


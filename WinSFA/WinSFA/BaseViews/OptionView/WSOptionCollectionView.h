//
//  WSOptionCollectionView.h
//  WinSFA
//
//  Created by wangzhiwei on 2018/1/23.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSOptionCollectionView : UICollectionView<UICollectionViewDataSource,UICollectionViewDelegate>
@property(nonatomic,copy) NSArray * dataItems;

- (instancetype)initWithFrame:(CGRect)frame andDataItems:(NSArray *)dataItems row:(NSInteger)row col:(NSInteger)col;

@end

//
//  WSAcvtTabCollectionView.h
//  WinSFA
//
//  Created by Alicia on 2018/1/25.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, WSAcvtTabStyle) {
    WSAcvtTabStyleSide,               // YIHAIKERRY-1141 样式
    WSAcvtTabStyleButton                // MN-267 样式
};

typedef void (^SelectedAcvtTab)(NSInteger index, WSAcvtTabStyle style);

@interface WSAcvtTabCollectionView : UICollectionView

@property (nonatomic, copy) SelectedAcvtTab selectedAcvtTabBlock;

- (instancetype)initWithFrame:(CGRect)frame titleArray:(NSArray *)titleArray style:(WSAcvtTabStyle)style;

- (void)setSelectedIndex:(NSInteger)selectedIndex;
@end

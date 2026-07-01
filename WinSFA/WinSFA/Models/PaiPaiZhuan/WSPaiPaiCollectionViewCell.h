//
//  WSPaiPaiCollectionViewCell.h
//  WinSFA
//
//  Created by zhangmin on 2019/12/10.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSAcvtListDataItem.h"


NS_ASSUME_NONNULL_BEGIN

@interface WSPaiPaiCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) WSAcvtListDataItem *model;//数据模型
@property (nonatomic, strong) UIImageView *bgIcon;      //背景图

- (void)setViewColorWithIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END

//
//  WSCollectionMVListCell.h
//  WinSFA
//
//  Created by Alicia on 17/1/14.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMBadgeView.h"

// TAB_MVListViewStyleHorizontal 时显示的 Cell
@interface WSCollectionMVListCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *mainTitleLabel;
@property (nonatomic, strong) CALayer *separatorLayer;
@property (nonatomic, strong) WSFuncsBean *funcsBean;
@property (nonatomic, assign) NSInteger badgeCount;
@property (nonatomic, strong) XMBadgeView *badgeView;

- (void)setTitle:(NSString *)title;

@end

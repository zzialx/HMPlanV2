//
//  WSProdGrideWithExpandableBrandsRightTableViewCell.h
//  WinSFA
//
//  Created by HZH on 2017/7/18.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSDataGridComponentView.h"

@interface WSProdGrideWithExpandableBrandsRightTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *itemImageView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIImageView  *indicatorImageView;
@property (nonatomic, assign) BOOL indicatorImageOpenedOrClosed;

@property (nonatomic, strong) UIView  *TopLineView;
@property (nonatomic, strong) UIView  *separatorLineView;

@property (nonatomic, strong) UIColor  *separatorLineColor;

@property (nonatomic, assign) CGFloat itemCellHeight;

@property (nonatomic, strong) WSDataGridComponentView *dataGridComponentView;


@end

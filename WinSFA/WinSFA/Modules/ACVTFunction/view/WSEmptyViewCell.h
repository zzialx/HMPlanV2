//
//  WSEmptyViewCell.h
//  WinSFA
//
//  Created by yuanji on 2018/1/20.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
//==========================================================================================================================================================

#pragma mark - 空视图单元格
@interface WSEmptyViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *iconImageView;   //图标视图
@property (nonatomic, strong) UILabel *label;               //标签

#pragma mark - 设置空视图单元格 funcsBean:功能块
- (void)setupEmptyViewCellFromFuncsBean:(WSFuncsBean *)funcsBean;

@end
//==========================================================================================================================================================

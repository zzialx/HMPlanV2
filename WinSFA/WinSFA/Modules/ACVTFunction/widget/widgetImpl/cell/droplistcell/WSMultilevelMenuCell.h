//
//  WSMultilevelMenuCell.h
//  WinSFA
//
//  Created by sunhf on 2018/1/15.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSMultilevelMenuCell : UITableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) WSDictBean *dictBean;
/*
 设置是否隐藏分割线,外部可控 默认NO
 */
@property (nonatomic, assign) BOOL isHiddenSeparatorLine;
//第一个层级的tableView需要特殊处理
@property (nonatomic, assign) BOOL isFirstTableView;

@end

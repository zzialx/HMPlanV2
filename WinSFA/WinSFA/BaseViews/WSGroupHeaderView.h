//
//  WSGroupHeaderView.h
//  WinSFA
//
//  Created by huzepei on 16/6/24.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WSProdBeanArray.h"
@class WSGroupHeaderView;

@protocol WSGroupHeaderViewDelegate <NSObject>

- (void)WSGroupHeaderViewDidClickBtn:(WSGroupHeaderView *)headerView;

- (void)WSGroupHeaderViewDidClickAllSelectedBtn:(WSGroupHeaderView *)headerView;

@end

@interface WSGroupHeaderView : UITableViewHeaderFooterView

@property (nonatomic, weak) id<WSGroupHeaderViewDelegate>delegate;
@property (nonatomic, strong) WSProdBeanArray *prodBeanArray;
@property (nonatomic, strong) UIButton *allSelectedBtn;

+ (instancetype)groupHeaderViewWithTableView:(UITableView *)tableView;

@end

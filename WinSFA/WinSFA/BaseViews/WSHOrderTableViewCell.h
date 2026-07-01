//
//  WSHOrderTableViewCell.h
//  WinSFA
//
//  Created by HZH on 2017/7/23.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSHOrderCellModel.h"

@interface WSHOrderTableViewCell : UITableViewCell
{
    CGFloat _tableViewWidth;
}
@property (nonatomic, strong) UILabel *nameTitleLabel;
@property (nonatomic, strong) UILabel *totalTitleLabel;
@property (nonatomic, strong) NSMutableArray *titleLabelArray;//放所有动态创建的Item
@property (nonatomic, strong) WSHOrderCellModel *orderCellModel;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTableViewWidth:(CGFloat)tableViewWidth;
@end


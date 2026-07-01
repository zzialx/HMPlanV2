//
//  WSHighFrequencySearchResultCell.h
//  WinSFA
//
//  Created by yuanji on 2018/11/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
//=====================================================================================================================================

#pragma mark - 高频搜索结果单元格
@interface WSHighFrequencySearchResultCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;      //标题标签
@property (nonatomic, strong) UIButton *deleteButton;   //删除按键
@property (nonatomic, strong) UIView *lineView;         //线视图

#pragma mark - 设置单元格数据方法 text:文本
- (void)setCellWithText:(NSString *)text;

@end
//=====================================================================================================================================

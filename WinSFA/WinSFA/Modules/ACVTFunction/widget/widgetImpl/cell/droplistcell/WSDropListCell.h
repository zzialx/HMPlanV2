//
//  WSDropListCell.h
//  WinSFA
//
//  Created by yang on 15/3/30.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol I_W_OptionDataItem;

@interface WSDropListCell : UITableViewCell

@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) UIImageView *markImageView;

@property (nonatomic, strong) UIImageView *selectedImageView;

@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, strong) NSObject<I_W_OptionDataItem> *dataItem;

@property (nonatomic, assign) BOOL isResetColor;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isMultiChoice:(BOOL)isMultiChoice;
- (void)setDataItem:(NSObject<I_W_OptionDataItem> *)dataItem isSelected:(BOOL)isSelected;

@end

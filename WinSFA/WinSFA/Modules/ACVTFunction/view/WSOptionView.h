//
//  WSOptionView.h
//  WinSFA
//
//  Created by yang on 15-3-25.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "I_W_OptionDataItem.h"

#define kOptionViewHeight      12

@class WSOptionView;

@protocol WSOptionViewDelegate <NSObject>

- (void)optionView:(WSOptionView *)optionView didClickItem:(NSObject<I_W_OptionDataItem> *)dataItem;

- (void)optionView:(WSOptionView *)optionView didClickItemImage:(UIImage *)image;

@end

@interface WSOptionView : UIView

@property (nonatomic, strong) NSObject<I_W_OptionDataItem> *dataItem;

@property (nonatomic, strong) UIButton *button;

@property (nonatomic, strong) UITextField *reasonTextField;

@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, weak) id<WSOptionViewDelegate> delegate;


- (instancetype)initWithFrame:(CGRect)frame andDataItem:(NSObject<I_W_OptionDataItem> *)dataItem withMultiseriate:(BOOL)isMultiseriate;

- (instancetype)initWithFrame:(CGRect)frame andDataItem:(NSObject<I_W_OptionDataItem> *)dataItem withMultiseriate:(BOOL)isMultiseriate isHideOptionnName:(BOOL)isHideOptionnName;

- (instancetype)initWithFrame:(CGRect)frame andDataItem:(NSObject<I_W_OptionDataItem> *)dataItem hasReason:(BOOL)hasReason readonly:(BOOL)isReadonly;

- (void)optionViewEnable:(BOOL)enable;


@end

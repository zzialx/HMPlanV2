//
//  WSBasePanel.h
//  WinSFA
//
//  Created by winchannel on 15/3/19.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSWidget.h"
#import <UIKit/UIKit.h>
#import "WSAcvtQstWidgetRelationTools.h"
#import "UIColor+Additions.h"




@interface WSBasePanel : WSWidget{
    
    UILabel  *titleLabel; //显示内容的标签
 
    
}

@property (nonatomic,strong) UILabel  *titleLabel; //显示内容标签

@property (nonatomic, strong) UIImageView *iconImageView; // 问题图标

@property (nonatomic, assign) BOOL isShowTitleLabel;


@property (nonatomic, strong) UIView  *bottomLineView; //底部线

/**
 * @brief 设置title的内容.
 *
 * @param titleContent NSString
 *
 * @return void.
 *
 */
- (void)setTitleContent:(NSString *)titleContent;

/**
 * @brief 设置title的对齐.
 *
 * @param align NSTextAlignment
 *
 * @return void.
 *
 */

- (void)setTitleLabelAlignment:(NSTextAlignment)align;

/**
 * @brief 设置title的位置及大小.
 *
 * @param frame CGRect
 *
 * @return void.
 *
 */

- (void)setTitleLabelFrame:(CGRect)frame;
/**
 * @brief 设置title的字体.
 *
 * @param font UIFont
 *
 * @return void.
 *
 */
- (void)setTitleLabelFont:(UIFont *)font;

/**
 * @brief 设置title的字体颜色.
 *
 * @param color UIColor
 *
 * @return void.
 *
 */
- (void)setTitleLabelColor:(UIColor *)color;

/**
 * @brief 设置Answer的字体颜色.
 *
 * @param color UIColor
 *
 * @return void.
 *
 */
- (void)setViewAnswerColor:(UIColor *)color;

/**
 * @brief 设置title的字体颜色字符串.
 *
 * @param colorStr UIColor
 *
 * @return void.
 *
 */
- (void)setTitleLabelColorStrByHex:(NSString *)colorStr;


/**
 * @brief 设置title的字体背景颜色.
 *
 * @param color UIColor
 *
 * @return void.
 *
 */
- (void)setTitleLabelBgColor:(UIColor *)color;

/**
 * @brief 设置title的字体背景颜色字符串.
 *
 * @param color UIColor
 *
 * @return void.
 *
 */
- (void)setTitleLabelBgColorStrByHex:(NSString *)color;

/**
 设置问题的icon为选择状态

 @param selected true or false   1  or 0
 */
-(void)setQstIconUrlSelected:(NSString *)selected;

@end

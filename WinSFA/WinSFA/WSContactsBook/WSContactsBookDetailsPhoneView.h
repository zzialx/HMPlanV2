//
//  WSContactsBookDetailsPhoneView.h
//  WinSFA
//
//  Created by yuanji on 2018/5/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^MessageClickBlock)(NSString *phone); //定义 短信点击闭包
typedef void (^PhoneClickBlock)(NSString *phone);   //定义 电话点击闭包
//===================================================================================================================================================================

#pragma mark - 通讯录详情电话视图
@interface WSContactsBookDetailsPhoneView : UIView

@property (nonatomic, copy) MessageClickBlock messageClickBlock;//短信点击闭包
@property (nonatomic, copy) PhoneClickBlock phoneClickBlock;    //电话点击闭包

#pragma mark - 更新视图方法 title:标题 content:内容 messageIcon:信息图标 phoneIcon:电话图标 isShowLine:是否显示线标示
- (void)updateViewWithTitle:(NSString *)title content:(NSString *)content messageIcon:(UIImage *)messageIcon phoneIcon:(UIImage *)phoneIcon isShowLine:(BOOL)isShowLine;

#pragma mark - 获取高度方法 title:标题 content:内容 messageIcon:信息图标 phoneIcon:电话图标 isShowLine:是否显示线标示 maxWidth:最大宽度
- (CGFloat)getHeightWithTitle:(NSString *)title content:(NSString *)content messageIcon:(UIImage *)messageIcon phoneIcon:(UIImage *)phoneIcon
                   isShowLine:(BOOL)isShowLine maxWidth:(CGFloat)maxWidth;

@end
//===================================================================================================================================================================

//
//  WSContactsBookDetailsTwoTitleView.h
//  WinSFA
//
//  Created by yuanji on 2018/5/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
//===================================================================================================================================================================

#pragma mark - 通讯录详情二个标题视图
@interface WSContactsBookDetailsTwoTitleView : UIView

#pragma mark - 更新视图方法 title:标题 content:内容 isShowLine:是否显示线标示
- (void)updateViewWithTitle:(NSString *)title content:(NSString *)content isShowLine:(BOOL)isShowLine;

#pragma mark - 获取高度方法 title:标题 content:内容 isShowLine:是否显示线标示 maxWidth:最大宽度
- (CGFloat)getHeightWithTitle:(NSString *)title content:(NSString *)content isShowLine:(BOOL)isShowLine maxWidth:(CGFloat)maxWidth;

@end
//===================================================================================================================================================================

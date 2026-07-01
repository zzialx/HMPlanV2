//
//  WSContactsBookDetailsOneTitleView.h
//  WinSFA
//
//  Created by yuanji on 2018/5/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
//===================================================================================================================================================================

#pragma mark - 通讯录详情一个标题视图
@interface WSContactsBookDetailsOneTitleView : UIView

#pragma mark - 更新视图方法 title:标题 isBottomSpace:是否底部空间
- (void)updateViewWithTitle:(NSString *)title isBottomSpace:(BOOL)isBottomSpace;

#pragma mark - 获取高度方法 title:标题 maxWidth:最大宽度 isBottomSpace:是否底部空间
- (CGFloat)getHeightWithTitle:(NSString *)title isBottomSpace:(BOOL)isBottomSpace maxWidth:(CGFloat)maxWidth;

@end
//===================================================================================================================================================================

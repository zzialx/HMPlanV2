//
//  WSContactsBookDetailsHeaderView.h
//  WinSFA
//
//  Created by yuanji on 2018/5/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
//===================================================================================================================================================================

#pragma mark - 通讯录详情头视图
@interface WSContactsBookDetailsHeaderView : UIView

#pragma mark - 更新视图方法 bgImage:背景视图 name:姓名 jobTitle:职称 iconUrl:头像url
- (void)updateViewWithBgImage:(UIImage *)bgImage name:(NSString *)name jobTitle:(NSString *)jobTitle iconUrl:(NSString *)iconUrl;

#pragma mark - 获取高度方法 bgImage:背景视图 maxWidth:最大宽度
- (CGFloat)getHeightWithBgImage:(UIImage *)bgImage maxWidth:(CGFloat)maxWidth;

@end
//===================================================================================================================================================================

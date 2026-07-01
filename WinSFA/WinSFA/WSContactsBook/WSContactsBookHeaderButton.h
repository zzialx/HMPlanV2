//
//  WSContactsBookHeaderButton.h
//  WinSFA
//
//  Created by yuanji on 2018/5/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
//===================================================================================================================================================================

#pragma mark - 通讯录头按键
@interface WSContactsBookHeaderButton : UIButton

#pragma mark - 更新方法 mark:标示 content:内容
- (void)updateWithMark:(NSString *)mark content:(NSString *)content;

#pragma mark - 获取高度方法 mark:标示 content:内容 maxWidth:最大宽度
- (CGFloat)getHeightWithMark:(NSString *)mark content:(NSString *)content maxWidth:(CGFloat)maxWidth;

@end
//===================================================================================================================================================================

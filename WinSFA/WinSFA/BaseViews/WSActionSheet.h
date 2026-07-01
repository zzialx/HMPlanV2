//
//  WSActionSheet.h
//  WinSFA
//
//  Created by yuanji on 2017/9/18.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WSActionSheetDelegate;
@class WSActionSheet;

typedef void (^WSActionSheetDidSelectActionBlock)(WSActionSheet *actionSheet, NSInteger index); //动作表格点击闭包 actionSheet:动作表格 index:选择索引
//===================================================================================================================================================================

#pragma mark - 动作表格
@interface WSActionSheet : UIView

#pragma mark - 自定义初始化方法(+号) title:标题 cancelTitle:取消标题 otherTitles:其它标题 selectActionBlock:选择闭包
+ (instancetype)ws_actionSheetViewWithTitle:(NSString *)title cancelTitle:(NSString *)cancelTitle otherTitles:(NSArray *)otherTitles
                          selectActionBlock:(WSActionSheetDidSelectActionBlock)selectActionBlock;

#pragma mark - 自定义初始化方法(-号) title:标题 cancelTitle:取消标题 otherTitles:其它标题selectActionBlock:选择闭包
- (instancetype)initWithTitle:(NSString *)title cancelTitle:(NSString *)cancelTitle otherTitles:(NSArray *)otherTitles
            selectActionBlock:(WSActionSheetDidSelectActionBlock)selectActionBlock;

#pragma mark - 自定义初始化方法(+号) title:标题 cancelTitle:取消标题 otherTitles:其它标题 delegate:代理指针
+ (instancetype)sr_actionSheetViewWithTitle:(NSString *)title cancelTitle:(NSString *)cancelTitle otherTitles:(NSArray *)otherTitles
                                   delegate:(id<WSActionSheetDelegate>)delegate;

#pragma mark - 自定义初始化方法(-号) title:标题 cancelTitle:取消标题 otherTitles:其它标题 delegate:代理指针
- (instancetype)initWithTitle:(NSString *)title cancelTitle:(NSString *)cancelTitle otherTitles:(NSArray *)otherTitles
                     delegate:(id<WSActionSheetDelegate>)delegate;

#pragma mark - 显示方法
- (void)show;

@end
//===================================================================================================================================================================

#pragma mark - 动作表格代理协议
@protocol WSActionSheetDelegate <NSObject>

#pragma mark - 点击协议方法 actionSheet:动作表格 index:选择索引
- (void)actionSheet:(WSActionSheet *)actionSheet didSelectSheet:(NSInteger)index;

@end
//===================================================================================================================================================================

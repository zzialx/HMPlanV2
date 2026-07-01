//
//  WSFuncTipAlertView.h
//  TestDemo
//
//  Created by xq的电脑 on 2023/12/3.
//

#import <UIKit/UIKit.h>
@class WSFuncTipAlertView;
//===================================================================================================================

NS_ASSUME_NONNULL_BEGIN

typedef void (^FuncTipAlertViewCompleteBlock)(WSFuncTipAlertView *view);  //定义完成闭包

#pragma mark - 菜单提醒视图
@interface WSFuncTipAlertView : UIView

@property (nonatomic, copy) FuncTipAlertViewCompleteBlock completeBlock; //完成闭包

+ (instancetype)creatFuncTipAlertViewWithList:(NSArray *)list title:(NSString *)title;  //创建菜单提醒视图方法
- (void)closeFuncTipAlertView;                                                          //关闭菜单提醒视图方法

@end

NS_ASSUME_NONNULL_END
//===================================================================================================================

//
//  WSNavigationBar.h
//  NavigationDemo
//
//  Created by melody on 13-11-25.
//  Copyright (c) 2013年 melody. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface UIViewController(NavTab)




/**
 *	@brief 返回到上一页面 等于[self.navigationController popViewControllerAnimated:YES];
 */
- (void)pop;


/**
 *	@brief 返回到Root页面 等于[self.navigationController popToRootViewControllerAnimated:YES];
 */
- (void)popToRoot;


/**
 *	@brief	创建导航条右按钮
 *
 *	@param 	title 	按钮标题
 *	@param 	target 	按钮点击事件响应对象
 *	@param 	selector 	按钮点击事件响应方法
 */
- (UIBarButtonItem *)barButtonItemTitle:(NSString *)title target:(id)target action:(SEL)selector;



/**
 *	@brief	创建导航条右按钮
 *
 *	@param 	imageName 	按钮图片
 *	@param 	target 	按钮点击事件响应对象
 *	@param 	selector 	按钮点击事件响应方法
 */
- (UIBarButtonItem *)barButtonItemImage:(NSString *)imageName target:(id)target action:(SEL)selector;



/**
 *	@brief	创建导航条右按钮
 *
 *	@param 	imageName 	按钮图片
 *	@param 	target 	按钮点击事件响应对象
 *	@param 	selector 	按钮点击事件响应方法
 *	@param 	title 	按钮标题
 */
- (UIBarButtonItem *)barButtonItemImage:(NSString *)imageName target:(id)target action:(SEL)selector title:(NSString *)title;


/**
 *
 *	@param 	imageName 	按钮图片
 *	@param 	target 	按钮点击事件响应对象
 *	@param 	selector 	按钮点击事件响应方法
 *	@param 	title 	按钮标题
 *	@param 	font 	按钮字体
 */
- (UIBarButtonItem *)barButtonItemImage:(NSString *)imageName target:(id)target action:(SEL)selector title:(NSString *)title font:(UIFont *)font buttonWidth:(CGFloat)width fontLeftWith:(CGFloat)fontWidth;


/**
 *	@brief	创建导航条左按钮
 *
 *	@param 	title 	按钮标题
 *	@param 	target 	按钮点击事件响应对象
 *	@param 	selector 	按钮点击事件响应方法
 */
- (void)leftItemTitle:(NSString *)title target:(id)target action:(SEL)selector;




/**
 *	@brief	创建导航条左按钮
 *
 *	@param 	imageName 	按钮图片
 *	@param 	target 	按钮点击事件响应对象
 *	@param 	selector 	按钮点击事件响应方法
 */
- (void)leftItemImage:(NSString *)imageName target:(id)target action:(SEL)selector;



/**
 *	@brief	创建导航条左按钮
 *
 *	@param 	imageName 	按钮图片
 *	@param 	target 	按钮点击事件响应对象
 *	@param 	selector 	按钮点击事件响应方法
 *	@param 	title 	按钮标题
 */
- (void)leftItemImage:(NSString *)imageName target:(id)target action:(SEL)selector title:(NSString *)title;


/**
 *	@brief	创建导航条左按钮
 *
 *	@param 	imageName 	按钮图片
 *	@param 	target 	按钮点击事件响应对象
 *	@param 	selector 	按钮点击事件响应方法
 *	@param 	title 	按钮标题
 *	@param 	font 	按钮字体
 */
- (void)leftItemImage:(NSString *)imageName target:(id)target action:(SEL)selector title:(NSString *)title font:(UIFont *)font buttonWidth:(CGFloat)width fontLeftWith:(CGFloat)fontWidth;


/**
 *	@brief	创建导航条左返回按钮
 *
 *	@param 	imageName 	按钮图片
 *	@param 	title 	按钮标题
 */
- (void)leftItemBack:(NSString *)imageName title:(NSString *)title;

- (void) backItemAction:(SEL)selector target:(id)target withDelay:(int)delaySecond;
- (void) backItemAction:(SEL)selector target:(id)target;

/**
 *	@brief	清除右按钮
 */
- (void)clearRightItem;



/**
 *	@brief	清除左按钮
 */
- (void)clearLeftItem;



/**
 *	@brief	显示和隐藏导航条
 *
 *	@param 	hide 	YES隐藏 NO显示
 */
- (void)navBarHidden:(BOOL)hide;




/**
 *	@brief	显示和隐藏选项卡
 *
 *	@param 	hide 	YES隐藏 NO显示
 */
- (void)tabBarHidden:(BOOL)hide;



/**
 *	@brief	动画显示和隐藏选项卡
 *
 *	@param 	hidden 	YES隐藏 NO显示
 */

- (void) tabBarHiddenAnimated:(BOOL) hidden;




@end


@interface UINavigationBar(LazyNavigationBar)


@end

@interface UINavigationItem(NaviItemCategory)

@end


@interface CustomNavigationBar : UINavigationBar
{
    
    UIImage *_image;
    BOOL isShadow;
}
@property (nonatomic,strong) UIImage *image;

/**
 *	@brief	设置导航条背景图片
 *
 *	@param 	backgroundImage 	图片
 */
- (void) setBackgroundWith:(UIImage*)backgroundImage;


/**
 *	@brief	是否设置阴影
 *
 *	@param 	shadow 	是或否
 */
- (void)setShadow:(BOOL)shadow;


@end


@interface UITabBarController(NavTabRoot)




/**
 *	@brief	设置上面的图片以及动画
 *
 *	@param 	indicatorImage 	上面的图片
 *	@param 	animated 	是否有动画
 */
- (void)setIndicatorImage:(UIImage *)indicatorImage animated:(BOOL)animated;




/**
 *	@brief	改写颜色,设置setSelectImageNames则此方法无效
 *
 *	@param 	selectColor 	选中时颜色
 *	@param 	bgColor 	未选中时颜色
 */
- (void)setSelectColor:(UIColor *)selectColor bgColor:(UIColor *)bgColor;



/**
 *	@brief	设置选项卡背景图片
 *
 *	@param 	image 	图片
 */
- (void) setBackgroundWith:(UIImage *)image;



/**
 *	@brief	设置选项卡是所有的ViewController都有导航
 *
 *	@param 	controllers 	ViewController数组
 */
- (void) setNViewControllers:(NSArray*)controllers;


/**
 *	@brief	设置选项卡按钮的标题和图片，调用方法前请确保调用self.viewControllers数组不为空
 *
 *	@param 	titles 	标题数组
 *	@param 	imageNames 	图片数组
 */
- (void) setTitles:(NSArray *)titles imageNames:(NSArray *)imageNames;


/**
 *	@brief	设置选项卡按钮的标题和图片，调用方法前请确保调用self.viewControllers数组不为空
 *
 *	@param 	selectImageNames 	选中图片数组
 *	@param 	unSelectImageNames 	没选中图片数组
 */
//- (void) setSelectImageNames:(NSArray *)selectImageNames unSelectImageNames:(NSArray *)unSelectImageNames;

/**
 *	@brief	设置选项卡按钮的标题和图片，调用方法前请确保调用self.viewControllers数组不为空
 *
 *	@param 	selectImageNames 	选中图片数组
 *	@param 	unSelectImageNames 	没选中图片数组
 *	@param 	selectIndex 	选中第一个
 */
- (void) setMDSelectImageNames:(NSArray *)selectImageNames unSelectImageNames:(NSArray *)unSelectImageNames selectIndex:(int)index;



@end

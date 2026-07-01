//
//  UINavigationBar+Image.m
// Core
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import "UINavigationBar+Image.h"

@implementation UINavigationBar (Image)

// 这里由类别改成继承方式，主要是在5.0以下版本，调用短信，邮件等系统界面时，需在调用原来的绘制方法，
// 但是类别实现不能满足这一需求，所以改为继承，这里重写此方法实现
//+ (Class)class
//{
//    return NSClassFromString(@"RSNavigationBar");
//}


static UIImage* navigationBarImage;


//- (void)drawRect:(CGRect)rect {
//    UIImage* image = navigationBarImage;
//    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
//}

// 设置导航条背景图片 navigation_bar_bg.png
- (void)setNavigationBarWithImageKey:(NSString *)imageKey{
//    UIImage *image = [UIImage imageForKey:imageKey];
//    
//    if ([self respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
//        [self setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
//        self.tintColor = [UIColor colorWithPatternImage:image];
//    }
//    else{
//        navigationBarImage = image;
//    }
////    if ([self respondsToSelector:@selector(setTitleVerticalPositionAdjustment:forBarMetrics:)]) {
////        [self setTitleVerticalPositionAdjustment:44.0f - image.size.height forBarMetrics:UIBarMetricsDefault];
////    }
    self.backgroundColor = [UIColor blackColor];
}

- (void)clearNavigationBarImage{
    if ([self respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [self setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    }else{
        navigationBarImage = nil;
    }
}


//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    
//    // tlb注：本来导航栏高度为44，但图片高度为50，所以设为50.
//    CGRect frame = self.frame;
//	if (frame.size.height > WCAppContext.navigationBarImage.size.height) {
//        return; // with prompt
//    }
//    frame.size.height = WCAppContext.navigationBarImage.size.height;
//	//chenyi modify 50 to self.bgImage.size.height ,否则bgImage图片高度改变的时候,
//	//leftBarButtonItem和rightBarButtonItem 无法上下居中
//	
//    self.frame = frame;
//    
//    // 设置标题显示范围
//    CGRect fl = self.topItem.leftBarButtonItem.customView.frame;
//    CGRect fr = self.topItem.rightBarButtonItem.customView.frame;
//    
//    fl.origin.y = 0.0;
//    fr.origin.y = 0.0;
//    self.topItem.leftBarButtonItem.customView.frame = fl;
//    self.topItem.rightBarButtonItem.customView.frame = fr;
//    
//    if ([[UIDevice currentDevice] systemVersionLowerThan:@"5.0"]) {
//        // 5.0以下版本，要布局一下titleVie的坐标
//        // 5.0以上，用[self setTitleVerticalPositionAdjustment:-5.0f forBarMetrics:UIBarMetricsDefault]方法
//        CGRect ft = self.topItem.titleView.frame;
//        if (!CGRectIsEmpty(ft)) {
//            ft.origin.y = (44.0 - ft.size.height) / 2;
//        }
//        self.topItem.titleView.frame = ft;
//    }
//}

@end

/*
@implementation RSNavigationBar

@synthesize bgImage = _bgImage;

- (void)dealloc
{
    [self clearNavigationBarImage];
    
    [super dealloc];
}

- (void)drawRect:(CGRect)rect {
    if (self.bgImage == nil) {
        [super drawRect:rect];
    }
    else {
        [self.bgImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }
}

//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    
//    // tlb注：本来导航栏高度为44，但图片高度为50，所以设为50.
//    CGRect frame = self.frame;
//	if (frame.size.height > self.bgImage.size.height) {
//        return; // with prompt
//    }
//    frame.size.height = self.bgImage.size.height;
//	//chenyi modify 50 to self.bgImage.size.height ,否则bgImage图片高度改变的时候,
//	//leftBarButtonItem和rightBarButtonItem 无法上下居中
//	
//    self.frame = frame;
//
//    // 设置标题显示范围
//    CGRect fl = self.topItem.leftBarButtonItem.customView.frame;
//    CGRect fr = self.topItem.rightBarButtonItem.customView.frame;
//    
//    fl.origin.y = 0.0;
//    fr.origin.y = 0.0;
//    self.topItem.leftBarButtonItem.customView.frame = fl;
//    self.topItem.rightBarButtonItem.customView.frame = fr;
//
//    if ([[UIDevice currentDevice] systemVersionLowerThan:@"5.0"]) {
//        // 5.0以下版本，要布局一下titleVie的坐标
//        // 5.0以上，用[self setTitleVerticalPositionAdjustment:-5.0f forBarMetrics:UIBarMetricsDefault]方法
//        CGRect ft = self.topItem.titleView.frame;
//        if (!CGRectIsEmpty(ft)) {
//            ft.origin.y = (44.0 - ft.size.height) / 2;
//        }
//        self.topItem.titleView.frame = ft;
//    }
//}

// 设置导航条背景图片 navigation_bar_bg.png
- (void)setNavigationBarWithImageKey:(NSString *)imageKey{
	self.bgImage = [[UIImage imageForKey:imageKey];
    [self setNavigationBarWithImage:self.bgImage];
//
//    if ([self respondsToSelector:@selector(setTitleVerticalPositionAdjustment:forBarMetrics:)]) {
//        [self setTitleVerticalPositionAdjustment:44.0f - self.bgImage.size.height forBarMetrics:UIBarMetricsDefault];
//    }
//    self.tintColor = [UIColor colorWithPatternImage:self.bgImage];
//    self.backgroundColor = [UIColor clearColor];
//    [self setNeedsDisplay];
}

- (void)setNavigationBarWithImage:(UIImage *)image
{
    self.bgImage = image;
    
    if ([self respondsToSelector:@selector(setTitleVerticalPositionAdjustment:forBarMetrics:)]) {
        [self setTitleVerticalPositionAdjustment:44.0f - self.bgImage.size.height forBarMetrics:UIBarMetricsDefault];
    }
    self.tintColor = [UIColor colorWithPatternImage:self.bgImage];
    self.backgroundColor = [UIColor clearColor];
    [self setNeedsDisplay];

}

- (void)clearNavigationBarImage{
    self.bgImage = nil;
}
@end
 */

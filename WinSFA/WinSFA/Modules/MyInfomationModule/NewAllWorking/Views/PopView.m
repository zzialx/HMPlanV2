//
//  PopView.m
//  demo
//
//  Created by zhiqingPC on 15/10/20.
//  Copyright (c) 2015年 zhiqingPC. All rights reserved.
//

#import "PopView.h"
#import "TitleButton.h"
#import "UIView+Extension.h"
@interface PopView ()

@property(nonatomic,strong)TitleButton * titleBtn;
@property(nonatomic,weak)UIImageView * bgView;

@end

@implementation PopView
-(instancetype)initWithCustomView:(UIView *)customView{
    self = [super init];
    if (self) {
        self.size = [UIScreen mainScreen].bounds.size;
        
        [self addTarget:self action:@selector(hide:) forControlEvents:UIControlEventTouchUpInside];
        // 初始化小灰框
        UIImageView * imageView = [[UIImageView alloc]init];
        
        UIImage * img = [UIImage imageNamed:@"xiala_bj"];
        
        CGFloat top = 25; // 顶端盖高度
        CGFloat bottom = 5 ; // 底端盖高度
        CGFloat left = 5; // 左端盖宽度
        CGFloat right = 5; // 右端盖宽度
        UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
        // 指定为拉伸模式，伸缩后重新赋值
        img = [img resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        // 设置可以接受用户点击事件
        imageView.userInteractionEnabled = YES;
        imageView.image = img;
        imageView.size = CGSizeMake(customView.width, customView.height + 10);
        customView.y = 5;
        imageView.alpha = 0.8;
        [imageView addSubview:customView];
        [self addSubview:imageView];
        self.bgView = imageView;
        
    }
    
    
    return self;
    
}

// 坐标转换
-(void)showWithView:(UIView *)taggetView{
    
    
    
    UIWindow *wc = [[[UIApplication sharedApplication] windows] firstObject];
    UIView* rootView= wc.rootViewController.view;
    
    // 把 button的坐标  转换到屏幕的坐标
    CGRect rect = [taggetView convertRect:taggetView.bounds toView:rootView];
    
    
    self.bgView.centerX = CGRectGetMidX(rect);
    
    self.bgView.y = CGRectGetMaxY(rect) - 4 ;
    
    self.titleBtn = (TitleButton *)taggetView;
    
    [rootView addSubview:self];
    
    
}

// 点击蒙板  移除popview
-(void)hide:(UIButton * )btn{
    // 隐藏  就是把 当前的蒙版View 从 父控件移除
    
    [UIView animateWithDuration:0.5 animations:^{
        self.titleBtn.imageView.transform = CGAffineTransformRotate(self.titleBtn.imageView.transform, M_PI);
    }];
    [self removeFromSuperview];
    
}

@end

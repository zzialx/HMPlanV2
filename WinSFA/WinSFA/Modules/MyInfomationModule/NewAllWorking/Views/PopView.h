//
//  PopView.h
//  demo
//
//  Created by zhiqingPC on 15/10/20.
//  Copyright (c) 2015年 zhiqingPC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopView : UIButton
// 通过传入一个自定义的VIew 去初始化一个pop菜单

-(instancetype)initWithCustomView:(UIView * )customView;

// 坐标转换  把空间显示在某个控件之下
-(void)showWithView:(UIView *)taggetView;

@end


//
//  WSPageControl.h
//  WinSFA
//
//  自定义 PageControl 圆点或者图片的位置
//  Created by Alicia on 2017/6/5.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    WSPageContolAlimentRight,
    WSPageContolAlimentCenter
} WSPageContolAliment;


@interface WSPageControl : UIPageControl

@property (nonatomic, assign) CGFloat dotWidth;
@property (nonatomic, assign) CGFloat dotHeight;
@property (nonatomic, assign) CGFloat dotMargin;
/** 分页控件位置 */
@property (nonatomic, assign) WSPageContolAliment pageControlAliment;

@end

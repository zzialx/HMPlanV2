//
//  WSViewingView.m
//  WinSFA
//
//  Created by macbook  on 2018/6/26.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSViewingView.h"

#define OFFSETX 10.0
#define RWidth self.frame.size.width
#define RHeight self.frame.size.height
#define V_OFFSET(x) (20.0f*x)

@implementation WSViewingView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.width = 0;
        self.height = 0;
        self.maxCameraperHeight = 0;
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame width:(CGFloat)width height:(CGFloat)height maxCameraperHeight:(CGFloat)maxCameraperHeight{
    self = [self initWithFrame:frame];
    if (self) {
        self.width = width;
        self.height = height;
        self.maxCameraperHeight = maxCameraperHeight;
    }
    return self;
}

- (CGRect)getAbsHollowRect {
    CGRect hollowRect = [self getHollowRect];
    CGRect curRect = self.frame;
    return  CGRectMake(hollowRect.origin.x + curRect.origin.x, hollowRect.origin.y + curRect.origin.y, hollowRect.size.width, hollowRect.size.height);
}

// 计算全透明区域，即取景的范围
- (CGRect)getHollowRect {
    // 默认已水平方向为基准
    BOOL horORVerFlag = YES;
    // width，height 都存在，如果宽度大于高度
    if (self.width > 0 && self.height > 0) {
        if (self.width > self.height) {
            horORVerFlag = YES;
        }
    }
    
    // actualWith，actualHeight 手机屏幕除去边缘的实际宽度、高度
    CGFloat actualWith = RWidth - 2*OFFSETX;
    CGFloat actualHeight = self.maxCameraperHeight;
    CGFloat scaleX = 0;
    CGFloat scaleY = 0;
    // 宽度、高度 对应的放大压缩比例
    if (horORVerFlag) {
        scaleX = actualWith/self.width;
        scaleY = actualHeight/self.height;
    } else {
        scaleX = actualWith/self.height;
        scaleY = actualWith/self.width;
    }
    
    // 如果宽度放大缩小比例大于高度，那么取高度的值；如果宽度放大缩小比例小于高度，取宽度值
    CGFloat scale = 0;
    if (scaleX > scaleY) {
        scale = scaleY;
    } else {
        scale = scaleX;
    }
    
    // 全透明区域
    CGRect hollowRect = CGRectMake(0, 0, 0, 0);
    if (horORVerFlag) {
        hollowRect = CGRectMake((RWidth - self.width*scale)/2, (RHeight - self.height*scale)/2, self.width*scale, self.height*scale);
    } else {
        hollowRect = CGRectMake((RWidth - self.height*scale)/2, (RHeight -self.width*scale)/2, self.height*scale, self.width*scale);
    }
    
    return hollowRect;
}

- (void)drawRect:(CGRect)rect {
    [[UIColor colorWithWhite:0 alpha:0.8] setFill];
    // 半透明区域
    UIRectFill(rect);
    
    // 透明区域
    CGRect hollowRect  = [self getHollowRect];
    CGRect holeiInterSection = CGRectIntersection(hollowRect, rect);
    [[UIColor clearColor] setFill];
    UIRectFill(holeiInterSection);
    
    // 绘制取景框四角的线
    CGFloat offsetX = hollowRect.origin.x;
    CGFloat offsetY = hollowRect.origin.y;
    CGFloat width = hollowRect.size.width;
    CGFloat height = hollowRect.size.height;
    // 左上角
    [self drawLine:CGPointMake(offsetX, offsetY) xDirection:1 yDirection:1];
    [self drawLine:CGPointMake(width + offsetX, offsetY) xDirection:-1 yDirection:1];
    [self drawLine:CGPointMake(offsetX, height +offsetY) xDirection:1 yDirection:-1];
    [self drawLine:CGPointMake(width + offsetX, height + offsetY) xDirection:-1 yDirection:-1];
}

-(void)drawLine:(CGPoint)startPoint xDirection:(int) xDirection yDirection:(int)yDirection {
    //获得处理的上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //指定直线样式
    CGContextSetLineCap(context, kCGLineCapSquare);
    //直线宽度
    CGContextSetLineWidth(context, 4);
    //设置颜色
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    //开始绘制
    CGContextBeginPath(context);
    //画笔移动到点(31,170)
    CGContextMoveToPoint(context, startPoint.x, startPoint.y + V_OFFSET(yDirection));
    //下一点
    CGContextAddLineToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, startPoint.x + V_OFFSET(xDirection), startPoint.y);
    //绘制完成
    CGContextStrokePath(context);
}
@end

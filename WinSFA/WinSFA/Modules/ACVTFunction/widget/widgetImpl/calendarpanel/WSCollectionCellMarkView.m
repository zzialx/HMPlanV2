//
//  WSCollectionCellMarkView.m
//  WinSFA
//
//  Created by heju on 15/4/22.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#define FILL_COLOR [UIColor colorWithRed:251.0f/255 green:182.0f/255 blue:166.0f/255 alpha:1.0f] //[UIColor colorWithRed:63.0f/255 green:163.0f/255 blue:214.0f/255 alpha:1.0f]



#import "WSCollectionCellMarkView.h"

@implementation WSCollectionCellMarkView



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame markStyle:(MarkViewType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.currentMarkType = type;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    switch (self.currentMarkType) {
        case MarkViewTrangleType:
        {
            [self drawTrangleWith:CGRectMake(0, 0, self.width, self.height)];
        }
            break;
        case MarkViewLeftCircleType: {
            [self drawLeftCircleTrangleWith:rect];
        }
            break;
        case MarkViewRightCircleType: {
            [self drawRightCircleTrangleWith:rect];
        }
            break;
        default:
            break;
    }
}


- (void)drawLeftCircleTrangleWith:(CGRect)rect {
    [self drawHalfCircleWithX:20 y:self.height/2 radius:self.height/2 startAngle:M_PI/2 endAngle:-M_PI/2];
    [self drawTrangleWith:CGRectMake(20, 0, self.width - 20, self.height)];
}

- (void)drawRightCircleTrangleWith:(CGRect)rect {
    [self drawTrangleWith:CGRectMake(0, 0, self.width - 20, self.height)];
    [self drawHalfCircleWithX:self.width - 20 y:self.height/2 radius:self.height/2 startAngle:-M_PI/2 endAngle:M_PI/2];
}

/*
 rect中绘制矩形
 */
- (void)drawTrangleWith:(CGRect) rect {
    // 右部分矩形
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path,NULL, rect);/*将矩形添加到路径中*/
    //将路径添加到上下文
    CGContextAddPath(currentContext, path);
    //设置矩形填充色
    [FILL_COLOR setFill];
    //矩形边框颜色
    [[UIColor whiteColor] setStroke];
    //边框宽度
    CGContextSetLineWidth(currentContext,0.0f);
    //绘制
    CGContextDrawPath(currentContext, kCGPathFillStroke);
    CGPathRelease(path);
}

/*
 绘制半圆
 */
- (void)drawHalfCircleWithX:(CGFloat )x y:(CGFloat)y radius:(CGFloat)radius startAngle:(float)startAngle endAngle:(float)endAngle {
    //左部分半圆
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(currentContext, FILL_COLOR.CGColor);//填充颜色
    CGContextSetLineWidth(currentContext, 0.0);//线的宽度
    [[UIColor whiteColor] setStroke];
    CGContextAddArc(currentContext,x,y,radius, startAngle,endAngle, 0); //添加一个半圆
    /*kCGPathFill填充非零绕数规则,
     kCGPathEOFill表示用奇偶规则,
     kCGPathStroke路径,
     kCGPathFillStroke路径填充,
     kCGPathEOFillStroke表示描线不是填充
     */
    CGContextDrawPath(currentContext, kCGPathFillStroke); //绘制路径加填充
}
 /*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

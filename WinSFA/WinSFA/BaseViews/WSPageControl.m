//
//  WSPageControl.m
//  WinSFA
//
//  Created by Alicia on 2017/6/5.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSPageControl.h"

#define kDotWidth   5
#define kDotHeight  5
#define kDotMargin  3

@implementation WSPageControl

- (instancetype)init {
    self = [super init];
    if (self) {
       [self setupValues];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupValues];
    }
    return self;
}

- (void)setupValues {
    self.dotWidth = kDotWidth;
    self.dotHeight = kDotHeight;
    self.dotMargin = kDotMargin;
    self.pageControlAliment = WSPageContolAlimentCenter;
}

// 重设圆点间距
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat marginX = self.dotWidth + self.dotMargin;
    CGFloat newWidth = (self.subviews.count - 1) * marginX;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, newWidth, self.frame.size.height);
    
  
    if (self.pageControlAliment == WSPageContolAlimentCenter) {
        CGPoint center = self.center;
        center.x = self.superview.center.x;
        self.center = center;
    } else  {
        CGFloat paddingX = self.superview.bounds.size.width - MAIN_PADDING - newWidth;
        self.frame = CGRectMake(paddingX, self.frame.origin.y, newWidth, self.frame.size.height);
    }
    
    //遍历subview,设置圆点frame
    CGFloat lastPos = 0;
    for (int i = 0; i < [self.subviews count]; i++) {
        UIImageView* dot = [self.subviews objectAtIndex:i];
        
        CGFloat dotWidth = self.dotWidth;
//        if (i == self.currentPage) {
//            dotWidth = self.dotWidth;
//        } else {
//            dotWidth = self.dotWidth;
//        }
        
        [dot setFrame:CGRectMake(lastPos, dot.frame.origin.y, dotWidth, self.dotHeight)];
        lastPos += dotWidth + self.dotMargin;
    }
}

@end

//
//  UIView+ViewFrameGeometry.h
//  menu
//
//  Created by Niu Zhaowang on 11/9/12.
//  Copyright (c) 2012 Niu Zhaowang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ViewFrameGeometry)

@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize size;
@property (nonatomic,readonly) CGPoint bottomLeft;
@property (nonatomic,readonly) CGPoint bottomRight;
@property (nonatomic,readonly) CGPoint topRight;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat right;

- (void)moveBy: (CGPoint) delta;
- (void)scaleBy: (CGFloat) scaleFactor;
- (void)fitInSize: (CGSize) aSize;

@end

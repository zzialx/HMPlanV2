//
//  UIView+ViewFrameGeometry.m
//  menu
//
//  Created by Niu Zhaowang on 11/9/12.
//  Copyright (c) 2012 Niu Zhaowang. All rights reserved.
//

#import "UIView+ViewFrameGeometry.h"

@implementation UIView (ViewFrameGeometry)

//Retrieve and set the origin
- (CGPoint) origin
{
    return self.frame.origin;
}

- (void) setOrigin: (CGPoint) aPoint
{
    CGRect newframe = self.frame;
    newframe.origin = aPoint;
    self.frame = newframe;
}

//Retrieve and set the size
- (CGSize) size
{
    return self.frame.size;
}

- (void) setSize: (CGSize) aSize
{
    CGRect newframe = self.frame;
    newframe.size = aSize;
    self.frame = newframe;
}

//Qurey other frame locations
- (CGPoint) bottomRight
{
    CGFloat x = self.frame.origin.x + self.frame.size.width;
    CGFloat y = self.frame.origin.y + self.frame.size.height;
    return CGPointMake(x, y);
}

- (CGPoint) bottomLeft
{
    CGFloat x = self.frame.origin.x;
    CGFloat y = self.frame.origin.y + self.frame.size.height;
    return CGPointMake(x, y);
}

- (CGPoint) topRight
{
    CGFloat x = self.frame.origin.x + self.frame.size.width;
    CGFloat y = self.frame.origin.y;
    return CGPointMake(x, y);
}

//Retrieve and set height, width, top, bottom, left, right
- (CGFloat) height
{
    return self.frame.size.height;
}

- (void) setHeight: (CGFloat) newHeight
{
    CGRect newframe = self.frame;
    newframe.size.height = newHeight;
    self.frame = newframe;
}

- (CGFloat) width
{
    return self.frame.size.width;
}

- (void) setWidth: (CGFloat)newWidth
{
    CGRect newframe = self.frame;
    newframe.size.width = newWidth;
    self.frame = newframe;
}

- (CGFloat) top
{
    return self.frame.origin.y;
}

- (void) setTop: (CGFloat) newTop
{
    CGRect newframe = self.frame;
    newframe.origin.y = newTop;
    self.frame = newframe;
}

- (CGFloat) left
{
    return self.frame.origin.x;
}

- (void) setLeft:(CGFloat)newLeft
{
    CGRect newframe = self.frame;
    newframe.origin.x = newLeft;
    self.frame = newframe;
}

- (CGFloat) bottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void) setBottom:(CGFloat)newBottom
{
    CGRect newframe = self.frame;
    newframe.origin.y = newBottom - self.frame.size.height;
    self.frame = newframe;
}

- (CGFloat) right
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void) setRight:(CGFloat)newRight
{
    CGFloat delta = newRight - (self.frame.origin.x + self.frame.size.width);
    CGRect newframe = self.frame;
    newframe.origin.x += delta;
    self.frame = newframe;
}

- (void) fitInSize:(CGSize)aSize
{
    CGFloat scale;
    CGRect newframe = self.frame;
    
    if (newframe.size.height > aSize.height)
    {
        scale = aSize.height / newframe.size.height;
        newframe.size.width *= scale;
        newframe.size.height *= scale;
    }
    
    if (newframe.size.width > aSize.width)
    {
        scale = aSize.width / newframe.size.width;
        newframe.size.width *= scale;
        newframe.size.height *= scale;
    }
    
    self.frame = newframe;
}

- (void) moveBy:(CGPoint)delta
{
    CGPoint newCenter = self.center;
    newCenter.x += delta.x;
    newCenter.y += delta.y;
    self.center = newCenter;
}

- (void) scaleBy:(CGFloat)scaleFactor
{
    CGRect newframe = self.frame;
    CGFloat newwidth = newframe.size.width * scaleFactor;
    CGFloat newheight = newframe.size.height * scaleFactor;
    CGFloat x = newframe.origin.x - (newwidth - newframe.size.width)/2.0f;
    CGFloat y = newframe.origin.y - (newheight - newframe.size.height)/2.0f;
    newframe.origin.x = x;
    newframe.origin.y = y;
    newframe.size.width = newwidth;
    newframe.size.height = newheight;
    
    self.frame = newframe;
}
@end

//
//  WSCGRect.m
//  WinSFA
//
//  Created by macbook  on 2018/6/28.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSCGRect.h"

@implementation WSCGRect
// showRect 取景框取景的frame preview 取景框view的frame
+(CGRect)caculateNewRect:(CGRect)showRect previewRect:(CGRect)previewRect imageSize:(CGSize)size {
    CGFloat h = showRect.size.height;
    CGFloat w = showRect.size.width;
    
    // 取景框的起点 X，Y 对应到iamge上的位置
    CGFloat originX = showRect.origin.x;
    CGFloat originY = (showRect.origin.y) * size.height / previewRect.size.height;
    // 取景框的宽度对应到image上的实际宽度
    CGFloat clipW = w * size.width / previewRect.size.width;
    // 取景框对高度对应的image上的实际高度
    CGFloat clipH = h * size.height / previewRect.size.height;
    // 实际取景框大小
    CGRect clipRect = CGRectMake(originX, originY, clipW, clipH);
    return  clipRect;
}
@end

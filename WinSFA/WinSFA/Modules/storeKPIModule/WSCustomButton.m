//
//  WSCustomButton.m
//  WinSFA
//
//  Created by winchannel on 2017/7/3.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSCustomButton.h"

@implementation WSCustomButton

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    CGRect rect = CGRectMake(0,0 /*(contentRect.size.height - ICONHEIGHT - TITLEHEIGHT) / 2*/, contentRect.size.width, ICONHEIGHT);
    return rect;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGRect rect = CGRectMake(0, (contentRect.size.height -  TITLEHEIGHT), contentRect.size.width, TITLEHEIGHT);
    return rect;
}

-(void)setHighlighted:(BOOL)highlighted
{
    
}
@end

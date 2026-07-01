//
//  UITextField+UIMenuItem.m
//  WinSFA
//
//  Created by mac on 2018/9/3.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "UITextField+UIMenuItem.h"

@implementation UITextField (UIMenuItem)
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    
    if ((action == @selector(cut:) || action == @selector(copy:)) && !self.isSecureTextEntry) {
        return YES;
    } else if (action == @selector(paste:)) {
        return YES;
    } else if (action == @selector(select:)) {
        return YES;
    } else if (action == @selector(selectAll:)) {
        return YES;
    }else
    {
        return NO;
    }
}
@end

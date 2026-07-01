//
//  UICopyLabel.m
//  WinSFA
//
//  Created by yang on 16/5/4.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "UICopyLabel.h"

@implementation UICopyLabel


- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self attachTapHandler];
    }
    
    return self;
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}


-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return (action == @selector(copy:));
}


-(void)copy:(id)sender
{
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    
    pboard.string = self.text;
    
}


-(void)attachTapHandler
{
    self.userInteractionEnabled = YES;  //用户交互的总开关
    
    UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    
    [self addGestureRecognizer:touch];
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self attachTapHandler];
    
}

-(void)handleTap:(UIGestureRecognizer*) recognizer
{
    
    [self becomeFirstResponder];
    
    [[UIMenuController sharedMenuController] setTargetRect:self.frame inView:self.superview];
    
    [[UIMenuController sharedMenuController] setMenuVisible:YES animated: YES];
    
}

@end

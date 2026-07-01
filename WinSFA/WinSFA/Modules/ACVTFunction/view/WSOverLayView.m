//
//  WSOverLayView.m
//  WinSFA
//
//  Created by winchannel on 15/10/20.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSOverLayView.h"

@implementation WSOverLayView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor =[UIColor clearColor];
        // Initialization code
    }
    return self;
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    return [self.delegate overLayView:self didHitPoint:point withEvent:event];
}

@end

//
//  WSLampText.m
//  WinSFA
//
//  Created by huzepei on 17/3/10.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSLampText.h"

@implementation WSLampText

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@synthesize motionWidth;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        motionWidth = 200;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    float w  = self.frame.size.width;
    if (motionWidth>=w) {
        return;
    }
    
    CGRect frame = self.frame;
    frame.origin.x = 320;
    self.frame = frame;
    
    [UIView beginAnimations:@"testAnimation" context:NULL];
    [UIView setAnimationDuration:8.0f * (w<320?320:w) / 320.0 ];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationRepeatAutoreverses:NO];
    [UIView setAnimationRepeatCount: LONG_MAX];
    
    frame = self.frame;
    frame.origin.x = -w ;
    self.frame = frame;
    [UIView commitAnimations];
}

@end

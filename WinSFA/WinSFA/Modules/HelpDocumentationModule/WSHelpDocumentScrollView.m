//
//  WSHelpDocumentScrollView.m
//  WinSFA
//
//  Created by heju on 3/7/14.
//  Copyright (c) 2014 WinChannel. All rights reserved.
//

#import "WSHelpDocumentScrollView.h"

@implementation WSHelpDocumentScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view {
    //yes  将触摸事件传递给相应的subView;
    //no  直接滚动scrollView，不传递触摸事件到subView
    return YES;// NO;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view{

    //no  touch事件由scrollView的subView处理,scrollView不滚动;
    //yes touch事件由scrollView处理，scrollView可滚动
    return NO;// NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

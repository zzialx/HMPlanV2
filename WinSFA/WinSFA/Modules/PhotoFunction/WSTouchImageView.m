//
//  TouchImageView.m
//  PhotoBrowserTest
//
//  Created by Jiepeng Zheng on 12-8-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSTouchImageView.h"

@implementation WSTouchImageView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageTouch:)])
    {
        [self.delegate imageTouch:self];
        NSLog(@"imageTouch");
    }
}

@end

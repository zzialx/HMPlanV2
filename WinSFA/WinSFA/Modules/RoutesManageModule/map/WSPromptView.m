//
//  WCPromptView.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 5/15/13.
//
//

#import "WSPromptView.h"

@interface WSPromptView ()

@property (nonatomic, strong)UILabel *titleLabel;

@end

@implementation WSPromptView
@synthesize titleLabel = _titleLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autoresizesSubviews = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor yellowColor];
        self.center = CGPointMake(self.center.x, -self.center.y);
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.titleLabel = label;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
    }
    return self;
}

- (void)layoutSubviews
{
    CGRect rect = self.bounds;
    self.titleLabel.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
}

- (void)setPrompt:(NSString *)aPrompt
{
    if (self.titleLabel != nil) {
        self.titleLabel.text = aPrompt;
    }
}

- (void)show
{ 
    [UIView animateWithDuration:.35 animations:^{
        self.center = CGPointMake(self.center.x, -self.center.y);
    } completion:^(BOOL finished) {
        if (finished) {
            [self performSelector:@selector(fadeout) withObject:nil afterDelay:2];
        }
    }];
    
}

- (void)fadeout
{
    [UIView animateWithDuration:.5 animations:^{
        self.center = CGPointMake(self.center.x, -self.center.y);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fadeout) object:nil];
}

@end

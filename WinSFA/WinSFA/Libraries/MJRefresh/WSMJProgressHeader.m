//
//  WSMJProgressHeader.m
//  WinSFA
//
//  Created by Alicia on 2017/5/31.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSMJProgressHeader.h"

#define kControlHeight      70
#define kTopPadding         20  // 空出没有导航栏时的高度
#define kContentHeight      (kControlHeight - kTopPadding)
#define kImageLoadingWH     24
#define kAnimationKey       @"rotationAnimation"

@interface WSMJProgressHeader()

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIImageView *loading;
@end

@implementation WSMJProgressHeader

#pragma mark - 重写方法
#pragma mark 在这里做一些初始化配置（比如添加子控件）
- (void)prepare
{
    [super prepare];
    
    // 设置控件的高度
    self.mj_h = kControlHeight;
    
    // 添加label
    UILabel *label = [[UILabel alloc] init];
    label.textColor = DETAIL_TEXT_COLOR;
    label.font = [UIFont systemFontOfSize:FONT_SIZE_DESC];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    self.label = label;
    
    // loading
    UIImageView *loading = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"progress_header"]];
    loading.bounds = CGRectMake(0, kTopPadding, kImageLoadingWH, kImageLoadingWH);
    loading.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:loading];
    self.loading = loading;
}

#pragma mark 在这里设置子控件的位置和尺寸
- (void)placeSubviews
{
    [super placeSubviews];
    
    self.loading.center = CGPointMake(self.mj_w / 2, kTopPadding + kContentHeight * 0.25);
    
    self.label.frame = CGRectMake(0, kTopPadding + kImageLoadingWH, self.bounds.size.width, kContentHeight - kImageLoadingWH);
}

#pragma mark 监听scrollView的contentOffset改变
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];
}

#pragma mark 监听scrollView的contentSize改变
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change
{
    [super scrollViewContentSizeDidChange:change];
}

#pragma mark 监听scrollView的拖拽状态改变
- (void)scrollViewPanStateDidChange:(NSDictionary *)change
{
    [super scrollViewPanStateDidChange:change];
    
}

#pragma mark 监听控件的刷新状态
- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState;
    
    switch (state) {
        case MJRefreshStateIdle:
            [self stopLoading];
            self.label.text = NSLocalizedString(MJRefreshHeaderIdleText, nil);
            break;
        case MJRefreshStatePulling:
            [self stopLoading];
            self.label.text = NSLocalizedString(MJRefreshHeaderPullingText, nil);
            break;
        case MJRefreshStateRefreshing:
            self.label.text = NSLocalizedString(MJRefreshHeaderRefreshingText, nil);
            [self startLoading];
            break;
        default:
            break;
    }
}



#pragma mark - Public Method
- (void)setLoadingProgress:(NSInteger)progress {
    NSString *loading = NSLocalizedString(@"pull_to_refresh_refreshing_label", nil);
    self.label.text = [NSString stringWithFormat:@"%@%ld%%", loading, (long)progress];
}

#pragma mark - Private Method
- (void)startLoading {
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.repeatCount = HUGE_VALF;
    rotationAnimation.duration = 1.2;
    rotationAnimation.cumulative = YES;
    [self.loading.layer addAnimation:rotationAnimation forKey:kAnimationKey];//开始动画
}

- (void)stopLoading {
    if ([self.loading isAnimating]) {
        [self.loading.layer removeAnimationForKey:kAnimationKey];
    }
}
@end

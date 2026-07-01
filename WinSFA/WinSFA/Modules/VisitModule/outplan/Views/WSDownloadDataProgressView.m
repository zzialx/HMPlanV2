//
//  WSDownloadDataProgressView.m
//  WinSFA
//
//  Created by zhangmin on 2018/8/8.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSDownloadDataProgressView.h"
#import "WSLoadingImageView.h"

#define firstParsm 10
#define secondParsm 2
@interface WSDownloadDataProgressView()

//title
@property (nonatomic,strong) UILabel *titleLbl;
@property (nonatomic,assign) NSInteger sum;
@property (nonatomic, strong) NSTimer *listTimer;
@property (nonatomic, strong) WSLoadingImageView *indicatorView;

 @end

@implementation WSDownloadDataProgressView

- (instancetype)initWithSelect:(NSInteger )allNumber
{
    if(self == [super init])
    {
        self.frame = [UIScreen mainScreen].bounds;
        UIView *shadow = [[UIView alloc]initWithFrame:self.frame];
        shadow.alpha = 0.1;
        shadow.backgroundColor = [UIColor blackColor];
        [self addSubview:shadow];
        
        CGFloat h = 90;
        CGFloat w = 170;
        
        CGFloat imageLeft = 15;
        CGFloat imageWH = 20;

        float labelLeft = 50;
        float labelW = 120;
        UIView * imgBackground = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width-w)/2,(self.frame.size.height-h)/2,w,h)];
        imgBackground.layer.cornerRadius = 10;
        imgBackground.alpha = 0.6;
        imgBackground.backgroundColor = [UIColor blackColor];
        [self addSubview:imgBackground];

        CGRect indicatorFrame = CGRectMake((self.frame.size.width-w)/2 + imageLeft ,(self.frame.size.height-imageWH)/2,imageWH,imageWH) ;
        WSLoadingImageView *indicatorView = [[WSLoadingImageView alloc] initWithFrame:indicatorFrame];
        _indicatorView = indicatorView;
        [self addSubview: self.indicatorView];
        [self.indicatorView startAnimating];
        
       
        
        self.titleLbl = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width-w)/2 + labelLeft,(self.frame.size.height-imageWH)/2,labelW,imageWH)];
        self.titleLbl.textColor = [UIColor whiteColor];
        NSString *tipsString = NSLocalizedString(@"load_storelist", nil);
        self.titleLbl.text = [NSString stringWithFormat:@"%@0%%",tipsString];
        self.titleLbl.font = FONT_SIZE_PINGFANG_REGULAR(15);//设置文字类型与大小
        [self addSubview:self.titleLbl];

        _listTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_listTimer forMode:NSRunLoopCommonModes];
       
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storelisetRequestOk) name:@"kGetStoreListData" object:nil];

    }
    return self;
}

- (void)showDownListAlertView
{
    [[[[UIApplication sharedApplication] delegate] window]  addSubview:self];
}
//移除视图
- (void)closeListProgress {
    
    if (self.indicatorView) {
        [self.indicatorView stopAnimating];
    }
    [self removeTimer];
    
    [self removeFromSuperview];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
//虚拟进度条
-(void)timerFired:(NSTimer *)timer {
  self.sum += firstParsm ;
    if (self.sum >= 90) {
        [self removeTimer];
    }
    [self setProgress:self.sum];
  
}
//虚拟进度条
-(void)secondTimerFired:(NSTimer *)timer {
    self.sum += secondParsm;
    if (self.sum > 98) {
        self.sum = 98;
    }
    [self setProgress:self.sum];
}
//请求成功的通知
- (void)storelisetRequestOk {
    self.sum = 90;
    [self setProgress:self.sum];
    [self removeTimer];
    _listTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(secondTimerFired:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_listTimer forMode:NSRunLoopCommonModes];
}
- (void)setProgress:(NSInteger)progress
{
    self.sum = progress;
    
    NSString *tipsString = NSLocalizedString(@"load_storelist", nil);
    NSString *loading = [NSString stringWithFormat:@"%@%ld%%",tipsString,(long)progress];
    self.titleLbl.text = loading;
    if (progress >= 100) {
        [self performSelector:@selector(closeListProgress) withObject:self afterDelay:0.2];
        
    }
}
- (void)removeTimer {
    if (_listTimer) {
        [_listTimer invalidate];
        _listTimer = nil;
    }
}


@end

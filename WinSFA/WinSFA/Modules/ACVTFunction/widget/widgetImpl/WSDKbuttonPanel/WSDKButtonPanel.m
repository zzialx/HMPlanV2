//
//  WSDKButtonPanel.m
//  WinSFA
//
//  Created by mac on 17/8/18.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSDKButtonPanel.h"
#import "WSBaseModel.h"
#import "WSRequestHelper.h"
#import "WSLuaExecutorManager.h"

#define k_DKButton_Height  128
#define k_DKButton_Horizontal_Height  44

#define k_qstNameLabel_X  10
#define k_qstNameLabel_Height  30

#define k_Horizontal_Left_Space 50

#define k_qstNameTitleFont [UIFont systemFontOfSize:26]
#define K_timeTitle__Font [UIFont systemFontOfSize:16];
#define K_Title_Horizontal_Font [UIFont systemFontOfSize:22];
@interface WSDKButtonPanel ()

@property (nonatomic ,strong) UIView * DKButtonView;   // 背景view
@property (nonatomic , strong) UIImageView * DKButtonImageViwe;  // 背景图
@property (nonatomic , strong) UILabel * qstNameLabel;    // 问题名称
@property (nonatomic , strong) UILabel * timeLabel;   // 时间显示
@property (nonatomic , strong) NSTimer * timer;
@property (nonatomic , assign) double countdownTotalSecs;

@end

@implementation WSDKButtonPanel

-(void)buildDisplayContent{
    [super buildDisplayContent];
    
    self.DKButtonView = [[UIView alloc]initWithFrame:CGRectMake(self.centerX - k_DKButton_Height * 0.5, 10, k_DKButton_Height, k_DKButton_Height)];
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
    [self.DKButtonView addGestureRecognizer:tapGesture];
    [self addSubview:_DKButtonView];

    self.DKButtonImageViwe = [[UIImageView alloc]initWithFrame:self.DKButtonView.bounds];
    self.DKButtonImageViwe.image = [UIImage imageNamed:@"icon_round_blue"];
//    [self.DKButtonImageViwe setImage:[UIImage imageNamed:@"icon_online_chat"]];
    [self.DKButtonView addSubview:self.DKButtonImageViwe];
    
    self.qstNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(k_qstNameLabel_X, 1.5 *k_qstNameLabel_Height, k_DKButton_Height - 2 * k_qstNameLabel_X , k_qstNameLabel_Height)];
    self.qstNameLabel.text = [xbuildInfo getQuestName];
    self.qstNameLabel.textColor = [UIColor whiteColor];
    self.qstNameLabel.textAlignment = NSTextAlignmentCenter;
    self.qstNameLabel.font = k_qstNameTitleFont;
    [self.DKButtonView addSubview:self.qstNameLabel];
    
    self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(k_qstNameLabel_X, self.qstNameLabel.bottom , k_DKButton_Height - 2 * k_qstNameLabel_X, k_qstNameLabel_Height)];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.font = K_timeTitle__Font;
   
    [self.DKButtonView addSubview:self.timeLabel];

    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, k_DKButton_Height + 20)];
    
    //  MN-102  蒙牛添加 水平布局 add by 支庆
    if ([xbuildInfo getOrientation] && [[xbuildInfo getOrientation] isEqualToString:@"1"]) {
        
        self.DKButtonImageViwe.image = [UIImage imageNamed:@"bg_btn_green"];
        self.qstNameLabel.font = K_Title_Horizontal_Font;
        self.timeLabel.font = K_Title_Horizontal_Font;
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, k_DKButton_Horizontal_Height + 20)];
    }
  

    /*
     2017-10-27 Jira-winSFAMSTD-6683 by  孙洪福
     通过字段控制和其他项目冲突支庆项目初始化timer其他不初始化
     */
    if ([xbuildInfo getQstDescription].length == 0) {
        self.timeLabel.text = [WSCurrentTime getShortTimeString];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimeLabel) userInfo:nil repeats:YES];
    }
    
    UIColor *bgColor = [UIColor colorForKey:@"AcvtViewBackgroundColor"];
    if (!bgColor) {
        bgColor = [UIColor clearColor];
    }
    self.backgroundColor = bgColor;
}

#pragma mark - 重写layoutSubviews方法 (MSTD-6638 增加布局剧中处理)
- (void)layoutSubviews
{
    [super layoutSubviews];
    BOOL isHorizontal = NO;
    if ([xbuildInfo getOrientation] && [[xbuildInfo getOrientation] isEqualToString:@"1"]) {
        isHorizontal = YES;
    }
    
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = 0;
    CGFloat h = 0;
   
    if (isHorizontal)
    {
        x = k_Horizontal_Left_Space;
        y = (self.height - k_DKButton_Horizontal_Height) * 0.5;
        w = self.width - 2 * k_Horizontal_Left_Space;
        h = k_DKButton_Horizontal_Height;
    }else{
        x = (CGRectGetWidth(self.frame) - CGRectGetWidth(self.DKButtonView.frame)) / 2;
        y = (CGRectGetHeight(self.frame) - CGRectGetHeight(self.DKButtonView.frame)) / 2;
        w = CGRectGetWidth(self.DKButtonView.frame);
        h = CGRectGetHeight(self.DKButtonView.frame);
    }
   
    self.DKButtonView.frame = CGRectMake(x, y, w, h);

    if (isHorizontal)
    {
        x = 0;
        y = 0;
        w = self.width - 2 * k_Horizontal_Left_Space;
        h = k_DKButton_Horizontal_Height;
    }else{
        x = (CGRectGetWidth(self.DKButtonView.frame) - CGRectGetWidth(self.DKButtonImageViwe.frame)) / 2;
        y = (CGRectGetHeight(self.DKButtonView.frame) - CGRectGetHeight(self.DKButtonImageViwe.frame)) / 2;
        w = CGRectGetWidth(self.DKButtonImageViwe.frame);
        h = CGRectGetHeight(self.DKButtonImageViwe.frame);
    }
 
    self.DKButtonImageViwe.frame = CGRectMake(x, y, w, h);
    
    if (isHorizontal)
    {
        x = (self.DKButtonView.width - CGRectGetWidth(self.qstNameLabel.frame) - CGRectGetWidth(self.timeLabel.frame)) * 0.5 ;
        y = (self.DKButtonView.height - CGRectGetHeight(self.qstNameLabel.frame)) * 0.5;
        w = CGRectGetWidth(self.qstNameLabel.frame);
        h = CGRectGetHeight(self.qstNameLabel.frame);
    }else{
        CGFloat height = CGRectGetHeight(self.qstNameLabel.frame) + CGRectGetHeight(self.timeLabel.frame);
        x = (CGRectGetWidth(self.DKButtonView.frame) - CGRectGetWidth(self.qstNameLabel.frame)) / 2;
        y = (CGRectGetHeight(self.DKButtonView.frame) - height) / 2;
        w = CGRectGetWidth(self.qstNameLabel.frame);
        h = CGRectGetHeight(self.qstNameLabel.frame);
    }
   
    self.qstNameLabel.frame = CGRectMake(x, y, w, h);

    
    if (isHorizontal)
    {
        x = self.qstNameLabel.right;
        y = (self.DKButtonView.height - CGRectGetHeight(self.qstNameLabel.frame)) * 0.5;
        w = CGRectGetWidth(self.timeLabel.frame);
        h = CGRectGetHeight(self.timeLabel.frame);
    }else{
        x = (CGRectGetWidth(self.DKButtonView.frame) - CGRectGetWidth(self.timeLabel.frame)) / 2;
        y = CGRectGetMaxY(self.qstNameLabel.frame);
        w = CGRectGetWidth(self.timeLabel.frame);
        h = CGRectGetHeight(self.timeLabel.frame);
    }
    
    self.timeLabel.frame = CGRectMake(x, y, w, h);
    
}

-(void)updateTimeLabel{
    self.timeLabel.text = [WSCurrentTime getShortTimeString];
}

-(void)tapClick:(UITapGestureRecognizer *)gesture{
    
    [self.timer invalidate];
    self.timer = nil;
    
    NSString *luaScript = [xbuildInfo getLuaScript];
    if (luaScript && [luaScript length] > 0) {
        
        //MN-4140
        if ([luaScript containsString:@"function excuseAction("]) {
            if ([self.delegate respondsToSelector:@selector(executeLuaScript:script:functionName:widget:)]) {
                [self.delegate executeLuaScript:xbuildInfo script:luaScript funcName:@"function excuseAction(" widget:self];
            }
            return;
        }

        if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
            [self.delegate executeLuaScript:xbuildInfo widget:self];
        }
    }
}


-(void)setImgUrl:(NSString *)imageUrl{
    
    if (imageUrl.length > 0) {
        [[WSRequestHelper shareInstance] downloadImageWithUrl:[WSHttpURLHelper getImageCompleteURL:imageUrl] imageView:self.DKButtonImageViwe];
    }
}

- (void)setReadonly:(NSString *)isReadonly
{
    [super setReadonly:isReadonly];
    self.DKButtonView.userInteractionEnabled = YES;

    if([isReadonly isEqualToString:@"true"]){
        self.DKButtonView.userInteractionEnabled = NO;
        self.DKButtonImageViwe.image = [UIImage imageNamed:@"bg_round_grey"];
    }
}

-(void)setTitle:(NSString*)title
{
    self.qstNameLabel.text = title;
}

-(NSString *)getTitle
{
    return self.qstNameLabel.text;
}

//MN-3255 2018-07-14
- (void)showDialog:(NSString *)dialog
{
    BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:((dialog.length > 0) ? dialog : @"")];
    [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:nil];
    [alert addButtonWithTitle:NSLocalizedString(@"confirm_label", nil) block:^{
        
        _resultCheck = @"confirm";
        NSString *script = [WSLuaExecutorManager getSubLuaScriptWith:[xbuildInfo getLuaScript] ByFuntionName:@"function confirm("];
        if ([self.delegate respondsToSelector:@selector(executeLuaScript:script:widget:)] && (script.length > 0))
            [self.delegate executeLuaScript:xbuildInfo script:script widget:self];
    }];
    [alert show];
}

-(void)dealloc{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)setRange:(NSString *)timeRange
{
    
    self.DKButtonView.userInteractionEnabled = NO;
    _countdownTotalSecs = [timeRange doubleValue]/1000.0;
    [self.timer invalidate];
    self.timer = nil;
    
    if ([self.viewController isKindOfClass:[BaseViewController class]]) {
        BaseViewController *baseVC = (BaseViewController *)self.viewController;
        
        if (!(baseVC.currentFuncs.unredo == 1 && [baseVC.model.datasFromDB count] > 0)) {
          /*
           2017-10-27 Jira-winSFAMSTD-6683 by  孙洪福
           self.timer = nil 是支庆项目初始化控件时候初始化了一个正计时的timer 置空了他的
           _countdownTotalSecs++作用是将countdown--的加回来,保证初始值正确
           [self countdown]是保证视图出现时 实时显示数据 防止延后一秒的问题
           */
            self.timer = nil;
            _countdownTotalSecs++;
            [self countdown];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countdown) userInfo:nil repeats:YES];
        }
    }
    
}

- (void)countdown
{
    _countdownTotalSecs --;
    NSInteger secondsCountDown = [[NSNumber numberWithDouble:_countdownTotalSecs] integerValue];
//    NSString *str_hour = [NSString stringWithFormat:@"%02ld",secondsCountDown/3600];
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(secondsCountDown%3600)/60];
    NSString *str_second = [NSString stringWithFormat:@"%02ld",secondsCountDown%60];
    NSString *format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
//    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    //修改倒计时标签现实内容
    self.timeLabel.text=[NSString stringWithFormat:@"%@",format_time];

    if (_countdownTotalSecs <= 0) {
        
        [self.timer invalidate];
        self.timer = nil;
        
        NSString *luaScript = [xbuildInfo getLuaScript];
        if (luaScript && [luaScript length] > 0) {
            if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
                [self.delegate executeLuaScript:xbuildInfo widget:self];
            }
        }

    }
}

@end

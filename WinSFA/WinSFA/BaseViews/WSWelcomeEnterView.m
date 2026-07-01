//
//  WSWelcomeEnterView.m
//  WinSFA
//
//  Created by huzp on 16/6/1.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#define User_Font  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 17.0f : 17.0f)
#define Welcome_Font  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 19.0f : 19.0f)
#define LogoImageY ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 34.0f : 34.0f)
#define LogoImageWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 88.0f : 88.0f )
#define LoginImageHeight ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 88.0f : 88.0f)

#define UIColorFromRGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

#define LabelHeight 25
#define labelMagin  15



#import "WSWelcomeEnterView.h"
@interface WSWelcomeEnterView()

@property (nonatomic,strong) UIView *backView;

@property (nonatomic,strong) UIImageView *welcomeBackView;

@property (nonatomic,strong) UIButton *enterBtn;

@end

@implementation WSWelcomeEnterView

#pragma mark -init
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _backView=[[UIView alloc] initWithFrame:frame];
        _backView.backgroundColor=[UIColor blackColor];
        _backView.alpha= 0.0f;
        [self addSubview:_backView];
        
        UIImage* welcomeImage=[UIImage imageForName:@"welcome"];
        
        _welcomeBackView =[[UIImageView alloc] initWithFrame:CGRectMake((self.width-welcomeImage.size.width)/2, self.height, welcomeImage.size.width, welcomeImage.size.height)];
        
        _welcomeBackView.image= welcomeImage;
        _welcomeBackView.userInteractionEnabled = YES;
        _welcomeBackView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_welcomeBackView];
        
        _welcomeBackView.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        
    
        NSString *path = [[NSBundle mainBundle] pathForResource:@"logo_welcome" ofType:@"png"];
        UIImage *logoImage = [UIImage imageWithContentsOfFile:path];
        
        UIImageView* logoImageView=[[UIImageView alloc] initWithFrame:CGRectMake((_welcomeBackView.width-LogoImageWidth)/2, LogoImageY, LogoImageWidth, LoginImageHeight)];
        logoImageView.image=logoImage;
        [_welcomeBackView addSubview:logoImageView];

        UILabel* userNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(logoImageView.frame) + labelMagin, _welcomeBackView.width, LabelHeight)];
        /* 显示为其ID
         userNameLabel.text=[NSString stringWithFormat:@"Hi, %@",[[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_CALL_APP]];
         */
        /*
         修改为显示其登陆名字
         */
        userNameLabel.text = [NSString stringWithFormat:@"HI! %@",[WSAppData getObjectbyKey:EMPNAME]];
        userNameLabel.textColor = [UIColor blackColor];
        
        userNameLabel.font=[UIFont systemFontOfSize:User_Font];
        userNameLabel.textAlignment=NSTextAlignmentCenter;
        userNameLabel.backgroundColor=[UIColor clearColor];
        [_welcomeBackView addSubview:userNameLabel];
        
        UILabel* welcomeLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(userNameLabel.frame), _welcomeBackView.width, LabelHeight)];

        NSString *text;
        if ([[UIDevice getPreferredLanguage] isEqualToString:@"ja_JP"]) {
            text = [NSString stringWithFormat:@"%@ %@", APP_DISPLAY_NAME, NSLocalizedString(@"welcome_enter", nil)];
            
        }else {
            text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"welcome_enter", nil), APP_DISPLAY_NAME];
        }
        
        welcomeLabel.text=text;
//        welcomeLabel.textColor = [UIColor colorForKey:@"welcomeViewTitleColor"];
        welcomeLabel.textColor = [UIColor blackColor];
        
        welcomeLabel.font=[UIFont systemFontOfSize:Welcome_Font];
        welcomeLabel.textAlignment=NSTextAlignmentCenter;
        welcomeLabel.backgroundColor=[UIColor clearColor];
        [_welcomeBackView addSubview:welcomeLabel];
        
        UILabel *timeLabel =[[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(welcomeLabel.frame),_welcomeBackView.width, LabelHeight)];
        NSString *currentDate = [WSCurrentTime getDateTimeWithOutTime];
        timeLabel.text = currentDate;
        timeLabel.font =[UIFont systemFontOfSize:14];
        timeLabel.textColor = [UIColor grayColor];
        
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.backgroundColor = [UIColor clearColor];
        [_welcomeBackView addSubview:timeLabel];
        
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = UIColorFromRGB(233,233,233);
        lineView.frame = CGRectMake(0, CGRectGetMaxY(timeLabel.frame) + labelMagin, _welcomeBackView.width, 1.0);
        [_welcomeBackView addSubview:lineView];
        
        
        _enterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        CGFloat enterHeight= _welcomeBackView.height - CGRectGetMaxY(lineView.frame);
        
        _enterBtn.frame = CGRectMake(0, CGRectGetMaxY(lineView.frame), _welcomeBackView.width, enterHeight);
        
        [_enterBtn setTitle:NSLocalizedString(@"into", nil) forState:UIControlStateNormal];
        [_enterBtn setTitleColor:MAIN_TINT_COLOT forState:UIControlStateNormal];
        
        [_enterBtn addTarget:self action:@selector(enter) forControlEvents:UIControlEventTouchUpInside];
        [_enterBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:INTERFACE_IS_PHONE ? 18 : 20]];
        
        [_welcomeBackView addSubview:_enterBtn];
    
        
        [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _welcomeBackView.centerY=self.height/2;
            _backView.alpha=0.7f;
        } completion:nil];
        
        [self performSelector:@selector(enter) withObject:nil afterDelay:2.0f];
    }
    return self;
}

-(void)enter
{
    [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _welcomeBackView.bottom=0;
        _backView.alpha=0.0f;
    } completion:^(BOOL finish){
        [self removeFromSuperview];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"removeWelcomeView" object:nil];
    }];
}

@end

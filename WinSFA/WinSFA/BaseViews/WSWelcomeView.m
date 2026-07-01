//
//  WSWelcomeView.m
//  WinSFA
//
//  Created by zhangke on 14/7/1.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#define User_Font  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 17.0f : 20.0f)
#define Welcome_Font  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 19.0f : 25.0f)
#define LogoImageY ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 0.0f : 10.0f)
#define LogoImageWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 270.0f : 385.0f )
#define LoginImageHeight ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 97.0f : 116.0f)

#import "WSWelcomeView.h"

@interface WSWelcomeView (){
    UIView* backView;
    UIImageView* welcomeBackView;
}

@end

@implementation WSWelcomeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        backView=[[UIView alloc] initWithFrame:frame];
        backView.backgroundColor=[UIColor blackColor];
        backView.alpha=0.0f;
        [self addSubview:backView];
        
        UIImage* welcomeImage=[UIImage imageForName:@"welcome"];
        welcomeBackView=[[UIImageView alloc] initWithFrame:CGRectMake((self.width-welcomeImage.size.width)/2, self.height, welcomeImage.size.width, welcomeImage.size.height)];
        welcomeBackView.image=welcomeImage;
        [self addSubview:welcomeBackView];
        welcomeBackView.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"logo_welcome" ofType:@"png"];
        UIImage *logoImage = [UIImage imageWithContentsOfFile:path];
        UIImageView* logoImageView=[[UIImageView alloc] initWithFrame:CGRectMake((welcomeBackView.width-LogoImageWidth)/2, LogoImageY, LogoImageWidth, LoginImageHeight)];
        logoImageView.image=logoImage;
        [welcomeBackView addSubview:logoImageView];
        
        UILabel* userNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(logoImageView.frame), welcomeBackView.width, 30)];
        /* 显示为其ID
        userNameLabel.text=[NSString stringWithFormat:@"Hi, %@",[[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_CALL_APP]];
         */
        /*
         修改为显示其登陆名字
         */
        userNameLabel.text = [NSString stringWithFormat:@"Hi, %@",[WSAppData getObjectbyKey:EMPNAME]];
        userNameLabel.textColor = [UIColor colorForKey:@"welcomeViewTitleColor"];
        userNameLabel.font=[UIFont systemFontOfSize:User_Font];
        userNameLabel.textAlignment=NSTextAlignmentCenter;
        userNameLabel.backgroundColor=[UIColor clearColor];
        [welcomeBackView addSubview:userNameLabel];
        
        UILabel* welcomeLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(userNameLabel.frame), welcomeBackView.width, 30)];
        
        NSString *text;
        if ([[UIDevice getPreferredLanguage] isEqualToString:@"ja_JP"]) {
            text = [NSString stringWithFormat:@"%@ %@", APP_DISPLAY_NAME, NSLocalizedString(@"welcome", nil)];
            
        }else {
            text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"welcome", nil), APP_DISPLAY_NAME];
        }
        
        welcomeLabel.text=text;
        welcomeLabel.textColor = [UIColor colorForKey:@"welcomeViewTitleColor"];
        welcomeLabel.font=[UIFont systemFontOfSize:Welcome_Font];
        welcomeLabel.textAlignment=NSTextAlignmentCenter;
        welcomeLabel.backgroundColor=[UIColor clearColor];
        [welcomeBackView addSubview:welcomeLabel];
        
        UILabel *timeLabel =[[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(welcomeLabel.frame),welcomeBackView.width, 32)];
        NSString *currentDate = [WSCurrentTime currentDay];
        timeLabel.text = currentDate;
        timeLabel.font =[UIFont systemFontOfSize:User_Font];
        timeLabel.textColor = [UIColor colorForKey:@"welcomeViewTitleColor"];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.backgroundColor = [UIColor clearColor];
        [welcomeBackView addSubview:timeLabel];
        
        [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            welcomeBackView.centerY=self.height/2;
            backView.alpha=0.7f;
        } completion:nil];
        
        [self performSelector:@selector(removeSelf) withObject:nil afterDelay:3.0f];
    }
    return self;
}

-(void)removeSelf
{
    [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        welcomeBackView.bottom=0;
        backView.alpha=0.0f;
    } completion:^(BOOL finish){
        [self removeFromSuperview];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"removeWelcomeView" object:nil];
    }];
}


@end

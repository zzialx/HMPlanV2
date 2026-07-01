//
//  WCNavBar.h
//  QuadCore
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import "WCBaseView.h"

#define NAV_BAR_HEIGHT 51

#define NAV_BAR_SIZE CGSizeMake(49,49)

#define NAV_BAR_LOGO_SIZE CGSizeMake(49,49)

#define NAV_BAR_INDICATOR_SIZE CGSizeMake(30,30)

#define NAV_BAR_INDICATOR_RIGHTPADING 5

#define NAV_BAR_TITLE_FONT (16.0f)

@interface WCNavBar : WCBaseView
{
    NSString *_title;
    UILabel *_titleLabel;
    UIButton *_leftButton;
    UIButton *_rightButton;
    UIActivityIndicatorView *_indicatorView;
    UILabel *_indicatorLabel;
    UIImageView *_logoView;
}

@property(nonatomic,copy)NSString *title;
@property(nonatomic,retain)UILabel *titleLabel;
@property(nonatomic,retain)UIButton *leftButton;
@property(nonatomic,retain)UIButton *rightButton;
@property(nonatomic,retain)UIActivityIndicatorView *indicatorView;
@property(nonatomic,retain)UILabel *indicatorLabel;
@property(nonatomic,retain)UIImageView *logoView;

/**
 * 显示菊花跟对应text的Label
 */
-(void)showActivityWithText:(NSString*)text;

/**
 * 显示菊花在title的左边
 */
-(void)showAcitvityLeftTitle;

-(void)hideActivity;


@end

//
//  WCNavBar.m
//  QuadCore
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import "WCNavBar.h"



@implementation WCNavBar

@synthesize title = _title;
@synthesize titleLabel = _titleLabel;
@synthesize leftButton = _leftButton;
@synthesize rightButton = _rightButton;
@synthesize indicatorView = _indicatorView;
@synthesize indicatorLabel = _indicatorLabel;
@synthesize logoView = _logoView;


-(void)dealloc
{
    self.title = nil;
    self.titleLabel = nil;
    self.leftButton = nil;
    self.rightButton = nil;
    self.indicatorView = nil;
    self.indicatorLabel = nil;
    self.logoView = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UILabel *tLabel = [[UILabel alloc] initWithFrame:CGRectMake(NAV_BAR_SIZE.width, 0, frame.size.width - NAV_BAR_SIZE.width*2, frame.size.height)];
        tLabel.textAlignment = UITextAlignmentCenter;
//        tLabel.font = [UIFont standardFontForSize:NAV_BAR_TITLE_FONT isBold:YES];
//        tLabel.textColor = [UIColor colorForKey:@"CommonModule-colorTypeA"];
        tLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel = tLabel;
        [self addSubview:self.titleLabel];

        UIButton *lBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, NAV_BAR_SIZE.width, NAV_BAR_SIZE.height)];
        [lBtn setHidden:YES];
        [lBtn setImage:[UIImage imageForName:@"nav_bar_back"] forState:UIControlStateNormal];
        [lBtn setImage:[UIImage imageForName:@"nav_bar_back_hl"] forState:UIControlStateHighlighted];
        self.leftButton = lBtn;
        [self.leftButton setHidden:YES];
        [self addSubview:self.leftButton];

        UIButton *rBtn = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - NAV_BAR_SIZE.width, 0, NAV_BAR_SIZE.width, NAV_BAR_SIZE.height)];
        [rBtn setHidden:YES];
        self.rightButton = rBtn;
        [self addSubview:self.rightButton];

        UIImage *bgImage = [UIImage imageForName:@"nav_bar_bg"];
        UIColor *bgColor = [UIColor colorWithPatternImage:bgImage];
        self.backgroundColor =bgColor;
        self.opaque = NO;
    }
    return self;
}


-(UIImageView *)logoView
{
    if(_logoView == nil)
    {
        _logoView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - NAV_BAR_LOGO_SIZE.width)/2, (self.frame.size.height - NAV_BAR_LOGO_SIZE.height)/2, NAV_BAR_LOGO_SIZE.width, NAV_BAR_LOGO_SIZE.height)];
        [self addSubview:_logoView];
    }
    return _logoView;
}


-(UIActivityIndicatorView *)indicatorView
{
    if(_indicatorView == nil)
    {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - NAV_BAR_INDICATOR_SIZE.height)/2, NAV_BAR_INDICATOR_SIZE.width, NAV_BAR_INDICATOR_SIZE.height)];
        _indicatorView.activityIndicatorViewStyle =  UIActivityIndicatorViewStyleGray;
        [self addSubview:_indicatorView];
    }
    return _indicatorView;
}

-(UILabel *)indicatorLabel
{
    if(_indicatorLabel == nil)
    {
//        UIFont *font = [UIFont standardFontForSize:NAV_BAR_TITLE_FONT isBold:YES];
        _indicatorLabel = [[UILabel alloc] init];
//        _indicatorLabel.font = font;
//        _indicatorLabel.textColor = [UIColor colorForKey:@"CommonModule-colorTypeA"];
//        _indicatorLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_indicatorLabel];
    }
    return _indicatorLabel;
}


#pragma indicatorView method

-(void)showActivityWithText:(NSString*)text
{
//    UIFont *font = [UIFont standardFontForSize:NAV_BAR_TITLE_FONT isBold:YES];
//    CGSize textSize = [text sizeWithFont:font];
    
    CGRect frame = self.indicatorView.frame;
//    frame.origin.x = (PHONE_SCREEN_SIZE.width - textSize.width - NAV_BAR_INDICATOR_RIGHTPADING - NAV_BAR_INDICATOR_SIZE.width)/2;
    
    self.indicatorView.frame = frame;
    
//    frame = CGRectMake(0, (self.frame.size.height - textSize.height)/2, textSize.width, textSize.height);
    frame.origin.x = self.indicatorView.frame.origin.x + NAV_BAR_INDICATOR_RIGHTPADING + NAV_BAR_INDICATOR_SIZE.width;
    
    self.indicatorLabel.frame = frame;
    self.indicatorLabel.text = text;
    
    [self.indicatorView startAnimating];
    
    [self.titleLabel setHidden:YES];
}

-(void)showAcitvityLeftTitle
{
    CGSize textSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font];
    
    CGRect frame = self.indicatorView.frame;
    frame.origin.x = (PHONE_SCREEN_SIZE.width - textSize.width)/2 - NAV_BAR_INDICATOR_RIGHTPADING - NAV_BAR_INDICATOR_SIZE.width;
    
    self.indicatorView.frame = frame;
    
    [self.indicatorView startAnimating];
}

-(void)hideActivity
{
    [self.indicatorView stopAnimating];
    [self.indicatorView removeFromSuperview];
    self.indicatorView = nil;
    
    [self.indicatorLabel removeFromSuperview];
    self.indicatorLabel = nil;
    
    [self.titleLabel setHidden:NO];
}

-(void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = _title;
}

@end

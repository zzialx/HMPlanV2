//
//  WSLeftBottomButton.m
//  WinSFA
//
//  Created by Stephanie on 16/8/17.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSLeftBottomButton.h"

#define kImageViewLeftSapce 6.0f
#define kImageViewWidth 28.0f
#define kImageViewHeight 28.0f
#define kLabelLeftGap 6.0f

#define kEventLabelWidth 22.0f
#define kEventLabelHeight 17.0f
#define kEventLabelRightSpace 5.0f

@interface WSLeftBottomButton ()

@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *eventCountLabel;

@end

@implementation WSLeftBottomButton

- (instancetype)initWithFrame:(CGRect)frame funcsBean:(WSFuncsBean *)funcsBean
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _funcsBean = funcsBean;
        
        self.backgroundColor = [UIColor colorForKey:@"LeftBottomCellBackgroundColor"];
//        self.clipsToBounds = YES;
        self.layer.cornerRadius = 5;
        
        
        self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kImageViewLeftSapce, (kMainBottomCellHeight - kImageViewHeight)/2, kImageViewWidth, kImageViewHeight)];
        self.iconImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:self.iconImageView];
        [self.iconImageView setImage:[UIImage imageForName:[NSString stringWithFormat:@"%@_ipad.png", [funcsBean fv]]]];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.iconImageView.right + kLabelLeftGap, 0, kMainBottomCellWidth - kImageViewLeftSapce - kImageViewWidth - kLabelLeftGap, kMainBottomCellHeight)];
        [self.titleLabel setBackgroundColor:[UIColor clearColor]];
        [self.titleLabel setTextColor:[UIColor whiteColor]];
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:UI_LeftView_Font]];
        [self addSubview:self.titleLabel];
        [self.titleLabel setText:funcsBean.name];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected) {
        self.backgroundColor = [UIColor colorForKey:@"LeftViewCellSelectedBackgroundColor"];
        [self.iconImageView setImage:[UIImage imageForName:[NSString stringWithFormat:@"%@_ipad_hl.png", [self.funcsBean fv]]]];
        
        if (self.isBottomButton) {
            self.backgroundColor = [UIColor colorForKey:@"LeftViewCellSelectedBackgroundColor"];
            [self.titleLabel setTextColor:[UIColor grayColor]];
            [self.iconImageView setImage:[UIImage imageForName:[NSString stringWithFormat:@"%@_ipad.png", [self.funcsBean fv]]]];
        }
        
    }else {
        self.backgroundColor = [UIColor colorForKey:@"LeftBottomCellBackgroundColor"];
        [self.iconImageView setImage:[UIImage imageForName:[NSString stringWithFormat:@"%@_ipad.png", [self.funcsBean fv]]]];
        
        if (self.isBottomButton) {
            [self.titleLabel setTextColor:[UIColor whiteColor]];
        }
    }
    

}

- (void)setEventIdentifer:(NSString *)identifer
{
    if (self.eventCountLabel == nil) {
        self.eventCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(kMainBottomCellWidth + kEventLabelRightSpace - kEventLabelWidth, -kEventLabelRightSpace, kEventLabelWidth, kEventLabelHeight)];
        UIColor *bgColor = [UIColor colorForKey:@"LeftViewCellIdentiferBackgroundColor"];
        if (!bgColor) {
            bgColor = [UIColor whiteColor];
        }
        UIColor *titleColor = [UIColor colorForKey:@"LeftViewCellIdentiferTitleColor"];
        if (!titleColor) {
            titleColor = MAIN_TINT_COLOT;
        }
        [self.eventCountLabel setBackgroundColor:bgColor];
        [self.eventCountLabel setTextColor:titleColor];
        [self.eventCountLabel setFont:[UIFont systemFontOfSize:12]];
        [self.eventCountLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:self.eventCountLabel];
        self.eventCountLabel.layer.cornerRadius = kEventLabelHeight / 2.0;
        self.eventCountLabel.clipsToBounds = YES;
    }
    
    if (identifer) {
        self.eventCountLabel.hidden = NO;
    }
    else
    {
        self.eventCountLabel.hidden = YES;
    }
    [self.eventCountLabel setText:identifer];
}



@end

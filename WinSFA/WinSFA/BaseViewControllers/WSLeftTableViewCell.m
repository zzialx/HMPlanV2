//
//  WSLeftTableViewCell.m
//  WinSFA
//
//  Created by yang on 14-4-21.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSLeftTableViewCell.h"
#import "WSMainLeftView.h"

#define kImageViewLeftSapce 15.0f
#define kImageViewWidth 28.0f
#define kImageViewHeight 28.0f
#define kLabelLeftGap 5.0f
#define kEventLabelWidth 22.0f
#define kEventLabelHeight 18.0f
#define kEventLabelRightSpace 5.0f

@implementation WSLeftTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (highlighted) {
        UIColor *selectedBgColor = [UIColor colorForKey:@"LeftViewCellSelectedBackgroundColor"];
        if (!selectedBgColor) {
            selectedBgColor = [UIColor whiteColor];
        }
        
        UIColor *selectedTitleColor = [UIColor colorForKey:@"LeftViewCellSelectedTitleColor"];
        if (!selectedTitleColor) {
            selectedTitleColor = [UIColor colorWithRed:129.0/255.0 green:130.0/255.0 blue:132.0/255.0 alpha:1.0];
        }
        
//        [self.contentView setBackgroundColor: selectedBgColor];
    }
    else
    {
//        [self.contentView setBackgroundColor:[UIColor clearColor]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (selected) {
        UIColor *selectedBgColor = [UIColor colorForKey:@"LeftViewCellSelectedBackgroundColor"];
        if (!selectedBgColor) {
            selectedBgColor = [UIColor whiteColor];
        }
        
        UIColor *selectedTitleColor = [UIColor colorForKey:@"LeftViewCellSelectedTitleColor"];
        if (!selectedTitleColor) {
            selectedTitleColor = [UIColor colorWithRed:129.0/255.0 green:130.0/255.0 blue:132.0/255.0 alpha:1.0];
        }
        
        [self.contentView setBackgroundColor: selectedBgColor];
        [self.titleLabel setTextColor: selectedTitleColor];
        [self.iconImageView setImage:[UIImage imageForName:[NSString stringWithFormat:@"%@_ipad_hl.png", self.funcsBean.fv]]];
        
        UIColor *bgColor = [UIColor colorForKey:@"LeftViewCellIdentiferBackgroundColor"];
        if (!bgColor) {
            bgColor = MAIN_TINT_COLOT;
        }
        UIColor *titleColor = [UIColor colorForKey:@"LeftViewCellIdentiferTitleColor"];
        if (!titleColor) {
            titleColor = [UIColor whiteColor];
        }

        [self.eventCountLabel setTextColor:titleColor];
        [self.eventCountLabel setBackgroundColor:bgColor];
    }
    else
    {
        UIColor *normalTitleColor = [UIColor colorForKey:@"LeftViewCellNormalTitleColor"];
        if (!normalTitleColor) {
            normalTitleColor = [UIColor whiteColor];
        }
        
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        [self.titleLabel setTextColor:normalTitleColor];
        [self.iconImageView setImage:[UIImage imageForName:[NSString stringWithFormat:@"%@_ipad.png", self.funcsBean.fv]]];
        
        UIColor *bgColor = [UIColor colorForKey:@"LeftViewCellIdentiferBackgroundColor"];
        if (!bgColor) {
            bgColor = [UIColor whiteColor];
        }
        UIColor *titleColor = [UIColor colorForKey:@"LeftViewCellIdentiferTitleColor"];
        if (!titleColor) {
            titleColor = MAIN_TINT_COLOT;
        }
        [self.eventCountLabel setTextColor:titleColor];
        [self.eventCountLabel setBackgroundColor:bgColor];
    }
}

- (void)setData:(WSFuncsBean *)funcsBean
{
    if (self.funcsBean != funcsBean) {
        self.funcsBean = funcsBean;
    }
    
    if (self.iconImageView == nil) {
        self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kImageViewLeftSapce, (kLeftViewCellHeight - kImageViewHeight)/2, kImageViewWidth, kImageViewHeight)];
        self.iconImageView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:self.iconImageView];
    }
    [self.iconImageView setImage:[UIImage imageForName:[NSString stringWithFormat:@"%@_ipad.png", [funcsBean fv]]]];
    
    if (self.titleLabel == nil) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.iconImageView.right + kLabelLeftGap, 0, k_MainkLeftVieWidth - (self.iconImageView.right + kLabelLeftGap), kLeftViewCellHeight)];
        [self.titleLabel setBackgroundColor:[UIColor clearColor]];
        
        UIColor *titleColor = [UIColor colorForKey:@"LeftViewCellNormalTitleColor"];
        if (!titleColor) {
            titleColor = [UIColor whiteColor];
        }
        
        [self.titleLabel setTextColor:titleColor];
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:UI_LeftView_Font]];
        [self.contentView addSubview:self.titleLabel];
    }
    [self.titleLabel setText:funcsBean.name];
    
    [self setEventIdentifer:funcsBean.eventIdentifer];
    
    UIColor *lineColor = [UIColor colorForKey:@"LeftViewCellSeparatorLineColor"];
    
    if (lineColor) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, kLeftViewCellHeight - 1, k_MainkLeftVieWidth, 1)];
        line.backgroundColor = lineColor;
        [self.contentView addSubview:line];
    }
}

- (void)setEventIdentifer:(NSString *)identifer
{
    if (self.eventCountLabel == nil) {
        self.eventCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(k_MainkLeftVieWidth - kEventLabelRightSpace - kEventLabelWidth, (kLeftViewCellHeight - kEventLabelHeight)/2, kEventLabelWidth, kEventLabelHeight)];
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
        [self.contentView addSubview:self.eventCountLabel];
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

- (void)setValueChanged:(BOOL)changed
{
    if (self.ValueChangedLabel == nil) {
        self.ValueChangedLabel = [[UILabel alloc] initWithFrame:CGRectMake(k_MainkLeftVieWidth  - kEventLabelWidth - kEventLabelRightSpace, (kLeftViewCellHeight - kEventLabelWidth)/2, kEventLabelWidth, kEventLabelWidth)];
        [self.ValueChangedLabel setBackgroundColor:[UIColor whiteColor]];
        [self.ValueChangedLabel setTextColor:[UIColor redColor]];
        [self.ValueChangedLabel setFont:[UIFont systemFontOfSize:20]];
        [self.ValueChangedLabel setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:self.ValueChangedLabel];
        self.ValueChangedLabel.layer.cornerRadius = kEventLabelWidth / 2.0;
        self.ValueChangedLabel.clipsToBounds = YES;
        self.ValueChangedLabel.text = @"!";
    }
    
    if (changed) {
        self.ValueChangedLabel.hidden = NO;
    }
    else
    {
        self.ValueChangedLabel.hidden = YES;
    }
}



@end

//
//  WSNewAddProdsWithSeriesLeftTableViewCell.m
//  WinSFA
//
//  Created by HZH on 2017/9/16.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSNewAddProdsWithSeriesLeftTableViewCell.h"

#define kLeftTableCellTextSize 14.0

#define kLeftTableCellBadgeLabelHeightScale     0.30
#define kLeftTableCellBadgeLabelWidthScale      0.28

#define kGridCellTextdDefaultColor        ([UIColor colorForKey:@"WorkFlowSectionHeaderViewTitle"] ? [UIColor colorForKey:@"WorkFlowSectionHeaderViewTitle"] : kGridCellTextColor)
#define kGridCellTextSelectColor        ([UIColor colorForKey:@"GridCellTextSelectColor"] ? [UIColor colorForKey:@"GridCellTextSelectColor"] : MAIN_TINT_COLOR)

#define kGridCellTextdDefaultFont          ([UIFont fontForKey:@"WorkFlowSectionHeaderViewTitle"] ? [UIFont fontForKey:@"WorkFlowSectionHeaderViewTitle"] : [UIFont fontWithName:@"PingFangSC-Medium" size:kLeftTableCellTextSize])

#define kGridCellTextdSelectFont          ([UIFont fontForKey:@"GridCellTextSelectColor"] ? [UIFont fontForKey:@"GridCellTextSelectColor"] : [UIFont fontWithName:@"PingFangSC-Medium" size:kLeftTableCellTextSize])


@implementation WSNewAddProdsWithSeriesLeftTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        //        if (!IOS7_OR_LATER) {
        //            self.selectionStyle = UITableViewCellSelectionStyleNone;
        //        }
        
        [self setupSubviews];
        //        self.separatorLineColor = RGBCOLOR(218, 218, 218);//[UIColor colorWithHexString:@"#c7c7c7"];
        
    }
    
    return self;
}

- (void)setupSubviews
{
    
    self.frontView = [[UIView alloc] initWithFrame:CGRectMake(0.0, (self.height - kLeftTableCellTextSize)/2, 2.0, kLeftTableCellTextSize)];
    self.frontView.backgroundColor = MAIN_TINT_COLOR;
    
    [self.contentView addSubview: self.frontView];
    
    self.titleLabel = [[UILabel alloc] init];
    
    self.titleLabel.font = kGridCellTextdDefaultFont;
    self.titleLabel.textColor = kGridCellTextdDefaultColor;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
//    self.titleLabel.highlightedTextColor = MAIN_TINT_COLOR;
    
    [self.contentView addSubview:self.titleLabel];
    
    self.badgeLabel = [[UILabel alloc] init];
    self.badgeLabel.textColor = [UIColor whiteColor];
    self.badgeLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:kLeftTableCellTextSize - 2];
    self.badgeLabel.numberOfLines = 0;
    self.badgeLabel.textAlignment = NSTextAlignmentCenter;
    self.badgeLabel.layer.masksToBounds = YES;
    self.badgeLabel.layer.cornerRadius = 9.0;
    self.badgeLabel.text = @"999+";
    self.badgeLabel.backgroundColor = MAIN_TINT_COLOR;
    self.badgeLabel.hidden = YES;
    
    [self.contentView addSubview:self.badgeLabel];

    UITapGestureRecognizer *singleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellSelectedAction:)];
    singleTapGR.numberOfTapsRequired = 1;
    
    [self.contentView addGestureRecognizer:singleTapGR];
    
}

- (void)cellSelectedAction:(id)sender
{
    if([self.delegate respondsToSelector:@selector(didSelectedCell:)]){
        [self.delegate didSelectedCell:self];
    }
    
}

- (void)setIsChecked:(BOOL)isChecked
{
    _isChecked = isChecked;
    
    if (_isChecked) {
        self.frontView.hidden = NO;
        self.frontView.backgroundColor = MAIN_TINT_COLOR;
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.titleLabel.textColor = kGridCellTextSelectColor;
        self.titleLabel.font = kGridCellTextdSelectFont;

    }else{
        self.frontView.hidden = YES;
        self.frontView.backgroundColor = MAIN_TINT_COLOR;
        if (_leftTableViewCellStyle == WSNewAddProdsWithSeries1LevelLeftTableViewCell) {
            self.contentView.backgroundColor = kGridCellColor;

        }else if (_leftTableViewCellStyle == WSNewAddProdsWithSeries2LevelLeftTableViewCell) {
            self.contentView.backgroundColor = [UIColor whiteColor];

        }
        self.titleLabel.textColor = kGridCellTextdDefaultColor;
        self.titleLabel.font = kGridCellTextdDefaultFont;

    }
    
    //    [self layoutIfNeeded];
}

- (void)setBadgeLabelText:(NSString *)badgeText
{
    self.badgeLabel.text = badgeText;
    
    if (badgeText && badgeText.length > 0 && ![badgeText isEqualToString:@"0"]) {
        self.badgeLabel.hidden = NO;
        if ([badgeText intValue] > 999) {
            self.badgeLabel.text = @"999+";
        }
    }else{
        self.badgeLabel.hidden = YES;
    }
}

- (void)layoutSubviews
{
    
    [super layoutSubviews];
    
    [self resetSubviewsFrame];
    
}

- (void)resetSubviewsFrame
{
    
    if (_leftTableViewCellStyle == WSNewAddProdsWithSeries1LevelLeftTableViewCell) {
        [self.frontView setFrame:CGRectMake(0.0, 0.0, 2.0, self.height)];
        
        CGFloat titleLabelWidth = self.contentView.frame.size.width - 12.0;
        
        [self.titleLabel setFrame:CGRectMake(12.0, 0.0, titleLabelWidth, self.height)];
        [self.badgeLabel setFrame:CGRectMake(self.contentView.frame.size.width - self.contentView.frame.size.width * kLeftTableCellBadgeLabelWidthScale - 3.0, 2.0, self.contentView.frame.size.width * kLeftTableCellBadgeLabelWidthScale, self.contentView.frame.size.height * kLeftTableCellBadgeLabelHeightScale)];

    }else if (_leftTableViewCellStyle == WSNewAddProdsWithSeries2LevelLeftTableViewCell) {
        [self.frontView setFrame:CGRectMake(12.0, (self.height - 3.0)/2, 3.0, 3.0)];
        self.frontView.layer.masksToBounds = YES;
        self.frontView.layer.cornerRadius = 2.0;
        

        CGFloat titleLabelWidth = self.contentView.frame.size.width - 20.0;
        
        [self.titleLabel setFrame:CGRectMake(20.0, 0.0, titleLabelWidth, self.height)];
    }

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

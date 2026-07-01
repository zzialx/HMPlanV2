//
//  WSProdGrideWithExpandableBrandsLeftTableViewCell.m
//  WinSFA
//
//  Created by HZH on 2017/9/11.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSProdGrideWithExpandableBrandsLeftTableViewCell.h"

#define kLeftTableCellTextSize 14.0

#define kLeftTableCellHeight 40.0

@implementation WSProdGrideWithExpandableBrandsLeftTableViewCell

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

    self.frontView = [[UIView alloc] initWithFrame:CGRectMake(8.0, (kLeftTableCellHeight - kLeftTableCellTextSize)/2, 2.0, kLeftTableCellTextSize)];
    self.frontView.backgroundColor = MAIN_TINT_COLOR;
    
    [self.contentView addSubview: self.frontView];
    
    self.titleLabel = [[UILabel alloc] init];
    
    self.titleLabel.font = FONT_SIZE_PINGFANG_MEDIUM(13.0);
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.textColor = [UIColor colorWithHexString:@"0x353535"];
    self.titleLabel.highlightedTextColor = MAIN_TINT_COLOR;
    
    [self.contentView addSubview:self.titleLabel];
    
}

- (void)setIsChecked:(BOOL)isChecked
{
    _isChecked = isChecked;
    
    if (_isChecked) {
        self.frontView.hidden = NO;
        self.frontView.backgroundColor = MAIN_TINT_COLOR;
        self.contentView.backgroundColor = [UIColor whiteColor];
    }else{
        self.frontView.hidden = YES;
        self.frontView.backgroundColor = MAIN_TINT_COLOR;
        self.contentView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
    }
    
//    [self layoutIfNeeded];
}

- (void)layoutSubviews
{
    
    [super layoutSubviews];
    
    [self resetSubviewsFrame];
    
}

- (void)resetSubviewsFrame
{
    [self.frontView setFrame:CGRectMake(8.0, (kLeftTableCellHeight - kLeftTableCellTextSize)/2, 2.0, kLeftTableCellTextSize)];
    
    CGFloat titleLabelWidth = self.contentView.frame.size.width - 17.0;
    
    [self.titleLabel setFrame:CGRectMake(17.0, 0.0, titleLabelWidth, kLeftTableCellHeight)];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

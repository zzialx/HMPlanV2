//
//  WSMultilevelMenuCell.m
//  WinSFA
//
//  Created by sunhf on 2018/1/15.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSMultilevelMenuCell.h"

@implementation WSMultilevelMenuCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews
{
    [self.contentView addSubview: self.titleLabel];
    [self.contentView addSubview: self.lineView];
    [self makeSubviewsConstraints];
}

#pragma mark - 约束
- (void)makeSubviewsConstraints
{
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(0, 15, 1, 15));
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.left.equalTo(self).offset(15);
        make.right.equalTo(self.mas_right).offset(-15);
        make.height.equalTo(1);
    }];
}

#pragma mark - Setter
- (void)setDictBean:(WSDictBean *)dictBean
{
    if (_dictBean != dictBean) {
        _dictBean = dictBean;
    }
    self.titleLabel.text = dictBean.name;
    if (_dictBean.isSelected)
    {
        [self changeSelectedStatus:YES];
    }
    else
    {
        [self changeSelectedStatus:NO];
    }
}

//设置选中和没选中时候的颜色
- (void)changeSelectedStatus:(BOOL)selected
{
    if (selected)
    {
        if (!_isFirstTableView)
        {
            self.titleLabel.textColor = [self getSelectedTitleColor];
        }
        
        self.lineView.backgroundColor = [self getSelectedTitleColor];
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        self.titleLabel.textColor = [self getNormalTitleColor];
        self.lineView.backgroundColor = RGB_COLOR(MultilevelMenu_SeparatorLine_Normal_Color);
        self.contentView.backgroundColor = [UIColor clearColor];
    }
}

//设置是否隐藏分割线,外部可控
- (void)setIsHiddenSeparatorLine:(BOOL)isHiddenSeparatorLine
{
    if (isHiddenSeparatorLine)
    {
        _lineView.hidden = YES;
    }
    else
    {
        _lineView.hidden = NO;
    }
}

#pragma mark - Getter
- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:kWord_Font_28px];
        _titleLabel.numberOfLines = 0;
        _titleLabel.textColor = [self getNormalTitleColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
    }
    return _titleLabel;
}

- (UIView *)lineView
{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [self  getNormalTitleColor];
    }
    return _lineView;
}

- (UIColor *)getNormalTitleColor
{
    UIColor *color = [UIColor colorForKey:@"DropListCellNormalTitleColor"];
    if (!color) {
        color = RGB_COLOR(MultilevelMenu_Normal_Color);
    }
    return color;
}

- (UIColor *)getSelectedTitleColor
{
    UIColor *color = [UIColor colorForKey:@"DropListCellSelectedTitleColor"];
    if (!color) {
        color = RGB_COLOR(MultilevelMenu_Selected_Color);
    }
    return color;
}

- (UIColor *)getSelectedCellBackgroundColor
{
    UIColor *color = [UIColor colorForKey:@"DropListCellSelectedBackgroudColor"];
    if (!color) {
        color = MAIN_CELL_SELECTED_COLOR;
    }
    return color;
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

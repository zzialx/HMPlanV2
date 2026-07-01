//
//  WSHOrderTableViewCell.m
//  WinSFA
//
//  Created by HZH on 2017/7/23.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSHOrderTableViewCell.h"

#define hCellLabelFontSize 14.0

@implementation WSHOrderTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTableViewWidth:(CGFloat)tableViewWidth
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        _tableViewWidth = tableViewWidth;
        if (!IOS7_OR_LATER) {
            self.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        [self setupSubviews];
        //        self.separatorLineColor = RGBCOLOR(218, 218, 218);//[UIColor colorWithHexString:@"#c7c7c7"];
        
    }
    
    return self;
}

- (void)setupSubviews
{
    _totalTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_tableViewWidth - 60, 0, 50, self.height)];
    _totalTitleLabel.textAlignment = NSTextAlignmentCenter;
    //    _totalTitleLabel.backgroundColor = [UIColor lightGrayColor];
    _totalTitleLabel.numberOfLines = 0;
    _totalTitleLabel.font = [UIFont systemFontOfSize:hCellLabelFontSize];
    
    _nameTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10 , 0, SCREEN_WIDTH - 60 - 150, self.height)];
    //    _nameTitleLabel.backgroundColor = [UIColor greenColor];
    _nameTitleLabel.numberOfLines = 0;
    _nameTitleLabel.font = [UIFont systemFontOfSize:hCellLabelFontSize];
}

- (void)setOrderCellModel:(WSHOrderCellModel *)orderCellModel
{
    if (_orderCellModel != orderCellModel) {
        _orderCellModel = orderCellModel;
    }
    [self.titleLabelArray removeAllObjects];
    [self.contentView removeAllSubviews];
    
    [self addSubview:_nameTitleLabel];
    [self addSubview:_totalTitleLabel];
    _nameTitleLabel.text = _orderCellModel.prodBean.name;
    for (int i = 0; i < _orderCellModel.paramValueArray.count; i++) {
        UILabel *paramTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nameTitleLabel.right+i*50, 0, 50, self.height)];
        paramTitleLabel.textAlignment = NSTextAlignmentCenter;
        paramTitleLabel.font = [UIFont systemFontOfSize:hCellLabelFontSize];
        paramTitleLabel.text = orderCellModel.paramValueArray[i];
        paramTitleLabel.textColor = [UIColor darkGrayColor];
        paramTitleLabel.numberOfLines = 0;
        [self.contentView addSubview: paramTitleLabel];
        [self.titleLabelArray addObject: paramTitleLabel];
    }
    UILabel *paramTitleLabel = self.titleLabelArray.lastObject;
    
    _totalTitleLabel.frame = CGRectMake(paramTitleLabel.right, 0, 50, self.height);
    _totalTitleLabel.text = _orderCellModel.totalStr;
    
}

- (NSMutableArray *)titleLabelArray
{
    if (!_titleLabelArray)
    {
        _titleLabelArray = [NSMutableArray array];
    }
    return _titleLabelArray;
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

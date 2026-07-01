//
//  WinStockOutTableViewCell.m
//  WinSFA
//
//  Created by zzialx on 2025/7/30.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#import "WinStockOutTableViewCell.h"
#import "WSInventoruHeader.h"

@implementation WinStockOutTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupCellUI];
        [self setConstraint];
    }
    return self;
}
#pragma mark - # Private Method
- (void)setupCellUI {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.contentView addSubview:self.productNameLabel];
    
    [self.contentView addSubview:self.quantityLabel];
    
        
}
- (void)setConstraint{
        
    [self.productNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(PAD_P_LR);
        make.centerY.equalTo(self.contentView);
    }];
   
    [self.quantityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-PAD_P_LR);
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo(STOCK_OUT_CELL_W);
        make.left.equalTo(self.productNameLabel.mas_right).offset(PAD_P_LR);
    }];
}
#pragma mark - # Public Method
- (void)configureWithItem:(WSStockOutModel *)item {
    self.productNameLabel.text = item.prodName;
    self.quantityLabel.text = item.qhDays;
}
#pragma mark - # Lazy Load

- (UILabel*)productNameLabel{
    if (!_productNameLabel) {
        _productNameLabel = [[UILabel alloc] init];
        _productNameLabel.font = [UIFont systemFontOfSize:14];
        _productNameLabel.textColor = [UIColor blackColor];
        _productNameLabel.numberOfLines = 2; // 最多显示2行
        _productNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _productNameLabel;
}
- (UILabel*)quantityLabel{
    if (!_quantityLabel) {
        _quantityLabel = [[UILabel alloc] init];
        _quantityLabel.font = [UIFont systemFontOfSize:14];
        _quantityLabel.textColor = [UIColor blackColor];
        _quantityLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _quantityLabel;
}
@end

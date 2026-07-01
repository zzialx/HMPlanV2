//
//  WSJYOrderDetialTableViewCell.m
//  WinSFA
//
//  Created by zzialx on 2025/7/10.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#import "WSJYOrderDetialTableViewCell.h"
#import "WSInventoruHeader.h"

@implementation WSJYOrderDetialTableViewCell

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
    
    [self.contentView addSubview:self.storeCodeLabel];
    
    [self.contentView addSubview:self.productNameLabel];
    
    [self.contentView addSubview:self.quantityLabel];
    
    [self.contentView addSubview:self.buyCountLabel];
        
}
- (void)setConstraint{
    
    [self.storeCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(PAD_P_LR);
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo(DNM_W);
    }];
    
    [self.productNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.storeCodeLabel.mas_right).offset(PAD_P_LR);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.buyCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-PAD_P_LR);
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo(BCJYSL_CONTENT_O_W);
    }];
    
    [self.quantityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.buyCountLabel.mas_left).offset(-PAD_P_LR);
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo(BCJYSL_CONTENT_O_W);
        make.left.equalTo(self.productNameLabel.mas_right).offset(PAD_P_LR);
    }];
}
#pragma mark - # Public Method
- (void)configureWithItem:(WSInventoryModel *)item {
    self.storeCodeLabel.text = item.storeCode;
    self.productNameLabel.text = item.prodName;
    self.quantityLabel.text = item.jysl;
    self.buyCountLabel.text = item.gjsl;
    if([item.color isEqualToString:@"1"]){
        self.storeCodeLabel.textColor = LIGHT_CELL_COLOR;
        self.productNameLabel.textColor = LIGHT_CELL_COLOR;
        self.buyCountLabel.textColor = LIGHT_CELL_COLOR;
        self.quantityLabel.textColor = LIGHT_CELL_COLOR;
    }

}
#pragma mark - # Lazy Load
- (UILabel*)storeCodeLabel{
    if (!_storeCodeLabel) {
        _storeCodeLabel = [[UILabel alloc] init];
        _storeCodeLabel.font = [UIFont systemFontOfSize:14];
        _storeCodeLabel.textColor = [UIColor blackColor];
        _storeCodeLabel.textAlignment = NSTextAlignmentLeft;
        _storeCodeLabel.numberOfLines = 2;
    }
    return _storeCodeLabel;
}

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
- (UILabel*)buyCountLabel{
    if (!_buyCountLabel) {
        _buyCountLabel = [[UILabel alloc] init];
        _buyCountLabel.font = [UIFont systemFontOfSize:14];
        _buyCountLabel.textColor = [UIColor blackColor];
        _buyCountLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _buyCountLabel;
}
@end

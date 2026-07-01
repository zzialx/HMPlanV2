//
//  WSFuncTipsTableViewCell.m
//  TestDemo
//
//  Created by xq的电脑 on 2023/12/3.
//

#import "WSFuncTipsTableViewCell.h"
//===================================================================================================================

#pragma mark - 菜单提醒单元格
@implementation WSFuncTipsTableViewCell

#pragma mark - 获取funcNameLab方法
- (UILabel *)funcNameLab {
    
    if (!_funcNameLab) {
        
        _funcNameLab = [[UILabel alloc] init];
        _funcNameLab.backgroundColor = [UIColor clearColor];
        _funcNameLab.font = [UIFont boldSystemFontOfSize:16.0f];
        _funcNameLab.textColor = [UIColor colorWithHexString:@"#666666"];
    }
    return _funcNameLab;
}

#pragma mark - 获取passLab方法
- (UILabel *)passLab {
    
    if (!_passLab) {
        
        _passLab = [[UILabel alloc] init];
        _passLab.backgroundColor = [UIColor clearColor];
        _passLab.font = [UIFont boldSystemFontOfSize:13.0f];
        _passLab.textColor = kAlertViewButtonTextColor;
    }
    return _passLab;
}

#pragma mark - 获取refuseLab方法
- (UILabel *)refuseLab {
    
    if (!_refuseLab) {
        
        _refuseLab = [[UILabel alloc] init];
        _refuseLab.backgroundColor = [UIColor clearColor];
        _refuseLab.font = [UIFont boldSystemFontOfSize:13.0f];
        _refuseLab.textColor = UIColor.redColor;
    }
    return _refuseLab;
}

#pragma mark - 获取line方法
- (UIView *)line {
    
    if (!_line) {
        
        _line = [[UIView alloc] init];
        _line.backgroundColor = [UIColor colorWithHexString:@"#666666"];
    }
    return _line;
}

#pragma mark - 重写initWithStyle:reuseIdentifier:方法
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.funcNameLab];
        [self.contentView addSubview:self.passLab];
        [self.contentView addSubview:self.refuseLab];
        [self.contentView addSubview:self.line];

        [self myLayoutSubviews];
    }
    return self;
}

#pragma mark - 自定义布局方法
- (void)myLayoutSubviews {
    
    [self.funcNameLab mas_makeConstraints:^(MASConstraintMaker *make) {

        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.contentView.mas_left).offset(10.0f);
    }];
    
    [self.passLab mas_makeConstraints:^(MASConstraintMaker *make) {

        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.funcNameLab.mas_right).offset(10.0f);
    }];
    
    [self.refuseLab mas_makeConstraints:^(MASConstraintMaker *make) {

        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.passLab.mas_right).offset(10.0f);
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {

        make.left.equalTo(self.contentView.mas_left).offset(5.0f);
        make.right.equalTo(self.contentView.mas_right).offset(-5.0f);
        make.height.mas_equalTo(0.5f);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-0.5f);
    }];
}

@end
//===================================================================================================================

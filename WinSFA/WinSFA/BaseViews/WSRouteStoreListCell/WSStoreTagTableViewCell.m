//
//  WSStoreTagTableViewCell.m
//  WinSFA
//
//  Created by admin on 2022/10/27.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import "WSStoreTagTableViewCell.h"

#define PAG_TOP  2.5

@interface WSStoreTagTableViewCell ()

/// 背景图
@property(nonatomic,strong)UIView * bgView;
/// 标题
@property(nonatomic,strong)UILabel * titleNameLab;
/// 内容
@property(nonatomic,strong)UILabel * contentLab;

@end

@implementation WSStoreTagTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.titleNameLab];
        [self.titleNameLab addSubview:self.bgView];
        [self.bgView sendSubviewToBack:self.titleNameLab];
        [self p_addMasonry];
        
    }
    return self;
}

- (void)setListModel:(WSShowQstViewSingleLineModel*)model{
    [self.titleNameLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_lessThanOrEqualTo(self.contentView.width-PAG_TOP);
    }];
    NSString * content = [NSString stringWithFormat:@"%@：%@ ",model.qstname,ISNULL(model.qstanwser)];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:content];
    [attributedText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(0, content.length)];
    [attributedText addAttribute:NSForegroundColorAttributeName value:HColorFromHex(0x2A2A2A) range:NSMakeRange(0, content.length)];
    NSRange decollatorRange = [content rangeOfString:@"："];
    [attributedText addAttribute:NSForegroundColorAttributeName value:HColorFromHex(0x28A707) range:NSMakeRange(decollatorRange.location +1, content.length - decollatorRange.location - 1 )];
    self.titleNameLab.attributedText = attributedText;
}

#pragma mark - # Private Methods
- (void)p_addMasonry {
    // 标题
    [self.titleNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(PAG_TOP);
        make.top.equalTo(self.contentView).offset(PAG_TOP);
        make.height.mas_greaterThanOrEqualTo(20.0);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-PAG_TOP);
    }];
    // 背景
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleNameLab).offset(-PAG_TOP);
        make.right.equalTo(self.titleNameLab).offset(PAG_TOP);
        make.top.equalTo(self.titleNameLab).offset(-PAG_TOP/2);
        make.bottom.equalTo(self.titleNameLab).offset(PAG_TOP/2);
    }];
}

#pragma mark - # Getter
- (UILabel *)titleNameLab {
    if (!_titleNameLab) {
        _titleNameLab = [[UILabel alloc] init];
        _titleNameLab.numberOfLines = 2;
        _titleNameLab.font = [UIFont systemFontOfSize:11.0];
        _titleNameLab.textColor = HColorFromHex(0x343434);
    }
    return _titleNameLab;
}
- (UILabel *)contentLab {
    if (!_contentLab) {
        _contentLab = [[UILabel alloc] init];
        _contentLab.numberOfLines = 0;
        _contentLab.font = [UIFont systemFontOfSize:11.0];
        _contentLab.textColor = HColorFromHex(0x343434);
    }
    return _contentLab;
}
- (UIView*)bgView{
    if(!_bgView){
        _bgView = [[UIView alloc]initWithFrame:CGRectZero];
        _bgView.backgroundColor = HColorFromHex(0xF4F4F4);
    }
    return _bgView;
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

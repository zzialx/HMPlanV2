//
//  WSAgreeMentCollectionViewCell.m
//  WXLoginDemo
//
//  Created by admin on 2022/11/2.
//

#import "WSAgreeMentCollectionViewCell.h"
#import <Masonry/Masonry.h>

#define UI_SubView_Detail_Font (INTERFACE_IS_PHONE ? 11.0f : 15.0f)

#define ISNULL(x) ((x) == nil || [x isEqual:[NSNull null]] ? @"" : (x))

#define HColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1.0]

#define PAG_TOP  2.5

#define PAD_LEFT        16.0

#define K_NAV_BUTTON_WIDHT      (INTERFACE_IS_PHONE ? 80 : 85)


@interface WSAgreeMentCollectionViewCell ()

/// 背景图
@property(nonatomic,strong)UIView * bgView;

/// 标题
@property(nonatomic,strong)UILabel * titleNameLab;

@end

@implementation WSAgreeMentCollectionViewCell

- (id)initWithFrame:(CGRect)frame{

  self = [super initWithFrame:frame];

  if (self) {
      
      
      [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
      }];

      [self.contentView addSubview:self.titleNameLab];
      
      

      [self.contentView addSubview:self.bgView];
      [self.contentView sendSubviewToBack:self.bgView];

      [self p_addMasonry];

  }
  return self;

}

- (void)setListModel:(WSShowQstViewSingleLineModel*)model{
    NSString * content = [NSString stringWithFormat:@"%@：%@ ",model.qstname,ISNULL(model.qstanwser)];
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.lineSpacing = 1.0;
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:content];
    [attributedText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(0, content.length)];
    [attributedText addAttribute:NSForegroundColorAttributeName value:HColorFromHex(0x2A2A2A) range:NSMakeRange(0, content.length)];
    NSRange decollatorRange = [content rangeOfString:@"："];
    [attributedText addAttribute:NSForegroundColorAttributeName value:HColorFromHex(0x28A707) range:NSMakeRange(decollatorRange.location +1, content.length - decollatorRange.location - 1 )];
    [attributedText addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, content.length)];
    self.titleNameLab.attributedText = attributedText;

}

#pragma mark - # Private Methods
- (void)p_addMasonry {
    // 标题
    [self.titleNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(PAG_TOP);
        make.top.equalTo(self.contentView).offset(PAG_TOP);
        make.height.mas_greaterThanOrEqualTo(20.0);
        make.width.mas_lessThanOrEqualTo(self.contentView.width-PAG_TOP);
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
        _titleNameLab.numberOfLines = 0;
        _titleNameLab.font = [UIFont systemFontOfSize:UI_SubView_Detail_Font];
        _titleNameLab.textColor = HColorFromHex(0x343434);
//        _titleNameLab.backgroundColor = HColorFromHex(0xF4F4F4);

    }
    return _titleNameLab;
}
- (UIView*)bgView{
    if(!_bgView){
        _bgView = [[UIView alloc]initWithFrame:CGRectZero];
        _bgView.backgroundColor = HColorFromHex(0xF4F4F4);
    }
    return _bgView;
}
@end

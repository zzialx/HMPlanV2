//
//  WSANActivityHeadView.m
//  WinSFA
//
//  Created by zzialx on 2025/5/9.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#import "WSANActivityHeadView.h"
#import "WSANActivityHeader.h"
#import "UIButton+JKTouchAreaInsets.h"

#define Icon_WH         20

@interface WSANActivityHeadView()

@property(nonatomic,copy)deleteActivityItemBlock deleteActivityItemBlock;

@property(nonatomic,copy)expandActivityBlock expandActivityBlock;

@end

@implementation WSANActivityHeadView
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor =  RGBCOLOR(239.0, 240.0, 241.0);
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self setConstraints];
    }
    return self;
}
- (void)setupUI{
    [self headImageView];
    [self titleLab];
    [self expandBtn];
    [self deleteBtn];
    [self lineView];
}
- (void)setConstraints{
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(kActivityHaderSpace);
        make.centerY.equalTo(self.mas_centerY);
        make.height.width.mas_equalTo(Icon_WH);
    }];
    
    [self.expandBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-kActivityHaderSpace);
        make.centerY.equalTo(self.mas_centerY);
        make.height.width.mas_equalTo(Icon_WH);
    }];
    
    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.expandBtn.mas_left).offset(-kActivityHaderSpace);
        make.centerY.equalTo(self.mas_centerY);
        make.height.width.mas_equalTo(Icon_WH);
    }];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headImageView.mas_right).offset(kHeaderTitlePadLR);
        make.right.equalTo(self.deleteBtn.mas_left).offset(-kHeaderTitlePadLR);
        make.height.mas_equalTo(kActivityHaderTitleHeight);
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(0);
        make.right.equalTo(self.mas_right).offset(0);
        make.bottom.equalTo(self.mas_bottom).offset(-kHeaderLineHeight);
        make.height.mas_equalTo(kHeaderLineHeight);
    }];
}
- (void)deleteActibityBtnAction:(UIButton *)sender {
    LogInfo(@"删除活动Action");
    if (self.deleteActivityItemBlock) {
        self.deleteActivityItemBlock();
    }
}
- (void)expandAction:(UIButton *)sender {
    LogInfo(@"活动展开Action");
    sender.selected = !sender.selected;
    if (self.expandActivityBlock) {
        self.expandActivityBlock(sender.selected);
    }
}
#pragma mark - # Public Method
- (void)deleteActivityItemBlock:(deleteActivityItemBlock)block{
    
    self.deleteActivityItemBlock = block;
    
}

- (void)expandActivityBlock:(expandActivityBlock)block{
    
    self.expandActivityBlock = block;
    
}
- (void)setHeadModel:(WSANActivityModel *)headModel{
    
    _headModel = headModel;
    
    self.titleLab.text = _headModel.activityTitle;
    
    if (_headModel.isExpand) {
        self.expandBtn.selected = YES;
    }else{
        self.expandBtn.selected = NO;
    }
}
#pragma mark - # Load Lazy
- (UIButton*)deleteBtn{
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_deleteBtn];
        [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"ic_dele_acvt"] forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(deleteActibityBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}
- (UIImageView*)headImageView{
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc]init];
        [self addSubview:_headImageView];
        _headImageView.image = [UIImage imageNamed:@"ic_activity_logo"];
    }
    return _headImageView;
}
- (UILabel*)titleLab{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc]initWithFrame:CGRectZero];
        [self addSubview:_titleLab];
        _titleLab.font = FONT(15);
        _titleLab.textColor = RGBCOLOR(10.0, 10.0, 10.0);
        _titleLab.numberOfLines= 2;
    }
    return _titleLab;
}
- (UIButton*)expandBtn{
    if (!_expandBtn) {
        _expandBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_expandBtn];
        [_expandBtn setBackgroundImage:[UIImage imageNamed:@"ic_up_item"] forState:UIControlStateNormal];
        [_expandBtn setBackgroundImage:[UIImage imageNamed:@"ic_down_item"] forState:UIControlStateSelected];
        [_expandBtn addTarget:self action:@selector(expandAction:) forControlEvents:UIControlEventTouchUpInside];
        _expandBtn.jk_touchAreaInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    }
    return _expandBtn;
}
- (UIView*)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc]init];
        [self addSubview:_lineView];
        _lineView.backgroundColor = RGBCOLOR(220.0, 220.0, 220.0);
    }
    return _lineView;
}
@end

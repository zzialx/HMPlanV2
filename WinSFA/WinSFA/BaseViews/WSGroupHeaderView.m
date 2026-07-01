//
//  WSGroupHeaderView.m
//  WinSFA
//
//  Created by huzepei on 16/6/24.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSGroupHeaderView.h"

#define kLabelFont [UIFont systemFontOfSize:UI_Font]


@interface WSGroupHeaderView()

@property (nonatomic, weak) UIButton *headerBtn;


@property (nonatomic,strong) UILabel * numLabels;


@end
@implementation WSGroupHeaderView

+(instancetype)groupHeaderViewWithTableView:(UITableView *)tableView
{
    static NSString *headerID = @"WSGroupHeaderView";
    WSGroupHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerID];
    if (headerView == nil) {
        headerView = [[self alloc] initWithReuseIdentifier:headerID];
    }
    return headerView;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupChlidView];
    }
    return self;
}

-(void)setupChlidView
{
    UIButton *headerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:headerBtn];
    self.headerBtn = headerBtn;
    [self.headerBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.headerBtn setImage:[UIImage imageNamed:@"brand_unchecked"] forState:UIControlStateNormal];
    [self.headerBtn setImage:[UIImage imageNamed:@"brand_checked"] forState:UIControlStateSelected];
    self.headerBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.headerBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    self.headerBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [self.headerBtn setBackgroundImage:[UIImage imageNamed:@"pro_header_bg"] forState:0];
    [self.headerBtn setBackgroundImage:[UIImage imageNamed:@"pro_header_bg_highlighted"] forState:1];
    self.headerBtn.imageView.contentMode = UIViewContentModeCenter;
    self.headerBtn.imageView.clipsToBounds = NO;
    [self.headerBtn.titleLabel setFont:[UIFont systemFontOfSize:UI_Font]];
    
    [self.headerBtn addTarget:self action:@selector(headerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.headerBtn.frame = self.bounds;
    
    self.allSelectedBtn.center = CGPointMake(self.width - 20, self.height/2);
    self.allSelectedBtn.bounds = CGRectMake(0, 0, 70, 40);

}
- (void)headerBtnClick:(UIButton *)sender {

    self.prodBeanArray.expend = !self.prodBeanArray.expend;
    
    
    if (!self.prodBeanArray.isExpend) {
        [self.headerBtn setImage:[UIImage imageNamed:@"brand_unchecked"] forState:UIControlStateNormal];
        //self.headerBtn.imageView.transform = CGAffineTransformMakeRotation(0);
    }else {
        [self.headerBtn setImage:[UIImage imageNamed:@"brand_checked"] forState:UIControlStateNormal];
        //self.headerBtn.imageView.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    
    if ([self.delegate respondsToSelector:@selector(WSGroupHeaderViewDidClickBtn:)]) {
        
        [self.delegate WSGroupHeaderViewDidClickBtn:self];
    }
}

-(void)selectedBtnClick:(UIButton *)sender {
    
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.isSelected;
    
    if ([self.delegate respondsToSelector:@selector(WSGroupHeaderViewDidClickAllSelectedBtn:)]) {
        
        [self.delegate WSGroupHeaderViewDidClickAllSelectedBtn:self];
    }
    
}



-(void)setProdBeanArray:(WSProdBeanArray *)prodBeanArray
{
    _prodBeanArray = prodBeanArray;
    [self.headerBtn setTitle:self.prodBeanArray.name forState:0];
    
    //根据prodBeanArray计算文字大小
    CGSize size = [self.prodBeanArray.name ws_sizeWithFont:kLabelFont constrainedToWidth:300 lineBreakMode:NSLineBreakByCharWrapping];
    
    self.numLabels.frame = CGRectMake(size.width + 70, 0, 50, 44);
    
    NSString *str = [NSString stringWithFormat:@"%ld/%lu",(long)_prodBeanArray.selectNum,(unsigned long)_prodBeanArray.prodArray.count];
    self.numLabels.text = str;

    if (!self.prodBeanArray.isExpend) {
        [self.headerBtn setImage:[UIImage imageNamed:@"brand_unchecked"] forState:UIControlStateNormal];
    }else {
        [self.headerBtn setImage:[UIImage imageNamed:@"brand_checked"] forState:UIControlStateNormal];
    }
    
    if (self.prodBeanArray.isSelected) {
        
        self.allSelectedBtn.selected = YES;
        
    }else{
        
        self.allSelectedBtn.selected = NO;
    }
}

-(UIButton *)allSelectedBtn
{
    if (!_allSelectedBtn) {
        _allSelectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:_allSelectedBtn];
        [_allSelectedBtn setImage:[UIImage imageNamed:@"icn_nocheck"] forState:UIControlStateNormal];
        [_allSelectedBtn setImage:[UIImage imageNamed:@"icn_check"] forState:UIControlStateSelected];
        [_allSelectedBtn addTarget:self action:@selector(selectedBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _allSelectedBtn;
}

-(UILabel *)numLabels
{
    if (!_numLabels) {
        _numLabels = [[UILabel alloc] init];
        [self.contentView addSubview:_numLabels];
        _numLabels.font = [UIFont systemFontOfSize:14.0];
        _numLabels.textColor = MAIN_TINT_COLOT;
    }
    return _numLabels;
}
@end

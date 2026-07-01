//
//  WSSuggestView.m
//  WinSFA
//
//  Created by huzepei on 16/7/5.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSuggestView.h"
#import "PureLayout.h"
#import "WSSuggest.h"
#import "WSSuggestWholesale.h"
#import "WSSuggestHome.h"

#define TAGBASE 100000

@interface WSSuggestView()

@property (nonatomic,strong) UIView *containerView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *descLabel;
@property (nonatomic,strong) UIImageView *monthBgImageView;
@property (nonatomic,strong) UIImageView *yearBgImageView;
@property (nonatomic,strong) UILabel *monthDesc;
@property (nonatomic,strong) UILabel *yearDesc;
@property (nonatomic,strong) UILabel *monthIncome;
@property (nonatomic,strong) UILabel *yearIncome;
@property (nonatomic,strong) UIButton *closeBtn;
@property (nonatomic,strong) UIButton *plusBtn;

@property (nonatomic,strong)UIImageView *suggestBgImageView;
@end

@implementation WSSuggestView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _suggestBgImageView = [[UIImageView alloc] initWithImage:[UIImage imageForName:@"bg-kuang.png"]];
        _suggestBgImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        _suggestBgImageView.hidden = YES;
        [self addSubview:_suggestBgImageView];
        
    }
    return self;
}

-(void)setSuggestIndex:(NSInteger)suggestIndex
{
    _suggestIndex = suggestIndex;
}

-(void)setSuggest:(WSSuggest *)suggest
{
    _suggest = suggest;
    _titleLabel.text = _suggest.title;
    _monthIncome.text = _suggest.monthlyIncome;
    _yearIncome.text = _suggest.yearsIncome;
    
}

-(void)setShowPlus:(BOOL)showPlus
{
    _showPlus = showPlus;
    if (_showPlus) {
        _suggestBgImageView.hidden = NO;
    }
}

//批发有四种pro
-(void)setSuggestWholesale:(WSSuggestWholesale *)suggestWholesale
{
    _suggestWholesale = suggestWholesale;
    _titleLabel.text = _suggestWholesale.name;
    _monthIncome.text = _suggestWholesale.sugModel.moreMonthFits;
    _yearIncome.text = _suggestWholesale.sugModel.moreYearFits;
 
    
    NSString *str = _suggestWholesale.sugModel.ownSP_wholesale.name;
    if (!str) {
        str = @"无本品";
    }
    
    NSString *str2 = _suggestWholesale.sugModel.otherSP_wholesale.name;
    
    if (!str2) {
        str2 = @"无竞品";
    }
    
    NSString *desc = [NSString stringWithFormat:@"%@与%@价格对比",str,str2];
    _descLabel.text = desc;
    
}

//用家后来改了只剩一个pro了,就没有用index判断了
-(void)setSuggestHome:(WSSuggestHome *)suggestHome
{
    _suggestHome = suggestHome;
    _titleLabel.text = _suggestHome.name;
    _monthIncome.text = _suggestHome.sugHomeModel.monthMore;
    _yearIncome.text = _suggestHome.sugHomeModel.yearMore;
    
    
    NSString *str = _suggestHome.sugHomeModel.ownSP_top.name;
    if (!str) {
        str = @"无本品";
    }
    
    NSString *str2 = _suggestHome.sugHomeModel.otherSP_top.name;
    
    if (!str2) {
        str2 = @"无竞品";
    }
    
    NSString *desc = [NSString stringWithFormat:@"%@与%@价格对比",str,str2];
    _descLabel.text = desc;
}

-(void)setUpPlusBtn
{
    _plusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_plusBtn addTarget:self action:@selector(plusBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_plusBtn setBackgroundImage:[UIImage imageForName:@"plus_btn.png"] forState:UIControlStateNormal];
    [self addSubview:_plusBtn];
    
    [self layoutPlusBtn];
}

/**
 *  UI加载
 */
-(void)setupViews
{
    _suggestBgImageView.hidden = NO;
    
    _containerView = [[UIView alloc] init];
    _containerView.tag = (TAGBASE + 10) << 8 | 0;
    _containerView.userInteractionEnabled = YES;
    [self addSubview:_containerView];
    
    //添加手势
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(containerViewClick)];
    //将手势添加到需要相应的view中去
    [_containerView addGestureRecognizer:tapGesture];
    
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:16.0];
    [_containerView addSubview:_titleLabel];
    
    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeBtn setBackgroundImage:[UIImage imageForName:@"shanchu_icon.png"] forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(closeCurrentView) forControlEvents:UIControlEventTouchUpInside];
    [_containerView addSubview:_closeBtn];

    _descLabel = [[UILabel alloc] init];
    _descLabel.text = @"与同类竞品比较:";
    _descLabel.numberOfLines = 0;
    _descLabel.font = [UIFont systemFontOfSize:14.0];
    [_containerView addSubview:_descLabel];
    
    _monthBgImageView = [[UIImageView alloc] initWithImage:[UIImage imageForName:@"fangzi_small.png"]];
    [_containerView addSubview:_monthBgImageView];
    
    _yearBgImageView = [[UIImageView alloc] initWithImage:[UIImage imageForName:@"fangzi_big.png"]];
    [_containerView addSubview:_yearBgImageView];
    
    _monthDesc = [[UILabel alloc] init];
    _monthDesc.text = @"月收入:";
    _monthDesc.backgroundColor = [UIColor clearColor];
    _monthDesc.font = [UIFont systemFontOfSize:14.0];
    [_containerView addSubview:_monthDesc];
    
    _yearDesc = [[UILabel alloc] init];
    _yearDesc.backgroundColor = [UIColor clearColor];
    _yearDesc.text = @"年收益:";
    _yearDesc.font = [UIFont systemFontOfSize:14.0];
    [_containerView addSubview:_yearDesc];
    
    _monthIncome = [[UILabel alloc] init];
    _monthIncome.backgroundColor = [UIColor clearColor];
    _monthIncome.font = [UIFont systemFontOfSize:16.0];
    [_containerView addSubview:_monthIncome];
    
    _yearIncome = [[UILabel alloc] init];
    _yearIncome.backgroundColor = [UIColor clearColor];
    _yearIncome.font = [UIFont systemFontOfSize:16.0];
    [_containerView addSubview:_yearIncome];
    
    [self layoutViews];
}

-(void)layoutPlusBtn
{
    [_plusBtn autoCenterInSuperview];
    [_plusBtn autoSetDimensionsToSize:_plusBtn.currentBackgroundImage.size];
}

/**
 *  设置约束
 */
-(void)layoutViews
{
    
    ALEdgeInsets defInsets = ALEdgeInsetsMake(20.0,20.0,20.0,20.0);
    
    [_containerView autoPinEdgesToSuperviewEdgesWithInsets:defInsets];
    
    [_titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5.0];
    [_titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5.0];
    
    [_closeBtn autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:-5.0];
    [_closeBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];
    [_closeBtn autoSetDimensionsToSize:_closeBtn.currentBackgroundImage.size];
    
    [_descLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_titleLabel withOffset:10];
    [_descLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:_containerView withOffset:10];
    [_descLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5.0];
    
    
    CGFloat monthW = (self.frame.size.width - 40) / 2;
    CGFloat monthH = monthW / _monthBgImageView.image.size.width * _monthBgImageView.image.size.height;
    [_monthBgImageView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [_monthBgImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_monthBgImageView autoSetDimension:ALDimensionWidth toSize:monthW];
    [_monthBgImageView autoSetDimension:ALDimensionHeight toSize:monthH];
    
    
    CGFloat yearW = (self.frame.size.width - 40) / 2;
    CGFloat yearH = monthW / _yearBgImageView.image.size.width * _yearBgImageView.image.size.height;
    [_yearBgImageView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [_yearBgImageView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [_yearBgImageView autoSetDimension:ALDimensionWidth toSize:yearW];
    [_yearBgImageView autoSetDimension:ALDimensionHeight toSize:yearH];
    
    [_monthDesc autoAlignAxis:ALAxisHorizontal toSameAxisOfView:_monthBgImageView];
    [_monthDesc autoAlignAxis:ALAxisVertical toSameAxisOfView:_monthBgImageView];
    
    [_monthIncome autoAlignAxis:ALAxisVertical toSameAxisOfView:_monthDesc];
    [_monthIncome autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_monthDesc withOffset:10];
    
    [_yearDesc autoAlignAxis:ALAxisHorizontal toSameAxisOfView:_yearBgImageView];
    [_yearDesc autoAlignAxis:ALAxisVertical toSameAxisOfView:_yearBgImageView];
    
    [_yearIncome autoAlignAxis:ALAxisVertical toSameAxisOfView:_yearDesc];
    [_yearIncome autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_yearDesc withOffset:10];
    
}

/**
 *  重绘
 */
-(void)layoutSubviews
{
    if ((_suggestWholesale || _suggestHome) && [self hasContainerView]) {
        _plusBtn.hidden = YES;
        _containerView.hidden = NO;
        
    }else if(_showPlus && [self hasPlusBtn])
    {
        _containerView.hidden = YES;
        _plusBtn.hidden = NO;
        
    }else{
        _containerView.hidden = YES;
        _plusBtn.hidden = YES;
    }
    [super layoutSubviews];
}

#pragma mark -event

/**
 *  单击内容视图
 */
-(void)containerViewClick
{
    if ([self.delegate respondsToSelector:@selector(WSSuggestViewDidClickContainerView:WithIndex:)]) {
        [self.delegate WSSuggestViewDidClickContainerView:self WithIndex:_suggestIndex];
    }
}

-(void)closeCurrentView
{
    if ([self.delegate respondsToSelector:@selector(WSSuggestViewDidClickCloseBtn:WithIndex:)]) {
        [self.delegate WSSuggestViewDidClickCloseBtn:self WithIndex:_suggestIndex];
    }
}
-(void)plusBtnClick
{
    if ([self.delegate respondsToSelector:@selector(WSSuggestViewDidClickPlusBtn:WithIndex:)]) {
        [self.delegate WSSuggestViewDidClickPlusBtn:self WithIndex:_suggestIndex];
    }
}

/**
 *  删除suggestView
 */
-(void)removeContainerViewAndPlusBtn
{
    _suggestBgImageView.hidden = YES;
    if (_containerView) {
        [_containerView removeFromSuperview];
    }
    if (_plusBtn) {
        [_plusBtn removeFromSuperview];
    }
    
}

-(BOOL)hasContainerView
{
    for (UIView *view in self.subviews) {
        if (_containerView == view) {
            return YES;
            break;
        }
    }
    return NO;
}

-(BOOL)hasPlusBtn
{
    for (UIButton *btn in self.subviews) {
        if (_plusBtn == btn) {
            return YES;
            break;
        }
    }
    return NO;
}
@end
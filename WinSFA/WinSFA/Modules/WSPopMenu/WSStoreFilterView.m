//
//  WSStoreFilterView.m
//  WinSFA
//
//  Created by sunhongfu on 2017/12/7.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSStoreFilterView.h"
#define kMainWindow  [[[UIApplication sharedApplication] delegate] window]

@interface WSStoreFilterView ()
{
    UIButton *lastClickBtn;//记录上一次点击的按钮设置其他按钮的状态
}
@property (nonatomic,strong)NSMutableArray *buttonArray;//放置所有button的数组
@property (nonatomic,strong)UIScrollView *myScrollView;
@property (nonatomic,strong)NSMutableArray *dataArray;//数据数组

@end

@implementation WSStoreFilterView

- (id)initWithFrame:(CGRect)frame withDataArray:(NSMutableArray *)dataArray withFilterStyle:(WSStoreFilterViewStyle)filterStyle
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _filterStyle = filterStyle;
        self.dataArray =[NSMutableArray arrayWithArray:dataArray];
        self.backgroundColor = HColorFromHex(0xf9f9f9);
        [self createSubviews];
    }
    return self;
}
- (void)createSubviews
{
    self.buttonArray = [NSMutableArray array];
    self.myScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _myScrollView.backgroundColor = HColorFromHex(0xf9f9f9);
    _myScrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_myScrollView];

    CGFloat filterButtonWidth = 120;
    for (int i = 0; i < _dataArray.count; i++)
    {
        UIButton *filterBtn;
        filterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        filterBtn.tag = 500+i;
        if (_filterStyle == WSStoreFilterViewMengNiuStyle)
        {
             WSAcvtBean_qst *qstObj = _dataArray[i];
            [filterBtn setTitle:qstObj.defaultValue forState:UIControlStateNormal];
            filterBtn.frame =CGRectMake(i*(_myScrollView.width/3), 0, _myScrollView.width/3, _myScrollView.height);
            [filterBtn setTitleColor:HColorFromHex(0x7c7c7c) forState:UIControlStateNormal];
            [filterBtn setImage:[UIImage imageNamed:@"icon_arrow_down"] forState:UIControlStateNormal];
            [filterBtn setImage:[UIImage imageNamed:@"icon_arrow_up"] forState:UIControlStateSelected];
            filterBtn.titleLabel.font = FONT_SIZE_PINGFANG_REGULAR(26/2);
            [filterBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -filterBtn.imageView.image.size.width-5, 0, filterBtn.imageView.image.size.width)];
            [filterBtn setImageEdgeInsets:UIEdgeInsetsMake(0, filterBtn.titleLabel.bounds.size.width, 0, -filterBtn.titleLabel.bounds.size.width-5)];
        }
        else
        {
            WSDictBean *dictObj = _dataArray[i];
            filterBtn.frame =CGRectMake(10 + i*(filterButtonWidth + 5), 10, filterButtonWidth, _myScrollView.height-20);
            [filterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            filterBtn.titleLabel.font = FONT_SIZE_PINGFANG_REGULAR(30/2);
            filterBtn.layer.borderColor = [UIColor blackColor].CGColor;
            filterBtn.layer.borderWidth = 1.0;
            [filterBtn setBackgroundImage:[UIImage imageNamed:@"backBlueColor"] forState:UIControlStateNormal];
            [filterBtn setBackgroundImage:[UIImage imageNamed:@"backYellowColor"] forState:UIControlStateSelected];
            [filterBtn setTitle:dictObj.name forState:UIControlStateNormal];
        }
        
        [filterBtn addTarget:self action:@selector(btnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [_myScrollView addSubview:filterBtn];
        [_buttonArray addObject:filterBtn];
    }
    //根据最后一个按钮的坐标 计算出scrollview的contentSize
    UIButton *lastBtn = _buttonArray.lastObject;
    _myScrollView.bounces = (lastBtn.right < _myScrollView.width) ? NO : YES;
    _myScrollView.contentSize = CGSizeMake(lastBtn.right, _myScrollView.height);
    //底部下划线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height-0.5, self.width, 0.5)];
    lineView.backgroundColor = HColorFromHex(0xd2d2d2);
    [self addSubview:lineView];
}

- (void)btnDidClick:(UIButton *)btn
{
    /*点击按钮时候 移除掉window上其他的menuView*/
    if ([kMainWindow.subviews.lastObject isKindOfClass:[WSPopMenuView class]])
    {
        WSPopMenuView *menuView = (WSPopMenuView *)kMainWindow.subviews.lastObject;
        [menuView dismiss];
    }
    
    /*控制显隐 当点击的按钮是未选中状态或者不是之前点击的按钮才会再弹出menuView*/
    if (lastClickBtn != btn || !btn.selected)
    {
        /*因为有多个按钮 点击按钮时候 设置其他按钮未选中状态*/
        for (UIButton *btn in _buttonArray) {
            btn.selected = NO;
        }
        btn.selected = YES;
        lastClickBtn = btn;
        if ([self.delegate respondsToSelector:@selector(storeFilterButonDidClick:)])
        {
            [self.delegate storeFilterButonDidClick:btn];
        }
    }
    else
    {
        btn.selected = NO;
        if (_filterStyle == WSStoreFilterViewHuiRuiStyle && [self.delegate respondsToSelector:@selector(storeFilterButonDidClick:)])
        {
            [self.delegate storeFilterButonDidClick:btn];
        }
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

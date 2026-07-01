//
//  WSAcvtTabView.m
//  WinSFA
//
//  Created by Stephanie on 16/7/20.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSTitleTabView.h"

const CGFloat xOffset = 8;
const CGFloat buttonWidth = 115;
const CGFloat buttonHeight = 40;
const CGFloat buttonGap = 8;

#define kSelectedBgColor [UIColor colorForKey:@"AcvtTabViewTitleSelectedBackgroudColor"]
#define kUnSelectedBgColor [UIColor colorForKey:@"AcvtTabViewTitleUnSelectedBackgroudColor"]

@interface WSTitleTabView ()
{
    UIScrollView *_scrollView;
}

@property (nonatomic, strong) NSMutableArray *buttonArray;

@property (nonatomic, assign) WSTitleTabViewAlignment alignment;

@end

@implementation WSTitleTabView

- (instancetype)initWithFrame:(CGRect)frame titleArray:(NSArray *)titleArray aligment:(WSTitleTabViewAlignment)aligment
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _alignment = aligment;
        
        UIColor *bgColor = [UIColor colorForKey:@"AcvtTabViewTitleBackgroundColor"];
        if (!bgColor) {
            bgColor = RGBCOLOR(246, 246, 246);
        }
        
        self.backgroundColor = bgColor;
        
        self.clipsToBounds = YES;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.backgroundColor = bgColor;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_scrollView];
        
        // MN-992 加入按钮宽度等于等分屏幕不可滑动逻辑
        CGFloat btnEqualWidth = (self.bounds.size.width - (titleArray.count + 1) * buttonGap) / titleArray.count;
        
        CGFloat x = xOffset;
        
        UIFont *font = [UIFont fontForKey:@"AcvtTabViewTitle"];
        if (!font) {
            font = [UIFont systemFontOfSize:15];
        }
        
        _buttonArray = [NSMutableArray array];
        
        for (NSInteger i = 0; i < [titleArray count]; i++) {
            
            NSString *title = titleArray[i];
            
            CGSize size = [title ws_sizeWithFont:font constrainedToWidth:CGFLOAT_MAX lineBreakMode:NSLineBreakByCharWrapping];
            
            CGFloat width = buttonWidth;
            if (size.width + 45 > buttonWidth) {
                width = size.width + 45;
            }
            
            if (width > btnEqualWidth) {
                width = btnEqualWidth;
                _scrollView.scrollEnabled = NO;
            }
            
            // MN-3490 要求 iPhone 修改样式
            if (INTERFACE_IS_PHONE) {
                if (width < btnEqualWidth) {
                    width = btnEqualWidth;
                }
            }
            
            UIColor *unSelectColor = kUnSelectedBgColor;
            if (!unSelectColor) {
                unSelectColor = RGBCOLOR(255,255,255);
            }
            
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, frame.size.height - buttonHeight, width, buttonHeight)];
            [button setBackgroundColor:unSelectColor];
            button.titleLabel.font = font;
            
            CGRect rect = CGRectMake(0, 0, width, buttonHeight);
            CGSize radio = CGSizeMake(5, 5);//圆角尺寸
            UIRectCorner corner = UIRectCornerTopLeft | UIRectCornerTopRight;//这只圆角位置
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corner cornerRadii:radio];
            CAShapeLayer *masklayer = [[CAShapeLayer alloc]init];//创建shapelayer
            masklayer.frame = button.bounds;
            masklayer.path = path.CGPath;//设置路径
            button.layer.mask = masklayer;
            
            UIColor *titleColor = [UIColor colorForKey:@"AcvtTabViewTitle"];
            if (!titleColor) {
                titleColor = RGBCOLOR(0, 0, 0);
            }
            
            UIColor *titleSelectedColor = [UIColor colorForKey:@"AcvtTabViewTitleSelectedColor"];
            if (!titleSelectedColor) {
                titleSelectedColor = RGBCOLOR(255, 255, 255);
            }
            
            [button setTitleColor:titleColor forState:UIControlStateNormal];
            [button setTitleColor:titleSelectedColor forState:UIControlStateSelected];
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:title forState:UIControlStateNormal];
            //button.titleLabel.font = [UIFont systemFontOfSize:UI_Font + 1];
            
            [_scrollView addSubview:button];
            
            x += width + buttonGap;
            
            [button setTag:kTitleTabViewTag + i];
            
            [_buttonArray addObject:button];
        }
        
        if (x < _scrollView.width && aligment == WSTitleTabViewAlignmentCenter) {
            x = self.width - (x - xOffset - buttonGap);
            for (NSInteger i = 0; i < [_buttonArray count]; i++) {
                UIButton *button = _buttonArray[i];
                button.frame = CGRectMake(x, button.top, button.width, button.height);
                x += button.width + buttonGap;
            }
        }
        
        [_scrollView setContentSize:CGSizeMake(x, frame.size.height)];
        
    }
    return self;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    if (selectedIndex > [self.buttonArray count] - 1) {
        return;
    }
    
    UIColor *selectColor = kSelectedBgColor;
    if (!selectColor) {
        selectColor = MAIN_TINT_COLOR;
    }
    UIColor *unSelectColor = kUnSelectedBgColor;
    if (!unSelectColor) {
        unSelectColor = RGBCOLOR(185,190,195);
    }
    
    
    UIColor *titleColor = [UIColor colorForKey:@"AcvtTabViewTitle"];
    if (!titleColor) {
        titleColor = RGBCOLOR(255, 255, 255);
    }
    
    UIButton *button = self.buttonArray[_selectedIndex];
    [button setBackgroundColor:unSelectColor];
//    button.titleLabel.textColor = titleColor;
    [button setSelected:NO];
    
    _selectedIndex = selectedIndex;
    
    button = self.buttonArray[_selectedIndex];
    [button setBackgroundColor:selectColor];
//    button.titleLabel.textColor = titleSelectedColor;
    [button setSelected:YES];
    
    if ([self.delegate respondsToSelector:@selector(titleTabView:didSelectTitleAtIndex:)]) {
        [self.delegate titleTabView:self didSelectTitleAtIndex:_selectedIndex];
    }
}

- (void)buttonAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if ([button isSelected]) {
        return;
    }
    
    NSInteger index = [self.buttonArray indexOfObject:button];
    
    BOOL shouldSelect = YES;
    if ([self.delegate respondsToSelector:@selector(titleTabView:shouldSelectTitleAtIndex:)]) {
        shouldSelect = [self.delegate titleTabView:self shouldSelectTitleAtIndex:index];
    }
    
    if (shouldSelect) {
        [self setSelectedIndex:index];
    }
}

- (void)layoutSubviews
{
    [self refreshButtonFrame];
}

- (void)refreshButtonFrame
{
    CGFloat x = xOffset;
    
    UIFont *font = [UIFont fontForKey:@"AcvtTabViewTitle"];
    if (!font) {
        font = [UIFont systemFontOfSize:16];
    }
    
    CGFloat btnEqualWidth = (self.bounds.size.width - (_buttonArray.count + 1) * buttonGap) / _buttonArray.count;
    
    for (NSInteger i = 0; i < [self.buttonArray count]; i++) {
        
        UIButton *button = self.buttonArray[i];
        
        NSString *title = button.titleLabel.text;
        
        CGSize size = [title ws_sizeWithFont:font constrainedToWidth:CGFLOAT_MAX lineBreakMode:NSLineBreakByCharWrapping];
        
        CGFloat width = buttonWidth;
        if (size.width + 45 > buttonWidth) {
            width = size.width + 45;
        }
        
        if (width > btnEqualWidth) {
            width = btnEqualWidth;
            _scrollView.scrollEnabled = NO;
        }
        
        // MN-3490 要求 iPhone 修改样式
        if (INTERFACE_IS_PHONE) {
            if (width < btnEqualWidth) {
                width = btnEqualWidth;
            }
        }
        
        button.frame = CGRectMake(x, self.height - buttonHeight, width, buttonHeight);
        
        CGRect rect = CGRectMake(0, 0, width, buttonHeight);
        CGSize radio = CGSizeMake(5, 5);//圆角尺寸
        UIRectCorner corner = UIRectCornerTopLeft | UIRectCornerTopRight;//这只圆角位置
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corner cornerRadii:radio];
        CAShapeLayer *masklayer = [[CAShapeLayer alloc]init];//创建shapelayer
        masklayer.frame = button.bounds;
        masklayer.path = path.CGPath;//设置路径
        button.layer.mask = masklayer;
        
        x += width + buttonGap;
        
    }
    
    if (x < self.width && self.alignment == WSTitleTabViewAlignmentCenter) {
        x = (self.width - (x - xOffset - buttonGap))/2;
        for (NSInteger i = 0; i < [self.buttonArray count]; i++) {
            UIButton *button = _buttonArray[i];
            button.frame = CGRectMake(x, button.top, button.width, button.height);
            x += button.width + buttonGap;
        }
    }
}

- (void)setTitle:(NSString *)title forTabAtIndex:(NSUInteger)index
{
    UIButton *button = _buttonArray[index];
    [button setTitle:title forState:UIControlStateNormal];
    
    [self refreshButtonFrame];
}

- (void)refreshTitlesWithTitleArray:(NSArray *)titleArray
{
    for (NSInteger i = 0; i < [titleArray count]; i++) {
        
        NSString *title = titleArray[i];
        
        UIButton *button = _buttonArray[i];
        [button setTitle:title forState:UIControlStateNormal];

    }
    
    [self refreshButtonFrame];

}

@end

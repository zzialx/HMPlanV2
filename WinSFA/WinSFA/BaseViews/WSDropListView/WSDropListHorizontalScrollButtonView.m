//
//  WSDropListHorizontalScrollButtonView.m
//  WinSFA
//
//  Created by HZH on 2018/3/22.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSDropListHorizontalScrollButtonView.h"

#define kSpacing        (MAIN_PADDING / 2)

@interface WSDropListHorizontalScrollButtonView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *bgScrollView;
//@property (nonatomic, strong) NSMutableArray *selectedArray;
@property (nonatomic, strong) NSMutableDictionary *cellIdDic;
@property (nonatomic, strong) NSMutableArray *buttonsMArray;
@property (nonatomic, strong) NSArray *itemFrameArray;

@end

@implementation WSDropListHorizontalScrollButtonView

- (void)setDataSourceArray:(NSArray *)dataSourceArray {
    [super setDataSourceArray:dataSourceArray];
    
    
    [self setupSubviews];
}

- (void)setupSubviews
{
    self.buttonsMArray = [[NSMutableArray alloc] init];
    
    CGFloat height = [self getViewHeight];
    self.height = height + 2 * kSpacing;
    CGRect frame = CGRectMake(0, kSpacing, self.width, height);
    
    
    if (!self.bgScrollView) {
        self.bgScrollView = [[UIScrollView alloc] initWithFrame:frame];
        self.bgScrollView.showsHorizontalScrollIndicator = NO;
        
        CGFloat contentWidth = 0.0;
        
        for (NSUInteger i = 0; i < [self.dataSourceArray count]; i ++) {
            NSObject<I_W_OptionDataItem> *dataItem = [self.dataSourceArray objectAtIndex:i];

            UIButton *contentButton = [[UIButton alloc] initWithFrame:CGRectMake(MAIN_CELL_BUTTON_WH * i + kSpacing * (i + 1), 0, MAIN_CELL_BUTTON_WH, MAIN_CELL_BUTTON_WH)];
            contentButton.titleLabel.font = [UIFont systemFontOfSize:UI_Font];
            contentButton.titleLabel.adjustsFontSizeToFitWidth = YES;
            [contentButton setTitleColor:MAIN_TEXT_COLOR forState:UIControlStateNormal];
            [contentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            UIImage *normalImage = [UIImage imageFromColor:BTN_GRAY_BG_COLOR with:contentButton.frame];
            UIImage *selectedImage = [UIImage imageFromColor:MAIN_TINT_COLOR with:contentButton.frame];
            [contentButton setBackgroundImage:normalImage forState:UIControlStateNormal];
            [contentButton setBackgroundImage:selectedImage forState:UIControlStateSelected];
            
            [contentButton setTitle:[dataItem getDataItemName] forState:UIControlStateNormal];
            
            [contentButton addTarget:self action:@selector(contentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:contentButton.bounds
                                                                cornerRadius:contentButton.height];
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = contentButton.bounds;
            maskLayer.path = maskPath.CGPath;
            contentButton.layer.mask = maskLayer;
            contentButton.titleLabel.font = [UIFont systemFontOfSize:UI_Font];
            
            [self.bgScrollView addSubview:contentButton];

            [self.buttonsMArray addObject:contentButton];
            
            if (i == [self.dataSourceArray count] - 1) {
                contentWidth = contentButton.frame.origin.x + contentButton.frame.size.width + kSpacing;
            }
        }
        
        CGSize contentSize = CGSizeMake(contentWidth, height);
        self.bgScrollView.contentSize = contentSize;
        
        [self addSubview:self.bgScrollView];
        
    }
}

- (void)contentButtonClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    NSUInteger bIndex = [self.buttonsMArray indexOfObject:btn];
    
    if (self.selectedItem) {
        NSUInteger dIndex = [self.dataSourceArray indexOfObject:self.selectedItem];
        UIButton *lastClickedBtn = [self.buttonsMArray objectAtIndex:dIndex];
        [lastClickedBtn setSelected:NO];
    }
    
    self.selectedItem = [self.dataSourceArray objectAtIndex:bIndex];
    
    [btn setSelected:YES];

    if (self.dropListDelegate &&
        [self.dropListDelegate respondsToSelector:@selector(dropListViewDidChangeSelect:)])  {
        [self.dropListDelegate performSelector:@selector(dropListViewDidChangeSelect:) withObject:self];
    }
    
    self.isValueChange = YES;
}

- (CGFloat)getViewHeight {
    if (!self.dataSourceArray || self.dataSourceArray.count == 0) {
        return 0;
    }
    
    return MAIN_CELL_BUTTON_WH;
}

- (void)setUpSelectionByItemIDArray:(NSArray *)dataItemIDArray {
    [super setUpSelectionByItemIDArray:dataItemIDArray];
    
    if (self.selectedItem) {
        NSUInteger dIndex = [self.dataSourceArray indexOfObject:self.selectedItem];
        UIButton *lastClickedBtn = [self.buttonsMArray objectAtIndex:dIndex];
        [lastClickedBtn setSelected:YES];
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

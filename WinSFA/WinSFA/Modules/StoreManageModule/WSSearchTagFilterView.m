//
//  WSSearchTagFilterView.m
//  WinSFA
//
//  Created by yang on 16/3/9.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSearchTagFilterView.h"
#import "WSSearchTagGroupView.h"
#import "WSBaseAcvtDBService.h"

#define kAnimationDuration 0.3

#define kBottomViewHeight 46

#define kButtonWidth 90
#define kButtonHeight 32
#define kButtonLeftOffset 15


#define kViewGap 5

@interface WSSearchTagFilterView ()

@property (nonatomic, copy) NSString *searchTagString;

@property (nonatomic, strong) WSAcvtBean *acvtBean;

@property (nonatomic, strong) UIView *blockView;

@property (nonatomic, strong) UIScrollView *contentView;

@property (nonatomic, strong) NSMutableArray *groupViewArray;

@end

@implementation WSSearchTagFilterView

- (instancetype)initWithFrame:(CGRect)frame searchTagString:(NSString *)searchTagString
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _searchTagString = searchTagString;
        
        if ([searchTagString length] > 0) {
        
            WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];
            _acvtBean = [[baseAcvtDBService queryAcvtsByFilter:searchTagString acvtCode:searchTagString] firstObject];
        }
        
        _groupViewArray = [NSMutableArray array];
        
        self.backgroundColor = [UIColor whiteColor];//[UIColor colorWithHexString:@"f0eff5"];
        
        
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 64)];
        
        UIColor *navBarBackgroudColor;
        
        navBarBackgroudColor = [UIColor colorForKey:@"NavigationBarBackgroundColor"];
        if (INTERFACE_IS_PAD) {
            navBarBackgroudColor = MAIN_TINT_COLOT;
        }
        if (!navBarBackgroudColor) {
            navBarBackgroudColor = MAIN_TINT_COLOT;
        }

        
        titleView.backgroundColor = navBarBackgroudColor;
        
        [self addSubview:titleView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, titleView.width, 44)];
        label.text = NSLocalizedString(@"w_filter", nil);
        label.font = [UIFont boldSystemFontOfSize:INTERFACE_IS_PHONE ? 18 : 20];
        label.textColor = [UIColor whiteColor];
        [label setTextAlignment:NSTextAlignmentCenter];
        [titleView addSubview:label];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.width - 50, 20, 50, 44)];
        [button setBackgroundColor:[UIColor clearColor]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:NSLocalizedString(@"disable_lable", nil) forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:UI_Font]];
        [button addTarget:self action:@selector(hideView) forControlEvents:UIControlEventTouchUpInside];
        [titleView addSubview:button];
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, titleView.bottom, self.width, self.height - titleView.height - kBottomViewHeight)];
        
        CGFloat y = kViewGap;
        WSSearchTagGroupView *groupView = nil;
        
        if (self.acvtBean) {
            for (WSAcvtBean_qst *qstBean in self.acvtBean.qsts) {
                groupView = [[WSSearchTagGroupView alloc] initWithFrame:CGRectMake(0, y, self.width, 40) qstBean:qstBean];
                [scrollView addSubview:groupView];
                [self.groupViewArray addObject:groupView];
                y += groupView.height + kViewGap;
            }
        }else {
            groupView = [[WSSearchTagGroupView alloc] initWithFrame:CGRectMake(0, y, self.width, 40) searchTagString:_searchTagString];
            [scrollView addSubview:groupView];
            [self.groupViewArray addObject:groupView];
            y += groupView.height + kViewGap;
        }
       
        
        [scrollView setContentSize:CGSizeMake(scrollView.width, y)];
        
        [self addSubview:scrollView];
        
        _contentView = scrollView;
        
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - kBottomViewHeight, self.width, kBottomViewHeight)];
        bottomView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        bottomView.backgroundColor = RGBCOLOR(241, 241, 241);
        
        UIButton *resetButton = [[UIButton alloc] initWithFrame:CGRectMake(kButtonLeftOffset, (kBottomViewHeight - kButtonHeight)/2, kButtonWidth, kButtonHeight)];
        [resetButton addTarget:self action:@selector(resetAction) forControlEvents:UIControlEventTouchUpInside];
        [resetButton setTitle:NSLocalizedString(@"w_reset", nil) forState:UIControlStateNormal];
        [resetButton.titleLabel setFont:[UIFont systemFontOfSize:UI_Font]];
        [resetButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        resetButton.backgroundColor = RGBCOLOR(248, 248, 248);
        resetButton.layer.borderWidth = 1.0;
        resetButton.layer.borderColor = RGBCOLOR(220, 220, 220).CGColor;
        resetButton.layer.cornerRadius = 5.0;
        [bottomView addSubview:resetButton];
        
        UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(self.width - kButtonLeftOffset - kButtonWidth, (kBottomViewHeight - kButtonHeight)/2, kButtonWidth, kButtonHeight)];
        [searchButton addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
        [searchButton setTitle:NSLocalizedString(@"query_label", nil) forState:UIControlStateNormal];
        [searchButton setBackgroundColor:navBarBackgroudColor];
        [searchButton.titleLabel setFont:[UIFont systemFontOfSize:UI_Font]];
        searchButton.layer.cornerRadius = 5.0;
        [bottomView addSubview:searchButton];
        
        [self addSubview:bottomView];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - kBottomViewHeight - 1, self.width, 1)];
        line.backgroundColor = RGBCOLOR(232, 232, 232);
        [self addSubview:line];
    }
    
    return self;
}

- (void)showOnView:(UIView *)superView
{
    self.blockView = [[UIView alloc] initWithFrame:superView.bounds];
    self.blockView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.blockView.alpha = 0.01;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blockViewTapped:)];
    [self.blockView addGestureRecognizer:tap];
    [superView addSubview:self.blockView];
    
    CGRect endFrame = self.frame;
    self.frame = CGRectMake(endFrame.origin.x + self.width, endFrame.origin.y, self.width, self.height);
    
    [superView addSubview:self];
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.frame = endFrame;
        self.blockView.alpha = 1.0;
    }];
}

- (void)hideView
{
    [self.blockView removeFromSuperview];
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.frame = CGRectMake(self.frame.origin.x + self.width, self.frame.origin.y, self.width, self.height);;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)blockViewTapped:(id) sender
{
    [self hideView];
}

- (void)searchAction
{
    if ([self.delegate respondsToSelector:@selector(searchTagView:searchButtonClicked:)]) {
        NSMutableArray *array = [NSMutableArray array];
        for (WSSearchTagGroupView *groupView in self.groupViewArray) {
            [array addObjectsFromArray:groupView.selectedTagArray];
        }
        
        [self.delegate searchTagView:self searchButtonClicked:array];
    }
    
    [self hideView];
}

- (void)resetAction
{
    for (WSSearchTagGroupView *groupView in self.groupViewArray) {
        [groupView resetAllTags];
    }
    
    [self.delegate searchTagView:self searchButtonClicked:nil];
}

- (void)setSelectedSearchTagArray:(NSArray *)selectedSearchTagArray
{
    for (WSSearchTagGroupView *groupView in _groupViewArray) {
        [groupView setSelectedTagArray:[selectedSearchTagArray mutableCopy]];
    }
}

@end

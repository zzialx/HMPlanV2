//
//  WSNextStepFuncsView.m
//  WinSFA
//
//  Created by Alicia on 2017/12/6.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSNextStepFuncsView.h"
#import "WSNextStepFuncsItemButton.h"
#import "WSNextStepFuncsItemLineButton.h"
#import "HYPageView.h"

#define kPaddingY           2
#define kTagBase            100

@interface WSNextStepFuncsView () <HYPageViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *vcArray;
@property (nonatomic, strong) id target;
@property (nonatomic, assign) CGFloat itemWidth;
@property (nonatomic, assign) WSNextStepFuncsViewStyle viewStyle;
@end

@implementation WSNextStepFuncsView

//- (instancetype)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame:frame];
//    if (self) {
//
//    }
//    return self;
//}

- (void)setupViews {
    if (!self.scrollView) {
        UIScrollView *scrollView;
        if (_viewStyle == WSNextStepFuncsUnderLineScroll) {
            scrollView = [self createHYPageView];
        } else {
            scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kPaddingY, self.width, self.height - 2 * kPaddingY)];
        }
        
        self.scrollView = scrollView;
        [self.scrollView setShowsHorizontalScrollIndicator:NO];
        [self.scrollView setShowsVerticalScrollIndicator:NO];
        [self addSubview:self.scrollView];
        
        [self setBackgroundColor:GRID_BG_COLOR];
        
        //    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - MAIN_CELL_SEPERATOR_HEIGHT, self.width, MAIN_CELL_SEPERATOR_HEIGHT)];
        //    [bottomView setBackgroundColor:MAIN_SEPERATE_LINE_COLOR];
        //    [self addSubview:bottomView];
        
    } else {
        [self.scrollView removeAllSubviews];
    }
    

    [self createItemButtonWithFuncsArray:_funcsArray viewStyle:_viewStyle];
    
}

- (HYPageView *)createHYPageView {
    if (!self.funcsArray || [self.funcsArray count] == 0 || !self.vcArray || [self.vcArray count] == 0) {
        return nil;
    }
    NSMutableArray *titleArray = [NSMutableArray arrayWithCapacity:self.funcsArray.count];
    for (NSInteger i = 0; i < [self.funcsArray count]; i++) {
        WSFuncsBean *funcsBean = self.funcsArray[i];
        [titleArray addObject:funcsBean.name];
    }
    
    HYPageView *pageView = [[HYPageView alloc] initWithFrame:self.bounds withTitles:[titleArray copy] withViewControllers:self.vcArray withParameters:nil];
    pageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    pageView.pageDelegate = self;
    return pageView;
}

- (void)setFuncsArray:(NSArray *)funcsArray {
    _funcsArray = funcsArray;
    
    [self setupViews];
}


- (void)createItemButtonWithFuncsArray:(NSArray *)funcsArray viewStyle:(WSNextStepFuncsViewStyle)viewStyle {
    if (_viewStyle == WSNextStepFuncsUnderLineScroll) {
        return;
    }
    CGFloat viewWidth = 0;
    NSInteger count = funcsArray.count;
    CGFloat width = self.width / count;
    CGFloat itemWidth = width;
    if (viewStyle == WSNextStepFuncsArrow) {
        width += kNextStepArrowWidth;
        itemWidth = itemWidth < kNextStepMinWidth ? kNextStepMinWidth : itemWidth;
    }
    
    self.itemWidth = itemWidth;
    for (NSInteger i = 0; i < count; i++) {
        WSNextStepFuncsItemButton *itemButton;
        if (viewStyle == WSNextStepFuncsArrow) {
            CGFloat offsetX = i * (itemWidth - kNextStepArrowWidth) -  kNextStepArrowWidth / 2 ;
            itemButton = [[WSNextStepFuncsItemButton alloc] initWithFrame:CGRectMake(offsetX, 0, itemWidth, self.scrollView.height)];
        } else {
            CGFloat offsetX = i * itemWidth;
            itemButton = [[WSNextStepFuncsItemLineButton alloc] initWithFrame:CGRectMake(offsetX, 0, itemWidth, self.scrollView.height)];
        }
        WSFuncsBean *funcsBean = self.funcsArray[i];
        [itemButton setFuncsBean:funcsBean];
        [itemButton setCurrentIndex:i];
        [itemButton setTag:kTagBase + i];
        
        BOOL isLastItem = NO;
        if (i == count - 1) {
            isLastItem = YES;
        }
        [itemButton setIsLastItem:isLastItem];	
        
        [self.scrollView addSubview:itemButton];
        [self.scrollView sendSubviewToBack:itemButton];
        
        [itemButton addTarget:self action:@selector(gotoNextFuncsAction:) forControlEvents:UIControlEventTouchUpInside];
        
        if (i == 0) {
            [itemButton setSelected:YES];
        }
        
        viewWidth += itemWidth;
        if (viewStyle == WSNextStepFuncsArrow) {
            viewWidth -= kNextStepArrowWidth;
        }
    }
    
    [self.scrollView setContentSize:CGSizeMake(viewWidth, self.scrollView.size.height)];
}


#pragma mark - Action
- (void)gotoNextFuncsAction:(WSNextStepFuncsItemButton *)button {
    if (self.delegate) {
        [self.delegate gotoFuncs:button.funcsBean index:button.currentIndex];
    }
}

#pragma mark - Property
- (void)setCurrentIndex:(NSInteger)currentIndex {
    if (currentIndex == _currentIndex) {
        return;
    }
   
    WSNextStepFuncsItemButton *lastButton = [((WSNextStepFuncsItemButton *)self) viewWithTag:kTagBase + self.currentIndex];
    [lastButton setSelected:NO];
    
    _currentIndex = currentIndex;
    
    WSNextStepFuncsItemButton *currentButton = [((WSNextStepFuncsItemButton *)self) viewWithTag:kTagBase + currentIndex];
    [currentButton setSelected:YES];
    
    [self moveToVisibleWithIndex:currentIndex];
}

#pragma mark - Public method
- (void)setHasVisitedIndex:(NSInteger)index
{
    //MN-1965 2018-04-20
    WSNextStepFuncsItemButton *lastButton = [((WSNextStepFuncsItemButton *)self) viewWithTag:kTagBase + index];
    if([lastButton isKindOfClass:[WSNextStepFuncsItemButton class]])
        [lastButton setHasVisited];
}

- (void)setViewStyle:(WSNextStepFuncsViewStyle)viewStyle vcArray:(NSArray *)vcArray {
    _viewStyle = viewStyle;
    _vcArray = vcArray;
}


- (void)moveToVisibleWithIndex:(NSInteger)index {
    if ([self.scrollView isKindOfClass:[HYPageView class]]) {
        if (index >=0) {
            HYPageView *pageView = (HYPageView *)self.scrollView;
            [pageView scrollToIndex:index];
        }
    } else {
        CGFloat posX = self.itemWidth * index;
        if (posX > self.width) {
            posX = self.scrollView.contentSize.width - self.width;
            CGPoint offset = self.scrollView.contentOffset;
            offset.x = posX;
            [self.scrollView setContentOffset:offset];
        } else if (self.scrollView.contentOffset.x > 0) {
            CGPoint offset = self.scrollView.contentOffset;
            offset.x = 0;
            [self.scrollView setContentOffset:offset];
        }
    }
}

- (void)resetVCFrameWithIndex:(NSInteger)index frame:(CGRect)frame {
    if (index >= 0 && index < self.vcArray.count) {
        UIViewController *vc = self.vcArray[index];
        vc.view.frame = frame;
        vc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
}

- (UIViewController *)getViewControllerByIndex:(NSInteger)index {
    return self.vcArray[index];
}

#pragma mark - HYPageViewDelegate
- (BOOL)isEnableToController:(UIViewController *)vc pageIndex:(NSInteger)pageIndex {
    if (self.delegate) {
        return [self.delegate isValidController:vc index:pageIndex];
    } else {
        return YES;
    }
}

@end

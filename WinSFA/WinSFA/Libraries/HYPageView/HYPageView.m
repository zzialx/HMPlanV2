//
//  HYPageView.m
//  HYNavigation
//
//  Created by runlhy on 16/9/27.
//  Copyright © 2016年 Pengcent. All rights reserved.
//
#define LEFT_SPACE 20
#define RIGHT_SPACE 20
#define MIN_SPACING 20
#define TAB_HEIGHT 44
#define TOP_SPACE 20
#define LINEBOTTOM_HEIGHT 2
#define TOPBOTTOMLINEBOTTOM_HEIGHT .5
#define SELECTED_COLOR MAIN_TINT_COLOR
#define UNSELECTED_COLOR [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0]
#define TPOTABBOTTOMLINE_COLOR [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0]

#import "HYPageView.h"
#import <objc/runtime.h>
#import "DateView.h"
#import "WSStatisticsManager.h"
#import "WSReportFormController.h"
#import "WinJSBridgeViewController.h"

@interface HYScrollView : UIScrollView

@end

@implementation HYScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    NSString *classStr = NSStringFromClass([otherGestureRecognizer.view class]);
    if ([classStr isEqualToString:@"UITableView"] || [classStr isEqualToString:@"UIWebBrowserView"] || [classStr isEqualToString:@"WSAcvtScrollView"] || [classStr isEqualToString:@"WKContentView"]) {
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    NSString *classStrTouch = NSStringFromClass([touch.view class]);
    if ([classStrTouch isEqualToString:@"MKNewAnnotationContainerView"]|| [classStrTouch isEqualToString:@"MKAnnotationContainerView"] || [classStrTouch isEqualToString:@"UIWebOverflowContentView"] ||
        [classStrTouch isEqualToString:@"BMKTapDetectingView"]|| [classStrTouch isEqualToString:@"UIWebBrowserView"]) {
        return NO;
    }
    
    classStrTouch = NSStringFromClass([touch.view.superview class]);
    if ([classStrTouch isEqualToString:@"WSPlanCalendarManageTableViewCell"]) {
        return NO;
    }
    
    if ([touch.view isKindOfClass:[DateView class]] || [touch.view isKindOfClass:[MBProgressHUD class]] || [touch.view isKindOfClass:[WSReportFormController class]]) {
        return NO;
    }
    
    if ([touch.view.viewController isKindOfClass:[WinJSBridgeViewController class]] ||
        [touch.view.viewController isKindOfClass:[WSReportFormController class]]) {
        return NO;
    }
    
    return YES;
}

@end

@interface HYPageView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIView *topTabView;
@property (nonatomic, strong) UIScrollView *topTabScrollView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *strongArray;
@property (nonatomic, strong) NSMutableDictionary *additionalInfo;
@property (nonatomic, assign) BOOL isResetTitle;
@property (nonatomic, weak) UIViewController *viewController;

@end

@implementation HYPageView{
    
    CGRect _selfFrame;
    NSInteger _topTabScrollViewWidth;
    
    NSMutableArray        <NSString *> *_titles;
    NSMutableArray *_viewControllers;
    NSArray        *_parameters;
    UIView         *_lineBottom;
    NSMutableArray *_titleButtons;
    NSMutableArray *_titleSizeArray;
    NSMutableArray *_centerPoints;
    
    NSMutableArray *_width_k_array;
    NSMutableArray *_width_b_array;
    NSMutableArray *_point_k_array;
    NSMutableArray *_point_b_array;
    NSInteger _oldPageIndex;
    NSInteger _newPageIndex;
    BOOL _isActionFromBtnClick;
}

- (void)dealloc{
    NSLog(@"%@",self.class);
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"routeSelect" object:nil];

    if (_scrollView) {
        [self removeObserver:self forKeyPath:@"currentPage"];
    }
}

#pragma mark - set Method

- (void)setSelectedColor:(UIColor *)selectedColor{
    _selectedColor              = selectedColor;
    _lineBottom.backgroundColor = selectedColor;
    [self updateSelectedPage:0];
}

- (void)setUnselectedColor:(UIColor *)unselectedColor{
    _unselectedColor    = unselectedColor;
    [self updateSelectedPage:0];
}

-(void)setIsShowRightButton:(BOOL)isShowRightButton{
    _isShowRightButton = isShowRightButton;
    if (isShowRightButton) {
        [self.rightButton setImage:[UIImage imageNamed:@"title-bar_create_icon"] forState:UIControlStateNormal];
        [self.rightButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.rightButton  sizeToFit];
        self.leftButton = [[UIButton alloc]initWithFrame:self.rightButton.bounds];
    }
}

-(UIButton *)rightButton{
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _rightButton;
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    // MN-275 打包服务器有问题暂时屏蔽逻辑
//    if (self.isHideTitle && !self.isResetTitle) {
//        self.isResetTitle = YES;
//        CGRect frame = self.frame;
//        frame.origin.y -= TOP_SPACE;
//        self.frame = frame;
//    }
    _selfFrame = self.frame;

    _scrollView.frame = CGRectMake(0, _scrollView.origin.y, self.width, self.height);
    _scrollView.contentSize = CGSizeMake(_selfFrame.size.width * _titles.count, 0);
    
    _viewController = [self findViewController:self];
    if (![self isNavBarHidden]) {
        _topSpace = 0;
    }
    _font = _font?_font:[UIFont systemFontOfSize:16];
    [self addSubview:self.scrollView];
    // SFA-14257 add by zhiqing
    if (self.isFirstLoad) {
        self.currentPage = 0;
    }
    [self addSubview:self.topTabView];
    [self addSubview:self.topTabScrollView];
    
}

- (BOOL)isNavBarHidden {
     if ((_viewController.navigationController && (_viewController.navigationController.navigationBar.hidden || _viewController.navigationController.navigationBarHidden)) || self.isHideTitle) {
         return YES;
     } else {
         return NO;
     }
}

#pragma mark - lazy
- (UIView *)topTabView{
    if (!_topTabView){
        BOOL isNavBarHidden = [self isNavBarHidden];
        CGFloat y = 0;
        if (isNavBarHidden && !_isAdapteNavigationBar) {
            y = -64;
        }
        CGRect frame = CGRectMake(0, y, _selfFrame.size.width, TAB_HEIGHT + _topSpace);
        _topTabView  = [[UIView alloc] initWithFrame:frame];
        if (_isTranslucent) {
//    MSTD-7476 donghong
//            UIToolbar *backView = [[UIToolbar alloc] initWithFrame:_topTabView.bounds];
//            backView.barStyle   = UIBarStyleDefault;
//            [_topTabView addSubview:backView];
        }else{
            UIColor *navBarBackgroudColor = [UIColor whiteColor];
            if (isNavBarHidden) {
                navBarBackgroudColor = [UIColor colorForKey:@"NavigationBarBackgroundColor"];
            }
            _topTabView.backgroundColor = navBarBackgroudColor;
        
        }
        if (self.leftButton) {
            self.leftButton.center = CGPointMake(self.leftButton.bounds.size.width / 2 + LEFT_SPACE, TAB_HEIGHT / 2 + _topSpace);
            [_topTabView addSubview:self.leftButton];
        }
        if (_isShowRightButton) {
            self.rightButton.center = CGPointMake(_selfFrame.size.width - self.rightButton.bounds.size.width / 2 - RIGHT_SPACE , TAB_HEIGHT / 2 + _topSpace);
            [_topTabView addSubview:self.rightButton];
        }
        if (!self.bottomImage) {
            UIView *topTabBottomLine = [UIView new];
            topTabBottomLine.backgroundColor = _topTabBottomLineColor;
            topTabBottomLine.frame = CGRectMake(0, TAB_HEIGHT + _topSpace - TOPBOTTOMLINEBOTTOM_HEIGHT, _selfFrame.size.width, TOPBOTTOMLINEBOTTOM_HEIGHT);
            [_topTabView addSubview:topTabBottomLine];
        }
    }
    return _topTabView;
}

- (UIScrollView *)topTabScrollView{
    if (!_topTabScrollView){
        CGFloat leftWidth  = 0;
        CGFloat rightWidth = 0;
        if (self.leftButton) {
            leftWidth = self.leftButton.bounds.size.width + LEFT_SPACE;
        }
        if (_isShowRightButton) {
            rightWidth = self.rightButton.bounds.size.width + RIGHT_SPACE;
        }
        _topTabScrollViewWidth = _selfFrame.size.width - leftWidth - rightWidth;
        CGRect frame = CGRectMake(leftWidth, _topSpace + _topTabView.frame.origin.y, _topTabScrollViewWidth, TAB_HEIGHT);
        _topTabScrollView = [[UIScrollView alloc] initWithFrame:frame];
        _topTabScrollView.showsHorizontalScrollIndicator = NO;
        _topTabScrollView.alwaysBounceHorizontal = YES;
        _topTabScrollView.scrollsToTop = NO;
        
        CGFloat totalWidth = 0;
        _titleSizeArray    = [NSMutableArray array];
        CGFloat equalX     = _leftSpace;
        NSMutableArray *equalIntervals = [NSMutableArray array];
        
        for (NSInteger i=0; i<_titles.count; i++) {
            CGSize titleSize = [_titles[i] sizeWithAttributes:@{NSFontAttributeName:_font}];
            [_titleSizeArray addObject:[NSValue valueWithCGSize:titleSize]];
            totalWidth += titleSize.width;
            [equalIntervals addObject:[NSNumber numberWithFloat:(equalX + titleSize.width/2)]];
            equalX += _minSpace + titleSize.width;
        }
        
        CGFloat dividend = _titles.count>1?_titles.count-1:1;
        CGFloat minWidth = (_topTabScrollViewWidth - totalWidth - _leftSpace - _rightSpace) / dividend;
        CGFloat averageX = _leftSpace;
        if (_isAverage) {
            minWidth = (_topTabScrollViewWidth - totalWidth) / (_titles.count + 1);
            averageX = minWidth;
        }
        NSMutableArray *averageIntervals = [NSMutableArray array];
        for (NSInteger i=0; i<_titles.count; i++) {
            [averageIntervals addObject:[NSNumber numberWithDouble:(averageX + [_titleSizeArray[i] CGSizeValue].width/2)]];
            averageX += minWidth + [_titleSizeArray[i] CGSizeValue].width;
        }
        totalWidth += (_titles.count - 1) * _minSpace + _leftSpace + _rightSpace;
        NSMutableArray *centerPoints = [NSMutableArray array];
        if (totalWidth > _topTabScrollViewWidth){
            centerPoints = equalIntervals;
        }else{
            centerPoints = averageIntervals;
            totalWidth = _topTabScrollViewWidth;
        }
        _centerPoints = centerPoints;
        _width_k_array = [NSMutableArray array];
        _width_b_array = [NSMutableArray array];
        _point_k_array = [NSMutableArray array];
        _point_b_array = [NSMutableArray array];
        
        for (NSInteger i=0; i<_titles.count-1; i++) {
            CGFloat k = ([_centerPoints[i+1] floatValue] - [_centerPoints[i] floatValue])/_selfFrame.size.width;
            CGFloat b = [_centerPoints[i] floatValue] - k * i * _selfFrame.size.width;
            [_width_k_array addObject:[NSNumber numberWithFloat:k]];
            [_width_b_array addObject:[NSNumber numberWithFloat:b]];
        }
        for (NSInteger i=0; i<_titles.count-1; i++) {
            [self setPointArray:i isReplace:NO];
        }
        
        _topTabScrollView.contentSize = CGSizeMake(totalWidth, 0);
        _titleButtons = [NSMutableArray array];
        for (NSInteger i=0; i<_titles.count; i++) {
            UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
            titleButton.tag = i;
            [_titleButtons addObject:titleButton];
            titleButton.titleLabel.font = _font;
            [titleButton setTitle:_titles[i] forState:UIControlStateNormal];
            CGFloat x = [_centerPoints[i] floatValue];
            CGFloat width = [_titleSizeArray[i] CGSizeValue].width;
            CGRect buttonFrame = CGRectMake(x-width/2, 0, width, TAB_HEIGHT);
            titleButton.frame = buttonFrame;
            [_topTabScrollView addSubview:titleButton];
            [titleButton addTarget:self action:@selector(touchAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        _titleBadgeView = [NSMutableArray array];
        for (NSInteger i=0; i<_titleButtons.count; i++) {
            UIButton *button = _titleButtons[i];
            JSBadgeView *badgeView = [[JSBadgeView alloc] initWithParentView:button.titleLabel alignment:JSBadgeViewAlignmentTopRight];
            [badgeView setBadgeMinWidth:10];
            [_titleBadgeView addObject:badgeView];
        }
        
        UIButton *button = _titleButtons[0];
        
        [[WSStatisticsManager sharedInstance] insertMenuPageSenceEventWithID:EVENT_MENU_CLICK parentFuncBean:nil currentFuncBean:nil store:nil eventValue:button.titleLabel.text startTime:[WSCurrentTime getTimeMillisStringForDevice] endTime:nil genId:[WSStatisticsManager getGenId]];
        
        [self updateSelectedPage:0];
        
        UIView *topTabBottomLine = [UIView new];
        topTabBottomLine.frame = CGRectMake(-totalWidth, TAB_HEIGHT - TOPBOTTOMLINEBOTTOM_HEIGHT, totalWidth*3, TOPBOTTOMLINEBOTTOM_HEIGHT);
        topTabBottomLine.backgroundColor = _topTabBottomLineColor;
        [_topTabScrollView addSubview:topTabBottomLine];
        
        // 保留之前标题底部线为标题长度的设置
        UIButton *titleBtn01 = (UIButton *)[_titleButtons firstObject];
        if (!self.bottomImage) {
        _lineBottom = [[UIView alloc] initWithFrame:CGRectMake(titleBtn01.frame.origin.x, TAB_HEIGHT - LINEBOTTOM_HEIGHT,[_titleSizeArray[0] CGSizeValue].width, LINEBOTTOM_HEIGHT)];
//        _lineBottom.center = CGPointMake([centerPoints[0] floatValue], _lineBottom.center.y);
        
        // 标题底部线长度为_topTabScrollView.contentSize按标题数量均分
//        _lineBottom = [[UIView alloc] initWithFrame:CGRectMake(0, TAB_HEIGHT - LINEBOTTOM_HEIGHT,_topTabScrollView.contentSize.width/_titles.count, LINEBOTTOM_HEIGHT)];
//        _lineBottom.center = CGPointMake(_topTabScrollView.contentSize.width/_titles.count/2, _lineBottom.center.y);
            
            _lineBottom.backgroundColor = _selectedColor;
        } else {
            CGFloat imageHeight = self.bottomImage.size.height;
            UIImageView *topTabBottomImageView = [[UIImageView alloc] initWithImage:self.bottomImage];
            topTabBottomImageView.frame = CGRectMake(titleBtn01.frame.origin.x, TAB_HEIGHT - imageHeight, [_titleSizeArray[0] CGSizeValue].width, imageHeight);
            [topTabBottomImageView setContentMode:UIViewContentModeCenter];
            _lineBottom = topTabBottomImageView;
        }
        [_topTabScrollView addSubview:_lineBottom];
        
        if ([self.pageDelegate respondsToSelector:@selector(refreshBadge)]) {
            [self.pageDelegate refreshBadge];
        }
    }
    return _topTabScrollView;
}

- (void)setPointArray:(NSInteger)i isReplace:(BOOL)isReplace {
    if (i >= _titleSizeArray.count-1) {
        return;
    }
    CGFloat k = ([_titleSizeArray[i+1] CGSizeValue].width - [_titleSizeArray[i] CGSizeValue].width)/_selfFrame.size.width;
    CGFloat b = [_titleSizeArray[i] CGSizeValue].width - k * i * _selfFrame.size.width;
    if (!isReplace) {
        [_point_k_array addObject:[NSNumber numberWithFloat:k]];
        [_point_b_array addObject:[NSNumber numberWithFloat:b]];
    } else {
        [_point_k_array replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:k]];
        [_point_b_array replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:b]];
    }
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[HYScrollView alloc] init];
        _scrollView.scrollsToTop = NO;
        
        CGFloat y = 0;
//        if (_viewController.navigationController && !_viewController.navigationController.navigationBar.hidden && !_viewController.navigationController.navigationBarHidden) {
//            y = -64;
//        }else if (_viewController.navigationController && (_viewController.navigationController.navigationBar.hidden || _viewController.navigationController.navigationBarHidden)){
//            y = -20;
//        }
        
        _scrollView.frame = CGRectMake(0, y, self.width, self.height);
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.contentSize = CGSizeMake(_selfFrame.size.width * _titles.count, 0);
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.bounces = self.isScrollViewBounces;
        [self addObserver:self forKeyPath:@"currentPage" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
        // SFA-14257 add by zhiqing
//        self.currentPage = 0;
        _oldPageIndex = 0;
        _newPageIndex = 0;
        _isActionFromBtnClick = NO;
    }
    return _scrollView;
}

- (NSMutableArray *)strongArray{
    if (!_strongArray){
        _strongArray = [NSMutableArray arrayWithArray:_viewControllers];
    }
    return _strongArray;
}

#pragma mark - Calculation Method

- (CGFloat)getTitleWidth:(CGFloat)offset{
    return [self getTitleCalculationByOffset:offset kArray:_width_k_array bArray:_width_b_array];
}

- (CGFloat)getTitlePoint:(CGFloat)offset{
    return [self getTitleCalculationByOffset:offset kArray:_point_k_array bArray:_point_b_array];
}

//对title 的计算
- (CGFloat)getTitleCalculationByOffset:(CGFloat)offset kArray:(NSArray *)kArray bArray:(NSArray *)bArray {
    
    NSInteger index = (NSInteger)(offset / _selfFrame.size.width);
    // MMSH-1440 添加越界处理，防止非正常操作出现数组越界的问题
    if (index >= [kArray count]) {
        index = [kArray count] - 1;
    }
    CGFloat k = 0;
    CGFloat b = 0;
    if (index >= 0 && index < kArray.count && index < bArray.count) {
        k = [kArray[index] floatValue];
        b = [bArray[index] floatValue];
    }
    CGFloat x = offset;
    return  k * x + b;
}

- (NSInteger)getPageIndex:(UIScrollView *)scrollView {
    NSInteger newIndex = (NSInteger)((scrollView.contentOffset.x + _selfFrame.size.width / 2) / _selfFrame.size.width);
    return newIndex;
}


- (void)scrollViewEndHandling:(UIScrollView *)scrollView isResetBottom:(BOOL)isResetBottom {
    
    NSInteger newIndex =  [self getPageIndex:scrollView];
    if (newIndex == _currentPage) {
        return;
    }
    
    if ([self.pageDelegate respondsToSelector:@selector(isEnableToController:pageIndex:)]) {

        BOOL isEnable = [self.pageDelegate isEnableToController:_viewControllers[newIndex] pageIndex:newIndex];
        if (!isEnable) {
            [self scrollToIndex:_oldPageIndex];
            self.currentPage = _oldPageIndex;
            return;
        }
    }
    self.currentPage = newIndex;

    if (isResetBottom) {
        [self resetLineBottomViewWithScrollView:scrollView];
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    [self subScrollViewScrollEnabled:NO];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    [self subScrollViewScrollEnabled:YES];
    [self scrollViewEndHandling:scrollView isResetBottom:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    _isActionFromBtnClick = NO;
    [self scrollViewEndHandling:scrollView isResetBottom:YES];
}

// MSTD-5364 程序进入后台或者锁屏后不会调用scrollViewDidEndDecelerating，所以需加上此方法对其特殊处理
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(!decelerate){
        [self scrollViewEndHandling:scrollView isResetBottom:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if (scrollView.contentOffset.x < 0 || scrollView.contentOffset.x > _selfFrame.size.width * (_titles.count-1)) {
        return;
    }
    
//    [self resetLineBottomViewWithScrollView:scrollView];
    
    [self resetLineBottomViewWhenDidScrollWithScrollView:scrollView];

//    _lineBottom.center = CGPointMake((scrollView.contentOffset.x + _topTabScrollView.contentSize.width/_titles.count)/2, _lineBottom.center.y);
//    _lineBottom.bounds = CGRectMake(0, 0, _topTabScrollView.contentSize.width/_titles.count, LINEBOTTOM_HEIGHT);
 
  
    NSInteger page = [self getPageIndex:scrollView];
    [self updateSelectedPage:page];
}

// MN-2376 屏蔽处理，将修改方式改在手势穿透的地方处理
// MSTD-6086 左右滑动的时候禁用子view的滑动事件，避免斜着能滑的反常规操作
//- (void)subScrollViewScrollEnabled:(BOOL)scrollEnabled
//{
//    for (UIViewController *vc in _viewControllers) {
//        for (UIView *view in vc.view.subviews) {
//            if ([view isKindOfClass:[UIScrollView class]]) {
//                UIScrollView *scrollView = (UIScrollView *)view;
//                scrollView.scrollEnabled = scrollEnabled;
//            }
//        }
//    }
//}

// MSTD-6196 新增Tab页 切换动效。

- (void)resetLineBottomViewWhenDidScrollWithScrollView:(UIScrollView *)scrollView
{
    
    //MN-2616 暂时去掉逻辑 在updateSelectedPage方法内增加resetLineBottomViewWithScrollView
    CGFloat page = [self getPageIndex:scrollView] - 0.5;
    
    if (page > _oldPageIndex) {
        
        if (!_isActionFromBtnClick) {
            _newPageIndex = _oldPageIndex + 1 < _titleButtons.count ? _oldPageIndex + 1 : _titleButtons.count - 1;
        }
        
        /*
        UIButton *titleBtn01 = (UIButton *)[_titleButtons objectAtIndex:(_oldPageIndex > 0 ? _oldPageIndex : 0)];
        UIButton *titleBtn02 = (UIButton *)[_titleButtons objectAtIndex:(_newPageIndex < _titleButtons.count ? _newPageIndex : _titleButtons.count - 1)];
        
        CGFloat lineBottomMaxWidth = titleBtn02.frame.origin.x + titleBtn02.frame.size.width - titleBtn01.frame.origin.x;
        
        CGFloat halfScrollPageNum = ((CGFloat)_newPageIndex - (CGFloat)_oldPageIndex)/2 + _oldPageIndex;

        if (page < halfScrollPageNum) {
            CGFloat lineBottomWidth = titleBtn01.frame.size.width + (scrollView.contentOffset.x - _selfFrame.size.width * _oldPageIndex);
            
            lineBottomWidth = lineBottomWidth < lineBottomMaxWidth ? lineBottomWidth : lineBottomMaxWidth ;
            
            lineBottomWidth = lineBottomWidth > titleBtn01.frame.size.width ? lineBottomWidth : titleBtn01.frame.size.width ;
            
            _lineBottom.frame = CGRectMake(titleBtn01.frame.origin.x, _lineBottom.frame.origin.y, lineBottomWidth, _lineBottom.frame.size.height);
        }else{

            CGFloat lineBottomWidth = titleBtn02.frame.size.width + _selfFrame.size.width * _newPageIndex - scrollView.contentOffset.x;
            
            lineBottomWidth = lineBottomWidth < lineBottomMaxWidth ? lineBottomWidth : lineBottomMaxWidth ;
            
            _lineBottom.frame = CGRectMake(titleBtn01.frame.origin.x + lineBottomMaxWidth - lineBottomWidth, _lineBottom.frame.origin.y, lineBottomWidth, _lineBottom.frame.size.height);
        }
         */
        
    }else{
        
        if (!_isActionFromBtnClick) {
            _newPageIndex = _oldPageIndex - 1 > 0 ? _oldPageIndex - 1 : 0;
        }
        
        /*
        UIButton *titleBtn01 = (UIButton *)[_titleButtons objectAtIndex:(_oldPageIndex < _titleButtons.count ? _oldPageIndex : _titleButtons.count - 1)];
        UIButton *titleBtn02 = (UIButton *)[_titleButtons objectAtIndex:(_newPageIndex > 0 ? _newPageIndex : 0)];
        
        CGFloat lineBottomMaxWidth = titleBtn01.frame.origin.x + titleBtn01.frame.size.width - titleBtn02.frame.origin.x;
        
        CGFloat halfScrollPageNum = ((CGFloat)_oldPageIndex - (CGFloat)_newPageIndex)/2 + _newPageIndex;
        
        if (page >= halfScrollPageNum) {
            
            CGFloat lineBottomWidth = titleBtn01.frame.size.width + (_selfFrame.size.width * _oldPageIndex - scrollView.contentOffset.x);
            
            lineBottomWidth = lineBottomWidth < lineBottomMaxWidth ? lineBottomWidth : lineBottomMaxWidth ;
            
            _lineBottom.frame = CGRectMake(titleBtn02.frame.origin.x + lineBottomMaxWidth - lineBottomWidth, _lineBottom.frame.origin.y, lineBottomWidth, _lineBottom.frame.size.height);

        }else{
            CGFloat lineBottomWidth = titleBtn02.frame.size.width + scrollView.contentOffset.x - _selfFrame.size.width * _newPageIndex;
            
            lineBottomWidth = lineBottomWidth < lineBottomMaxWidth ? lineBottomWidth : lineBottomMaxWidth ;
            
            lineBottomWidth = lineBottomWidth > titleBtn02.frame.size.width ? lineBottomWidth : titleBtn02.frame.size.width ;
            
            _lineBottom.frame = CGRectMake(titleBtn02.frame.origin.x, _lineBottom.frame.origin.y, lineBottomWidth, _lineBottom.frame.size.height);
        }
         */
    }
}


// 20170915 以前的调整下划线的方法
- (void)resetLineBottomViewWithScrollView:(UIScrollView *)scrollView
{
    //MN-2894 去掉判断(同 MN-2616 jira 结合开发)
    //if (self.bottomImage)
    //return;
    
    if (scrollView.contentOffset.x < _selfFrame.size.width)
    {
        _lineBottom.center = CGPointMake([self getTitleWidth:scrollView.contentOffset.x], _lineBottom.center.y);
        _lineBottom.bounds = CGRectMake(0, 0, [self getTitlePoint:scrollView.contentOffset.x], LINEBOTTOM_HEIGHT);
    }
    else
    {
        // scrollView.contentOffset.x >= _selfFrame.size.width 会超出边界，导致getTitleWidth和getTitlePoint方法出现数组越界的情况，此处加了特殊处理
        _lineBottom.center = CGPointMake([self getTitleWidth:scrollView.contentOffset.x - 1], _lineBottom.center.y);
        _lineBottom.bounds = CGRectMake(0, 0, [self getTitlePoint:scrollView.contentOffset.x - 1], LINEBOTTOM_HEIGHT);
    }
}

-(void)buttonClick:(UIButton *)sender{
    
    if ([self.pageDelegate respondsToSelector:@selector(currentPageClickButtonWithPageIndex:)]) {
        [self.pageDelegate currentPageClickButtonWithPageIndex:self.currentPage];
    }
}
#pragma mark - My Method

- (void)touchAction:(UIButton *)button {
    _isActionFromBtnClick = YES;
    _newPageIndex = button.tag;
    
    [[WSStatisticsManager sharedInstance] insertMenuPageSenceEventWithID:EVENT_MENU_CLICK parentFuncBean:nil currentFuncBean:nil store:nil eventValue:button.titleLabel.text startTime:[WSCurrentTime getTimeMillisStringForDevice] endTime:nil genId:[WSStatisticsManager getGenId]];

    [_scrollView setContentOffset:CGPointMake(_selfFrame.size.width * button.tag, 0) animated:YES];
}

- (void)updateSelectedPage:(NSInteger)page{
    for (UIButton *button in _titleButtons) {
        if (button.tag == page) {
            [button setTitleColor:_selectedColor forState:UIControlStateNormal];
            if (_isAnimated) {
                [UIView animateWithDuration:0.3 animations:^{
                    button.transform = CGAffineTransformMakeScale(1.1, 1.1);
                }];
            }
        }else{
            [button setTitleColor:_unselectedColor forState:UIControlStateNormal];
            if (_isAnimated) {
                [UIView animateWithDuration:0.3 animations:^{
                    button.transform = CGAffineTransformIdentity;
                }];
            }
        }
    }
    
    //MN-2616
    [self resetLineBottomViewWithScrollView:_scrollView];
}

- (void)uploadTitle
{
    if (_titles.count > 2) {
        _isActionFromBtnClick = YES;
        _newPageIndex = 1;
        [_scrollView setContentOffset:CGPointMake(_selfFrame.size.width * 1, 0) animated:YES];
        
    }
}
- (UIViewController *)findViewController:(UIView *)sourceView
{
    id target = sourceView;
    while (target) {
        target = ((UIResponder *)target).nextResponder;
        if ([target isKindOfClass:[UIViewController class]]) {
            break;
        }
    }
    return target;
}

- (BOOL)getVariableWithClass:(Class)myClass varName:(NSString *)name{
    unsigned int outCount, i;
    Ivar *ivars = class_copyIvarList(myClass, &outCount);
    for (i = 0; i < outCount; i++) {
        Ivar property = ivars[i];
        NSString *keyName = [NSString stringWithCString:ivar_getName(property) encoding:NSUTF8StringEncoding];
        keyName = [keyName stringByReplacingOccurrencesOfString:@"_" withString:@""];
        if ([keyName isEqualToString:name]) {
            free(ivars);
            return YES;
        }
    }
    free(ivars);
    return NO;
}

- (void)refreshTitle:(NSString *)title atPageIndex:(NSInteger)index
{
    
    if (_titleButtons && _titleButtons.count > 0) {
        // 重新给titleButton设置title，并调整宽度和距离父视图的偏移
        UIButton *titleButton = (UIButton *)[_titleButtons objectAtIndex:index];
        [titleButton setTitle:title forState:UIControlStateNormal];
        NSString *oldTitleStr = [_titles objectAtIndex:index];
        
        CGSize oldTitleSize = [oldTitleStr sizeWithAttributes:@{NSFontAttributeName:_font}];
        CGSize newTitleSize = [title sizeWithAttributes:@{NSFontAttributeName:_font}];
        
        CGFloat tempWidth = newTitleSize.width - oldTitleSize.width;
        
        
        CGRect buttonFrame = titleButton.frame;
        buttonFrame.size.width += (tempWidth);
        buttonFrame.origin.x -= (tempWidth/2);
        titleButton.frame = buttonFrame;
        
        [_titles replaceObjectAtIndex:index withObject:title];
        
        [_titleSizeArray replaceObjectAtIndex:index withObject:[NSValue valueWithCGSize:newTitleSize]];
        
        // MN-1772 重新设置title宽度需要重置横线宽度
        if (index == _newPageIndex) {
            _lineBottom.frame = CGRectMake(titleButton.origin.x, _lineBottom.frame.origin.y, newTitleSize.width, _lineBottom.frame.size.height);
            [self setPointArray:index isReplace:YES];
        }
    }

}

- (void)scrollToIndex:(NSInteger)index {
    [_scrollView setContentOffset:CGPointMake(index * _scrollView.width, 0) animated:YES];
}

-(void)setScrollViewScrollEnabled:(BOOL)isEnabled{
    self.scrollView.scrollEnabled = isEnabled;
}










#pragma mark - 自定义初始化方法1
- (instancetype)initWithFrame:(CGRect)frame withTitles:(NSArray *)titles withViewControllers:(NSArray *)controllers withParameters:(NSArray *)parameters {
    
    return [self initWithFrame:frame titles:titles viewControllers:controllers parameters:parameters additionalInfo:nil];
}

#pragma mark - 自定义初始化方法2
- (instancetype)initWithFrame:(CGRect)frame withTitles:(NSArray *)titles withViewControllers:(NSArray *)controllers withParameters:(NSArray *)parameters
           withAdditionalInfo:(NSDictionary *)additionalInfo {
    
    return [self initWithFrame:frame titles:titles viewControllers:controllers parameters:parameters additionalInfo:additionalInfo];
}

#pragma mark - 自定义内部初始化方法(终极初始化方法)
- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles viewControllers:(NSArray *)controllers parameters:(NSArray *)parameters
               additionalInfo:(NSDictionary *)additionalInfo {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.scrollsToTop = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadTitle) name:@"routeSelect" object:nil];
        
        _selfFrame = frame;
        _parameters = parameters;
        
        _selectedColor = SELECTED_COLOR;
        _unselectedColor = UNSELECTED_COLOR;
        _leftSpace = LEFT_SPACE;
        _rightSpace = RIGHT_SPACE;
        _minSpace = MIN_SPACING;
        _topTabBottomLineColor = TPOTABBOTTOMLINE_COLOR;
        _topSpace = TOP_SPACE;
        
        _isAverage = YES;
        _isTranslucent = YES;
        _isAnimated = NO;
        _isAdapteNavigationBar = YES;
        _isFirstLoad = YES;
        _isScrollViewBounces = YES;
        
        _titles = [NSMutableArray arrayWithArray:titles];
        _viewControllers = [NSMutableArray arrayWithArray:controllers];
        [self.additionalInfo addEntriesFromDictionary:additionalInfo];
    }
    return self;
}

#pragma mark - 获取additionalInfo方法
- (NSMutableDictionary *)additionalInfo {
    
    if (!_additionalInfo) {
        _additionalInfo = [[NSMutableDictionary alloc] init];
    }
    return _additionalInfo;
}

#pragma mark - 实现observeValueForKeyPath:ofObject:change:context:监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if (![keyPath isEqualToString:@"currentPage"]) {
    
        return;
    }
    
    NSInteger page = [change[@"new"] integerValue];
    CGFloat offset = [_centerPoints[page] floatValue];
    if (offset < _topTabScrollViewWidth / 2) {
        [_topTabScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    else if (offset + _topTabScrollViewWidth / 2 < _topTabScrollView.contentSize.width) {
        [_topTabScrollView setContentOffset:CGPointMake(offset - _topTabScrollViewWidth / 2, 0) animated:YES];
    }
    else {
        [_topTabScrollView setContentOffset:CGPointMake(_topTabScrollView.contentSize.width - _topTabScrollViewWidth, 0) animated:YES];
    }

    for (NSInteger i = 0; i < _viewControllers.count; i++) {
        
        if (page != i) {
            continue;
        }
        
        UIViewController *viewController = nil;
        NSString *className = nil;
        if ([_viewControllers[page] isKindOfClass:[NSString class]]) {
            className = _viewControllers[page];
            if ([className isEqualToString:@"HYPAGEVIEW_AlreadyCreated"]) {
                return;
            }
        }
        else {
            viewController = _viewControllers[page];
        }
        
        if (_parameters && _parameters.count > i && _parameters[i] && [self getVariableWithClass:viewController.class varName:@"parameter"]) {
            [viewController setValue:_parameters[i] forKey:@"parameter"];
        }
        
        CGFloat offset = _topSpace + TAB_HEIGHT;
        CGRect frame = CGRectMake(_selfFrame.size.width * i, offset, _selfFrame.size.width, _scrollView.bounds.size.height - offset);
        if ([viewController.view.class isSubclassOfClass:[UIScrollView class]]) {
            
            UIScrollView *view = (UIScrollView *)viewController.view;
            view.contentInset = UIEdgeInsetsMake(offset, 0, 0, 0);
            view.contentOffset = CGPointMake(0, -offset);
            frame = CGRectMake(_selfFrame.size.width * i, 0, _selfFrame.size.width, _scrollView.bounds.size.height);
        }
        if ([NSStringFromClass([viewController.view class]) isEqualToString:@"UICollectionViewControllerWrapperView"]) {
                
            UIScrollView *view = (UIScrollView *)viewController.view.subviews[0];
            view.contentInset = UIEdgeInsetsMake(offset, 0, 0, 0);
            view.contentOffset = CGPointMake(0, -offset);
            frame = CGRectMake(_selfFrame.size.width * i, 0, _selfFrame.size.width, _scrollView.bounds.size.height);
        }
        viewController.view.frame = frame;
            
        self.strongArray[i] = viewController;
        
        NSString *isRemoveChildVC = [self.additionalInfo objectForKey:@"isRemoveChildVC"];
        if ([isRemoveChildVC isEqualToString:@"1"]) {
            
            for (NSInteger j = 0; j < _viewController.childViewControllers.count; j++) {
                UIViewController *vc = [_viewController.childViewControllers objectAtIndex:j];
                [vc willMoveToParentViewController:nil];
                //[vc.view removeFromSuperview];
                [vc removeFromParentViewController];
            }
            [_viewController addChildViewController:viewController];
        }
        else {
            [_viewController addChildViewController:viewController];
        }
    }

    UIViewController *newVC = _viewControllers[page];
    [newVC.view removeFromSuperview];
    [_scrollView addSubview:newVC.view];
        
    if ([self.pageDelegate respondsToSelector:@selector(currentPageChangedFromOldIndex:toNewIndex:)]) {
        [self.pageDelegate currentPageChangedFromOldIndex:_oldPageIndex toNewIndex:page];
    }
    
    self.isFirstLoad = NO;
    _oldPageIndex = page;
}

@end

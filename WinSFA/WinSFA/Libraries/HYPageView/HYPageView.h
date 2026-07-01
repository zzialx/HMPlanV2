//
//  HYPageView.h
//  HYNavigation
//
//  Created by runlhy on 16/9/27.
//  Copyright © 2016年 Pengcent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSBadgeView.h"

@protocol HYPageViewDelegate <NSObject>

@optional

- (void)currentPageChangedFromOldIndex:(NSInteger)oldIndex toNewIndex:(NSInteger)newIndex;

/**
 pageview 点击按钮调用方法

 @param pageIndex 当前页面的页码
 */
- (void)currentPageClickButtonWithPageIndex:(NSInteger)pageIndex;

/**
 MN-1779 调查问卷需要判断是否进店才能滑动
 
 @param vc 待切换vc
 */
- (BOOL)isEnableToController:(UIViewController *)vc pageIndex:(NSInteger)pageIndex;

/**
 MN-2434 HYPageView 加载视图机制时机可能会不如预期，所以添加该方法在 BadgeView 创建后刷新 Badge Count
 */
- (void)refreshBadge;

@end

@interface HYPageView : UIScrollView

// Personalized configuration properties
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, strong) UIColor *unselectedColor;
@property (nonatomic, strong) UIColor *topTabBottomLineColor;
@property (nonatomic, assign) CGFloat leftSpace;
@property (nonatomic, assign) CGFloat rightSpace;
@property (nonatomic, assign) CGFloat minSpace;
/**
 default 20.
 For translucent status bar
 */
@property (nonatomic, assign) CGFloat topSpace;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, assign) id <HYPageViewDelegate> pageDelegate;
@property (nonatomic, assign) NSInteger      currentPage;

/**
 default YES.
 */
@property (nonatomic, assign) BOOL isAdapteNavigationBar;
/**
 default NO.
 */
@property (nonatomic, assign) BOOL isAnimated;
/**
 default YES.
 */
@property (nonatomic, assign) BOOL isTranslucent;
/**
 default YES ,Valid when only one page can be filled with all buttons
 */
@property (nonatomic, assign) BOOL isAverage;
/**
 Initializes and returns a newly allocated view object with the specified frame rectangle.
 
 @param frame       ...
 @param titles      Some title
 @param controllers Name of some controllers
 @param parameters  You need to set a property called "parameter" for your controller to receive.
 
 @return self
 */
@property (nonatomic, assign) BOOL isScrollViewBounces;


@property (nonatomic, assign) BOOL isFirstLoad;

// 是否隐藏导航栏
@property (nonatomic, assign) BOOL isHideTitle;

// 如果设置了图片则使用图片，否则是直线
@property (nonatomic, strong) UIImage *bottomImage;

// 是否显示右侧按钮
@property (nonatomic, assign) BOOL isShowRightButton;

// MN-792 红点标记视图
@property (nonatomic, strong) NSMutableArray *titleBadgeView;


- (instancetype)initWithFrame:(CGRect)frame withTitles:(NSArray *)titles withViewControllers:(NSArray *)controllers withParameters:(NSArray *)parameters;
- (instancetype)initWithFrame:(CGRect)frame withTitles:(NSArray *)titles withViewControllers:(NSArray *)controllers withParameters:(NSArray *)parameters
           withAdditionalInfo:(NSDictionary *)additionalInfo;

- (void)refreshTitle:(NSString *)title atPageIndex:(NSInteger)index;

- (void)scrollToIndex:(NSInteger)index;
-(void)setScrollViewScrollEnabled:(BOOL)isEnabled;

@end

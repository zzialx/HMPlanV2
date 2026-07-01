//
//  WSHorizontalPageViewController.m
//  WinSFA
//
//  Created by Alicia on 2017/9/22.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSHorizontalPageViewController.h"
#import "WSReportFormController.h"

#define kPageControlHeight          20
#define kViewHeight                 180

@interface WSHorizontalPageViewController () <UIScrollViewDelegate, WSReportFormControllerDelegate>

@property (nonatomic, strong) NSMutableArray *controllerArray;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, assign) NSInteger pageCount;
@property (nonatomic, assign) CGFloat viewHeight;
@end

@implementation WSHorizontalPageViewController

- (instancetype)initWithFuncs:(WSFuncsBean *)funcs {
    self = [super initWithFuncs:funcs];
    if (self) {
        if (!funcs.funcsArray || funcs.funcsArray.count == 0) {
            return nil;
        }
        self.currentFuncs = funcs;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupViews {
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.viewHeight = kViewHeight;
    self.pageCount = self.currentFuncs.funcsArray.count;
    
    self.controllerArray = [NSMutableArray arrayWithCapacity:self.pageCount];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.numberOfPages = self.pageCount;
    self.pageControl.currentPage = 0;
    self.pageControl.currentPageIndicatorTintColor = [UIColor lightGrayColor];
    self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
    [self.pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.pageControl];
    
    [self createPages];
}

- (void)viewDidLayoutSubviews {
    CGRect bounds = [self.view bounds];
    for (NSInteger i = 0; i <self.scrollView.subviews.count; i++) {
        UIView *view = self.scrollView.subviews[i];
        bounds.origin.x = bounds.size.width * i;
        bounds.origin.y = 0;
        view.frame = bounds;
    }
    self.scrollView.contentSize = CGSizeMake(bounds.size.width * self.pageCount, bounds.size.height);
    self.pageControl.frame = CGRectMake(0, bounds.size.height - kPageControlHeight, bounds.size.width, kPageControlHeight);
}

#pragma mark - Public Method
- (CGFloat)contentHeight {
    [self setControllerFrame];
    return self.viewHeight;
}


#pragma mark - Private Method

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = sender.frame.size.width;
    NSInteger currentPage = floor((sender.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = currentPage;
}

- (void)createPages {
    for (WSFuncsBean *funcBean in self.currentFuncs.funcsArray) {
        NSString *className = [WSPlistHelper valueForKey:funcBean.fv withPlistName:kControllerMappingFileName];
        LogInfo(@"Going to init class: %@",className);
        WCBaseViewController *vc = [[NSClassFromString(className) alloc] initWithFuncs:funcBean];
        [self.controllerArray addObject:vc];
        
        [self addChildViewController:vc];
        
        if ([vc isKindOfClass:[WSReportFormController class]]) {
            ((WSReportFormController *)vc).isInContainerView = YES;
            ((WSReportFormController *)vc).delegate = self;
        }
        
        [self.scrollView addSubview:vc.view];
    }
}

- (void)changePage:(id)sender {
    NSInteger page = self.pageControl.currentPage;
    
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
}

- (void)setControllerFrame {
    for (WCBaseViewController *controller in self.controllerArray) {
        CGFloat viewHeight = [controller contentHeight];
        if (self.viewHeight < viewHeight) {
            self.viewHeight = viewHeight;
        }
    }
}


@end

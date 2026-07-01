//
//  WSStoreVisitViewController.m
//  WinSFA
//
//  Created by Alicia on 17/1/19.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSStoreVisitScrollViewController.h"
#import "WSStoreVisitCollectioncell.h"
#import "WSBaseStoreDBService.h"
#import "WSStoreBean.h"
#import "WSAppData.h"
#import "WSPageControl.h"
#import "WSFuncsBeanFilterLogicService.h"
#import "WSStoreVisitNextView.h"

#define INPLAN_UPDATA_NOTIFY @"INPLAN_UPDATA_NOTIFY"


#define kViewHeight             (INTERFACE_IS_PHONE ? 145 : 170)
#define kScrollTimeInterval     3
#define kMaxCount               3
#define kPageHeight             12
#define kScrollNextOffset       0.22
#define kScrollNextWith         100

#define ALL_STORE_FILTER_FLAG @"allstore"

static NSString * const kVisitStoreCellIdentifier = @"VisitScrollCell";

@interface WSStoreVisitScrollViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *dataCollectionView;
@property (nonatomic, strong) NSArray *filterStoreArray;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, strong) WSFuncsBean *nextFuncs; // Swipe to next Funcs
@property (nonatomic, strong) WSStoreVisitNextView *nextView;

@end

@implementation WSStoreVisitScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.infiniteLoop = YES;
    self.isAutoScroll = NO;
    
    [self initData];
    [self setupViews];
    [self initLocation];

    self.isAutoEnterStorePage = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self resetStoresVisitAction];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    ((UICollectionViewFlowLayout *)self.dataCollectionView.collectionViewLayout).itemSize = CGSizeMake(self.view.width, kViewHeight);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.dataCollectionView.delegate = nil;
    self.dataCollectionView.dataSource = nil;
    [self invalidateTimer];
}


#pragma mark - Init
- (id)initWithFuncs:(WSFuncsBean *)funcs {
    if (!funcs) {
        return nil;
    }
    self = [super init];
    if (self != nil) {
        self.currentFuncs = funcs;
        WSFuncsBean* subMenuFB = [WSFuncsBeanFilterLogicService getSubMenuFuncsBeanByCurrentFB:self.currentFuncs];
        self.subMenuFuncsBean = subMenuFB;
        self.subMenuFuncsCode = subMenuFB.fc;
        return self;
    }
    return self;
}


- (void)setupViews {
    UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.flowLayout = layout;
    
    CGRect frame = CGRectMake(0, 0, self.view.width,self.view.height);
    self.dataCollectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    self.dataCollectionView.delegate = self;
    self.dataCollectionView.dataSource = self;
    self.dataCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.dataCollectionView registerClass:[WSStoreVisitCollectionCell class] forCellWithReuseIdentifier:kVisitStoreCellIdentifier];
    [self.dataCollectionView setBackgroundColor:[UIColor whiteColor]];
    self.dataCollectionView.pagingEnabled = YES;
    [self.dataCollectionView setShowsHorizontalScrollIndicator:NO];
    [self.view addSubview:self.dataCollectionView];

    [self.pageControl setFrame:CGRectMake(0, kViewHeight - MAIN_PADDING - kPageHeight, self.view.width, kPageHeight)];
    [self.view addSubview:self.pageControl];
}

- (void)initLocation {
    // 实时定位  默认为开启GPS，如果配置为Y开启
    if (!self.currentFuncs.opt.isGps || [self.currentFuncs.opt.isGps isEqualToString:@"Y"]) {
        
        DDLogInfo(@"使用通知方式获取定位回调");
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationFinished:) name:locationAddressManagerDidUpdatedFinishedNotification object:nil];
        [[WSLocationManager getInstance] startUpdatingLocationWithActive:YES];

//        NSString *useNewLocation = [WSPlistHelper valueForKey:@"useNewLocation" withPlistName:kConfilgFileName];
//        if ([useNewLocation isEqualToString:@"1"]) {
//
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationFinished:) name:locationAddressManagerDidUpdatedFinishedNotification object:nil];
//            [[WSLocationManager getInstance] startUpdatingLocationWithActive:YES];
//
//        }else{
//
//            [[WSLocationManager getInstance] startUpdateUserLocationWithBlock:^(WSLocationDescribe *aLocationDescribe, NSError *error) {
//                if (aLocationDescribe.location
//                    && (aLocationDescribe.location.coordinate.longitude != 0
//                        && aLocationDescribe.location.coordinate.latitude != 0)) {
//                        self.locationDescribe = aLocationDescribe;
//
//                        self.filterStoreArray = [self filterNearestStoresByisCalcDistance:YES];
//                    } else {
//                        self.filterStoreArray = [self filterNearestStoresByisCalcDistance:NO];
//                    }
//            }];
//        }
        
    } else {
        self.filterStoreArray = [self filterNearestStoresByisCalcDistance:NO];;
    }
}

- (void)locationFinished:(NSNotification *)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:locationAddressManagerDidUpdatedFinishedNotification object:nil];
    
    NSDictionary *userInfo = [sender userInfo];
    NSError *error = [userInfo objectForKey:locationAddressManagerDidUpdatedFinishedNotificationErrorKey];
    WSLocationDescribe *tmpLocationDescribe = [userInfo objectForKey:locationAddressManagerDidUpdatedFinishedKey];
    
    if (error) {
        LogError(@"定位失败");
    }else{
        LogInfo(@"定位成功：aLocationDescribe=====%@",tmpLocationDescribe);
        if (tmpLocationDescribe.location && (tmpLocationDescribe.location.coordinate.longitude != 0 && tmpLocationDescribe.location.coordinate.latitude != 0)) {
            self.locationDescribe = tmpLocationDescribe;
            self.filterStoreArray = [self filterNearestStoresByisCalcDistance:YES];
        }else{
            self.filterStoreArray = [self filterNearestStoresByisCalcDistance:NO];
        }
    }
    
}

- (void)initData {
    [self initOtherFuncsBean];
    
    NSString *currenteEmpId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *subEmpId = self.subempStore.Id;
    NSString *empId = subEmpId?:currenteEmpId;
    
    NSString *funCode = self.currentFuncs.fc;
    
    if (self.subMenuFuncsCode) {
        funCode = self.subMenuFuncsCode;
    }
    NSString * search_objId = STORES;
    if ([self.currentFuncs.ds length] > 0) {
        search_objId = self.currentFuncs.ds;
    }
    
    BOOL isSearchable  = [self.currentFuncs.opt.isSearchable isEqualToString:@"remote"];
    NSArray *tempArray = [[WSBaseStoreDBService shareInstance] queryAllStoreWithFuncCode:funCode empId:empId styp:self.currentFuncs.styp searchStr:nil search_objId:search_objId isSearchable:isSearchable storeAccessMode:[subEmpId length] > 0 ? WSStoreAccessModeSubEmp : WSStoreAccessModeNormal parentStoreFc:self.currentFuncs.opt.parentStoreFc];
    self.storeArray = [tempArray mutableCopy];
}

- (void)reloadStoreList{

    [self initData];
    [self initLocation];
}

- (CGFloat)contentHeight {
    //SFA-25339
    return ((self.storeArray.count > 0) ? kViewHeight : 0.0f);
}


#pragma mark - Property

- (void)setIsAutoScroll:(BOOL)isAutoScroll {
    _isAutoScroll = isAutoScroll;
    
    [self invalidateTimer];
    
    if (_isAutoScroll) {
        [self setupTimer];
    }
}

- (void)setFilterStoreArray:(NSArray *)filterStoreArray {
    [self invalidateTimer];
    
    _filterStoreArray = filterStoreArray;
    
    
    if (filterStoreArray.count < self.storeArray.count) {
        if (!self.nextFuncs && [self.currentFuncs.opt.contextMenu length] > 0) {
            WSFuncsBeanArray *fbArray = [WSAppData getObjectbyKey:FUNCS];
            if (fbArray) {
                self.nextFuncs = [fbArray getFuncsBeanWithFC:self.currentFuncs.opt.contextMenu];
            }
        }
        
        if (self.nextFuncs) {
            self.infiniteLoop = NO;
            self.isAutoScroll = NO;
            
            [self.nextView setFrame:CGRectMake(self.filterStoreArray.count * self.view.width, 0, kScrollNextWith, self.view.height)];
        }
    }
    
    _totalCount = self.filterStoreArray.count;
    
    // MMSH-3248 门店个数大于 1 的时候才能无限循环
    if (self.infiniteLoop && [self.filterStoreArray count] > 1) {
        _totalCount = self.filterStoreArray.count * 1000;
    }
    
    self.pageControl.numberOfPages = self.filterStoreArray.count > kMaxCount ? kMaxCount : self.filterStoreArray.count;;
    
    [self.dataCollectionView reloadData];
    
    if (self.dataCollectionView.contentOffset.x == 0 && self.totalCount) {
        if (self.infiniteLoop) {
            NSInteger targetIndex = self.totalCount * 0.5;
            [self.dataCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
    }
}


#pragma mark - Actions

- (void)setupTimer {
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:kScrollTimeInterval target:self selector:@selector(automaticScroll) userInfo:nil repeats:YES];
    _timer = timer;
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)invalidateTimer {
    if (!self.isAutoScroll) {
        return;
    }
    [_timer invalidate];
    _timer = nil;
}


- (void)automaticScroll {
    if (self.totalCount == 0) {
        return;
    }
    NSInteger currentIndex = [self currentIndex];
    NSInteger targetIndex = currentIndex + 1;
    [self scrollToIndex:targetIndex];
}

- (void)scrollToIndex:(NSInteger)targetIndex {
    if (targetIndex >= self.totalCount) {
        [self invalidateTimer];
        if (self.infiniteLoop) {
            targetIndex = self.totalCount * 0.5;
            [_dataCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
        return;
    }
    [self.dataCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

- (NSInteger)currentIndex {
    if (self.dataCollectionView.width == 0 || self.dataCollectionView.height == 0) {
        return 0;
    }
    
    NSInteger index =  (self.dataCollectionView.contentOffset.x + self.flowLayout.itemSize.width * 0.5) / self.flowLayout.itemSize.width;
    return MAX(0, index);
}

- (NSInteger)convertIndex:(NSInteger)index {
    return (NSInteger)index % self.filterStoreArray.count;
}

#pragma mark - Private Method
- (NSArray *)filterNearestStoresByisCalcDistance:(BOOL)isCalcDistance {
    NSArray *storeArray;
    if (isCalcDistance) {
        //distancesSort 为1 按门店字段distance过滤
        if ([self.currentFuncs.opt.distancesSort isEqualToString:@"1"]) {
            NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:self.storeArray.count];
            for (WSStoreBean *store in self.storeArray) {
                WSStoreBean *distanceStore = [WSLocationManager calculateDistanceWith:store func:self.currentFuncs locationDescribe:self.locationDescribe isStoreList:YES];
                
                if ([distanceStore.distance length] > 0) {
                    [tempArray addObject:distanceStore];
                }
            }
            storeArray =  [tempArray sortedArrayUsingFunction:customSort context:nil];
        } else {
            storeArray = self.storeArray;
        }
    
    } else {
        storeArray = [self.storeArray copy];
    }
    if (storeArray.count <= kMaxCount ) {
        return storeArray;
    }
    
    // 过滤掉已访的门店，如果过滤后门店不足三家，仍然需要显示三家
    NSMutableArray *notVisitedArray = [NSMutableArray array];
    NSMutableArray *visitedArray = [NSMutableArray array];
    for (WSStoreBean *store in storeArray) {
        if (notVisitedArray.count == kMaxCount) {
            break;
        }
        if (![store.actionState isEqualToString:ActionDone]) {
            [notVisitedArray addObject:store];
        } else {
            [visitedArray addObject:store];
        }
    }
    
    NSInteger notVisitedCount = [notVisitedArray count];
    if (notVisitedCount == kMaxCount) {
        return [notVisitedArray copy];
    }
    
    [notVisitedArray addObjectsFromArray:[visitedArray subarrayWithRange:NSMakeRange(0, kMaxCount - notVisitedCount)]];
    return notVisitedArray;
}

- (void)resetStoresVisitAction {
    if (!self.subMenuFuncsCode || self.subMenuFuncsCode.length == 0
        || !self.filterStoreArray || self.filterStoreArray.count == 0) {
        return;
    }
    
    NSMutableArray *tempArray = [self.filterStoreArray mutableCopy];
    for (WSStoreBean *storeBean in tempArray) {
        
        storeBean.actionState = [self getActionStateByStore:storeBean andmodule_fc:self.subMenuFuncsCode];
    }
    
    self.filterStoreArray = tempArray;
}

#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.totalCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WSStoreVisitCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVisitStoreCellIdentifier forIndexPath:indexPath];
    
    NSInteger currentIndex = [self convertIndex:indexPath.item];
    WSStoreBean *storeBean = self.filterStoreArray[currentIndex];
    NSInteger index = currentIndex + 1;
    [cell setStoreBean:storeBean index:index count:self.filterStoreArray.count];
    return cell;
}



#pragma mark - Collection View Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self invalidateTimer];
    
    NSInteger currentIndex = [self convertIndex:indexPath.item];
    WSStoreBean *storeBean = self.filterStoreArray[currentIndex];
    self.currentStore = storeBean;
    [self didSelectStore:storeBean notification:nil];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.width, kViewHeight);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self invalidateTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (self.filterStoreArray.count == self.storeArray.count || !self.nextFuncs) {
        return;
    }
    CGPoint contentOffset = scrollView.contentOffset;
    CGSize viewSize = scrollView.bounds.size;
    
    CGFloat pageOffset = contentOffset.x / viewSize.width;
    CGFloat offsetPercent = pageOffset - (self.filterStoreArray.count - 1);
    if (offsetPercent >= kScrollNextOffset) {
        NSString *className = [WSPlistHelper valueForKey:self.nextFuncs.fv withPlistName:kControllerMappingFileName];
        WCBaseViewController *vc = [[NSClassFromString(className) alloc] initWithFuncs:self.nextFuncs];
        if (vc) {
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            [self.nextView setIsRelease:NO];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint contentOffset = scrollView.contentOffset;
    CGSize viewSize = scrollView.bounds.size;
    
    NSInteger pageIndex = contentOffset.x / viewSize.width;
    self.pageControl.currentPage =  pageIndex % self.pageControl.numberOfPages;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.filterStoreArray.count == self.storeArray.count || !self.nextFuncs) {
        return;
    }
    CGPoint contentOffset = scrollView.contentOffset;
    CGSize viewSize = scrollView.bounds.size;
    
    CGFloat pageOffset = contentOffset.x / viewSize.width;
    if (pageOffset <= self.filterStoreArray.count - 1) {
        return;
    }
    
    CGFloat offsetPercent = pageOffset - (self.filterStoreArray.count - 1);

    if (offsetPercent >= kScrollNextOffset && !self.nextView.isRelease) {
        [self.nextView setIsRelease:YES];
        
    } else if (offsetPercent < kScrollNextOffset && self.nextView.isRelease) {
        [self.nextView setIsRelease:NO];
        
    }
}

#pragma mark - Property
- (UIPageControl *)pageControl {
    if (!_pageControl) {
        UIPageControl *pageControl = [[UIPageControl alloc] init];
//        [pageControl setValue:[UIImage imageNamed:@"icon_page_control"] forKeyPath:@"_pageImage"];
//        [pageControl setValue:[UIImage imageNamed:@"icon_page_control_current"] forKeyPath:@"_currentPageImage"];
//        pageControl.dotWidth = 9;
//        pageControl.dotHeight = 3;
        pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
        pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        pageControl.currentPage = 0;
        pageControl.userInteractionEnabled = NO;
        _pageControl = pageControl;
    }
    return _pageControl;
}

- (WSStoreVisitNextView *)nextView {
    if (!_nextView) {
        _nextView = [[WSStoreVisitNextView alloc] init];
        [self.dataCollectionView addSubview:_nextView];
    }
    return _nextView;
}


@end

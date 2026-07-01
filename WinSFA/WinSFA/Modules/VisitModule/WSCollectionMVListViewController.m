//
//  WSCollectionMVListViewController.m
//  WinSFA
//
//  Created by Alicia on 17/1/14.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSCollectionMVListViewController.h"
#import "WSAcvtListViewController.h"
#import "WSProdGrideViewController.h"
#import "WSDictBean.h"
#import "WSAcvtViewController.h"
#import "WSVisitStoreActionTable.h"
#import "WSNewAddListViewController.H"
#import "WSTableMVListCell.h"
#import "WSReportFormController.h"
#import "WSModifyPasswdViewController.h"
#import "WSBaseDictsDBService.h"
#import "WSCollectionMVListCell.h"
#import "WSCollectionMVViewCell.h"
#import "WSNewStoreListViewController.h"
#import "UIImageView+EMWebCache.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSMsgBeanArray.h"
#import "WSMsgsBean.h"
#import "WSBaseMsgTypeTable.h"
#import "WSMsgsBean_msg.h"
#import "WSEmpinforefreshBeanArray.h"
#import "WSBaseMsgTable.h"

#import "WSBaseAcvtDBService.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "WSWorkbenchCollectionViewCell.h"
#import "WSGridHorizontalFuncBeansListScrollView.h"
#import "WSFuncsBeanFilterLogicService.h"
#import "WSPageControl.h"
#import "WSCollectionViewHorizontalLayout.h"
#define kWorkbenchItemHeight 74
#define kPageHeight          12

static NSString * const kMVCellIdentifier = @"MVListCollectionCell";
static NSString * const kFVExitApp = @"FV_EXIT_APP";
static NSString * const kFVModifyPsw = @"FV_MODIFY_PSW";
static NSString * const kScrollGridHorizontalStyle = @"ScrollGridHorizontalStyle";

static CGFloat const kItemGap = 7.0f;

static CGFloat const kIcon_Width = 35.0f;


typedef NS_ENUM(NSInteger, MV_LISTViewWorkMode) {
    TAB_MVListViewWorkInFunctionMode,   // 当前列表用于加载funcs的拜访项
    TAB_MVListViewWorkInProductMode     // 当前列表用于加载产品的拜访项
};

typedef NS_ENUM(NSInteger, MV_LISTViewStyleMode) {
    TAB_MVListViewStyleHorizontal,      // 当前列表项横向显示
    TAB_MVListViewStyleVertical,         // 当前列表项纵向显示
    TAB_MVListViewStyleHorizontalAndScrollPageEnable         // 当前列表项纵向显示,且能左右滑动（按页）
};

@interface WSCollectionMVListViewController () <UICollectionViewDelegate, UICollectionViewDataSource, WSGridHorizontalFuncBeansListScrollViewDelegate>
{
    /*Jira - MENGNIU-1144 一条数据自动跳转 后后台配置是否可以跳转 create by sunhognfu 2017-11-8*/
    BOOL isPopBack;
    NSInteger _maxRow;
    NSInteger _maxCol;
}
@property (nonatomic, assign) MV_LISTViewWorkMode iWorkMode;
@property (nonatomic, assign) MV_LISTViewStyleMode viewStyle;
@property (nonatomic, strong) NSNumber *iParentItemInfo; //Product info parent id
@property (nonatomic, strong) NSArray *iItemArray;
@property (nonatomic, strong) NSMutableArray *displayFuncsArray;
@property (nonatomic, assign) BOOL isSTART_EXIT_APP;
@property (nonatomic, assign) BOOL isTab;   // MSTD-7315 兼容安卓的配置，使用 Tab 显示的时候本类不做任何操作
@property (nonatomic, assign) NSInteger itemCount;//要创建的CollectionCell 的数量
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, assign) NSInteger pageCount;//显示的页数
@end

@implementation WSCollectionMVListViewController
@synthesize currentFuncs;

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.isTab) {
        return;
    }
    
    BOOL imageMode = NO;
    if (self.iWorkMode == TAB_MVListViewWorkInFunctionMode && self.displayFuncsArray.count == 1) {
        
        NSString *imageName = [[NSString stringWithFormat:@"%@_%@", self.currentFuncs.fc, [UIDevice getPreferredLanguage]] lowercaseString];
        
        UIImage *image = [UIImage scaledImageForName:imageName ofType:@"jpg" bundleName:IMAGES_BUNDLE];
        if (image) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
            imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            imageView.image = image;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
            [imageView addGestureRecognizer:tap];
            imageView.userInteractionEnabled = YES;
            
            [self.view addSubview:imageView];
            imageMode = YES;
        }
    }
//    MMSH-3246
//    iOS--玛氏中国MWC--uat环境手机端--首页菜单区域，菜单满一屏时，需要滑动显示下一屏，没有滑动效果的显示
    _itemCount = [self getItemCount];
    if (self.viewStyle == TAB_MVListViewStyleHorizontalAndScrollPageEnable || self.viewStyle == TAB_MVListViewStyleHorizontal) {
        _maxCol = currentFuncs.colNum > 0 ? currentFuncs.colNum : 3;
        if (self.viewStyle == TAB_MVListViewStyleHorizontal) {
            NSInteger row = _itemCount / _maxCol;
            _maxRow = _itemCount % _maxCol > 0 ? row + 1 : row;
        } else {
            _maxRow = currentFuncs.maxRow > 0 ? currentFuncs.maxRow : 1;
        }

        CGFloat pageCount = _itemCount % (_maxRow * _maxCol);
        if (pageCount) {
            self.pageCount = (_itemCount / (_maxRow * _maxCol)) + 1;
        } else {
            self.pageCount = _itemCount / (_maxRow * _maxCol);
        }
        _itemCount = self.pageCount * (_maxRow * _maxCol);
        
    }
//    if (self.viewStyle == TAB_MVListViewStyleHorizontalAndScrollPageEnable) {
//        [self setupViewsWithStyleHorizontalAndScrollPageEnable];
//    }else{
        if (!imageMode) {
            [self setupViews];
        }
//    }

    
}

- (void)loadView
{
    WSFuncsBean *currentFB = self.currentFuncs;
    
    // MMSH-2564 如果isTab=1，此类不做任何处理，交给父类完成初始化及页面绘制；反之则此类完成，调用父类绘制时数据模型传空
    if (!self.isTab) {
        self.currentFuncs = nil;
    }
    
    [super loadView];
    
    self.currentFuncs = currentFB;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    if (self.isTab) {
        return;
    }
    
    if (self.ownParentViewController)
    {
        self.ownParentViewController.navigationItem.rightBarButtonItem = nil;
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.isTab) {
        return;
    }
    
    [self refreshCollectionViewItemsAndData];
    
    /*Jira - MENGNIU-1144 一条数据自动跳转 后后台配置是否可以跳转 create by sunhognfu 2017-11-8*/
    if ([self.currentFuncs.opt.autoJumpNext length] > 0 && [self.currentFuncs.opt.autoJumpNext isEqualToString:@"1"] && !self.isPageSegmentView)
    {
        if ([self getItemCount] == 1) {
            if (!isPopBack) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
                [self didSelectItemAtIndexPath:indexPath];
                isPopBack = YES;
            } else {
                // MENGNIU-1826
                [self backToParent];
            }
        }
    }
}

- (void)refreshCollectionViewItemsAndData
{
    [self refreshCollectionViewItemWidth];
    [self.mvListCollectionView reloadData];
}

- (void)viewWillLayoutSubviews
{
    if (self.isTab) {
        return;
    }
    [self refreshCollectionViewItemsAndData];
}

- (void)tapAction {
    [self didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

- (void)reloadView {
    [self.mvListCollectionView reloadData];
}

#pragma mark - Init
- (id)initWithFuncs:(WSFuncsBean *)funcs {
    if (!funcs) {
        return nil;
    }
    self = [super init];
    if (self != nil) {
        self.currentFuncs = funcs;
        
        [self setIsTabByFuncs];
        if (!self.isTab) {
            [self initData];
            // MENGNIU-1825 跟 Android 一致没有数据的时候不显示该控件
            if ([self getItemCount] == 0) {
                if (self.viewStyle != TAB_MVListViewStyleVertical) {
                    return nil;
                } else {
                    [self addEmptyView];
                }
            }
        }
    }
    return self;
}

// MSTD-7315 以页签的方式就用父类处理，当前类不做任何事情
- (void)setIsTabByFuncs {
    if (!self.currentFuncs.menuStyle && self.currentFuncs.funcsArray.count > 1) {
        WSFuncsBean *fb = self.currentFuncs.funcsArray[0];
        if ([fb.fv rangeOfString:@"TAB"].location != NSNotFound || [fb.fv isEqualToString:@"FV_mobile_report"]) {
            self.isTab = YES;
        }
    }
}

- (void)initData {
    self.iItemArray = [[NSArray alloc] init];
    
    if ((!self.currentFuncs.filter) || [self.currentFuncs.filter isEqualToString:@""] ) {
        self.iWorkMode = TAB_MVListViewWorkInFunctionMode;
    } else {
        self.iWorkMode = TAB_MVListViewWorkInProductMode;
    }
    
    NSString *menuStyleId = self.currentFuncs.menuStyle;
    NSString *menuStyle = nil;
    
    // 根据Id去base_dicts查询菜单样式名字
    if (menuStyleId && menuStyleId.length > 0) {
        WSBaseDictsDBService *dictService = [[WSBaseDictsDBService alloc] init];
        WSDictBean *menuStyleDict = [dictService queryDictWithID:menuStyleId];
        menuStyle = menuStyleDict.name;
    }
    
    if (menuStyle && menuStyle.length > 0) {
        if ([menuStyle isEqualToString:kScrollGridHorizontalStyle]) {
            self.viewStyle = TAB_MVListViewStyleHorizontalAndScrollPageEnable;
        }else
            self.viewStyle = TAB_MVListViewStyleHorizontal;
    } else {
        self.viewStyle = TAB_MVListViewStyleVertical;
    }
    
    if (TAB_MVListViewWorkInProductMode == self.iWorkMode) {
        WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
        if (self.iParentItemInfo) {
            self.iItemArray = [service queryDictsWithParentId:[self.iParentItemInfo stringValue] filter:self.currentFuncs.filter];
        } else {
            self.iItemArray = [service queryDictsForAcvtGridWithFilter:self.currentFuncs.filter];
        }
    } else if (TAB_MVListViewWorkInFunctionMode == self.iWorkMode) {
        if (!self.displayFuncsArray) {
            self.displayFuncsArray = [[NSMutableArray alloc] init];
            for (WSFuncsBean *fb in self.currentFuncs.funcsArray) {
                if (!fb.styp || !self.currentStore) {
                    [self.displayFuncsArray addObject:fb];
                } else if ([self.currentStore.styp hasPrefix:fb.styp]) {
                    [self.displayFuncsArray addObject:fb];
                }
            }
        }
    }
    NSSortDescriptor* sort = [[NSSortDescriptor alloc] initWithKey:@"Id" ascending:YES];
    NSArray* sortArray = [[NSArray alloc] initWithObjects:sort, nil];
    self.iItemArray = [self.iItemArray sortedArrayUsingDescriptors:sortArray];
}

- (void)setupViews {
    
//    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
//    SFA-17174
//    SFA葵花药业--IOS端首页button按钮显示问题
    UICollectionViewFlowLayout *layout  = nil ;
    if ( self.viewStyle  == TAB_MVListViewStyleHorizontalAndScrollPageEnable || self.viewStyle == TAB_MVListViewStyleHorizontal) {
        WSCollectionViewHorizontalLayout *Hlayout = [[WSCollectionViewHorizontalLayout alloc] init];
        Hlayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        Hlayout.rowCount = _maxRow;
        Hlayout.itemCountPerRow = (_itemCount < _maxCol ? _itemCount : _maxCol);
        layout = Hlayout;
    } else {

        layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
   
    [self setCollectionViewLayoutItemSizeWithLayout:layout];

    CGRect frame = CGRectMake(0, 0, self.view.width,self.view.height);
    self.mvListCollectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    self.mvListCollectionView.delegate = self;
    self.mvListCollectionView.dataSource = self;
    self.mvListCollectionView.pagingEnabled = YES;
    self.mvListCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (self.viewStyle == TAB_MVListViewStyleHorizontal || self.viewStyle == TAB_MVListViewStyleHorizontalAndScrollPageEnable)  {
        [self.mvListCollectionView registerClass:[WSCollectionMVListCell class] forCellWithReuseIdentifier:kMVCellIdentifier];
        [self.mvListCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CollectionCell"];
        self.mvListCollectionView.showsHorizontalScrollIndicator = NO;
        self.view.backgroundColor = [UIColor clearColor];
        [self.mvListCollectionView setBackgroundColor:[UIColor clearColor]];
        layout.minimumInteritemSpacing = kItemGap;
        layout.minimumLineSpacing = kItemGap;
        CGFloat content = [self contentHeight];

        if ( self.viewStyle  == TAB_MVListViewStyleHorizontalAndScrollPageEnable) {
            if (self.pageCount > 1){
                self.pageControl  = [[UIPageControl alloc] initWithFrame:CGRectMake(0,content, self.view.width, kPageHeight)];
                //            [self.pageControl setValue:[UIImage imageNamed:@"icon_page_control"] forKeyPath:@"_pageImage"];
                //            [self.pageControl setValue:[UIImage imageNamed:@"icon_page_control_current"] forKeyPath:@"_currentPageImage"];
                //          self.pageControl.dotWidth = 9;
                //          self.pageControl.dotHeight = 3;
                self.pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
                self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
                self.pageControl.currentPage = 0;
                self.pageControl.numberOfPages=self.pageCount;
                self.pageControl.userInteractionEnabled = NO;
                [self.view addSubview:self.pageControl];
                
            }
        }
       
    } else {
        [self.mvListCollectionView registerClass:[WSCollectionMVViewCell class] forCellWithReuseIdentifier:kMVCellIdentifier];
        [self.mvListCollectionView setBackgroundColor:[UIColor whiteColor]];
        layout.minimumInteritemSpacing = 0.1;
        layout.minimumLineSpacing = 0.1;
    }

    [self.view addSubview:self.mvListCollectionView];
    
}

// MMSH-2125 新增可按页滑动的网格菜单样式
- (void)setupViewsWithStyleHorizontalAndScrollPageEnable
{
    WSGridHorizontalFuncBeansListScrollView *gridHorizontalFuncBeansListScrollView = [[WSGridHorizontalFuncBeansListScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width,self.view.height) andParentFuncsBean:self.currentFuncs];
    gridHorizontalFuncBeansListScrollView.fDelegate = self;
    gridHorizontalFuncBeansListScrollView.pagingEnabled = YES;
    
    [self.view addSubview:gridHorizontalFuncBeansListScrollView];
}

- (void)doActionAfterCellClickedWithFuncsBean:(WSFuncsBean *)fb
{
    if (fb) {
        [self doJumpToNextViewControllerWithFuncsBean:fb andTitle:fb.name andWorkModeDictBean:nil];
    }

}

- (CGFloat)contentHeight {
    
    if (self.viewStyle == TAB_MVListViewStyleHorizontalAndScrollPageEnable) {

        return kWorkbenchItemHeight * self.currentFuncs.maxRow;
    }
    else if (self.viewStyle == TAB_MVListViewStyleHorizontal) {
        return MAIN_CELL_HEIGHT * _maxRow + kItemGap * (_maxRow - 1);
    }

    return MAIN_CELL_HEIGHT;
}

- (CGFloat)getItemWidth {
    
    NSInteger total;
    if (TAB_MVListViewWorkInProductMode == self.iWorkMode) {
        total = self.iItemArray ? [self.iItemArray count] : 0;
    } else {
        total = self.displayFuncsArray ? [self.displayFuncsArray count] : 0;
    }
    
    CGFloat width;
    NSInteger col = total < _maxCol ? total : _maxCol;
    if (self.viewStyle == TAB_MVListViewStyleHorizontal) {
        width = (self.view.width - (col - 1) * kItemGap) / col;
    }else  if (self.viewStyle == TAB_MVListViewStyleHorizontalAndScrollPageEnable) {
        width = (self.view.width-30)/4;
    }
    else {
        width = self.view.width;
    }
    
    return width;
}

- (void)refreshCollectionViewItemWidth
{
    [self setCollectionViewLayoutItemSizeWithLayout:(UICollectionViewFlowLayout *)self.mvListCollectionView.collectionViewLayout];
}
// 获取layout 的itemSize
- (void)setCollectionViewLayoutItemSizeWithLayout:(UICollectionViewFlowLayout *)layout
{
    CGFloat width = [self getItemWidth];
    if (self.viewStyle == TAB_MVListViewStyleHorizontal) {
        layout.itemSize = CGSizeMake(width, MAIN_CELL_HEIGHT);
    } else if (self.viewStyle == TAB_MVListViewStyleHorizontalAndScrollPageEnable) {
        layout.itemSize = CGSizeMake(width, kWorkbenchItemHeight-4);
    }
    else {
        layout.itemSize = CGSizeMake(width, MAIN_CELL_HEIGHT);
    }
}

- (NSInteger)getItemCount {
    if (TAB_MVListViewWorkInProductMode == self.iWorkMode) {
        return (self.iItemArray ? [self.iItemArray count] : 0);
    } else {
        return (self.displayFuncsArray ? [self.displayFuncsArray count] : 0);
    }
}


#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _itemCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  
    UICollectionViewCell *cell = nil;
    if (indexPath.item < [self getItemCount]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMVCellIdentifier forIndexPath:indexPath];
        WSFuncsBean *tmpFuncsBean;
        NSString *title = nil;
        if (TAB_MVListViewWorkInProductMode == self.iWorkMode) {
            WSDictBean *bean = [self.iItemArray objectAtIndex:indexPath.row];
            title = bean.name;
        } else {
            tmpFuncsBean = [self.displayFuncsArray objectAtIndex:indexPath.row];
        }
        
        if (self.viewStyle == TAB_MVListViewStyleHorizontal || self.viewStyle == TAB_MVListViewStyleHorizontalAndScrollPageEnable) {
            WSCollectionMVListCell *listCell = (WSCollectionMVListCell *)cell;
            if (indexPath.row == 0) {
                [listCell.separatorLayer setHidden:YES];
            } else {
                [listCell.separatorLayer setHidden:NO];
            }
            if ([self isContainMsgFuncsBeanWithParentFuncsBean:tmpFuncsBean]) {
                NSInteger unReadBadgeCnt = [self getBadgeCountWithFuncBean:tmpFuncsBean];
                
                listCell.badgeCount = unReadBadgeCnt;
            }else{
                NSInteger badgeCount = 0;
                WSBaseStoreOtherDataObject *obj = [WSBaseStoreOtherDataDBService queryFuncTipWithFc:tmpFuncsBean.fc];
                if ([obj.item2 integerValue] > 0) {
                    badgeCount = [obj.item2 integerValue];
                }
                
                listCell.badgeCount = badgeCount;
                
            }
            
            if (tmpFuncsBean) {
                [listCell setFuncsBean:tmpFuncsBean];
            }else {
                [listCell setTitle:title];
            }
            //        MMSH-3021 董宏暂时添加
          
            if(self.viewStyle == TAB_MVListViewStyleHorizontalAndScrollPageEnable)
            {
                listCell.imageView.frame = CGRectMake((listCell.frame.size.width-kIcon_Width)/2, kItemGap, kIcon_Width, kIcon_Width);
                listCell.mainTitleLabel.frame = CGRectMake(0, CGRectGetMaxY(listCell.imageView.frame)+kItemGap, listCell.frame.size.width, listCell.frame.size.height-listCell.imageView.frame.size.height-2*kItemGap);
                listCell.backgroundColor = [UIColor clearColor];
                listCell.mainTitleLabel.font = [UIFont systemFontOfSize:2*kItemGap];
                [listCell.badgeView setBadgeTextFont:[UIFont systemFontOfSize:10.0]];
                
            }
            // YIHAIKERRY-3738
           
        }
        else
        {
            WSCollectionMVViewCell *viewCell = (WSCollectionMVViewCell *)cell;
            
            if (tmpFuncsBean) {
                [viewCell setFuncsBean:tmpFuncsBean];
            }else {
                [viewCell setTitle:title];
            }
            
            VisitActionStatus status = [self getVisitActionStatusByFuncsBean:tmpFuncsBean];
            [viewCell setActionStatus:status];
        }
    }else{
         cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    }
    return cell;
}

//获取未读条数SFA-28930（根据filter或是styp进行过滤，可以是多个字段用逗号拼接）
- (NSInteger)getBadgeCountWithFuncBean:(WSFuncsBean *)fb {
    
    NSInteger Totalcount = 0;
    NSMutableString *tpyCodes = [NSMutableString string];
    for (WSFuncsBean *funcBean in fb.funcsArray) {
        NSString *filterStr = funcBean.filter.length > 0 ? funcBean.filter : funcBean.styp;
        if (filterStr && filterStr.length > 0) {

            if (tpyCodes.length > 0) {
                [tpyCodes appendString:@","];
            }
            [tpyCodes appendString:filterStr];
            
        }
    }
    
    if (tpyCodes.length > 0) {
        Totalcount = [[WSBaseMsgTable sharedTable] queryNOReadedBaseMsgsWithIsread:@"0" multiTypcode:tpyCodes];
    }else {
        NSArray *baseMsgArray = [[WSBaseMsgTable sharedTable] queryAllUnreadBaseMsgs];
        Totalcount = baseMsgArray.count;
    }
    return Totalcount;
}

//SFA-28930 （注释掉，不同的模块不应该全是查出所有未读消息）
//- (NSInteger)markBadgeWithFuncBean:(WSFuncsBean *)fb
//{
//
//    NSArray *baseMsgArray = [[WSBaseMsgTable sharedTable] queryAllUnreadBaseMsgs];
//
//    NSInteger unReadCnt = 0;
//
//    if (baseMsgArray.count > 0) {
//        unReadCnt = baseMsgArray.count;
//    }
//
//    return unReadCnt;
//}

// 递归查找含有公告信息的funcsBean
- (BOOL)isContainMsgFuncsBeanWithParentFuncsBean:(WSFuncsBean *)fb
{
    if ([fb.fv isEqualToString:@"TAB_V1002"]){
        return YES;
    }else{
        if (fb.funcsArray && fb.funcsArray.count > 0) {
            for (WSFuncsBean *subfb in fb.funcsArray) {
                return [self isContainMsgFuncsBeanWithParentFuncsBean:subfb];
            }
        }
    }
    return NO;
}

- (void)didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //MMSH-5219 2018-06-30
    if(indexPath.row >= self.displayFuncsArray.count)
        return;
    
    WSFuncsBean* fb = nil;
    NSString *title = nil;
    WSDictBean *dictBean = nil;
    if (TAB_MVListViewWorkInProductMode == self.iWorkMode)
    {
        fb = [self.currentFuncs.funcsArray objectAtIndex:0];
        dictBean = [self.iItemArray objectAtIndex:indexPath.row];
        title = dictBean.name;
    }
    else
    {
        fb = [self.displayFuncsArray objectAtIndex:indexPath.row];
        WSFuncsBean *contentFuncsBean = fb;
        // SFA-18573 fv=TAB_CONTAINER时不需要取子菜单的第一个元素
        if ([contentFuncsBean.fv hasPrefix:FUNCS_FV_HAS_TAB] && ![contentFuncsBean.fv isEqualToString:@"TAB_CONTAINER"])
            fb = contentFuncsBean.funcsArray.firstObject;
        title = fb.name;
    }
    
    [self doJumpToNextViewControllerWithFuncsBean:fb andTitle:title andWorkModeDictBean:dictBean];
}

- (void)doJumpToNextViewControllerWithFuncsBean:(WSFuncsBean *)fb andTitle:(NSString *)title andWorkModeDictBean:(WSDictBean *)dictBean
{
    // 在ENABLE_LOCATION为1的前提下，如果opt中isGPS为R 且程序没有授权GPS服务/本机GPS服务不能用则禁止进入下一级页面.
    NSString *enableLocation = [[NSUserDefaults standardUserDefaults] objectForKey:ENABLE_LOCATION];
    WSFuncsBean_opt *opt = fb.opt;
    NSString *isGps = fb.opt.isGps;
    if (enableLocation !=nil && [enableLocation isEqualToString:@"1"]) {
        if (opt != nil && isGps !=nil ) {
            BOOL enterStore = [[WSLocationManager getInstance] checkConfigAndAuthorizationGps:isGps showAlert:fb.name];
            if (!enterStore) {
                return ;
            }
        }
    }
    if ([fb.fv isEqualToString:CALL_TEL_FV]) {
        if ([fb.opt.label length] > 0) {
            NSString *telString = NSLocalizedString(@"contact_phone", nil);
            NSString *msg = [NSString stringWithFormat:@"%@:%@\n%@", telString, fb.value, fb.opt.label];
            
            BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"dial_the_phone", nil) message:msg];
            [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:nil];
            [alert addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
                [self makeCallWithTelString:fb.value];
            }];
            
            [alert show];
        } else {
            [self makeCallWithTelString:fb.value];
        }
        return;
    }
    
    NSString *className = [WSPlistHelper valueForKey:fb.fv withPlistName:kControllerMappingFileName];
    if ([fb.fv isEqualToString:kFVExitApp]) {
        if (self.isSTART_EXIT_APP ) {
            self.isSTART_EXIT_APP = NO;
            [[NSNotificationCenter defaultCenter]
             postNotificationName:LOGOUT object:nil];
        }
        else{
            BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"two_click_exit_app", nil)];
            [alert addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
            }];
            [alert show];
            self.isSTART_EXIT_APP = YES;
        }
        return;
    } else {
        self.isSTART_EXIT_APP = YES;
    }
    
    UIViewController *vc = nil;
    if ([fb.fv isEqualToString:kFVModifyPsw]) {
        NSString *getPasswordMjet = [WSPlistHelper valueForKey:kMODIFY_PASSWORD_URL withPlistName:kConfilgFileName];
        if ([getPasswordMjet length] > 0) {
            getPasswordMjet = [NSString stringWithFormat:@"%@&nls=%@", getPasswordMjet,[UIDevice getPreferredLanguage]];
            vc = [[WSReportFormController alloc]initWithURL:[NSURL URLWithString:getPasswordMjet]];
        } else {
            vc = [[WSModifyPasswdViewController alloc]init];
            ((WSModifyPasswdViewController *)vc).modifyUserName = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_LAST_LOGIN];
        }
    }
    
    
    BOOL isAddAcvt = NO;
    if ([fb.opt.isAdd isEqualToString:@"Y"]) {
        isAddAcvt = YES;
    }
    
    if (!vc) {
        if (!isAddAcvt) {
            if (self.currentStore) {
                vc = [[NSClassFromString(className) alloc] initWithFuncs:fb Store:self.currentStore];
            } else {
                vc = [[NSClassFromString(className) alloc] initWithFuncs:fb];
            }
        }
    }
    
    if (TAB_MVListViewWorkInFunctionMode == self.iWorkMode) {
        if (!vc) {
            if (isAddAcvt) {
                
                if (self.currentStore) {
                    vc = [[WSNewAddListViewController alloc]  initWithFuncs:fb Store:self.currentStore];
                }else {
                    vc = [[WSNewStoreListViewController alloc] initWithFuncs:fb];
                }
                
            } else {
                if ([fb.isAcvtList isEqualToString:@"1"]) {
                    
                    WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];
                    NSArray *filtersArray = [baseAcvtDBService queryAcvtsWithStoreId:self.currentStore.Id filter:fb.filter];
                    
                    WSAcvtBean *acvtBean = [filtersArray lastObject];
                    if (acvtBean) {
                        vc = [[WSAcvtViewController alloc]initWithAcvt:acvtBean Funcs:fb Store:nil];
                    }
                } else {
                    vc = [[WSAcvtListViewController alloc] initWithFuncs:fb];
                }
            }
        }
    } else if (TAB_MVListViewWorkInProductMode == self.iWorkMode) {
        if (vc && [vc isKindOfClass:[WSProdGrideViewController class]]) {
            WSProdGrideViewController *productGrid = (WSProdGrideViewController*)vc;
            productGrid.iBrandId = dictBean.Id;
        }
    }
    vc.title = title;
    LogInfo(@"Going to in class:%@", vc);
    if (vc) {
        WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
        action.parent_action_id = self.currentVisitAction.ID;
        action.store_id = self.currentStore.Id;
        action.func_code = fb.fc;
        action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
        action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
        action.title = title;
        if (self.currentVisitAction
            && self.currentVisitAction.module_fc
            && [self.currentVisitAction.module_fc length] > 0) {
            action.module_fc = self.currentVisitAction.module_fc;
        }else{
            action.module_fc = action.func_code;
        }
        action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
        vc.currentVisitAction = action;
//        if (self.parentViewController) {
//            vc.hidesBottomBarWhenPushed = YES;
//            [self.parentViewController.navigationController pushViewController:vc animated:YES];
//        } else {
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
//        }
    }
}

#pragma mark - Collection View Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self didSelectItemAtIndexPath:indexPath];
}
#pragma mark - Private Method
- (void)makeCallWithTelString:(NSString *)str {
   NSString* phone = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSURL *telUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", phone]];
        if ([[UIApplication sharedApplication] canOpenURL:telUrl]) {
            [[UIApplication sharedApplication] openURL:telUrl options:@{} completionHandler:nil];
        }
}

- (VisitActionStatus)getVisitActionStatusByFuncsBean:(WSFuncsBean *)funcsbean {
    WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
    action.parent_action_id = self.currentVisitAction.ID;
    action.store_id = self.currentStore.Id;
    action.func_code = funcsbean.fc;
    action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
    // 字典项为数据的 不通过fb(fb.required) 判断必填
    if (TAB_MVListViewWorkInProductMode == self.iWorkMode) {
        action.is_required = @"O";
    } else {
        action.is_required = funcsbean.required;
    }
    
    action.title = funcsbean.name;
    if (self.currentVisitAction
        && self.currentVisitAction.module_fc
        && [self.currentVisitAction.module_fc length] > 0) {
        action.module_fc = self.currentVisitAction.module_fc;
    } else {
        action.module_fc = action.func_code;
    }
    VisitActionStatus status = [[WSVisitStoreActionTable sharedTable] queryActionStatus:action];
    return status;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    if ( self.viewStyle  != TAB_MVListViewStyleVertical) {
       
        CGFloat scrollViewW = scrollView.frame.size.width;
        // scrollView 的x 方向的偏移量
        CGFloat x = scrollView.contentOffset.x;
        // 当前所在第几页
        int page = (x + scrollViewW/2)/scrollViewW;
        self.pageControl.currentPage = page;
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
        pageControl.numberOfPages=self.pageCount;
        pageControl.userInteractionEnabled = NO;
        _pageControl = pageControl;
    }
    return _pageControl;
}


@end

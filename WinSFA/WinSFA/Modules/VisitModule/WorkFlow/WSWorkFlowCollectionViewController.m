//
//  WSWorkFlowCollectionViewController.m
//  WinSFA
//
//  Created by Alicia on 17/2/14.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSWorkFlowCollectionViewController.h"
#import "WSWorkFlowViewCell.h"
#import "WSWorkFlowListViewCell.h"
#import "WSWorkFlowCollectionViewCell.h"
#import "WSSplitViewController.h"
#import "WSAcvtViewController.h"
#import "WSSpecialAcvtViewController.h"
#import "WSWorkFlowMoreViewController.h"
#import "WSWorkbenchSectionHeaderView.h"
#import "WSBaseDictsDBService.h"
#import "WSAcvtListViewController.h"
#import "WSDictGrideViewController.h"
#import "WSProdGrideViewController.h"
#import "WSMV_LISTViewController.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "WSNoticeNumFcService.h"
#import "WSDataSourceManager.h"
#import "WSStatisticsManager.h"
#import "WSRequestHelper.h"
#import "WSStoreDataProcessService.h"
#import "WSLeaveStoreAcvtViewController.h"
#import "WSRequestTools.h"
#import "WSVisitStoreStatusTable.h"

#define kNotSelected    -1
#define kFV_V20A01      @"V20A01"
#define kNoNotic          @"noNotic"

#define UPDATA_NOTIFY_FB       @"fb_notify"


static NSString * const kWorkFlowCellId = @"WorkFlowCell";
static NSString * const kWorkFlowHeaderCellId = @"WorkFlowCellHeader";

@interface WSWorkFlowCollectionViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *dataCollectionView;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) WSWorkFlowViewStyleMode viewStyle;
@property (nonatomic, assign) BOOL isGridMore;

//YIHAIKERRY-3257 用于签退时没有提交门店拜访数据，为yes，弹出提示 ,默认NO，不弹出
@property (nonatomic, assign) BOOL isShowVisitTip;
@property (nonatomic, strong) NSIndexPath *visitIndexPath;
@property (nonatomic, copy) NSString *leaveStoreTipFunc; //离店的菜单里面配置OPT参数leaveStoreTipFunc值为需要提示的菜单的编码。
@property (nonatomic, strong) WSFuncsBean *visitFuncBean; //菜单编码对应的bean
@property (nonatomic, strong) WSNoticeNumFcService *noticeNumFcServicce; //获取右上角角标的工具
@property (nonatomic, strong) UICollectionView *collectionViewFB; //获取右上角角标的工具
@property (nonatomic, strong) NSIndexPath *indexPathFB; //获取右上角角标的工具

- (void)didSelectItemJump:(UIViewController *)vc funcsBean:(WSFuncsBean *)fb; //点击选择项目跳转方法 vc:跳转视图管理器 fb:功能模块

@end

@implementation WSWorkFlowCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self queryVisitStoreState];
    [WSDataSourceManager sharedInstance].currentActiveModel = nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [self refreshItemSize];
}

- (void)loadData {
    [self setIsGridMore];
    
    self.selectedIndex = kNotSelected;
    
    if (self.currentFuncs.menuStyle && self.currentFuncs.menuStyle.length > 0) {
        self.viewStyle = WSWorkFlowViewStyleCollection;
    } else {
        self.viewStyle = WSWorkFlowViewStyleList;
    }
}

- (void)setupViews {
    UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
    CGFloat width;
    layout.minimumInteritemSpacing = 0.1;
    layout.minimumLineSpacing = 0.1;
    
    if (self.viewStyle == WSWorkFlowViewStyleCollection) {
        width = (self.view.width - layout.minimumInteritemSpacing * (kColumn + 1)) / kColumn;
        layout.itemSize = CGSizeMake(width, width * kWidthHeightRatio);
    } else {
        width = self.view.width;
        layout.itemSize = CGSizeMake(width, WORKFLOW_CELL_DEFAULT_HEIGHT);
    }

    CGRect frame = CGRectMake(0, 0, self.view.width,self.view.height);
    self.dataCollectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    self.dataCollectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    
    self.dataCollectionView.delegate = self;
    self.dataCollectionView.dataSource = self;
    if (self.viewStyle == WSWorkFlowViewStyleCollection) {
        [self.dataCollectionView registerClass:[WSWorkFlowCollectionViewCell class] forCellWithReuseIdentifier:kWorkFlowCellId];
    } else {
        [self.dataCollectionView registerClass:[WSWorkFlowListViewCell class] forCellWithReuseIdentifier:kWorkFlowCellId];
    }
    self.dataCollectionView.showsHorizontalScrollIndicator = NO;
    self.dataCollectionView.showsVerticalScrollIndicator = NO;
    
    
    if (self.dictBeanArray) {
        [self.dataCollectionView registerClass:[WSWorkbenchSectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kWorkFlowHeaderCellId];
        layout.headerReferenceSize = CGSizeMake(self.view.width, MAIN_SECTION_HEIGHT);
    }
    
    self.dataCollectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.dataCollectionView];
}

- (void)refreshItemSize
{
    UICollectionViewFlowLayout *layout  = (UICollectionViewFlowLayout *)self.dataCollectionView.collectionViewLayout;
    CGFloat width;
    layout.minimumInteritemSpacing = 0.1;
    layout.minimumLineSpacing = 0.1;
    if (self.viewStyle == WSWorkFlowViewStyleCollection) {
        width = (self.view.width - layout.minimumInteritemSpacing * (kColumn + 1)) / kColumn;
        layout.itemSize = CGSizeMake(width, width * kWidthHeightRatio);
    } else {
        width = self.view.width;
        layout.itemSize = CGSizeMake(width, WORKFLOW_CELL_DEFAULT_HEIGHT);
    }
}


#pragma mark - Public Method
- (void)reloadData {
    [self.dataCollectionView reloadData];
}

- (void)setAllDataArray:(NSArray *)allDataArray {
    _allDataArray = allDataArray;

    if (self.isGridMore)  {
        NSMutableArray *tempArray = [NSMutableArray array];
        for (WSFuncsBean *fb in allDataArray) {
            //if ([self.currentFuncs.menuStyle isEqualToString:fb.menuStyle]) {
                if ([self isFuncsBeanShow:fb]) {
                    [tempArray addObject:fb];
                }
            //}
        }
        self.funcBeanArray = [tempArray copy];
    } else {
        self.funcBeanArray = allDataArray;
    }
    
    //YIHAIKERRY-3257 获取需要提示的菜单的编码
    [self getCurrentLeaveStoreTipFunc];
    
    //YIHAIKERRY-3717 ---zhangmin 2018/08/17
    [self resetDictBeanArrayAndDataSource];
    
    [self initDictBeanAndDataSource];
    
    [self setupViews];
}
// YIHAIKERRY-3717 给门店拜访页面图标排序 按照菜单项排序（门店按照菜单项排序，工作台按照字典项排序）
- (void)resetDictBeanArrayAndDataSource {
    
    NSMutableArray * dictIDArray = [NSMutableArray array];
    for (int i = 0; i < self.funcBeanArray.count ; i ++) {
        WSFuncsBean *funcBean = self.funcBeanArray[i];
        NSString * menuType = funcBean.menuType;
        if (menuType && menuType.length > 0) {
            if (![dictIDArray containsObject:menuType]) {
                [dictIDArray addObject:menuType];
            }
        }
    }
    
    if (!dictIDArray || dictIDArray.count == 0) {
        return;
    }
    if (!self.dictBeanArray || self.dictBeanArray.count == 0) {
        return;
    }
    NSMutableArray *dictBeanArray = [NSMutableArray array];
    NSMutableArray *dataSource = [NSMutableArray array];
    for (int i = 0; i < dictIDArray.count; i++) {
        NSString *menuType = dictIDArray[i];
        for (int j = 0; j < self.dictBeanArray.count; j ++) {
            WSDictBean * dictBean = self.dictBeanArray[j];
            if ([menuType isEqualToString:dictBean.Id] ) {
                [dictBeanArray addObject:dictBean];
                break;
            }
        }
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.menuType = %@", menuType];
        NSArray *funcsArray = [self.funcBeanArray filteredArrayUsingPredicate:predicate];
        [dataSource addObject:funcsArray];
        
    }
    self.dictBeanArray = dictBeanArray;
    self.dataSource = dataSource;
}

- (void)setBackgroundColor:(UIColor *)color
{
    self.view.backgroundColor = color;
    self.dataCollectionView.backgroundColor = color;
}

- (void)reloadView
{
    [self reloadData];
}

- (void)reloadHeaderView{
    if ([self.parentViewController isKindOfClass:[WSWorkFlowViewController class]]) {
        WSWorkFlowViewController *workFlowVC = (WSWorkFlowViewController *)self.parentViewController;
        [workFlowVC reloadHeaderView];
    }
}

- (void)removeSelection
{
    if (self.selectedIndex != kNotSelected) {
        [self.dataCollectionView deselectItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0] animated:NO];
        self.selectedIndex = kNotSelected;
    }
}

- (void)resetSelection
{
    [self.dataCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

#pragma mark - Private Method
// 保存完成开始拜访但没完成结束拜访的店
- (void)saveEnterAndNotLeaveStoreWithFuncsBean:(WSFuncsBean *)funcsBean visitActionStatus:(VisitActionStatus)visitActionStatus {
    NSString *storeId = self.currentStore.Id;
    [[NSUserDefaults standardUserDefaults] setObject:storeId forKey:@"EnterAndNotLeaveId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Collection DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *sectionArray = self.dataSource[section];
    return [sectionArray count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.dataSource count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WSWorkFlowViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kWorkFlowCellId forIndexPath:indexPath];
    
    NSArray *sectionArray = self.dataSource[indexPath.section];
    NSInteger total = [sectionArray count];
    WSFuncsBean* fb = sectionArray[indexPath.row];
    WSVisitStoreActionObject *action = [self queryVisitActionObjectWithFuncsBean:fb];
    VisitActionStatus visitStatus = [self getVisitActionStatusWithFuncsBean:fb action:action];
    BOOL hasTips = [self hasTipsWithStore:self.currentStore funcCode:fb];
    
    WSBaseStoreOtherDataDBService *dataService = [[WSBaseStoreOtherDataDBService alloc] init];
    NSInteger badgeCount = [dataService getFuncTipCountWithFC:fb.fc storeId:self.currentStore.Id];
    NSString *key = [NSString stringWithFormat:@"%@_%@",self.currentStore.Id,fb.fc];
//    YIHAIKERRY-2543
//    SFA益海嘉里-传统渠道 IOS【门店拜访】功能菜单加上标，标识内容个数
     if (badgeCount == 0) {
         NSDictionary *noticeNumFc = [self.noticeNumFcServicce getAllStoreMenuNotice];
         badgeCount = [[noticeNumFc objectForKey:key] integerValue];
     }
    [cell setDataWithFuncsBean:fb store:self.currentStore visitActionStatus:visitStatus action:action hasTips:hasTips badgeCount:badgeCount indexPath:indexPath totalCount:total];

    // 保存未离的店
    [self saveEnterAndNotLeaveStoreWithFuncsBean:fb visitActionStatus:visitStatus];
    
    if (self.viewStyle == WSWorkFlowViewStyleList) {
        BOOL isSelected = indexPath.row == self.selectedIndex ? YES : NO;
        [cell setBackgroundBySelected:isSelected];
    }
    
    //YIHAIKERRY-3257 没有提交门店拜访中的销退标准和专项检查问卷 签退时弹出提醒。
    if ([fb.fc isEqualToString:self.leaveStoreTipFunc] && self.leaveStoreTipFunc ) {
        if (badgeCount > 0) {
            self.visitIndexPath = indexPath;
            self.visitFuncBean = fb;
            if ([visitStatus isEqualToString:ActionDone]) {
                self.isShowVisitTip = NO;
            }else {
                self.isShowVisitTip = YES;
            }
        }
    }

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    WSWorkbenchSectionHeaderView* reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kWorkFlowHeaderCellId forIndexPath:indexPath];
    WSDictBean *dictBean = self.dictBeanArray[indexPath.section];
    [reusableView setTitle:dictBean.name];
    return reusableView;
}

static BOOL didEnd = NO;
static BOOL result = YES;
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.selectedIndex == indexPath.row) {
        return YES;
    }

    BOOL isNeedConfirm = NO;
    
    UIViewController *contenViewController = nil;
    if (self.wsSplitController) {
        WCNavigationController *currentCenterController = (WCNavigationController *)self.wsSplitController.rightViewController;
        if(currentCenterController){
            UIViewController *realContentTopViewController = [currentCenterController visibleViewController];
            
            if ([realContentTopViewController respondsToSelector:@selector(isValueChange)]) {
                //                BOOL changed = [(BaseViewController*)realContentTopViewController isValueChange];
                contenViewController = realContentTopViewController;
                if ([(BaseViewController*)realContentTopViewController isValueChange]) {
                    isNeedConfirm = YES;
                }
            }
        }
    }
    
    result = YES;
    if (isNeedConfirm) {
        didEnd = NO;
        
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"back_confirm2", nil)];
        [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:^{
            didEnd = YES;
            result = NO;
        }];
        
        [alert addButtonWithTitle:NSLocalizedString(@"upload_label", nil) block:^{
            didEnd = YES;
            result = NO;
            
            UIViewController *realContentVC = contenViewController;
            
            if ([realContentVC isKindOfClass:[WSMV_LISTViewController class]]) {
                realContentVC = [((WSMV_LISTViewController *)realContentVC) selectedController];
            }
            //不用else if是因为WSMV_LISTViewController的selectedController可能还是个WSSpecialAcvtViewController
            if ([realContentVC isKindOfClass:[WSSpecialAcvtViewController class]]) {
                realContentVC = [((WSSpecialAcvtViewController *)realContentVC) m_AcvtViewController];
            }
            
            
            if ([realContentVC isKindOfClass:[WSAcvtViewController class]]) {
                WSAcvtViewController *acvtCon = (WSAcvtViewController *)realContentVC;
                [acvtCon performSelector:@selector(executeUpload) withObject:nil afterDelay:0.01];
            }else if ([realContentVC isKindOfClass:[WSDictGrideViewController class]]) {
                WSDictGrideViewController *gridCon = (WSDictGrideViewController *)realContentVC;
                [gridCon performSelector:@selector(upload) withObject:nil afterDelay:0.01];
            }else if ([realContentVC isKindOfClass:[WSProdGrideViewController class]]) {
                WSProdGrideViewController *gridCon = (WSProdGrideViewController *)realContentVC;
                [gridCon performSelector:@selector(upload) withObject:nil afterDelay:0.01];
            }
            
        }];
        
        [alert addButtonWithTitle:NSLocalizedString(@"give_up", nil) block:^{
            didEnd = YES;
            result = YES;
        }];
        [alert show];
        
        while (!didEnd) {
            [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
        }
        
        if (!result) {
            [self performSelector:@selector(resetSelection) withObject:nil afterDelay:0.01];
        }
        return result;
    }
    return result;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //YIHAIKERRY-3257 用于签退时没有提交门店拜访数据，为yes，弹出提示 ,默认NO，不弹出
    NSArray *sectionArray = self.dataSource[indexPath.section];
    WSFuncsBean* fb = sectionArray[indexPath.row];
    if (fb.script) {
        if (![self executeValidateLuaScripWithFb:fb functionName:@"function getAcvtData(" params:self.currentStore.Id]) {
            return;
        }
    }
   // SFA-24568
    //备注: executeValidateLuaScripWithFb 这个方法是在父类的中，如果其他地方需要执行菜单上的脚本可以直接调用此方法
    //判断fb 中有没有脚本，如果有脚本的话先走脚本
    
    //SFA-25370
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    if (!model) {
        model = [[WSAcvtModel alloc] init];
        model.currentFuncs = fb;
        model.currentStore = self.currentStore;
        model.isNewAddAcvt = NO;
        [model createMD5With:[model md5Param]];
        [WSDataSourceManager sharedInstance].currentActiveModel = model;
    }
//    if (![self executeValidateLuaScripWithFb:fb]) {
//        return;
//    }
    
    if (self.leaveStoreTipFunc && self.isShowVisitTip && [fb.opt.leaveStoreTipFunc isEqualToString:self.leaveStoreTipFunc]) {
        // YIHAIKERRY-3568 zhaodanyang
        BOOL isValid = [self checkEnterLeaveStore:fb showToast:YES];
        if (isValid) {
            NSString *message = [NSString stringWithFormat:@"%@%@,%@",NSLocalizedString(@"data_not_submit", nil),self.visitFuncBean.name,NSLocalizedString(@"check_out_tip_lable_end", nil)];
            
            BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:message];
            __weak __typeof(self) weakSelf = self;
            [alert setCancelButtonWithTitle:fb.name block:^{
                [weakSelf didSelectItemWithCollectionView:collectionView AtIndexPath:indexPath];
            }];
            [alert addButtonWithTitle:self.visitFuncBean.name block:^{
                [weakSelf  checkClickStoreVist];
            }];
            [alert show];
        }

    }else {
//        donghong   SFA-26536
        if( fb.ds && fb.ds.length > 0 && fb.opt.sendRequest && [fb.opt.sendRequest isEqualToString:@"remote"])
        {
          
            self.collectionViewFB = collectionView;
            self.indexPathFB = indexPath;
            if(![self.currentFuncs.fc  isEqualToString:@"F40S01_01"]){
                [self startUpdata:self.currentStore];
            }
        }
        else
        {
            [self didSelectItemWithCollectionView:collectionView AtIndexPath:indexPath];
        }
    }
    
    [[WSStatisticsManager sharedInstance] insertMenuPageSenceEventWithID:EVENT_MENU_CLICK parentFuncBean:self.currentFuncs.iParentFuncsBean currentFuncBean:self.currentFuncs store:self.currentStore eventValue:fb.name startTime:[WSCurrentTime getTimeMillisStringForDevice] endTime:nil genId:[WSStatisticsManager getGenId]];

    
}
- (void)startUpdata:(WSStoreBean*)store
{
    
   
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishRequest:)
                                                 name:UPDATA_NOTIFY_FB
                                               object:nil];
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    NSArray *sectionArray = self.dataSource[self.indexPathFB.section];
    WSFuncsBean* fb = sectionArray[self.indexPathFB.row];
    
    NSInteger timeout = 0;
    
    if (fb.styp  && [fb.styp length] > 0) {
        
        NSString *styp = [fb.styp copy];
        [uploadMgr appUpdataManagerInfo:store StoreIds:nil subempId:nil withObjId:fb.ds  notifyName:UPDATA_NOTIFY_FB styp:styp timeout:timeout];
        
    }else{
        [uploadMgr appUpdataManagerInfo:store StoreIds:nil subempId:nil withObjId:fb.ds notifyName:UPDATA_NOTIFY_FB styp:nil timeout:timeout];
    }
    
    
    [self querying_messageTips];
    
}

-(void)finishRequest:(id)sender
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UPDATA_NOTIFY_FB
                                                  object:nil];
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    //NSLog(@"outplan is %@",info);
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0) {
        NSString *tmpString = [error ws_localizedDescription];
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    else
    {
        NSDictionary *uploadState = [info objectFromJSONString];

        NSArray *sectionArray = self.dataSource[self.indexPathFB.section];
        WSFuncsBean* fb = sectionArray[self.indexPathFB.row];
        
        NSString *objId = fb.ds;
        
        NSObject *tmpObject = uploadState[objId];
        NSDictionary *storeDicInfo = nil;
        if ([tmpObject isKindOfClass:[NSDictionary class]]) {
            storeDicInfo = (NSDictionary *)tmpObject;
        }else if ([tmpObject isKindOfClass:[NSArray class]]) {
            storeDicInfo = [(NSArray *)tmpObject firstObject];
        }
        if(self.currentStore != nil){
            [self.currentStore reSetStore:uploadState Key:objId];
            
            [WSStoreDataProcessService processStoreInfoDataToDbWith:self.currentStore info:storeDicInfo];
            
            NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
            [WSBaseStoreOtherDataDBService saveStoreRequestFlagWith:WSASVC_OUTPLANSTORE_REQUESTED_FLAG empId:empId storeId:self.currentStore.Id ];
            [self didSelectItemWithCollectionView:self.collectionViewFB AtIndexPath:self.indexPathFB];
        }
        
    }
}
-(void)didSelectItemWithCollectionView:(UICollectionView *)collectionView AtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionArray = self.dataSource[indexPath.section];
    WSFuncsBean* fb = sectionArray[indexPath.row];
//    SFA-31575
    if (([fb.fv rangeOfString:@"TAB"].location !=NSNotFound ||[fb.fv isEqualToString:@"FV_NOTICE"]) && fb.funcsArray.count > 0) {
        fb =  [fb.funcsArray firstObject];
    }
    
    // SFA-17330 此处兼容安卓错误逻辑，一般不会出现两个菜单编码相同的情况，如果出现暂时按取第一个元素（与安卓保持一致）
    WSFuncsBeanArray *fba = [WSAppData getObjectbyKey:FUNCS];
    fb = [fba getFuncsBeanFromAllFucsWithFC:fb.fc];
    //查询完新的fc之后，iParentFuncsBean丢失了，需要查询下iParentFuncsBean
    if (fb.iParentFuncsBean==nil) {
        LogError(@"查询完新的fc之后，iParentFuncsBean丢失了，需要查询下iParentFuncsBean,需要用到iParentFuncsBean");
        WSFuncsBean * tmpParentFuncsBean = [fba getParentFuncsBeanWithFk:fb.fk];
        fb.iParentFuncsBean = tmpParentFuncsBean;
    }

    if (!self.wsSplitController) {
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];    //选中后的反显颜色即刻消失
    } else {
        
        if (self.selectedIndex != indexPath.row) {
            NSIndexPath *selectedPath = [NSIndexPath indexPathForRow:self.selectedIndex inSection:0];
            WSWorkFlowListViewCell *cell = (WSWorkFlowListViewCell *)[collectionView cellForItemAtIndexPath:selectedPath];
            [cell setBackgroundBySelected:NO];
            
            self.selectedIndex = indexPath.row;
        }else if (![fb.fv isEqualToString:ENTERSTORE_FV] && ![fb.fv isEqualToString:LEAVESTORE_FV]){
            return;
        }
    }

    if (![fb.fv isEqualToString:MORE_FV]) {
        UIViewController *vc = [self checkNextPageWithFuncsBean:fb withShowToast:YES];
        if (!vc) {
            return;
        }
        
        //YIHAIKERRY-4345
        if ([fb.fv isEqualToString:LEAVESTORE_FV]) {
            
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:nil tips:nil tapTarget:nil action:nil];
            
            __block UIViewController *blockVc = vc;
            __block WSFuncsBean *blockFb = fb;
            __weak __typeof(self) weakSelf = self;
            NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
            NSString *storeId = self.currentStore.Id;
            
            [self queryAdditionalRemindWithEmpId:empId storeId:storeId completionBlock:^(BOOL isSuccess, NSString *result) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:YES];
                    if (!isSuccess) {
                        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:result];
                        [alert addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:nil];
                        [alert show];
                        return;
                    }
                    
                    if (result && result.length > 0 && ![result isEqualToString:kNoNotic]){
                            BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:result];
                            [alert addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:nil];
                            [alert show];
                            return;
                    }
                    
                    [weakSelf didSelectItemJump:blockVc funcsBean:blockFb];
                });
            }];
            
            return;
        }
        
        [self didSelectItemJump:vc funcsBean:fb];
    } else {
        WSWorkFlowMoreViewController *vc = [[WSWorkFlowMoreViewController alloc] initWithFuncs:self.currentFuncs Store:self.currentStore];
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.allDataArray];
        [tempArray removeObject:fb];
        vc.funcBeanArray = tempArray;
        vc.ignoreMenuTypeId = self.currentFuncs.menuType;
        vc.moduleFC = self.moduleFC;
        vc.currentVisitAction = self.currentVisitAction;
        vc.input_reflect_code = self.input_reflect_code;
        vc.acvtNewStore = self.acvtNewStore;
        vc.wsSplitController = self.wsSplitController;
        vc.realParentFuncsCode = self.realParentFuncsCode;
        vc.title = self.title;
        [self pushViewController:vc isAutoJump:NO];
    }
    

}

#pragma mark - Private Method

- (void)setIsGridMore {
    if (!self.currentFuncs.menuStyle || self.currentFuncs.menuStyle.length == 0) {
        return;
    }
    WSBaseDictsDBService *dbService = [[WSBaseDictsDBService alloc] init];
    WSDictBean *dictBean = [dbService queryDictWithID:self.currentFuncs.menuStyle];
    if (dictBean ) {
        NSString *dictName = dictBean.name;
        if ([dictName isEqualToString:FUNCS_MORE_GRID_STYLE]) {
            self.isGridMore = YES;
        }
    }
}

- (BOOL)isFuncsBeanShow:(WSFuncsBean *)funcbean {
    BOOL isShow = YES;
    NSString *fv = [funcbean.fv uppercaseString];
    if ([funcbean.required isEqualToString:REQUIRED_R] &&
        [fv isEqualToString:kFV_V20A01] &&
        [funcbean.isAcvtList isEqualToString:@"1"]) {
        NSArray* l_acvtFilters = [WSAcvtListViewController filterAcvtListWithCurrentFuncs:funcbean withCurrentStore:self.currentStore];
        if (l_acvtFilters && l_acvtFilters.count == 0) {
            isShow = NO;
        }
    }
    return isShow;
}

#pragma mark -- 触发门店拜访的点击
- (void)checkClickStoreVist {
    [self collectionView:self.dataCollectionView didSelectItemAtIndexPath:self.visitIndexPath];
}
//获取需要提示的菜单的编码
- (void)getCurrentLeaveStoreTipFunc {
    
    for (int i = 0; i < self.funcBeanArray.count;i ++ ) {
            WSFuncsBean* fb = self.funcBeanArray[i];
            if (fb.opt.leaveStoreTipFunc) {
                self.leaveStoreTipFunc = fb.opt.leaveStoreTipFunc;
                break;
            }
        }
    
}
-(WSNoticeNumFcService *)noticeNumFcServicce {
    if (!_noticeNumFcServicce) {
        //
        _noticeNumFcServicce = [[WSNoticeNumFcService alloc]init];
    }
    return _noticeNumFcServicce;
}

#pragma mark - 点击选择项目跳转方法 vc:跳转视图管理器 fb:功能模块
- (void)didSelectItemJump:(UIViewController *)vc funcsBean:(WSFuncsBean *)fb {
    
    if ([vc isKindOfClass:[SuperWorkSpaceViewController class]]) {
        SuperWorkSpaceViewController *superVC = (SuperWorkSpaceViewController *)vc;
        superVC.wsSplitController = self.wsSplitController;
    }    
    BOOL isGotoNextPage = [self gotoNextPageWithViewController:vc withFuncsBean:fb withAutoJump:NO];
    if (isGotoNextPage && self.wsSplitController) {
        [self reloadData];
    }
}

#pragma mark - # 收集地理位置信息弹框
- (void)addCollectUserLocationPlaclyAlert:(completeSuccess)successBlock{
    NSString * visitPrivacyPolicyMsg = [[WSAppData sharedManager].datas objectForKey:VISITPRIVACYMESSAGE];
    BlockAlertView *alert = [BlockAlertView alertWithTitle:@"通知" message:visitPrivacyPolicyMsg];
    [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:^{
        
    }];
    [alert addButtonWithTitle:NSLocalizedString(@"approval", nil) block:^{
        LogInfo(@"同意手机用户定位信息");
        [WSRequestTools requestAgreeAppCollectingPrivacySuccess:^(BOOL success) {
            NSString * empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithValue:@"1"] forKey:[NSString stringWithFormat:@"%@_%@",VISITPRIVACYFLAG,ISNULL(empId)]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if (successBlock) {
                successBlock(YES);
            }
        }];
        

    }];
    [alert show];
}
#pragma mark - # 查询门店拜访状态
- (void)queryVisitStoreState{
    
    WSVisitStoreStatusObject  * obj = [WSVisitStoreStatusTable queryVisitStoreStatusWithStoreId:self.currentStore.Id];
    if (obj) {
        if (obj.from_module&&obj.from_module.length>0) {
            if ([obj.from_module isEqualToString:@"助销"]) {
                self.currentStore.actionState = ActionWorking;
            }if ([obj.from_module isEqualToString:@"已助销"]) {
                self.currentStore.actionState = ActionDone;
            }
        }else{
            self.currentStore.actionState = obj.status;
        }
    }
}

@end

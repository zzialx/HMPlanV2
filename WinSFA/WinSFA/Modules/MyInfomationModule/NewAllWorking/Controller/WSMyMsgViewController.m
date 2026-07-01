//
//  PopTableViewController.m
//  demo
//
//  Created by zhiqingPC on 18/1/20.
//  Copyright (c) 2015年 zhiqingPC. All rights reserved.
//

#import "WSMyMsgViewController.h"
#import "TitleButton.h"
#import "PopView.h"
#import "WSDetalViewController.h"
#import "CellModel.h"
#import "WSMyMessageCell.h"
#import "UIViewController+ESSeparatorInset.h"
#import "UIBarButtonItem+Extension.h"
#import "WSNavigationBar.h"
#import "WSFuncsBean.h"
#import "WSMsgsBean.h"
#import "WSMsgBeanArray.h"
#import "WSMsgsBean_msg.h"
#import "WSRequestHelper.h"
#import "WSSubMsgsViewController.h"
#import "WSMsgAlertView.h"
#import "MJRefresh.h"
#import "WSBaseMsgTable.h"
#import "WSBaseMsgTypeTable.h"
#import "WSBaseMsgTypeDBService.h"
#import "WSMessageForNewUICell.h"
#import "WSSearchBar.h"
#import "WSMJProgressHeader.h"
#import "WSRequestHelper.h"
#import "WSEmptyViewCell.h"
#import "WSFuncsBeanArray.h"
#import "WSTopBannerCycleScrollView.h"
#import "WSMessageForiPadCell.h"
#import "WSReportFormController.h"
#import "WSJSONBuilder.h"
#import "GetMD5byStr.h"

#define BROWSERVC_WIDTH 1024
#define BROWSERVC_HEIGNT 768
#define BANNERVIEW_WIDTH  381
#define BANNERVIEW_HEIGHT 286

//=======================================================================================================================================================

@interface WSMyMsgViewController () <UISearchBarDelegate,WSTopBannerCycleScrollViewDelegate>

@property (nonatomic, strong) WSDetalViewController *detalCtrl;
@property (nonatomic, strong) NSMutableArray *sourceArray;
@property (nonatomic, strong) TitleButton *popBtn;
@property (nonatomic, strong) PopView *popView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong)WSCustomView *customView;
@property (nonatomic, strong) WSFuncsBean *subFuncBean;
@property (nonatomic, strong) WSSearchBar *searchBar;
@property (nonatomic, strong) WSMsgsBean *selectMsgsBean;
@property (nonatomic, copy) NSString *titleForAll;
@property (nonatomic, strong) NSMutableArray *MsgArray;         //信息分类的数组
@property (nonatomic, strong) NSMutableArray *allMsg_msgArray;  //发布的全部信息
@property (nonatomic, strong) NSMutableArray * unReadMsgArray;  //未读消息
@property (nonatomic, assign) BOOL isFirstDrag;
@property (nonatomic, assign) BOOL isFirstLoad;
@property (nonatomic, strong) WSEmptyView *msgEmptyView;        //消息空视图
@property (nonatomic, assign) BOOL isBackRefresh;               //是否需要返回刷新标示
@property (nonatomic, strong) WSTopBannerCycleScrollView *topBannerView;     //
@property (nonatomic, strong) UIView *msgBackgoundView;
@property (nonatomic, assign) BOOL isEnterMsgList;
#pragma mark - 发布公告响应方法 sender:按键
- (void)releaseNoticeResponse:(id)sender;

@end
//=======================================================================================================================================================

#pragma mark - WSMyMsgViewController延展(工具)
@interface WSMyMsgViewController (Tools)

#pragma mark - 获取表视图头部高度方法
- (CGFloat)getTableViewHeaderViewHeight;

#pragma mark - 增加导航栏右按钮方法
- (void)addRightBarButtonItem;

#pragma mark - 请求公告方法
- (void)requestMsg;

@end
//=======================================================================================================================================================

@implementation WSMyMsgViewController

- (NSMutableArray *)allMsg_msgArray
{
    if (!_allMsg_msgArray)
        _allMsg_msgArray = [NSMutableArray array];
    
    return _allMsg_msgArray;
}

- (NSMutableArray *)isReadArray
{
    if (!_isReadArray)
        _isReadArray = [[NSMutableArray alloc]init];
    
    return _isReadArray;
}

- (NSMutableArray *)unReadMsgArray
{
    if (!_unReadMsgArray)
        _unReadMsgArray = [[NSMutableArray alloc]init];
    
    return _unReadMsgArray;
}

- (NSMutableArray *)sourceArray
{
    if (!_sourceArray)
        _sourceArray = [[NSMutableArray alloc]init];
    
    return _sourceArray;
}

#pragma mark - 获取msgEmptyView方法
- (WSEmptyView *)msgEmptyView
{
    if(_msgEmptyView == nil)
    {
        _msgEmptyView = [[WSEmptyView alloc] initWithFrame:self.view.bounds];
        _msgEmptyView.backgroundColor = [UIColor whiteColor];
        _msgEmptyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _msgEmptyView.hidden = YES;
    }
    return _msgEmptyView;
}

#pragma mark - system mathod
-(id)initWithFuncs:(WSFuncsBean*)funcs
{
    if(funcs == nil)
        return nil;
    
    self = [super init];
    if(self != nil)
    {
        self.currentFuncs = funcs;
        return self;
    }
    return nil;
}

- (void)viewDidLoad
{
    self.navigationItem.leftBarButtonItem = nil;
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:236/255.0 alpha:1];
    //MN-220 2018-01-27
    [self addRightBarButtonItem];
    
    [self addSearchView]; //添加收索框
    
    CGRect tableViewRect;
    
    self.tableView = [[UITableView alloc]init];
    self.tableView.delegate = self ;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    if (INTERFACE_IS_PAD) {
        [self.view addSubview:self.searchBar];
        
        
        WSTopBannerCycleScrollView *topBannerView = [[WSTopBannerCycleScrollView alloc] initWithFrame:CGRectMake(20, 64, BANNERVIEW_WIDTH, BANNERVIEW_HEIGHT) withUseTitle:YES];
        topBannerView.delegate = self;
        self.topBannerView = topBannerView;
        [self.view addSubview:topBannerView];
        
        CGFloat tabelWidth = BROWSERVC_WIDTH - 200 - self.topBannerView.right - 2 *MAIN_CELL_SEPERATOR_LENGTH;
        CGFloat tableHeight = BANNERVIEW_HEIGHT -4  - 44;
        CGFloat tableViewY = 48;
        self.msgBackgoundView = [self addMsgBgViewWithFram:CGRectMake(self.topBannerView.right + MAIN_CELL_SEPERATOR_LENGTH, self.searchBar.bottom + MAIN_CELL_SEPERATOR_LENGTH, tabelWidth, BANNERVIEW_HEIGHT)];
        [self.view addSubview:self.msgBackgoundView];
        self.tableView.frame = CGRectMake(0, tableViewY, tabelWidth , tableHeight);
        [self.msgBackgoundView addSubview:self.tableView];
    }else{
        self.tableView.frame =  self.view.bounds;
        tableViewRect = self.view.bounds;
        self.tableView.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:236/255.0 alpha:1];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:self.tableView];
    }
    
    if ([self getNavigationController].viewControllers.count>1)
        [self initializationBackItemAction];
    if (self.currentFuncs.funcsArray.count > 1)
        self.subFuncBean = [self.currentFuncs.funcsArray objectAtIndex:0];
    
    BOOL isHomePage = YES;
    [self setWorkInfoWithHomePage:isHomePage];
    
    [self getNavigationItem].titleView = nil;
    TitleButton  *popBtn = [TitleButton buttonWithType:UIButtonTypeCustom];
//    popBtn.centerX = self.view.width / 2;
    popBtn.width = SCREEN_WIDTH - 44;
    if (self.MsgArray.count >= 1)
    {
        UIImage * normalImg = [UIImage imageNamed:@"menu_xialan_arrow"];
        [popBtn setImage:normalImg forState:UIControlStateNormal];
    }
    [popBtn addTarget:self action:@selector(titleBtnClk:) forControlEvents:UIControlEventTouchUpInside];
    [self getNavigationItem].titleView = popBtn ;
    self.popBtn = popBtn;
    [self changeTileButtonState];
    
    WSMJProgressHeader *header = [WSMJProgressHeader headerWithRefreshingTarget:self refreshingAction:@selector(updataInfo)];
    header.automaticallyChangeAlpha = YES;
    self.tableView.mj_header = header;
    self.isFirstLoad = YES;
    
    [self.view addSubview:self.msgEmptyView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //    if (INTERFACE_IS_PAD)
    //    {
    //        self.navigationController.view.width = (BROWSERVC_WIDTH - kLeftVieWidth)/2;
    //        if (self.sourceArray.count == 0)
    //            [[NSNotificationCenter defaultCenter] postNotificationName:MYMSG_DETAIL_DIDSELECT_MESSAGE object:nil];
    //    }
    
//    [_tableView reloadData];
    
    if(self.isBackRefresh)
    {
        self.isBackRefresh = NO;
        [self requestMsg];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self changeTitleButton];
//    if (self.isFirstLoad)
//    {
//        self.isFirstLoad = NO;
//        if (INTERFACE_IS_PHONE) {
//            NSDictionary *mobileHomeDic = [WSAppData getObjectbyKey:MOBILEHOMEPAGE];
//            self.isEnterMsgList = [[NSString stringNotNilWithValue:mobileHomeDic[@"fc"]] isEqualToString:@"3"];
//            NSArray *unReadMessage = [[WSBaseMsgTable sharedTable]queryAllUnreadBaseMsgs]; // MSTD-6205 如果只有一条未读消息直接跳到详情页面，如果有多条未读消息 跳到列表
//            if (unReadMessage.count == 1 && self
//                .isEnterMsgList)
//            {
//                [self jumpNextDetailPage:unReadMessage];
//                return;
//            }
//            else if (unReadMessage.count > 1)
//                return;
//        }
//
//        NSString *filter = nil;
//        if (self.subFuncsBeanNeedShow)
//            filter = self.subFuncsBeanNeedShow.filter;
//        
//        if ([filter length] > 0)
//        {
//            NSInteger index = 0;
//            WSMsgsBean *workInfoMsgBean = nil;
//            for (WSMsgsBean *msgBean in self.MsgArray)
//            {
//                if ([msgBean.cod isEqualToString:filter])
//                {
//                    workInfoMsgBean = msgBean;
//                    index = [self.MsgArray indexOfObject:msgBean];
//                    break;
//                }
//            }
//            
//            if (workInfoMsgBean)
//            {
//                NSArray *tempArray = [[[WSBaseMsgTable sharedTable] queryBaseMsgWithPid:workInfoMsgBean.Id] copy];
//                NSInteger readNum = [[WSBaseMsgTable sharedTable] queryReadedBaseMsgsWithPid:workInfoMsgBean.Id];
//                if (tempArray && tempArray.count > 0) // 如果没有重要消息，就进入列表页，不选中重要消息
//                {
//                    NSString * titleString = [NSString stringWithFormat:@"%@(%ld/%ld)",workInfoMsgBean.name,(long)readNum,(unsigned long)tempArray.count];
//                    [self selectMsgWithIndex:index + 1 title:titleString];
//                }
//                else
//                {
//        //                  SFA-18938 donghong
//                    [self showParticulars];
//                }
//            }
//            self.subFuncsBeanNeedShow = nil;
//        }
//        else
//        {
//            [self showParticulars];
//
//        }
//    }
//    
//    if ([WSAppData sharedManager].showHomePage) {
//        return;
//    }
//    [WSAppData sharedManager].showHomePage = YES;
//    WSFuncsBeanArray* fba= [WSAppData getObjectbyKey:FUNCS];
//    NSDictionary *showFuncsDict = [fba getShowFuncsBean];
//    if ([[showFuncsDict objectForKey:IS_SHOW] isEqualToString:@"1"]) {
//        
//        [self pushViewWithFuncsBean:[showFuncsDict objectForKey:FROM_FUNCS_BEAN] realSubFuncsBean:[showFuncsDict objectForKey:SHOW_FUNCS_BEAN]];
//        
//    }
}
- (void)pushViewWithFuncsBean:(WSFuncsBean *)fb realSubFuncsBean:(WSFuncsBean *)realSubFuncsBean{
    WCBaseViewController* vc = [WCBaseViewController getControllerWithFuncsBean:fb realSubFuncsBean:realSubFuncsBean];
    
    if (vc) {
        [self setHidesBottomBarWhenPushed:YES];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)showParticulars
{
    if (INTERFACE_IS_PAD && self.sourceArray.count)
    {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
        [self tableView:self.tableView didSelectRowAtIndexPath:ip];
    }
}
-(void)initializationBackItemAction
{
    NSDictionary *mobileHomeDic = [WSAppData getObjectbyKey:MOBILEHOMEPAGE];
    if (mobileHomeDic)
    {
        if (self.currentFuncs && self.currentFuncs.isHomePageWillShow)
        {
            NSString *readTimeStr = [mobileHomeDic objectForKey:MobileHomePageReadingTimeKey];
            [self backItemAction:nil target:nil withDelay:[readTimeStr intValue]];
            self.currentFuncs.isHomePageWillShow = NO;
        }
    }
    else
        [self backItemAction:nil target:nil];
}

- (void)setWorkInfoWithHomePage:(BOOL)isHomePageSign
{
    WSMsgBeanArray *messageArray = nil;
    if (self.currentStore) {
        messageArray = [[WSMsgBeanArray alloc]initWithObject:[[WSBaseMsgTypeTable sharedTable] queryBaseMsgType]
                                                     storeId:self.currentStore.Id];
    } else {
        messageArray = [[WSMsgBeanArray alloc]initWithObject:[[WSBaseMsgTypeTable sharedTable] queryBaseMsgType]];
    }

    
    
    self.MsgArray = [[NSMutableArray alloc] init];//存储分类数据信息
    
    // 存储全部信息
    if (self.currentFuncs.styp && self.currentFuncs.styp.length > 0)
        self.MsgArray = [[messageArray getMsgsBeansWithStyp:self.currentFuncs.styp] mutableCopy];
    else
        self.MsgArray = messageArray.msgArray;
    
    [self getAllMsgArrayData];
    
    if (messageArray.msgArray.count == 0)
        return;
    
    NSArray *msgsArray = nil;
    __block WSMsgsBean * workMsgBean = nil;
    __block WSMsgsBean_msg * msgsB_msg = nil;
    
    NSMutableArray *filterArray = [NSMutableArray array];
    if (self.currentFuncs.filter != nil && [self.currentFuncs.filter length] > 0)
    {
        msgsArray = [messageArray getMsgsBeansWithFilter:self.currentFuncs.filter];
        if (msgsArray != nil)
        {
            WSFuncsBean* subfuncs = self.currentFuncs;
            if (self.currentFuncs.funcsArray.count > 0)
                subfuncs   = [self.currentFuncs.funcsArray objectAtIndex:0];
            
            [msgsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                workMsgBean = (WSMsgsBean*)obj;
                BOOL isFilter = NO;
                for (WSMsgsBean_msg *msg in workMsgBean.msg)
                {
                    if (msg.typcode != nil) {
                        if ([msg.typcode isEqualToString:subfuncs.filter]) {
                            msgsB_msg = msg;
                        } else if (!isFilter) {
                            isFilter = YES;
                            [filterArray addObject:obj];
                        }
                    }
                }
            }];
            //
            if ([filterArray count] > 0) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF in %@", [filterArray copy]];
                self.MsgArray = [[msgsArray filteredArrayUsingPredicate:predicate] mutableCopy];
            } else {
                self.MsgArray = [msgsArray mutableCopy];
            }
            
            [self changeTitleButton];
        }
    }
    
    
    if (msgsB_msg == nil)
    {
        for (WSMsgsBean * workMsgB in messageArray.msgArray)
        {
            NSString *filter = self.subFuncBean.filter;
            if (filter && [filter isEqualToString:workMsgB.cod])
            {
                workMsgBean = workMsgB;
                break;
            }
        }
        
        msgsB_msg = [workMsgBean.msg lastObject];
    }
    
    if ([workMsgBean.cod isEqualToString:@"msgAlter"] && INTERFACE_IS_PAD)
    {
        [self createAlterViewWith:msgsB_msg];
        return;
    }
}
#pragma mark------修改标题和刷新数据源
-(void)changeTitleButton
{
    if (self.selectMsgsBean == nil)
    {
        [self getAllMsgArrayData];
        [self changeTileButtonState];
        [self.tableView reloadData];
    }
    else
    {
        [self getSelectBeanSourceArray:self.selectMsgsBean];
        [self setPopBtnTitle:self.selectMsgsBean];
        [self.tableView reloadData];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MAIN_VC_NEED_UPDATE_BADGE_NOTIFY object:nil];
}

- (void)getAllMsgArrayData
{
    [self.allMsg_msgArray removeAllObjects];
    for (int i = 0; i < self.MsgArray.count; i++)
    {
        WSMsgsBean * msgBean = self.MsgArray[i];
        for (WSMsgsBean_msg * tempMsg in msgBean.msg)
        {
            tempMsg.componentMsgs = [tempMsg generateComponentMsgsWith:tempMsg fileUrl:tempMsg.fileUrl];
            [self.allMsg_msgArray addObject:tempMsg];
        }
    }
    
    [self.sourceArray removeAllObjects];
    self.sourceArray = self.allMsg_msgArray.mutableCopy;
}
#pragma mark-----下拉获取新的数据
-(void)updataInfo
{
    self.searchBar.searchBar.text = @"";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadFinished:) name:UPDATA_MSG object:nil];
    if (self.currentStore) {
        [[WSRequestHelper shareInstance] postNewRequestMSGWithType:nil storeId:self.currentStore.Id];

    }else{
        [[WSRequestHelper shareInstance] postRequestMSGWithType:nil];

    }
    
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    aiv.hidesWhenStopped = YES;
    [aiv startAnimating];
}
#pragma mark-----请求结束，数据处理
-(void)uploadFinished:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATA_MSG object:nil];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0)
    {
        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        [self endRefreshData];
        return;
    }
    else
    {
        if (self.currentStore) {
            NSDictionary *uploadState = [info objectFromJSONString];
            NSArray * array = [NSArray array];
            NSArray * storeArray = [NSArray array];
            if ([uploadState.allKeys containsObject:MSG_REAL]) {
                NSDictionary * msg_real_dic = [uploadState[MSG_REAL] firstObject];
                array = [msg_real_dic objectForKey:MSGS];
                storeArray  = [msg_real_dic objectForKey:@"storemsg"];
            }else{
                array = [uploadState objectForKey:MSGS];
            }
            if (array.count && array.count > 0)
            {
                [[WSBaseMsgTypeTable sharedTable] deleteAll];
                [[WSBaseMsgTable sharedTable] deleteAll];
                WSBaseMsgTypeDBService * dbSeevice = [[WSBaseMsgTypeDBService alloc] init];
                //插入新的消息数据
                [dbSeevice replaceToTableWithDicts:array FromNode:MSGS hasNewData:YES];
                if (storeArray.count>0) {
                    [dbSeevice updateMsgStoreTable:storeArray storeId:self.currentStore.Id];
                }
            }
        }else{
            NSDictionary *uploadState = [info objectFromJSONString];
            NSArray *array = [uploadState objectForKey:MSGS];
            
            if (array.count && array.count > 0)
            {
                [[WSBaseMsgTypeTable sharedTable] deleteAll];
                [[WSBaseMsgTable sharedTable] deleteAll];
                WSBaseMsgTypeDBService * dbSeevice = [[WSBaseMsgTypeDBService alloc] init];
                [dbSeevice replaceToTableWithDicts:array FromNode:MSGS hasNewData:YES];
            }
        }
        
        WSMsgBeanArray *messageArray = nil;
        if (self.currentStore) {
            messageArray = [[WSMsgBeanArray alloc]initWithObject:[[WSBaseMsgTypeTable sharedTable] queryBaseMsgType]
                                                         storeId:self.currentStore.Id];
        } else {
            messageArray = [[WSMsgBeanArray alloc]initWithObject:[[WSBaseMsgTypeTable sharedTable] queryBaseMsgType]];
        }
        
        if (messageArray.msgArray .count && messageArray.msgArray.count > 0)
        {
            NSArray *arrays = nil;
            if (self.currentFuncs.filter != nil && [self.currentFuncs.filter length] > 0)
                arrays = [messageArray getMsgsBeansWithFilter:self.currentFuncs.filter];
            
            if (self.currentFuncs.styp != nil && [self.currentFuncs.styp length] > 0)
                arrays = [messageArray getMsgsBeansWithStyp:self.currentFuncs.styp];
            [self.MsgArray removeAllObjects];
            if (arrays == nil)
                self.MsgArray = [NSMutableArray arrayWithArray:messageArray.msgArray];
            else
                self.MsgArray = [NSMutableArray arrayWithArray:arrays];
            
            [self changeTitleButton];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:MAIN_VC_NEED_UPDATE_BADGE_NOTIFY object:nil]; // 下拉刷新出新的数据后,通知首页更新未读数
            //            NSString *tmpString = NSLocalizedString(@"update_done_label",nil);
            //            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        }
    }
    
    [self endRefreshData];
}

- (void)addSearchView
{
    self.searchBar = [[WSSearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 44.0) isResetTextField:NO isResetBackgroundColor:YES];
    self.searchBar.searchBar.placeholder = NSLocalizedString(@"query_label", nil);
    self.searchBar.searchBar.delegate = self;
    self.searchBar.backViewColor = [UIColor whiteColor];
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}

- (UIView *)addMsgBgViewWithFram:(CGRect)frame{
    
    UIView *bgView = [[UIView alloc] initWithFrame:frame];
    bgView.backgroundColor = [UIColor whiteColor];
    
    UIView *boderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, bgView.width, 4)];
    boderView.backgroundColor = [UIColor colorWithHexString:@"#3983f9"];
    [bgView addSubview:boderView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 4, bgView.width, 44)];
    titleLabel.backgroundColor = [UIColor whiteColor];
    titleLabel.text = @"最新公告";
    titleLabel.font = FONT_SIZE_PINGFANG_REGULAR(24);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.contentMode = UIViewContentModeCenter;
    titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    [bgView addSubview:titleLabel];
    
//    UIButton *refresh = [UIButton buttonWithType:UIButtonTypeCustom];
//    refresh.frame = CGRectMake((bgView.width - 67)/2.0 , (bgView.height - 60) + 10, 67, 35);
//    [refresh addTarget:self action:@selector(updataInfo) forControlEvents:UIControlEventTouchUpInside];
//    UIImage *image = [UIImage imageNamed:@"more_refresh"];
//    [refresh setImage:image forState:UIControlStateNormal];
//    [bgView addSubview:refresh];
    
    return bgView;
}
- (void)endRefreshData
{
    [self.tableView.mj_header endRefreshing];
}

-(void)pop
{
    [[self getNavigationController] popViewControllerAnimated:YES];
}

-(void)titleBtnClk:(TitleButton *)titleBtn
{
    float height = 0.0f;
    NSInteger rowCount = 0;
    for (int i = 0; i < self.MsgArray.count; i++)
    {
        [self.isReadArray removeAllObjects]; // 这里也需要再清理一次
        WSMsgsBean *bean = self.MsgArray[i];
        
        for (WSMsgsBean_msg * bean_msg in bean.msg)
        {
            NSString *key = [NSString stringWithFormat:@"%@#%@#%@", bean_msg.s, bean_msg.Id,[WSAppData getObjectbyKey:APPDATA_EMPID]];
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            NSDictionary *dic = [user dictionaryForKey:kWSMessageDomainName];
            NSNumber *number = [dic objectForKey:key];
            if ([bean_msg.isread isEqualToString:@"1"] || (number && [number boolValue]))
                [_isReadArray addObject:bean_msg];
        }
        if (bean.msg.count && (bean.msg.count != 0))
            ++rowCount;
    }
    
    height = (rowCount + 1) * 44;
    WSCustomView *customView = [[WSCustomView alloc] initWithFrame:CGRectMake(0, 0, 205, height) msgArray:self.MsgArray  titleName:_titleForAll];
    self.customView = customView;
    customView.delegate = self;
    [UIView animateWithDuration:0.5 animations:^{
        titleBtn.imageView.transform = CGAffineTransformRotate(titleBtn.imageView.transform, M_PI);
    }];
    
    if (self.MsgArray.count >= 1)
    {
        PopView *popView = [[PopView alloc] initWithCustomView:customView];
        [popView showWithView:titleBtn];
        self.popView = popView;
    }
}

-(void)selectBtn:(UIButton * )btn
{
    [UIView animateWithDuration:0.5 animations:^{
        self.popBtn.imageView.transform = CGAffineTransformRotate(self.popBtn.imageView.transform, M_PI);
    }];
    
    [self selectImpotWorKing:btn];
    self.searchBar.searchBar.text = @"";
    [self.searchBar endEditing:YES];
}

-(void)selectImpotWorKing:(UIButton * )btn
{
    [self selectMsgWithIndex:btn.tag title:btn.titleLabel.text];
}

- (void)selectMsgWithIndex:(NSInteger)index title:(NSString *)title;
{
    [self.popBtn setTitle:title forState:UIControlStateNormal];
//    [self.popBtn sizeToFit];
    LogInfo(@"按钮索引--->%ld",index);

    if (index == 0)
    {
        self.sourceArray = [self.allMsg_msgArray mutableCopy];
        self.selectMsgsBean = nil;
        [self changeTileButtonState];
    }
    else
    {
        self.selectMsgsBean = nil;
        WSMsgsBean * bean =   self.MsgArray[index - 1];
        self.selectMsgsBean = bean;
        [self getSelectBeanSourceArray:bean];
    }
    
    [self orderByPubdateDate];
    [self.tableView reloadData];
    [self.popView removeFromSuperview];
    
    if (self.subFuncsBeanNeedShow && [self.sourceArray count] > 0 && self.isEnterMsgList)
        [self jumpNextDetailPage:self.sourceArray.copy];// 只有一条消息时进入详情，多条的话进入列表
    
    if (INTERFACE_IS_PAD && self.sourceArray.count)
    {
        NSIndexPath *ip=[NSIndexPath indexPathForRow:0 inSection:0];
        [self tableView:self.tableView didSelectRowAtIndexPath:ip];
    }
}

-(void)jumpNextDetailPage:(NSArray *)array
{
    if (array.count == 1)
    {
        if (INTERFACE_IS_PHONE)
        {
            WSDetalViewController * detalCtrl = [[WSDetalViewController alloc]init];
            WSMsgsBean_msg * msgsBean = array[0];
            if ([msgsBean isKindOfClass:[WSBaseMsgObject class]])
            {
                WSMsgsBean_msg * msgBean = [[WSMsgsBean_msg alloc]initWithObject:msgsBean];
                msgBean.componentMsgs = [msgBean generateComponentMsgsWith:msgBean fileUrl:msgBean.fileUrl];
                detalCtrl.model = msgBean;
            }
            else
                detalCtrl.model = msgsBean;
            
            detalCtrl.msgBean = self.MsgArray;
            detalCtrl.isHomePageShow = YES;
            detalCtrl.hidesBottomBarWhenPushed = YES;
            [[self getNavigationController] pushViewController:detalCtrl animated:YES];
        }
    }
}

- (void)getSelectBeanSourceArray:(WSMsgsBean *)bean
{
    [self.sourceArray removeAllObjects];
    NSMutableArray * tempArray = [NSMutableArray array];
    tempArray = [[[WSBaseMsgTable sharedTable] queryBaseMsgWithPid:bean.Id] mutableCopy] ;
    for (WSMsgsBean_msg *tempModel  in tempArray)
    {
        WSMsgsBean_msg * temp = [[WSMsgsBean_msg alloc]initWithObject:tempModel];
        temp.componentMsgs = [temp generateComponentMsgsWith:temp fileUrl:temp.fileUrl];
        [self.sourceArray addObject:temp];
    }
}

- (void)setPopBtnTitle:(WSMsgsBean *)workInfoBean
{
    NSMutableArray *isReadArray = [NSMutableArray array];
    for (WSMsgsBean_msg * bean_msg in workInfoBean.msg)
    {
        NSString *key = [NSString stringWithFormat:@"%@#%@#%@", bean_msg.s, bean_msg.Id,[WSAppData getObjectbyKey:APPDATA_EMPID]];
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSDictionary *dic = [user dictionaryForKey:kWSMessageDomainName];
        NSNumber *number = [dic objectForKey:key];
        if ([bean_msg.isread isEqualToString:@"1"] || (number && [number boolValue]))
            [isReadArray addObject:bean_msg];
    }
    
    NSInteger msgCount = workInfoBean.msg.count;
    NSInteger readCount = [isReadArray count];
    [self.popBtn setTitle:[NSString stringWithFormat:@"%@(%ld/%ld)",workInfoBean.name,(long)readCount,(long)msgCount] forState:UIControlStateNormal];
}

-(void)changeTileButtonState
{
    [self orderByPubdateDate];
    
    NSString *title = NSLocalizedString(@"all", nil); //  SFA 项目 SFA-5765  后面如果再遇到有需求是不显示 ‘全部’ 需要显示 菜单名的需要添加参数
    if ([self.currentFuncs.fc isEqualToString:@"TB_F10_AT78"] && [self.currentFuncs.fv isEqualToString:@"TB_V10"])
        title = @"积分政策";
    
    _titleForAll = [NSString stringWithFormat:@"%@(%lu/%lu)",title,(unsigned long)self.isReadArray.count,(unsigned long)self.sourceArray.count];
    [self.popBtn setTitle:_titleForAll forState:UIControlStateNormal];
    if (INTERFACE_IS_PAD)
    {
        [self.popBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.popBtn.titleLabel.font = [UIFont systemFontOfSize:20.0];
    }
}

-(void)orderByPubdateDate
{
    [self.isReadArray removeAllObjects];;
    [self.unReadMsgArray removeAllObjects];;
    
    for (WSMsgsBean_msg * tempMsg in self.sourceArray)
    {
        tempMsg.componentMsgs = [tempMsg generateComponentMsgsWith:tempMsg fileUrl:tempMsg.fileUrl];
        NSString *key = [NSString stringWithFormat:@"%@#%@#%@", tempMsg.s, tempMsg.Id,[WSAppData getObjectbyKey:APPDATA_EMPID]];
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSDictionary *dic = [user dictionaryForKey:kWSMessageDomainName];
        NSNumber *number = [dic objectForKey:key];
        if ([tempMsg.isread isEqualToString:@"1"] || (number && [number boolValue]))
            [self.isReadArray addObject:tempMsg];
        else
            [self.unReadMsgArray addObject:tempMsg];
    }
    
    NSSortDescriptor *carNameDesc = [NSSortDescriptor sortDescriptorWithKey:@"pubdate" ascending:NO];
    NSArray *descriptorArray = [NSArray arrayWithObjects:carNameDesc, nil];
    self.isReadArray = [[self.isReadArray sortedArrayUsingDescriptors:descriptorArray] mutableCopy];
    self.unReadMsgArray = [[self.unReadMsgArray sortedArrayUsingDescriptors:descriptorArray] mutableCopy];
    
    [self.sourceArray removeAllObjects];
    [self.sourceArray addObjectsFromArray:self.unReadMsgArray];  //未读在前，已读在后
    [self.sourceArray addObjectsFromArray:self.isReadArray];
}

- (void)createAlterViewWith:(WSMsgsBean_msg *)msgBean
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    WSMsgAlertView *alterView = [[WSMsgAlertView alloc] initWithFrame: window.rootViewController.view.bounds msgBean:msgBean];
    [window.rootViewController.view addSubview:alterView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ((self.sourceArray.count > 0) ? self.sourceArray.count : 1);
}

-(UITableViewCell * )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.sourceArray.count > 0)
    {
        WSMsgsBean_msg *allMsgModel = self.sourceArray[indexPath.row];
        if (INTERFACE_IS_PHONE) {
            WSMessageForNewUICell *cell = [WSMessageForNewUICell cellWithTableView:tableView];
            cell.msgBean = self.MsgArray;
            cell.MsgsBean_msg = allMsgModel;
            return cell;
        }else{
            WSMessageForiPadCell *cell = [WSMessageForiPadCell cellWithTableView:tableView];
            cell.MsgsBean_msg = allMsgModel;
            return cell;
        }
    }
    
    static NSString *EmptyViewCellIdentifier = @"concernsCelEmptyViewCellIdentifierlIdentifier";
    WSEmptyViewCell *emptyViewCell = [tableView dequeueReusableCellWithIdentifier:EmptyViewCellIdentifier];
    if(emptyViewCell == nil)
    {
        emptyViewCell = [[WSEmptyViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:EmptyViewCellIdentifier];
        [emptyViewCell setBackgroundColor:[UIColor whiteColor]];
        [emptyViewCell setAccessoryType:UITableViewCellAccessoryNone];
        [emptyViewCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    [emptyViewCell setupEmptyViewCellFromFuncsBean:self.currentFuncs];
    return emptyViewCell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.sourceArray.count > 0) {
        if (INTERFACE_IS_PHONE) {
            return [WSMessageForNewUICell cellHeightForRow:self.sourceArray[indexPath.row] with:self.view.width];
        }else{
            CGFloat cellHeight = [WSMessageForiPadCell cellHeightForRow:self.sourceArray[indexPath.row] with:self.tableView.width];
            return cellHeight;
        }
    }
    return CGRectGetHeight(tableView.bounds);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (INTERFACE_IS_PAD) {
        [tableView selectRowAtIndexPath:indexPath animated:YES
                         scrollPosition:UITableViewScrollPositionNone];
    }
    if(self.sourceArray.count <= 0)
        return;
    
    WCBaseViewController *detalCtrl = nil;
    WSMsgsBean_msg *msgBean = self.sourceArray[indexPath.row];
    if ([msgBean.cont length] > 0 && [msgBean.cont hasPrefix:@"http"]) {
        NSURL *url = [NSURL URLWithString:msgBean.cont];
        detalCtrl = [[WSReportFormController alloc] initWithURL:url];
    } else {
//        detalCtrl = [[WSDetalViewController alloc]init];
//        ((WSDetalViewController *)detalCtrl).model = self.sourceArray[indexPath.row] ;
//        ((WSDetalViewController *)detalCtrl).msgBean = self.MsgArray;
        WSMsgsBean_msg * model = self.sourceArray[indexPath.row] ;
        WinJSBridgeViewController *detalCtrlVC = [[WinJSBridgeViewController alloc] init];
        detalCtrlVC.externalOpenUrl = self.currentFuncs.opt.jumpUrlLink;
        detalCtrlVC.externalInfoDic = @{Win_JSBridge_URL_Replacing_MSGID_Mark :model.Id};
        detalCtrl = detalCtrlVC;
        self.isBackRefresh = YES;

    }
    
    detalCtrl.hidesBottomBarWhenPushed = YES;
    
    if (INTERFACE_IS_PAD) {
        for (UIViewController *vc in self.childViewControllers) {
            if ([vc isKindOfClass:[WSDetalViewController class]]) {
                [vc.view removeAllSubviews];
                [vc removeFromParentViewController];
                break;
            }
        }
        //      SFA-23516  donghong
        if([detalCtrl isKindOfClass:[WSDetalViewController class]])
        {
            WSMsgsBean_msg* msg =  self.sourceArray[indexPath.row];
            if (![msg.isread isEqualToString:@"1"]) {
                [self setWorkInfoWithHomePage:YES];
                [self changeTitleButton];
            }
        }
        NSString *isHomePageShow = @"0";
        if (self.subFuncsBeanNeedShow && [self.sourceArray count] == 1)
            isHomePageShow = @"1";
        detalCtrl.view.frame = CGRectMake(20, BANNERVIEW_HEIGHT + 20 + 64, BROWSERVC_WIDTH - kLeftVieWidth - 40, self.view.height - BANNERVIEW_HEIGHT - 40  -64 );
        detalCtrl.ownParentViewController = self ;
        [self.view addSubview:detalCtrl.view];
        [self addChildViewController:detalCtrl];
        
    }else{
        [[self getNavigationController] pushViewController:detalCtrl animated:YES];
        
    }
    
    
//    [self markAsReadedByMsg:msgBean];
    
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    WSMsgsBean_msg *fliter_msg = [self filterIs_SlideMessage];
    if (!(fliter_msg && [fliter_msg.headrail isEqualToString:@"1"]))
        view.tintColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:236/255.0 alpha:1];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (INTERFACE_IS_PHONE) {
        CGFloat height = INTERFACE_IS_PAD ? 200 : 130;
        WSServerIPList *svip =  [WSAppData getObjectbyKey:SERVERURL];
        WSServerIPController *serverIP =[svip.serverIPArray firstObject];
        WSMsgsBean_msg *msg_model = [self filterIs_SlideMessage];
        NSString *stringURL = nil;
        
        if ([msg_model.headrail isEqualToString:@"1"])
        {
            NSArray *urlArray = [msg_model.url componentsSeparatedByString:@","];
            stringURL = [urlArray firstObject];
            stringURL = [NSString stringWithFormat:@"%@%@",[serverIP ServerIPString],stringURL];
            stringURL = [stringURL stringByReplacingOccurrencesOfString:@"//" withString:@"/"];//字符转换
            UIImageView *headView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, height)];
            headView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedImage:)];
            [headView addGestureRecognizer:tapGesture];
            [[WSRequestHelper shareInstance] downloadImageWithUrl:stringURL imageView:headView];
            
            return headView;
        }
        if(self.sourceArray.count > 0)
        {
            return self.searchBar;
        }
    }
    //    else{
    //        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.tableView.width, 44)];
    //        titleLabel.backgroundColor = [UIColor whiteColor];
    //        titleLabel.text = @"最新公告";
    //        titleLabel.font = FONT_SIZE_PINGFANG_REGULAR(24);
    //        titleLabel.textAlignment = NSTextAlignmentCenter;
    //        titleLabel.contentMode = UIViewContentModeCenter;
    //        titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    //        return titleLabel;
    //    }
    
    return nil;
}
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//    UIButton *refresh = [UIButton buttonWithType:UIButtonTypeCustom];
//    refresh.frame = CGRectMake((tableView.width - 67)/2.0 , (tableView.height - 35)/2.0, 67, 35);
//    [refresh addTarget:self action:@selector(updataInfo) forControlEvents:UIControlEventTouchUpInside];
//
//    UIImage *image = [UIImage imageNamed:@"more_refresh"];
//    [refresh setImage:image forState:UIControlStateNormal];
//    //[refresh setBackgroundImage:[UIImage scaleImage:image toSize:CGSizeMake(67, 35)] forState:UIControlStateNormal];
//   //[refresh setImage:[UIImage scaleImage:image toSize:CGSizeMake(67, 35)] forState:UIControlStateNormal];
//    return refresh;
//
//}
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//
//    return 70.0;
//}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    donghong MSTD-7694 没有公告信息 隐藏搜索
    if (INTERFACE_IS_PHONE && self.sourceArray.count > 0) {
        return [self getTableViewHeaderViewHeight];
    }
    return 0.0f;
    
}

- (void)topBannerCycleScrollView:(WSTopBannerCycleScrollView *)topBanner didSlectItem:(WSMsgsBean_msg *)msgBean{
    
    for (UIViewController *vc in self.childViewControllers) {
        if ([vc isKindOfClass:[WSDetalViewController class]]) {
            [vc.view removeAllSubviews];
            [vc removeFromParentViewController];
            break;
        }
    }
    WSDetalViewController *detalCtr = [[WSDetalViewController alloc]init];
    detalCtr.ownParentViewController = self;
    detalCtr.model = msgBean;
    WSBaseMsgTypeObject *typeObj = [[WSBaseMsgTypeTable sharedTable] queryBaseMsgTypeById:msgBean.pid];
    WSMsgsBean *msgTypeBean = [[WSMsgsBean alloc] initWithObject:typeObj];
    if (msgTypeBean) {
        detalCtr.msgBean = [NSMutableArray arrayWithObject:msgTypeBean];
    }
    detalCtr.hidesBottomBarWhenPushed = YES;
    detalCtr.view.frame = CGRectMake(20, BANNERVIEW_HEIGHT + 20 + 64, BROWSERVC_WIDTH - kLeftVieWidth - 40, self.view.height - BANNERVIEW_HEIGHT - 40  -64 );
    [self.view addSubview:detalCtr.view];
    [self addChildViewController:detalCtr];
    
}

- (void)markAsReadedByMsg:(WSMsgsBean_msg *)msg {
    if (!msg || !msg.s || !msg.Id) {
        return;
    }
    
    if (![msg.isread isEqualToString:@"1"]) {
        [[WSBaseMsgTable sharedTable] updateWithNames:@[@"isread"] values:@[@"1"] whereName:@[@"_id"] whereValue:@[msg.Id]];
    }
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@#%@#%@", msg.s, msg.Id,[WSAppData getObjectbyKey:APPDATA_EMPID]];
    NSDictionary *dic = [user dictionaryForKey:kWSMessageDomainName];

    NSNumber *number = [dic objectForKey:key];
    if (number == nil || ![number boolValue]) {
        [self sendReadedMessageRequestByMsg:msg];
    }
    
    NSNumber *value = [NSNumber numberWithBool:YES];
    NSMutableDictionary *dicInfo = [NSMutableDictionary dictionaryWithDictionary:dic];
    
    if (value) {
        [dicInfo setObject:value forKey:key];
    }
    
    if (dicInfo) {
        [user setObject:dicInfo forKey:kWSMessageDomainName];
    }
    
    [user synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MAIN_VC_NEED_UPDATE_BADGE_NOTIFY object:nil];
}

- (void)sendReadedMessageRequestByMsg:(WSMsgsBean_msg *)msg {
    if (!msg || !msg.s || !msg.Id) {
        return;
    }

    NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *bizDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    NSString *md5 = [NSString md5:[NSString stringWithFormat:@"%@%@%@%@",empId,bizDate, msg.s, msg.Id]];
    
    NSString  *strData = [WSJSONBuilder  buildSendRedMessageWithMsgId:msg.Id andNotifyName:notifyID andMD5:md5];
    // 先插入数据库
    [self insertUploadData:strData URL:URL_UPLOAD MD5:md5 IsPhoto:NO NotifyName:notifyID];
    
    // 再上传数据，后更新upload_flag
    WSRequestHelper *uploadHandler = [WSRequestHelper shareInstance];
    [uploadHandler sendReadedMessageRequestWithMsgId:msg.Id andNotifyName:notifyID andMD5:md5];
}


#pragma mark - insert off line table
-(void) insertUploadData:(NSString*)aPostDate
                     URL:(NSString*)aUrl
                     MD5:(NSString*)aMd5
                 IsPhoto:(BOOL)aIsPhoto
              NotifyName:(NSString*)aNotifyName

{
    if (!aNotifyName) {
        LogError(@"离线上传数据库插入未执行，原因：Notiy为空");
        return;
    }
    if ([aNotifyName isKindOfClass:[NSNull class]]) {
        LogError(@"离线上传数据库插入未执行，原因：Notiy为NULL");
        return;
    }
    
    NSMutableArray* l_Values = [[NSMutableArray alloc]init];
    //person
    [l_Values addObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]]];
    //date
    [l_Values addObject:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    //upload flag
    [l_Values addObject:@"0"];
    //upload data
    [l_Values addObject:aPostDate];
    //url
    [l_Values addObject:aUrl];
    //md5
    [l_Values addObject:aMd5];
    //isphoto
    if(aIsPhoto)
    {
        [l_Values addObject:@"1"];
        
    }else
        [l_Values addObject:@"0"];
    
    [l_Values addObject:aNotifyName];
    
    // 为保存向前兼容，不修改其它调用此方法的类，将之前使用此方法保存的数据都定为 D 类型
    [l_Values addObject:@"D"];
    
    //图片类型的存储图片路径，其他类型不需要使用，保持兼容，存个null
    [l_Values addObject:[NSNull null]];
    
    [[WSOffLineUploadTable sharedTable] insertWithArgumentsValue:l_Values];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self queryMsgWith:searchBar.text];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    [self queryMsgWith:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    [self queryMsgWith:searchBar.text];
}

-(void)queryMsgWith:(NSString *)searchText
{
    self.selectMsgsBean = nil;
    if (searchText.length > 0)
    {
        NSString *pinyin = [NSString stringWithFormat:@"*%@*", searchText];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.title contains[cd] %@ || SELF.pinyin like[cd] %@", searchText, pinyin];
        self.sourceArray = [self.allMsg_msgArray filteredArrayUsingPredicate:predicate].mutableCopy;
    }
    else
        self.sourceArray = self.allMsg_msgArray.mutableCopy;
    
    [self changeTileButtonState];
    [self.tableView reloadData];
}

- (WSMsgsBean_msg *)filterIs_SlideMessage
{
    for (WSMsgsBean_msg *msg_model in self.sourceArray)
    {
        if ([msg_model.headrail isEqualToString:@"1"])
            return msg_model;
    }
    return nil;
}

- (void)tappedImage:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *view = [gestureRecognizer view];
    if ([view isKindOfClass:[UIImageView class]])
    {
        WSDetalViewController * detalCtrl = [[WSDetalViewController alloc]init];
        detalCtrl.model = [self filterIs_SlideMessage] ;
        detalCtrl.msgBean = self.MsgArray;
        detalCtrl.hidesBottomBarWhenPushed = YES;
        [[self getNavigationController] pushViewController:detalCtrl animated:YES];
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (!self.isFirstDrag)
    {
        self.isFirstDrag = YES;
        [self.tableView reloadData];
    }
}

#pragma mark - 发布公告响应方法 sender:按键
- (void)releaseNoticeResponse:(id)sender
{
    if(self.currentFuncs.opt.isJumpCallPlan)
    {
        WSFuncsBeanArray *funcsBeanArray = [WSAppData getObjectbyKey:FUNCS];
        WSFuncsBean *jumpFuncBean = [funcsBeanArray getFuncsBeanFromAllFucsWithFC:self.currentFuncs.opt.isJumpCallPlan];
        if (jumpFuncBean)
        {
            NSString *className = [WSPlistHelper valueForKey:jumpFuncBean.fv withPlistName:kControllerMappingFileName];
            WCBaseViewController *vc = [[NSClassFromString(className) alloc] initWithFuncs:jumpFuncBean];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            self.isBackRefresh = YES;
        }
    }
}

@end

@implementation WSMyMsgViewController(Tools)
#pragma mark - 获取表视图头部高度方法
- (CGFloat)getTableViewHeaderViewHeight
{
    WSMsgsBean_msg *fliter_msg = [self filterIs_SlideMessage];
    if (fliter_msg && [fliter_msg.headrail isEqualToString:@"1"] && [fliter_msg.url length] > 0)
    {
        CGFloat height = INTERFACE_IS_PAD ? 200 : 130;
        return height;
    }
    
    if (self.isFirstDrag)
        return 44;
    
    return 0;
}

#pragma mark - 增加导航栏右按钮方法
- (void)addRightBarButtonItem
{
    if(self.currentFuncs.opt.isJumpCallPlan)
    {
        UIBarButtonItem *buttonItem = [self barButtonItemImage:@"title-bar_create_icon" target:self action:@selector(releaseNoticeResponse:)];
        if (self.ownParentViewController)
            self.ownParentViewController.navigationItem.rightBarButtonItem = buttonItem;
        else
            self.navigationItem.rightBarButtonItem = buttonItem;
    }
}

#pragma mark - 请求公告方法
- (void)requestMsg
{
    [self.tableView.mj_header beginRefreshing];
}


@end
//=======================================================================================================================================================



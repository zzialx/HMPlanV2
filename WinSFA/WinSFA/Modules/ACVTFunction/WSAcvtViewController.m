//  AcvtViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "UIDevice+Addtional.h"
#import "UINavigationController+Additions.h"
#import "NSArray+SQL.h"
#import "UIImage+Eemporary.h"
#import "WSAcvtViewController.h"
#import "WSAcvtBean.h"
#import "WSAcvtBean_qst.h"
#import "WSAcvtBean_qst_opt.h"
#import "WSFuncsBean.h"
#import "WSAppData.h"
#import "WSCurrentTime.h"
#import "WSFacTable.h"
#import "WSRequestHelper.h"
#import "WSJSONBuilder.h"
#import "WSEmpAcvtDisArray.h"
#import "WSEmpAcvtDis.h"
#import "WSStoreAcvtDisBean.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "widget/WSWidget.h"
#import "WSAcvtShowBeanArray.h"
#import "WSAcvtShowBean.h"
#import "DataGridComponent.h"
#import "WSAcvtDataGridComponentView.h"
#import "WSTableItemsArray.h"
#import "WSAcvtDataGridComponentDataSource.h"
#import "WSStoreBean_prod.h"
#import "WSProdBean.h"
#import "WSAcvtDataGridComponentService.h"
#import "WSValidateData.h"
#import "WSImagePathTable.h"
#import "WSDictBean.h"
#import "WSNavigationBar.h"
#import "WSPhotoTypeView.h"
#import "WSPhotoTypeArrayItem.h"
#import "WSOutPlanStoreBean.h"
#import "WSQRModule.h"
#import "WSVisitStoreActionTable.h"
#import "WSReportFormController.h"
#import "WSEmbeddedAcvtViewController.h"
#import "WSRequestHelper.h"
#import "WSAcvtView.h"
#import "WSAcvtDisBean.h"
#import "WSAcvtDisQstBean.h"
#import "WSInterAction.h"
#import "WSAcvtModel.h"
#import "WSDataSourceManager.h"
#import "WidgetConstant.h"
#import "WSVerificationCodePanel.h"
#import "WSAcvtScrollView.h"
#import "WSDPListWithEmbedQAPanel.h"
#import "WSPhotoViewPanel.h"
#import "WSAcvtDataGridViewPanel.h"
#import "I_W_BuildInfo.h"
#import "WSAcvtDataGridHttpService.h"
#import "WSSelectInformationPanel.h"
#import "WSServiceDispatcher.h"
#import "WSLuaExecutorManager.h"
#import "I_Lua_Executor_Delegate.h"
#import "WSFptTable.h"
#import "WSPhotoTypeItem.h"
#import "WSSelectInfoPanelDataSource.h"
#import "WSEnvrionment.h"
#import "WSAcvtService.h"
#import "WSAcvtManagementObj.h"
#import "WSTextFiledWithRangePanel.h"
#import "WSHidedMapPanel.h"
#import "WSMapPanel.h"
#import "WSAddNewStoreModel.h"
#import "WSWorkFlowViewController.h"
#import "WSStoredDictDisBean.h"
#import "SuperWorkSpaceViewController.h"
#import "WSStoreDataProcessService.h"
#import "BlockTextPromptAlertView.h"
#import "WSTAAcvtDataGridViewPanel.h"
#import "WSTAAcvtDataGridComponentDataSource.h"
#import "WSEnterStoreAcvtViewController.h"
#import "WSLeaveStoreAcvtViewController.h"
#import "WSScanListPanel.h"
#import "WSPopViewController.h"
#import "I_NextStepContentView.h"
#import "WSSplitViewController.h"
#import "WSSignaturepanel.h"
#import "WSBaseStoreTable.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSMappingObject.h"
#import "WSSubempstoreBeanArray.h"
#import "WSMultiSelectAndSearchViewController.h"
#import "WSNavigationBar.h"
#import "WSAcvtQstDisItem.h"
#import "WSBaseAcvtDBService.h"
#import "WSDimensMacros.h"
#import "I_W_DisplayValue.h"
#import "WSVisitStoreAcvtDataTable.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSBaseStoreAcvtDBService.h"
#import "WSImageViewPanel.h"
#import "WSBaseStoreDBService.h"
#import "WSAcvtDisLogicService.h"
#import "WSPhotoLogicService.h"
#import "WSANNestedAcvtPanel.h"
#import "WSStoreInfoMapViewController.h"
#import "WSInoutStoreTable.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "WSFuncsBeanFilterLogicService.h"
#import "WSMV_LISTViewController.h"
#import "WSAcvtListDataItem.h"
#import "WSScrollLabelView.h"
#import "WSBaseDictsDBService.h"
#import "WSAcvtSideView.h"
#import "WSAcvtTabCollectionView.h"
#import "WSNextStepFuncsViewController.h"
#import "WSAcvtBatchUploadView.h"
#import "WSLocationManager.h"
#import "YYModel.h"
#import "WSVisitStoreAcvtTable.h"
#import "WSAddNewStoreViewController.h"
#import "WSEMSDKManager.h"
#import "WSStatisticsManager.h"
#import "WSAcvtViewControllerTools.h"
#import "WSPaiPaiManager.h"
#import "WSBaseStoreAcvtDisTable.h"
#import "WSBaseAcvtTable.h"
#import "WSBaseAcvtQstOptTable.h"
#import "WSBaseAcvtQstTable.h"
#import "WSAttanceViewModel.h"
#import "WSAcvtViewController+Tools.h"

#define kTitleWidth                     240
#define kTitleHeight                    25
#define kAdditionalWidth                20
#define SCAN_TEXT_TAG                   102
#define VIDEO_PICKER_TAG                103
#define DATA_TEXT_TAG                   104
#define TextLengthMax                   19
#define kDescriptionLabelMaxHeight      200
#define kScanButtonBaseTag              10000
#define kAcvtQstDeleteButtonWidth       (INTERFACE_IS_PAD ? 300.0f : 200.0f)
#define kAcvtQstDeleteButtonHeight      (INTERFACE_IS_PAD ?  30.0f : 25.0f)
#define NOTIFY_STOREINFO                @"storeInfo"
#define ACVT_LUA_FUNTION_DIALOG_CONFIRM @"function dialogConfirm("
#define ACVT_LUA_FUNTION_DIALOG_CANCEL  @"function dialogCancle("
#define K_REAL_TIME_REFRESH_ACVT_DATA   @"real_time_refresh_acvt_data"
//==========================================================================================================================================================================

#pragma mark - 调查问卷视图管理器 延展(内部)
@interface WSAcvtViewController () <WSSmsControllerDelegate, I_Lua_Executor_Delegate,WSPopViewControllerDelegate, I_NextStepContentView, AddNewStoreSelectDelegate> {

    BOOL firstLoad;                         //是否第一次载入
    BOOL isDatasChanged;                    //是否数据有变化
    BOOL isHomeBackAction;                  //是否返回主页动作
    UIButton *buttonHasBeenClickedJustNow;  //按钮尽在当时已经被按过
    UITextField *currentClickText;          //当前被选中的文本
    BOOL isHideUploadButton;
    BOOL isNeedLayout;                      //是否需要放置
    BOOL isObserverTBFrameChange;
    WSLuaExecutorManager  *wsLuaExecutor;
    BOOL isUpdateCalendarDataFromLua;       //是否是脚本调用的update方法
}

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, assign) BOOL isRequiredSendSMS;
@property (nonatomic, assign) BOOL qstTypIsDMNeedRequestFromServer;
@property (nonatomic, copy) NSString *dsForQstTypeIsDM;
@property (nonatomic, assign) BOOL acvtHasGrid;                             //调查问卷中有表格
@property (nonatomic, assign) BOOL sumbitWithReason;
@property (nonatomic, strong) BlockTextPromptAlertView *delReasonAlert;
@property (nonatomic, assign) BOOL isLoadForRealtimeRequest;
@property (nonatomic, strong) WSHosBean *hosBean;
@property (nonatomic, strong) NSMutableArray *barButtonItems;
@property (nonatomic, strong) WSAcvtScrollView *scrollView;
@property (nonatomic, strong) WSBlueToothListActionSheet *actionSheet;      //搜索出来的蓝牙列表
@property (nonatomic, weak) SEPrinterManager *manager;                      //蓝牙打印
@property (nonatomic, strong) WSAcvtSideView *sideView;                     //右侧边栏
@property (nonatomic, copy) NSString *fptDbDeleteWithMd5;                   //设置值为1 保存问卷时 fpttable中根据md5删除数据 为nil时 走老逻辑
@property (nonatomic, strong) NSMutableDictionary *customPhotoNameDict;     //定制照片名称字典
@property (nonatomic, strong) NSMutableArray *acvtDataGridViewPanelsMArray; //表格视图数组
@property (nonatomic, strong) WSAcvtViewControllerTools *vcTools;           //视图管理器工具

@end
//===========================================================================================================================================================================

#pragma mark - 调查问卷视图管理器
@implementation WSAcvtViewController
@synthesize m_height;
@synthesize isValueChange = _isValueChange;
@synthesize currentInputTextField;

#pragma mark - 实现backPromptWithFuncs:saveBlock:uploadBlock:giveupBlock:方法
+ (void)backPromptWithFuncs:(WSFuncsBean *)funcs saveBlock:(void (^)())saveblock uploadBlock:(void (^)())uploadBlock giveupBlock:(void (^)())giveupBlock {
    
    NSString *message = NSLocalizedString(@"back_confirm2", nil);
    if (funcs.opt.isSaveData_back && funcs.opt.isSaveData_back.length > 0) {
        message = NSLocalizedString(@"back_save", nil);
    }
    
    BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:message];
    [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:nil];
    
    if (funcs.opt.isSaveData_back && funcs.opt.isSaveData_back.length > 0) {
        [alert addButtonWithTitle:NSLocalizedString(@"save_label", nil) block:^{
            saveblock();
        }];
    }
    else {
        [alert addButtonWithTitle:NSLocalizedString(@"upload_label", nil) block:^{
            uploadBlock();
        }];
    }
    [alert addButtonWithTitle:NSLocalizedString(@"give_up", nil) block:^{
        giveupBlock();
    }];
    [alert show];
}

#pragma mark - 实现initWithAcvt:Funcs:Store:方法
- (id)initWithAcvt:(WSAcvtBean *)anAcvt Funcs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store {
    
    return [self initWithAcvt:anAcvt Funcs:funcs Store:store SubEmpId:nil];
}

#pragma mark - 实现initWithAcvt:Funcs:Store:SubEmpId:方法
- (id)initWithAcvt:(WSAcvtBean *)anAcvt Funcs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store SubEmpId:(NSString *)subEmpId {
    
    self = [super initWithFuncs:funcs];
    if (self) {
        
        isLoaded = NO;
        
        self.m_currentAcvt = anAcvt;
        self.currentStore = store;
        self.submitempid = subEmpId;
        
        [self initAcvtModel];
    }
    return self;
}

#pragma mark - 实现initWithAcvt:Funcs:Store:hosBean:方法
- (id)initWithAcvt:(WSAcvtBean *)anAcvt Funcs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store hosBean:(WSHosBean *)hosBean {
    
    self = [super initWithFuncs:funcs];
    if (self) {
        
        isLoaded = NO;
        
        self.m_currentAcvt = anAcvt;
        self.currentStore = store;
        self.hosBean = hosBean;
        
        [self initAcvtModel];
    }
    return self;
}

#pragma mark - 实现initWithAcvt:Funcs:Store:acvtNewStore:方法
- (id)initWithAcvt:(WSAcvtBean *)anAcvt Funcs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store acvtNewStore:(WSStoreBean *)acvtNewStore {
    
    self = [super initWithFuncs:funcs];
    if (self) {
        
        isLoaded = NO;
        
        self.m_currentAcvt = anAcvt;
        self.currentStore = store;
        self.currentNewStore = acvtNewStore;
        
        [self initAcvtModel];
        
        if (self.currentNewStore) {
            [self generateMd5];
        }
    }
    return self;
}

#pragma mark - 实现initWithAcvt:Funcs:Store:Section:方法
- (id)initWithAcvt:(WSAcvtBean*)anAcvt Funcs:(WSFuncsBean*)funcs Store:(WSStoreBean*)store Section:(int)section {
    
    self.mySection = section;
    return [self initWithAcvt:anAcvt Funcs:funcs Store:store];
}

#pragma mark - 实现initWithAcvt:Funcs:Store:md5:方法
- (id)initWithAcvt:(WSAcvtBean*)anAcvt Funcs:(WSFuncsBean*)funcs Store:(WSStoreBean*)store md5:(NSString *)acvtMd5 {
    
    return [self initWithAcvt:anAcvt Funcs:funcs Store:store md5:acvtMd5 isFromRealTimeData:NO];
}

#pragma mark - 实现initWithAcvt:Funcs:Store:md5:isFromRealTimeData:方法
- (id)initWithAcvt:(WSAcvtBean *)anAcvt Funcs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store md5:(NSString *)acvtMd5 isFromRealTimeData:(BOOL)isFromRealTimeData {
    
    return [self initWithAcvt:anAcvt Funcs:funcs Store:store md5:acvtMd5 isFromRealTimeData:isFromRealTimeData SubEmpId:nil];
}

#pragma mark - 实现initWithAcvt:Funcs:Store:md5:isFromRealTimeData:SubEmpId:方法
- (id)initWithAcvt:(WSAcvtBean *)anAcvt Funcs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store md5:(NSString *)acvtMd5 isFromRealTimeData:(BOOL)isFromRealTimeData SubEmpId:(NSString *)subEmpId {
    
    if (!anAcvt) {
        return nil;
    }
    
    self = [super initWithFuncs:funcs];
    if (self) {
        
        isLoaded = NO;
        
        if (!acvtMd5) {
            self.isNewAddAcvt = YES;
        }
        
        self.m_currentAcvt = anAcvt;
        self.currentStore = store;
        self.updateGenID = acvtMd5;
        self.md5 = acvtMd5;

        if (self.currentStore && self.currentStore.srid && self.currentStore.srid.length > 0) {
            self.submitempid = self.currentStore.srid;
        }
        
        if (subEmpId && subEmpId.length > 0) {
            self.submitempid = subEmpId;
        }
        
        [self initAcvtModel];
        ((WSAcvtModel *)self.model).isFromRealTimeData = isFromRealTimeData;
    }
    return self;
}

#pragma mark - 实现initWithAcvt:Funcs:subEmpStore:方法
- (id)initWithAcvt:(WSAcvtBean *)anAcvt Funcs:(WSFuncsBean *)funcs subEmpStore:(WSSubempstoreBean *)store {
    
    self = [super initWithFuncs:funcs];
    if (self) {
        
        isLoaded = NO;
        
        self.m_currentAcvt = anAcvt;
        self.currentSubEmpStore = store;
        
        [self initAcvtModel];
    }
    return self;
}

#pragma mark - 重写loadView方法
- (void)loadView {
    
    [super loadView];
    
    _isLoadForRealtimeRequest = YES;
    BOOL isNewAcvt = (self.isNewAddAcvt && !(self.updateGenID && [self.updateGenID length] > 0)); //如果是新增问卷则没有编辑按钮
    if ([[[(WSAcvtModel *)self.model currentAcvtBean] isBlock] isEqualToString:@"3"] || [(WSAcvtModel *)self.model isFromRealTimeData] || isNewAcvt) {
        _isLoadForRealtimeRequest = NO;
    }
}

#pragma mark - 重写viewDidLoad方法
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self addAppEnterBackgroundNotification];
    
    if ([self.acvtNameMainTitle length ] > 0) {
        self.title = self.acvtNameMainTitle;
    }
    else if (self.isShowStoreName) {
        self.title = self.currentStore.name;
    }
    else if (!self.title) {
        self.title = ((WSAcvtModel *)self.model).currentAcvtBean.acvtName;
    }
    
    [self.model loadDataFromDataBase];
    if ([self.model.currentFuncs.opt.isUseNewId isEqualToString:@"E"] && !self.updateGenID) {
        self.updateGenID = self.model.md5;
    }
    
    [self uploadVisitActionWithAcvtNoData];
    [self uploadVisitActionWhenReadonly];
    
    self.model.ownAcvtViewController = self;
    self.uploadBtnEnable = YES;
    self.qstTypIsDMNeedRequestFromServer = NO;
    self.mImagePicker.delegate = self;
    
    firstLoad = YES;
    isUpdateCalendarDataFromLua = NO;
    
    if ([self.currentFuncs.unredo integerValue] == 1) {
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 25)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [label setText:NSLocalizedString(@"disable_modify_tip", nil)];
        [label setBackgroundColor:[UIColor colorWithHexString:@"#EAEAEA"]];
        [label setTextColor:[UIColor grayColor]];
        [label setFont:[UIFont systemFontOfSize:13]];
        [self.view addSubview:label];
        
        self.y_point = label.height;
    }
    
    NSString *redisData = [WSAppData getObjectbyKey:REDIS_DATA];
    if ([redisData length] > 0) {
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 25)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [label setText:[NSString stringWithFormat:@"   %@", redisData]];
        [label setBackgroundColor:[UIColor colorWithHexString:@"#EAEAEA"]];
        [label setTextColor:[UIColor grayColor]];
        [label setFont:[UIFont systemFontOfSize:13]];
        [self.view addSubview:label];
        
        self.y_point = label.height;
    }
    
    for (WSAcvtBean_qst *qst in _m_currentAcvt.qsts) {
        
        if ([qst.qstType isEqualToString:QST_TYPE_TB]) {
            _acvtHasGrid = YES;
            break;
        }
    }
    
    if (self.loadAcvtViewFormViewDidLoad) {
        [self loadAcvtView];
    }
}

#pragma mark - 重写viewWillAppear:方法
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self setupScrollNavTitleView];
    
    if (_scrollView) {
        [self setSteadyTableHeadViewHiddenOrNotWithScrollView:_scrollView];
    }
    
    if (self.acvtview) {
        [self.acvtview checkAndExecuteAcvtLuaScriptEvery];
    }
    
    if ((_acvtHasGrid || [_m_currentAcvt.qsts count] >= 20) && firstLoad ) { //当调查问卷嵌套表格的时候因加载数据较多 所以加此提示
        NSString *AccessInforString = NSLocalizedString(@"pull_to_refresh_refreshing_label", nil);
        self.hud = [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:AccessInforString tips:nil tapTarget:self action:nil];
    }
    
    self.firstEnterView = YES;
    [self reloadAddAllNavBBI];
}

#pragma mark - 重写viewDidAppear:方法
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (firstLoad) {
        
        BOOL isDatasFromRealTime = NO;
        if (!((WSAcvtModel *)self.model).isSubAcvt) {
            
            if ([self.currentFuncs.opt.sendRequest isEqualToString:@"remote"]) {
                isDatasFromRealTime = [self realTimeRefreshAcvtDatas:nil];
            }
            
            if ([self.currentFuncs.opt.sendRequest isEqualToString:@"remoteAdd"] && _isNewAddAcvt) {
                isDatasFromRealTime = [self realTimeRefreshAcvtDatas:nil];
            }
        }
        
        if (!isDatasFromRealTime) {
            [self setupViews];
        }
    }
    else {
        
        [self setupViews];
        [self.acvtview viewWillAppear];
    }
    
    if (!self.firstEnterView) {
        [self reloadAddAllNavBBI];
    }
}

#pragma mark - 重写viewWillDisappear:方法
- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    [serviceDispatcher setDispatcherDelegate:nil];
    serviceDispatcher = nil;
    [self clearAllNavBBI];
}

- (void)loadAcvtView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (!self.qstTypIsDMNeedRequestFromServer) {
        
        if (isLoaded == NO) {
            
            int height = 0;
            _scrollView = [[WSAcvtScrollView alloc] initWithFrame:CGRectMake(self.view.origin.x, self.y_point + height, self.view.width, self.view.height - self.y_point - height) andAcvtBean:_m_currentAcvt];
            _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            self.acvtview = _scrollView.acvtView;
            [self.acvtview buildDisplayContent];
        }
    }
}

#pragma mark - 重写dealloc方法
- (void)dealloc {
    
    [self removeAppEnterBackgroundNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self doRemoveAcvtGridSteadyTableHeadViewWhenBackToParentOrHome];
    [_manager stopScan];
    _manager.delegate = nil;
}

#pragma mark - 获取customPhotoNameDict方法
- (NSMutableDictionary *)customPhotoNameDict {
    
    if (!_customPhotoNameDict) {
        _customPhotoNameDict = [[NSMutableDictionary alloc] init];
    }
    return _customPhotoNameDict;
}

#pragma mark - 获取acvtDataGridViewPanelsMArray方法
- (NSMutableArray *)acvtDataGridViewPanelsMArray {
    
    if (!_acvtDataGridViewPanelsMArray) {
        _acvtDataGridViewPanelsMArray = [[NSMutableArray alloc] init];
    }
    return _acvtDataGridViewPanelsMArray;
}

#pragma mark - 获取vcTools方法
- (WSAcvtViewControllerTools *)vcTools {
    
    if (!_vcTools) {
        _vcTools = [[WSAcvtViewControllerTools alloc] init];
    }
    return _vcTools;
}

#pragma mark - 重写createModel方法<BaseViewController定义 创建模型方法 在父类initWithFuncs中调用>
- (void)createModel {
    
    self.model = [[WSAcvtModel alloc] init];
}

- (void)addGPSData {
  
    for (WSAcvtBean_qst *tmpQst in self.m_currentAcvt.qsts) {
        
        NSString *qstType = tmpQst.qstType;
        if (qstType && ([qstType isEqualToString:QST_TYPE_GF] || [qstType isEqualToString:QST_TYPE_GG])) {
            self.m_othersDic = [[WSLocationManager getLocationUploadDataWithLocation:self.location andAddress:self.locationDescribe.detailAddress] mutableCopy];
            break;
        }
    }
}

- (void)saveAcvtDatasToDBToPop {
    
    self.fptDbDeleteWithMd5 = @"1";
    [self saveAcvtDatasToDB];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *genId;
    if ([userDefaults objectForKey:SAVEACVTDATA]) {
        genId = [NSMutableDictionary dictionaryWithDictionary:[userDefaults objectForKey:SAVEACVTDATA]];
    }
    else {
        genId = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    
    if (![genId objectForKey:self.model.md5]) {
        [genId setObject:self.model.md5 forKey:self.model.md5];
    }
    
    [self uploadPhotosForAcvtView:NO];
    
    [userDefaults setObject:genId forKey:SAVEACVTDATA];
    [userDefaults synchronize];
    
    [self backAction];
}

- (void)initANOfUploadDatasBeforeUpload {
    
    WSAcvtModel *acvtModel = (WSAcvtModel *)self.model;
    if (acvtModel.anJsonDataDictionary && [acvtModel.anJsonDataDictionary count] > 0) {
        
        NSArray *jsonDataKeys = [acvtModel.anJsonDataDictionary allKeys];
        NSMutableArray *anArray = [NSMutableArray arrayWithCapacity:[jsonDataKeys count]];
        for (WSAcvtBean_qst *ab_qst in acvtModel.currentAcvtBean.qsts) {
            
            NSString *key = [NSString stringWithFormat:@"%@%@", QST_TYPE_AN, ab_qst.acvtNestedId];
            if ( [ab_qst.qstType isEqualToString:QST_TYPE_AN] && [jsonDataKeys containsObject:key] && ![ab_qst.displayMode containsString:@"showInMain"]) {
                
                id  subJsonDataDic = [acvtModel.anJsonDataDictionary objectForKey:key];
                if ([subJsonDataDic isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dic = [NSDictionary dictionaryWithObject:[[subJsonDataDic allValues] JSONString] forKey:[NSString stringWithFormat:@"%@%@", QST_TYPE_AN, ab_qst.acvtQstId]];
                    [anArray addObject:dic];
                }
            }
        }
        
        if (!self.m_othersDic) {
            self.m_othersDic = [NSMutableDictionary dictionaryWithCapacity:1];
        }
        [self.m_othersDic setValue:anArray forKey:QST_TYPE_AN];
    }
}

#pragma mark - 上传数据完成回调通知方法
- (void)uploadDatasFinish:(NSNotification *)notification {
    
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notification.name object:nil];
    
    NSError *error = [[notification userInfo] objectForKey:ERROR];
    if (error) {
        
        if (error.userInfo) {
            
            NSString *tip = [error.userInfo objectForKey:@"NSLocalizedDescription"];
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:@"" tips:tip tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        
            [self p_noNetAndNetErrorUploadTrax];
        }
        return;
    }
    
    NSString *responseString = [[notification userInfo] objectForKey:DATAS];
    NSDictionary *responseDictonary = [responseString objectFromJSONString];
    NSString *result = [responseDictonary objectForKey:@"result"];
    NSString *msg = [responseDictonary objectForKey:@"message"];
    if (!result || [result isKindOfClass:[NSNull class]]) {
        
        [self resultExecute:msg];
        return;
    }
    
    if ([result isEqualToString:@"0"]) {
        
        if (msg.length == 0) {
            msg = NSLocalizedString(@"fail_upload", nil);
        }
        [self resultExecute:msg];
    }
    else if ([result isEqualToString:@"1"]) {
        
        if (!msg || [msg isKindOfClass:[NSNull class]] || [msg length] == 0) {
            msg = NSLocalizedString(@"upload_success", nil);
            [WSAppData putObject:@[] forKey:APPDATA_LOGIN_REDIRECT_FC];
        }
        
        if ([(WSAcvtModel *)self.model isSynchronizeRequest]) {
            [self uploadPhotos];
        }
        
        [self saveAcvtDatasToDB];
        [self clearDataFromCacheIsUploadComplete:YES];
        
        if ([self.acvtview checkLuaScriptBlock]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RelieveStoreRefreshNotification object:nil];
        }
        
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:msg tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        
        [self restoreAcvtViewOriginalData];
        [self updateAcvtViewGenId];
        
        if ([self.currentFuncs.opt.isUseNewId isEqualToString:@"E"]) {
            [self.acvtview uploadImgID];
        }

        if ([(WSAcvtModel *)self.model isSynchronizeRequest]) {
            [self popToParentOrHome];
        }
    }
    else if ([result isEqualToString:@"2"]) {
        
        if ([(WSAcvtModel *)self.model isSynchronizeRequest]) {
            [self uploadPhotos];
        }
        
        [self saveAcvtDatasToDB];
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:msg tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
    else {
        
        NSDictionary *resultDictonary = [result objectFromJSONString];
        if ([[resultDictonary allKeys] containsObject:@"msg"]) {
            msg = [NSString stringWithFormat:@"%@" ,[resultDictonary objectForKey:@"msg"]];
        }
        else if ([[resultDictonary allKeys] containsObject:@"message"]) {
            msg = [NSString stringWithFormat:@"%@" ,[resultDictonary objectForKey:@"message"]];
        }
        
        NSString *stringFlag = [NSString stringWithFormat:@"%@" ,[resultDictonary objectForKey:@"flag"]];
        if ([stringFlag isEqualToString:@"1"]) {
            
            if (self.currentStore) {
                
                NSString *newStoreId = [NSString stringWithValue:[resultDictonary objectForKey:@"storeId"]];
                if ([newStoreId length] > 0 && (((WSAcvtModel *)self.model).isNewAddAcvt || [self.updateGenID length] > 0)) {
                    
                    WSStoreBean *newStore = [[WSStoreBean alloc] init];
                    newStore.Id = [NSString stringWithFormat:@"%@", newStoreId];
                    self.currentNewStore = newStore;
                    if (self.model) {
                        self.model.currentNewStore = newStore;
                    }
                }
            }
            
            if ([(WSAcvtModel *)self.model isSynchronizeRequest]) {
                [self uploadPhotos];
            }
        
            [self saveAcvtDatasToDB];
            [self clearDataFromCacheIsUploadComplete:YES];
            
            if ([self.acvtview checkLuaScriptBlock]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:RelieveStoreRefreshNotification object:nil];
            }
            
            if (msg == nil || [msg isEqualToString:@""] || [msg isEqualToString:@"null"] || [msg isEqualToString:@"(null)"]) {
                msg = NSLocalizedString(@"upload_success", nil);
            }
            
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:msg tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
                
            WSStoreBean *updateStoreBean = [[WSBaseStoreDBService shareInstance] getStoreWithResponseDic:resultDictonary];
            WSLocationDescribe *lastLocationDescribe = [[WSLocationManager getInstance] lastLocation];
            updateStoreBean = [WSLocationManager calculateDistanceWith:updateStoreBean func:self.currentFuncs locationDescribe:lastLocationDescribe isStoreList:NO];

            NSMutableDictionary *resultMDic = [[NSMutableDictionary alloc] initWithDictionary:resultDictonary];
            if (updateStoreBean.distance.length > 0) {
                [resultMDic setObject:updateStoreBean.distance forKey:@"distance"];
            }
            
            [[WSBaseStoreDBService shareInstance] updateStoreWithDataDic:resultMDic];

            if ( [WSEnvrionment getStoreDataFromDb]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:ModifyStoreInfoNotification object:nil];
            }
            else {
                [self.currentStore modifyStoreInfo:resultDictonary];
            }
            
            [self restoreAcvtViewOriginalData];
            [self updateAcvtViewGenId];
            [self popToParentOrHome];
        }
        else if ([stringFlag isEqualToString:@"3"] || [stringFlag isEqualToString:@"4"]) {
            
            [self resultExecuteUpload:msg flag:stringFlag];
        }else if ([stringFlag isEqualToString:@"-9"]){
            
            if ([(WSAcvtModel *)self.model isSynchronizeRequest]) {
                [self uploadPhotos];
            }
            
            [self saveAcvtDatasToDB];
            
            if ([self.acvtview checkLuaScriptBlock]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:RelieveStoreRefreshNotification object:nil];
            }
            
            if (msg == nil || [msg isEqualToString:@""] || [msg isEqualToString:@"null"] || [msg isEqualToString:@"(null)"]) {
                msg = NSLocalizedString(@"upload_success", nil);
            }
            
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:msg tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
            
            [self restoreAcvtViewOriginalData];
            //取name是请求发出的通知name就是用的m_notify，和更新数据的标识一样的
            NSString * notififyId = notification.name;
            //判断是否需要弹出转发微信弹框
            if ([resultDictonary.allKeys containsObject:@"data"]) {
                NSArray * dataList = [resultDictonary objectForKey:@"data"];
                if ([dataList isKindOfClass:[NSArray class]]&&dataList.count>0) {
                    self.isShowSuggestionOrderAlertView = YES;
                    @weakify_self;
                    [self showInventoryAlertViewWithResultDic:resultDictonary withNotifyId:notififyId complete:^{
                        @strongify_self;
                        self.isShowSuggestionOrderAlertView = NO;
                        [self popToParentOrHome];
                    }];
                }else{
                    [self popToParentOrHome];
                }
            }else{
                [self popToParentOrHome];
            }
        }else {
            
            if ([result isEqualToString:@"0"] || msg == nil || [msg isEqualToString:@""] || [msg isEqualToString:@"null"] || [msg isEqualToString:@"(null)"]) {
                
                NSArray *sameStoreArray = [resultDictonary objectForKey:@"sameStoreList"];
                if (sameStoreArray) {
                    [self showSameStoreList:sameStoreArray];
                    return;
                }
                
                msg = NSLocalizedString(@"fail_upload", nil);
            }
            
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:nil tips:msg tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            //上传失败报错修改状态会引起无法离店，因为助销拜访使用了门店的拜访状态
//            [self updateStoreVisitStaus:VisitStoreNotStart];
        }
    }
}

- (void) popToParentOrHome {
    
    if ([self.currentFuncs.opt.uploadStyle isEqualToString:@"noJump"]) {
        return;
    }
    
    [self doRemoveAcvtGridSteadyTableHeadViewWhenBackToParentOrHome];
    
    if (!self.model.uploadThenNotFinishView) {
        
        if (isHomeBackAction) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else {
            [self backToParent];
        }
    }
}

- (void)setSelectedTabIndex {
    
    if (self.model.uploadThenSelectedTabIndex) {
        
        if (!self.acvtview.isInAcvtTabMode) {
            
            UIViewController *parentController = (UIViewController *)self.parentViewController;
            if (parentController) {
                
                parentController = parentController.parentViewController;
                if ([parentController isKindOfClass:[WSMV_LISTViewController class]]) {
                    
                    WSMV_LISTViewController *listController = (WSMV_LISTViewController *)parentController;
                    [listController setSelectedIndex:self.model.uploadThenSelectedTabIndex - 1];
                }
            }
        }
    }
}

- (void)setPrepareVisitDate:(NSString *)prepareVisitDate {
    
    [super setPrepareVisitDate:prepareVisitDate];
    self.model.prepareVisitDate = prepareVisitDate;
}

- (void)uploadVisitActionWithAcvtNoData {

    if (self.currentFuncs.required && self.currentFuncs.required.length >0  && self.m_currentAcvt.qsts.count < 1) {
        [super uploadVisitAction];
    }
}

- (void)uploadVisitActionWhenReadonly{
    
    if (self.currentFuncs.readonly) {
        [super uploadVisitAction];
    }
}

- (void)setRealParentFuncsCode:(NSString *)realParentFuncsCode {
    
    [super setRealParentFuncsCode:realParentFuncsCode];
    self.model.realParentFuncsCode = realParentFuncsCode;
}

- (void)addAcvtshowBeansToView:(UIView *)aView viewHight:(int *)aHight {
    
    WSAcvtShowBeanArray *acvtShowArray = [WSAppData getObjectbyKey:ACVTSHOW];
    NSMutableString *namesString = [[NSMutableString alloc] initWithCapacity:64];
    if (acvtShowArray != nil) {
        
        int acvtid = [self.m_currentAcvt.acvtId intValue];
        NSArray *acvtshowBeans = [acvtShowArray getAcvtshowbeansWithAcvtid:acvtid];
        for (WSAcvtShowBean *bean in acvtshowBeans) {
            [namesString appendFormat:@"%@\n", bean.iName];
        }
    }
    
    if ([namesString length] > 0) {
        
        UIFont *font = [UIFont systemFontOfSize:UI_Font];
        CGSize size = [namesString ws_sizeWithFont:font constrainedToWidth:self.view.bounds.size.width lineBreakMode:NSLineBreakByWordWrapping];
        
        int xwidth = 0;
        if ([UIDevice isiPad] || [UIDevice isiPadSimulator]) {
            xwidth = 44;
        }
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xwidth, 10, self.view.bounds.size.width, size.height)];
        label.font = [UIFont systemFontOfSize:UI_Font];
        label.numberOfLines = 0;
        label.text = namesString;
        [aView addSubview:label];
        (*aHight) += (label.size.height+5);
        label = nil;
        
        aView.frame = CGRectMake(aView.frame.origin.x, aView.origin.y, aView.frame.size.width, *aHight);
    }
    
    namesString = nil;
}

- (void)addToolBar {
    
    BOOL isShowUploadButton = YES;
    NSMutableArray *readOnlyWidget = [NSMutableArray array];
    for (WSWidget *widget in self.acvtview.widgetArray) {
        
        if ([[widget getReadonly] isEqualToString:@"true"]) {
            [readOnlyWidget addObject:widget];
        }
    }
    
    if (([[self getUploadStyle] length] > 0 && ![[self getUploadStyle] isEqualToString:@"noJump"]) || (readOnlyWidget.count == self.acvtview.widgetArray.count && readOnlyWidget.count > 0)) {
        isShowUploadButton = NO;
    }
    
    if (self.uploadButton == nil && isShowUploadButton) {
        self.uploadButton = [self barButtonItemImage:@"icon_upload" target:self action:@selector(executeUpload)];
    }
    
    NSMutableArray *barButtonItems = [NSMutableArray array];
    BOOL readonly = [self getAcvtReadOnly];
    if (!readonly && isShowUploadButton) {
        
        [barButtonItems addObject:self.uploadButton];
    }

    if ([self.currentFuncs.menuStyle length] > 0) {
        
        WSBaseDictsDBService *dictService = [[WSBaseDictsDBService alloc] init];
        WSDictBean *menuStyleDict = [dictService queryDictWithID:self.currentFuncs.menuStyle];
        if ([menuStyleDict.name isEqualToString:FUNCS_MENUSTYLE_LIST]&&[self.acvtview getTabNameArrayInOrder].count>0) {
            
            UIBarButtonItem *sideButton = [self barButtonItemImage:@"acvtSearchStore" target:self action:@selector(showOrHideSideView)];
            [barButtonItems addObject:sideButton];
        }
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *genId = [userDefaults objectForKey:SAVEACVTDATA];
    if ([genId objectForKey:self.model.md5]) {
        
        UIBarButtonItem *sideButton = [self barButtonItemImage:@"icon_delete" target:self action:@selector(deleteButtonClick)];
        [barButtonItems addObject:sideButton];
    }
    
    if (barButtonItems.count<1) {
        return;
    }
    
    if (self.uploadBtnHidden) {
        [barButtonItems removeObjectAtIndex:0];
    }
    
    [self setRightBarButtonItems:barButtonItems];
    
    self.barButtonItems = barButtonItems;
    
    if ((self.m_currentAcvt.isReadonly != nil && self.m_currentAcvt.isReadonly.integerValue == 1) || (self.m_currentAcvt.parentReadonly != nil && self.m_currentAcvt.parentReadonly.integerValue == 1)) {
        [self setRightBarButtonItems:nil];
    }

    self.uploadButton.enabled = self.uploadBtnEnable;
}

- (void)setRightBarButtonItems:(NSArray *)rightBarButtonItems {
    
    if (self.m_ParentViewController) {
        
        if ([self.m_ParentViewController isKindOfClass:[BaseViewController class]]) {
            [((BaseViewController *)self.m_ParentViewController) getNavigationItem].rightBarButtonItems = rightBarButtonItems;
        }
        else {
            self.m_ParentViewController.navigationItem.rightBarButtonItems = rightBarButtonItems;
        }
    }
    else {
         self.navigationItem.rightBarButtonItems = rightBarButtonItems;
    }
}

- (void)initializationBackItemAction {
    
    NSArray *vcs = self.navigationController.viewControllers;
    if (vcs) {
        
        if (vcs.count > 2) {
            
            if (self.currentFuncs && self.currentFuncs.opt && [self.currentFuncs.opt.isReturnHome isEqualToString:@"1"]) {
                
                UIView *homeButtonView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, MAIN_BUTTON_WH * 2, 44)];
                UIButton *homeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, MAIN_BUTTON_WH, 44)];
                homeButton.backgroundColor = [UIColor clearColor];
                [homeButton addTarget:self action:@selector(homeAction) forControlEvents:UIControlEventTouchUpInside];
                [homeButton setImage:[[UIImage imageForName:@"icon_home.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
                [homeButton setImage:[UIImage imageForName:@"icon_home_press.png"] forState:UIControlStateHighlighted];
                [homeButtonView addSubview:homeButton];
                
                UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(MAIN_BUTTON_WH, 0, MAIN_BUTTON_WH, 44)];
                [backBtn setBackgroundColor:[UIColor clearColor]];
                [backBtn setImage:[[UIImage scaledImageForName:@"icon_back" ofType:@"png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
                [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
                [homeButtonView addSubview:backBtn];

                UIBarButtonItem *homeButtonItem = [[UIBarButtonItem alloc]initWithCustomView:homeButtonView];
                self.navigationItem.leftBarButtonItem=homeButtonItem;
            }
            else {
                [self setTheBackItemByTheCurrentFuncs];
            }
        }
        else {
            [self setTheBackItemByTheCurrentFuncs];
        }
    }
    else {
        [super initializationBackItemAction];
    }
}

- (void)setTheBackItemByTheCurrentFuncs {
    
    if (self.currentFuncs && self.currentFuncs.isHomePageWillShow) {
        
        if (self.currentFuncs && self.currentFuncs.opt && [self.currentFuncs.opt.isReturnHome isEqualToString:@"1"]) {
            
            NSDictionary *mobileHomeDic = [WSAppData getObjectbyKey:MOBILEHOMEPAGE];
            if (mobileHomeDic) {
                NSString *readTimeStr = [mobileHomeDic objectForKey:MobileHomePageReadingTimeKey];
                [self backItemAction:nil target:nil withDelay:[readTimeStr intValue]];
            }
        }
        else {
            
            self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
            if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
                self.navigationController.interactivePopGestureRecognizer.enabled = NO;
            }
        }
        self.currentFuncs.isHomePageWillShow = NO;
    }
    else {
        [self backItemAction:@selector(backAction) target:self];
    }
}

- (void)reloadAddAllNavBBI {

    if (!(isHideUploadButton)) {
        [self clearAllNavBBI];
        [self addToolBar];
    }
    else {
        [self clearAllNavBBI];
    }
}

- (void)clearAllNavBBI {
    
    [self navBarClearRightBarButtonItems];
}

- (void)navBarClearRightBarButtonItems {
    
    [self getNavigationItem].rightBarButtonItems = nil;
    self.uploadButton = nil;
}

- (void)setupScrollNavTitleView {
    
    CGFloat margin = [self.navigationController getNavTitleMargin];
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    
    WSScrollLabelView *scrollLabelView = [[WSScrollLabelView alloc] initWithFrame:CGRectMake(0, 0, width - margin, 44)];
    scrollLabelView.text = self.navigationItem.title;
    UIColor *navBarTitleColor = [UIColor colorForKey:@"NavigationBarTitleColor"];
    UIFont *navBarTitleFont = [UIFont fontForKey:@"NavigationBarTitleFont"];
    scrollLabelView.textColor = navBarTitleColor;
    scrollLabelView.font = navBarTitleFont;
    self.navigationItem.titleView = scrollLabelView;
}

- (void)setupViews {
    
    if (firstLoad) {
        
        if (!self.qstTypIsDMNeedRequestFromServer) {
            
            if (isLoaded == NO) {
                
                int height = 0;
                if (INTERFACE_IS_PHONE) {
                    if (!self.isNotShowStoreNameLabel) {
                        [self loadStoreNameLabel];
                    }
                }
              
                CGFloat uploadViewHeight = 0;
                BOOL isBatchUpload = NO;
                if ([[self getUploadStyle] isEqualToString:@"bottom"]) {
                    isBatchUpload = YES;
                    uploadViewHeight = MAIN_CELL_BUTTON_WH;
                }
                
                _scrollView = [[WSAcvtScrollView alloc] initWithFrame:CGRectMake(0, self.y_point + height, self.view.width, self.view.height  - uploadViewHeight - self.y_point - height) andAcvtBean:_m_currentAcvt];
                _scrollView.delegate = self;
                _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
                
                self.acvtview = _scrollView.acvtView;
                self.acvtview.delegate = self;
                self.acvtview.acvtViewDelegate = self;
                [self addAcvtshowBeansToView:self.acvtview viewHight:&height];
                
                if (height > 0) {
                    self.acvtview.positionY = height;
                }
                
                if (self.kqArrange) {
                    self.acvtview.kqArrange = self.kqArrange;
                }
                
                [self.acvtview buildDisplayContent];
                [self addAcvtDataGridViewPanelsToCacheArray];
                [self.view addSubview:_scrollView];
                
                if (isBatchUpload) {
                    WSAcvtBatchUploadView *batchUploadView = [[WSAcvtBatchUploadView alloc] initWithFrame:CGRectMake(0, self.view.height - uploadViewHeight, self.view.width, uploadViewHeight) target:self];
                    [self.view addSubview:batchUploadView];
                }
                
                isLoaded =YES;
            }
        }
    }
    
    if (isHideUploadButton && [self.parentViewController isKindOfClass:[WSPopViewController class]]) {
        
        WSPopViewController *parent = (WSPopViewController *)self.parentViewController;
        [parent setConfirmButtonEnable:NO];
    }
    
    NSInteger uploadCountLimit = [self getAcvtUploadCountLimit];
    if (uploadCountLimit != NSNotFound && uploadCountLimit != 0) {
        
        NSInteger hasUploadCount = [self  getHasUploadCount];
        if (hasUploadCount >= uploadCountLimit) {
            self.uploadButton.enabled = NO;
        }
    }
    
    if (self.isLoadForRealtimeRequest && firstLoad) {
        
        [self accordingToIsBlockResetAcvtWidgetsReadonly:YES];
        self.isLoadForRealtimeRequest = NO;
    }
    
    if ([self.currentFuncs.unredo integerValue] == 1 && !_isNewAddAcvt && ([self.model.datasFromDB count] > 0)) {
        
        [self setAcvtReadOnly];
        [self.acvtview executeLuaScriptWhenInitFinish];
    }

    if (self.hud) {
        [self.hud hideAnimated:YES];
    }
    
    if (firstLoad) {
        [self setSteadyTableHeadViewHiddenOrNotWithScrollView:_scrollView];
    }
    
    firstLoad = NO;
}

- (BOOL)getAcvtReadOnly {
    
    NSInteger readonly = self.currentFuncs.readonly;
    if (!readonly && self.m_currentAcvt.isReadonly) {
        readonly = self.m_currentAcvt.isReadonly.integerValue;
    }
    
    if (!readonly && self.m_currentAcvt.parentReadonly) {
        readonly = self.m_currentAcvt.parentReadonly.integerValue;
    }
    
    if (!readonly && self.currentStore.inReadonlyMode) {
        readonly = 1;
    }
    
    if (readonly == 1) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)setAcvtReadOnlyByParam:(NSString *)param {
    
    if ([param isEqualToString:@"1"]) {
        if (!((WSAcvtModel *)self.model).isNewAddAcvt) {
            [self setAcvtReadOnly];
        }
    }
    else if ([param isEqualToString:@"2"]) {
        [self setUploadButtonHidden:NO];
    }
    else if ([param isEqualToString:@"3"]) {
        [self setUploadButtonHidden:YES];
    }
}






- (void)setAcvtReadOnly {
    for(WSWidget* widget in self.acvtview.widgetArray){
        [widget setReadonly:@"1"];
    }
    
    [self setUploadButtonHidden:YES];
}

- (void)resetSteadyViewHiddenOrNot
{
    if (_scrollView) {
        [self setSteadyTableHeadViewHiddenOrNotWithScrollView:_scrollView];
    }
}

#pragma mark - 蓝牙打印脚本调用
- (void)showBlueToothListViewWithParam:(NSString *)str {
    
    BOOL isFirst = [SEPrinterManager getSharedInstancePrinterManager] ? NO : YES;
    
    if (!self.manager) {
        self.manager = [SEPrinterManager sharedInstance];
        self.manager.delegate = self;
    }
    
    if (!self.actionSheet) {
        self.actionSheet = [[WSBlueToothListActionSheet alloc] initWithFrame:self.view.bounds WithBaseController:self withSEPrinterManager:self.manager withPrintParam:str];
    } else {
        [self.actionSheet reloadPrintParam:str];
    }
    
    if (!isFirst) {
        [self showBlueToothListView];
    }
}

#pragma mark - 显示蓝牙列表视图
- (void)showBlueToothListView {
    
    if (self.manager.isStatePoweredOn) {
        [self.actionSheet show];
        return;
    }
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请打开蓝牙" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *setAction = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        NSURL *url = [NSURL URLWithString:@"App-Prefs:root=Bluetooth"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action){}];
    [alertVC addAction:setAction];
    [alertVC addAction:cancelAction];
    [self presentViewController:alertVC animated:YES completion:^{}];
}

#pragma mark -  WSAcvtScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self setSteadyTableHeadViewHiddenOrNotWithScrollView:scrollView];
    [self setTopOrBottomWightSteadyWith:scrollView];
}

-(void)setTopOrBottomWightSteadyWith:(UIScrollView *)scrollView{
    //  MN-102  蒙牛添加 固定顶部和底部控件 add by 支庆
//优化表格闪退问题
//    NSArray * array = ((WSAcvtScrollView *)scrollView).acvtView.widgetArray;
//    for (WSWidget * widget in array) {
//        if ([[widget.xbuildInfo getLayout_gravity] isEqualToString:@"top"]) {
//            widget.top = scrollView.contentOffset.y;
//            [((WSAcvtScrollView *)scrollView).acvtView bringSubviewToFront:widget];
//        }
//        
//        if ([[widget.xbuildInfo getLayout_gravity] isEqualToString:@"bottom"]) {
//            widget.top = scrollView.height - widget.height + scrollView.contentOffset.y;
//        }
//        
//    }
}

// 通过当前scrollView.contentOffset.y设置嵌套表格固定表头的显示与隐藏
- (void)setSteadyTableHeadViewHiddenOrNotWithScrollView:(UIScrollView *)scrollView
{
    if (self.acvtDataGridViewPanelsMArray && self.acvtDataGridViewPanelsMArray.count > 0) {
        for (WSAcvtDataGridViewPanel *acvtDataGridViewPanel in self.acvtDataGridViewPanelsMArray) {
            if (scrollView.contentOffset.y > acvtDataGridViewPanel.frame.origin.y + acvtDataGridViewPanel.dataGridView.headerHeight && scrollView.contentOffset.y < acvtDataGridViewPanel.frame.origin.y + acvtDataGridViewPanel.frame.size.height - acvtDataGridViewPanel.dataGridView.headerHeight && acvtDataGridViewPanel.dataGridView.isExtendedView) {
                acvtDataGridViewPanel.acvtGridSteadyTableHeadView.hidden = NO;

            }else{
                acvtDataGridViewPanel.acvtGridSteadyTableHeadView.hidden = YES;
            }
        }
    }
   
}

// 将调查问卷里面的嵌套表格控件加入到cache数组中，以便做固定表头的显示(因为一个调查问卷有可能嵌套多个表格)
- (void)addAcvtDataGridViewPanelsToCacheArray
{
    for (UIView *view in self.acvtview.subviews) {
        if ([view isKindOfClass:[WSAcvtDataGridViewPanel class]]) {
            WSAcvtDataGridViewPanel *acvtDataGridViewPanel = (WSAcvtDataGridViewPanel *)view;
            if (![self.acvtDataGridViewPanelsMArray containsObject:acvtDataGridViewPanel]) {
                [self.acvtDataGridViewPanelsMArray addObject:acvtDataGridViewPanel];
            }
        }else{
            
        }
    }
}


- (void)doRemoveAcvtGridSteadyTableHeadViewWhenBackToParentOrHome
{
    if (self.acvtDataGridViewPanelsMArray && self.acvtDataGridViewPanelsMArray.count > 0) {
        for (WSAcvtDataGridViewPanel *acvtDataGridViewPanel in self.acvtDataGridViewPanelsMArray) {
            [acvtDataGridViewPanel.acvtGridSteadyTableHeadView removeFromSuperview];
            acvtDataGridViewPanel.acvtGridSteadyTableHeadView = nil ;
        }
    }
}

- (void)accordingToIsBlockResetAcvtWidgetsReadonly:(BOOL)isReadonly {
    
    /*编辑新增阻塞问卷要*/
    BOOL isOtherBlock =  ([self.updateGenID length] > 0 && [(WSAcvtModel *)self.model isSynchronizeRequest]);
    
    if ([[[(WSAcvtModel *)self.model currentAcvtBean] isBlock] isEqualToString:@"2"] || isOtherBlock) {
        UIBarButtonItem *barButtonItem = nil;
        barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageForName:@"icon_upload"] style:UIBarButtonItemStylePlain target:self action:@selector(executeUpload)];

        if (self.uploadButton) {
            if(self.m_ParentViewController != nil)
            {
                [self resetRightBarButtonItem:barButtonItem  forViewController:self.m_ParentViewController ];
            }
            else
            {
                [self resetRightBarButtonItem:barButtonItem forViewController:self];
            }
        }
    }
}


- (void)resetRightBarButtonItem:(UIBarButtonItem *)newItem  forViewController:(UIViewController *)controller{
    NSMutableArray *originBarButtonArray = [NSMutableArray arrayWithArray:controller.navigationItem.rightBarButtonItems];
    for (NSInteger i = 0;i < [originBarButtonArray count] ;i++) {
        UIBarButtonItem *barButtonItem = originBarButtonArray[i];
        NSString *actionName = NSStringFromSelector(barButtonItem.action);
        
        if ([actionName isEqualToString:@"realTimeRefreshAcvtDatas"] ||
            [actionName isEqualToString:@"executeUpload"] || actionName == nil) {
            [originBarButtonArray replaceObjectAtIndex:i withObject:newItem];
            break;
        }
        
    }
    controller.navigationItem.rightBarButtonItems = originBarButtonArray;
}

#pragma mark - 重写gestureRecognizerShouldBegin:方法
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if ([gestureRecognizer isEqual:self.navigationController.interactivePopGestureRecognizer]) {
        return NO;
    }
    return NO;
}

// YIHAIKERRY-2180 升级经确认可以暂时屏蔽手势 SFA-25321(禁用此页面左划，自测没有问题)
- (BOOL)shouldCustomInteractivePopGestureRecognizerDelegate
{
    return YES;
}

- (BOOL)shouldPauseBackAction
{
    // SFA-11750 SFA葵花药业--手机端问卷设置必填，需要控制必须填写，才能离开
    WSAcvtModel *model = (WSAcvtModel *)self.model;

    if ([self.m_currentAcvt.isReq isEqualToString:@"1"]) {
        if (model.qstDBValueDictionary.count == 0) {
            return YES;
        }
    }
    
    /*Jira - SFA-14258 create by sunhongfu 2017-11-24 对人不能返回,对店可以返回*/
    //    MMSH-3477
    //    SFA玛氏中国MWC- 【IOS:拜访】WS 门店（10253444）（账号50949，1111）在“位置”表单点击返回没有提示“取消/上传/放弃”，而提示“请上传数据”
    // 问卷调查是否必填是由脚本控制 和配置isReq 无关
    if (model.isReqFromLua && !self.currentStore) {
        if (model.qstDBValueDictionary.count == 0) {
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"Please_input_data", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return YES;
        }
    }
    
    // 返回的时候调用上传，所以不能返回
    BOOL isUploading = [self hasSTQstToUpload];
    if (isUploading) {
        return YES;
    }
    
    return NO;
}

- (void)homeAction {
    [self goBackWithIsBackHome:YES];
}

- (void)backAction {
    [self goBackWithIsBackHome:NO];
}

- (void)goBackWithIsBackHome:(BOOL)isBackHome {
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    if ([self batchUploadAction]) {
        return;
    }
    
    if ([self shouldPauseBackAction]) {
        return;
    }
    
    if ([self isShowBackPrompt]) {
        
        [WSAcvtViewController backPromptWithFuncs:self.currentFuncs saveBlock:^{
            [self backToSave];
            [self backToParent];
            
        } uploadBlock:^{
            if (isBackHome) {
                isHomeBackAction = YES;
            }
            self.isBackClick = NO;
            [self executeUpload];
            
        } giveupBlock:^{
            [self backToGiveup];
            [self backToParent];
            
        }];
        return;
    }
    self.isBackClick = YES;
    [self doRemoveAcvtGridSteadyTableHeadViewWhenBackToParentOrHome];
    // YIHAIKERRY-2465  donghong
    if (isBackHome) {
        
        isHomeBackAction = YES;
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        [self backToParent];
    }
}

- (BOOL)isShowBackPrompt {
    // YIHAIKERRY-2404 按钮隐藏时 设置了 UploadStyle 也需要校验
    if ((self.uploadButton.isEnabled && !self.uploadBtnHidden) || ([[self getUploadStyle] length] > 0 && ![[self getUploadStyle] isEqualToString:@"noJump"])) {
        if ([self respondsToSelector:@selector(isValueChange)]) {
            // 如果上传按钮隐藏，则不需要提示，直接返回
            if ([self performSelector:@selector(isValueChange)]) {
                return YES;
            }
        }
    }
    
    return NO;
}

// YIHAIKERRY-2120 批量上传的返回需要处理多个文件的保存放弃等操作
- (BOOL)batchUploadAction {
    WSMV_LISTViewController *mvListController = [self getBatchUploadController];
    if (mvListController) {
        [mvListController batchUploadBackAction];
        return YES;
    }
    return NO;
}

// YIHAIKERRY-2120 需要批量上传的话则返回 WSMV_LISTViewController 类，该类中统一调用，不需要批量上传返回 nil
- (WSMV_LISTViewController *)getBatchUploadController {
    if ([self.m_ParentViewController isKindOfClass:[WSMV_LISTViewController class]]) {
        WSMV_LISTViewController *mvListController = (WSMV_LISTViewController *)self.m_ParentViewController;
        if (mvListController.isBatchUpload) {
            return mvListController;
        }
    }
    return nil;
}

- (NSString *)getUploadStyle {
    NSString *uploadStyle = [[self getBatchUploadController] getUploadStyle];
    if (!uploadStyle) {
        uploadStyle = self.currentFuncs.opt.uploadStyle;
    }
    // YIHAIKERRY-2436 升级临时方案
    if (!uploadStyle) {
        uploadStyle = self.uploadStyle;
    }
    return uploadStyle;
}

- (void)backToSave {
    BOOL isResult =  [WSBaseStoreOtherDataDBService saveStoreId:self.currentStore.Id withFc:self.currentFuncs.fc withAcvtId:self.m_currentAcvt.acvtId withBizDate:[WSCurrentTime getDateString] withEmpId:self.model.currentSubEmpStore.Id genId:self.model.md5];
    if (isResult) {
        self.isBackClick = NO;
        [self saveAcvtDatasToDB];
        [self uploadPhotosForAcvtView:NO];
        [self saveParentAcvtQst];
        [self doRemoveAcvtGridSteadyTableHeadViewWhenBackToParentOrHome];
    }
}
- (void)saveParentAcvtQst
{
    //    YIHAIKERRY-3039
    //    益海嘉里-深圳：【ios】：门店拜访：点击保存按钮，闪退。上传诊断日志时间：2018-06-06 21:45
    if ([self.model isKindOfClass:[WSAcvtModel class]]) {
        WSAcvtModel *model = (WSAcvtModel *)self.model;
        if (model.md5.length > 0 && self.m_currentAcvt.parentQstCode != nil && self.m_currentAcvt.parentQstCode.length > 0 && model.isSubAcvt) {
            WSBaseStoreOtherDataDBService *dataService = [[WSBaseStoreOtherDataDBService alloc] init];
            NSString *date = [WSCurrentTime getDateString];
            NSDictionary *dic = @{@"item1":self.m_currentAcvt.parentQstCode,@"item2":self.m_currentAcvt.acvtId,@"item3": self.model.md5,@"biz_date":date};
            [dataService insertOrUpdateStoreWithDataDic:dic];
        }
    }
}

- (void)backToGiveup {
    self.deleteDBAcvtDatas = YES;
    self.isBackClick = YES;
    
    [self clearDatasWhenBackAction];
    [self doRemoveAcvtGridSteadyTableHeadViewWhenBackToParentOrHome];
}

// SFA-15017 查找是否有 ST 类型的问题并且ST问题没有回显或者回显值不是1，如果存在则执行上传
- (BOOL)hasSTQstToUpload {
    if (![self getAcvtReadOnly]) {
        return NO;
    }
    NSArray *qstArray = self.m_currentAcvt.qsts;
    if ([qstArray count] > 0) {
        WSBaseAcvtdisDBService *acvtDisDBService = [[WSBaseAcvtdisDBService alloc] init];
        NSMutableArray *acvtQstArray = [NSMutableArray arrayWithCapacity:qstArray.count];
        for (WSAcvtBean_qst *qst in qstArray) {
            if ([qst.qstType isEqualToString:QST_TYPE_ST]) {
                [acvtQstArray addObject:qst.acvtQstId];
            }
        }
        if (!acvtQstArray || [acvtQstArray count] == 0) {
            return NO;
        }
        NSArray *dataArray = [acvtDisDBService queryQstValueWithStoreId:self.currentStore.Id    acvtQstIdArray:acvtQstArray];
        if ([dataArray count] == 0) {
            [self executeUpload];
            return YES;
        } else {
            for (NSString *qstAnwser in dataArray) {
                if (![qstAnwser isEqualToString:@"1"]) {
                    [self executeUpload];
                    return YES;
                }
            }
        }
    }
    return NO;
}

#pragma mark - WSBatchUploadView Action
- (void)bottomUploadAction:(id)sender {
    [self executeUpload];
}

- (void)bottomSaveAction:(id)sender {
    WSMV_LISTViewController *mvListController = [self getBatchUploadController];
    if (mvListController) {
        [mvListController batchUploadBackToSave];
    } else {
        [self backToSave];
        [self backToParent];
    }
}

#pragma mark - About isValueChange

- (BOOL)isValueChange {
    if (self.operationAcvtType == WSOnlySaveAcvtDataForCalendarType) {
        if (_isValueChange) {
            return YES;
        }
    }
    _isValueChange = NO;
    if ([self.acvtview isValueChange]) {
        _isValueChange = YES;
        return _isValueChange;
    }
    
    return NO;
}

#pragma mark - sms method
-(BOOL) checkAndSendSmsWithDelegate:(id<WSSmsControllerDelegate>)delegate
                    withExpandBlock:(LuaScriptWithParamsExpandBlock)block
{
    //检测是否有onsubmit脚本，如果有则通过lua环境处理，否则直接忽略返回NO
    if (self.m_currentAcvt && self.m_currentAcvt.luaScript) {
        
        if ([self.m_currentAcvt.luaScript rangeOfString:@"sendSMS"].location == NSNotFound) {
            return NO;
        }
        
        self.luaParserObj = [[WSLuaScriptContext alloc] initWithFuncsBean:nil
                                                            withStoreBean:self.currentStore
                                                                 withAcvt:self.m_currentAcvt];
        self.luaParserObj.luaScriptStr = self.m_currentAcvt.luaScript;
        self.luaParserObj.smsContentPage = [[WSSmsController alloc] initWithDelegate:self
                                                                        withParentVC:self];
        [self.luaParserObj initializationWithVariableParamsBlock:block];
        WSLuaScriptEnter *luaEnter = [[WSLuaScriptEnter alloc] init];
        [luaEnter initializationLuaContextWithLuaScriptContext:self.luaParserObj];
        NSString *resultStr = [luaEnter runOnSumbit];
        LogInfo(@"resultStr:%@", resultStr);
        if (resultStr) {
            if ([resultStr isEqualToString:@"0"]) {
                LogInfo(@"短信界面启动");
#if TARGET_IPHONE_SIMULATOR
                [self SmsFinishedWithResult:ESmsComposeResultSent
                                withContent:self.luaParserObj.smsContentPage.smsContent];
#endif
                return YES;
            }else if ([resultStr isEqualToString:@"1"]) {
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"sms_error_tip", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                if (self.isRequiredSendSMS) {
                    return YES;
                }
            }
            else if ([resultStr isEqualToString:@"2"]) { //忽略短信功能
                //Note:解析的文本数据为空，脚本配置有问题。
            }
        }
    }
    
    return NO;
}

#pragma mark - WSSmsControllerDelegate method
-(void) SmsFinishedWithResult:(ESmsComposeResult)result withContent:(NSString*) contentStr
{
    LogInfo(@"result :%ld", (unsigned long)result);
    switch (result) {
        case ESmsComposeResultSent:
            [self showWaitHudAndDoUpload];
            break;
        case ESmsComposeResultCancelled:
        case ESmsComposeResultFailed:
            //如果必填，则需要弹出提示框
        {
            if (self.isRequiredSendSMS) {
                NSString *title = NSLocalizedString(@"必须发送短信", nil);
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            }else {
                int state = 2;
                if (ESmsComposeResultFailed == result) {
                    state = 1;
                }
                [self showWaitHudAndDoUpload];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - weChatImgShare
// 点击微信分享按钮到联系人列表
-(void)weChatImgShareButtonClick:(id)sender{
    
}

- (NSData *)zipImageWithImage:(UIImage *)originalImage
{
    CGFloat maxFileSize = 32*1024;
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    NSData *compressedData = UIImageJPEGRepresentation(originalImage, compression);
    if ([compressedData length] > maxFileSize && compression > maxCompression) {
        compression = maxFileSize / [compressedData length];
    }
    compressedData = UIImageJPEGRepresentation(originalImage, compression);
    
    return compressedData;
}
// 打开微信
-(void)weChatImgShareToWeChart:(UIButton *)sender{

  
}

-(void)alertView{
   
    NSString * title = NSLocalizedString(@"not_wechat", nil);
    NSString * message = NSLocalizedString(@"请先下载微信,再使用此功能", nil) ;
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:message tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
}

#pragma mark - request finish
- (void)requestFinishForQstTypeDm:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"QST_TYP_DM_NOTIFIY" object:nil];
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSDictionary *dic = [info objectFromJSONString];
    NSNumber *flag = [dic objectForKey:@"flag"];
    if (flag && [flag isKindOfClass:[NSNumber class]] && [flag integerValue] == 1) {
        NSArray *spestore = [dic objectForKey:@"spestore"];
        NSMutableArray *spestores = [NSMutableArray array];
        if (spestore && [spestore count] > 0) {
            for (NSInteger i = 0 ; i < [spestore count]; i++) {
                NSDictionary *storeDic = [spestore objectAtIndex:i];
                NSString *org_id = [storeDic objectForKey:@"ORG_ID"];
                NSString *cod = [storeDic objectForKey:@"cod"];
                NSString *empId = [storeDic objectForKey:@"empId"];
                NSString *storeId = [storeDic objectForKey:@"id"];
                NSString *storeName =[storeDic objectForKey:@"name"];
                NSString *styp = [storeDic objectForKey:@"chainDist"];
                
                WSStoreBean * storeBean = [[WSStoreBean alloc] init];
                storeBean.orgId = org_id;
                storeBean.code  = cod;
                storeBean.empId = empId;
                if (storeId && [storeId isKindOfClass:[NSNumber class]]) {
                    storeBean.Id = [(NSNumber *)storeId    stringValue];
                }

                storeBean.name = storeName;
                storeBean.styp = styp;
                [spestores addObject:storeBean];
            }
        }
        if (spestores && [spestores count] > 0) {
            [WSAppData putObject:spestores forKey:self.dsForQstTypeIsDM];
        }
    }
    
        
    if (isLoaded==NO) {
        
        WSAcvtScrollView *scrollView = [[WSAcvtScrollView alloc] initWithFrame:CGRectMake(self.view.origin.x, self.y_point, self.view.width, self.view.height - self.y_point) andAcvtBean:_m_currentAcvt];
        
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        self.acvtview = scrollView.acvtView;
        
        self.acvtview.delegate = self;
        
        self.acvtview.acvtViewDelegate = self;
        
        [self.acvtview buildDisplayContent];
        
        [self.view addSubview:scrollView];
        
        isLoaded =YES;
    }
}

#pragma mark - new acvt upload

-(void)executeUpload{
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    __weak __typeof(self) weakSelf = self;
    if (self.currentFuncs.opt.uploadDialog_tip && self.currentFuncs.opt.uploadDialog_tip.length > 0) {
        
        NSString *message = self.currentFuncs.opt.uploadDialog_tip;
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:message];
        [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:^{
        }];
        [alert addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
            [weakSelf validateAndUpload];
        }];
        [alert show];
        return;
    }
    
    //非必填问题验证逻辑
    if(self.currentFuncs.opt.notReqCheck_tip.length>0){
        NSMutableDictionary *dic = [self.acvtview notReqCheckTip];
        if (dic.allKeys.count > 0) {
            NSString *message = self.currentFuncs.opt.notReqCheck_tip;
            for (NSString *key in dic.allKeys) {
                NSString *newKey = [NSString stringWithFormat:@"{%@}", key];
                if ([message containsString:newKey]) {
                    NSNumber *number = [dic objectForKey:key];
                    NSString *str = [NSString stringWithFormat:@"%ld", [number integerValue]];
                    message = [message stringByReplacingOccurrencesOfString:newKey withString:str];
                }
            }
            
            __weak __typeof(self) weakself = self;
            BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:message];
            [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:nil];
            [alert addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
                [weakself validateAndUpload];
            }];
            [alert show];
            return;
        }
    }
    
    
    [self validateAndUpload];
}

- (void)validateAndUpload
{
    isUpdateCalendarDataFromLua = NO;
    self.currentUploadActionType = WSNormalActionType;
    
    [self.acvtview readyToUpload]; // SFA-25392 问题需要处理准备传的状态
    
    WSMV_LISTViewController *mvListController = [self getBatchUploadController];  // YIHAIKERRY-1816 需要批量上传的话则在 WSMV_LISTViewController 类中统一调用上传
    if (mvListController) {
        [mvListController batchUpload];
        return;
    }
    
    if (![self executeValidate]) {
        return;
    }
    
    [self checkSameMainTitleTipAndUpload];
}

- (void)checkSameMainTitleTipAndUpload
{
    WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
    WSAcvtListDataItem *acvtListDataItem = nil;
    NSString *alertTitle = [self getQstAlertTitle];
    
    // SFA-13031 增加非阻塞下主标题问题答案相同的记录覆盖逻辑
    BOOL mNeedSameTip = YES;
    BOOL isNewAcvt = (self.isNewAddAcvt && !(self.updateGenID && [self.updateGenID length] > 0));
    if ([[[(WSAcvtModel *)self.model currentAcvtBean] isBlock] isEqualToString:@"1"] ||
        [[[(WSAcvtModel *)self.model currentAcvtBean] isBlock] isEqualToString:@"2"] ||
        [[[(WSAcvtModel *)self.model currentAcvtBean] isBlock] isEqualToString:@"3"] ||
        !isNewAcvt) {
        mNeedSameTip = NO;
    }
    
    BOOL isUploadCheckReplace = ([self.currentFuncs.opt.isUploadCheckReplace isEqualToString:@"1"]) ? YES : NO; //MN-3248
    if (mNeedSameTip && isUploadCheckReplace) {
        
        // SFA-14625 可能存在多个主标题覆盖的问题
        NSMutableArray *mainTitleWidgetArray = [NSMutableArray array];
        NSArray *acvtArray = [[(WSAcvtModel *)self.model currentAcvtBean] qsts];
        for (NSInteger i = 0; i < acvtArray.count; i++) {
            WSAcvtBean_qst *qst =  acvtArray[i];
            if (qst.isAcvtName && qst.isAcvtName.length > 0 && [qst.isAcvtName isEqualToString:@"1"]) {
                [mainTitleWidgetArray addObject:self.acvtview.widgetArray[i]];
            }
        }
        
        NSString *answer;
        if ([mainTitleWidgetArray count] > 0) {
            NSMutableArray *answerArray = [NSMutableArray arrayWithCapacity:mainTitleWidgetArray.count];
            for (WSWidget *mainTitleWidget in mainTitleWidgetArray) {
                id value = [mainTitleWidget getDisplayValuePresentation];
                if ([value isKindOfClass:[NSString class]]) {
                    [answerArray addObject:(NSString *)value];
                }
            }
            answer = [answerArray getInSqlString];
            
        } else {
            answer = @"null";
        }
        
        NSArray *serviceDataArray = [service queryAcvtDatasWithStoreID:self.currentStore.Id
                                                              acvtType:self.m_currentAcvt.typ
                                                             withEmpId:nil
                                                             qstAnswer:answer
                                                           isFromLocal:YES
                                                                isRead:YES];
        if (serviceDataArray && serviceDataArray.count > 0) {
            NSString *mainTitle = nil;
            if ([mainTitleWidgetArray count] == 1) {
                acvtListDataItem = (WSAcvtListDataItem *)[serviceDataArray firstObject];
                mainTitle = acvtListDataItem.mainTitle;
            } else {
                // SFA-14625 存在多个主标题问题时，当主标题用空格分隔后个数和问题个数一致时才提示覆盖
                for (NSInteger i = 0; i < serviceDataArray.count; i++) {
                    WSAcvtListDataItem *disItem = serviceDataArray[i];
                    NSString *disMainTitle = [disItem mainTitle];
                    NSArray *mainTitleArray = [disMainTitle componentsSeparatedByString:@" "];
                    if ([mainTitleArray count] == [mainTitleWidgetArray count]) {
                        mainTitle = disMainTitle;
                        acvtListDataItem = disItem;
                        break;
                    }
                }
            }
            if (mainTitle) {
                alertTitle = [NSString stringWithFormat:@"%@ %@", mainTitle, NSLocalizedString(@"Already exists，are you sure you want to overwrite it?", nil)];
            }
        }
    }
    
    if ([alertTitle length] > 0) {
        BlockAlertView *aler = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:alertTitle];
        [aler setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:nil];
        [aler addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
            
            // SFA-19468  之前代码在  alertTitle = [NSString stringWithFormat:@"%@ %@", mainTitle, NSLocalizedString(@"Already exists，are you sure you want to overwrite it?", nil)]; 这个位置，这会导致无论是点取消或者确认按钮，都会覆盖之前的数据，逻辑上错误，现在移动到点击确认之后才覆盖之前的逻辑。
            WSAcvtModel *model = (WSAcvtModel *)self.model;
            if(acvtListDataItem.genID&&acvtListDataItem.genID.length > 0)
            {
                model.md5 = acvtListDataItem.genID;
            }
            model.currentAcvtBean.iOriginalAcvtId = nil;
            
            if (acvtListDataItem) {
                NSMutableArray *sameAnswerAcvtListDateItemsGenIdsMArray = [[NSMutableArray alloc] init];
                [sameAnswerAcvtListDateItemsGenIdsMArray addObject:acvtListDataItem.genID];
                [service deleteLocalDataWithGenIds:sameAnswerAcvtListDateItemsGenIdsMArray];
            }
            [self showWaitHudAndDoUpload];
        }];
        [aler show];
        return;
    }
    
    [self showWaitHudAndDoUpload];
}
- (NSString*)getRoutId{
    
    NSString * routeid = [[NSUserDefaults standardUserDefaults]objectForKey:@"routeId"];
    
    return routeid;
}
- (NSString *)getQstAlertTitle
{
    NSArray *array = [((WSAcvtModel *)self.model).currentAcvtBean.qsts valueForKeyPath:@"@distinctUnionOfObjects.alertTitle"];
    
    NSMutableString *string = [NSMutableString string];
    
    for (NSString *title in array) {
        if ([title length] > 0) {
            if ([string length] > 0) {
                [string appendString:@"\r\n"];
            }
            [string appendString:title];
        }
    }
    
    if ([string length] > 0) {
        return string;
    }
    
    return nil;
}

- (BOOL)executeValidate
{
    self.isValueChange = YES;
    
    if (![self.acvtview executeValidate]) {
        return NO;
    }
    /*
     校验日历模式下是否点击确认问题
     */
    if (isUpdateCalendarDataFromLua) {
        
        
    }else {
        if (![self validteClickConfirmButtonInCalendarPattern]) {
            return NO;
        }
    }
//     SFA-24531 修改 执行顺序 董宏
    if (![self.acvtview checkLuaScriptWhenUpload]) {
        return NO;
    }
    //问题分组
    NSArray *reqGroupArray =[self.acvtview doExecuteGroupValidate];
    if (reqGroupArray && [reqGroupArray count] >0) {
        
        NSString *str = [reqGroupArray componentsJoinedByString:@","];
        NSString *tip = NSLocalizedString(@"not_filled", nil);
        NSString *toastStr = [NSString stringWithFormat:tip, str];
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:toastStr tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return NO;
    }
    
    //TODO 待重构
    if ([self checkAndSendSmsWithDelegate:self
                          withExpandBlock:^id(id keyObj,...) {
                              if (keyObj
                                  && [keyObj isKindOfClass:[NSString class]]){
                                  
                                  NSString *functionkey = [NSString stringWithFormat:@"%@", keyObj];
                                  if([functionkey isEqualToString:WSLUA_FUNCTION_ACVTTBCONTEXT_RETURN_ARRAY]){
                                      NSMutableArray *tabSources = nil;
                                      for(WSAcvtBean_qst *ab_qst in self.m_currentAcvt.qsts) {
                                          // 在 acvt 中添加表格 TB 类型
                                          if ([ab_qst.qstType isEqualToString:QST_TYPE_TB]) {
                                              WSAcvtDataGridViewPanel *comView = [self.acvtview.widgetDict objectForKey:ab_qst.acvtQstId];
                                              if (comView) {
                                                  if (!tabSources) {
                                                      tabSources = [[NSMutableArray alloc] init];
                                                  }
                                                  [tabSources addObject:[comView getAcvtDataSource]];
                                              }
                                          }
                                      }
                                      return tabSources;
                                      
                                  }else if ([functionkey isEqualToString:WSLUA_FUNCTION_EXPANDBLOCK_PARAM_ACVTBEANQST_RETURN_STRING]){
                                      va_list argsList;
                                      id secondObj;
                                      va_start(argsList, keyObj);
                                      secondObj = va_arg(argsList, id);
                                      va_end(argsList);
                                      if ([secondObj isKindOfClass:[WSAcvtBean_qst class]]) {
                                          WSAcvtBean_qst *qst = (WSAcvtBean_qst*)secondObj;
                                          WSWidget *widget = [self.acvtview.widgetDict objectForKey:qst.acvtQstId];
                                          NSString *value = (NSString *)[widget getResultDirectly];
                                          return value;
                                      }
                                  }
                              }
                              return nil;
                          }]){
                              return NO;
                          }
    // WRIGLEY-1829
    BOOL isRequired = (self.model.currentFuncs.nullvalue == 0) ? YES : NO;
    if (isRequired) {
        NSMutableDictionary *qstValuesDic =  (NSMutableDictionary *)[self.acvtview getAllPrepareSubmitData];
        if ([qstValuesDic count] == 0) {
            NSString *message = NSLocalizedString(@"not_input_label", nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:message tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return NO;
        }
    }
    
    return YES;
}

/**
 *  显示上传提示，并上传。
 */
- (void) showWaitHudAndDoUpload
{
    self.operationAcvtType = WSUploadAcvtDateNormalType;
    
   
    if ([self getAcvtCalWidgetResult] > 0) {
        self.operationAcvtType = WSUploadAcvtDataForCalendarType;
    }
    
    if([WSLuaExecutorManager shareInstance].isErrorFromScript){
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"uploading_prompt", nil)  tips:NSLocalizedString(@"please_wait", nil) tapTarget:self action:nil];
        
    if([self respondsToSelector:@selector(setVisitAction)]){
            
        [self performSelector:@selector(setVisitAction)];
    }
    [self performSelector:@selector(executeRealWillUpload:) withObject:[NSNumber numberWithInteger:self.operationAcvtType] afterDelay:0.01f];
}

- (BOOL)validteClickConfirmButtonInCalendarPattern {
    
    if ([self acvtHasCalendarQuestion]) {
        if ([self.md5sForCalendarPattern count] > 0) {
            
            for (NSString *md5 in self.md5sForCalendarPattern) {
                
                NSArray *storeAcvtDatas = [[WSVisitStoreAcvtDataTable sharedTable] queryWithNames:@[@"gen_id"] ArgumentsValue:@[[NSString stringNotNilWithValue:md5]]];
                
                if ([storeAcvtDatas count] == 0) {
                    BlockAlertView *blockAlertView = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"click_confirm",nil)];
                    [blockAlertView addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
                        
                    }];

                    [blockAlertView show];
                    return NO;
                }
            }
        }else {
            BlockAlertView *blockAlertView = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"click_confirm",nil)];
            [blockAlertView addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
                
            }];

            [blockAlertView show];
            return NO;
        }
    }
    return YES;
}

- (void)executeRealWillUpload:(NSNumber*)numberParam {
    
    self.operationAcvtType = (int)[numberParam integerValue];
    
    /*当问卷有排班功能时候 调查问卷上传逻辑和正常不同*/
    if (self.operationAcvtType == WSOnlySaveAcvtDataForCalendarType) {
        
        [self saveAcvtDatasToDBWhenCalHasCalendar];
        
    }
    else if (self.operationAcvtType == WSUploadAcvtDataForCalendarType){
        [self executeRealUploadWithCalendar];
    }
    else {
        
        [self executeRealUpload];
    }
}

- (void)executeRealUploadWithCalendar {
    
}

- (void)saveAcvtDatasToDBWhenCalHasCalendar {
    
    if (_calendarSelectedDates == nil) {
        _calendarSelectedDates = [[NSMutableArray alloc] init];
    }
    
    if (_md5sForCalendarPattern == nil) {
        _md5sForCalendarPattern = [[NSMutableArray alloc] init];
    }
    
    NSString *calendarSelectedDates = nil;
    for (WSWidget *widget  in  self.acvtview.widgetArray) {
        if ([[widget.xbuildInfo getAcvtQstType] isEqualToString:@"CAL"]) {
            NSString  *calendarQstId = [widget.xbuildInfo getAcvtQstId];
            self.calendarKeyId = [NSString stringWithFormat:@"%@%@",@"CAL",calendarQstId];
            calendarSelectedDates = (NSString *)[widget getResultDirectly];
            self.calendarPanel = (WSCalendarPanel *)widget;
            break;
        }
    }
    
    NSArray *dateStrs = [calendarSelectedDates componentsSeparatedByString:@","];
    if ([dateStrs count] > 0 ) {
        for (NSString *selectedDate  in  dateStrs) {
            if (![self.calendarSelectedDates containsObject:selectedDate]) {
                [self.calendarSelectedDates addObject:selectedDate];
            }
        }
    }
    
    if ([dateStrs count] > 0 && [calendarSelectedDates length] > 0) {
        for (NSInteger i = 0; i < [dateStrs count]; i++) {
            NSString *dateStr = dateStrs[i];
            if ([self.selectedEmployeeId length] == 0) {
                LogError(@"self.selectedEmployeeId is nil");
            }
            NSString *generateNewMd5 = [self generateMd5WhenAcvtHasCalendar:dateStr];
            if (![self.md5sForCalendarPattern containsObject:generateNewMd5]) {
                [self.md5sForCalendarPattern addObject:generateNewMd5];
            }
            
            self.currentUsingNewMd5WhenAcvtHasCalendar = generateNewMd5;
            self.currentCalendarValue = dateStr;
            
            // MSTD-4671 此处脚本调用的时候需要添加验证才能上传
            if ([self executeValidate]) {
                [self executeRealUpload];
            }
        }
    }
}

- (BOOL)acvtHasCalendarQuestion {
    for (WSWidget *widget  in  self.acvtview.widgetArray) {
        if ([[widget.xbuildInfo getAcvtQstType] isEqualToString:@"CAL"]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)uploadPhotos {
    //上传表格数据照片
    if (![self uploadPhotosForTable]) {
        [self showDBErrorTipAndHidAllHud];
        return NO;
    }
    //上传照片
    if (![self uploadPhotosForAcvtView:YES]) {
        [self showDBErrorTipAndHidAllHud];
        return NO;
    }
    return YES;
}

- (void)executeRealUpload
{
    [self setupCustomPhotoNameWithPhotoKey:nil isReady:YES];
    
    // 阻塞方式的上传等待 acvt 数据上传成功后进行上传
    if (![(WSAcvtModel *)self.model isSynchronizeRequest]) {
        if (![self uploadPhotos]) {
            return;
        }
    }
    //上传表格中的问卷数据(图片和问卷主数据) 先保存，再上传 ，只在这个方法中处理 --SFA-31445
    [self uploadGridDataWhenDSIsAcvt];
    //上传acvt数据
    if (![self uploadAcvtDatas]) {
        [self showDBErrorTipAndHidAllHud];
        return;
    };
    //橙色采集更新base_store_acvt_dis
    WSAcvtModel *model = (WSAcvtModel *)self.model;
    BOOL isUpdateOrangeAcvtDis = NO;
    for ( WSAcvtBean_qst * qst  in model.currentAcvtBean.qsts) {
        if ([qst.isAcvtName isEqualToString:@"17"]) {
            isUpdateOrangeAcvtDis = YES;
            break;
        }
    }
    if (isUpdateOrangeAcvtDis) {
        [self updateExitUpLoadAction];
    }
    
    if (self.currentUploadActionType != WSDeleteActionType) {
        [super uploadVisitAction];
    }
   
    NSInteger uploadCountLimit = [self getAcvtUploadCountLimit];
    
    if (uploadCountLimit != NSNotFound && uploadCountLimit != 0) {
        [self saveAcvtUploadCount];
    }
    
    //上传完成后，清除已改变标识
    [self clearDataFromCacheIsUploadComplete:NO];
    [self.vcTools removeSaveAcvtDataWithMD5:self.model.md5];

    // 立白上传监控数据
    [[WSStatisticsManager sharedInstance] uploadStatisticsLogs];
    if (![(WSAcvtModel *)self.model isSynchronizeRequest])
    {
        [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
        
        //MN-2476 2018-05-16
        [self restoreAcvtViewOriginalData];
        [self updateAcvtViewGenId];
        [[NSUserDefaults standardUserDefaults]  removeObjectForKey:SAVE_QSTCODE_AND_GENID];
        if (!self.model.uploadThenNotFinishView)
        {
            if (!self.hideUploadAlert)
            {
                NSString *tip = NSLocalizedString(@"add_upload_queue", nil);
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tip tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
            }
            [self popToParentOrHome];
        }
        
        [self setSelectedTabIndex];
    }
}

- (void)clearValueChangeData
{
    [self.acvtview.valueChangedWidgetDic removeAllObjects];
    self.isValueChange = NO;
}

//SFA-25657 和安卓对逻辑无论是阻塞上传还是不阻塞上传上传成功都会还原原始数据
- (void)clearDataFromCacheIsUploadComplete:(BOOL)isUploadComplete {
    if (!isUploadComplete) {
        if (![(WSAcvtModel *)self.model isSynchronizeRequest]) {
            if (!isUpdateCalendarDataFromLua) {
                [self clearValueChangeData];
            }
            return;
        }
    } else {
        [self clearValueChangeData];
    }
}

- (NSInteger )getAcvtUploadCountLimit {
    
    WSBaseStoreAcvtTable *baseStoreAcvtTable = [[WSBaseStoreAcvtTable alloc] init];
    return  [baseStoreAcvtTable queryUploadCountLimitWithStoreId:self.currentStore.Id acvtId:self.m_currentAcvt.acvtId];
}

- (NSInteger)getHasUploadCount {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [self generateAcvtUploadCountKey];
   return  [[userDefaults objectForKey:key] integerValue];

}

- (void)saveAcvtUploadCount {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [self generateAcvtUploadCountKey];
    NSInteger hasUploadCount = [[userDefaults objectForKey:key] integerValue];
    hasUploadCount += 1;
    [userDefaults setObject:[NSNumber numberWithInteger:hasUploadCount] forKey:key];
    [userDefaults synchronize];
}

- (NSString *)generateAcvtUploadCountKey {
    return  [NSString stringWithFormat:@"%@_%@_%@",[WSAppData getObjectbyKey:APPDATA_EMPID],self.currentStore.Id,self.m_currentAcvt.acvtId];
}

/*
 用于在当前页面上传后，再次上传数据不覆盖问题.
 */
- (void)changeMd5WhenUploadFinish {
    
    NSDictionary* md5Param=nil;
    if ([self respondsToSelector:@selector(md5Param)]) {
        md5Param = [self performSelector:@selector(md5Param)];
    }
    [self createMD5With:md5Param];
    [self.model createMD5With:[self.model md5Param]];
}

- (NSString *)getAcvtNameWithValueDic:(NSDictionary *)dic
{
    NSMutableString *acvtName = nil;
    
    NSMutableArray *acvtNameArray = [NSMutableArray array];
    
    for (WSAcvtBean_qst *qst in ((WSAcvtModel *)self.model).currentAcvtBean.qsts) {
        if ([qst.isAcvtName isEqualToString:@"1"]) {
            [acvtNameArray addObject:qst];
        }
    }
    
    if ([acvtNameArray count] > 0) {
        acvtName = [NSMutableString string];
        for (WSAcvtBean_qst *qst in acvtNameArray) {
            NSString *key = [NSString stringWithFormat:@"%@%@",qst.qstType, qst.acvtQstId];
            NSString *value = [dic objectForKey:key];
            if ([value length] > 0) {
                if ([acvtName length] > 0) {
                    [acvtName appendString:@" "];
                }
                [acvtName appendString:value];
            }
        }
    }
    
    if ([acvtName length] > 0) {
        return acvtName;
    }else {
        return nil;
    }
}

- (void)clearDatasWhenBackAction {
    
    [self deleteANNewAddWhenBack];
}

- (void)saveANDeleteWhenUpload
{
    for (WSWidget *widget in self.acvtview.widgetArray) {
        if ([widget isKindOfClass:[WSANNestedAcvtPanel class]]) {
            WSANNestedAcvtPanel *panel = (WSANNestedAcvtPanel *)widget;
            [panel saveDeleteWhenUpload];
        }
    }
}

- (void)deleteANNewAddWhenBack
{
    for (WSWidget *widget in self.acvtview.widgetArray) {
        if ([widget isKindOfClass:[WSANNestedAcvtPanel class]]) {
            WSANNestedAcvtPanel *panel = (WSANNestedAcvtPanel *)widget;
            [panel deleteNewAddDatasWhenRevert];
        }
    }
}

- (BOOL)uploadAcvtDatas
{
    LogTrace();
    
    
    if (self.isGpsReady) {
        [self addGPSData];
    }
    [self initANOfUploadDatasBeforeUpload];
    
     [self saveANDeleteWhenUpload];
    
    WSAcvtModel *model = (WSAcvtModel *)self.model;
    
    BOOL hasPhoto = [self.photoBrowseView.imageIDArray count] > 0? YES:NO;
    NSString *notifyID = [NSString stringWithFormat:@"%@%@", kOfflineTableNotifyIdPrefix, [WSJSONBuilder gen_uuid]];
    if ([model isFromNewAddList]) {
        if (self.currentNewStore.Id) {
            /*当前问卷的currentNewStore存在   则是新增的对店的店（调查问卷）按新增店的逻辑处理*/
            notifyID = [NSString stringWithFormat:@"%@%@", kOfflineTableNotifyIdPrefix_ModifyAddedNewStore, [WSJSONBuilder gen_uuid]];
        }else {
            notifyID = [NSString stringWithFormat:@"%@%@", kOfflineTableNotifyIdPrefix_AddedNewsAcvt, [WSJSONBuilder gen_uuid]];
        }
        
    }
    
    // 如果点击的是"开始拜访" || "删除门店"按钮，则注册返回当前页面的通知
    if ([model isSynchronizeRequest]) {
        //SFA-26701
        [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"uploading_prompt", nil)  tips:NSLocalizedString(@"please_wait", nil) tapTarget:self action:nil];
        if (self.currentUploadActionType == WSVisitActionType) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadBeginToVisitStoreDataFinish:) name:notifyID object:nil];
        } else if (self.currentUploadActionType == WSDeleteActionType) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteNewAddStoreFinish:) name:notifyID object:nil];
        }else {
            notifyID = [NSString stringWithFormat:@"%@%@", notifyID, kForcibleSynchronizeRequest];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadDatasFinish:) name:notifyID object:nil];
        }
    }
    else//SFA-19722 2018-05-09(阻塞模式与非阻塞模式都需要执行block()脚本 同安卓一致)
        [self.acvtview checkLuaScriptBlock];
    
    NSString *md5String = model.md5;
    NSString *newAcvtMD5 = nil;
    BOOL isSubAcvtNewId = NO;
    
    if (model.currentFuncs.opt.isUseNewId && (self.updateGenID && [self.updateGenID length] > 0)) {
        
        if ([model.currentFuncs.opt.isUseNewId isEqualToString:@"Y"]) { //配置成Y，按规则生成新id
            
            md5String = [[NSString stringWithFormat:@"%@_%@_%@_%@",model.currentFuncs.fc,model.md5,model.currentAcvtBean.acvtId,[WSAppData getObjectbyKey:APPDATA_EMPID]] md5];
            newAcvtMD5 = md5String;
            isSubAcvtNewId = YES;
            
        }else if ([model.currentFuncs.opt.isUseNewId isEqualToString:@"E"]) { //配置成E，每次生成一个新的唯一id
            
            md5String = [[NSString stringWithFormat:@"%@_%@_%@_%@",model.currentFuncs.fc,model.md5,model.currentAcvtBean.acvtId,[WSCurrentTime getDateTime]] md5];
            newAcvtMD5 = md5String;
            isSubAcvtNewId = YES;
            
        }else if ([model.currentFuncs.opt.isUseNewId isEqualToString:SUB_ACVT_USER_NEWID]) {
            isSubAcvtNewId = YES;
            
        }
    }
    
    NSArray *tableDatas = [self getTableDatasWithNewAcvtMD5:newAcvtMD5];
    NSMutableDictionary *qstValuesDic =  (NSMutableDictionary *)[self.acvtview getAllPrepareSubmitData];
    
    //阻塞模式上传时，上传成功后再插入数据库
    if (![model isSynchronizeRequest]) {
        if (![model saveAcvtDatasToDB:qstValuesDic useNewMd5:nil]) {
            return NO;
        }else{
            [self saveTBAcvtDatasToDB];
        }
        
    }
    
    if (isSubAcvtNewId) {
        //处理嵌套问卷的genid,也要重新生成
        [self processNestAcvtGenIdWhenNewId:qstValuesDic];
    }
    
    /*插入TA表格数据*/
    if (self.currentUploadActionType != WSDeleteActionType) {
        [self insertTATableDatas];
    }
    
    //TODO othersDic待重构，包含了AN类型
    
    NSString *acvtName = [self getAcvtNameWithValueDic:qstValuesDic];
    if (acvtName) {
        if (!self.m_othersDic) {
            self.m_othersDic = [NSMutableDictionary dictionaryWithCapacity:1];
        }
        [self.m_othersDic setObject:acvtName forKey:@"acvtName"];
    }
    
    NSMutableDictionary *deleteDic = [self.acvtview getPrepareDeleteAcvtNewStoreSubmitData];
    NSString* postData = nil;
    if (self.currentUploadActionType == WSDeleteActionType) {
        NSString *delReason = nil;
        if (self.sumbitWithReason) {
            delReason = self.delReasonAlert.textField.text;
        }
        postData = [WSJSONBuilder buildDeleteAcvtDatasbyFuncs:model.currentFuncs acvt:model.currentAcvtBean isPhoto:hasPhoto Store:model.currentStore qstValuesDic:deleteDic md5:md5String submitId:model.md5 Others:self.m_othersDic addedAcvtForStore:model.currentNewStore tableDatas:tableDatas delReason:delReason];
    } else {
        
        NSString *photoNames = [self generatePhotoNamesData];
        
        id store = model.currentStore ?:self.currentSubEmpStore;
        if (self.hosBean) {
            store = self.hosBean;
        }
        
        NSString *subempId = self.currentSubEmpStore ?self.currentSubEmpStore.Id :self.submitempid;
        postData = [WSJSONBuilder buildAcvtDatasbyFuncs:model.currentFuncs
                                                   acvt:model.currentAcvtBean
                                                isPhoto:hasPhoto
                                                  Store:store
                                           qstValuesDic:qstValuesDic
                                                    md5:md5String
                                               submitId:model.md5
                                                 Others:self.m_othersDic
                                      addedAcvtForStore:model.currentNewStore
                                             tableDatas:tableDatas
                                             photoNames:photoNames
                                              isNeedAdd:NO
                                                  isAdd:NO
                                          subempStoreId:subempId];
        
        if ([model.extralData length] > 0) {
            NSMutableDictionary *dic = [postData mutableObjectFromJSONString];
            [dic setObject:model.extralData forKey:@"extralData"];
            postData = [dic JSONString];
        }
        
        //MENGNIU-1414 2017-11-22
        if(model.confirm && [model.confirm length] > 0)
        {
            NSMutableDictionary *dic = [postData mutableObjectFromJSONString];
            [dic setObject:model.confirm forKey:@"confirm"];
            postData = [dic JSONString];
            
            ((WSAcvtModel *)self.model).confirm = nil;
        }
    }
    //非阻塞模式直接将请求数据添加到本地数据库
//    if (![model isSynchronizeRequest]) {
        BOOL insertAcvtDataIsSucceed = [self insertUploadData:postData URL:URL_UPLOAD MD5:model.md5 IsPhoto:hasPhoto NotifyName:notifyID];
        if (!insertAcvtDataIsSucceed)
            return insertAcvtDataIsSucceed;
//    }
    
    WSRequestHelper * helper = [WSRequestHelper shareInstance];
    [helper postRequestAcvtData:postData notifyName:notifyID md5:model.md5 isSynchronizeRequest:[model isSynchronizeRequest]];
    
//    [helper setRequsetFinish:^{
//        LogInfo(@"同步请求数据回调，无论成功失败都回调，防止网络失败传trax的图片丢失");
//        if (model.isSynchronizeRequest) {
//           BOOL insertAcvtDataIsSucceed = [self insertUploadData:postData URL:URL_UPLOAD MD5:model.md5 IsPhoto:hasPhoto NotifyName:notifyID];
//            if (insertAcvtDataIsSucceed) {
//                LogInfo(@"同步请求数据插入成功");
//                if (hasPhoto) {
//                    [self uploadPhotos];
//                }
//            }
//        }
//    }];
    
    
    //上传删除的照片
    if (![self uploadNewAcvtDeletePhotos])
        return NO;
    
    if (self.currentFuncs.opt.isSaveData_back)
    {
        WSBaseStoreOtherDataDBService *service = [[WSBaseStoreOtherDataDBService alloc]init];
        [service deleteWithStoreId:self.currentStore.Id withFc:self.currentFuncs.fc withAcvtId:self.m_currentAcvt.acvtId withEmpId:self.model.currentSubEmpStore.Id];
    }
    self.anJsonDataDictionary = nil;

    
    
    return YES;
}

#pragma mark--------更新付费陈列、主货架、二次陈列本地逻辑
- (void)updateExitUpLoadAction {
    
    WSAcvtModel *model = (WSAcvtModel *)self.model;
    BOOL isUpdateOrangeAcvtDis = NO;
    for (WSAcvtBean_qst *qst in model.currentAcvtBean.qsts) {
        
        if ([qst.isAcvtName isEqualToString:@"17"]) {
            isUpdateOrangeAcvtDis = YES;
            break;
        }
    }
    
    WSBaseStoreAcvtDisTable *acvtdisTable = [WSBaseStoreAcvtDisTable sharedTable];
    NSString *acvtId = [[[WSSqliteUtil alloc] init] queryTableInfoWithSql:
                        [NSString stringWithFormat:@"select _id from base_acvt where acvtCode = 'searchStore'"]];
    if (!acvtId) {
        return;
    }
    
    NSString *qstId = [[[WSSqliteUtil alloc] init] queryTableInfoWithSql:
                       [NSString stringWithFormat:@"select _id from base_acvt_qst where qstCod = 'storeStatus'"]];
    if (!qstId) {
        return;
    }
   
    if (isUpdateOrangeAcvtDis) {
        
//        NSMutableArray * insertOrangeArray = [NSMutableArray arrayWithCapacity:0];
//        NSMutableDictionary * acvtdisDic =[NSMutableDictionary dictionaryWithCapacity:0];
//        NSString * orangeId = [[[WSSqliteUtil alloc]init] queryTableInfoWithSql:[NSString stringWithFormat:@"select _id from base_acvt_qst_opt where optName = '完美已采集'"]];
//        if (orangeId==nil)return;
//        [acvtdisDic setValue:model.currentStore.Id forKey:@"sid"];
//        [acvtdisDic setValue:acvtId forKey:@"acvtid"];
//        [acvtdisDic setValue:qstId forKey:@"acvtQstid"];
//        [acvtdisDic setValue:model.currentStore.empId forKey:@"empId"];
//        [acvtdisDic setValue:@"storeacvtdis:searchStore" forKey:@"server_node"];
//        [acvtdisDic setValue:@"完美已采集" forKey:@"opt_value"];
//        [acvtdisDic setValue:orangeId forKey:@"acvt_qst_answer"];
//        [insertOrangeArray addObject:acvtdisDic];
//        [acvtdisTable insertAcvtDisDatasWith:insertOrangeArray];
    }
    else{
        if ([self.currentVisitAction.fromModuleName isEqualToString:kHelpSales_Name]) {
            LogInfo(@"助销模块不需要插入今日已访和本月已访数据");
            return;
        }
        NSString *todayId = [[[WSSqliteUtil alloc]init] queryTableInfoWithSql:
                             [NSString stringWithFormat:@"select _id from base_acvt_qst_opt  where optName = '今日拜访'"]];
        //判断是否是无效拜访
        double enterStoretime = [self.currentStore.inTime doubleValue];
        double outStoretime = [self.currentStore.outTime doubleValue];
        double inStoreTime = outStoretime - enterStoretime;
        BOOL isInvalidVisit = NO;
        NSString *role = [WSAttanceViewModel getLoginUserRole];
        
        if (inStoreTime < 5 * 60 && [role isEqualToString:@"销售代表"]) {
            todayId = [[[WSSqliteUtil alloc] init] queryTableInfoWithSql:
                       [NSString stringWithFormat:@"select _id from base_acvt_qst_opt  where optName = '无效拜访'"]];
            isInvalidVisit = YES;
        }
        
        if (!todayId) {
            return;
        }
        
        NSString *monthId = [[[WSSqliteUtil alloc] init] queryTableInfoWithSql:
                             [NSString stringWithFormat:@"select _id from base_acvt_qst_opt  where optName = '本月已访'"]];
        if (!monthId) {
            return;
        }
        
        NSMutableArray *insertArray = [NSMutableArray arrayWithCapacity:0];
        NSMutableDictionary *acvtdisDic =[NSMutableDictionary dictionaryWithCapacity:0];
        [acvtdisDic setValue:[NSString stringWithFormat:@"%@",model.currentStore.Id] forKey:@"sid"];
        [acvtdisDic setValue:acvtId forKey:@"acvtid"];
        [acvtdisDic setValue:qstId forKey:@"acvtQstid"];
        [acvtdisDic setValue:[NSString stringWithFormat:@"%@",model.currentStore.empId] forKey:@"empId"];
        [acvtdisDic setValue:@"storeacvtdis:searchStore" forKey:@"server_node"];
        if (isInvalidVisit) {
            [acvtdisDic setValue:@"无效拜访" forKey:@"opt_value"];
        }
        else {
            [acvtdisDic setValue:@"今日已访" forKey:@"opt_value"];
        }
        [acvtdisDic setValue:todayId forKey:@"acvt_qst_answer"];
        [insertArray addObject:acvtdisDic];
        [acvtdisTable insertAcvtDisDatasWith:insertArray];
        
        NSMutableArray *insertMothArray = [NSMutableArray arrayWithCapacity:0];
        NSMutableDictionary *acvtdisDic_month =[NSMutableDictionary dictionaryWithCapacity:0];
        [acvtdisDic_month setValue:acvtId forKey:@"acvtid"];
        [acvtdisDic_month setValue:qstId forKey:@"acvtQstid"];
        [acvtdisDic_month setValue:model.currentStore.Id forKey:@"sid"];
        [acvtdisDic_month setValue:model.currentStore.empId forKey:@"empId"];
        [acvtdisDic_month setValue:@"storeacvtdis:searchStore" forKey:@"server_node"];
        [acvtdisDic_month setValue:@"本月已访" forKey:@"opt_value"];
        [acvtdisDic_month setValue:monthId forKey:@"acvt_qst_answer"];
        [insertMothArray addObject:acvtdisDic_month];
        [acvtdisTable insertAcvtDisDatasWith:insertMothArray];
    }
}

- (void)processNestAcvtGenIdWhenNewId:(NSMutableDictionary *)dic
{
    //处理嵌套问卷的genid,也要重新生成
    NSArray *allKeys = [dic allKeys];
    for (NSString *key in allKeys) {
        if ([key hasPrefix:@"AN"] || [key hasPrefix:@"AM"]) {
            id obj = dic[key];
            NSArray *dataArray;
            BOOL isJson = NO;
            if ([obj isKindOfClass:[NSArray class]]) {
                dataArray = obj;
            }else if ([obj isKindOfClass:[NSString class]]) {
                dataArray = [obj objectFromJSONString];
                isJson = YES;
            }
            
            NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:dataArray.count];
            
            for (NSDictionary *dic in dataArray) {
                NSMutableDictionary *newDic = [dic mutableCopy];
                if ([newDic objectForKey:@"id"]) {
                    NSString *md5 = [[[WSJSONBuilder gen_uuid] md5] lowercaseString];
                    [newDic setObject:md5 forKey:@"id"];
                    [newArray addObject:newDic];
                }else {
                    [newArray addObject:dic];
                }
            }
            
            if (isJson) {
                [dic setObject:[newArray JSONString] forKey:key];
            }else {
                [dic setObject:newArray forKey:key];
            }
            
        }
    }
}

- (BOOL)newAcvtHasPhoto {
    for (WSWidget *tmpWidget in  self.acvtview.widgetArray) {
        if ([tmpWidget isKindOfClass:[WSPhotoViewPanel class]]) {
            WSPhotoBrowseView *photoBrowseView = [(WSPhotoViewPanel *)tmpWidget photoView];
            if ([photoBrowseView.imageIDArray count] > 0) {
                return YES;
            }
        }
    }
    return NO;
}


- (NSMutableDictionary *)getNewAcvtGpsInfo {
    for (WSWidget *tmpWidget in  self.acvtview.widgetArray) {
        
        if ([tmpWidget isKindOfClass:[WSMapPanel  class]]) {
            NSMutableDictionary *value = (NSMutableDictionary *)[tmpWidget getResultDirectly];
            WSMapPanel *mapPanel = (WSMapPanel *)tmpWidget;
            if (mapPanel.isGpsReady) {
                return value;
                break;
            }
        } else if ([tmpWidget isKindOfClass:[WSHidedMapPanel class]]) {
            NSMutableDictionary *value = (NSMutableDictionary *)[tmpWidget getResultDirectly];
            WSHidedMapPanel *mapPanel = (WSHidedMapPanel *)tmpWidget;
            if (mapPanel.isGpsReady) {
                return value;
                break;
            }
        }
    }
    return nil;
}

- (NSObject *)getNewAcvtMapPanelView
{
    for (WSWidget *tmpWidget in  self.acvtview.widgetArray) {
        
        if ([tmpWidget isKindOfClass:[WSMapPanel  class]]) {
            WSMapPanel *mapPanel = (WSMapPanel *)tmpWidget;
            return mapPanel;
        } else if ([tmpWidget isKindOfClass:[WSHidedMapPanel class]]) {
            WSHidedMapPanel *mapPanel = (WSHidedMapPanel *)tmpWidget;
            return mapPanel;
        }
    }
    return nil;
}

- (BOOL)uploadNewAcvtDeletePhotos {
    for (WSWidget *tmpWidget in  self.acvtview.widgetArray) {
        if ([tmpWidget isKindOfClass:[WSPhotoViewPanel class]]) {
            
            for (NSArray *tmpArray in [(WSPhotoViewPanel *)tmpWidget delPhotoBrowses]) {

                NSMutableArray* imageIds = [tmpArray objectAtIndex:1];
                for (NSString *imageID in imageIds) {
                    NSString *imageIndex = (NSString *)[tmpWidget getResultDirectly];
                    
                    NSString *flag = [tmpWidget.xbuildInfo getPhotoIsCoverNewId];
                    if (!([flag isEqualToString:@"1"] && [WSPhotoLogicService isServerRedisPhoto:imageID])) {
                        if (![self deleteImageIDX:imageIndex andImageID:imageID]) {
                            return NO;
                        }
                    }
                }
            }
        }
    }
    return YES;
}

// 删除本地 及后台照片
-(BOOL)deleteImageIDX:(NSString *)imageIndex andImageID:(NSString *)imageID{
    
    
    NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];

    if (imageIndex.length == 0 && imageID.length > 0) {
        NSArray * array =  [[WSImagePathTable sharedTable] queryAndReturnInfosBySql:[NSString stringWithFormat:@"select IMG_IDX img_idx from wch_imagePath where IMG_PATH  = '%@' ",imageID] andClassName:@"WSImagePathObject"];
        if (array.count > 0) {
            WSImagePathObject  * object= [array firstObject];
            imageIndex = object.img_idx;
        }else{
            imageIndex = @"";
        }
    }else if (imageIndex.length > 0 && imageID.length == 0){
        NSArray * array =  [[WSImagePathTable sharedTable] queryAndReturnInfosBySql:[NSString stringWithFormat:@"select IMG_PATH img_path  from wch_imagePath where IMG_IDX  = '%@' ",imageIndex] andClassName:@"WSImagePathObject"];
        if (array.count > 0) {
            WSImagePathObject  * object= [array firstObject];
            imageID = object.img_path;
        }else{
            imageID = @"";
        }
    }
    
    
    if (imageIndex.length > 0 && imageID.length > 0) {
        
        [[WSImagePathTable sharedTable] deleteWithImageIDX:imageIndex withImgKey:imageID];
        
        NSString *photoKey = imageID;
        if ([WSPhotoLogicService isServerRedisPhoto:imageID]) {
            photoKey = [WSPhotoLogicService getPhotoKeyFromServerRedisValue:imageID];
        }
        
        NSDictionary *params = [WSJSONBuilder buildDelImageParamsDicByImageID:photoKey withImgIdx:imageIndex];
        
        BOOL insertAcvtDataIsSucceed = [self insertUploadData:[params JSONString] URL:URL_UPLOAD MD5:imageIndex IsPhoto:NO NotifyName:notifyID];
        if (!insertAcvtDataIsSucceed) {
            return insertAcvtDataIsSucceed;
        }
        
        /*用新md5 当此self.isUsingNewMd5OnlyToSaveDataWhenAcvtHasCalendar 为YES的时候 紧保存数据 不上传数据*/
        if (self.operationAcvtType == WSOnlySaveAcvtDataForCalendarType) {
            
        }else {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletePhotoFinish:) name:notifyID object:nil];
            [[WSRequestHelper shareInstance] uploadDatasDictionary:params urlString:URL_UPLOAD notifyName:notifyID md5:self.model.md5 isUpload:YES];
        }
    }
    
    return YES;
}

- (BOOL)uploadOnePhotoWithFilePath:(NSString *)filePath imageIndex:(NSString *)imageIndex imageID:(NSString *)imageID{
    
    NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
    
    NSDictionary *params = [WSJSONBuilder buildImageParamsDicByImageID:imageID];
    
    //YIHAIKERRY-4758
    NSString *photoKey = [params objectForKey:@"photoKey"];
    NSString *photoName = [self setupCustomPhotoNameWithPhotoKey:photoKey isReady:NO];
    if (photoName && photoName.length > 0) {
        [params setValue:photoName forKey:@"photoName"];
    }
    
    NSString *photoFileName = [[SDImageCache sharedImageCache] cacheFileNameForKey:imageID];
    
    BOOL insertPhotoDataIsSucceed = [self insertUploadMedia:[params JSONString] Type:kOfflineTableDataType_P URL:URL_IMAGEUPLOAD MD5:imageIndex IsPhoto:YES NotifyName:notifyID photoFileName:photoFileName];
    if (!insertPhotoDataIsSucceed) {
        return NO;
    }
    
    if (self.operationAcvtType == WSOnlySaveAcvtDataForCalendarType) {
        /*当调查问卷有Cal (日历)类型问题时,调用updateCalendarData:方法时触发此条件*/
    }else {
        [[WSRequestHelper shareInstance] uploadImageWithFilePath:filePath
                                                          params:params
                                                             url:URL_IMAGEUPLOAD
                                                      notifyName:notifyID
                                                             md5:imageIndex];
    }
    
    return YES;
    
}

- (BOOL)uploadAndSavePhotosWithImageIndex:(NSString *)imageIndex imageIDArray:(NSArray *)imageIDArray photoIsCoverFlag:(NSString *)photoIsCoverFlag isUpload:(BOOL)isUpload{
    
    NSMutableArray *dicValueArrayAcvt = [[NSMutableArray alloc] init];
    
    for (NSString *imageID in imageIDArray) {
        NSString *filePath = [[SDImageCache sharedImageCache] imagePathFromKey:imageID];
        if (filePath) {
            
            NSString *photoKey = imageID;
            NSString *realFilePath = filePath;
            
            if ([(WSAcvtModel *)self.model isNeedNewImageIndex]) {
                
                UIImage *originImage = [[SDImageCache sharedImageCache] imageFromKey:imageID fromDisk:YES];
                
                if (originImage) {
                    
                    NSString *newPhotoKey = [[[WSJSONBuilder gen_uuid] md5] lowercaseString];
                    NSNumber *imgCompress = [[NSUserDefaults standardUserDefaults] objectForKey:@"ImgCompress"];
                    [[SDImageCache sharedImageCache] storeImage:originImage imageImgCompress:imgCompress forKey:newPhotoKey toDisk:YES toDocument:YES isSynchronized:YES];
                    
                    NSString *localFilePath = [[SDImageCache sharedImageCache] imagePathFromKey:newPhotoKey];
                    if (localFilePath) {
                        
                        photoKey = newPhotoKey;
                        realFilePath = localFilePath;
                        
                    }
                }
                
            }
            if (isUpload) {
                if (![self uploadOnePhotoWithFilePath:realFilePath imageIndex:imageIndex imageID:photoKey]) {
                    return NO;
                }
            }
            NSArray* array=[NSArray arrayWithObjects:imageIndex,photoKey,[WSAppData getObjectbyKey:APPDATA_BIZDATE],[WSCurrentTime getDateTime],@"0",nil];
            
            [dicValueArrayAcvt addObject:array];
            
        }else {
            
            NSString *flag = photoIsCoverFlag;
            if ([flag isEqualToString:@"1"]) { //flag为1时，服务器回显照片重新生成photokey,并重新上传。
                
                UIImage *serverImage = [[SDImageCache sharedImageCache] imageFromKey:[WSPhotoLogicService getPhotoKeyFromServerRedisValue:imageID] fromDisk:YES];
                
                if (!serverImage) {
                    NSString *localImageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:[WSHttpURLHelper getImageCompleteURL:[WSPhotoLogicService getPhotoURLFromServerRedisValue:imageID]]]];
                    serverImage = [[SDImageCache sharedImageCache] imageFromKey:localImageKey];
                }
                
                if (serverImage) {
                    
                    NSString *newPhotoKey = [[[WSJSONBuilder gen_uuid] md5] lowercaseString];
                    NSNumber *imgCompress = [[NSUserDefaults standardUserDefaults] objectForKey:@"ImgCompress"];
                    [[SDImageCache sharedImageCache] storeImage:serverImage imageImgCompress:imgCompress forKey:newPhotoKey toDisk:YES toDocument:YES isSynchronized:YES];
                    
                    NSString *filePath = [[SDImageCache sharedImageCache] imagePathFromKey:newPhotoKey];
                    if (filePath) {
                        if (isUpload) {
                            if (![self uploadOnePhotoWithFilePath:filePath imageIndex:imageIndex imageID:newPhotoKey]) {
                                return NO;
                            }
                        }
                        NSArray* array=[NSArray arrayWithObjects:imageIndex,newPhotoKey,[WSAppData getObjectbyKey:APPDATA_BIZDATE],[WSCurrentTime getDateTime],@"0",nil];
                        [dicValueArrayAcvt addObject:array];
                        
                    }
                }
                
                
            }else {
                if ([WSPhotoLogicService isServerRedisPhoto:imageID]) {
                    
                    NSArray *array = [NSArray arrayWithObjects:imageIndex,imageID,[WSAppData getObjectbyKey:APPDATA_BIZDATE],[WSCurrentTime getDateTime],@"0",nil];
                    [dicValueArrayAcvt addObject:array];
                }
            }
        }
    }
    
    if (dicValueArrayAcvt && [dicValueArrayAcvt count] > 0) {
        [[WSImagePathTable sharedTable] updateWithImageIDX:imageIndex withValuesArray:dicValueArrayAcvt];
    }
    else
    {
        [[WSImagePathTable sharedTable] deleteWithImageIDX:imageIndex];
    }
    
    return YES;
}

#pragma mark--------网路请求失败的情况下，也触发一次上传trax-----
- (void)p_noNetAndNetErrorUploadTrax{
    LogInfo(@"网络请求失败条件下触发一次trax的上传，是为了离线存储一次");
    WSAcvtModel *model = (WSAcvtModel *)self.model;

    NSString *imageIndex = [WSPhotoLogicService getAcvtImageIndexWithFC:self.currentFuncs.fc acvtMD5:model.md5 acvtQstId:self.m_currentAcvt.acvtId];
   
    //acvt中的问题为拍照
    for (WSPhotoViewPanel *photoViewPanel in self.acvtview.photoBrowseViewArray) {
        
        if (!photoViewPanel.photoView) {
            continue;
        }
        
        imageIndex = (NSString *)[photoViewPanel getResultDirectly];
        
        /*进店和调查问卷传照片格式不一样 用作进店改为调查问卷格显示*/
        if ([self isKindOfClass:[WSEnterStoreAcvtViewController class]] || [self isKindOfClass:[WSLeaveStoreAcvtViewController class]]) {
            imageIndex = [NSString stringWithFormat:@"%@_%@_%@",self.currentFuncs.fc,self.currentFuncs.fv,self.model.md5];
        }
        //
        if ([photoViewPanel.photoView.pz_type isEqualToString:@"3"]||[photoViewPanel.photoView.pz_type isEqualToString:@"2"]  ) {
            //上传到拍拍赚
            [self uploadAndSavePhotosWithImageIndex:imageIndex imageIDArray:photoViewPanel.photoView.imageIDArray photoIsCoverFlag:[photoViewPanel.xbuildInfo getPhotoIsCoverNewId] isUpload:NO];
            [[WSPaiPaiManager sharedInstance] uploadPPzImagesWithImageIndex:imageIndex];

        }
    }
}

- (void)excuseFromServer:(NSString *)param{
    NSDictionary * dic = [param objectFromJSONString];
    [self realTimeRefreshAcvtDatas:dic];
}

- (void)doRealtimeRefreshAcvtDatasWithParamDic:(NSDictionary *)paramDic
{
    [WSDataSourceManager sharedInstance].currentActiveModel = self.model;
    [self realTimeRefreshAcvtDatas:paramDic];
}

- (void)realtimeRequestAcvtDataFinish:(id)sender {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:K_REAL_TIME_REFRESH_ACVT_DATA object:nil];
    
    NSDictionary *userInfo = [(NSNotification *)sender userInfo];
    NSString *info = [userInfo objectForKey:DATAS];
    NSDictionary *resultDic = [info objectFromJSONString];
    
    NSError *error = [resultDic objectForKey:ERROR];
    if (error && error.code != 0) {
        
        [MBProgressHUD hideHUDForView:kApplicationWinddow animated:YES];
        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil
                                 type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    if ([resultDic.allKeys containsObject:[self getObjID]]) {
        
        NSDictionary *tipDic = [resultDic[[self getObjID]] firstObject];
        if ([tipDic.allKeys containsObject:@"tip"]) {
            
            NSString *tipStr = [tipDic objectForKey:@"tip"];
            if (tipStr.length > 0) {
                
                [MBProgressHUD hideHUDForView:kApplicationWinddow animated:YES];
                
                __weak __typeof(self) weakSelf = self;
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:tipStr message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirm", nil)
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *_Nonnull action)
                                         {
                                             [weakSelf backToParent];
                                         }];
                [alertVC addAction:action];
                [self presentViewController:alertVC animated:YES completion:^{}];
                return;
            }
        }
    }
    
    [self accordingToIsBlockResetAcvtWidgetsReadonly:NO];
    
    ((WSAcvtModel *)self.model).isFromRealTimeData = YES; // WRIGLEY-1449 主线 修改门店中要显示修改前的数据 (利用实时获取的数据刷新列表控件的值)
    if (self.itemCode.length > 0) {
        ((WSAcvtModel *)self.model).updateGenId = self.itemCode;
        ((WSAcvtModel *)self.model).md5 = self.itemCode;
    }
    
    NSDictionary *dataInfo = resultDic;
    NSArray *allKeys = [dataInfo allKeys];
    BOOL isHasPrefix = NO;
    for (NSString *key in allKeys) {
        if ([key hasPrefix:STOREACVTDIS] || [key hasPrefix:ACVTDIS]) {
            isHasPrefix = YES ;
        }
    }
    
    if (!isHasPrefix) {
        dataInfo = [resultDic[[self getObjID]] firstObject];
    }
    
    if ([self.currentFuncs.opt.sendRequest isEqualToString:@"remote"] || [self.currentFuncs.opt.sendRequest isEqualToString:@"remoteAdd"]) {
        [MBProgressHUD hideHUDForView:kApplicationWinddow animated:YES];
        [self processAcvtRequestData:dataInfo remote:YES];
    } else {
        if (isHasPrefix) {
            [WSStoreDataProcessService processStoreInfoDataToDbWith:self.currentStore info:dataInfo genId:self.model.md5];
            if (!_scrollView) {
                [self setupViews];
            } else {
                [self reloadAcvtview];
            }
        } else {
            [self processAcvtRequestData:dataInfo remote:NO];
        }
    }
    
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:YES];
    [self.wcBaseViewdelegate refreshedAllSubviewsWithRealtimeDatas];
}

//有可能出现没有配置remote  但是也需要出现实时请求的情况，具体jira  MN-1844
- (void) processAcvtRequestData:(id)dataInfo remote:(BOOL)remote{
    NSDictionary *storeDicInfo = nil;
    
    if ([dataInfo isKindOfClass:[NSDictionary class]]) {
        storeDicInfo = (NSDictionary *)dataInfo;
    }else if ([dataInfo isKindOfClass:[NSArray class]]) {
        storeDicInfo = [(NSArray *)dataInfo firstObject];
    }
    
    //MN-4115 回显中有jsonType  需要用jsonType做个判断，将数据再剥一层
    for (NSString *key in [storeDicInfo allKeys]) {
        if ([key hasPrefix:STOREACVTDIS] || [key hasPrefix:ACVTDIS]) {
            NSArray *acvtDisDictsArray = storeDicInfo[key];
            NSDictionary *firstDisDic = [acvtDisDictsArray firstObject];
            if ([firstDisDic[@"jsonType"] isEqualToString:@"array"]){
                storeDicInfo = firstDisDic;
            }
            break;
        }
    }
    
    NSArray *allKeys = [storeDicInfo allKeys];
    
    // MN-760 新增调查问卷下，服务器实时返回acvtDis回显数据的genId
    NSString *realTimeAcvtDisGenId = nil;
    
    for (NSString *key in allKeys) {
        if ([key hasPrefix:STOREACVTDIS] || [key hasPrefix:ACVTDIS]) {
            NSArray *acvtDisDictsArray = [storeDicInfo objectForKey:key];
            NSDictionary *firstDisDic = [acvtDisDictsArray firstObject];
            realTimeAcvtDisGenId = [firstDisDic objectForKey:@"gen_id"];
            break;
        }
    }
    
    if (realTimeAcvtDisGenId && realTimeAcvtDisGenId.length > 0) {
        ((WSAcvtModel *)self.model).updateGenId = realTimeAcvtDisGenId;
        ((WSAcvtModel *)self.model).md5 = realTimeAcvtDisGenId;
    }

    [WSStoreDataProcessService processStoreInfoDataToDbWith:self.currentStore info:storeDicInfo genId:nil isRemoteSearch:remote];
    if (!_scrollView) {
        [self setupViews];
    }else
        [self reloadAcvtview];
}

-(void)reloadAcvtview{
    for (WSWidget *widget  in  self.acvtview.widgetArray) {
        NSObject *object = [widget.xdisplayValue getDisplayValueFor:widget.xbuildInfo];
        NSObject *defaultValue = [widget.xdisplayValue getDefaultValue:widget.xbuildInfo];
        // SFA-22935 安卓逻辑，只会加载回显值，不考虑默认值
        if ((object && ![object isEqual:defaultValue]) && [widget respondsToSelector:@selector(reloadCurrentWidgetWithValue:)]) {
            [widget reloadCurrentWidgetWithValue:object];
        }
    }
    
    /*刷新数据后 再执行脚本*/
    [self.acvtview executeLuaScriptWhenInitFinish];
}

//上传时需要生成新的id时，需要把新id传过来，重新生成表格id
- (NSArray *)getTableDatasWithNewAcvtMD5:(NSString *)acvtMd5
{
    NSMutableArray *tableDataArray = [NSMutableArray array];
    
    WSAcvtModel *model = (WSAcvtModel *)self.model;
    
    for(WSWidget *widget in self.acvtview.widgetArray) {
        // 在 acvt 中添加表格 TB 类型
        if ([widget isKindOfClass:[WSAcvtDataGridViewPanel class]]) {
            
            WSAcvtDataGridViewPanel *dataGridPanel = (WSAcvtDataGridViewPanel *)widget;
            
            //ACVT 类型时 不处理 uploadGridDataWhenDSIsAcvt方法中统一处理
            if ([[dataGridPanel getAcvtDataSource].currentTableItem.ds isEqualToString:DS_ACVT]) {
                continue;
            }
            
            if ([dataGridPanel xbuildInfo]!=nil) {
                
                NSObject<I_W_BuildInfo>   *buildInfo = [widget xbuildInfo];
                
                if (!([buildInfo getNeedUploadData].length > 0 && [[buildInfo getNeedUploadData] isEqualToString:@"0"])) {
                
                    NSString *tableMD5 = (NSString *)[dataGridPanel getResultDirectly];
                    
                    if ([acvtMd5 length] > 0) {
                        tableMD5 = [[dataGridPanel getAcvtDataSource] generateGridMd5WithAcvtGenid:acvtMd5];
                        [dataGridPanel getAcvtDataSource].md5 = tableMD5;
                    }
                    
                    /*删除已选中产品*/
                    [dataGridPanel.dataGridView removeDeletedProdsWhenUpload];
                    
                    [dataGridPanel getAcvtDataSource].isClear = NO;
                    
                    BOOL isIgnoreNullValue = ([dataGridPanel getAcvtDataSource].currentFunc.nullvalue == 1) ? NO : YES;
                    
                    NSString *postData = [WSAcvtDataGridHttpService getAcvtGridJsonDataWithDataSource:[dataGridPanel getAcvtDataSource] acvtMD5:model.md5 tableMD5:tableMD5 isIgnoreNullValue:isIgnoreNullValue];
                
                    NSDictionary *dataDic = [postData objectFromJSONString];
                    //添加store
                    if(dataDic){
                        NSMutableDictionary * adddataDic=[[NSMutableDictionary alloc]initWithDictionary:dataDic];
                        id store = [dataGridPanel getAcvtDataSource].currentStore ?:self.currentSubEmpStore;
                        if (self.hosBean) {
                            store = self.hosBean;
                        }
                        NSString * storeId=[self getStoreId:store];
                        [adddataDic setObject:storeId forKey:@"store"];
                        if (adddataDic) {
                            [tableDataArray addObject:adddataDic];
                        }
                    }

                }
            }
        }
    }
    
    if ([tableDataArray count] > 0) {
        return tableDataArray;
    }else {
        return nil;
    }
}

/*调查问问卷TA类型的表格数据插入数据库*/
- (void)insertTATableDatas {
    for (WSWidget *widget in  self.acvtview.widgetArray) {
        if ([widget isKindOfClass:[WSTAAcvtDataGridViewPanel class]]) {
            WSTAAcvtDataGridViewPanel *taPanel = (WSTAAcvtDataGridViewPanel *)widget;
            [WSAcvtDataGridComponentService insertTATableDataToDBWithTAPanel:taPanel];
        }
    }
    
}

- (BOOL)uploadPhotosForTable
{
    for(WSWidget *widget in self.acvtview.widgetArray) {
        // 在 acvt 中添加表格 TB 类型
        if ([widget isKindOfClass:[WSAcvtDataGridViewPanel class]]) {
            
            WSAcvtDataGridViewPanel *dataGridPanel = (WSAcvtDataGridViewPanel *)widget;
            
            NSString *tableMD5 = (NSString *)[dataGridPanel getResultDirectly];
            
            //ACVT 类型时 不处理 uploadGridDataWhenDSIsAcvt方法中统一处理
            if ([[dataGridPanel getAcvtDataSource].currentTableItem.ds isEqualToString:DS_ACVT]) {
                continue;
            }
            
            BOOL insertAcvtGridDataIsSucceed = [WSAcvtDataGridHttpService uploadAcvtGridPhotosWithDataSource:[dataGridPanel getAcvtDataSource] acvtMD5:self.model.md5 tableMD5:tableMD5 operationType:self.operationAcvtType];
            if (!insertAcvtGridDataIsSucceed) {
                return insertAcvtGridDataIsSucceed;
            }
        }
    }
    
    return YES;
}
#pragma mark - 表格为acvt类型时，表格转为问卷数据上传 SFA-31445
- (BOOL)uploadGridDataWhenDSIsAcvt
{
    
    for(WSWidget *widget in self.acvtview.widgetArray) {
        // 在 acvt 中添加表格 TB 类型
        if ([widget isKindOfClass:[WSAcvtDataGridViewPanel class]]) {
            WSAcvtDataGridViewPanel *dataGridPanel = (WSAcvtDataGridViewPanel *)widget;
            WSAcvtDataGridComponentDataSource  *acvtDataSource = [dataGridPanel getAcvtDataSource] ;
            if ([acvtDataSource.currentTableItem.ds isEqualToString:DS_ACVT]) {
                //上传问卷和图片 在工具中处理
                [acvtDataSource.acvtTypeDataSourceTool uploadAcvtGridDataWithGridWidgetsArray:acvtDataSource.data ];
            }
            else
            {
                [acvtDataSource.acvtTypeDataSourceTool uploadGridWidgetsArray:acvtDataSource.data ];

            }
            
        }
    }
    
    return YES;
}
#pragma mark -

//目前是执行puh和present操作，后续可以执行相关的其它操作，比如弹出模态窗口、后台服务、网页等相关操作,可再次重构。
-(void)executeAnyOperationWith:(WSInterAction *)interaction{
    
    if (interaction==nil) {
        
        return;
        
    }
    
    if ([interaction  direct_type]==DIRECT_TYPE_PRESENT || [interaction direct_type] ==DIRECT_TYPE_PUSH || [interaction direct_type] ==DIRECT_TYPE_POPOVER) {
        
        NSString *execute_class_name =   [interaction execute_class];
        
        WCBaseViewController  *execute_controller = nil;
        
        if (execute_class_name && [execute_class_name  isEqualToString:@"WSAddressSelectViewController"]) {
            NSDictionary *dic = (NSDictionary *)[interaction execute_class_param];
            execute_controller= [[NSClassFromString(execute_class_name) alloc] initWithPreInfoDic:dic];

            
        } else if (execute_class_name && [execute_class_name  isEqualToString:@"MoreProductViewController"]) {
           
            execute_controller = [[NSClassFromString(execute_class_name) alloc] initWithProductArray:nil title:(NSString *)interaction.execute_class_param_title];
        }else if (execute_class_name && [execute_class_name  isEqualToString:@"WSNewAddProdsWithSeriesViewController"]) {
            
            execute_controller = [[NSClassFromString(execute_class_name) alloc] init];
            execute_controller.title = (NSString *)interaction.execute_class_param_title;
            execute_controller.currentStore = self.currentStore;
        }
        else  {
            execute_controller = [[NSClassFromString(execute_class_name) alloc] init];
        }
        
        execute_controller.executeParam = interaction;
        
        execute_controller.wcBaseViewdelegate = self;
        
        if ([execute_controller isKindOfClass:[WSPhotoGalleryViewController class]]) {
            
            WSPhotoGalleryViewController *photoGalleryVC = (WSPhotoGalleryViewController *)execute_controller;
            photoGalleryVC.delegate = interaction.excute_class_delegate;
            if (interaction.execute_class_param_title) {
                photoGalleryVC.title = (NSString *)interaction.execute_class_param_title;
            }
        }
        
        if ([execute_controller isKindOfClass:[WSMultiSelectAndSearchViewController class]]) {
            
            WSMultiSelectAndSearchViewController *multiSelectAndSearchVC = (WSMultiSelectAndSearchViewController *)execute_controller;
            multiSelectAndSearchVC.selectedDelegate = interaction.excute_class_delegate;
            multiSelectAndSearchVC.selectedItemArray = (NSMutableArray *)interaction.execute_method_param;
            multiSelectAndSearchVC.title = (NSString *)interaction.execute_class_param_title;

        }
        
        execute_controller.currentStore=self.currentStore;
        if ([interaction  direct_type]== DIRECT_TYPE_PRESENT) {
            
            if (interaction.execute_controller) {
                if (self.isAsView) {
                    [[self getNavigationController] presentViewController:interaction.execute_controller animated:YES completion:nil];
                }
                else {
                    [self presentViewController:interaction.execute_controller animated:YES completion:nil];
                }
            }
            else {
                [self presentViewController:execute_controller animated:YES completion:nil];
            }
        }
        else if ([interaction direct_type] == DIRECT_TYPE_PUSH) {
            
            UIViewController *controller = interaction.execute_controller;
            if (!controller) {
                controller = execute_controller;
            }
            
            if ([self.parentViewController isKindOfClass:[WSPopViewController class]]) {
                UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:controller];
                [controller leftItemImage:@"icon_back" target:controller action:@selector(backAction)];
                [self.parentViewController presentViewController:navCon animated:YES completion:nil];
            }else {
                [self.navigationController pushViewController:controller animated:YES];

            }
            
        }else if ([interaction direct_type] == DIRECT_TYPE_POPOVER) {
            
            UIViewController *contentCon = interaction.execute_controller;
            if (!contentCon) {
                contentCon = execute_controller;
            }

            WSPopViewController *popCon = [[WSPopViewController alloc] initWithContentViewController:(WCBaseViewController *)contentCon];
            popCon.confirmSelector = @selector(executeUpload);
            popCon.delegate = self;
            popCon.wcBaseViewdelegate = self;
            
            if ([interaction.execute_class_param isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = (NSDictionary *)interaction.execute_class_param;
                if ([dic objectForKey:@"height"] && [dic objectForKey:@"width"]) {
                    popCon.popViewSize = CGSizeMake([[dic objectForKey:@"width"] floatValue], [[dic objectForKey:@"height"] floatValue]);
                }
            }
            
            
            if (IOS8_OR_LATER) {
                popCon.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            }else {
                
                if (self.wsSplitController) {
                    self.wsSplitController.modalPresentationStyle = UIModalPresentationCurrentContext;
                }else {
                    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
                }
            }
            
            UIViewController *presentingCon = self;
            
            if (self.wsSplitController) {
                presentingCon = self.wsSplitController;
            }
            
            [presentingCon presentViewController:popCon animated:YES completion:nil];
        }
        
        return;
    }
    
    if([interaction direct_type] ==DIRECT_TYPE_SHOW_IN_MAINVIEW ){
        
        WSWidget  *widget = [[NSClassFromString([interaction execute_class]) alloc] initWithFrame:ZERORECT];
        widget.delegate = self;
        [widget makeCurrentWidgetActivity:interaction];
        return;
    }
    
    if ([interaction direct_type] == DIRECT_TYPE_SERVICE_METHOD) {
        
        serviceDispatcher =[[WSServiceDispatcher alloc] init];
        [serviceDispatcher setDispatcherDelegate:self];
        [serviceDispatcher executeDispatcher:interaction];
        return;
    }
    
    if([interaction direct_type] == DIRECT_TYPE_METHOD_WITH_SINGLEPARAM ){
        
        if (interaction && interaction.execute_method != nil && [self respondsToSelector:interaction.execute_method]) {
            SuppressPerformSelectorLeakWarning(
                                               [self performSelector:interaction.execute_method withObject:interaction.execute_method_param];
                                               );
        }
    }
    if ([interaction direct_type] == DIRECT_TYPE_DISMISS) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}
#pragma mark-----付费陈列没有活动返回上个页面
- (void)backButtonClick{
    [self backToParent];
}
-(void)callBackWhenFinishTask:(WSInterAction *)interaction
{
    //MN-2540 2018-05-18
    if ([WSDataSourceManager sharedInstance].currentActiveModel == nil)
        [WSDataSourceManager sharedInstance].currentActiveModel = self.model;
    
    [self.acvtview applyData:interaction forExecuteWidget:[interaction acvt_qust_id]];
}

-(void)sendResultInterAction:(WSInterAction *)interaction{
}

-(void)serviceBeginExecute:(WSInterAction *)interaction{
}

-(void)serviceExecuteEnd:(WSInterAction *)interaction{
}

-(void)serviceInExecute:(WSInterAction *)interaction{
}

-(void)serviceExecuteEndWithError:(WSInterAction *)interaction{
}

//控件可能根据需求执行lua脚本
-(void)executeLuaScript:(NSObject<I_W_BuildInfo> *)buildInfo widget:(WSWidget *)widget {
    
    wsLuaExecutor =[WSLuaExecutorManager shareInstance];
    wsLuaExecutor.delegate = self;
    wsLuaExecutor.currentoperator = widget;
    [wsLuaExecutor executeLuaScript:[buildInfo getLuaScript] ];
}

#pragma mark - WSAcvtViewDelegate
- (void)setUploadButtonEnable:(BOOL)isEnable
{
    self.uploadBtnEnable = isEnable;
    self.uploadButton.enabled = isEnable;
}

- (void)setUploadButtonHidden:(BOOL)isHidden
{
    self.uploadBtnHidden = isHidden;
    
    NSArray *items = nil;
    if (!isHidden) {
        if (self.uploadButton) {
            items = @[self.uploadButton];
        }
//        SFA-24142 donghong
        if (self.barButtonItems && self.barButtonItems.count>0) {
            items = self.barButtonItems;
        }
    }
    [self setRightBarButtonItems:items];
}

- (void)addChildVC:(UIViewController *)vc isResetOffset:(BOOL)isResetOffset {
    [self addChildViewController:vc];
    [self.scrollView setIsResetOffset:isResetOffset];
}
#pragma mark - # 不同意获取用户信息
- (void)cancleAgreeCollectPrivacyPolicyMesage{
    [self popToParentOrHome];

}
- (NSString *)getObjIDByisFromScript:(BOOL)isFromScript
{
    //SFA-22722 2018-08-10
    if(isFromScript){
        return ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME;
    }
    
    if(self.objID && self.objID.length > 0){
        return self.objID;
    }
    if(self.currentFuncs.ds && (![self.currentFuncs.ds isEqualToString:@"acvt"])){
        return self.currentFuncs.ds;
    }
    if(self.currentStore.Id && (![self.currentStore.Id isEqualToString:@"-1"])){
        return ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME;
    }
    
    WSBaseAcvtdisDBService *acvtdisDBService = [[WSBaseAcvtdisDBService alloc] init];
    NSArray *acvtDisArray = [acvtdisDBService queryServerStoreAcvtDisBeanArrayWithStoreID:nil genID:self.model.md5];
    WSBaseStoreAcvtDisObject *acvtDis = [acvtDisArray firstObject];
    if(!acvtDis){
        return STOREACVTDIS;
    }
    return acvtDis.server_node;
}

- (NSString *)getObjID
{
    return [self getObjIDByisFromScript:NO];
}

/**
 生成photonames信息 --理文
 */
- (NSString *)generatePhotoNamesData{
    
    NSString *imageIndex = nil;
    NSMutableDictionary *photoNames = [NSMutableDictionary dictionary];
    NSArray * imageIDArray = nil;
    for (WSPhotoViewPanel *photoViewPanel in self.acvtview.photoBrowseViewArray) {
        if (!photoViewPanel.photoView) {
            continue;
        }
        
        if ([photoViewPanel isKindOfClass:[WSPhotoViewPanel class]]) {
            imageIDArray = photoViewPanel.photoView.imageIDArray;
        }
        
        if ([photoViewPanel isKindOfClass:[WSSignaturepanel class]]) {
            WSSignaturepanel * signaturePanel = (WSSignaturepanel *)photoViewPanel;
            imageIDArray = signaturePanel.imageIDArray;
        }
        
        if([photoViewPanel isKindOfClass:[WSImageViewPanel class]]){
            WSImageViewPanel * signaturePanel = (WSImageViewPanel *)photoViewPanel;
            imageIDArray =[NSArray arrayWithObject:signaturePanel.imageID];
        }
        
        imageIndex = (NSString *)[photoViewPanel getResultDirectly];
        NSArray *imageNamesArrary = [self getPhotoNameArrayByImageIDArray:imageIDArray];
        
        NSString *imageNames = [imageNamesArrary componentsJoinedByString:@","];
        if ([imageNames length] > 0) {
            [photoNames  setObject:imageNames forKey:imageIndex];
        }
    }
    if ([[photoNames allKeys] count] > 0) {
        return [photoNames JSONString];
    }
    return nil;
}

- (NSArray *)getPhotoNameArrayByImageIDArray:(NSArray *)imageIDArray {
    
    NSMutableArray *imageNamesArrary = [NSMutableArray array];
    for (NSString *imageId in imageIDArray) {
        NSString *imageName = nil;
        NSString *saasStr = @"";
        NSString *appId = @"";
        NSString *dateStr = @"";
        
        if ([WSEnvrionment getUseAliyun]) {
            saasStr = @"Saas/";
            appId = [NSString stringWithFormat:@"%@/", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]] ;
            dateStr = [NSString stringWithFormat:@"%@/", [WSCurrentTime getDateString]];
        }
        
        if ([imageId rangeOfString:@"@/media"].location != NSNotFound) {
            NSString *tmpImageId = [WSPhotoLogicService getPhotoKeyFromServerRedisValue:imageId];
            NSString *photoName = [self setupCustomPhotoNameWithPhotoKey:tmpImageId isReady:NO];
            NSString *linkStr = (photoName.length > 0) ? photoName : tmpImageId;
            imageName = [NSString stringWithFormat:@"%@%@%@%@%@", saasStr, appId, dateStr, linkStr, PHOTO_JPG_SUFFIX];
        } else {
            NSString *photoName = [self setupCustomPhotoNameWithPhotoKey:imageId isReady:NO];
            NSString *linkStr = (photoName.length > 0) ? photoName : imageId;
            imageName = [NSString stringWithFormat:@"%@%@%@%@%@", saasStr, appId, dateStr, linkStr, PHOTO_JPG_SUFFIX];
        }
        
        if (imageName) {
            [imageNamesArrary addObject:imageName];
        }
    }
    
    return imageNamesArrary;
}

#pragma mark - creatAnd
// 点击开始拜访按钮事件
- (void)beginToVisitStore:(NSString *)tips {
    [WSDataSourceManager sharedInstance].currentActiveModel = self.model;
    self.currentUploadActionType = WSVisitActionType;
    if ([self executeValidate]) {
        if ([tips length] == 0) {
            tips = NSLocalizedString(@"update_data_tip",nil);
        }
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tips  tips:nil tapTarget:self action:nil];
        
        /**
         如果新增的对调查问卷的门店存在 ，且其问题值未修改，则直接请求门店数据
         */
        WSBaseStoreDBService *service = [[WSBaseStoreDBService alloc] init];
        WSStoreBean *newStore = [service queryStoreByAcvtGenId:self.model.md5];
        if (self.model.currentNewStore && newStore && ![self isValueChange]) {
            
            self.model.currentNewStore = newStore;
            
            //拜访之前检测未离店
            WSInoutStoreObject *inOutStoreObj = [[WSInoutStoreTable sharedTable] anyStorehaveNotLeave];
            NSString *unLeavedStoreName = inOutStoreObj.memo1;
            if (unLeavedStoreName && [unLeavedStoreName length] > 0 &&
                ![self.model.currentNewStore.Id isEqualToString:inOutStoreObj.store_id] &&
                ![self.currentStore.Id isEqualToString:inOutStoreObj.store_id] &&
                ![self.currentFuncs.required isEqualToString:@"E"]) {
                
                [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
                NSString *LeaveString = NSLocalizedString(@"not_leave_store",nil);
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:[NSString stringWithFormat:@"%@%@",unLeavedStoreName,LeaveString] tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                return;
            }
            
            //请求过一次门店数据不再请求
            WSBaseStoreOtherDataDBService *baseStoreOtherDataDBService = [[WSBaseStoreOtherDataDBService alloc] init];
            NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
            BOOL isRequested = [baseStoreOtherDataDBService isStoreRequested:STORE_NOT_REQUEST empId:empId storeId:self.currentStore.Id];
            if (!isRequested) {
                isRequested = [baseStoreOtherDataDBService isStoreRequested:WSASVC_OUTPLANSTORE_REQUESTED_FLAG empId:empId storeId:self.currentStore.Id];
            }
            if (!isRequested) {
                [self startUpdataStoreInfosWith:self.model.currentNewStore.Id];
            }else {
                
                [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
                [self goAndCheckGoWorkFlowController:self.model.currentNewStore.Id msg:nil];
            }
            
            return;
        }
        [self executeRealUpload];
        /*上传后置为空*/
        [WSAppData putObject:@[] forKey:APPDATA_LOGIN_REDIRECT_FC];
        
    }else{
        self.currentUploadActionType = WSNormalActionType;
    }
}

// 点击开始拜访后请求数据完成
- (void)uploadBeginToVisitStoreDataFinish:(NSNotification *)notification {
    LogTrace();
    
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notification.name object:nil];
    
    NSString *info = [[notification userInfo] objectForKey:DATAS];
    NSDictionary *infoDic = [info objectFromJSONString];
    NSString *result = [infoDic objectForKey:@"result"];
    NSDictionary *resultDic = [result objectFromJSONString];
    
    BOOL isSucess = NO;
    BOOL isNeedVisit = NO;
    
    NSString *message = [NSString stringNotNilWithValue:[infoDic objectForKey:@"message"]];
    NSDictionary *resultDictioary = [result objectFromJSONString];
    NSString *flag = [NSString stringWithFormat:@"%@",[resultDictioary objectForKey:@"flag"]];
    if ([result isEqualToString:@"1"]) {
        isSucess = YES;
    }else if ([result isEqualToString:@"0"]) {
        isSucess = NO;
    }else if ([result isEqualToString:@"2"]){
        if ([flag isEqualToString:@"1"]) {
            isSucess = YES;
        }
        else if ([flag isEqualToString:@"0"]) {//失败
            isSucess = NO;
        }
    }
    else
    {

        if ([[resultDictioary allKeys] containsObject:@"msg"])
            message = [NSString stringWithFormat:@"%@" ,[resultDictioary objectForKey:@"msg"]];
        else if ([[resultDictioary allKeys] containsObject:@"message"])
            message = [NSString stringWithFormat:@"%@" ,[resultDictioary objectForKey:@"message"]];
        
        if ([flag isEqualToString:@"1"]) //成功
            isSucess = YES;
        else if ([flag isEqualToString:@"0"]) { //失败
            NSArray *sameStoreArray = [resultDictioary objectForKey:@"sameStoreList"];
            if (sameStoreArray) {
                [self showSameStoreList:sameStoreArray];
                return;
            }
            
            isSucess = NO;
        }
        else if([flag isEqualToString:@"4"]) //再次上传
            isSucess = NO;
    }
    NSString *storeId = @"-1";
    if (!isSucess) //失败
    {
        if ([flag isEqualToString:@"3"] || [flag isEqualToString:@"4"]) {
            self.currentUploadActionType = WSNormalActionType;
            [self resultExecuteUpload:((message.length > 0) ? message : NSLocalizedString(@"fail_upload", nil)) flag:flag];
        }
        else {
            [self resultExecute:message];
        }
    }
    else
    {
        if (!message || [message isKindOfClass:[NSNull class]] || [message length] == 0)
            message = NSLocalizedString(@"upload_success", nil);
    
        storeId = [NSString stringWithValue:[resultDic objectForKey:@"storeId"]];
    
        if ([(WSAcvtModel *)self.model isSynchronizeRequest])
            [self uploadPhotos];
        
        [self.acvtview checkLuaScriptBlock];
        
        if (self.currentUploadActionType == WSVisitActionType && [storeId length] > 0)
        {
            NSString *addType = [resultDic objectForKey:@"addtype"];
            if ([addType isEqualToString:@"5"])
            {
                WSBaseStoreDBService *service = [[WSBaseStoreDBService alloc] init];
                [service insertOrUpdateStoreWithDataDic:resultDic acvtGenId:self.model.md5];
            }
            
            WSStoreBean *visitStore = [[WSStoreBean alloc]init];
            NSString *code = [resultDic objectForKey:@"code"];
            NSString *name = [resultDic objectForKey:@"name"];
            NSString *type = [resultDic objectForKey:@"type"];
            NSString *msg = [resultDic objectForKey:@"msg"];
            
            visitStore.Id = storeId;
            visitStore.name = name;
            visitStore.styp = type;
            visitStore.code = code;
            
            NSString *isCoverStoreStr = [resultDic objectForKey:@"isCoverStore"];
            BOOL isCoverStore = [isCoverStoreStr isEqualToString:@"1"] ? YES : NO;
            
            if (self.currentStore && !isCoverStore)
            {
 
                if ([self.currentStore.Id isEqualToString:@"-1"]) {
                    self.model.currentStore = visitStore;
                    self.currentStore = visitStore;
                }
            
                self.model.currentNewStore = visitStore;
                [self insertNewStoreVisitActionToDbWith:self.model.currentNewStore.Id];
                [WSAcvtDataGridComponentService updateTATableUploadFlagWith:self.acvtview.widgetArray acvtNewStoreId:storeId];
            }
            else
                self.currentStore = visitStore;
            
            [self saveAcvtDatasToDB];
            [[NSNotificationCenter defaultCenter]postNotificationName:newStoreNotification object:nil]; // SFA 项目 SFA-4630   新增不上传 直接开始拜访 返回的时候应该有列表
            [self goAndCheckGoWorkFlowController:visitStore.Id msg:msg];
            isNeedVisit = YES;
        }
        else
        {
            [self saveAcvtDatasToDB];
            [[NSNotificationCenter defaultCenter]postNotificationName:newStoreNotification object:nil]; // SFA 项目 SFA-4630   新增不上传 直接开始拜访 返回的时候应该有列表
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ModifyStoreRefreshNotification object:nil];
        
        if (!isNeedVisit) // isNeedVisit 时需要在请求数据提示等待中
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:message tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        
        [self.vcTools removeSaveAcvtDataWithMD5:self.model.md5];
    }
    
    if (isSucess && !isNeedVisit && !self.model.uploadThenNotFinishView)
    {
        if ([self isKindOfClass:[WSAddNewStoreViewController class]] && (storeId.length < 1 || [storeId isEqualToString:@"-1"]))
            {
                [self.acvtview checkLuaScriptBlock];
                return;
            }
        [self popToParentOrHome];
    }
}

/*
 用于门店的拜访项下的新增门店
 */
- (void)insertNewStoreVisitActionToDbWith:(NSString *)storeId {
    WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
    action.parent_action_id = self.currentVisitAction.ID;
    action.store_id = self.currentStore.Id;
    action.dict_id = self.m_currentAcvt.acvtId;
    action.newstore_id= [NSString stringNotNilWithValue:storeId];
    action.func_code = self.currentFuncs.fc;
    action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
    action.title = self.model.md5;
    self.currentVisitAction = action;
}

// 点击开始拜访按钮发送的第二次请求
-(void)startUpdataStoreInfosWith:(NSString *)storeId
{
    LogTrace();
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishRequest:)
                                                 name:UPDATE_IMMEDIATELY_STORE_NOTIFY
                                               object:nil];
    [self querying_messageTips];

    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    [uploadMgr appUpdataManagerInfo:storeId withObjId: [self getObjIDByisFromScript:YES] notifyName:UPDATE_IMMEDIATELY_STORE_NOTIFY];
    
}


- (void)deletePhotoFinish:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:notification.name object:nil];
    
    NSString *info = [[notification userInfo] objectForKey:DATAS];
    NSDictionary *dic = [info objectFromJSONString];
    if ([[dic objectForKey:@"result"] isEqualToString:@"0"]) {
        [[WSOffLineUploadTable sharedTable] updateUploadFlagZeroWithNotifyId: notification.name];
    }
}

-(void)finishRequest:(id)sender
{
    LogTrace();
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UPDATE_IMMEDIATELY_STORE_NOTIFY
                                                  object:nil];
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:YES];
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    NSDictionary *uploadState = [info objectFromJSONString];
    if([uploadState count] < 4){
        LogInfo(@"新增门店拜访后,服务端返回数据：%@",info);
    }
    
    NSString *objId = [self getObjIDByisFromScript:YES];
    
    NSArray *allPlanStores = [uploadState objectForKey:objId];
    
    
    NSNumber *flag =  [uploadState objectForKey:@"flag"];
    if (error.code != 0) {
        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    NSString *tip = nil;
    if (flag &&  [flag intValue] == 1) {
        NSString *objIdStr = [self getObjID];
        WSStoreBean *store;
        if (self.model.currentNewStore != nil) {
            store = self.model.currentNewStore;
        } else {
            store = self.currentStore;
        }
        [store reSetStore:uploadState Key:objIdStr];
        
        if ([objId hasPrefix:@"allplanstoreotherinfoontime"]) {
            uploadState  = [allPlanStores firstObject];
        }
        
        [WSStoreDataProcessService processStoreInfoDataToDbWith:store info:uploadState];
        
        NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
        [WSBaseStoreOtherDataDBService saveStoreRequestFlagWith:WSASVC_OUTPLANSTORE_REQUESTED_FLAG empId:empId storeId:store.Id];
        
        tip = NSLocalizedString(@"store_update_success", nil);

        
        // 当前funcs若无拜访项，查看是否引用其他funcs的拜访项（即subMenuFB的拜访项）
        WSFuncsBean* subMenuFB = [WSFuncsBeanFilterLogicService getSubMenuFuncsBeanByCurrentFB:self.currentFuncs];
        if (!subMenuFB && (!self.currentFuncs.funcsArray || [self.currentFuncs.funcsArray count] == 0)) {
            LogInfo(@"新增门店无拜访项");
            return;
        }
        
        [self goWorkFlowController:subMenuFB];
      
    }else {
        LogInfo(@"点击开始拜访按钮发送的第二次请求失败，flag=0");
    }
}

- (void)goAndCheckGoWorkFlowController:(NSString *)storeId msg:(NSString *)msg {
    // 没有提示信息则直接进入拜访
    if (!msg || [msg isEqualToString:@""]) {
        [self startUpdataStoreInfosWith:storeId];
        return;
    }
    
    BlockAlertView *aler = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:msg];
    [aler setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:^{
//        donghong  SFA-25652
        [self backToParent];
    }];
    [aler addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
        
        //拜访之前检测未离店
        WSInoutStoreObject *inOutStoreObj = [[WSInoutStoreTable sharedTable] anyStorehaveNotLeave];
        NSString *unLeavedStoreName = inOutStoreObj.memo1;
        if (unLeavedStoreName && [unLeavedStoreName length] > 0 &&
            ![storeId isEqualToString:inOutStoreObj.store_id] &&
            ![self.currentFuncs.required isEqualToString:@"E"]) {
            
            NSString *LeaveString = NSLocalizedString(@"not_leave_store",nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:[NSString stringWithFormat:@"%@%@",unLeavedStoreName,LeaveString] tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            [self backToParent];

            return;
        }
        
        // 向后台请求拜访项先关数据（acvtArray,prodArray 处理逻辑和计划外相同）
        [self startUpdataStoreInfosWith:storeId];
        
       
    }];
    [aler show];
}

- (void)showSameStoreList:(NSArray *)storeArray {
    NSMutableArray *storeBeanArray = [[NSMutableArray alloc] initWithCapacity:storeArray.count];
    for (NSInteger i = 0 ; i < storeArray.count; i++) {
        NSDictionary *tempDict = [storeArray objectAtIndex:i];
        WSStoreBean *storeBean = [[WSStoreBean alloc] initStoreWithObject:tempDict IsPlan:NO];
        [storeBean modifyStoreInfo:tempDict];
        [storeBeanArray addObject:storeBean];
    }
    
    WSAddNewStoreSelectView *selectView = [[WSAddNewStoreSelectView alloc] initWithFrame:self.view.bounds];
    selectView.dataArray = storeBeanArray;
    selectView.delegate = self;
    [self.view addSubview:selectView];
}


- (void)goWorkFlowController:(WSFuncsBean *)subMenuFB {

    WSWorkFlowViewController* wfvc = nil;
    
    WSFuncsBean *funcsBean;
    if(subMenuFB){
        funcsBean = subMenuFB;
    } else {
        funcsBean = self.currentFuncs;
    }
    
    if (self.model.currentNewStore) {
        
        if (!self.currentStore || [self.currentStore.Id isEqualToString:@"-1"]) {
            wfvc = [[WSWorkFlowViewController alloc]initWithFuncs:funcsBean Store:self.model.currentNewStore];
        }else {
            /*存在 在店的拜访项中  新增店*/
            if ([self.currentStore.Id isEqualToString:self.model.currentNewStore.Id]) {
                wfvc = [[WSWorkFlowViewController alloc]initWithFuncs:funcsBean Store:self.model.currentNewStore];
            }else {
                wfvc = [[WSWorkFlowViewController alloc]initWithFuncs:funcsBean Store:self.currentStore acvtNewStore:self.model.currentNewStore];
            }
        }
        
    } else {
        wfvc = [[WSWorkFlowViewController alloc]initWithFuncs:funcsBean Store:self.currentStore];
    }
    
    WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
    action.parent_action_id = self.currentVisitAction.ID;
    action.store_id = self.model.currentStore.Id;
    action.func_code = funcsBean.fc;
    action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
    action.title = funcsBean.name;
    if (self.currentVisitAction
        && self.currentVisitAction.module_fc
        && [self.currentVisitAction.module_fc length] > 0) {
        action.module_fc = self.currentVisitAction.module_fc;
    }else{
        
        action.module_fc = action.func_code;
    }
    
    if (self.model.currentNewStore && ![self.currentStore.Id isEqualToString:self.model.currentNewStore.Id] ) {//SNOW-12
        action.newstore_id = self.model.currentNewStore.Id;
        [[WSVisitStoreActionTable sharedTable] insertCurrentAction:action];
    }
    action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
    wfvc.currentVisitAction = action;
    wfvc.moduleFC = wfvc.currentVisitAction.func_code;
    
    if (self.model.currentNewStore) {
        if ([self.model.currentNewStore.name isKindOfClass:[NSString class]] && ![self.model.currentNewStore.name isEqualToString:@""]) {
            wfvc.title = self.model.currentNewStore.name;
        }
    } else {
        wfvc.title = self.currentStore.name;
    }
    
    // MN-1205 调查问卷自动跳转拜访之前检测是否有未离店
    WSInoutStoreObject *inOutStoreObj = [[WSInoutStoreTable sharedTable] anyStorehaveNotLeave];
    NSString *unLeavedStoreName = inOutStoreObj.memo1;
    if (unLeavedStoreName && [unLeavedStoreName length] > 0 &&
        ![self.model.currentNewStore.Id isEqualToString:inOutStoreObj.store_id] &&
        ![self.currentStore.Id isEqualToString:inOutStoreObj.store_id]) {
        
        [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
        NSString *LeaveString = NSLocalizedString(@"not_leave_store",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:[NSString stringWithFormat:@"%@%@",unLeavedStoreName,LeaveString] tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed autoHideTime:2.0];
        [self performSelector:@selector(backAction) withObject:nil afterDelay:2.0];
        return;
    }
    
    [self gotoWorkFlowController:wfvc withFuncs:subMenuFB];

}

- (void)gotoWorkFlowController:(WSWorkFlowViewController *)wfvc withFuncs:(WSFuncsBean *)funcs  {
    BOOL isNextStep = [funcs.opt.isIntentToStore isEqualToString:@"navigation"];
    if ((wfvc.currentFuncs.readonly && wfvc.currentFuncs.iParentFuncsBean.funcsArray.count == 1) ||
        !isNextStep) {
        [self gotToController:wfvc];
    } else {
        [self gotoNextStepFuncsControllerWithWfvc:wfvc];
    }
}

- (void)gotoNextStepFuncsControllerWithWfvc:(WSBaseWorkFlowViewController *)wfvc {
    WSNextStepFuncsViewController *vc = [[WSNextStepFuncsViewController alloc] initWithFuncs:wfvc.currentFuncs store:wfvc.currentStore subempStore:nil acvtNewStore:wfvc.acvtNewStore moduleFC:wfvc.moduleFC];
    vc.currentVisitAction = wfvc.currentVisitAction;
    vc.input_reflect_code = wfvc.input_reflect_code;
    vc.realParentFuncsCode = wfvc.realParentFuncsCode;
    vc.isTabMode = YES;
    
    [self gotToController:vc];
}

- (void)gotToController:(WCBaseViewController *)wfvc {
    LogInfo(@"Going into class:%@", wfvc);
    UINavigationController *naviCon = [self getNavigationController];
    NSArray *array = naviCon.viewControllers;
    
    if (INTERFACE_IS_PAD && array.count <= 1) {
        [self showWorkFlowInSplitViewController:wfvc];
    }else {
        if (array.count > 1) {
            UIViewController *tmpVC = [array objectAtIndex:array.count-2];
            if ([wfvc isKindOfClass:[WSBaseWorkFlowViewController class]]) {
                ((WSBaseWorkFlowViewController *)wfvc).backVC = tmpVC;
            }
        }
        [naviCon pushViewController:wfvc animated:YES];
    }
}

- (void)workFlowBackAction {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showWorkFlowInSplitViewController:(WCBaseViewController *)controller {
    
    WCNavigationController *workFlowNav = [[WCNavigationController alloc] initWithRootViewController:controller];
    
    WCBaseViewController *rightCon = nil;
    
    if ([controller isKindOfClass:[WSWorkFlowViewController class]]) {
        WSWorkFlowViewController *workFlowCon = (WSWorkFlowViewController *)controller;
        rightCon = [workFlowCon getDefaultShowController];
    }
    
    if (!rightCon) {
        rightCon = [[WSStoreInfoMapViewController alloc] init];
    }
    
    WCNavigationController *rightNav = [[WCNavigationController alloc] initWithRootViewController:rightCon];
    
    [controller leftItemImage:@"icon_back" target:self  action:@selector(workFlowBackAction)];
    
    WSSplitViewController *split = [[WSSplitViewController alloc] initWithLeftController:workFlowNav rightController:rightNav];
    CGFloat width = SPLITVIEW_LEFT_DEFAULT_WIDTH;
    
    if (controller.currentFuncs.wfcol > 0) {
        width = (CGFloat)controller.currentFuncs.wfcol;
    }
    split.leftControllerWidth = width;
    split.separatorLineColor = [UIColor colorWithHexString:@"#cdcdcd"];
    
    controller.wsSplitController = split;
    rightCon.wsSplitController = split;
    
    [self presentViewController:split animated:YES completion:nil];
}

// 删除按钮事件
// 1.删除本地的新增的门店数据
// 2.还需上传给服务器数据删除当前的新增的门店
- (void)deleteButtonClick:(UIButton *)sender {
    
    self.sumbitWithReason = [self showDeleteReasonTextField:[sender tag]];
    
    NSArray * storeAcvtDis = [[[WSBaseAcvtdisDBService alloc]init] queryAcvtQstDatasByGenId:self.currentStore.update_md5id];
    // 如果此门店已经新增
    if (self.model.currentNewStore.Id || storeAcvtDis.count > 0) {
        
        if (sender.selected) {
            NSString *titile = NSLocalizedString(@"confirm_delete_store",nil);
            NSString *ok = NSLocalizedString(@"confirm",nil);
            NSString *cancel = NSLocalizedString(@"cancel_label", nil);
            
            BlockAlertView *alert = nil;
            if (self.sumbitWithReason) {
                UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 50, 210, 40)];
                alert = [BlockTextPromptAlertView promptWithTitle:titile message:nil textField: &textField];
                self.delReasonAlert = (BlockTextPromptAlertView *)alert;
            }else {
                alert = [BlockAlertView alertWithTitle:titile message:nil];
            }
            
            [alert setCancelButtonWithTitle:cancel block:^{
                sender.selected = NO;
                self.currentUploadActionType = WSNormalActionType;
            }];
            [alert addButtonWithTitle:ok block:^{
                
                NSString *storeId = self.model.currentNewStore.Id ?: self.currentStore.Id;
                //删除之前检测未离店
                WSInoutStoreObject *inOutStoreObj = [[WSInoutStoreTable sharedTable] anyStorehaveNotLeave];
                NSString *unLeavedStoreName = inOutStoreObj.memo1;
                if (unLeavedStoreName && [unLeavedStoreName length] > 0 && [storeId isEqualToString:inOutStoreObj.store_id]) {
                    
                    NSString *LeaveString = NSLocalizedString(@"not_leave_store",nil);
                    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:[NSString stringWithFormat:@"%@%@",unLeavedStoreName,LeaveString] tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                    return;
                }
                
                self.currentUploadActionType = WSDeleteActionType;
                NSString *AccessInforString = NSLocalizedString(@"update_data_tip",nil);
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:AccessInforString  tips:nil tapTarget:self action:nil];
                [self executeRealUpload];
            }];
            [alert show];
        }
    } else {
        NSString *title = NSLocalizedString(@"newstore_delete",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
}

// 点击删除按钮请求数据完成
- (void)deleteNewAddStoreFinish:(NSNotification *)notification {
    LogTrace();
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notification.name object:nil];
    NSString *info = [[notification userInfo] objectForKey:DATAS];
    NSDictionary *infoDic = [info objectFromJSONString];
    NSString *result = [infoDic objectForKey:@"result"];
    NSDictionary *resultDic = [result objectFromJSONString];
    NSString *tip = nil;
    
    LogInfo(@"info--%@",info);
    BOOL isSucceed = NO;
    if ([info rangeOfString:@"flag"].location != NSNotFound) {
        if (resultDic) {
            NSString *flag = [resultDic objectForKey:@"flag"];
            if (flag && [flag isKindOfClass:[NSNumber class]] && [flag intValue] == 1) {
                isSucceed = YES;
            } else {
                // 服务器删除失败提示
                tip = NSLocalizedString(@"deleted_failure_label",nil);
            }
        } else {
            tip = NSLocalizedString(@"server_reponse_error",nil);
        }
    }else {
        if (result && [result isEqualToString:@"1"]) {
             isSucceed = YES;
        }else {
            tip = NSLocalizedString(@"deleted_failure_label",nil);
        }
    }
    if (isSucceed) {
        // 服务器删除成功提示
        tip = NSLocalizedString(@"deleted_success_label",nil);
        if ([(WSAcvtModel *)self.model isSynchronizeRequest]) {
            [self uploadPhotos];
        }
        
        WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
        [service deleteLocalDataWithGenId:self.model.md5];
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSString stringNotNilWithValue:self.model.md5 ]forKey:DelteStoreMD5_Key];
        [[NSNotificationCenter defaultCenter] postNotificationName:DeleteNewAddStoreSucceed object:self userInfo:userInfo];
        [self backToParent];
    }

    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tip tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
}


- (BOOL)showDeleteReasonTextField:(NSInteger)delButtonTag {
    for (WSAcvtBean_qst *acvtBean_qst  in  _m_currentAcvt.qsts) {
        if ([acvtBean_qst.acvtQstId isEqualToString: [NSString stringWithFormat:@"%ld",(long)delButtonTag]]) {
            if (acvtBean_qst.script && [acvtBean_qst.script rangeOfString:@"onSubmitDelete"].location != NSNotFound) {
                return YES;
            }
            
        }
    }
    return NO;
}

- (void)updateCalendarData:(NSString *)param {
    isUpdateCalendarDataFromLua = YES;
    self.selectedEmployeeId = param;
    [self executeRealWillUpload:[NSNumber numberWithInt:WSOnlySaveAcvtDataForCalendarType]];
    
    WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
    WSBaseAcvtDBService *acvtDBService = [[WSBaseAcvtDBService alloc] init];
    NSMutableDictionary *calendarIconsDic = [NSMutableDictionary dictionary];

    for (NSInteger i = 0; i < [self.calendarSelectedDates count]; i++) {
        
        NSMutableDictionary *curentDic = [NSMutableDictionary dictionary];
        NSString *dateStr = self.calendarSelectedDates[i];
        if ([dateStr length] == 0) {
            LogInfo(@"dateStr is  nil");
            continue;
        }
        NSString *generateNewMd5 =  [self generateMd5WhenAcvtHasCalendar:dateStr];
        
      //  SFA-13372 xuhan 20171023
        /*查询某一天对应的数据*/
        NSArray *acvtQstDisItems = [service queryAcvtQstDatasWithStoreID:self.currentStore.Id acvtType:self.currentFuncs.filter searchText:nil genIDs:@[generateNewMd5] isFromLocal:YES isRead:YES isRemoteSearch:0];
        
        if ([acvtQstDisItems count] > 0) {
            for (WSAcvtQstDisItem *acvtQstDisItem in acvtQstDisItems) {
                NSString *isAcvtName = acvtQstDisItem.isacvtname;
                NSString *acvtQstAnswer = acvtQstDisItem.acvtanswer;
                if ([isAcvtName length] > 0 && [acvtQstAnswer length] > 0) {
                    NSString *acvtQstId = acvtQstDisItem.acvtQstId;
                    if ([acvtQstAnswer length] > 0) {
                        NSString *compeletUrl = [WSHttpURLHelper getImageCompleteURL:acvtQstAnswer];
                        NSString *optPic = nil;
                        if ( [isAcvtName isEqualToString:@"10"]) {
                            optPic = [acvtDBService queryOptPicByID:acvtQstAnswer acvtQstID:acvtQstId];
                            if ([optPic length] > 0) {
                                compeletUrl = [WSHttpURLHelper getImageCompleteURL:optPic];
                            }
                            curentDic[LOAD_IMAGE_Number10URL] = [NSString stringNotNilWithValue:compeletUrl];
                        }else if ( [isAcvtName isEqualToString:@"12"]){
                            optPic = [acvtDBService queryOptPicByID:acvtQstAnswer acvtQstID:acvtQstId];
                            if ([optPic length] > 0) {
                                compeletUrl = [WSHttpURLHelper getImageCompleteURL:optPic];
                            }

                            curentDic[LOAD_IMAGE_Number12URL] = [NSString stringNotNilWithValue:compeletUrl];
                        }else if ( [isAcvtName isEqualToString:@"13"]){
                            optPic = [acvtDBService queryOptPicByID:acvtQstAnswer acvtQstID:acvtQstId];
                            if ([optPic length] > 0) {
                                compeletUrl = [WSHttpURLHelper getImageCompleteURL:optPic];
                            }
                            curentDic[LOAD_IMAGE_Number13URL] = [NSString stringNotNilWithValue:compeletUrl];
                        }
                    }
                }
            }
        }
        if ([curentDic allKeys].count > 0 && [dateStr length] > 0) {
            [calendarIconsDic setObject:curentDic forKey:dateStr];
        }
    }

    [self.calendarPanel reloadCurrentWidgetWithValue:calendarIconsDic];
    
}

- (NSString *)generateMd5WhenAcvtHasCalendar:(NSString *)dateStr {
    NSString *memo = [dateStr stringByAppendingString:self.selectedEmployeeId];
    if ([self.selectedEmployeeId length] == 0) {
        LogError(@"self.selectedEmployeeId is nil");
    }
    NSString *md5 = [Md5Manager getMd5ByEmpId:[WSAppData getObjectbyKey:APPDATA_EMPID]
                                                 sotreId:nil
                                                 bizDate:nil
                                                funcCode:self.currentFuncs.fc
                                                  acvtId:self.calendarKeyId
                                               memo:memo];
    return md5;
}

- (NSString *)getAcvtCalWidgetResult {

    for (WSWidget *widget  in  self.acvtview.widgetArray) {
        
        if ([[widget.xbuildInfo getAcvtQstType] isEqualToString:@"CAL"]) {
            return (NSString *)[widget getResultDirectly];
            break;
            
        }
    }
    return nil;
}

#pragma mark - WSPopViewControllerDelegate
- (void)popViewControllerDidDismiss:(WSPopViewController *)controller isConfirm:(BOOL)isConfirm
{
    [WSDataSourceManager sharedInstance].currentActiveModel = self.model;
    
    // SFA-7336 添加对更多产品的事件响应
    if ([controller.contentViewController isKindOfClass:[MoreProductViewController class]]) {
        MoreProductViewController *mpvc = (MoreProductViewController *)controller.contentViewController;
        if (isConfirm) {
            [mpvc postReceiveMoreNotificationAndSendSelectedProducts];
        }
    }
    
}

#pragma mark - I_NextStepContentView
- (void)nextStepContentViewClearData
{
    [self clearDatasWhenBackAction];
    [self doRemoveAcvtGridSteadyTableHeadViewWhenBackToParentOrHome];
}

- (BOOL)nextStepContentViewValidateData
{
    return [self executeValidate];
}

- (void)nextStepContentViewUploadData
{
    self.model.uploadThenNotFinishView = YES;
    [self executeRealUpload];
}

#pragma mark - General function

-(NSString *)getStoreId:(id)aStore{
    
    NSString *l_storeId = nil;
    if ([aStore isKindOfClass:[WSStoreBean class]]) {
        
        WSStoreBean *tmpStore = (WSStoreBean *)aStore;
        l_storeId =tmpStore.Id;
        if (tmpStore.iStoreIdentify != nil ) {
            l_storeId = tmpStore.iStoreIdentify;
        }
        if (tmpStore.Id == nil) {
            l_storeId = [NSString stringWithFormat:@"%d",-1];
        }
    } else if ([aStore isKindOfClass:[WSSubempstoreBean class]]) {
        
        WSSubempstoreBean *tmpSubEmpStore = (WSSubempstoreBean *)aStore;
        
        if (tmpSubEmpStore.Id) {
            l_storeId = tmpSubEmpStore.Id;
        } else {
            l_storeId = [NSString stringWithFormat:@"%d",-1];
        }
    }else if ([aStore isKindOfClass:[WSHosBean class]]) {
        WSHosBean *hosBean = (WSHosBean *)aStore;
        if (hosBean.Id) {
            l_storeId = hosBean.Id;
        }
    }else if (!aStore){
        l_storeId = [NSString stringWithFormat:@"%d",-1];
    }
    
    return l_storeId;

}

- (BOOL)getIsUpdateCalendarDataFromLua
{
    return isUpdateCalendarDataFromLua;
}

#pragma mark - resetMd5ByCustomDateString

- (void)resetMd5ByCustomDateString:(NSString *)dateString {
    
    NSMutableDictionary *dic = [[self.model md5Param] mutableCopy];
    
    if ([dateString length] > 0) {
        [dic setObject:dateString forKey:DATE_MD5_PARAM_KEY];
    }
    
    [self.model createMD5With:dic];
    
}
- (void)deleteButtonClick
{
    __weak WSAcvtViewController *weakSelf = self;
    BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"alert_default_title", nil) message:NSLocalizedString(@"confirm_delete_dialog_title", nil)];
    
    [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:^{
    }];
    
    [alert addButtonWithTitle:NSLocalizedString(@"delete_label", nil) block:^{
        
        [[WSVisitStoreAcvtTable sharedTable] deleteDatasGenId:weakSelf.model.md5];
        [[WSVisitStoreAcvtDataTable sharedTable] deleteDateGenId:weakSelf.model.md5];
        [[NSNotificationCenter defaultCenter] postNotificationName:NEWADDACVTSUCCEED object:nil];
        [weakSelf backAction];
    }];
    [alert show];
}

#pragma mark - SideView
-(void)showOrHideSideView {
    [self.sideView showOrHideWithAnimation];
}

- (WSAcvtSideView *)sideView {
    if (!_sideView) {
        
        NSString *title = NSLocalizedString(@"acvt_filter", nil);
        UIView *subView = [self.acvtview getSideSubView];
        CGFloat width = [[UIScreen mainScreen] bounds].size.width;
        CGFloat height = [[UIScreen mainScreen] bounds].size.height;
        
        _sideView = [[WSAcvtSideView alloc] initWithFrame:CGRectMake(0, 0, width, height) subView:subView title:title];
        [_sideView setHidden:YES];
        
        if ([subView isKindOfClass:[WSAcvtTabCollectionView class]]) {
            WSAcvtTabCollectionView *tabView = (WSAcvtTabCollectionView *)subView;
            __weak typeof(self) weakSelf = self;
            tabView.selectedAcvtTabBlock = ^(NSInteger index, WSAcvtTabStyle style) {
                
                if (style == WSAcvtTabStyleSide) {
                    [weakSelf.sideView showOrHideWithAnimation];
                    CGFloat posY = [weakSelf.acvtview getGroupPosYByIndex:index];
                    [weakSelf.scrollView setContentOffset:CGPointMake(0, posY)];
                }
            };
        }
        
        WSAppDelegate *delegate = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
        UIViewController *rootViewController = delegate.window.rootViewController;
        [rootViewController.view addSubview:_sideView];
    }
    return _sideView;
}

#pragma mark - 更新genid数据方法 param:参数
- (void)updateGenidData:(NSString *)param
{
    self.md5 = ((param.length > 0) ? param : self.md5);
    self.model.md5 = ((param.length > 0) ? param : self.model.md5);
}

#pragma mark - WSAddNewStoreSelectDelegate
- (void)addNewStoreByIsAdd:(BOOL)isAdd overideStore:(WSStoreBean *)store {
    // SFA-22809 原功能进行调整，不再需要 uploadDataByIsNeedAdd 的调用
    if (!isAdd) {
        WSAddNewStoreModel *model = (WSAddNewStoreModel *)self.model;
        model.currentStore = store;
        // SFA-22809 选择非新增则走修改的逻辑
        model.isNewAddAcvt = NO;
        
        if ([self.currentFuncs.opt.isIntentToStore isEqualToString:@"Y"]) {
            [self showIsVisitTipWithCurrentStore:store];
        } else {
            
            [self startGetStoreInfoBySotreId:store.Id];
        }
    }
    // SFA-22809 添加执行脚本逻辑
    [self runAddNewStoreSelectScriptByIsAdd:isAdd];
    //    SFA-23051 董宏 SFA-23080 lr
    if ([self.currentFuncs.opt.isIntentToStore isEqualToString:@"Y"] ||
        [self.currentFuncs.opt.isIntentToStore isEqualToString:@"add"]) {
        [self executeUpload];
    }

}
//弹出拜访与不拜访提示
- (void)showIsVisitTipWithCurrentStore:(WSStoreBean *)storeBean
{
    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"whether_to_visit_the_customer_immediately", nil),storeBean.name];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *visitAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"visit_label", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //拜访
        [self popToParentOrHome];
        if ([self isKindOfClass:[WSAddNewStoreViewController class]]) {
            if ([((WSAddNewStoreViewController*)self).delegate respondsToSelector:@selector(toBeVisitedStore:)]) {
                [((WSAddNewStoreViewController*)self).delegate toBeVisitedStore:storeBean];
            }
        }
        
    }];
    UIAlertAction *notVisitAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"not_visit_label", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        //不拜访
        [self popToParentOrHome];
    }];
    [alertController addAction:visitAction];
    [alertController addAction:notVisitAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 待重构，网络请求是通过通知方式返回数据，抽出公共部分代码需要添加更多通知所以该函数是重复代码
// 与 SuperWorkSpaceViewController 的 startGetStoreInfoBySotre 重复
// 不同处是参数由 Store 改为了 StoreId，成功后调用了 reloadAcvtview
- (void)startGetStoreInfoBySotreId:(NSString *)storeId {
    [self querying_messageTips];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(storeInfoRequestFinish:)
                                                 name:NOTIFY_STOREINFO
                                               object:nil];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:[NSString stringNotNilWithValue:storeId] forKey:WSREQUEST_STOREID];
    [dictionary setObject:@"1" forKey:@"compress"];
    [dictionary setObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]] forKey:APPDATA_EMPIDBIGI];
    //    SFA-21760
    //    【SFA泸州老窖】【iOS】在客户管理列表中点击新增客户时点击提示 加载错误
    if (self.currentFuncs.opt.nextAcvtNode.length > 0) {
        [dictionary setObject:self.currentFuncs.opt.nextAcvtNode forKey:APPDATA_OBJID];
    } else {
        [dictionary setObject:@"acvtForEditStore" forKey:APPDATA_OBJID];
    }
    [[WSRequestHelper shareInstance] postRequestData:dictionary notifyName:NOTIFY_STOREINFO];
}

- (void)storeInfoRequestFinish:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTIFY_STOREINFO
                                                  object:nil];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    NSString *acvtId = nil;
    if (error) {
        [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
        LogError(@"%@",error);
    }else{
        NSDictionary *infoDic = [info objectFromJSONString];
        NSArray *storeInfoArr = nil;
        if (self.currentFuncs.opt.nextAcvtNode.length > 0) {
            storeInfoArr = [infoDic objectForKey:self.currentFuncs.opt.nextAcvtNode];
        } else {
            storeInfoArr = [infoDic objectForKey:@"acvtForEditStore"];
        }
        if (storeInfoArr == nil) {
            storeInfoArr = @[];
        }
        NSDictionary *storeInfoDic = [storeInfoArr objectAtIndex:0];
        acvtId = [storeInfoDic objectForKey:@"acvtId"];
        NSArray *storeActs = [storeInfoDic objectForKey:STOREACVTDIS];
        
        if (!acvtId || !storeActs || storeActs.count == 0) {
            [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
            
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"load_data_failure", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            LogError(@"修改门店信息，后台没有下发acvtId");
            return;
        }
        
        if (storeActs.count>0)
        {
            WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
            [service replaceToTableWithDicts:storeActs FromNode:STOREACVTDIS hasNewData:YES storeID:self.currentStore.Id isRemoteSearch:YES];
            
            NSString *deleteLocalAcvtData = [NSString stringWithValue:[storeInfoDic objectForKey:@"deleteLocalAcvtData"]];
            if ([deleteLocalAcvtData isEqualToString:@"1"]) {
                //实时请求门店信息后以服务器数据为准，清除本地编辑的数据
                [service deleteLocalDataWithStoreId:self.currentStore.Id acvtId:acvtId];
            }
            
            [self reloadAcvtview];
        }
        
        [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
        
    }
}

- (void)runAddNewStoreSelectScriptByIsAdd:(BOOL)isAdd {
    WSAddNewStoreModel *model = (WSAddNewStoreModel *)self.model;
    
    NSString *funcName;
    if (isAdd) {
        funcName = ACVT_LUA_FUNTION_DIALOG_CANCEL;
    } else {
        funcName = ACVT_LUA_FUNTION_DIALOG_CONFIRM;
    }
    
    WSLuaExecutorManager *wsLuaExecutor = [WSLuaExecutorManager shareInstance];
    wsLuaExecutor.sourceType = WSLuaExecuteSourceTypeAcvt;
    
    NSString *subScript = [WSLuaExecutorManager getSubLuaScriptWith:model.currentAcvtBean.luaScript ByFuntionName:funcName];
    if ([subScript length] > 0) {
        [wsLuaExecutor executeLuaScript:subScript];
    }
}

- (void)alertCancleAction {
    [self.acvtview executeLuaScriptCancle];
}

- (void)jumpActivityWithFv:(NSString *)fv {
    NSString *className = [WSPlistHelper valueForKey:fv withPlistName:kControllerMappingFileName];
    WSFuncsBean *fb = [[WSAppData getObjectbyKey:FUNCS] getFuncsBeanWithFV:fv];
    UIViewController *vc = [[NSClassFromString(className) alloc] initWithFuncs:fb];
    if (self.ownParentViewController)
    {
        self.ownParentViewController.hidesBottomBarWhenPushed = YES;
        [self.ownParentViewController.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (NSString *)getAcvtEdit
{
    if ([self.acvtview isValueChange]) {
        return @"true";
    }
    return @"false";
}

#pragma mark - 刷新位置方法
- (void)refeshLocation:(NSString *)param {
    
    for (WSWidget *tmpWidget in  self.acvtview.widgetArray) {
        
        if ([tmpWidget isKindOfClass:[WSMapPanel class]] && [[tmpWidget.xbuildInfo getIsHidden] isEqualToString:@"0"]) {
            
            WSMapPanel *mapView = (WSMapPanel*)tmpWidget;
            [mapView refeshLocation:@""];
        }
    }
}

#pragma mark - 上传返回结果需要再次上传方法 message:消息 flag:标示
- (void)resultExecuteUpload:(NSString *)message flag:(NSString *)flag
{
    NSString *info = message;
    NSString *confirm = NSLocalizedString(@"retry",nil);
    NSString *cancel = NSLocalizedString(@"cancel_label", nil);
    __weak typeof(self)weakSelf = self;
    
    if([message containsString:@"@&@"]) {
        NSArray *separateArray = [message componentsSeparatedByString:@"@&@"];
        if (separateArray.count >= 3) {
            info = [separateArray objectAtIndex:0];
            confirm = [separateArray objectAtIndex:1];
            cancel = [separateArray objectAtIndex:2];
        }
    }
    
    BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:info];
    
    [alert addButtonWithTitle:confirm block:^{
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"update_data_tip",nil) tips:nil tapTarget:self action:nil];
        ((WSAcvtModel *)weakSelf.model).confirm = @"1";
        [weakSelf executeRealUpload];
    }];
    
    if ([flag isEqualToString:@"3"]) {
        [alert setCancelButtonWithTitle:cancel block:^{
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"update_data_tip",nil) tips:nil tapTarget:self action:nil];
            ((WSAcvtModel *)weakSelf.model).confirm = @"0";
            [weakSelf executeRealUpload];
        }];
    }
    else {
        [alert setCancelButtonWithTitle:cancel block:nil];
    }

    [alert show];
}

#pragma mark - 上传返回结果错误提示 MN-1190 错误为0的时候的处理
- (void)resultExecute:(NSString*)message
{
    if (!message || [message isKindOfClass:[NSNull class]] || [message length] == 0)
    {
        message = NSLocalizedString(@"fail_upload", nil);
    }
    NSString *cancel = NSLocalizedString(@"cancel_label", nil);
    BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:message];
    [alert setCancelButtonWithTitle:cancel block:nil];
    [alert show];
}

#pragma mark - 复原问卷视图原始数据方法
- (void)restoreAcvtViewOriginalData
{
    BOOL isTabMode = (self.isTabMode || [self.acvtview acvtViewIsTabMode]); //安卓判定isTab还多一种情况 系统tabBar形式(iOS暂时忽略这个条件)
    if ([self.currentFuncs.dateTyp isEqualToString:@"E"] && isTabMode)
    {
        [self.acvtview celearAcvtData];
        [self changeMd5WhenUploadFinish];
    }
}

#pragma mark - 更新问卷视图genid方法
- (void)updateAcvtViewGenId
{
}

#pragma mark - 设置定制照片名称方法 photoKey:照片key isReady:是否准备状态 返回:照片名称
- (NSString *)setupCustomPhotoNameWithPhotoKey:(NSString *)photoKey isReady:(BOOL)isReady {
    
    if ([self.currentFuncs.opt.customFormatImgName isEqualToString:@"Y"]) {
        
        if (isReady) {
            [self.customPhotoNameDict removeAllObjects];
            return @"";
        }
        
        if (!photoKey || photoKey.length <= 0) {
            return @"";
        }
        
        if ([self.customPhotoNameDict.allKeys containsObject:photoKey]) {
            return [self.customPhotoNameDict objectForKey:photoKey];
        }
        
        NSInteger index = (self.customPhotoNameDict.allKeys.count + 1);
        
        if ([self.currentStore.Id isEqualToString:@"-1"] || !self.currentStore) {
            NSString *dateTime = [WSCurrentTime getCurrentTimeForRichMedia];
            NSString *userName = [[WSEMSDKManager sharedInstance] getUserInfo].wsname;
            NSString *photoName = [NSString stringWithFormat:@"%@-%@-%ld", dateTime, userName, index];
            [self.customPhotoNameDict setObject:photoName forKey:photoKey];
            return photoName;
        }
        
        if (self.currentStore.Id && self.currentStore.Id.length > 0) {
            NSString *storeCode = self.currentStore.custCode;
            NSString *storeName = self.currentStore.name;
            NSString *dateTime = [WSCurrentTime getCurrentTimeForRichMedia];
            NSString *userName = [[WSEMSDKManager sharedInstance] getUserInfo].wsname;
            NSString *photoName = [NSString stringWithFormat:@"%@-%@-%@-%@-%ld", storeCode, storeName, dateTime, userName, index];
            [self.customPhotoNameDict setObject:photoName forKey:photoKey];
            return photoName;
        }
    }
    
    return @"";
}










#pragma mark - 实现initAcvtModel方法<初始化问卷模型数据方法>
- (void)initAcvtModel {
    
    ((WSAcvtModel *)self.model).currentAcvtBean = self.m_currentAcvt;
    ((WSAcvtModel *)self.model).currentStore = self.currentStore;
    ((WSAcvtModel *)self.model).currentFuncs = self.currentFuncs;
    ((WSAcvtModel *)self.model).md5 = self.md5;
    
    if ([self.updateGenID length] > 0) {
        ((WSAcvtModel *)self.model).updateGenId = self.updateGenID;
    }
    
    ((WSAcvtModel *)self.model).prepareVisitDate = self.prepareVisitDate;
    ((WSAcvtModel *)self.model).isNewAddAcvt = self.isNewAddAcvt;
    ((WSAcvtModel *)self.model).subEmpId = self.submitempid;
    ((WSAcvtModel *)self.model).currentNewStore = self.currentNewStore;
    ((WSAcvtModel *)self.model).realParentFuncsCode = self.realParentFuncsCode;
    
    if (self.hosBean) {
        ((WSAcvtModel *)self.model).hosBean = self.hosBean;
    }
}

#pragma mark - 保存调查问卷数据到数据库方法
- (void)saveAcvtDatasToDB {
    
    NSDictionary *qstValuesDic = (NSDictionary *)[self.acvtview getAllPrepareSubmitData];
    [(WSAcvtModel *)self.model saveAcvtDatasToDB:qstValuesDic useNewMd5:nil];
    [self saveTBAcvtDatasToDB];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NEWADDACVTSUCCEED object:nil];
}

#pragma mark - 保存表格数据到数据库方法
- (void)saveTBAcvtDatasToDB {
    
    for (WSWidget *widget in self.acvtview.widgetArray) {
        
        if ([widget isKindOfClass:[WSAcvtDataGridViewPanel class]]) {
            
            WSAcvtDataGridViewPanel *dataGridPanel = (WSAcvtDataGridViewPanel *)widget;
            if (self.fptDbDeleteWithMd5) {
                [dataGridPanel getAcvtDataSource].isClear = NO;
            }
            
            NSDate *date = [NSDate date];
            [WSAcvtDataGridComponentService insertDataToTableWithWSAcvtDataGridComponentDataSource:[dataGridPanel getAcvtDataSource]];
            NSDate *after = [NSDate date];
            LogInfo(@"insertDataToTableWithWSAcvtDataGridComponentDataSource耗时:%f", [after timeIntervalSinceDate:date]);
        }
    }
}

#pragma mark - 上传照片方法
- (BOOL)uploadPhotosForAcvtView:(BOOL)isUpload {

    WSAcvtModel *model = (WSAcvtModel *)self.model;
    NSString *imageIndex = [WSPhotoLogicService getAcvtImageIndexWithFC:self.currentFuncs.fc acvtMD5:model.md5 acvtQstId:self.m_currentAcvt.acvtId];
    
    for (WSScanListPanel *scanListPanel  in self.acvtview.photoScanListViewArray) {
        
        if (!scanListPanel.addPhotoDict) {
            continue;
        }

        NSString *qstValue = (NSString *)[scanListPanel getResultDirectly];
        NSArray *qstValueArray = [qstValue componentsSeparatedByString:@","];
        NSMutableArray *dicValueArrayAcvt = [[NSMutableArray alloc] init];
    
        for (int i = 0; i < scanListPanel.addPhotoDict.count; i++) {
            
            NSString *qst_value_str = [qstValueArray objectAtIndex:i];
            NSRange range = [qst_value_str rangeOfString:@"@"];
            imageIndex = [qst_value_str substringFromIndex:range.location+1];
            
            NSString *scanCode = [qst_value_str substringToIndex:range.location];
            NSObject *obj = [scanListPanel.addPhotoDict objectForKey:scanCode];
            if ([obj isKindOfClass:[NSArray class]]) {
                
                NSArray *imageIDS = (NSArray *)obj;
                for (NSString *imageId in imageIDS) {
     
                    NSString *filePath = [[SDImageCache sharedImageCache] imagePathFromKey:imageId];
                    if (filePath) {
                        
                        if (isUpload) {
                            
                            if (![self uploadOnePhotoWithFilePath:filePath imageIndex:imageIndex imageID:imageId]) {
                                return NO;
                            }
                        }
                        
                        NSString *bizdate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
                        NSString *time = [WSCurrentTime getDateTime];
                        NSArray *array = [NSArray arrayWithObjects:imageIndex, imageId, bizdate, time, @"0", nil];
                        [dicValueArrayAcvt addObject:array];
                    }
                }
            }
        }
        
        if (dicValueArrayAcvt && [dicValueArrayAcvt count] > 0) {
            [[WSImagePathTable sharedTable] updateWithImageIDX:imageIndex withValuesArray:dicValueArrayAcvt];
        }
        else {
            [[WSImagePathTable sharedTable] deleteWithImageIDX:imageIndex];
        }
    }
    
    [self uploadAndSavePhotosWithImageIndex:imageIndex imageIDArray:self.photoBrowseView.imageIDArray photoIsCoverFlag:nil isUpload:isUpload];
   
    for (WSPhotoViewPanel *photoViewPanel in self.acvtview.photoBrowseViewArray) {
        
        if (!photoViewPanel.photoView) {
            continue;
        }
        
        imageIndex = (NSString *)[photoViewPanel getResultDirectly];
        if ([self isKindOfClass:[WSEnterStoreAcvtViewController class]] || [self isKindOfClass:[WSLeaveStoreAcvtViewController class]]) {
            imageIndex = [NSString stringWithFormat:@"%@_%@_%@", self.currentFuncs.fc, self.currentFuncs.fv, self.model.md5];
        }
        
        if ([photoViewPanel.photoView.pz_type isEqualToString:@"3"] || [photoViewPanel.photoView.pz_type isEqualToString:@"2"]) {
           
            [self uploadAndSavePhotosWithImageIndex:imageIndex imageIDArray:photoViewPanel.photoView.imageIDArray
                                   photoIsCoverFlag:[photoViewPanel.xbuildInfo getPhotoIsCoverNewId] isUpload:NO];
            [[WSPaiPaiManager sharedInstance] uploadPPzImagesWithImageIndex:imageIndex];
        }
        else {
            
            [self uploadAndSavePhotosWithImageIndex:imageIndex imageIDArray:photoViewPanel.photoView.imageIDArray
                                   photoIsCoverFlag:[photoViewPanel.xbuildInfo getPhotoIsCoverNewId] isUpload:isUpload];
        }
    }
    
    for (WSSignaturepanel *signaturepanel in self.acvtview.widgetArray) {
        
        if ([signaturepanel isKindOfClass:[WSSignaturepanel class]]) {
            
            imageIndex = (NSString *)[signaturepanel getResultDirectly];
            if (signaturepanel.delectImageID && signaturepanel.delectImageID.length > 0) {
                [self deleteImageIDX:nil andImageID:signaturepanel.delectImageID];
            }
            
            [self uploadAndSavePhotosWithImageIndex:imageIndex imageIDArray:signaturepanel.imageIDArray photoIsCoverFlag:nil isUpload:isUpload];
        }
    }
    
    for (WSImageViewPanel *imageViewPanel in self.acvtview.widgetArray) {
        
        if ([imageViewPanel isKindOfClass:[WSImageViewPanel class]]){
            
            if (!imageViewPanel.imageID) {
                continue;
            }
            
            imageIndex = (NSString *)[imageViewPanel getResultDirectly];
            [WCUserDefaultHelper saveUserImageKey:imageViewPanel.imageID];
            [self uploadAndSavePhotosWithImageIndex:imageIndex imageIDArray:@[imageViewPanel.imageID] photoIsCoverFlag:nil isUpload:isUpload];
        }
    }

    for (WSPhotoTypeArrayItem *arrayItem in self.photoTypeArray) {
        
        for (WSPhotoTypeItem *item in arrayItem.photoTypeItemArray) {
            
            for (NSString *imageID in item.photoIDArray) {
                
                if (imageID) {
                    
                    NSString *filePath = [[SDImageCache sharedImageCache] imagePathFromKey:imageID];
                    NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
                    NSString *photoFileName = [[SDImageCache sharedImageCache] cacheFileNameForKey:imageID];
                    NSDictionary *dic = [WSJSONBuilder buildImageParamsDicByImageID:imageID andImageType:item.typeID];
                    BOOL insertPhotoDataIsSucceed = [self insertUploadMedia:[dic JSONString] Type:kOfflineTableDataType_P URL:URL_IMAGEUPLOAD MD5:imageIndex
                                                                    IsPhoto:YES NotifyName:notifyID photoFileName:photoFileName];
                    
                    if (!insertPhotoDataIsSucceed) {
                        return insertPhotoDataIsSucceed;
                    }
                    
                    if (self.operationAcvtType == WSOnlySaveAcvtDataForCalendarType) {
                    }
                    else {
                        [[WSRequestHelper shareInstance] uploadImageWithFilePath:filePath params:dic url:URL_IMAGEUPLOAD notifyName:notifyID md5:imageIndex];
                    }
                }
            }
        }
    }
    
    return YES;
}

#pragma mark - 请求调查问卷数据方法
- (BOOL)realTimeRefreshAcvtDatas:(NSDictionary *)paramDict {
    
    BOOL isOpenEnterBackground = [((WSAcvtModel *)self.model) getEnterBackgroundSaveAcvtDataMark];
    if (isOpenEnterBackground) {
        
        WinEnterBackgroundDataModel *model = [((WSAcvtModel *)self.model) queryEnterBackgroundMark];
        if (model) {
            return NO;
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(realtimeRequestAcvtDataFinish:) name:K_REAL_TIME_REFRESH_ACVT_DATA object:nil];
    
    NSMutableDictionary* l_dic = [[NSMutableDictionary alloc]init];
    if ([self.currentFuncs.opt.isCurrEmpId isEqualToString:@"1"]) {
 
        [l_dic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    }
    else {
        
        if (self.currentStore.empId.length > 0) {
            [l_dic setObject:self.currentStore.empId forKey:@"empId"];
        } else {
            [l_dic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
        }
    }

    [l_dic setObject:[self getObjID]  forKey:@"objId"];
    [l_dic setObject:[[(WSAcvtModel *)self.model currentAcvtBean] acvtId] forKey:@"extra_acvtId"];
    [l_dic setObject:self.itemCode.length > 0 ? self.itemCode: self.model.md5 forKey:@"genId"];
    
    if (self.currentStore && self.currentStore.Id && ![self.currentStore.Id isEqualToString:@"-1"]) {
        
        [l_dic setObject:self.currentStore.Id forKey:@"store"];
        [l_dic setObject:self.currentStore.Id forKey:@"storeId"];
        [l_dic setObject:self.itemCode.length > 0 ? self.itemCode: self.model.md5 forKey:@"orderCode"];
    }
    
    if (paramDict) {
        
        if ([paramDict.allKeys indexOfObject:@"objId"] != NSNotFound && [NSString stringWithFormat:@"%@", [paramDict objectForKey:@"objId"]].length > 0) {
            self.objID = [NSString stringWithFormat:@"%@", [paramDict objectForKey:@"objId"]];
        }
        [l_dic addEntriesFromDictionary:paramDict];
    }
    
    if (self.currentStore.srid.length > 0) {
        [l_dic setObject:self.currentStore.srid forKey:@"srid"];
    }
    [l_dic setObject:[WSCurrentTime getDateString] forKey:@"bizDate"];

    [self querying_messageTips];
    
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    [uploadMgr postRequestData:l_dic notifyName:K_REAL_TIME_REFRESH_ACVT_DATA];
    
    return YES;
}

#pragma mark - 添加APP进入后台通知方法
- (void)addAppEnterBackgroundNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

#pragma mark - 删除APP进入后台通知方法
- (void)removeAppEnterBackgroundNotification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

#pragma mark - app进入后台通知回调方法(UIApplicationDidEnterBackgroundNotification)
- (void)appEnterBackground:(NSNotification *)notification {
    
    [self enterBackgroundSaveAcvtDatasToDB];
}

#pragma mark - 进入后台保存调查问卷数据到数据库方法
- (void)enterBackgroundSaveAcvtDatasToDB {
    
    BOOL isOpenEnterBackground = [((WSAcvtModel *)self.model) getEnterBackgroundSaveAcvtDataMark];
    if (!isOpenEnterBackground) {
        return;
    }
    
    //2025-06-12 嵌套问卷有释放问题(后期处理) 暂时将不再导航堆栈的问卷忽略
    if (!self.navigationController) {
        return;
    }
    //如果显示建议订单alertView,则不保存数据
    if (self.isShowSuggestionOrderAlertView) {
        LogError(@"如果显示建议订单alertView,退到后台不保存问卷数据");
        return;
    }
    
    NSDictionary *qstValuesDic = (NSDictionary *)[self.acvtview getAllPrepareSubmitData];
    [(WSAcvtModel *)self.model enterBackgroundSaveAcvtDatasToDB:qstValuesDic useNewMd5:nil vcMd5:self.md5 vcUpdateGenId:self.updateGenID];
    [self saveTBAcvtDatasToDB];
    [self uploadPhotosForAcvtView:NO];
}

#pragma mark - 实现WSAcvtViewDelegate协议 是否是进离店视图
- (BOOL)isEnterLeaveVC {
    
    if ([self isKindOfClass:[WSEnterStoreAcvtViewController class]] || [self isKindOfClass:[WSLeaveStoreAcvtViewController class]]) {
        return YES;
    }
    return NO;
}

#pragma mark - 设置md5属性方法
- (void)setMd5:(NSString *)md5 {
    
    WinEnterBackgroundDataModel *model = [((WSAcvtModel *)self.model) queryEnterBackgroundMark];
    if (model) {

        [super setMd5:model.vcMd5];
        return;
    }

    [super setMd5:md5];
}

#pragma mark - 设置updateGenID属性方法
- (void)setUpdateGenID:(NSString *)updateGenID {

    WinEnterBackgroundDataModel *model = [((WSAcvtModel *)self.model) queryEnterBackgroundMark];
    if (model) {

        _updateGenID = model.vcUpdateGenId;
        return;
    }

    _updateGenID = updateGenID;
}

@end
//===========================================================================================================================================================================

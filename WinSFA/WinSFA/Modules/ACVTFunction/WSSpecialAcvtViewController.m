//
//  SpecialAcvtViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-3-27.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSSpecialAcvtViewController.h"
#import "WSAcvtViewController.h"
#import "WSAcvtBean.h"
#import "WSAppData.h"
#import "WSAcvtListViewController.h"
#import "WSNavigationBar.h"
#import "WSEnvrionment.h"

#import "WSBaseAcvtDBService.h"

#import "WSNewAddAcvtViewController.h"
#import "WSAddNewStoreViewController.h"
#import "WSAcvtGridViewController.h"

#import "WSDataSourceManager.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSFuncTipDBService.h"
#import "WSInterAction.h"
#import "WSAcvtListFlagArray.h"


@interface WSSpecialAcvtViewController () {
    NSString* _subempid;
    BOOL _isFuncsHomePageWillShow;
    NSString* _filterResult;//过滤问卷

}

@property (nonatomic, strong)WSAcvtListViewController *m_acvtListViewController;

@end

@implementation WSSpecialAcvtViewController
@synthesize m_AcvtViewController = _m_AcvtViewController;
@synthesize m_acvtListViewController = _m_acvtListViewController;


-(id)initWithFuncs:(WSFuncsBean*)funcs
{
    if(funcs == nil)
        return nil;
    self = [super init];
    if(self)
    {
        self.currentFuncs = funcs;
        // 此参数会在_m_AcvtViewController里面被篡改，所以需保存一下
        _isFuncsHomePageWillShow = funcs.isHomePageWillShow;
        [_m_AcvtViewController setHasSegment:NO];
    }
    return self;
}

/**
 用于对店的新增门店 acvtNewStore是在店的拜访项中新增的门店（调查问卷）
 */
- (instancetype)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store acvtNewStore:(WSStoreBean *)acvtNewStore {
    self = [self initWithFuncs:funcs Store:store];
    if (self) {
        self.acvtNewStore = acvtNewStore;
    }
    return self;
}


-(void)setSubempid:(NSString*)empid
{
    _subempid=empid;
}

#pragma mark - View lifecycle
- (BOOL)isFuncsBeanValid {
    WSFuncsBean *funbean = self.currentFuncs;
    if (funbean == nil && funbean.filter == nil) {
        return NO;
    } else {
        return YES;
    }
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];

    if (![self isFuncsBeanValid]) {
        return;
    }
    
    self.view.backgroundColor = [UIColor grayColor];

    WSFuncsBean *funbean = self.currentFuncs;
    
    [self executeValidateLuaScripWithFb:funbean functionName:@"function initData(" params:self.currentStore.Id];
    
    NSMutableArray* l_acvtFilters = [NSMutableArray arrayWithArray:[WSAcvtListViewController filterAcvtListWithCurrentFuncs:funbean withCurrentStore:self.currentStore]];
    
    if (_filterResult && _filterResult.length > 0) {
        NSArray *array = [_filterResult componentsSeparatedByString:@"@"];
        if(array.count > 1)
        {
            NSString *function = [array firstObject];
            NSString *code = array [1];
            for (WSAcvtBean *acvtBean in l_acvtFilters){
                if ([acvtBean.acvtCode isEqualToString:code]) {
                    if ([function isEqualToString:@"remove"]) {
                        [l_acvtFilters removeObject:acvtBean];
                        break;
                    }else if([function isEqualToString:@"require"]){
                        acvtBean.isReq = @"1";
                    }
                
                }
            }
        }
    }
    WSAcvtBean *newAddAcvtBean = nil;
    
    NSString *isAdd = [NSString stringWithValue:self.currentFuncs.opt.isAdd];
    if ( [isAdd length] > 0 && !([isAdd isEqualToString:@"N"])) {
        
        /*
         走新增调查问卷的逻辑
         */
        if ([isAdd isEqualToString:@"Y"]) {
            newAddAcvtBean = [l_acvtFilters firstObject];
        }else {
            
            WSBaseAcvtDBService *dbService = [[WSBaseAcvtDBService alloc] init];
            newAddAcvtBean = [dbService  queryAcvtWithAcvtCode:self.currentFuncs.opt.isAdd];
            if (newAddAcvtBean == nil) {
                newAddAcvtBean = [dbService queryAcvtByFilter:self.currentFuncs.opt.isAdd acvtCode:nil];
                
            }
        }
    }
    
//    董宏 修改 去掉 ==nil的|| 与安卓核对
    //SFA-22862 因为安卓默认也是在没有配isAcvtList并且只有一个问卷的情况下要跳到问卷的所以暂时先把这个条件去掉
    //SFA-23331
    // SFA-23409 和安卓统一逻辑，只有funbean.isAcvtList == 1 且l_acvtFilters 只有一个对象时 留在当前问卷页。其余跳到详情页（如果想留在当前页请配置将isAcvtList字段配为1）
    if(newAddAcvtBean || ([l_acvtFilters count] == 1 && ((funbean.isAcvtList != nil && [funbean.isAcvtList isEqualToString:@"1"]))))
    {
        [self.m_AcvtViewController removeFromParentViewController];
        self.m_AcvtViewController = nil;
        WSAcvtViewController* i_AcvtViewController =  nil;
        WSAcvtBean* i_CurrentAcvtBean = nil;
        if (newAddAcvtBean) {
            i_CurrentAcvtBean = newAddAcvtBean;
            if (self.currentStore.Id) {
                i_AcvtViewController = [[WSNewAddAcvtViewController alloc]initWithAcvt:newAddAcvtBean Funcs:funbean Store:self.currentStore SubEmpId:_subempid];
            }else {
                i_AcvtViewController = [[WSAddNewStoreViewController alloc]initWithAcvt:newAddAcvtBean Funcs:funbean Store:self.currentStore SubEmpId:_subempid];
            }
        }else if (self.acvtNewStore) {
            i_CurrentAcvtBean = [l_acvtFilters objectAtIndex:0];
            i_AcvtViewController = [[WSAcvtViewController alloc]initWithAcvt:i_CurrentAcvtBean Funcs:funbean Store:self.currentStore acvtNewStore:self.acvtNewStore];
        } else  {
            i_CurrentAcvtBean = [l_acvtFilters objectAtIndex:0];
            //MN-4431
            if ((!self.currentStore.Id) && self.subempStore) {
                //没有门店idid说明是对人的
                WSStoreBean *bean = [[WSStoreBean alloc] init];
                bean.srid = self.subempStore.Id;
                i_AcvtViewController = [[WSAcvtViewController alloc]initWithAcvt:i_CurrentAcvtBean Funcs:funbean Store:bean];
            } else {
                i_AcvtViewController = [[WSAcvtViewController alloc]initWithAcvt:i_CurrentAcvtBean Funcs:funbean Store:self.currentStore SubEmpId:_subempid];
                i_AcvtViewController.itemCode = self.itemCode;
            }
        }
        
        i_AcvtViewController.wsSplitController = self.wsSplitController;
        i_AcvtViewController.prepareVisitDate = self.prepareVisitDate;
        i_AcvtViewController.moduleFC = self.moduleFC;
        i_AcvtViewController.currentVisitAction = self.currentVisitAction;
        i_AcvtViewController.isTabMode = self.isTabMode;
        
        if (self.kqArrange) {
            i_AcvtViewController.kqArrange = self.kqArrange;
        }
        i_AcvtViewController.uploadStyle = self.uploadStyle;
        
        self.m_AcvtViewController = i_AcvtViewController;
        
        if (self.m_AcvtViewController) {
            [self addChildViewController:self.m_AcvtViewController];
        }
        
        if (self.ownParentViewController) {
            i_AcvtViewController.m_ParentViewController = self.ownParentViewController;
        }else{
            i_AcvtViewController.m_ParentViewController = self;
            if (!i_AcvtViewController.currentVisitAction) {
                i_AcvtViewController.currentVisitAction = self.currentVisitAction;
            }
        }
        
        self.title = i_AcvtViewController.title;
        
        i_AcvtViewController.view.frame = self.view.bounds;
        i_AcvtViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
       
        [self.view addSubview:self.m_AcvtViewController.view];
        LogInfo(@"[self.m_AcvtViewController.view description]----%@",[self.m_AcvtViewController.view description]);
    }else if ([funbean.isAcvtList isEqualToString:@"2"]){
        WSAcvtGridViewController *gridCon = [[WSAcvtGridViewController alloc] initWithFuncs:funbean Store:self.currentStore];
        gridCon.wsSplitController = self.wsSplitController;
        gridCon.prepareVisitDate = self.prepareVisitDate;
        gridCon.moduleFC = self.moduleFC;
        
        if (gridCon) {
            [self addChildViewController:gridCon];
        }
        
        if (self.ownParentViewController) {
            gridCon.m_ParentViewController = self.ownParentViewController;
        }else{
            gridCon.m_ParentViewController = self;
            if (!gridCon.currentVisitAction) {
                gridCon.currentVisitAction = self.currentVisitAction;
            }
        }
        
        gridCon.view.frame = self.view.bounds;
        gridCon.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        [self.view addSubview:gridCon.view];
        
    }else if( [l_acvtFilters count] >= 1 ||
              // SFA-8592  SFA-9082
             [self.currentFuncs.opt.addType isEqualToString:self.currentFuncs.filter]) {
       
        [self.m_acvtListViewController removeFromParentViewController];
        self.m_acvtListViewController = nil;
        
        WSAcvtListViewController *acvtList ;
        if (self.currentStore) {
            
            if (self.hosBean) {
                acvtList = [[WSAcvtListViewController alloc]initWithFuncs:funbean Store:self.currentStore hosBean:self.hosBean];
            }else {
                acvtList = [[WSAcvtListViewController alloc] initWithFuncs:funbean Store:self.currentStore];
            }
            
            
            
        }else{
            acvtList = [[WSAcvtListViewController alloc]initWithFuncs:funbean];
        }
        acvtList.currentVisitAction = self.currentVisitAction;
        acvtList.isTabMode = self.isTabMode;
        
        acvtList.Subempid=_subempid;
        self.m_acvtListViewController = acvtList;
        acvtList.m_ParentViewController = self.ownParentViewController;
        acvtList.prepareVisitDate = self.prepareVisitDate;
        acvtList.wsSplitController = self.wsSplitController;
        acvtList.filterResult = _filterResult;
        [self addChildViewController:self.m_acvtListViewController];
        self.m_acvtListViewController.view.frame = self.view.bounds;
        self.m_acvtListViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:self.m_acvtListViewController.view];
        
    }else{
        [self addEmptyView];
    }
}
- (void)viewDidLoad{
    [super viewDidLoad];
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(MAIN_BUTTON_WH, 0, MAIN_BUTTON_WH, 44)];
    
    [backBtn setBackgroundColor:[UIColor clearColor]];
    
    [backBtn setImage:[UIImage scaledImageForName:@"icon_back" ofType:@"png"] forState:UIControlStateNormal];
    
    //    [backBtn setImage:[UIImage imageForName:@"icon_back_press.png"] forState:UIControlStateHighlighted];
    
    [backBtn addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *homeButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
   
    self.navigationItem.leftBarButtonItem=homeButtonItem;
    
    if ([self.currentFuncs.opt.isHiddenBack isEqualToString:@"1"]) {
        self.navigationItem.leftBarButtonItem = nil;
    }
    
}

-(void)backClicked{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
//MN-2866 开发该功能时发现问题 自行修复
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.view.subviews containsObject:self.empty]) {
        [self getNavigationItem].rightBarButtonItems = nil;
    }
    if ([self.currentFuncs.opt.isHiddenBack isEqualToString:@"1"]) {
        self.navigationItem.hidesBackButton = YES;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void)initializationBackItemAction{
    if (self.currentFuncs && _isFuncsHomePageWillShow) {
        if (self.currentFuncs && self.currentFuncs.opt && [self.currentFuncs.opt.isReturnHome isEqualToString:@"1"]) {
            NSDictionary *mobileHomeDic = [WSAppData getObjectbyKey:MOBILEHOMEPAGE];
            if (mobileHomeDic) {
                NSString *readTimeStr = [mobileHomeDic objectForKey:MobileHomePageReadingTimeKey];
                [self backItemAction:nil target:nil withDelay:[readTimeStr intValue]];
            }
            
        }else{
            self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
            if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
                self.navigationController.interactivePopGestureRecognizer.enabled = NO;
            }
        }
        self.currentFuncs.isHomePageWillShow = NO;
        _isFuncsHomePageWillShow = NO;
    }
    else if (self.m_AcvtViewController){
       
       [self backItemAction:@selector(backAction) target:self];
       
    }
    else{
        
        [self backItemAction:@selector(popList) target:self];
    }
}

- (void)popList
{
    WSVisitStoreActionObject *queryBean = [[WSVisitStoreActionObject alloc] init];
    queryBean.parent_action_id = self.currentVisitAction.ID;
    queryBean.store_id = self.currentStore.Id;
    queryBean.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    queryBean.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
    queryBean.status = ActionNotStart;
    queryBean.is_required = @"R";
    queryBean.module_fc = self.currentVisitAction.module_fc;
    queryBean.ID = (int)[[WSVisitStoreActionTable sharedTable] queryActionId:queryBean];
    NSArray *notcompleteArray = [[WSVisitStoreActionTable sharedTable] queryNotCompleteButRequiredAction:queryBean];
    if(notcompleteArray && notcompleteArray.count > 0){
        for(WSVisitStoreActionObject *storeAction in notcompleteArray)
        {
            WSAcvtListFlagArray* array=[WSAppData getObjectbyKey:MENUACVTLISTFLAG];
  
            NSPredicate* pre=[NSPredicate predicateWithFormat:@"self.empId==%@ and self.acvtId==%@",storeAction.emp_id,storeAction.dict_id];
            if (self.currentStore.Id) {
                pre=[NSPredicate predicateWithFormat:@"self.empId==%@ and self.acvtId==%@ and self.storeId==%@",storeAction.emp_id,storeAction.dict_id,self.currentStore.Id];
            }
            NSArray* filterArray=[array.acvtArray filteredArrayUsingPredicate:pre];
            if(filterArray.count < 1){
                [self executeValidateLuaScripWithFb:self.currentFuncs functionName:@"function onBackRequireCheck(" params:storeAction.title];
                return;
            }
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)backAction {
    // YIHAIKERRY-2113 此处直接调用子viewController的backAction
    [self.m_AcvtViewController backAction];
    
//    BOOL isPromptUpload = NO;
//     [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
//    // SFA-11750 SFA葵花药业--手机端问卷设置必填，需要控制必须填写，才能离开
//    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
//    //    MMSH-3477
//    //    SFA玛氏中国MWC- 【IOS:拜访】WS 门店（10253444）（账号50949，1111）在“位置”表单点击返回没有提示“取消/上传/放弃”，而提示“请上传数据”
//    // 问卷调查是否必填是由脚本控制 和配置isReq 无关
//    if (model.isReqFromLua) {
//        if (model.qstDBValueDictionary.count == 0) {
//            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"Please_input_data", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
//            return;
//        }
//    }
//
//    if ([self.m_AcvtViewController respondsToSelector:@selector(isValueChange)]) {
//        if ([self.m_AcvtViewController performSelector:@selector(isValueChange)]) {
//            isPromptUpload = YES;
//        }
//    }
//    if (isPromptUpload) {
//
//        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"back_confirm2", nil)];
//
//        [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:nil];
//        [alert addButtonWithTitle:NSLocalizedString(@"upload_label", nil) block:^{
//            //isHomeBackAction = NO;
//
//            [self.m_AcvtViewController executeUpload];
//        }];
//        [alert addButtonWithTitle:NSLocalizedString(@"give_up", nil) block:^{
//
//            [self.navigationController popViewControllerAnimated:YES];
//
//        }];
//        [alert show];
//        return;
//
//    }
    
//
//    BOOL isUpload = [self hasSTQstToUpload];
//    if (!isUpload) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
}




- (BOOL)isValueChange
{
    if ([self.m_AcvtViewController respondsToSelector:@selector(isValueChange)]) {
        return [self.m_AcvtViewController isValueChange];
    }
    
    return NO;
}

- (BOOL)shouldPauseBackAction {
    
    if ([self.m_AcvtViewController respondsToSelector:@selector(shouldPauseBackAction)]) {
        return [self.m_AcvtViewController shouldPauseBackAction];
    }
    
    return NO;
}


- (BOOL)isHiddenCurrentTab {
    if (![self isFuncsBeanValid]) {
        return YES;
    }
    
    NSArray *l_acvtFilters = [WSAcvtListViewController filterAcvtListWithCurrentFuncs:self.currentFuncs withCurrentStore:self.currentStore];
    if ([l_acvtFilters count] == 0) {
        return YES;
    }
    return NO;
}
-(void)executeInterAction:(WSInterAction *)interaction
{
    _filterResult = interaction.execute_result;
}
@end

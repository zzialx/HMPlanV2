//
//  SuperWorkSpaceViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-15.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "SuperWorkSpaceViewController.h"
#import "WSFuncsBean.h"
#import "WSStoreBean.h"
#import "WSAppData.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSRequestHelper.h"
#import "WSStoreInfoViewController.h"
#import "WSAcvtListViewController.h"
#import "WSAcvtViewController.h"
#import "WSFuncsBeanArray.h"
#import "WSRequestHelper.h"

static NSString *const kWorkQueryAdditionalRemindNotify = @"kWorkQueryAdditionalRemindNotify"; //工作查询额外提醒通知

@interface SuperWorkSpaceViewController () {
}

@property (nonatomic, copy) WCWorkQueryAdditionalRemindBlock workQueryAdditionalRemindBlock; //工作查询额外提醒闭包

- (void)workQueryAdditionalRemindFinish:(id)sender;   //工作查询额外提醒成回调方法

@end

@implementation SuperWorkSpaceViewController

@synthesize currentFuncs = _currentFuncs;
@synthesize parentViewHasSegment = _parentViewHasSegment;


-(id)initWithFuncs:(WSFuncsBean*)funcs
{
    if(funcs == nil)
        return nil;

    self = [super init];
    if(self != nil)
    {
        self.currentFuncs = funcs;
        self.title = funcs.name;
        return self;
    }
    return nil;
}

- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store
{
    if(funcs == nil)
        return nil;
    
    self = [super init];
    if(self != nil)
    {
        self.currentFuncs = funcs;
        self.title = funcs.name;
        self.currentStore=store;
        return self;
    }
    return nil;
}


- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store hosBean:(WSHosBean*)hosBean {
    if (funcs == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.currentFuncs = funcs;
        self.title = funcs.name;
        self.currentStore=store;
        self.hosBean = hosBean;
        return self;
    }
    return nil;
}


- (id)initWithFuncs:(WSFuncsBean *)funcs subempStore:(WSSubempstoreBean *)subempStore {
    self = [self initWithFuncs:funcs];
    if (self) {
        if ([subempStore isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)subempStore;
            _subempStore =[dict objectForKey:@"subEmpStoreBean"];
        }else{
            _subempStore = subempStore;
        }
        return self;
    }
    return nil;
}

- (instancetype)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store acvtNewStore:(WSStoreBean *)acvtNewStore {
    self = [self initWithFuncs:funcs Store:store];
    if (self) {
        self.acvtNewStore = acvtNewStore;
        if (acvtNewStore) {
            self.currentStore = acvtNewStore;
        }
    }
    return self;
}

- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store subEmpStore:(WSSubempstoreBean *)subempStore {
    self = [self initWithFuncs:funcs];
    if (self) {
        _subempStore = subempStore;
        _currentStore = store;
        return self;
    }
    return nil;
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
#endif
    
    if (INTERFACE_IS_PAD) {
        self.view.backgroundColor = RGBCOLOR(246, 246, 246);
    }
    
    [self initializationBackItemAction];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.originalViewYPosition = [NSNumber numberWithFloat:self.view.frame.origin.y];
    self.navigationController.toolbarHidden=YES;
}


#pragma mark - public method

-(int) initializationSelectSegment
{
    if (self.currentFuncs && self.currentFuncs.isHomePageWillShow) {
        NSDictionary *mobileHomeDic = [WSAppData getObjectbyKey:MOBILEHOMEPAGE];
        if (mobileHomeDic) {
            NSString *fcValue = [mobileHomeDic objectForKey:MobileHomePageFcKey];
            for(int i = 0 ; i < [self.currentFuncs.funcsArray count];i++) {
                WSFuncsBean* subfuncs = [self.currentFuncs.funcsArray objectAtIndex:i];
                if ([subfuncs.fc isEqualToString:fcValue]) {
                    return i;
                }
            }
        }
    }
    
    return 0;
}

-(void)initializationBackItemAction
{
    if (self.currentFuncs && self.currentFuncs.isHomePageWillShow) {
        NSDictionary *mobileHomeDic = [WSAppData getObjectbyKey:MOBILEHOMEPAGE];
        if (mobileHomeDic) {
            NSString *readTimeStr = [mobileHomeDic objectForKey:MobileHomePageReadingTimeKey];
            [self backItemAction:nil target:nil withDelay:[readTimeStr intValue]];
            self.currentFuncs.isHomePageWillShow = NO;
        }
    }else {
        
        [self backItemAction:nil target:nil];
    }
}

- (void)refreshControllerTitle:(NSString *)title
{
    if ([self.delegate respondsToSelector:@selector(superWorkSpaceVC:refreshControllerTitle:)]) {
        [self.delegate superWorkSpaceVC:self refreshControllerTitle:title];
    }
}

//TO DO  SFA-22331
//【泸州老窖-ios】手机端所有模块的拜访列表头部点击可以自动进入该终端的明细数据（同客户管理）
- (void)startGetStoreInfoBySotre:(WSStoreBean *)store {
    [self querying_messageTips];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(storeInfoRequestFinish:)
                                                 name:NOTIFY_STOREINFO
                                               object:nil];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSString *storeId = store.sid ? store.sid : self.currentStore.Id;
    [dictionary setObject:[NSString stringNotNilWithValue:storeId] forKey:WSREQUEST_STOREID];
    [dictionary setObject:@"1" forKey:@"compress"];
    [dictionary setObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]] forKey:APPDATA_EMPIDBIGI];
    
    //SFA-25741
    if (self.currentFuncs.isStoreInfo) {
        WSFuncsBeanArray *funcsArray = [WSAppData getObjectbyKey:FUNCS];
        WSFuncsBean *funcsBean = [funcsArray getFuncsBeanWithFC:self.currentFuncs.isStoreInfo];
        if (funcsBean.opt.nextAcvtNode  && funcsBean.opt.nextAcvtNode.length > 0 ) {
            [dictionary setObject:funcsBean.opt.nextAcvtNode forKey:APPDATA_OBJID];
        }
        else
        {
            //SFA-25790 donghong
            [dictionary setObject:@"acvtForEditStore" forKey:APPDATA_OBJID];
        }
    }
    else
    {
        // SFA-21760
        if (self.currentFuncs.opt.nextAcvtNode  && self.currentFuncs.opt.nextAcvtNode.length > 0 ) {
            [dictionary setObject:self.currentFuncs.opt.nextAcvtNode forKey:APPDATA_OBJID];
        } else {
            [dictionary setObject:@"acvtForEditStore" forKey:APPDATA_OBJID];
        }
    }


    [[WSRequestHelper shareInstance] postRequestData:dictionary notifyName:NOTIFY_STOREINFO];
}

- (void)storeInfoRequestFinish:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTIFY_STOREINFO
                                                  object:nil];
    
    
    self.navigationController.navigationBar.userInteractionEnabled=YES;
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    NSString *acvtId = nil;
    if (error) {
        
        [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
        LogError(@"%@",error);
    }else{
        NSDictionary *infoDic = [info objectFromJSONString];
        NSArray *storeInfoArr = nil;
        
        //SFA-25741
        if (self.currentFuncs.isStoreInfo) {
            WSFuncsBeanArray *funcsArray = [WSAppData getObjectbyKey:FUNCS];
            WSFuncsBean *funcsBean = [funcsArray getFuncsBeanWithFC:self.currentFuncs.isStoreInfo];
            if (funcsBean.opt.nextAcvtNode  && funcsBean.opt.nextAcvtNode.length > 0 ) {
                storeInfoArr = [infoDic objectForKey:funcsBean.opt.nextAcvtNode];
            }
            else
            {
                //SFA-25790 donghong
                storeInfoArr = [infoDic objectForKey:@"acvtForEditStore"];
            }
        }
        else
        {
            if (self.currentFuncs.opt.nextAcvtNode  && self.currentFuncs.opt.nextAcvtNode.length > 0 ) {
                storeInfoArr = [infoDic objectForKey:self.currentFuncs.opt.nextAcvtNode];
            } else {
                storeInfoArr = [infoDic objectForKey:@"acvtForEditStore"];
            }
        }

        if (storeInfoArr == nil) {
            storeInfoArr = @[];
        }
        NSDictionary *storeInfoDic = [storeInfoArr objectAtIndex:0];
        acvtId = [storeInfoDic objectForKey:@"acvtId"];
        
        //SFA-28777
        //NSArray *storeActs = [storeInfoDic objectForKey:STOREACVTDIS];
        NSMutableArray *storeActs = [[NSMutableArray alloc] init];
        NSMutableArray *keys = [[NSMutableArray alloc] init];
        for (NSString *key in storeInfoDic.allKeys) {
            if ([key hasPrefix:STOREACVTDIS]) {
                [storeActs addObjectsFromArray:[storeInfoDic objectForKey:key]];
                [keys addObject:key];
            }
        }

        if (!acvtId || !storeActs || storeActs.count == 0) {
            [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"load_data_failure", nil) tips:nil tapTarget:nil action:nil
                                     type:MBProgressHUDMessageTypeFailed];
            LogError(@"修改门店信息，后台没有下发acvtId");
            return;
        }
        
        if (storeActs.count > 0) {
            WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
            //SFA-28777
            //[service replaceToTableWithDicts:storeActs FromNode:STOREACVTDIS hasNewData:YES storeID:self.currentStore.Id isRemoteSearch:YES];
            for (NSString *key in keys) {
                [service replaceToTableWithDicts:storeActs FromNode:key hasNewData:YES storeID:self.currentStore.Id isRemoteSearch:YES];
            }

            NSString *deleteLocalAcvtData = [NSString stringWithValue:[storeInfoDic objectForKey:@"deleteLocalAcvtData"]];
            if ([deleteLocalAcvtData isEqualToString:@"1"]) {
                [service deleteLocalDataWithStoreId:self.currentStore.Id acvtId:acvtId];//实时请求门店信息后以服务器数据为准，清除本地编辑的数据
            }
        }
        
        //SFA-26211
        //如果有storeinfo对应的菜单，则使用此菜单进行修改门店操作，否则用上级funcmodel
        WSFuncsBean *funcs = self.currentFuncs;
        WSFuncsBeanArray *funcsArray = [WSAppData getObjectbyKey:FUNCS];
        if (funcs.isStoreInfo && funcs.isStoreInfo.length > 0) {
            WSFuncsBean *storeInfoFuncs = [funcsArray getFuncsBeanFromAllFucsWithFC:funcs.isStoreInfo];
            // SFA-25357 如果有值才赋给 funcs
            if (storeInfoFuncs) {
                funcs = storeInfoFuncs;
            }
        }
        
        if (!funcs) {
            if (self.realParentFuncsCode.length > 0) {
                funcs = [funcsArray getFuncsBeanWithFC:self.realParentFuncsCode];
            }
        }
        
        NSString *className = [WSPlistHelper valueForKey:self.currentFuncs.ds withPlistName:kControllerMappingFileName];
        // SFA-22331 后台返回调查问卷 ID，且找不到 className 时，走调查问卷逻辑
        if ([className length] == 0 && [acvtId length] > 0) {
            className = @"WSAcvtListViewController";
            //            funcs = nil;
        }
        
        UIViewController* storeInfo = [[NSClassFromString(className) alloc] initWithFuncs:funcs];
        if (storeInfo) {
            self.refreshVisitFlagWhenBackTo = YES;
        }
        if ([storeInfo isKindOfClass:[WSAcvtListViewController class]]) {
            WSAcvtListViewController *acvtListViewCtr = (WSAcvtListViewController *)storeInfo;
            //            [acvtListViewCtr setM_storeInfoDic:dictionary];
            acvtListViewCtr.m_currentStore = self.currentStore;
            
            [acvtListViewCtr initAcvtList:@[[NSString stringNotNilWithValue: acvtId]]];
            
            
            //            NSString* md5str=[self insertTableWithAcvtViewController:acvtListViewCtr acvtId:acvtId];
            
            /*
             为了区分acvtlist中不同类型的acvt(区分三棵树中->客户信息修改列表中专卖店和经销商,更改代码也适用于不区分acvt的情况)
             */
            WSAcvtBean* l_acvtBean;
            if (acvtListViewCtr.m_currentAcvtArray) {
                for (NSInteger i = 0; i < [acvtListViewCtr.m_currentAcvtArray count]; i++) {
                    WSAcvtBean *currentAcvtBean = [acvtListViewCtr.m_currentAcvtArray objectAtIndex:i];
                    if ([currentAcvtBean.acvtId isEqualToString:acvtId]) {
                        l_acvtBean = currentAcvtBean;
                    }
                }
            }
            self.currentAcvt = l_acvtBean;
            WSAcvtViewController *avc = [[WSAcvtViewController alloc]initWithAcvt:l_acvtBean Funcs: acvtListViewCtr.m_currentFuncs Store:acvtListViewCtr.m_currentStore];
            avc.isShowStoreName = YES;
            //avc.title = l_acvtBean.acvtName;
            avc.model.isFromModifyStore = YES;
            
            // action应该是和当前选中的store相关
            WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
            action.parent_action_id = self.currentVisitAction.ID;
            action.store_id = self.currentStore.Id;
            action.func_code = self.currentFuncs.fc;
            action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
            action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
            action.title = self.currentFuncs.name;
            if (self.currentVisitAction
                && self.currentVisitAction.module_fc
                && [self.currentVisitAction.module_fc length] > 0) {
                
                action.module_fc = self.currentVisitAction.module_fc;
            }else{
                
                action.module_fc = action.func_code;
            }
            action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
            avc.currentVisitAction = action;
            
            [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
            
            [[self getNavigationController] pushViewController:avc animated:YES];
            avc = nil;
            
        }
        else
        {
            
            [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
            NSString *StoreInforString = NSLocalizedString(@"store_info", nil);
            storeInfo.title = StoreInforString;
            
            [self getNavigationController].hidesBottomBarWhenPushed = YES;
            [[self getNavigationController].navigationController pushViewController:storeInfo animated:YES];
        }
        
    }
}
- (WSFuncsBean *)getRealFuncBeanNeedSubMenu:(BOOL)needSubMenu
{
    WSFuncsBean* nextfb = nil;
    if (self.currentFuncs.funcsArray != nil && [self.currentFuncs.funcsArray count] == 1) {
        WSFuncsBean *tempSub = [self.currentFuncs.funcsArray objectAtIndex:0];
        // SFA-23991
        //兼容三棵树部分升级时老配置,多一层TAB_V11001
//        if ([tempSub.fv isEqualToString:self.currentFuncs.fv] && tempSub.funcsArray.count == 1) {
//            tempSub = [tempSub.funcsArray firstObject];
//            nextfb = tempSub;
//        }
        // MN-3589
        //if ([tempSub.fv isEqualToString:FV_TAB_V21001]) {
            nextfb = tempSub;
        //}
    }
    
    /*
     * 优先使用subMenu
     * 如果没有subMenu，但是下一级页面为FV_TAB_V21001，则使用下一级页面
     * 都没有时使用self.currentFuncs
     */
    WSFuncsBean *realFuncBean;
    if (needSubMenu) {
        realFuncBean = self.subMenuFuncsBean;
    }    if (!realFuncBean && nextfb) {
        realFuncBean = nextfb;
    }
    if (!realFuncBean) {
        realFuncBean = self.currentFuncs;
    }
    
    return realFuncBean;
}

#pragma mark - 查询额外提醒方法 empId:用户id storeId:门店id completionBlock:完成闭包
- (void)queryAdditionalRemindWithEmpId:(NSString *)empId storeId:(NSString *)storeId completionBlock:(WCWorkQueryAdditionalRemindBlock)completionBlock {
    
    NSString *extraReminderNodeName = [WSAppData getObjectbyKey:APPDATA_EXTRA_REMINDER_NODE_NAME];
    if (extraReminderNodeName && extraReminderNodeName.length > 0) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(workQueryAdditionalRemindFinish:) name:kWorkQueryAdditionalRemindNotify object:nil];
        
        self.workQueryAdditionalRemindBlock = completionBlock;
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
        [dic setObject:[NSString stringNotNilWithValue:storeId] forKey:@"storeId"];
        [dic setObject:[NSString stringNotNilWithValue:extraReminderNodeName] forKey:@"objId"];
        
        WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
        [uploadMgr uploadDatasDictionary:dic urlString:URL_UPDATE notifyName:kWorkQueryAdditionalRemindNotify md5:nil isUpload:NO];
        return;
    }
    
    if (completionBlock) {
        completionBlock(YES, nil);
    }
}

#pragma mark - 工作查询额外提醒成回调方法
- (void)workQueryAdditionalRemindFinish:(id)sender {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kWorkQueryAdditionalRemindNotify object:nil];
    
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error){
        
        if (self.workQueryAdditionalRemindBlock) {
            self.workQueryAdditionalRemindBlock(NO, NSLocalizedString(@"network_failure",nil));
            self.workQueryAdditionalRemindBlock = nil;
        }
        return;
    }
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSDictionary *dataDic = [info objectFromJSONString];
    NSArray *array = [dataDic objectForKey:[WSAppData getObjectbyKey:APPDATA_EXTRA_REMINDER_NODE_NAME]];
    NSDictionary *dict = [array firstObject];
    
    if (![dict.allKeys containsObject:APPDATA_EXTRA_REMINDER_NODE_NAME_KEY]) {
        if (self.workQueryAdditionalRemindBlock) {
            self.workQueryAdditionalRemindBlock(NO, NSLocalizedString(@"server_reponse_error",nil));
            self.workQueryAdditionalRemindBlock = nil;
        }
        return;
    }
    
    NSString *result = [dict objectForKey:APPDATA_EXTRA_REMINDER_NODE_NAME_KEY];
    if (self.workQueryAdditionalRemindBlock) {
        self.workQueryAdditionalRemindBlock(YES, result);
        self.workQueryAdditionalRemindBlock = nil;
    }
}

@end

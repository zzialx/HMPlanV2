//
//  WSEnterStoreAcvtViewController.m
//  WinSFA
//
//  Created by heju on 15/12/20.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSEnterStoreAcvtViewController.h"

#import "WSInoutStoreTable.h"

#import "WSPhotoTypeItem.h"

#import "WCOptionalSource.h"

#import "WSFuncsBean_other.h"

#import "WSPhotoTypeArrayItem.h"

#import "WSJSONBuilder.h"

#import "WSRequestHelper.h"

#import "WSBeaconManager.h"

#import "WSVisitStoreStatusTable.h"

#import "WSEnvrionment.h"

#import "WSPhotoViewPanel.h"

#import "WSBaseModel.h"

#import "WSAcvtModel.h"

#import "WSEnterStoreAcvtModel.h"
#import "WSHidedMapPanel.h"
#import "WSMapPanel.h"

#import "WSBaseFunsDBService.h"

@interface WSEnterStoreAcvtViewController ()

@property (nonatomic, strong) NSString *enterStoreTimeStamp;

@end

@implementation WSEnterStoreAcvtViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title =  self.currentFuncs.name;
    self.enterStoreTimeStamp = [WSCurrentTime getServerTime];
    ((WSAcvtModel *)self.model).luaExecuteParams = [WSCurrentTime getDateTime];
}

- (void)createModel {
    
    self.model = [[WSEnterStoreAcvtModel alloc] init];
    
}

- (void)executeRealUpload {
    
    if (![super uploadVisitAction]) {
        [self showDBErrorTipAndHidAllHud];
        return;
    }
    
    //上传表格数据
    if (![self uploadPhotosForTable]) {
        [self showDBErrorTipAndHidAllHud];
        return;
    }
    
    if (![self uploadDatas]) {
        // 数据库插入失败提示
        [self showDBErrorTipAndHidAllHud];
        return;
    }
    
    //上传照片
    //YIHAIKERRY-1541 SFA 益海嘉里-深圳 IOS：门店拜访，开始拜访拍照点击签到时，APP闪退
    if (![self uploadPhotosForAcvtView:YES]) {
        [self showDBErrorTipAndHidAllHud];
        return;
    }
    
    
    //设置结束节点标志
    WSFuncsBean *parent = self.currentFuncs.iParentFuncsBean;
    
    NSArray *array = parent.funcsArray;
    WSFuncsBean *leavestore = nil;
    // 不同类型的门店（测试门店，经销商门店） 结束拜访和开始拜访的fv一样,但fc不一样
    // 判断是否重复进店时候需要判断该拜访项是否属于此类门店
    // 否则会引起不能离店的情况
    // 规则见WSWorkFlowViewController类的initWorkFlow方法。
    for (WSFuncsBean *bean in array) {
        if ([bean.fv isEqualToString:LEAVESTORE_FV]) {
            if (self.currentStore.styp && bean.styp) {
                if ((bean.styp && [self.currentStore.styp hasPrefix:bean.styp])  || (!bean.styp || !(bean.styp.length > 0))) {
                    leavestore = bean;
                    break;
                }
                
            }  else if(!bean.styp) {
                
                leavestore = bean;
                break;
            }
        }
    }
    
    WSVisitStoreActionObject *enterstoreAction = self.currentVisitAction;
    
    //处理重复进店
    if (self.currentVisitAction && leavestore != nil)
    {
        NSArray *arr =[[WSVisitStoreActionTable sharedTable] queryActionsWithObject:enterstoreAction];
        
        
        if ([arr count]==0) {
            
            arr = [[WSVisitStoreActionTable sharedTable] queryActionsWithObjectExceptParentId:enterstoreAction];
            if([arr count]>0){
                
                WSVisitStoreActionObject *taction = [arr objectAtIndex:0];
                
                WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
                
                NSLog(@"==>>>>> %@",self.input_reflect_code);
                
                action.parent_action_id = taction .parent_action_id;
                action.store_id = self.currentVisitAction.store_id;
                action.func_code = leavestore.fc;
                action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
                action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
                action.is_required = leavestore.required;
                action.title = leavestore.name;
                if (self.currentVisitAction
                    && self.currentVisitAction.module_fc
                    && [self.currentVisitAction.module_fc length] > 0) {
                    action.module_fc = self.currentVisitAction.module_fc;
                }else{
                    action.module_fc = action.func_code;
                }
                if (![action.status isEqualToString:ActionNotStart] )
                {
                    [[WSVisitStoreActionTable sharedTable] updateAction:action toStatus:ActionNotStart];
                }
                
            }else{
                
                WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
                
                NSLog(@"==>>>>> %@",self.input_reflect_code);
                
                action.parent_action_id = self.currentVisitAction.parent_action_id;
                action.store_id = self.currentVisitAction.store_id;
                action.func_code = leavestore.fc;
                action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
                action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
                action.is_required = leavestore.required;
                action.title = leavestore.name;
                if (self.currentVisitAction
                    && self.currentVisitAction.module_fc
                    && [self.currentVisitAction.module_fc length] > 0) {
                    action.module_fc = self.currentVisitAction.module_fc;
                }else{
                    action.module_fc = action.func_code;
                }
                
                NSLog(@"==>>> %@   , %@ ",self.relate_sub_menu_code,self.currentVisitAction.module_fc);
                
                VisitActionStatus status = [[WSVisitStoreActionTable sharedTable] queryActionStatus:action];
                // VisitActionStatus status = [[WSVisitStoreActionTable sharedTable] queryActionStatus:action intOutFlag:self.relate_sub_menu_code];
                if (![status isEqualToString:ActionNotStart] )
                {
                    
                    [[WSVisitStoreActionTable sharedTable] updateAction:action toStatus:ActionNotStart];
                    //[[WSVisitStoreActionTable sharedTable] updateAction:action toStatus:ActionNotStart inOutFlag:self.relate_sub_menu_code];
                    
                    
                }
            }
            
        }else{
            
            WSVisitStoreActionObject *taction = [arr objectAtIndex:0];
            
            WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
            
            action.parent_action_id = taction .parent_action_id;
            action.store_id = self.currentVisitAction.store_id;
            action.func_code = leavestore.fc;
            action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
            action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
            action.is_required = leavestore.required;
            //action.title = leavestore.name;
            if (self.currentVisitAction
                && self.currentVisitAction.module_fc
                && [self.currentVisitAction.module_fc length] > 0) {
                action.module_fc = self.currentVisitAction.module_fc;
            }else{
                action.module_fc = action.func_code;
            }
            if (![action.status isEqualToString:ActionNotStart] )
            {
                [[WSVisitStoreActionTable sharedTable] updateAction:action toStatus:ActionNotStart];
            }
            
        }
        
    }
    if (self.currentStore.beaconUUId) {
        [[WSBeaconManager getInstance] startBeaconWithUUID:self.currentStore.beaconUUId withStoreId:self.currentStore.Id];
    }
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    NSString *tip = NSLocalizedString(@"add_upload_queue", nil);
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tip tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
    [[NSNotificationCenter defaultCenter] postNotificationName:ENTER_OR_LEAVESTORE_RELOAD_STORE_LIST object:nil];
    [self addVisitInStoreNotification];
    [self backToParent];
}

#pragma mark - 上传数据方法
- (BOOL)uploadDatas {

    __block NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithCapacity:8];
    
    NSString *enable_gps = [CLLocationManager locationServicesEnabled] ? @"1" : @"0";
    [jsonDict setObject:enable_gps forKey:GPS_ENABLE_GPS];
    
    NSMutableDictionary *newWorkDic = [self  getNetWorkStatus];
    [newWorkDic enumerateKeysAndObjectsUsingBlock:^(id   key, id  obj, BOOL *stop) {
        [jsonDict setObject:obj forKey:key];
    }];
    
    //逻辑挪到 [self.acvtview getAcvtQstMemoValues] 内
    //NSMutableDictionary *gpsInfo = [self getNewAcvtGpsInfo];
    //[jsonDict setDictionary:gpsInfo];
    NSMutableDictionary *qstMemoValuesDict = (NSMutableDictionary *)[self.acvtview getAcvtQstMemoValues];
    [qstMemoValuesDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [jsonDict setObject:obj forKey:key];
    }];
    //传递parentcode
    WSBaseFunsDBService * bsDB  = [[WSBaseFunsDBService alloc]init];
    NSString * parentFC = [bsDB getParentFuncsCode:self.currentFuncs.fc];
    if(parentFC&&parentFC.length>0){
        [jsonDict setObject:parentFC forKey:@"parentFc"];
    }
    BOOL isCustomEnterStore = NO;
    if ([((WSAcvtModel *)self.model).customEnterStoreTimeDic count] > 0) {
        [jsonDict addEntriesFromDictionary:((WSAcvtModel *)self.model).customEnterStoreTimeDic];
        isCustomEnterStore = YES;
    }
    //SFA 进店时间规则修订为点击上传问卷的时间,获取服务器计时时间
    self.enterStoreTimeStamp = [WSCurrentTime getServerTime];
    
    BOOL hasPhoto = [self newAcvtHasPhoto];
    NSString *postData = [WSJSONBuilder buildEnterLeaveStorebyFuncs:self.currentFuncs
                                                            isPhoto:hasPhoto
                                                              Store:self.currentStore
                                                           jsonData:jsonDict
                                                                md5:self.model.md5
                                                   isUsingDataEntry:isCustomEnterStore
                                                     enterLeaveTime:self.enterStoreTimeStamp];
    
    NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
    NSString *enterStoreMark = [NSString stringWithFormat:@"%@%@", @"EnterStore", self.currentStore.Id];
    NSString *newMd5 = [[NSString alloc] initWithFormat:@"%@_%@_%@", self.currentFuncs.fc, enterStoreMark, self.model.md5];
    BOOL insertSuccess = [self insertUploadData:postData URL:URL_UPLOAD MD5:newMd5 IsPhoto:NO NotifyName:notifyID];
    if (!insertSuccess) {
        return NO;
    }
    
    [self updateStoreVisitStaus:VisitStoreWorking];
    [self uploadFaieldToInsertKeysAndValues];
    
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    [uploadMgr postRequestOnEnterLeaveStorebyData:postData md5:self.model.md5 notifyName:notifyID];
    
    return YES;
}


/*检测当前位置与门店的距离是否有效*/

-(BOOL)checkTheCurrentDistanceIsValidFromStore {
    
    BOOL locatonIsValid = YES;
    NSString *isGps = self.currentFuncs.opt.isGps;
    if (isGps && [isGps isKindOfClass:[NSString class]] && [isGps isEqualToString:REQUIRED_D]) {
        if (!self.currentStore.latitude || !self.currentStore.longitude) {
            locatonIsValid = NO;
        }
        if (!self.location.coordinate.latitude || !self.location.coordinate.longitude) {
            locatonIsValid = NO;
        }
        
        if (self.currentStore.latitude && self.currentStore.longitude && self.location){
            CLLocation *storeLocation = [[CLLocation alloc] initWithLatitude:self.currentStore.latitude longitude:self.currentStore.longitude];
            double distance = [[WSLocationManager getInstance] distanceUserLocattion:self.location fromStoreLocation:storeLocation];
            if (distance > ENTER_STORE_VALID_DISTANCE) {
                locatonIsValid = NO;
            }
        }
    }
    return locatonIsValid;
}

-(void)showCurrentLocationIsError{
    NSString *cancelTitle = NSLocalizedString(@"cancel_label", nil);
    NSString *destructiveTitle = NSLocalizedString(@"confirm", nil);
    NSString *message = NSLocalizedString(@"visit_location_error", nil);

    if (IOS8_OR_LATER) {
        UIAlertController *alterController = [UIAlertController alertControllerWithTitle:APP_DISPLAY_NAME message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }];
        UIAlertAction *destructiveAction = [UIAlertAction actionWithTitle:destructiveTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            /*添加拍照按钮代码*/
            [self addPhotoButtonWhenDistanceIsInvalid];
            
        }];
        [alterController addAction:cancelAction];
        [alterController addAction:destructiveAction];
        [self presentViewController:alterController animated:YES completion:nil];
        
    } else {
        UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:APP_DISPLAY_NAME message:message delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:destructiveTitle, nil];
        alterView.tag = WSDistanceInvliadAlertTag;
        [alterView show];
    }
}

/**
 使用调查问卷D类型(日期类型)问题的答案作为拜访日期
 */
- (NSString *)isUseSelectedQstValueForVisitDate {
    NSMutableDictionary *qstValuesDict = nil;
    qstValuesDict =  (NSMutableDictionary *)[self.acvtview getAllPrepareSubmitData];
    for (WSAcvtBean_qst *qst in self.m_currentAcvt.qsts) {
        if (qst.qstType && [qst.qstType isEqualToString:QST_TYPE_D]) {
            return [qstValuesDict objectForKey:[NSString stringWithFormat:@"%@%@",qst.qstType,qst.acvtQstId]];
        }
    }
    return nil;
}



-(void)uploadFaieldToInsertKeysAndValues
{
    
    //    NSArray *keys=[NSArray arrayWithObjects:@"store_id",@"emp_id",@"is_planed",@"biz_date",@"intime",@"outtime",@"img_idx",@"memo",@"upload_date",@"upload_flag",@"in_lon",@"in_lat",@"out_lon",@"out_lat",@"in_callid",@"out_callid",@"sr_id",@"func_code",@"memo1",@"memo2",@"memo3",@"memo4",@"memo5",@"memo6",@"memo7",@"memo8",@"memo9",@"memo10",VISIT_ID,modulefc, nil];
    NSNumber *isPlan =[NSNumber numberWithBool:YES];
    if ([self.currentStore isKindOfClass:[WSStoreBean class]]) {
        isPlan = [NSNumber numberWithBool:self.currentStore.plan];
    }
    
    
    NSString *lonValues = nil;
    NSString  *latValues = nil;
    
    // WRIGLEY-1453【箭牌IOS】主线，进店改成调查问卷的方式，进店数据没有覆盖，经纬度取值方式修改
    NSMutableDictionary *gpsInfo = [self getNewAcvtGpsInfo];
    if (gpsInfo) {
        if ([gpsInfo objectForKey:@"lon"] && [gpsInfo objectForKey:@"lat"]) {
            lonValues=[NSString stringWithFormat:@"%@",[gpsInfo objectForKey:@"lon"]];
            latValues=[NSString stringWithFormat:@"%@",[gpsInfo objectForKey:@"lat"]];
        }else{
            lonValues=@"null";
            latValues=@"null";
        }
    }else{
        lonValues=@"null";
        latValues=@"null";
    }
    
    // self.isGpsReady 一直为NO，取不到经纬度的值
//    if (!self.isGpsReady) {
//        lonValues=@"null";
//        latValues=@"null";
//    }else {
//        lonValues=[NSString stringWithFormat:@"%.12f",self.location.coordinate.longitude];
//        latValues=[NSString stringWithFormat:@"%.12f",self.location.coordinate.latitude];
//    }
    
    NSString* l_serverTime = self.enterStoreTimeStamp;
    
    
    NSString* storeList_parentFC = @"null";
    if (self.moduleFC) {
        storeList_parentFC = self.moduleFC;
    }
    
    NSString *srid = (self.currentStore.srid && [self.currentStore.srid length] > 0) ? [self.currentStore.srid copy]: @"null";
    
    ///////////////////////////////////////////////////////////////////////////////// 根据配置下的submenu中的配置来进行决定是否打开此开关，如果submenu引用的结果列表的fc不等用当前传入的parentfc，则使用submenu引用结果列表中的fc
    if(self.relate_sub_menu_code){
        if (![storeList_parentFC isEqualToString:self.relate_sub_menu_code]) {
            
            storeList_parentFC = self.relate_sub_menu_code;
            
        }
    }
    /////////////////////////////////////////////////////////////////////////////////  根据配置下的submenu中的配置来进行决定是否打开此开关，如果submenu引用的结果列表的fc不等用当前传入的parentfc，则使用submenu引用结果列表中的fc
    
    NSString *imageIDStr = [self getImageIDsWithAcvt];
    
    // YIHAIKERRY-4194
    id needTip = @"null";
    if ([self.currentFuncs.opt.leaveTipFlag length] > 0 && [self.currentFuncs.opt.leaveTipFlag isEqualToString:self.currentStore.ctyp]) {
        needTip = @"0";
    }
    
    NSArray *values=[NSArray arrayWithObjects:self.currentStore.Id,
                     [WSAppData getObjectbyKey:APPDATA_EMPID],
                     [isPlan stringValue],
                     [WSAppData getObjectbyKey:APPDATA_BIZDATE],
                     l_serverTime,@"null",
                     self.model.md5,
                     @"null",
                     l_serverTime,
                     @"0",
                     lonValues,
                     latValues,
                     lonValues,
                     latValues,
                     @"null",@"null",srid,
                     [NSString stringNotNilWithValue:self.currentFuncs.fc],
                     [NSString stringNotNilWithValue:self.currentStore.name],
                     @"null",@"null",@"null",@"null",@"null",@"null",@"null",@"null",@"null",
                     self.model.md5,
                     storeList_parentFC,(imageIDStr.length > 0 ? imageIDStr :@"null"), needTip, nil];
    
    /*
    NSString *enterTime=[[WSInoutStoreTable sharedTable] getEnterStoreTime:self.currentStore andOtherParam:self.model.md5 andParamType:EParameterType_VisitId];
    
    if (enterTime!=nil)
    {
        NSArray *wNames = @[@"store_id",@"visit_id"];
        NSArray *wValues = @[[NSString stringNotNilWithValue:self.currentStore.Id],[NSString stringNotNilWithValue:self.model.md5]];
        NSArray *names = @[@"intime",@"outtime",@"local_image"];
        NSArray *values = @[l_serverTime,@"null",imageIDStr];
        [[WSInoutStoreTable sharedTable] updateWithNames:names values:values whereName:wNames whereValue:wValues];
        [[WSInoutStoreTable sharedTable] cleanOldData];
    }else {
        [[WSInoutStoreTable sharedTable] insertWithArgumentsValue:values];
    }
     */
    
    //改为先删后插 (玛氏补录时，id不同会产生多条记录，导致进离店状态错误)
    [[WSInoutStoreTable sharedTable] deleteWithNames:@[@"store_id",@"func_code",@"emp_id",@"modulefc"]
                                      ArgumentsValue:@[self.currentStore.Id, [NSString stringNotNilWithValue:self.currentFuncs.fc],[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]] , storeList_parentFC]];
    
    [[WSInoutStoreTable sharedTable] insertWithArgumentsValue:values];
    
    if(self.currentFuncs.opt.automaticDeparture && self.currentFuncs.opt.automaticDeparture.length > 0)
    {

        NSArray  *array = [self.currentFuncs.opt.automaticDeparture componentsSeparatedByString:@","];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
        if (array.count>3) {
            [dic setValue:array[1] forKey:@"time"];
            [dic setValue:array[2] forKey:@"distance"];
            [dic setValue:array[3] forKey:@"autoDistance"];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:AUTOMATIC_DEPARTURE object:nil userInfo:dic];
    }
}

- (NSString *)getImageIDsWithAcvt{
    
    NSMutableArray *imageIds =[NSMutableArray array];
    
    //opt的 拍照
    if (self.photoBrowseView.imageIDArray.count >0) {
        [imageIds addObjectsFromArray:self.photoBrowseView.imageIDArray];
    }
    //acvt中的问题为拍照
    for (WSPhotoViewPanel *photoViewPanel in self.acvtview.photoBrowseViewArray) {
        
        if (!photoViewPanel.photoView) {
            continue;
        }
        if (photoViewPanel.photoView.imageIDArray.count >0) {
            
            [imageIds addObjectsFromArray:photoViewPanel.photoView.imageIDArray];
        }
        
    }
    return [imageIds componentsJoinedByString:@","];

    
    
}

#pragma mark - # 添加进店之后返回上一界面的通知
- (void)addVisitInStoreNotification{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CNY_ACTIVITY_NOT object:self];
    
}

@end

//
//  AddNewStoreViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-3-7.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSAddNewStoreViewController.h"
#import "WSAcvtBean.h"
#import "WSAppData.h"
#import "WSAddStoreTable.h"
#import "WSAcvtBean_qst.h"
#import "WSCurrentTime.h"
#import "WSAddNewStoreViewController.h"
#import "WSRequestHelper.h"
#import "WSJSONBuilder.h"
#import "WSDictBean.h"
#import "WSSelectListView.h"
#import "WSPhotoTypeArrayItem.h"
#import "WSPhotoTypeItem.h"
#import "WSAcvtBean_qst_opt.h"
#import "WSAddStoreQstTable.h"
#import "WSInoutStoreTable.h"
#import "WSStoreAcvtDisBean.h"
#import "WSANTableView.h"
#import "WSInterAction.h"
#import "WSBaseView.h"
#import "WSAcvtModel.h"
#import "WSAddNewStoreModel.h"
#import "WSAcvtView.h"
#import "WSAcvtService.h"
#import "WSEnvrionment.h"
#import "WSStoreDataProcessService.h"
#import "WSBaseAcvtDBService.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSBaseStoreDBService.h"
#import "WSDataSourceManager.h"
#import "WSLuaExecutorManager.h"
#import "wsLuaExecutor.h"

#define COLUMNSCOUNT            5

#define kOfflineTableNotifyIdPrefix_SyncModifyAddedNewStore     @"WSOffline_SyncModifyAddedNewStore"

//2017-09-23-yuanji-add
//=======================================================================================================
#pragma mark - WSAddNewStoreViewController 延展(内部)
@interface WSAddNewStoreViewController ()

- (void)result3Upload:(NSString *)confirm; //上传返回结果为3时再次上传方法
- (void)result4Upload:(NSString *)confirm; //上传返回结果为4时再次上传方法

@end
//=======================================================================================================

@interface WSAddNewStoreViewController()<WSBaseViewDelegate> {
    
}

//@property(nonatomic,copy)NSString* istoreid;
@property(nonatomic,copy)NSString* itimeupdate;
@property(nonatomic,copy)NSString* iUploadFlag;
@property (nonatomic, retain) NSString *notifyId;
@property(nonatomic,copy)NSString* update_md5id;

/*
 First showing qst id in the add store view. The type is the textfield. It is
 store name. Because don't judge store name by anything
 */
@property(nonatomic, strong)NSString *iFirstShowingQstId;

@end


@implementation WSAddNewStoreViewController

@synthesize m_dataSources = _m_dataSources;
@synthesize textField = _textField;
//@synthesize istoreid = _istoreid;
@synthesize itimeupdate = _itimeupdate;
@synthesize iUploadFlag = _iUploadFlag;
@synthesize notifyId = _notifyId;
@synthesize refresh_status;


#pragma mark - init methods
-(id)initWithFuncs:(WSFuncsBean *)funcs
{
    
    WSBaseAcvtDBService *service = [[WSBaseAcvtDBService alloc] init];
    WSAcvtBean *acvtBean = [service queryAcvtByFilter:funcs.filter acvtCode:funcs.opt.isAdd];
    if (!acvtBean) {
        return nil;
    }
    
    self = [super initWithAcvt:acvtBean Funcs:funcs Store:nil];
    if(self != nil)
    {
        self.currentUploadActionType = WSNormalActionType;
        self.isNewAddAcvt = YES;
        return self;
    }
    return nil;
}

- (id)initWithFuncs:(WSFuncsBean *)funcs acvtBean:(WSAcvtBean *)acvtBean storeBean:(WSStoreBean *)storeBean
{
    if (acvtBean == nil) {
        return nil;
    }
    self.isNewAddAcvt = YES;
    
    if (!storeBean) {
        storeBean = [[WSStoreBean alloc] init];
        storeBean.plan = NO;
        storeBean.Id = @"-1";
    }
    
    self = [super initWithAcvt:acvtBean Funcs:funcs Store:storeBean];
    
    if (self) {
        
        self.currentUploadActionType = WSNormalActionType;
        
        return self;
    }
    
    return nil;
}

//// store 及aArray 数据都是事实搜索的，不插入数据库
//- (id)initWithFuncs:(WSFuncsBean *)funcs genId:(NSString *)genId
//{
//    if(!funcs || !genId)
//        return nil;
//    
//    if(self = [self initWithFuncs:funcs])
//    {
//        
//        self.update_md5id = genId;
//        self.currentUploadActionType = WSNormalActionType;
////        self.istoreid = storeObject.store_id;
//        
//        WSStoreBean* store = [[WSStoreBean alloc] init];
//        self.updateGenID = genId;
//        store.plan = NO;
//        store.update_md5id = genId;
////        store.name = storeObject.store_name;
////        if ( && [self.istoreid length] > 0) {
////            store.Id = self.istoreid;
////        }else {
//            store.Id = @"-1";
////        }
//        
//        self.model.md5 = store.update_md5id;
//        self.currentStore = store;
//        
//        [self initAcvtModel];
//        
//        return self;
//    }
//    return nil;
//}

- (id)initWithFuncs:(WSFuncsBean *)funcs acvtId:(NSString *)acvtId genId:(NSString *)genId newStoreId:(NSString *)newStoreId{
    
    if(!funcs || !acvtId || !genId)
        return nil;
    
    WSBaseAcvtDBService *service = [[WSBaseAcvtDBService alloc] init];
    WSAcvtBean *acvtBean = [service queryAcvtWithAcvtID:acvtId];
    
    if (!acvtBean) {
        acvtBean = [service queryAcvtByFilter:funcs.filter acvtCode:funcs.opt.isAdd];
    }
    if (!acvtBean) {
        return nil;
    }
    
    self = [super initWithAcvt:acvtBean Funcs:funcs Store:nil];
    
    if(self != nil)
    {
        refresh_status = BTN_STATUS_REFRESH;
        
        self.currentUploadActionType = WSNormalActionType;
        
        self.updateGenID = genId;
        
        WSStoreBean* store = [[WSStoreBean alloc] init];
        store.Id = @"-1";
        store.plan = NO;
        store.update_md5id = genId;
        
        self.currentStore = store;
        
        if ([newStoreId length] > 0) {
            
            WSStoreBean *newStore = [[WSStoreBean alloc] init];
            newStore.Id = newStoreId;
            self.currentNewStore = newStore;
        }
        
        //MN-316 2018-02-02
        //self.model.md5 = genId;
        self.md5 = genId;
        
        [self initAcvtModel];
        
        return self;
    }
    
    return nil;
}

//- (id)initWithFuncs:(WSFuncsBean *)funcs StoreInfo:(NSArray*)aArray
//{
//    if(funcs == nil|| [aArray count] < 1)
//        return nil;
//    
//    if(self = [self initWithFuncs:funcs])
//    {
//        self.currentUploadActionType = WSNormalActionType;
//        int i = 0;
//        for ( WSAddStoreQstObject* addqst in aArray )
//        {
//            if (i == 0)
//            {
//                NSString* ans_id = addqst.ans_id;
//                self.updateGenID = ans_id;
//                
//                NSArray *whereNames=[NSArray arrayWithObjects:@"update_md5id", nil];
//                NSArray *whereValues=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:addqst.ans_id] ,nil];
//                WSAddStoreObject* storeObject= [[[WSAddStoreTable sharedTable] queryWithNames:whereNames ArgumentsValue:whereValues] firstObject];
//                
//                
//                self.istoreid = storeObject.store_id;
//                
//                WSStoreBean* store = [[WSStoreBean alloc] init];
//                
//                
//                store.plan = NO;
//                store.update_md5id = storeObject.update_md5id;
//                if (self.istoreid && [self.istoreid length] > 0) {
//                    store.Id = self.istoreid;
//                } else {
//                    store.Id = storeObject.update_md5id;
//                }
//                store.name = storeObject.store_name;
//                self.model.md5 = store.update_md5id;
//                self.currentStore = store;
//            }
//            i++;
//            
//            
//        }
//        
//        [self initAcvtModel];
//        [((WSAddNewStoreModel *)self.model) setUpQstDBValueDicWithAddStoreQstObjectArray:aArray];
//        
//        return self;
//    } 
//    return nil;
//}



- (BOOL)backToParent {
    if (self.deleteDBAcvtDatas) {
        [self deleteAcvtDatasWhenHasCalUploadFailedOrGiveup];
         [[NSNotificationCenter defaultCenter] postNotificationName:newStoreNotification object:nil];
    }
    self.deleteDBAcvtDatas = NO;
    return [super backToParent];
}

- (void)createModel
{
    self.model = [[WSAddNewStoreModel alloc] init];
}

- (void)executeRealUpload {
    [self uploadDataByIsNeedAdd:NO isAdd:NO];
}

- (void)executeRealUploadWithCalendar {
    
    NSString *dateStr = nil;
    
    for (int i = 0; i < [[self jsonArray] count]; i ++) {
        
        NSDictionary *qstDic = [[self jsonArray] objectAtIndex:i];
        
        if (i == 0) {
            dateStr = [NSString stringWithFormat:@"%@", [qstDic objectForKey:self.calendarKeyId]];
        }else{
            dateStr = [NSString stringWithFormat:@"%@,%@", dateStr, [qstDic objectForKey:self.calendarKeyId]];
        }
        
    }
    
    NSString *generateNewMd5 = [self generateMd5WhenAcvtHasCalendar:dateStr];
    self.currentUsingNewMd5WhenAcvtHasCalendar = generateNewMd5;
    self.currentCalendarValue = dateStr;
    
    [self uploadDataByIsNeedAdd:NO isAdd:NO];
}

- (void)uploadDataByIsNeedAdd:(BOOL)isNeedAdd isAdd:(BOOL)isAdd {
    if ([self.currentUsingNewMd5WhenAcvtHasCalendar length] > 0) {
        self.model.md5 = self.currentUsingNewMd5WhenAcvtHasCalendar;
        self.md5 = self.currentUsingNewMd5WhenAcvtHasCalendar;
    }
    
    // 阻塞方式的上传等待 acvt 数据上传成功后进行上传
    if (![(WSAcvtModel *)self.model isSynchronizeRequest]) {
        if (![self uploadPhotos]) {
            return;
        }
    }
    
    if (![self uploadNewAcvtDatasByIsNeedAdd:isNeedAdd isAdd:isAdd]) {
        [self showDBErrorTipAndHidAllHud];
        return;
    }
  
    //上传完成后，清除已改变标识
    if (![self getIsUpdateCalendarDataFromLua]) {
        [self clearValueChangeData];
    }
    
    
    if (self.operationAcvtType == WSOnlySaveAcvtDataForCalendarType) {
        /*当调查问卷有Cal (日历)类型问题时,调用updateCalendarData:方法时触发此条件*/
    }else {
        [self uploadVisitAction];
        
        // 如果点击的不是开始拜访按钮而是上传按钮 则返回上级页面
        
        if (![(WSAddNewStoreModel*)self.model isSynchronizeRequest]) {
            
            [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
            
            NSString *tip = NSLocalizedString(@"add_upload_queue", nil);
            
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tip tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
            
            if (!self.model.uploadThenNotFinishView) {
                
                if (_update_md5id == nil) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:newStoreNotification object:nil];
                }
                [self popToParentOrHome];
            }
        }
    }
    
}

/*
 * 泸州老窖新增参数，如果添加的门店是重复门店则供用户选择是覆盖还是强制新增
 * isNeedAdd 第一次添加门店时，isNeedAdd = NO，弹出同名列表时后再次添加门店时为 Yes
 * isAdd   是否新增门店，isNeedAdd 为 YES 时有效 isAdd 为 NO 时放弃添加，YES 时新增
 */
- (BOOL)uploadNewAcvtDatasByIsNeedAdd:(BOOL)isNeedAdd isAdd:(BOOL)isAdd
{
    LogTrace();
    
    WSAddNewStoreModel *model = (WSAddNewStoreModel *)self.model;
    
    if (self.isGpsReady) {
        [self addGPSData];
    }
    
    [self initANOfUploadDatasBeforeUpload];
    
    [self saveANDeleteWhenUpload];
    
//    if (!(self.updateGenID && [self.updateGenID length] > 0 && [model isSynchronizeRequest])) {//如果是修改信息，且为同步请求，等请求成功后再更新数据库
//        [model saveAcvtDatasToDB:qstValuesDic];
//    }
    
    NSString *prefix = (self.updateGenID && [self.updateGenID length] > 0) ? kOfflineTableNotifyIdPrefix_ModifyAddedNewStore : kOfflineTableNotifyIdPrefix_AddedNewsStore;
    NSString *notifyID;
    
    
    if (self.currentUploadActionType == WSNormalActionType && [model isSynchronizeRequest]) {
        if ([prefix isEqualToString:kOfflineTableNotifyIdPrefix_ModifyAddedNewStore]) {
            //同步请求更新数据时，请求成功后才更新数据库。
            notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix_SyncModifyAddedNewStore,[WSJSONBuilder gen_uuid]];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNewStoreDatasFinish:) name:notifyID object:nil];
        }else if ([prefix isEqualToString:kOfflineTableNotifyIdPrefix_AddedNewsStore]) {
            notifyID = [NSString stringWithFormat:@"%@%@",prefix,[WSJSONBuilder gen_uuid]];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadNewStoreDatasFinish:) name:notifyID object:nil];
        }
    }
    else
    {
        notifyID = [NSString stringWithFormat:@"%@%@",prefix,[WSJSONBuilder gen_uuid]];
    }
    
    self.notifyId = notifyID;
    
    // 如果点击的是"开始拜访" || "删除门店"按钮，则注册返回当前页面的通知
    if (self.currentUploadActionType == WSVisitActionType && [model isSynchronizeRequest]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadBeginToVisitStoreDataFinish:) name:self.notifyId object:nil];
    } else if (self.currentUploadActionType == WSDeleteActionType && [model isSynchronizeRequest]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteNewAddStoreFinish:) name:self.notifyId object:nil];
    }
    if(!model.md5)
    {
        [self generateMd5];
    }
    
    NSString *md5String = model.md5;
    NSString *newAcvtMD5 = nil;
    
    //辉瑞ECALL新增：
    //isUseNewId：编辑新增的调查问卷时，是否在提交时生成一个新的ID（辉瑞ECALL首次使用，为了完成会议流程的流转，每次更新问卷的状态时，生成一条新的记录，但是所有记录submitId是一样的）
    //isUseNewId为Y，并且aID有值时（aID有值代表当前是编辑之前的问卷，而不是第一次新增一个问卷），生成新的ID
    
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
    
    BOOL hasPhoto = [self.photoBrowseView.imageIDArray count] > 0 ? YES:NO;
    
    NSArray *tableDatas = [self getTableDatasWithNewAcvtMD5:newAcvtMD5];
    
    
    WSFuncsBeanArray *funcsArray = [WSAppData getObjectbyKey:FUNCS];
    WSFuncsBean* fb = [funcsArray getFuncsBeanWithFC:model.currentFuncs.fc];
    BOOL isIgnoreNullValue = fb.nullvalue == 1 ? NO : YES;
    NSMutableDictionary *qstValuesDic =  (NSMutableDictionary *)[self.acvtview getAllPrepareSubmitDataByIsIgnoreNullValue:isIgnoreNullValue];
    
    if ([self.calendarKeyId length] > 0 && [self.currentCalendarValue length] > 0) {
        qstValuesDic[self.calendarKeyId] = self.currentCalendarValue;
    }
    
    NSMutableDictionary *saveQstValuesDic =  (NSMutableDictionary *)[self.acvtview getAllPrepareSaveDataByIsIgnoreNullValue:isIgnoreNullValue resultdict:qstValuesDic];

    if (![model isSynchronizeRequest]) {//如果是同步请求，都应该等请求成功后再更新数据库，且阻塞时不需要插入离线数据库
        
        if (![model saveAcvtDatasToDB:saveQstValuesDic useNewMd5:nil]) {
            return NO;
        }else{
            [self saveTBAcvtDatasToDB];
        }
    }
    
    if (isSubAcvtNewId) {
        //处理嵌套问卷的genid,也要重新生成
        [self processNestAcvtGenIdWhenNewId:[qstValuesDic mutableCopy]];
    }
    
    /*保存排班的数据到内存中 用于一次性上传*/
    [self  saveAcvtDatasToMemoryWhenHasCALWithDictionary:[saveQstValuesDic mutableCopy] acvtModel:model md5Str:md5String];
    
    if (self.acvtNameMainTitle) {
        if (!self.m_othersDic) {
            self.m_othersDic = [NSMutableDictionary dictionaryWithCapacity:1];
        }
        [self.m_othersDic setObject:self.acvtNameMainTitle forKey:@"acvtName"];
    }
    /*组织photonames数据（理文需求）*/
    
    //TODO othersDic待重构，包含了AN类型
    NSString *photoNames = [self generatePhotoNamesData];
    NSString* postData  = [WSJSONBuilder buildAcvtDatasbyFuncs:model.currentFuncs
                                                          acvt:model.currentAcvtBean
                                                       isPhoto:hasPhoto
                                                         Store:model.currentStore
                                                  qstValuesDic:qstValuesDic
                                                           md5:md5String
                                                      submitId:model.md5
                                                        Others:self.m_othersDic
                                                        addedAcvtForStore:nil
                                                    tableDatas:tableDatas
                                                    photoNames:photoNames
                                                    isNeedAdd:isNeedAdd
                                                         isAdd:isAdd];
    
    if ([model.extralData length] > 0) {
        NSMutableDictionary *dic = [postData mutableObjectFromJSONString];
        [dic setObject:model.extralData forKey:@"extralData"];
        postData = [dic JSONString];
    }
    
    //2017-09-23-yuanji-add
    if(model.confirm && [model.confirm length] > 0)
    {
        NSMutableDictionary *dic = [postData mutableObjectFromJSONString];
        [dic setObject:model.confirm forKey:@"confirm"];
        postData = [dic JSONString];
    }
//  SFA-25995 董宏 同步也需要入库
//    if (![model isSynchronizeRequest]) {//如果是同步请求，都应该等请求成功后再更新数据库，且阻塞时不需要插入离线数据库
    
        if (![self insertUploadData:postData URL:URL_UPLOAD MD5:md5String IsPhoto:hasPhoto NotifyName:notifyID]) {
            return NO;
        }
//    }
    
    if (self.operationAcvtType == WSUploadAcvtDateNormalType) {
        [[WSRequestHelper shareInstance] postRequestAcvtData:postData
                                                  notifyName:notifyID
                                                         md5:md5String
                                        isSynchronizeRequest:[model isSynchronizeRequest]];

    }else if(self.operationAcvtType == WSOnlySaveAcvtDataForCalendarType) {
        /*不进行上传*/
        if ([model saveAcvtDatasToDB:saveQstValuesDic useNewMd5:nil]) {
            [self saveTBAcvtDatasToDB];
            // 只是保存本地并未进行上传，应不需要刷新列表
//             [[NSNotificationCenter defaultCenter] postNotificationName:newStoreNotification object:nil];
        }else{
            return NO;
        }
        
        /*阻塞模式不插入离线数据库(调查问卷有排班的时候必须是阻塞模式)*/
        /*
        if (![self insertUploadData:postData URL:URL_UPLOAD MD5:md5String IsPhoto:hasPhoto NotifyName:notifyID]) {
            return NO;
        }
         */
        
         if (self.updateGenID && [self.updateGenID length] > 0) {
             [[NSNotificationCenter defaultCenter] postNotificationName:modifyStoreNotification object:nil];
         }
    }else if (self.operationAcvtType == WSUploadAcvtDataForCalendarType) {
        
        postData = [self resetPostDataWhenHasCAL:postData];
        
        [[WSRequestHelper shareInstance] postRequestAcvtData:postData
                                                  notifyName:notifyID
                                                         md5:md5String
                                        isSynchronizeRequest:[model isSynchronizeRequest]];
        NSLog(@"postData---%@",postData);
    }
    //上传删除的照片
    if (![self uploadNewAcvtDeletePhotos]) {
        return NO;
    }
    
    return YES;
}

#pragma mark -
// 点击删除按钮请求数据完成
- (void)deleteNewAddStoreFinish:(id)sender {
     [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:self.notifyId object:nil];
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSDictionary *infoDic = [info objectFromJSONString];
    NSString *result = [infoDic objectForKey:@"result"];
    NSDictionary *resultDic = [result objectFromJSONString];
    NSString *tip = nil;
    if (resultDic) {
        NSString *flag = [resultDic objectForKey:@"flag"];
        if (flag && [flag isKindOfClass:[NSNumber class]] && [flag intValue] == 1) {
            // 服务器删除成功提示
            tip = NSLocalizedString(@"deleted_success_label",nil);
            // 用Md5删除本地数据库中的此门店，
//            NSArray *setNames = [NSArray arrayWithObjects:@"UPLOAD_FLAG", nil];
//            NSArray *setNamesValues = [NSArray arrayWithObjects:[NSNumber numberWithInteger:WCDatasUploadStatusInvaild], nil];
//            NSArray *deleteNames = [NSArray arrayWithObjects:@"UPDATE_MD5ID", nil];
//            NSArray *deleteValue = [NSArray arrayWithObjects:[NSString stringNotNilWithValue:self.model.md5], nil];
//            [[WSAddStoreTable sharedTable] updateWithNames:setNames values:setNamesValues whereName:deleteNames whereValue:deleteValue];
            
            if ([(WSAcvtModel *)self.model isSynchronizeRequest]) {
                [self uploadPhotos];
            }
            
            WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
            [service deleteServerDataWithGenId:self.model.md5];
            [service deleteLocalDataWithGenId:self.model.md5];
            
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSString stringNotNilWithValue:self.model.md5 ]forKey:DelteStoreMD5_Key];
            [[NSNotificationCenter defaultCenter] postNotificationName:DeleteNewAddStoreSucceed object:self userInfo:userInfo];
            [self backToParent];
        } else {
            // 服务器删除失败提示
            tip = NSLocalizedString(@"deleted_failure_label",nil);
            
        }
    } else {
        tip = NSLocalizedString(@"server_reponse_error",nil);
    }
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tip tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
}


- (void)uploadNewStoreDatasFinish:(NSNotification *)notification {
    
    
    if (self.operationAcvtType == WSUploadAcvtDataForCalendarType) {
        /*上传后无论是否成功 都把，标记 及批量上传的数据jsonArray置为nil，点击上传时候重新组织  */
        self.jsonArray = nil;
    }
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:notification.name object:nil];
    
    NSError *error = [[notification userInfo] objectForKey:ERROR];
    if (error != 0)
    {
        NSString *errorStr = [error ws_localizedDescription];
        [self showAlert: errorStr];
        return;
    }
    
    NSString *storeId = @"-1";
    NSString *storeName = @"";
    NSString *responseString = [[notification userInfo] objectForKey:DATAS];
    NSDictionary *responseDictonary = [responseString objectFromJSONString];
    
    NSString *result = [NSString stringNotNilWithValue:[responseDictonary objectForKey:@"result"]];
    
    BOOL isSucess = NO;
    NSString *message = [NSString stringNotNilWithValue:[responseDictonary objectForKey:@"message"]];
    BOOL isCover = NO;
    if ([result isEqualToString:@"1"]) {
        isSucess = YES;
    }else if ([result isEqualToString:@"0"]) {
        isSucess = NO;
    }
    else if ([result isEqualToString:@"2"]){
        NSDictionary *resultDictioary = [result objectFromJSONString];
        NSString *flag = [NSString stringWithFormat:@"%@",[resultDictioary objectForKey:@"flag"]];
        if ([flag isEqualToString:@"1"]) {
            isSucess = YES;
        }
        else if ([flag isEqualToString:@"0"]) {//失败
            isSucess = NO;
        }
    }
    else {
        NSDictionary *resultDictioary = [result objectFromJSONString];
        NSString *flag = [NSString stringWithFormat:@"%@",[resultDictioary objectForKey:@"flag"]];
        message = [resultDictioary objectForKey:@"msg"];
        
        if ([flag isEqualToString:@"1"]) {
            isSucess = YES;
            
            NSString *addType = [resultDictioary objectForKey:@"addtype"];
            if ([addType isEqualToString:@"5"]) {
                
                WSBaseStoreDBService *service = [[WSBaseStoreDBService alloc] init];
                [service insertOrUpdateStoreWithDataDic:resultDictioary acvtGenId:self.model.md5 search_objId:@""];
            }
            
            isCover = [[resultDictioary objectForKey:@"isCover"] boolValue];
            
            // SFA-13033 此处如果不获得新增的门店id，则在脚本执行删除门店时无法删除
            storeId = [NSString stringNotNilWithValue:[resultDictioary objectForKey:@"storeId"]];
            storeName = [resultDictioary objectForKey:@"name"];

            

//            NSString *storeId = [resultDictioary objectForKey:@"storeId"];
//            NSString *storeCode =  [resultDictioary objectForKey:@"code"];
//            NSString *empID = [WSAppData getObjectbyKey: APPDATA_EMPID ];
//            NSString *bizDate =[WSAppData getObjectbyKey:APPDATA_BIZDATE];
//            
//            NSArray *whereNames = [[NSArray alloc]initWithObjects:@"EMP_ID",@"STORE_ID",@"BIZ_DATE", nil];
//            NSArray *wherValues = [[NSArray alloc]initWithObjects:empID,storeId,bizDate ,nil];
//            
//            [[WSAddStoreTable sharedTable]updateWithNames:@[@"store_code"] values:@[storeCode] whereName:whereNames whereValue:wherValues];
            
            //！！问卷数据库表重构，与Android保持一致逻辑，去除WSAddStoreTable表，统一使用visit_store_acvt_data，如需存储storeID等应该在base_store表中新增一条记录，用genid关联。
            
        }
        else if ([flag isEqualToString:@"0"]) {//失败
            NSArray *sameStoreArray = [resultDictioary objectForKey:@"sameStoreList"];
            if (sameStoreArray) {
                [self showSameStoreList:sameStoreArray];
                return;
            } else {
                isSucess = NO;
            }
        }
        //2017-09-23-yuanji-add
        else if ([flag isEqualToString:@"3"] || [flag isEqualToString:@"4"]) {
            
            NSString *title = NSLocalizedString(@"js_alert_title", nil);
            NSString *only = [resultDictioary objectForKey:@"cancleLable"];
            NSString *confirm = [resultDictioary objectForKey:@"confirmLable"];
            
            // MN-4914 IOS-提交完兑奖订单—在提交卸车申请弹出提示未显示“确定，取消”按钮
            if ([message containsString:@"@&@"]) {
                NSArray *tempArray = [message componentsSeparatedByString:@"@&@"];
                if (tempArray.count == 3) {
                    message = tempArray[0];
                    confirm = tempArray[1];
                    only = tempArray[2];
                }
            }
            
            __weak WSAddNewStoreViewController *wself = self;
            
            BlockAlertView *alert = [BlockAlertView alertWithTitle:title message:message];
            [alert addButtonWithTitle:(only.length > 0 ? only : @"") block:^{
                if ([flag isEqualToString:@"3"]) {
                    [wself result3Upload:@"0"];
                }
                else {
                    [wself result4Upload:@"0"];
                }
            }];
            [alert addButtonWithTitle:(confirm.length > 0 ? confirm : @"") block:^{
                if ([flag isEqualToString:@"3"]) {
                    [wself result3Upload:@"1"];
                }
                else {
                    [wself result4Upload:@"1"];
                }
            }];
            [alert show];
            return;
        }
    }
    
    if (!isSucess) { //失败
        [self.jsonArray removeAllObjects];
        [self showAlert: message];
    }
    else{
        if (!message || [message isKindOfClass:[NSNull class]] || [message length] == 0) {
            message = NSLocalizedString(@"upload_success", nil);
        }
        
        if ([(WSAcvtModel *)self.model isSynchronizeRequest]) {
            [self uploadPhotos];
        }
        
        if (self.operationAcvtType == WSUploadAcvtDateNormalType) {
            if (!isCover) {
                [self saveAcvtDatasToDB];
            }
        }
        
        
        WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
        if ([model isKindOfClass:[WSAcvtModel class]]) {
            WSAcvtModel *acvtModel = (WSAcvtModel *)model;
            acvtModel.currentStore.Id = [NSString stringNotNilWithValue:storeId];
            acvtModel.currentStore.name = [NSString stringNotNilWithValue:storeName];
        }

        
        // SFA-13033 失效门店不执行脚本block()删除本地数据库的方法
        if([self.acvtview checkLuaScriptBlock])
            [[NSNotificationCenter defaultCenter] postNotificationName:RelieveStoreRefreshNotification object:nil];
        
        if (self.operationAcvtType == WSUploadAcvtDataForCalendarType) {
            [self saveAcvtDatasToDBWhenHasCAL];
        }
         
        
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:message tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        [[NSNotificationCenter defaultCenter] postNotificationName:newStoreNotification object:nil];

        //        SFA-21663
        //        【泸州老窖-iOS】拜访->终端走访中新增门店后刷新再拜访改成新增门店即拜访-打假办
        if (([storeId length] > 0 && ![storeId isEqualToString:@"-1"]) && [storeName length] > 0 && [self.currentFuncs.opt.isIntentToStore isEqualToString:@"Y"]) {
            [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
            [self showIsVisitTipWithCurrentStore:model.currentStore];

        } else {
            [self popToParentOrHome];
        }
    }    
}

- (void)updateNewStoreDatasFinish:(NSNotification *)notification {
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:notification.name object:nil];
    
    NSError *error = [[notification userInfo] objectForKey:ERROR];
    if (error != 0)
    {
        NSString *errorStr = [error ws_localizedDescription];
        [self showAlert: errorStr];
        return;
    }
    
    NSString *responseString = [[notification userInfo] objectForKey:DATAS];
    NSDictionary *responseDictonary = [responseString objectFromJSONString];
    
    NSString *result = [responseDictonary objectForKey:@"result"];
    
    BOOL isSucess = NO;
    NSString *message = [responseDictonary objectForKey:@"message"];
    
    if ([result isEqualToString:@"1"]) {
        isSucess = YES;
    }else if ([result isEqualToString:@"0"]) {
        isSucess = NO;
    }else {
        NSDictionary *resultDictioary = [result objectFromJSONString];
        NSString *flag = [NSString stringWithFormat:@"%@",[resultDictioary objectForKey:@"flag"]];
        message = [resultDictioary objectForKey:@"msg"];
        
        if ([flag isEqualToString:@"1"]) {
            isSucess = YES;
            
            NSString *addType = [resultDictioary objectForKey:@"addtype"];
            if ([addType isEqualToString:@"5"]) {
                
                WSBaseStoreDBService *service = [[WSBaseStoreDBService alloc] init];
                [service insertOrUpdateStoreWithDataDic:resultDictioary acvtGenId:self.model.md5];
            }
        }
        else if ([flag isEqualToString:@"0"]) {//失败
            isSucess = NO;
            
        }
    }
    
    
    if (!isSucess) { //失败
        [self showAlert: message];
    }
    else {
        if (!message || [message isKindOfClass:[NSNull class]] || [message length] == 0) {
            message = NSLocalizedString(@"upload_success", nil);
        }
        
        if ([(WSAcvtModel *)self.model isSynchronizeRequest]) {
            [self uploadPhotos];
        }
        
        if (self.operationAcvtType == WSUploadAcvtDateNormalType) {
             [self saveAcvtDatasToDB];
        }else {
            if (self.operationAcvtType == WSUploadAcvtDataForCalendarType) {
                [self saveAcvtDatasToDBWhenHasCAL];
            }
        }
        if (self.updateGenID && [self.updateGenID length] > 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:modifyStoreNotification object:nil];
        }
        
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:message tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        [self popToParentOrHome];
    }
    
}


- (void)showAlert:(NSString *)message{
    NSString *UploadFailString = NSLocalizedString(@"fail_upload",nil);
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:UploadFailString tips:message tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
}


#pragma mark  acvt has CAL typ qst Method

- (void)saveAcvtDatasToMemoryWhenHasCALWithDictionary:(NSMutableDictionary *)qstValuesDic  acvtModel:(WSBaseModel*)model
                                      md5Str:(NSString *)md5String {
    
    if (self.operationAcvtType == WSOnlySaveAcvtDataForCalendarType ) {
        if ([self.calendarKeyId length] > 0 && [self.currentCalendarValue length] > 0) {
            qstValuesDic[self.calendarKeyId] = self.currentCalendarValue;
            qstValuesDic[@"id"] = model.md5;
            qstValuesDic[@"submitId"] = md5String;
        }
        
        if (self.jsonArray == nil) {
            self.jsonArray = [[NSMutableArray alloc] init];
        }
        [self.jsonArray addObject:qstValuesDic];
    }
}




- (void)saveAcvtDatasToDBWhenHasCAL {
    
    if ([self.selectedEmployeeId length] == 0) {
        LogError(@"self.selectedEmployeeId is nil");
    }

    for (int i = 0; i < [[self jsonArray] count]; i ++) {
        
        NSDictionary *qstDic = [[self jsonArray] objectAtIndex:i];
        
        NSString *dateStr = [qstDic objectForKey:self.calendarKeyId];
        NSString *generateNewMd5 = [self generateMd5WhenAcvtHasCalendar:dateStr];
        self.currentUsingNewMd5WhenAcvtHasCalendar = generateNewMd5;
        self.currentCalendarValue = dateStr;
        NSMutableDictionary *qstValuesDic =  (NSMutableDictionary *)[self.acvtview getAllPrepareSubmitData];
        if ([self.calendarKeyId length] > 0 && [dateStr length] > 0) {
            qstValuesDic[self.calendarKeyId] = dateStr;
        }
        [(WSAcvtModel *)self.model saveAcvtDatasToDB:qstValuesDic useNewMd5:generateNewMd5];
        [self saveTBAcvtDatasToDB];
        
    }
    
//    if ([self.calendarSelectedDates count] > 0  ) {
//        for (NSInteger i = 0; i < [self.calendarSelectedDates count]; i++) {
//            NSString *dateStr = self.calendarSelectedDates[i];
//            NSString *generateNewMd5 = [self generateMd5WhenAcvtHasCalendar:dateStr];
//            self.currentUsingNewMd5WhenAcvtHasCalendar = generateNewMd5;
//            self.currentCalendarValue = dateStr;
//            NSMutableDictionary *qstValuesDic =  (NSMutableDictionary *)[self.acvtview getAllPrepareSubmitData];
//            if ([self.calendarKeyId length] > 0 && [dateStr length] > 0) {
//                qstValuesDic[self.calendarKeyId] = dateStr;
//            }
//            [(WSAcvtModel *)self.model saveAcvtDatasToDB:qstValuesDic useNewMd5:generateNewMd5];
//            [self saveTBAcvtDatasToDB];
//        }
//    }
}

- (void)deleteAcvtDatasWhenHasCalUploadFailedOrGiveup {
    if ([self.calendarSelectedDates count] > 0  ) {
        for (NSInteger i = 0; i < [self.calendarSelectedDates count]; i++) {
            NSString *dateStr = self.calendarSelectedDates[i];
            NSString *generateNewMd5 = [self generateMd5WhenAcvtHasCalendar:dateStr];
            /*实现 delete方法*/
            [(WSAcvtModel *)self.model deleteAcvtDatasWithGenId:generateNewMd5];
        }
    }
}



- (NSString *)resetPostDataWhenHasCAL:(NSString *)postData {
    if ([self.jsonArray count] > 0) {
        NSMutableDictionary *dic = [postData mutableObjectFromJSONString];
        [dic setObject:self.jsonArray forKey:@"jsonArray"];
        return [dic JSONString];
    }
    return postData;
}


#pragma mark -

-(void)callBackWhenFinishTask:(WSInterAction *)interaction{
    
    [super callBackWhenFinishTask:interaction];
    
}


-(void)setRefresh_Btn{
    
    UIImage *image =[UIImage imageNamed:@"edit_button.png"];
    
    SEL  selector = @selector(btnRefresh);
    
    [self addTopRightBarButton:image AndSelector:selector andTarget:self];
    
}

-(void)setUpload_Btn{
    
    SEL selector = @selector(upload);
    
    [self addTopRightBarButton:[UIImage imageForName:@"icon_upload"] AndSelector:selector andTarget:self];
    
    
    
}


-(void)addTopRightBarButton:(UIImage *)image AndSelector:(SEL)selector andTarget:(id)target{
    
    
    self.uploadButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:target action:selector];
    
    [self setRightBarBtn:self.uploadButton];
    
}

-(void)addTopRightBarButtonWithName:(NSString *)name AndSelector:(SEL)selector andTarget:(id)target{
    
    
    self.uploadButton = [[UIBarButtonItem alloc] initWithTitle:name style:UIBarButtonItemStylePlain target:target action:selector];
    
    [self setRightBarBtn:self.uploadButton];
    
}

-(void)setRightBarBtn:(UIBarButtonItem *)barbtn{
    
    
    NSArray *baritemArray =[NSArray arrayWithObjects:barbtn, nil];
    
    if(self.m_ParentViewController != nil) {
        
        self.m_ParentViewController.navigationItem.rightBarButtonItems = baritemArray;
        
    }
    else{
        
        self.navigationItem.rightBarButtonItems = baritemArray;
        
    }
    
    
}


-(void)initAcvtService{
    
    if(acvt_service==nil){
        
        acvt_service =[[WSAcvtService  alloc] init];
        
    }
    
    acvt_service.service_call_back_delegate = self;
    
}
-(void)btnRefresh{
    
    
    NSString *message  = @"正在刷新数据，请稍候！";
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:message tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeWaiting];
    
    [self initAcvtService];
    
    NSString *empId= [WSAppData getObjectbyKey:APPDATA_EMPID];
    
    acvt_service.fv = self.currentFuncs.fv;
    
    acvt_service.fc = self.currentFuncs.fc;
    
    acvt_service.current_acvt_md5  = self.model.md5;
    
    acvt_service.current_emp_id = empId;
    
    [acvt_service requestAcvtDisplayByNode:@"acvtdis" genId:self.model.md5 empId:empId version:@""];  //需要重新处理
    
    
    
}


#pragma mark -
#pragma mark BaseServiceDelegate method


-(void)serviceExecuteSuccessed:(WSBaseService *)baseService andResultObject:(NSObject *)object{
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    NSString *message  = @"刷新数据成功！";
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:message tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeWaiting];
    
    [self performSelector:@selector(hiddenMBProgressHUD) withObject:self afterDelay:1.0];
    
    self.refresh_status = BTN_STAUS_UPLOAD;
    
    [self setUpload_Btn];
    
//    [self RefreshView];
//    
//    [self changeAcvtNestedBtnStatus:YES];

    
}


-(void)hiddenMBProgressHUD{
    
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
}

-(void)serviceExecuteFailed:(WSBaseService *)baseService andResultObject:(NSObject *)object andError:(NSError *)error{
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    NSString *message  = @"刷新失败，请您稍后再试！";
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:message tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
    
     [self performSelector:@selector(hiddenMBProgressHUD) withObject:self afterDelay:1.0];
    
}

- (void)gotoWorkFlowController:(WSBaseWorkFlowViewController *)workFlowVC{
    
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
    if (self.currentNewStore) {
        action.newstore_id = self.currentNewStore.Id;
    }
    action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
    workFlowVC.currentVisitAction = action;
    workFlowVC.moduleFC = workFlowVC.currentVisitAction.func_code;
    
    if ([self.currentStore.name isKindOfClass:[NSString class]] && ![self.currentStore.name isEqualToString:@""]) {
        workFlowVC.title = self.currentStore.name;
    }
    
    LogInfo(@"Going into class:%@", workFlowVC);
    if (self.m_ParentViewController) {
        NSArray *array = self.m_ParentViewController.navigationController.viewControllers;
        if (array.count > 1) {
            UIViewController *tmpVC = [array objectAtIndex:array.count-2];
            workFlowVC.backVC = tmpVC;
        }
        [self.m_ParentViewController.navigationController pushViewController:workFlowVC animated:YES];
    }else {
        NSArray *array = self.navigationController.viewControllers;
        if (array.count > 1) {
            UIViewController *tmpVC = [array objectAtIndex:array.count-2];
            workFlowVC.backVC = tmpVC;
        }
        [self.navigationController pushViewController:workFlowVC animated:YES];
    }

}

#pragma mark - 上传返回结果为3时再次上传方法 2017-09-23-yuanji-add
- (void)result3Upload:(NSString *)confirm
{
    if (confirm && confirm.length > 0) {
        
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow
                             withText:NSLocalizedString(@"uploading_prompt", nil)
                                 tips:NSLocalizedString(@"please_wait", nil)
                            tapTarget:self action:nil];
        ((WSAddNewStoreModel *)self.model).confirm = confirm;
        [self executeRealUpload];
    }
}

#pragma mark - 上传返回结果为4时再次上传方法
- (void)result4Upload:(NSString *)confirm
{
    if (confirm && [confirm isEqualToString:@"1"]) {
        
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow
                             withText:NSLocalizedString(@"uploading_prompt", nil)
                                 tips:NSLocalizedString(@"please_wait", nil)
                            tapTarget:self
                               action:nil];
        ((WSAddNewStoreModel *)self.model).confirm = confirm;
        [self executeRealUpload];
    }
}

@end

//
//  EnterStoreViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-7.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//


#import "WSEnterStoreViewController.h"
#import "WSFuncsBean.h"
#import "WSFuncsBean_opt.h"
#import "WSAppData.h"
#import "WSCurrentTime.h"
#import "WSRequestHelper.h"
#import "WSJSONBuilder.h"
//#import "ConfigFileController.h"
#import "WCOptionalSource.h"
#import "WSVisitStoreActionTable.h"
#import "WSFuncsBean_other.h"
#import "WSNavigationBar.h"
#import "WSPhotoTypeItem.h"
#import "WSPhotoTypeArrayItem.h"
#import "FUIDatePickerView.h"
#import "WSCustomEnterStoreTimeObject.h"
#import "FUICheckBox.h"
#import "WSBeaconManager.h"

#import "WSVisitStoreStatusTable.h"
#import "WSEnvrionment.h"

//#import "WSSmsController.h"

#define ENTERSTORE      @"EnterStore"

#define kBottomDataChangeTag        (5010)




@interface WSEnterStoreViewController ()
{
    BOOL    isRepairInifSign;       //补录数据标识
}

@property (nonatomic, strong) UIAlertView *datasChangeAlertView;
@property (nonatomic, strong) FUIDatePickerView *datePickerView;
@property (nonatomic, strong) FUIDatePickerView *timePickerView;

@property (nonatomic, strong) NSString *enterStoreTimeStamp;

@end

@implementation WSEnterStoreViewController
@synthesize md5;

@synthesize isPhotoRequire = _isPhotoRequire;
@synthesize isValueChange = _isValueChange;

NSString* formatString(id str) {
    if (!str || [str isKindOfClass:[NSNull class]]) {
        str = @"";
    }else if (![str isKindOfClass:[NSString class]]) {
        str = [NSString stringWithValue:str];
    }
    
    return str;
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
    if (!self.isGpsReady) {
        lonValues=@"null";
        latValues=@"null";
    }else {
        lonValues=[NSString stringWithFormat:@"%.12f",self.location.coordinate.longitude];
        latValues=[NSString stringWithFormat:@"%.12f",self.location.coordinate.latitude];
    }
  
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
    
    NSMutableArray *imageIds =[NSMutableArray array];
    
    
    for (NSString *imagID in self.photoBrowseView.imageIDArray) {
        NSString *filePath = [[SDImageCache sharedImageCache] imagePathFromKey:imagID];
        if (filePath) {
            [imageIds addObject:imagID];
        }
    }
    for (WSPhotoTypeArrayItem *arrayItem in self.photoTypeArray) {
        for (WSPhotoTypeItem *item in arrayItem.photoTypeItemArray) {
            for (NSString *imageID in item.photoIDArray){
                NSString *filePath = [[SDImageCache sharedImageCache] imagePathFromKey:imageID];
                if (filePath) {
                    [imageIds addObject:imageID];
                }
            }
        }
    }
    NSString *imageIDStr = [imageIds componentsJoinedByString:@","];

    NSArray *values=[NSArray arrayWithObjects:self.currentStore.Id,
                     [WSAppData getObjectbyKey:APPDATA_EMPID],
                     [isPlan stringValue],
                     [WSAppData getObjectbyKey:APPDATA_BIZDATE],
                     l_serverTime,@"null",
                     [self md5],
                     @"null",
                     l_serverTime,
                     @"0",
                     lonValues,
                     latValues,
                     lonValues,
                     latValues,
                     @"null",@"null",srid,
                     formatString(self.currentFuncs.fc),
                     formatString(self.currentStore.name),
                     @"null",@"null",@"null",@"null",@"null",@"null",@"null",@"null",@"null",
                     self.md5,
                     storeList_parentFC,imageIDStr,nil];
    
    /*
    NSString *enterTime=[[WSInoutStoreTable sharedTable] getEnterStoreTime:self.currentStore andOtherParam:self.md5 andParamType:EParameterType_VisitId];
    
    
    if (enterTime!=nil)
    {
        NSArray *wNames = @[@"store_id",@"visit_id"];
        NSArray *wValues = @[[NSString stringNotNilWithValue:self.currentStore.Id],[NSString stringNotNilWithValue:self.md5]];
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

}

//
//-(void)uploadSuccessToInsertKeysAndValues
//{
////    NSArray *keys=[NSArray arrayWithObjects:@"store_id",@"emp_id",@"is_planed",@"biz_date",@"intime",@"outtime",@"img_idx",@"memo",@"upload_date",@"upload_flag",@"in_lon",@"in_lat",@"out_lon",@"out_lat",@"in_callid",@"out_callid",@"sr_id",@"func_code",@"memo1",@"memo2",@"memo3",@"memo4",@"memo5",@"memo6",@"memo7",@"memo8",@"memo9",@"memo10", nil];
//    
//    NSString *is_planed = nil;
//    if (self.currentStore.plan==YES) {
//        is_planed=@"1";
//    }else if(self.currentStore.plan ){
//        is_planed=@"0";
//    }
//    
////    double lonValues = 0.0,latValues = 0.0;
////    if (self.location.longitude) {
////        lonValues=self.location.longitude;
////    }else if(self.location.latitude){
////        latValues=self.location.latitude;
////    }
//
//    NSString *lonValues = nil;
//    NSString  *latValues = nil;
//    if (!self.isGpsReady) {
//        lonValues=@"null";
//        latValues=@"null";
//    }else {
//        lonValues=[NSString stringWithFormat:@"%.12f",self.location.coordinate.longitude];
//        latValues=[NSString stringWithFormat:@"%.12f",self.location.coordinate.latitude];
//    }
//    
//    
//    
//    NSArray *values=[NSArray arrayWithObjects:formatString(self.currentStore.Id),[WSAppData getObjectbyKey:APPDATA_EMPID],is_planed,[WSAppData getObjectbyKey:APPDATA_BIZDATE],[WSCurrentTime getTimeMillisString],[WSCurrentTime getTimeMillisString],[self md5],@"null",[WSCurrentTime getTimeMillisString],@"1",lonValues,latValues,lonValues,latValues,@"null",@"null",@"null",formatString(self.currentFuncs.fc),formatString(self.currentStore.name),@"null",@"null",@"null",@"null",@"null",@"null",@"null",@"null",@"null",nil];
//    
//    if (![[WSInoutStoreTable sharedTable] isEnterStore:self.currentStore andOtherParam:self.md5 andParamType:EParameterType_VisitId]){
//        [[WSInoutStoreTable sharedTable] insertWithArgumentsValue:values];
//        
//    }else{
//        [[WSInoutStoreTable sharedTable] cleanOldData];
//        [[WSInoutStoreTable sharedTable] insertWithArgumentsValue:values];
//    }
//    
//}

- (void)showAlert:(NSString *)message{
    NSString *UploadFailString = NSLocalizedString(@"fail_upload",nil);
    NSString *OkString = NSLocalizedString(@"confirm",nil);
    NSString *TryString = NSLocalizedString(@"retry", nil);
    
    BlockAlertView *alert = [BlockAlertView alertWithTitle:UploadFailString message:message];
    [alert setCancelButtonWithTitle:OkString block:nil];
    [alert addButtonWithTitle:TryString block:^{
        
    }];
    [alert show];
}

-(BOOL)uploadDatas
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(back:) name:@"back" object:nil];
     NSMutableDictionary *dicOtherInfo = [[NSMutableDictionary alloc] initWithCapacity:8];
    // gps信息
    if  (self.isGpsReady ) {
        dicOtherInfo = [[WSLocationManager getLocationUploadDataWithLocation:self.location andAddress:self.locationDescribe.detailAddress] mutableCopy];
    }
    //SFA-2629 SFA 立白，IOS端，门店地图，没有显示拜访轨迹 当门店的位置为空时，门店位置采用采集点位置
    if (self.currentStore.longitude == 0 && self.currentStore.latitude == 0) {
        [self.currentStore modifyStoreInfo:dicOtherInfo];
    }
    
    [self.selectedDataDic keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        [dicOtherInfo setObject:obj forKey:key];
        return YES;
    }];
    
    
    
    // "opt MEMO"
    if (self.memoData && self.memoData.length > 0) {
        [dicOtherInfo setObject:self.memoData forKey:@"memo"];
    }
    
    for (int i = 0; i < [self.currentFuncs.otherArray count]; i++) {
        WSFuncsBean_other *other = [self.currentFuncs.otherArray objectAtIndex:i];
        if (([other.tpy isEqualToString:OTHER_TPY_N] || [other.tpy isEqualToString:OTHER_TPY_T]) &&
            [other.col hasPrefix:@"memo"]) {
            UIView *infoView = [self.view viewWithTag:(OTHER_TEXTFIELD_TAG + i)];
            if ([infoView isKindOfClass:[UITextField class]]) {
                UITextField *field = (UITextField *)infoView;
                NSString *value = (field.text == nil) ?  @"" : field.text;
                
                [dicOtherInfo setValue:value forKey:other.col];
            }else if ([infoView isKindOfClass:[UITextView class]]) {
                UITextView *textView = (UITextView *)infoView;
                NSString *value = (textView.text == nil) ?  @"" : textView.text;;
                if (dicOtherInfo == nil) {
                    dicOtherInfo = [[NSMutableDictionary alloc] init];
                }
                [dicOtherInfo setValue:value forKey:other.col];
            }
        }
        else if ([other.tpy isEqualToString:OTHER_TPY_C] && [other.col hasPrefix:@"memo"])
        {
            //c是多选，写的有问题
            UIView *infoView = [self.view viewWithTag:(OTHER_SWITCH_TAG+i)];
            if ([infoView isKindOfClass:[UISwitch class]]) {
                UISwitch *swichView = (UISwitch *)infoView;
                NSString *flag = swichView.isOn ? @"1" : @"0";
                [dicOtherInfo setValue:flag forKey:other.col];
            }
        }
    }
    
    // Switch on or off
    for (int i = 0; i < [self.currentFuncs.otherArray count]; i++) {
        WSFuncsBean_other *other = [self.currentFuncs.otherArray objectAtIndex:i];
        if ([other.tpy isEqualToString:OTHER_TPY_C]) {
            //c是多选，写的有问题

            UISwitch *infoView = (UISwitch *)[self.view viewWithTag:(OTHER_SWITCH_TAG+i)];
            if ([infoView isKindOfClass:[UISwitch class]]) {
                int flag = infoView.isOn ? 1 : 0;
                [dicOtherInfo setValue:[NSNumber numberWithInteger:flag] forKey:other.col];
            }
        } else if ([other.tpy isEqualToString:OTHER_TPY_R]) {

            for (NSInteger i=0; i<[self.radioViewArray count]; i++) {
                NSMutableDictionary *tmpOptDic= [self.radioViewArray objectAtIndex:i];
                NSMutableArray *tmpOptArray = [tmpOptDic objectForKey:other.col];
                for (NSInteger j= 0; j < [tmpOptArray count]; j++) {
                    WSRadioButton *radioButton = [tmpOptArray objectAtIndex:j];
                    if (radioButton.selected) {
                        [dicOtherInfo setValue:[NSNumber numberWithInteger:radioButton.tag] forKey:other.col];
                    }
                }
                
                
            }
        } else if ([other.tpy isEqualToString:OTHER_TPY_CS]) {
            UIButton *infoView = (UIButton *)[self.view viewWithTag:(OTHER_BUTTON_TAG+i)];
            [dicOtherInfo setValue:[NSNumber numberWithInteger:infoView.selected] forKey:other.col];
        }
    }
    
    BOOL hasPhoto = NO;
    if ([self.photoBrowseView.imageIDArray count] > 0)
    {
        hasPhoto = YES;
    }
    
    for (WSPhotoTypeArrayItem *arrayItem in self.photoTypeArray)
    {
        for (WSPhotoTypeItem *item in arrayItem.photoTypeItemArray) {
            if ([item.photoIDArray count] > 0) {
                hasPhoto = YES;
                break;
            }
        }
    }
    

    NSString* storeList_parentFC = nil;
    if (self.moduleFC) {
        storeList_parentFC = self.moduleFC;
    }
    //补填数据处理
    if (isRepairInifSign) {
        [[WSCustomTimeTable sharedTable] insertEnterCustomTimeWithStoreId:self.currentStore.Id
                                                                     withFC:storeList_parentFC
                                                             withCustomDate:[self.selectedDataDic objectForKey:kRepairEnterStoreDateKey]
                                                             withCustomTime:[self.selectedDataDic objectForKey:kRepairEnterStoreTimeKey]
                                                              withVisitId:self.md5];
    }else {
       // [[WSCustomTimeTable sharedTable] insertEnterNormalTimeWithStoreId:self.currentStore.Id withFC:storeList_parentFC withVisitId:self.md5];
        [dicOtherInfo removeObjectForKey:kRepairEnterStoreDateKey];
        [dicOtherInfo removeObjectForKey:kRepairEnterStoreTimeKey];
    }
    
    NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];

    NSString *postData = [WSJSONBuilder buildEnterLeaveStorebyFuncs:self.currentFuncs
                                                            isPhoto:hasPhoto
                                                              Store:self.currentStore
                                                           jsonData:dicOtherInfo
                                                                md5:self.md5
                                                   isUsingDataEntry:YES
                                                     enterLeaveTime:self.enterStoreTimeStamp];
    
    //离线上传 modify by wangdongyan 04-17 for 多张图片上传问题
    BOOL insertSuccess = [self insertUploadData:postData URL:URL_UPLOAD MD5:self.md5 IsPhoto:NO NotifyName:notifyID];
    if (!insertSuccess) {
        return NO;
    }

    [self updateStoreVisitStaus:VisitStoreWorking];

    [self uploadFaieldToInsertKeysAndValues];
 
    
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    [uploadMgr postRequestOnEnterLeaveStorebyData:postData
                                            md5:self.md5
                                     notifyName:notifyID];
    return YES;
}

-(BOOL)uploadPhotos
{
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    for (NSString *imageID in self.photoBrowseView.imageIDArray) {
        NSString *filePath = [[SDImageCache sharedImageCache] imagePathFromKey:imageID];
        if (filePath) {
            NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
            NSDictionary *params = [WSJSONBuilder buildImageParamsDicByImageID:imageID];
            NSString *imageIndex = [NSString stringWithFormat:@"%@_%@_%@", self.currentFuncs.fc, self.currentFuncs.fv, self.md5];
            
            LogInfo(@"enter store upload photos data 1:%@", params);

            NSString *photoFileName = [[SDImageCache sharedImageCache] cacheFileNameForKey:imageID];
            BOOL insertPhotoSucceed = [self insertUploadMedia:[params JSONString] Type:kOfflineTableDataType_P URL:URL_IMAGEUPLOAD MD5:imageIndex IsPhoto:YES NotifyName:notifyID photoFileName:photoFileName];
            if (!insertPhotoSucceed) {
                return insertPhotoSucceed;
            }
            [uploadMgr uploadImageWithFilePath:filePath
                                        params:params
                                           url:URL_IMAGEUPLOAD
                                    notifyName:notifyID
                                           md5:imageIndex];
        }
        else
        {
            LogError(@"照片数据不存在，imageID:%@",imageID);
        }
    }
    
    if (!([self.photoBrowseView.imageIDArray count] > 0)) {
        LogError(@"photoBrowseView中无照片");
    }
    
    for (WSPhotoTypeArrayItem *arrayItem in self.photoTypeArray)
    {
        
        for (WSPhotoTypeItem *item in arrayItem.photoTypeItemArray) {
            
            for (NSString *imageID in item.photoIDArray)
            {
                if (imageID) {
                    
                    NSString *filePath = [[SDImageCache sharedImageCache] imagePathFromKey:imageID];
                    if (filePath) {
                        NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
                        
                        NSDictionary *params = [WSJSONBuilder buildImageParamsDicByImageID:imageID andPhotoTypeId:item.typeID];
                        NSString *photoFileName = [[SDImageCache sharedImageCache] cacheFileNameForKey:imageID];
                        BOOL insertPhotoSucceed = [self insertUploadMedia:[params JSONString] Type:kOfflineTableDataType_P URL:URL_IMAGEUPLOAD MD5:self.md5 IsPhoto:YES NotifyName:notifyID photoFileName:photoFileName];
                        if (!insertPhotoSucceed) {
                            return insertPhotoSucceed;
                        }
                        
                        LogInfo(@"enter store upload photos data 2:%@", params);
                        
                        [uploadMgr uploadImageWithFilePath:filePath
                                                    params:params
                                                       url:URL_IMAGEUPLOAD
                                                notifyName:notifyID
                                                       md5:self.md5];
                    }
                    else {
                        LogError(@"照片数据不存在，imageID:%@",imageID);
                    }
                }
            }
        }
    }
    return YES;
}

- (BOOL)isNeedPhotoNecssary {
    if ([self.currentFuncs.opt.isPic isEqualToString:QST_TYPE_R])
    {
        if (![self.currentFuncs.opt.isGps isEqualToString:REQUIRED_V]) {
            return YES;
        }
        else
        {
            if (!self.isGpsReady) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)upload
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    if (!self.photoBrowseView.imageIDArray
        && ![self checkTheCurrentDistanceIsValidFromStore]) {
        [self showCurrentLocationIsError];
        return;
    }
    
    if (self.photoBrowseView.imageIDArray && [self.photoBrowseView.imageIDArray count] ==0 &&  ![self checkTheCurrentDistanceIsValidFromStore]) {
        [MBProgressHUD showHUDAddedTo:self.view withText:NSLocalizedString(@"请拍照片,谢谢", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    if (![self checkMustUploadGPS]) {
        return;
    }
    
    if ([self.currentFuncs.required isEqualToString:@"R"])
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *storeString=[[NSString alloc]initWithFormat:@"%@.plist",self.currentStore.name];
        
        NSString *WorkListFile=[documentsDirectory stringByAppendingPathComponent:storeString];
        
        NSMutableDictionary *WorkListDic=[[NSMutableDictionary alloc]initWithContentsOfFile:WorkListFile];
        for (int i=0; i<[[WorkListDic allKeys] count]; i++) 
        {
            if ([self.currentFuncs.name isEqualToString:[[WorkListDic allKeys]objectAtIndex:i]]) 
            {
                if (![[WorkListDic objectForKey:[[WorkListDic allKeys]objectAtIndex:i]] isEqualToString:@"1"]) 
                {
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    
                    NSString *storeString=[[NSString alloc]initWithFormat:@"%@.plist",self.currentStore.name];
                    
                    NSString *WorkListFile=[documentsDirectory stringByAppendingPathComponent:storeString];
                    
                    [WorkListDic setValue:@"1" forKey:[[WorkListDic allKeys]objectAtIndex:i ]];
                    
                    [WorkListDic writeToFile:WorkListFile atomically:YES];
                    break;
                }
            }
        }
    }
        
    [[WCOptionalSource sharedInstance] setViewControllerParam:self byKey:self.currentFuncs.fv];
    BOOL hasPhoto = false;
    if ([self.photoBrowseView.imageIDArray count] > 0 || ([self.currentFuncs.opt.isPic isKindOfClass:[NSString class]] && [self.currentFuncs.opt.isPic isEqualToString:@"N"])) {
        hasPhoto = YES;
    }
    
    if (!hasPhoto)
    {
        NSString *TakePhotoString = nil;
        if ([self isNeedPhotoNecssary] && [self.photoBrowseView.imageIDArray count] < 1) {
            TakePhotoString = NSLocalizedString(@"pls_take_photo",nil);
        }

        if (TakePhotoString != nil && self.photoTypeArray.count == 0) {
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:TakePhotoString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return;
           
        }
    }
    
    NSMutableString *typeNotPic = [[NSMutableString alloc] init];
    
    for (WSPhotoTypeArrayItem *arrayItem in self.photoTypeArray) {
        
        for (WSPhotoTypeItem *item in arrayItem.photoTypeItemArray) {
            NSString *isRequire = [self.isPhotoRequire objectForKey:item.typeName];
            BOOL shouldPhoto = YES;
            if (isRequire && [isRequire isEqualToString:@"0"])
            {
                shouldPhoto = NO;
            }
            if ([item.photoIDArray count] == 0 && shouldPhoto)
            {
                [typeNotPic appendFormat:@"%@\n",item.typeName];
            }
        }
        
    }
    
    
    
    if (![typeNotPic isEqualToString:@""])
    {
        NSString *title = NSLocalizedString(@"no_photo_items", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:typeNotPic tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    //开始摆放上传照片的加载等待.
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"uploading_prompt", nil)  tips:NSLocalizedString(@"please_wait", nil) tapTarget:self action:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self doUpLoad];
    });
}

- (void)doUpLoad {
    
    if (![super uploadVisitAction]) {
        [self showDBErrorTipAndHidAllHud];
        return;
    }
    
    if (![self uploadDatas]) {
        // 数据库插入失败提示
        [self showDBErrorTipAndHidAllHud];
        return;
    }
    if (![self uploadPhotos]) {
        // 照片插入数据库失败提示
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
                // MMSH-6852
                // 【IOS】离店后再次进店，离店打勾的标志没有清除
                BOOL isContainsStoreStyp = NO;
                NSArray *beanStypArray = [bean.styp componentsSeparatedByString:@","];
                NSArray *storeStypArray = [self.currentStore.styp componentsSeparatedByString:@","];
                for (NSString *storeStyp in storeStypArray) {
                    if ([beanStypArray containsObject:storeStyp]) {
                        isContainsStoreStyp = YES;
                        break;
                    }
                }
                if (isContainsStoreStyp || (!bean.styp || !(bean.styp.length > 0))) {
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
                //action.title = leavestore.name;
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
            
        }
        
    }
    if (self.currentStore.beaconUUId) {
        [[WSBeaconManager getInstance] startBeaconWithUUID:self.currentStore.beaconUUId withStoreId:self.currentStore.Id];
    }
    
   [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    NSString *tip = NSLocalizedString(@"add_upload_queue", nil);
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tip tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
    
    
    [self backToParent];

}

- (void) amendSwitchAction:(id)sender
{
    if ([sender isKindOfClass:[UISwitch class]]) {
        UISwitch *uSwitch = sender;
        isRepairInifSign = uSwitch.on;
        
        if (isRepairInifSign) {
            [self resetMd5WithCustomDataStr:[self.selectedDataDic objectForKey:kRepairEnterStoreDateKey]];
        }else {
            [self resetMd5WithCustomDataStr:nil];
        }
        
        UIView *bottomView = [self.view viewWithTag:kBottomDataChangeTag];
        LogInfo(@"amendSwitchAction bottomView subviews count =  %lu", (unsigned long)bottomView.subviews.count);
        for (UIView *tmpView in bottomView.subviews) {
            LogInfo(@"bottomView class is %@", NSStringFromClass([tmpView class]));
            if ([tmpView isKindOfClass:[UILabel class]]) {
                [(UILabel*)tmpView setTextColor: isRepairInifSign ? MAIN_TEXT_COLOR : MAIN_TEXT_DISABLE_COLOR];
            }else if ([tmpView isKindOfClass:[FUIDatePickerView class]]) {
                if (isRepairInifSign) {
                    LogInfo(@"FUIDatePickerView enable");
                } else {
                    LogInfo(@"FUIDatePickerView disable");
                }
                [(FUIDatePickerView*)tmpView changeInteractionEnabled: isRepairInifSign];
            }else if ([tmpView isKindOfClass:[UIImageView class]]) {
                [tmpView setHidden: isRepairInifSign];
            }
        }
        
        if (self.photoBrowseView) {
            [self.photoBrowseView setIsSupperLocalPhoto: isRepairInifSign];
            if (self.photoBrowseView.imageIDArray) {
                [self.photoBrowseView deleteAllImage];
            }
        }
    }
}

- (void) userChangeDateView
{
    NSArray *array = [WSAppData getObjectbyKey:BASE_DATA_ENTRY];
    NSString *empIdStr = [WSAppData getObjectbyKey:APPDATA_EMPID];
    for (WSCustomEnterStoreTimeObject *obj in array) {
        if ([obj.empIdStr isEqualToString: empIdStr]) {
    
            self.y_point += 10;
            UIView *changeDateView = [[UIView alloc] initWithFrame:CGRectMake(0, self.y_point, self.view.bounds.size.height, 88)];
            [changeDateView setBackgroundColor:[UIColor whiteColor]];
            self.y_point += 88;
            [self.contentScrollView addSubview:changeDateView];
            
            
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.height, 1)];
            [lineView setBackgroundColor:[UIColor colorWithHexString:@"#C8C8C8"]];
            [changeDateView addSubview:lineView];
            
            //修改进店时间行
            UILabel *amendLabel = [[UILabel alloc] initWithFrame:CGRectMake(k_LabelXOffset, 1, 100, 42)];
            [amendLabel setFont:[UIFont systemFontOfSize:UI_Font]];
            [amendLabel setBackgroundColor:[UIColor clearColor]];
            amendLabel.text = NSLocalizedString(@"modify_enter_store_time", nil);
            amendLabel.lineBreakMode = NSLineBreakByWordWrapping;
            amendLabel.numberOfLines = 0;
            [changeDateView addSubview:amendLabel];
            
            UISwitch *amendSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 2 * k_LabelXOffset - 55, 6, 51, 31)];
            [amendSwitch addTarget:self action:@selector(amendSwitchAction:) forControlEvents:UIControlEventValueChanged];
            [changeDateView addSubview:amendSwitch];
            
            
            //分割线
            UIView *lineCopyView = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:lineView]];
            [lineCopyView setFrame:CGRectMake(k_LabelXOffset, 44, self.view.bounds.size.height, 1)];
            [changeDateView addSubview:lineCopyView];
            
            //创建底部时间选择控件
            UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 45, self.view.bounds.size.height, 44)];
            [bottomView setBackgroundColor:[UIColor clearColor]];
            bottomView.tag = kBottomDataChangeTag;
            [changeDateView addSubview:bottomView];
            
            //进店时间选择器
            UILabel *enterTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(k_LabelXOffset, 0, 100, 42)];
            [enterTitleLabel setBackgroundColor:[UIColor whiteColor]];
            [enterTitleLabel setFont:[UIFont systemFontOfSize:UI_Font]];
            [enterTitleLabel setTextColor:[UIColor colorWithHexString:@"#888888"]];
            enterTitleLabel.text = NSLocalizedString(@"txt_enter_store_time", nil);
            enterTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            enterTitleLabel.numberOfLines = 0;
            [bottomView addSubview:enterTitleLabel];
            
            UIImageView *lockImgView = [[UIImageView alloc] initWithFrame:CGRectMake(105, 15, 8, 11)];
            [lockImgView setImage:[UIImage imageForName:@"lock.png"]];
            [bottomView addSubview:lockImgView];
            
            NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
            NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            formatter.dateFormat = @"yyyy-MM-dd";
            NSDate *todayDate = [WSCurrentTime getCurrentServerDate];
            NSString *timestamp = [formatter stringFromDate:todayDate];
            CGFloat height = 40;
            
            [self.selectedDataDic setObject:timestamp forKey:kRepairEnterStoreDateKey];
            self.datePickerView = [[FUIDatePickerView alloc] initWithFrame:CGRectMake(120, 2, 110, height)
                                                            withPickerMode:UIDatePickerModeDate
                                                              withTitleStr:nil
                                                         withDateNormalStr:timestamp
                                                             withAcvtQstId:nil
                                                                 withBlock:^(NSString *acvtQstId, NSString *dateStr) {
                                                                     self.isValueChange = YES;
                                                                     [self.selectedDataDic setObject:dateStr forKey:kRepairEnterStoreDateKey];
                                                                     [self resetMd5WithCustomDataStr:dateStr];
                                                                     
                                                                     NSLog(@"ccccccccc:%@", dateStr);
                                                                 }];
            [self.datePickerView changeInteractionEnabled:NO];
            
            if (obj.timeLimitStr) {
                NSTimeInterval timeInterval = [todayDate timeIntervalSince1970];
                timeInterval += [obj.timeLimitStr intValue] * 60 * 60 * 24;
                if ([obj.timeLimitStr intValue] == 0) {
                    [self.datePickerView.customDatePicker setMaximumDate:todayDate];
                    [self.datePickerView.customDatePicker setMinimumDate:todayDate];
                }
                else if ([obj.timeLimitStr intValue] < 0) {
                    [self.datePickerView.customDatePicker setMaximumDate:todayDate];
                    [self.datePickerView.customDatePicker setMinimumDate:[NSDate dateWithTimeIntervalSince1970: timeInterval]];
                }else {
                    [self.datePickerView.customDatePicker setMinimumDate:todayDate];
                    [self.datePickerView.customDatePicker setMaximumDate:[NSDate dateWithTimeIntervalSince1970: timeInterval]];
                }
            }
            [bottomView addSubview:self.datePickerView];
            formatter.dateFormat = @"HH:mm";
            timestamp = [NSString stringWithFormat:@"%@:00", [formatter stringFromDate:[NSDate date]]];
            [self.selectedDataDic setObject:timestamp forKey:kRepairEnterStoreTimeKey];
            self.timePickerView = [[FUIDatePickerView alloc] initWithFrame:CGRectMake(230, 2, 80, height)
                                                            withPickerMode:UIDatePickerModeTime
                                                              withTitleStr:nil
                                                         withDateNormalStr:timestamp
                                                             withAcvtQstId:nil
                                                                 withBlock:^(NSString *acvtQstId, NSString *dateStr) {
                                                                     self.isValueChange = YES;
                                                                     [self.selectedDataDic setObject:dateStr forKey:kRepairEnterStoreTimeKey];
                                                                     
//                                                                     NSUserDefaults *userDefaults= [NSUserDefaults standardUserDefaults];
//                                                                     NSMutableDictionary *dic = [userDefaults objectForKey:kRepairDataKey];
//                                                                     if (!dic) {
//                                                                         dic = [NSMutableDictionary dictionary];
//                                                                     }
//                                                                     [dic setObject:dateStr forKey:kRepairEnterStoreTimeKey];
//                                                                     [userDefaults synchronize];
                                                                 }];
            [self.timePickerView changeInteractionEnabled:NO];
            [bottomView addSubview:self.timePickerView];
            
            //分割线
            lineCopyView = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:lineView]];
            [lineCopyView setFrame:CGRectMake(0, 87, self.view.bounds.size.height, 1)];
            [changeDateView addSubview:lineCopyView];
            
            break;
        }
    }
}

- (BOOL) isSupperChangedLocalPhoto
{
    return NO;
}


-(NSDictionary*)md5Param
{
   
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    
    if ([self.realParentFuncsCode length] > 0) {
        [dic setValue:self.realParentFuncsCode  forKey:@"memo"];
    }else if ([self.currentVisitAction.module_fc length] > 0) {
        [dic setValue:self.currentVisitAction.module_fc  forKey:@"memo"];
    }
    
    return dic;

}




- (void)loadView
{
    LogTrace();
    [super loadView];
    
    if (INTERFACE_IS_PHONE) {
        [self loadStoreNameLabel];
    }
    
    [self addFuncsOtherBeanView];
    [self addOptView];
    
//    if ([self isNeedPhotoNecssary]) {
//        [self.photoBrowseView setIsPhotoNecessary:YES];
//    }

    [self userChangeDateView];
    // 加载结束后 重置contenWidth
    CGFloat contentWidth = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? self.view.bounds.size.width : (self.view.bounds.size.width - 160));
    self.contentScrollView.contentSize = CGSizeMake(contentWidth, self.y_point);

}

-(void)viewWillAppear:(BOOL)animated
{
    LogTrace();
    [super viewWillAppear:animated];
    [super addToolBar];
}

-(void)initializationBackItemAction
{
    if (self.currentFuncs && self.currentFuncs.isHomePageWillShow) {
        NSDictionary *mobileHomeDic = [WSAppData getObjectbyKey:MOBILEHOMEPAGE];
        if (mobileHomeDic) {
            NSString *readTimeStr = [mobileHomeDic objectForKey:MobileHomePageReadingTimeKey];
            [self backItemAction:@selector(backAction) target:self withDelay:[readTimeStr intValue]];
            self.currentFuncs.isHomePageWillShow = NO;
        }
    }else {
        [self backItemAction:@selector(backAction) target:self];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.enterStoreTimeStamp = [WSCurrentTime getServerTime];
}



#pragma mark alertviewdelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == _datasChangeAlertView)
    {
        switch (buttonIndex)
        {
            case 0:
                [self.navigationController popViewControllerAnimated:YES];
                [self clearMapData];
                break;
            case 1:
//                [self.navigationController popViewControllerAnimated:YES];
                [self upload];
                break;
            default:
                break;
        }
        
    }
    else if (alertView.tag == WSDistanceInvliadAlertTag){
        switch (buttonIndex) {
            case 0:
            {
            }
                break;
            case 1:
            {
                [self addPhotoButtonWhenDistanceIsInvalid];
            }
                break;
                
            default:
                break;
        }
        
    }
    else if(alertView.tag != ALERT_CAMERA_TAG)
    {
        switch (buttonIndex)
        {
            case 0:
                break;
            case 1:
                [self upload];
                break;
            default:
                break;
        }
    }
    
}



 

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    

    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldCustomInteractivePopGestureRecognizerDelegate
{
    return YES;
}

- (BOOL)shouldPauseBackAction
{
    if (self.isValueChange || [self.photoBrowseView.imageIDArray count]>0) {
        return YES;
    }
    
    return NO;
}

- (void)backAction {
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    if (self.isValueChange || [self.photoBrowseView.imageIDArray count]>0) {
        
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"back_confirm2", nil)];
        
        [alert setCancelButtonWithTitle:NSLocalizedString(@"give_up", nil) block:^{
            [self.navigationController popViewControllerAnimated:YES];
            [self clearMapData];
        }];
        [alert addButtonWithTitle:NSLocalizedString(@"upload_label", nil) block:^{
            [self upload];
        }];
        [alert show];
        
    } else {
        [self.navigationController popViewControllerAnimated:YES];
        [self clearMapData];
    }
}

- (BOOL)isValueChange
{
    if ([super respondsToSelector:@selector(isValueChange)]) {
        BOOL superValueChange = [super isValueChange];
        if (superValueChange) return YES;
    }
    
    if (_isValueChange) return _isValueChange;
    
    for (UIView *view in self.contentScrollView.subviews) {
        if ([view respondsToSelector:@selector(isValueChange)]) {
            if ([view performSelector:@selector(isValueChange)]) {
                _isValueChange = YES;
                return _isValueChange;
            }
        }
    }
    
    return NO;
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



@end

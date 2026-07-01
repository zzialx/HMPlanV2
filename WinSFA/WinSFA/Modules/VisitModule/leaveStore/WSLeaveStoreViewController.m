//
//  LeaveStoreViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-7.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSLeaveStoreViewController.h"
#import "WSInoutStoreTable.h"
#import "WSAppData.h"
#import "WSCurrentTime.h"
#import "WSRequestHelper.h"
#import "WSJSONBuilder.h"
//#import "ConfigFileController.h"
#import "WSFuncsBean_other.h"
#import "WSFuncsBean_opt.h"
#import "DDLog.h"
#import "WSPhotoTypeItem.h"
#import "WSPhotoTypeArrayItem.h"
#import "WSNavigationBar.h"
#import "FUIDatePickerView.h"
#import "WSBeaconManager.h"
#import "WSStoreBean.h"
#import "WSStoreBeans.h"
#import "WSPolicyObject.h"

#import "WSEnvrionment.h"
#import "WSVisitStoreStatusTable.h"


@class WSAcvtView;


#define CELLHEIGHT      40
#define kRepairLeaveStoreTimeKey        @"repairLeaveStoreTimeKey"      //补录离店日期（时:分:秒）
#define kCustomTimeHeight   30.0f
#define kCellHeight         44.0f

#define K_TableViewHeight  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 310 :310)
#define K_SPACEHEIGTH      ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 10.0f : 15.0f)


@interface WSLeaveStoreViewController ()

@property (nonatomic, strong) NSString *leaveStoreTimeStamp;

@end

@implementation WSLeaveStoreViewController
@synthesize tableView = _tableView;
@synthesize dataArray = _dataArray;
@synthesize allowUpload = _allowUpload;
//@synthesize unfinishedString;
//@synthesize alert;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.leaveStoreTimeStamp = [WSCurrentTime getServerTime];
}

-(void)showUpdloadMessage{
    
     [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"uploading_prompt", nil)  tips:NSLocalizedString(@"please_wait", nil) tapTarget:self action:nil];
}


-(void)hiddenUploadMessage{
    
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:YES];
    
}

-(NSString *)getTextFieldValue:(int)textFieldTag
{
    for(UIView* view in self.contentScrollView.subviews)
    {
        if([view isKindOfClass:[UITextField class]])
        {
            UITextField *memo2TextField=(UITextField *)view;
            if (memo2TextField.tag==1000)
            {
                return memo2TextField.text;
            }
        }
    }
    return nil;
}
-(BOOL)uploadDatas{
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    
    // Read upload id: Enter store uploading id equal to the leave store uploading id
    
    // BOOL hasPhoto = [self.photoDataArr count] > 0?YES:NO;
    BOOL hasPhoto = [self.photoBrowseView.imageIDArray count] > 0?YES:NO;
    
    //add by wangdongyan 04-25 for 图片更新问题
    NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
    
    //修改JSONDATA中memo2 by yanguoshuai at 2012-05-07
    NSMutableDictionary *jsonDataDic=[NSMutableDictionary dictionaryWithObject:@"1" forKey:@"is"];
    // gps信息
    if (self.isGpsReady) {
        jsonDataDic = [[WSLocationManager getLocationUploadDataWithLocation:self.location andAddress:self.locationDescribe.detailAddress] mutableCopy];
    }
    
    for (int i = 0; i < [self.currentFuncs.otherArray count]; i++) {
        WSFuncsBean_other *other = [self.currentFuncs.otherArray objectAtIndex:i];
        if (([other.tpy isEqualToString:OTHER_TPY_N] || [other.tpy isEqualToString:OTHER_TPY_T]) &&
            [other.col hasPrefix:@"memo"]) {
            UIView *infoView = [self.view viewWithTag:(OTHER_TEXTFIELD_TAG + i)];
            if ([infoView isKindOfClass:[UITextField class]]) {
                UITextField *field = (UITextField *)infoView;
                NSString *value = (field.text == nil) ?  @"" : field.text;
                
                [jsonDataDic setValue:value forKey:other.col];
            }else if ([infoView isKindOfClass:[UITextView class]]) {
                UITextView *textView = (UITextView *)infoView;
                NSString *value = (textView.text == nil) ?  @"" : textView.text;
                
                [jsonDataDic setValue:value forKey:other.col];
            }
        }
        else if ([other.tpy isEqualToString:OTHER_TPY_C] && [other.col hasPrefix:@"memo"])
        {
            UIView *infoView = [self.view viewWithTag:(OTHER_SWITCH_TAG+i)];
            if ([infoView isKindOfClass:[UISwitch class]]) {
                UISwitch *swichView = (UISwitch *)infoView;
                NSString *flag = swichView.isOn ? @"1" : @"0";
                [jsonDataDic setValue:flag forKey:other.col];
            }
        }
    }

    // MEMO"
    UIView *memoView = [self.view viewWithTag:MEMOTAG];
    NSString *strMemo;
    if (memoView != nil) {
        strMemo = [(UITextField *)memoView text];
        if (strMemo == nil|| strMemo.length == 0) {
            strMemo = @"null";
        }
        [jsonDataDic setObject:strMemo forKey:@"memo"];
    }
    
    
    /*
     新旧调查问卷的问题答案获取方式不一样
     */
    
    //更新离店补录时间
    [[WSCustomTimeTable sharedTable] updateLeaveCustomTimeWithStoreId:self.currentStore.Id
                                                       withCustomTime:[WSCurrentTime getTimeString]/*[self.selectedDataDic objectForKey:kRepairLeaveStoreTimeKey]*/
                                                          withVisitId:self.md5];
    //离线上传
    NSString *postData = [WSJSONBuilder buildEnterLeaveStorebyFuncs:self.currentFuncs
                                                            isPhoto:hasPhoto
                                                              Store:self.currentStore
                                                           jsonData:jsonDataDic
                                                                md5:self.md5
                                                   isUsingDataEntry:YES
                                                     enterLeaveTime:self.leaveStoreTimeStamp];
    
    BOOL insertDataSucceed = [self insertUploadData:postData URL:URL_UPLOAD MD5:self.md5 IsPhoto:NO NotifyName:notifyID];
    if (!insertDataSucceed) {
        return insertDataSucceed;
    }
    [[WSCustomTimeTable sharedTable] updateCustomTimeFinishedWithStoreId:self.currentStore.Id withVisitId:self.md5];

    
    [self manageActionStatus:self.currentVisitAction];
    [uploadMgr postRequestOnEnterLeaveStorebyData:postData
                                            md5:self.md5
                                     notifyName:notifyID];
    return YES;
}


- (void)upload{
    
   [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
     //modify By wangdongyan 2012-02-27 for 当拍多张图片时，可以选择任意一张上传
    if ([self.currentFuncs.opt.isPic isEqualToString:QST_TYPE_R] && [self.photoBrowseView.imageIDArray count] < 1) {
        NSString *TakePhotoString = NSLocalizedString(@"pls_take_photo",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:TakePhotoString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    if (![self validateMemo]) {
        return;
    }

    
    if ([temp_storebean miniumalDuration]==nil) {
        
        //离店没有  正在上传/已加入上传队列  缺陷代码的添加如下:
        [self showUpdloadMessage];
        [self performSelector:@selector(doUpLoad) withObject:nil afterDelay:0.1];
    }else{
        
        [self executeOutStoreImformationPolicy];
    }
}

- (void)doUpLoad {
    
    if (![self uploadDatas]) {
        [self showDBErrorTipAndHidAllHud];
        return ;
    }
    if (![self uploadPhotos]) {
        [self showDBErrorTipAndHidAllHud];
        return ;
    }

    /*更新门店显示的拜访状态*/
    [self updateStoreVisitStaus:VisitStoreDone];
    
    /*用于判断门店是否离店*/
    [[WSInoutStoreTable sharedTable] updateLeaveStoreTime:self.currentStore andOtherParam:self.md5 andParamType:EParameterType_VisitId];
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    if (self.currentStore.beaconUUId) {
        [[WSBeaconManager getInstance] removeBeaconWithStoreId:self.currentStore.Id];
    }
    
    NSString *tip = NSLocalizedString(@"add_upload_queue", nil);
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tip tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
    
    self.isBackAccrossParent = YES;
    [self backToParent];
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

            NSString *photoFileName = [[SDImageCache sharedImageCache] cacheFileNameForKey:imageID];
            BOOL insertPhotoDataIsSucceed = [self insertUploadMedia:[params JSONString] Type:kOfflineTableDataType_P URL:URL_IMAGEUPLOAD MD5:imageIndex IsPhoto:YES NotifyName:notifyID photoFileName:photoFileName];
            if (!insertPhotoDataIsSucceed) {
                return insertPhotoDataIsSucceed;
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
                    
                    NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
                    
                    NSDictionary *params = [WSJSONBuilder buildImageParamsDicByImageID:imageID andPhotoTypeId:item.typeID];
                    NSString *photoFileName = [[SDImageCache sharedImageCache] cacheFileNameForKey:imageID];
                    
                    BOOL insertPhotoData = [self insertUploadMedia:[params JSONString] Type:kOfflineTableDataType_P URL:URL_IMAGEUPLOAD MD5:self.md5 IsPhoto:YES NotifyName:notifyID photoFileName:photoFileName];
                    if (!insertPhotoData) {
                        return insertPhotoData;
                    }
                    
                    [uploadMgr uploadImageWithFilePath:filePath
                                                params:params
                                                   url:URL_IMAGEUPLOAD
                                            notifyName:notifyID
                                                   md5:self.md5];
                    
                }
            }
        }
    }
    return YES;
}

- (void)initializationBackItemAction{
    
    if (self.currentFuncs && self.currentFuncs.isHomePageWillShow) {
        NSDictionary *mobileHomeDic = [WSAppData getObjectbyKey:MOBILEHOMEPAGE];
        if (mobileHomeDic) {
            NSString *readTimeStr = [mobileHomeDic objectForKey:MobileHomePageReadingTimeKey];
            [self backItemAction:nil target:nil withDelay:[readTimeStr intValue]];
            self.currentFuncs.isHomePageWillShow = NO;
        }
    }else {
        [self backItemAction:@selector(backAction) target:self];
    }
    
}
- (void)backAction {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    if ([super respondsToSelector:@selector(isValueChange)]) {
        BOOL superValueChange = [super isValueChange];
        if (superValueChange) {
            BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"back_confirm2", nil)];
            
            [alert setCancelButtonWithTitle:NSLocalizedString(@"give_up", nil) block:^{
                [self.navigationController popViewControllerAnimated:YES];
                
            }];
            [alert addButtonWithTitle:NSLocalizedString(@"upload_label", nil) block:^{
                [self upload];
            }];
            [alert show];

        }else{
             [self.navigationController popViewControllerAnimated:YES];
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

- (void) userChangeTimeViewWithEnterDateStr:(NSString*)enterDateStr withEnterTimeStr:(NSString*)enterTimeStr
{
    self.y_point += 10;
    UIView *changeDateView = [[UIView alloc] initWithFrame:CGRectMake(0, self.y_point, self.view.bounds.size.height, 88)];
    [changeDateView setBackgroundColor:[UIColor whiteColor]];
    self.y_point += 88;
    [self.contentScrollView addSubview:changeDateView];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.height, 1)];
    [lineView setBackgroundColor:[UIColor colorWithHexString:@"#C8C8C8"]];
    [changeDateView addSubview:lineView];
    
    UIFont *font = [UIFont systemFontOfSize:UI_Font];
    
    //离店时间行
    UILabel *leaveLabel = [[UILabel alloc] initWithFrame:CGRectMake(k_LabelXOffset, 1, 100, 42)];
    [leaveLabel setFont:font];
    [leaveLabel setBackgroundColor:[UIColor clearColor]];
    leaveLabel.text = NSLocalizedString(@"txt_leave_store_time", nil);
    leaveLabel.lineBreakMode = NSLineBreakByWordWrapping;
    leaveLabel.numberOfLines = 0;
    [changeDateView addSubview:leaveLabel];
    
    UILabel *leaveDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 2, 100, 40)];
    [leaveDateLabel setTextColor:[UIColor colorWithHexString:@"#C8C8C8"]];
    [leaveDateLabel setBackgroundColor:[UIColor clearColor]];
    [leaveDateLabel setLineBreakMode:NSLineBreakByClipping];
    [leaveDateLabel setText:enterDateStr];
    [leaveDateLabel setFont:font];
    [changeDateView addSubview:leaveDateLabel];
    
    NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
    formatter.dateFormat = @"HH:mm:ss";
    NSDate *curDate = [NSDate date];
    NSString *leaveTimeStr = [formatter stringFromDate:curDate];
    
    //设置离店时间必须大于进店时间
    NSDate *tmpLeaverTime = [formatter dateFromString:leaveTimeStr];
    NSDate *tmpEnterTime = [formatter dateFromString:enterTimeStr];
    if ([tmpLeaverTime timeIntervalSince1970] < [tmpEnterTime timeIntervalSince1970]) {
        leaveTimeStr = enterTimeStr;
    }
    
    
    FUIDatePickerView *timePickerView = [[FUIDatePickerView alloc] initWithFrame:CGRectMake(235, 2, 80, 40)
                                                                  withPickerMode:UIDatePickerModeTime
                                                                    withTitleStr:nil
                                                               withDateNormalStr:leaveTimeStr
                                                                   withAcvtQstId:nil
                                                                       withBlock:^(NSString *acvtQstId, NSString *dateStr) {
                                                                           self.isValueChange = YES;
                                                                           [self.selectedDataDic setObject:dateStr forKey:kRepairLeaveStoreTimeKey];
                                                                       }];
    [self.selectedDataDic setObject:leaveTimeStr forKey:kRepairLeaveStoreTimeKey];
    
    //设置取值范围
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *minDate = [formatter dateFromString:[NSString stringWithFormat:@"%@ %@", enterDateStr, enterTimeStr]];
    [timePickerView.customDatePicker setDate:[formatter dateFromString:[NSString stringWithFormat:@"%@ %@", enterDateStr, leaveTimeStr]]];
    [timePickerView.customDatePicker setMinimumDate:minDate];
    [changeDateView addSubview:timePickerView];
    
    //分割线
    UIView *lineCopyView = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:lineView]];
    [lineCopyView setFrame:CGRectMake(k_LabelXOffset, 44, self.view.bounds.size.height, 1)];
    [changeDateView addSubview:lineCopyView];
    

    //创建底部时间选择控件
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 45, self.view.bounds.size.height, 44)];
    [bottomView setBackgroundColor:[UIColor clearColor]];
    [changeDateView addSubview:bottomView];
    
    //进店时间回显
    UILabel *enterTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(k_LabelXOffset, 0, 100, 42)];
    [enterTitleLabel setBackgroundColor:[UIColor whiteColor]];
    [enterTitleLabel setFont:font];
    enterTitleLabel.text = NSLocalizedString(@"txt_enter_store_time", nil);
    enterTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    enterTitleLabel.numberOfLines = 0;
    [bottomView addSubview:enterTitleLabel];
    
    UIImageView *lockImgView = [[UIImageView alloc] initWithFrame:CGRectMake(126, 15, 8, 11)];
    [lockImgView setImage:[UIImage imageForName:@"lock.png"]];
    [bottomView addSubview:lockImgView];
    
    UILabel *enterLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 0, 170, 44)];
    [enterLabel setText:[NSString stringWithFormat:@"%@    %@", enterDateStr, enterTimeStr]];
    [enterLabel setBackgroundColor:[UIColor clearColor]];
    [enterLabel setTextColor:[UIColor colorWithHexString:@"#888888"]];
    [enterLabel setLineBreakMode:NSLineBreakByClipping];
    [enterLabel setFont:font];
    [bottomView addSubview:enterLabel];
    
    //分割线
    lineCopyView = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:lineView]];
    [lineCopyView setFrame:CGRectMake(0, 87, self.view.bounds.size.height, 1)];
    [changeDateView addSubview:lineCopyView];
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
   [super loadView];
    
    WSInoutStoreObject * notleaveStore = [[WSInoutStoreTable sharedTable] getNotLeaveStoreByStoreId:self.currentStore.Id moduleFc:self.currentVisitAction.module_fc];
    if (notleaveStore
        && [notleaveStore.store_id isEqualToString:self.currentStore.Id]) {
        
        NSString *uploadid = notleaveStore.visit_id;
        if(uploadid)
        {
            self.md5 = uploadid;
            LogInfo(@"离店:%@,md5:%@", [self class], self.md5);
        }else {
            LogError(@"错误，离店时查询不到对应的进店记录，storeId:%@, module_fc:%@", self.currentStore.Id, self.currentVisitAction.module_fc);
        }
    }else {
        LogError(@"错误，离店时查询不到对应的进店记录，storeId:%@, module_fc:%@", self.currentStore.Id, self.currentVisitAction.module_fc);
        if (notleaveStore) {
            LogError(@"错误，进店记录和当前门店不一致,notleavestore:%@", notleaveStore.store_id);
        }
    }
    
    [self addOptView];
    NSString* LeaveStore = NSLocalizedString(@"storename",nil);
    NSString* EnterStoreTime = NSLocalizedString(@"txt_enter_store_time",nil);
    NSString* LeaveStoreTime = NSLocalizedString(@"txt_leave_store_time",nil);
    NSString* StoreTime = NSLocalizedString(@"visit_pos_time_label",nil);
    NSString* NeedUnploadData = NSLocalizedString(@"总上传数据:",nil);
    NSString* SuccessData = NSLocalizedString(@"已上传数据:",nil);
    NSString* NOSuccessData = NSLocalizedString(@"未上传数据:",nil);
    
    isCustomTime = NO;
    NSString *enterDateStr = nil;
    NSString *enterTimeStr = nil;
    if ([[WSCustomTimeTable sharedTable] isCustomTimeWithStoreId: self.currentStore.Id withNeedNoLeaveStore:YES withVisitId:self.md5 ] ) {
        NSArray *array = [[WSCustomTimeTable sharedTable] queryCustomDateAndTimeWithStoreId:self.currentStore.Id withNeedNoLeaveStore:YES withVisitId:self.md5];
        if (array) {
            
            NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:4];
            enterDateStr = [array objectAtIndex:0];
            if ([array count] > 1) {
                isCustomTime = YES;
                enterTimeStr = [array objectAtIndex:1];
            }
            
            [tmpArray addObject:[NSString stringWithFormat:@"%@  %ld", NeedUnploadData, (long)[[WSOffLineUploadTable sharedTable] queryCountWithUploadFlagType:Success]+[[WSOffLineUploadTable sharedTable] queryCountWithUploadFlagType:Failed]]]; //需要上传的数据
            [tmpArray addObject:[NSString stringWithFormat:@"%@  %ld", SuccessData,(long)[[WSOffLineUploadTable sharedTable] queryCountWithUploadFlagType:Success]]];          //成功上传的数据
            [tmpArray addObject:[NSString stringWithFormat:@"%@  %ld", NOSuccessData,(long)[[WSOffLineUploadTable sharedTable] queryCountWithUploadFlagType:Failed]]];         //未上传的r数据
            self.dataArray = tmpArray;
        }
    }
    BOOL isUseDataHeight = [self.dataArray count] > 0 ? YES : NO;
    CGFloat tableHeight = K_TableViewHeight;
    if (!isCustomTime) {
        if (isUseDataHeight) {
            tableHeight =  kCellHeight * [self.dataArray count];
        }
        self.dataArray = [NSArray arrayWithObjects:LeaveStore,EnterStoreTime,LeaveStoreTime ,StoreTime,NeedUnploadData,SuccessData,NOSuccessData,nil];
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.y_point + 10, self.view.bounds.size.width, tableHeight) style:UITableViewStylePlain];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }else {
        if (isUseDataHeight) {
            tableHeight = kCustomTimeHeight * [self.dataArray count];
        }
        [self userChangeTimeViewWithEnterDateStr:enterDateStr withEnterTimeStr:enterTimeStr];
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.y_point + 10, self.view.bounds.size.width, tableHeight) style:UITableViewStylePlain];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    
    self.y_point += tableHeight + K_SPACEHEIGTH;
    
    self.tableView.bounces = NO;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tableView.autoresizesSubviews = YES;
//    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.contentScrollView addSubview:self.tableView];
    CGFloat contentWidth = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? self.view.bounds.size.width : (self.view.bounds.size.width - 160));
    [self addFuncsOtherBeanView];
     self.contentScrollView.contentSize = CGSizeMake(contentWidth, self.y_point);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self addToolBar];
    
    temp_storebean = [self matchStoreBeanForStores];
    
    
    
}

- (BOOL)shouldCustomInteractivePopGestureRecognizerDelegate
{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark tableviewdelegate

//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isCustomTime) {
        return kCustomTimeHeight;
    }
    
    return kCellHeight;
}

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat headHeight = 0;
    if (!([[UIDevice currentDevice] systemVersionByFloat] < 7.0)) {
        headHeight = 1.0f;
    }
    return headHeight;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat viewHeight  = 0;
    if (!([[UIDevice currentDevice] systemVersionByFloat] < 7.0)) {
        viewHeight = 1.0f;
    }
    UIView *headView = [[UIView alloc]init];
    [headView setFrame:CGRectMake(0,0, tableView.frame.size.width, viewHeight)];
    return headView;
}

//绘制Cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             SimpleTableIdentifier];
    if (cell == nil) {  
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                    reuseIdentifier: SimpleTableIdentifier];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:UI_Font];

    NSInteger totalCount = [self.dataArray count];
    
    if (isCustomTime) {
        cell.textLabel.text = [self.dataArray objectAtIndex: indexPath.row];
        [cell.textLabel setTextColor:[UIColor colorWithHexString:@"#888888"]];
        [cell.textLabel setFont:[UIFont systemFontOfSize:UI_Font]];
    }else {
        
        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:UI_Font - 2]];
        
        switch (indexPath.row) {
                
            case 0: //门店信息
            {
//                cell.textLabel.text = [NSString stringWithFormat:@"%@%@",[self.dataArray objectAtIndex:indexPath.row],self.currentStore.name];
                cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.dataArray objectAtIndex:indexPath.row]];
                
                cell.detailTextLabel.text = self.currentStore.name;
                
//                cell.detailTextLabel.text = @"cell.detailTextLabel.textcell.detailTextLabel.text";
            }
                break;
                
                
            case 1:  //进店时间
            {
                NSString* enterTime = [NSString stringWithValue:[[WSInoutStoreTable sharedTable] getEnterStoreTime:self.currentStore andOtherParam:self.md5 andParamType:EParameterType_VisitId]] ;
                
                if(enterTime != nil){
//                    cell.textLabel.text = [NSString stringWithFormat:@"%@%@",[self.dataArray objectAtIndex:indexPath.row],[WSCurrentTime getTimeStringbyMills:[enterTime doubleValue]]];
                    cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.dataArray objectAtIndex:indexPath.row]];
                    cell.detailTextLabel.text = [WSCurrentTime getTimeStringbyMills:[enterTime doubleValue]];
                    
                    LogInfo(@"Enter store time = %@", cell.textLabel.text);
                }
            }
                break;
            case 2:  //离店时间
            {
                NSString *timeStr = [WSCurrentTime getTimeStringbyMills:[self.leaveStoreTimeStamp doubleValue]];
//                cell.textLabel.text = [NSString stringWithFormat:@"%@%@",[self.dataArray objectAtIndex:indexPath.row], timeStr];
                cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.dataArray objectAtIndex:indexPath.row]];
                cell.detailTextLabel.text = timeStr;
                
                
                [self.selectedDataDic setObject:timeStr forKey:kRepairLeaveStoreTimeKey];
                LogInfo(@"Leave store time = %@", cell.textLabel.text);
            }
                break;
            case 3: //总时间
            {
                NSString* enterTime = [[WSInoutStoreTable sharedTable] getEnterStoreTime:self.currentStore andOtherParam:self.md5 andParamType:EParameterType_VisitId];
                double time = ([self.leaveStoreTimeStamp doubleValue] - [enterTime doubleValue]);
//                cell.textLabel.text = [NSString stringWithFormat:@"%@%@",[self.dataArray objectAtIndex:indexPath.row],[WSCurrentTime getTimeDifferencebydif:time]];
                cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.dataArray objectAtIndex:indexPath.row]];
                cell.detailTextLabel.text = [WSCurrentTime getTimeDifferencebydif:time];
                
            }
                break;
            case 4://需要上传的数据
            {
//                cell.textLabel.text = [NSString stringWithFormat:@"%@%d",[self.dataArray objectAtIndex:indexPath.row],[[WSOffLineUploadTable sharedTable] queryCountWithUploadFlagType:Success]+[[WSOffLineUploadTable sharedTable] queryCountWithUploadFlagType:Failed]];
                
                cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.dataArray objectAtIndex:indexPath.row]];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",(long)[[WSOffLineUploadTable sharedTable] queryCountWithUploadFlagType:Success]+[[WSOffLineUploadTable sharedTable] queryCountWithUploadFlagType:Failed]];

                
            }
                break;
            case 5: //成功上传的数据
            {
//                cell.textLabel.text = [NSString stringWithFormat:@"%@%d",[self.dataArray objectAtIndex:indexPath.row],[[WSOffLineUploadTable sharedTable] queryCountWithUploadFlagType:Success]];
                cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.dataArray objectAtIndex:indexPath.row]];
                cell.detailTextLabel.text =  [NSString stringWithFormat:@"%ld",(long)[[WSOffLineUploadTable sharedTable] queryCountWithUploadFlagType:Success]];
            }
                break;
            case 6: //未上传的数据
            {
//                cell.textLabel.text = [NSString stringWithFormat:@"%@%d",[self.dataArray objectAtIndex:indexPath.row],[[WSOffLineUploadTable sharedTable] queryCountWithUploadFlagType:Failed]];
                cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.dataArray objectAtIndex:indexPath.row]];
                cell.detailTextLabel.text =  [NSString stringWithFormat:@"%ld",(long)[[WSOffLineUploadTable sharedTable] queryCountWithUploadFlagType:Failed]];
            }
                break;
            default:
                break;
        }
    }
    
    UIView *line = [cell.contentView viewWithTag:1088];
    if (!line) {
        line = [[UIView alloc] initWithFrame:CGRectZero];
        line.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        line.backgroundColor = [UIColor colorWithHexString:@"#dcdcdc"];
        line.tag = 1088;
        [cell.contentView addSubview:line];
    }
    
    CGFloat xOffset = 15;
    if (indexPath.row == totalCount - 1) {
        xOffset = 0;
    }
    
    line.frame = CGRectMake(xOffset, cell.contentView.height - 1, cell.contentView.width, 1);
    
    
    return cell;
}

#pragma mark uialertdelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if(alertView.tag != ALERT_CAMERA_TAG)
    {
        switch (buttonIndex)
        {
            case 0:
                
                break;
            case 1:
                [self showUpdloadMessage];
                [self doUpLoad];
                break;
            default:
                break;
        }
    }
}


- (void)checkDataComplete
{
    NSMutableString *tip = [[NSMutableString alloc] initWithCapacity:16];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filename=[[NSString alloc]initWithFormat:@"%@_%@_%@.plist",[WSAppData getObjectbyKey:APPDATA_EMPID],self.currentStore.Id,[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    NSString *infofile=[documentsDirectory stringByAppendingPathComponent:filename];
    NSMutableDictionary *dics = [[NSMutableDictionary alloc] initWithContentsOfFile:infofile];
    if (dics != nil) {
        NSArray *keys = [dics allKeys];
        for (NSString *key in keys) {
            NSDictionary *info = [dics objectForKey:key];
            if (info != nil) {
                NSString *isChecked = [info objectForKey:@"fischecked"];
                if ([isChecked isEqualToString:@"1"]) {
                    NSString *name = [info objectForKey:@"fname"];
                    NSString *column = [info objectForKey:@"fitem"];
                    NSString *compose = [NSString stringWithFormat:@"%@-%@\n",name, column];
                    [tip appendString:compose];
                }
            }
        }
    }
    
    if (tip.length > 0) {
        [tip appendString:@"未完全填写"];
        self.allowUpload = NO;
    }else{
        [tip appendString:NSLocalizedString(@"Check_success", nil)];
        self.allowUpload = YES;
    }
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tip tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];


}

- (void)memoData:(id)sender
{
    [self.memoData setString:((UITextField*)sender).text];
}

- (void)executeOutStoreImformationPolicy{
    
     WSAlertpolicy *policy = [[WSAlertpolicy alloc]init];
    
    NSMutableDictionary *policyDict =[[NSMutableDictionary alloc]init];
    
    //进店时间
    NSString* begin_time_str = [NSString stringWithValue:[[WSInoutStoreTable sharedTable]
                                       getEnterStoreTime:self.currentStore
                                           andOtherParam:self.md5
                                            andParamType:EParameterType_VisitId]] ;
    
    NSString *enterStoreTime = [WSCurrentTime getTimeStringbyMills:[begin_time_str doubleValue]];
    
   
    
    [policyDict setObject:enterStoreTime forKey:@"begin_time_str"];
    
    //离店时间
    
    NSString *end_time_str = [WSCurrentTime getTimeStringbyMills:[self.leaveStoreTimeStamp doubleValue]];
   [policyDict setObject:end_time_str forKey:@"end_time_str"];
    
    
    //离店日期
    NSString *dateStr =[WSCurrentTime getDateString];
    
    //storeName
    NSArray *nameArray = [self.currentStore.name componentsSeparatedByString:@"-"];
    NSString *storeName =[nameArray objectAtIndex:0];
    
    //alertTitle
    NSString *title =[NSString stringWithFormat:@"%@-%@\n%@-%@\n在店时间不足%@分钟",self.currentStore.code,storeName,dateStr,end_time_str,temp_storebean.miniumalDuration];
    [policyDict setObject:title forKey:@"title"];
    
    
    //alertMessage
    [policyDict setObject:IS_CONFIRM_LEAVE_STORE forKey:@"message"];
    
    //duration
    [policyDict setObject:temp_storebean.miniumalDuration  forKey:@"duration"];
    
    policy.delegate = self ;
    
    [policy executePolicy:policyDict];
    
}

-(WSStoreBean *)matchStoreBeanForStores{
    
    WSStoreBeans *storeBeansArray = [WSAppData getObjectbyKey:STORES];
    
    __block WSStoreBean *storebean = nil;
    [storeBeansArray.storesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        WSStoreBean *storeBean = (WSStoreBean *)obj;
        
        if ([storeBean.Id isEqualToString:self.currentStore.Id]) {
            storebean = storeBean;
            
        }
      }
    ];
    
    return storebean;
}
- (void)alertpolicyforUpload{

    [self showUpdloadMessage];
    [self doUpLoad];
}



@end

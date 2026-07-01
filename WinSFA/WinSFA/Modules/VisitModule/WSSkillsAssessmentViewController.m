//
//  SkillsAssessmentViewController.m
//  WinChannelFrameWork
//
//  Created by wdy on 12-3-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSSkillsAssessmentViewController.h"
#import "WSFuncsBean_other.h"
#import "WSMultipleChoiceLabel.h"
#import "WSFdtTable.h"
#import "WSBaseDictsDBService.h"
//#import "ConfigFileController.h"

@interface WSSkillsAssessmentViewController ()
{
    BOOL _isFirstLoadView;
}

@end

@implementation WSSkillsAssessmentViewController
@synthesize indexMarked;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)upload{

     [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:[NSString stringWithFormat:@"平均得分%.2f",[self meanValue]]];
    [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:nil];
    [alert addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
        [self doUploaded];
    }];
    [alert show];
}

- (float) meanValue
{
    float sum = 0;
    for(int i = 0 ; i < [self.datas count]; i++) {
        NSArray *row = (NSArray *)[self.datas objectAtIndex:i];
        id obj = [row lastObject];
        if ([obj isKindOfClass:[WSHTextField class]]) {
            WSHTextField *textField = (WSHTextField*)obj;
            sum += [textField.text integerValue];
        }
    }
    return  sum / [self.datas count];
}

- (void)doUploaded
{

    NSMutableDictionary *dicOtherInfo = [self returnDicOtherInfo];
    
    if (self.currentSubEmpStore.Id && [self.currentSubEmpStore.Id length] > 0) {
        [dicOtherInfo setValue:self.currentSubEmpStore.Id forKey:@"srid"];
    }
    
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    
    BOOL hasPhoto = [self.photoBrowseView.imageIDArray count] > 0 ? YES:NO;
    
    NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
    //离线上传 add by wangdongyan 04-17 for 多张图片更新
    NSString *postData = [WSJSONBuilder buildDictDetail2byFuncs:self.currentFuncs
                                                       isPhoto:hasPhoto
                                                         datas:self.datas
                                                       dataIDs:self.m_dataSources
                                                           md5:self.md5
                                                          memo:self.memoData
                                                     otherInfo:dicOtherInfo];
    
    
    [self insertUploadData:postData URL:URL_UPLOAD MD5:self.md5 IsPhoto:hasPhoto NotifyName:notifyID];
    NSDate *date = [NSDate date];
    [self insertDictData];
    NSDate *after = [NSDate date];
    LogInfo(@"insertDictData耗时:%f",[after timeIntervalSinceDate:date]);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishRequest:)
                                                 name:notifyID
                                               object:nil];
    [super uploadVisitAction];
    [uploadMgr postRequestAcvtData:postData
                        notifyName:notifyID
                               md5:self.md5
              isSynchronizeRequest:NO];
    
}

- (void)finishRequest:(NSNotification *)notification
{
    
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
    NSString *msg = [responseDictonary objectForKey:@"message"];
    if (!result || [result isKindOfClass:[NSNull class]]) {
        return;
    }
    
    if ([result isEqualToString:@"0"]) {        //失败
        [self showAlert: msg];
    }
    else if ([result isEqualToString:@"1"]) {   //成功
        if (!msg || [msg isKindOfClass:[NSNull class]] || [msg length] == 0) {
            msg = NSLocalizedString(@"errcode_success", nil);
        }
         [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:msg tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
    }
    else if ([result isEqualToString:@"2"]) {  //警告
         [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:msg tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }else{
    
        NSDictionary *resultDictonary = [result objectFromJSONString];
        NSString * stringFlag = [NSString stringWithFormat:@"%@" ,[resultDictonary objectForKey:@"flag"]];
        if ([stringFlag isEqualToString:@"1"]) {
            
            msg = NSLocalizedString(@"upload_success", nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:msg tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        }else{
            msg = NSLocalizedString(@"fail_upload", nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:msg tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
            
        }
        
    }
}


- (void)showAlert:(NSString *)message{
//    NSString *UploadFailString = NSLocalizedString(@"fail_upload",nil);
    NSString *UploadFailString = NSLocalizedString(@"js_alert_title",nil);
    NSString *OkString = NSLocalizedString(@"confirm",nil);
    NSString *TryString = NSLocalizedString(@"retry", nil);
    
    BlockAlertView *alert = [BlockAlertView alertWithTitle:UploadFailString message:message];
    
    [alert setCancelButtonWithTitle:OkString block:nil];
    
    [alert addButtonWithTitle:TryString block:^{
        
    }];
    
    [alert show];
    
}

-(NSMutableDictionary*)returnDicOtherInfo
{
    NSMutableDictionary *dicOtherInfo = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < [self.currentFuncs.otherArray count]; i++) {
        WSFuncsBean_other *other = [self.currentFuncs.otherArray objectAtIndex:i];
        if ([other.tpy isEqualToString:OTHER_TPY_N] ||[other.tpy isEqualToString:OTHER_TPY_T] ) {
            UIView *infoView = [self.view viewWithTag:(OTHER_TEXTFIELD_TAG+i)];
            if ([infoView isKindOfClass:[UITextField class]]) {
                UITextField *field = (UITextField *)infoView;
                NSString *value = (field.text == nil) ? @"" : field.text;
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
        else if ([other.tpy isEqualToString:OTHER_TPY_C])
        {
            
            WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
            NSArray* dictBeanArray = [service queryDictsForAcvtGridWithFilter:other.filter];
            
            for (NSInteger optionIndex = 0; optionIndex < dictBeanArray.count; optionIndex++ ){
                UIView   *option_btn = [self.view viewWithTag:5000+optionIndex*1000];
                if([option_btn isKindOfClass:[UIButton class]]){
                    UIButton* option_btn_= (UIButton *)option_btn;
                    if(option_btn_.selected){
                        WSDictBean* option_temp = [dictBeanArray objectAtIndex:optionIndex];
                        NSString* value=[dicOtherInfo valueForKey:other.col];
                        if(value!=nil){
                            value=[value stringByAppendingFormat:@",%@",option_temp.Id];
                        }else{
                            value=[NSString stringWithString:option_temp.Id];
                        }
                        [dicOtherInfo setValue:value forKey:other.col];
                    }
                }
            }
        }
    }
    return dicOtherInfo;
}

-(void)insertDictData {
    BOOL dataIsFollowup = NO;/*区别主管下有多个可以随访人员而添加*/
    if(![self.currentFuncs.ds isEqualToString:@"dicts"])
        return;
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSString *func_code = self.currentFuncs.fc;
    func_code = [func_code isKindOfClass:[NSString class]] ? func_code : @"";
    [array addObject:func_code];
    
    NSString *func_view = self.currentFuncs.fv;
    func_view = [func_view isKindOfClass:[NSString class]] ? func_view : @"";
    [array addObject:func_view];
    
    NSString *is_planed = @"0";
    if (self.currentStore != nil && [self.currentStore isKindOfClass:[WSStoreBean class]]) {
        is_planed = self.currentStore.plan ? @"1" : @"0";
    }
    else
    {
        is_planed = @"1";
    }
    [array addObject:is_planed];
    [array addObject:@""];
    
    NSString *store_id = nil;
    if (self.currentStore != nil) {
        if ([self.currentStore isKindOfClass:[WSStoreBean class]]) {
            store_id = self.currentStore.Id;
        }else{
            store_id = @"";
        }
    }else{
        store_id = @"";
    }
    [array addObject:store_id];
    
    NSString *emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
    emp_id = [emp_id isKindOfClass:[NSString class]] ? emp_id : @"";
    [array addObject:emp_id];
    
    NSString *biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    biz_date = [biz_date isKindOfClass:[NSString class]] ? biz_date : @"";
    [array addObject:biz_date];
    
    NSString *upload_date = [WSCurrentTime getDateString];
    upload_date = [upload_date isKindOfClass:[NSString class]] ? upload_date : @"";
    [array addObject:upload_date];
    [array addObject:@"0"];
    
    NSString *md5 = self.md5;
    md5 = [md5 isKindOfClass:[NSString class]] ? md5 : @"";
    [array addObject:md5];
    
    NSString *srid = nil;
    if (self.currentSubEmpStore.Id) {
        srid = self.currentSubEmpStore.Id;
        dataIsFollowup = YES;
    }else{
        
        srid = (self.currentStore.srid && [self.currentStore.srid length] > 0 ) ? [self.currentStore.srid copy] : @"null";
    }
    
    [array addObject:srid];
    
    // get the MEMOs datas
    NSMutableDictionary *dicOtherInfo = [self returnDicOtherInfo];
    
    // MEMO"
    NSString *memo = [dicOtherInfo objectForKey:@"memo"];
    UIView *memoView = [self.view viewWithTag:500];
    if (memo==nil&&memoView!=nil) {
        memo = [(UITextField *)memoView text];
    }
    [array addObject:[NSString stringNotNilWithValue:memo]];
    
    // MEMO1 ~ MEMO10
    for (int i = 0; i < 10; i++) {
        NSString *memoi = [dicOtherInfo objectForKey:[NSString stringWithFormat:@"memo%d", i + 1]];
        memoi = [memoi isKindOfClass:[NSString class]] ? memoi : @"null";
        [array addObject:memoi];
    }
    
    // MSTD-6968 TITLES
    [array addObject:@"null"];
    
    NSMutableArray *dictValues = [[NSMutableArray alloc] init];
    //产品数量
    for(int i = 0 ; i < [self.datas count]; i++) {
        NSArray *row = (NSArray *)[self.datas objectAtIndex:i];
        
        NSMutableDictionary *dictRow = [[NSMutableDictionary alloc] init];
        
        NSString *idx = self.md5;
        idx = [idx isKindOfClass:[NSString class]] ? idx : @"";
        [dictRow setValue:idx forKey:@"IDX"];
        
        UILabel *dictId = [row objectAtIndex:0];
        /*
         NSString *dict_id = [NSString stringWithValue: dictId.text];
         */
        NSString *dict_id_Value = [NSString stringWithFormat:@"%ld",(long)dictId.tag];
        [dictRow setValue:dict_id_Value forKey:@"DICT_ID"];
        
        for (int j = 1 ; j < [row count] ;j++) {
            WSFuncsBean_Param *param  =  [self.currentFuncs.paramArray objectAtIndex:j - 1];
            if (param.col.length > 4) {
                continue;
            }
            if ([[row objectAtIndex:j] isKindOfClass:[UITextField class]]) {
                UITextField *view = (UITextField *)[row objectAtIndex:j];
                //col
                if(view.text != nil) {
                    [dictRow setObject:view.text forKey:param.col];
                }
                
            } else if ([[row objectAtIndex:j] isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)[row objectAtIndex:j];
                if(button.isSelected) {
                    [dictRow setObject:@"1" forKey:param.col];
                }else{
                    [dictRow setObject:@"0" forKey:param.col];
                }
                
            } else if ([[row objectAtIndex:j] isKindOfClass:[WSMultipleChoiceLabel class]]) {
                WSMultipleChoiceLabel *label = (WSMultipleChoiceLabel *)[row objectAtIndex:j];
                NSString *value = (label.iContent != nil) ? label.iContent : @"";
                [dictRow setObject:value forKey:param.col];
            } else if ([[row objectAtIndex:j] isKindOfClass:[PhotoTypeButton class]]) {
                PhotoTypeButton *photoButton = (PhotoTypeButton *)[row objectAtIndex:j];
                if (photoButton.photoIDArray && [photoButton.photoIDArray count] > 0) {
                    NSString *string = [photoButton.photoIDArray componentsJoinedByString:@","];
                    if (string && [string length] > 0) {
                        [dictRow setObject:string forKey:param.col];
                    }
                }
            }else if ([[row objectAtIndex:j] isKindOfClass:[WSSelectListView class]]) {
                WSSelectListView *selectView = (WSSelectListView *)[row objectAtIndex:j];
                NSString *selectItem = nil;
                switch (selectView.selectMode) {
                    case WSSelectListViewSelectModeSingleSelection:
                    {
                        NSArray *content = selectView.content;
                        if (content && [content count] > 0) {
                            if(selectView.selectedIndex>-1){
                                selectItem= [selectView.content objectAtIndex:selectView.selectedIndex];
                            }
                        }
                    }
                        break;
                    case WSSelectListViewSelectModeMultipleChoice:
                    {
                        selectItem = [selectView getSelectedContentString];
                        
                        if (selectItem && [selectItem isEqualToString:[selectView getDefaultString]]){
                            selectItem = nil;
                        }
                    }
                        break;
                    default:
                        break;
                }
                
                if(selectItem && selectItem.length>0){
                    [dictRow setObject:selectItem forKey:param.col];
                }
            }
        }
        
        [dictValues addObject:dictRow];
    }
    
    NSDate *bef = [NSDate date];
    if (dataIsFollowup) {
        [[WSFdtTable sharedTable] insertWithFdtArray:array Dict:dictValues  srid:srid];
    } else {
        [[WSFdtTable sharedTable] insertWithFdtArray:array Dict:dictValues ];
    }
    
    
    NSDate *aft = [NSDate date];
    LogInfo(@"insertIntoFdtWithDictionary耗时:%f", [aft timeIntervalSinceDate:bef]);
}


//获取数据库的内容
-(NSString*)getDatasFromDataBaseWithParam:(WSFuncsBean_Param*)aParam Data:(WSDictBean*)aDict
{
    if(self.m_DataBaseDatas != nil)
    {
        //array 元素是nsdictionary
        for(WSDictObject* objcet in self.m_DataBaseDatas)
        {
            NSString* pID = objcet.dict_id;
            if([pID isEqualToString:aDict.Id])
            {
                return [objcet valueForKey:aParam.col];
                
            }
        }
        return nil;
    }
    return nil;
    
}


-(NSString*)getDefaultDataWithParam:(WSFuncsBean_Param*)aParam Others:(WSDictBean*)aDict
{
    return nil;
}


-(NSString*)getDataSourcesWithIndex:(NSNumber*)aIndex Other:(NSArray*)aDicts
{
    WSDictBean* l_dict = [aDicts objectAtIndex:[aIndex intValue]];
    return l_dict.name;
}

 
-(NSArray*)getDatasSources
{
    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
    NSArray* filterArray = [service queryDictsForAcvtGridWithFilter:self.currentFuncs.filter];
    
    return filterArray;
}


-(NSArray*)getDataBaseDatas
{
    NSString *sridTemp = nil;
    if (self.currentSubEmpStore.Id) {
        sridTemp = self.currentSubEmpStore.Id;
    }else{
        sridTemp = self.currentStore.srid;
    }
    NSArray* l_array = [[WSFdtTable sharedTable] queryDictWithStoreId:self.currentStore.Id fc:self.currentFuncs.fc srid:sridTemp withMd5:self.md5];
    return l_array;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _isFirstLoadView = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_isFirstLoadView) {
        
        [self reDrawGrideWithHeight:self.view.bounds.size.height -  SPACEHEIGTH];
        
        _isFirstLoadView = NO;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.m_ParentViewController && self.uploadButton) {
        NSArray *originBarButtonArray = self.m_ParentViewController.navigationItem.rightBarButtonItems;
        NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:[originBarButtonArray count]];
        [mArray addObjectsFromArray:originBarButtonArray];
        if ([mArray containsObject: self.uploadButton]) {
            [mArray removeObject:self.uploadButton];
        }
        self.m_ParentViewController.navigationItem.rightBarButtonItems = mArray;
        self.uploadButton = nil;
    }
}


  
#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


@end

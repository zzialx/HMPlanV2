//
//  DictGrideViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-2-23.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSDictGrideViewController.h"
#import "WSFdtTable.h"
#import "WSCurrentTime.h"
#import "WSRequestHelper.h"
#import "WSJSONBuilder.h"
//#import "ConfigFileController.h"
#import "WSMultipleChoiceLabel.h"
#import "WSAppData.h"
#import "WSAcvtBean.h"
#import "WSAbnormalDetailAcvtViewController.h"
#import "WSFuncsBean_Param.h"
#import "WSAcvtButtonForTB.h"
#import "WSImagePathTable.h"
#import "WSFuncsBean_other.h"
#import "WSNavigationBar.h"
#import "WSStoredDictDisArray.h"
#import "WSStoredDictDisBean.h"
#import "WSBaseStoreDictDisTable.h"
#import "WSMappingObject.h"
#import "WinSFA.h"
#import "WSEnvrionment.h"
#import "WSBaseDictsDBService.h"
#import "WSBaseAcvtDBService.h"

@interface WSDictGrideViewController ()
{
    BOOL _isFirstLoadView;
}

@property (nonatomic, strong) WSFuncsBean_Param *badReasonParam;
@property (nonatomic, strong) UIAlertView *datasChangeAlertView;
@property (nonatomic, assign) BOOL insertFdtDataIsSucceed;

@end

@implementation WSDictGrideViewController
@synthesize badReasonParam = _badReasonParam;


-(void)insertDictData {
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
    NSString *srid = [self getSrid];
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
            if (param.col.length > 5) {
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
    
    BOOL  insertFdtSucceed = [[WSFdtTable sharedTable] insertWithFdtArray:array Dict:dictValues ];
    if (!insertFdtSucceed) {
        _insertFdtDataIsSucceed = insertFdtSucceed;
        return;
    }
    
    NSDate *aft = [NSDate date];
    LogInfo(@"insertIntoFdtWithDictionary耗时:%f", [aft timeIntervalSinceDate:bef]);
}

- (NSString *)getSrid {
    NSString *srid = @"null";
    if (self.currentStore) {
        if (self.currentStore.srid && [self.currentStore.srid length] > 0 ) {
            srid = [self.currentStore.srid copy];
        }
    } else if (self.currentSubEmpStore) {
        if (self.currentSubEmpStore.Id && [self.currentSubEmpStore.Id length] > 0) {
            srid = self.currentSubEmpStore.Id;
        }
    }
    return srid;
}

//- (void)checkBoxPressed: (id)sender{
//    self.isValueChange = YES;
//    if ([sender isKindOfClass:[UIButton class]]) {
//        if (((UIButton *)sender).selected) {
//            [(UIButton *)sender setSelected:NO];
//        }else{
//            [(UIButton *)sender setSelected:YES];
//        }
//    }
//}

-(BOOL)hasPhotoForAbnormalReason
{
    NSArray *keys = [self.photoDataDic allKeys];
    for (NSString *key in keys) {
        NSArray *photoArray = [self.photoDataDic objectForKey:key];
        if ([photoArray count] > 0) {
            return TRUE;
        }
    }
    return FALSE;
}

-(NSString *)checkContentBeforeUpload
{
    NSLog(@"photoDataDic allKeys:%@", [self.photoDataDic allKeys]);
    NSMutableArray *datasArray = [NSMutableArray arrayWithArray:self.datas];
    if (self.abnormalReasonDict)
    {
        LogInfo(@"add abnormalreasondict");
        [datasArray addObject:self.abnormalReasonDict];
    }
    
    // Get other view info
    NSMutableDictionary *dicOtherInfo = nil;
    for (int i = 0; i < [self.currentFuncs.otherArray count]; i++) {
        WSFuncsBean_other *other = [self.currentFuncs.otherArray objectAtIndex:i];
        if ([other.tpy isEqualToString:OTHER_TPY_N] ||[other.tpy isEqualToString:OTHER_TPY_T] ) {
            UIView *infoView = [self.view viewWithTag:(OTHER_TEXTFIELD_TAG+i)];
            if ([infoView isKindOfClass:[UITextField class]]) {
                UITextField *field = (UITextField *)infoView;
                NSString *value = (field.text == nil) ? @"" : field.text;
                if (dicOtherInfo == nil) {
                    dicOtherInfo = [[NSMutableDictionary alloc] init];
                }
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
    
    NSString *postData = [WSJSONBuilder buildDictDetailbyFuncs:self.currentFuncs
                                                     isPhoto:0
                                                       datas:datasArray
                                                     dataIDs:self.m_dataSources
                                                       Store:self.currentStore
                                                         md5:@""
                                                        memo:self.memoData
                                                   otherInfo:dicOtherInfo];
    
    NSArray *paramArray = nil;
    NSDictionary *jsonData = [[postData objectFromJSONString] objectForKey:@"jsonData"];
    if ([jsonData isKindOfClass:[NSString class]]) {
        NSString *jsonString = (NSString *)jsonData;
        NSDictionary *dic = [jsonString objectFromJSONString];
        if (dic) {
           paramArray = [dic objectForKey:@"param"];
        }
    }else{
        paramArray = [jsonData objectForKey:@"param"];
    }
    for (int column = 0;  column < [self.currentFuncs.paramArray count]; column++ /*WSFuncsBean_Param *param in self.currentFuncs.paramArray*/)
    {
        WSFuncsBean_Param *param = [self.currentFuncs.paramArray objectAtIndex:column];
        if ([param.isReq isEqualToString:@"1"])
        {
            NSString *key = param.col;
            for (int row = 0; row < paramArray.count; row++ /*NSDictionary *dic in paramArray*/)
            {

                NSDictionary *dic = [paramArray objectAtIndex:row];
                
                //UI
                NSArray *subdatas = [self.datas objectAtIndex:row];
                id ui = [subdatas objectAtIndex:column + 1];
                
                if (([dic objectForKey:key] == nil) || ([[dic objectForKey:key] isKindOfClass:[NSString class]] && [[dic objectForKey:key] isEqualToString:@""]))
                {
//                    return EPhotoMiss;
                    if (ui != nil && [ui respondsToSelector:@selector(entityIsEnable)]) {
                        if ([ui entityIsEnable]) {
                            if ([ui respondsToSelector:@selector(isValueLegal)]) {
                                if (![ui isValueLegal]) {
//                                    return [ui isKindOfClass:[PhotoTypeButton class]] ? EPhotoMiss : EMemoMiss;
                                    return param.name;
                                }
                            }else{
                               return param.name;
                            }
                        }
                    }else{
                        return param.name;
                    }
                
                }
                else if ([[[dic objectForKey:key] objectFromJSONString] isKindOfClass:[NSDictionary class]])
                {
                    NSString *photoKey = [[[dic objectForKey:key] objectFromJSONString] objectForKey:@"photo"];
                    
                    if ((photoKey == nil) || ([(NSArray *)[self.photoDataDic objectForKey:photoKey] count] == 0))
                    {
                        if (ui != nil && [ui respondsToSelector:@selector(entityIsEnable)]) {
                            if ([ui entityIsEnable]) {
                                return param.name;
                            }
                        }else{
                            return param.name;
                        }
                    }
                }
            }
        }
        else if ([param.isReq length] > 0 &&[[param.isReq substringToIndex:1] isEqualToString:@"!"])
        {
            NSString *col = [param.isReq substringFromIndex:1];
            for (NSDictionary *dic in paramArray)
            {
                if ([(NSNumber *)[dic objectForKey:col] intValue] == 0)
                {
                    if ([[dic objectForKey:param.col] isEqualToString:@""])
                    {
                        return param.name;
                    }
                }
            }
            
        }else {
            NSString *key = param.col;
            for (int row = 0; row < [paramArray count]; row++ /*NSDictionary *dic in paramArray*/)
            {
                NSDictionary *dic = [paramArray objectAtIndex:row];
                NSArray *subdatas = [self.datas objectAtIndex:row];
                id ui = [subdatas objectAtIndex:column + 1];
                if (([dic objectForKey:key] == nil) || ([[dic objectForKey:key] isKindOfClass:[NSString class]] && [[dic objectForKey:key] isEqualToString:@""]))
                {
                    if (ui != nil && [ui respondsToSelector:@selector(isNeedValue)]) {
                        if ([ui performSelector:@selector(isNeedValue) withObject:nil]) {
                            return param.name;
                        }
                    }
                }
            }
        }
    }
    return nil;
    
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

-(BOOL)uploadDatas{
    
    // Get other view info

    NSMutableDictionary *dicOtherInfo = [self returnDicOtherInfo];
    if(self.currentStore==nil){
        NSString * srid=[self getSrid];
        if(srid){
            [dicOtherInfo setValue:srid forKey:@"srid"];
        }
    }
    
     _insertFdtDataIsSucceed = YES;
    if (self.abnormalReasonDict) {
        
        [self.datas addObject:self.abnormalReasonDict];
        
        BOOL hasPhoto = [self hasPhotoForAbnormalReason]==TRUE?YES:NO;
        
        NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];

        //离线上传 add by wangdongyan 04-17 for 多张图片更新
        NSString *postData = [WSJSONBuilder buildDictDetailbyFuncs:self.currentFuncs
                                                         isPhoto:hasPhoto datas:self.datas
                                                         dataIDs:self.m_dataSources
                                                           Store:self.currentStore
                                                             md5:self.md5
                                                            memo:self.memoData otherInfo:dicOtherInfo];
        
        NSDate *date = [NSDate date];
        BOOL insertDictDataIsSucceed = [self insertUploadData:postData URL:URL_UPLOAD MD5:self.md5 IsPhoto:hasPhoto NotifyName:notifyID];
        
        
        if (!insertDictDataIsSucceed) {
            return insertDictDataIsSucceed;
        }
        NSDate *after = [NSDate date];
        LogInfo(@"insertUploadData耗时:%f",[after timeIntervalSinceDate:date]);
        // cailei
        if ([[self.datas lastObject] isKindOfClass:[NSDictionary class]]) {
            [self.datas removeLastObject];
        }
        [self insertDictData];
        if (!_insertFdtDataIsSucceed) {
            return NO;
        }
        [super uploadVisitAction];
        [[WSRequestHelper shareInstance] postRequestAcvtData:postData
                                          notifyName:notifyID
                                                 md5:self.md5
                                        isSynchronizeRequest:NO];
    }
    else {
        
        WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];

        BOOL hasPhoto = [self.photoBrowseView.imageIDArray count] > 0 ? YES:NO;
        
        NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
        //离线上传 add by wangdongyan 04-17 for 多张图片更新
        NSString *postData = [WSJSONBuilder buildDictDetailbyFuncs:self.currentFuncs
                                                         isPhoto:hasPhoto
                                                           datas:self.datas
                                                         dataIDs:self.m_dataSources
                                                           Store:self.currentStore
                                                             md5:self.md5
                                                            memo:self.memoData
                                                       otherInfo:dicOtherInfo];
        BOOL insertPhotoDataIsSucceed = [self insertUploadData:postData URL:URL_UPLOAD MD5:self.md5 IsPhoto:hasPhoto NotifyName:notifyID];
        
        if (!insertPhotoDataIsSucceed) {
            return insertPhotoDataIsSucceed;
        }
        NSDate *date = [NSDate date];
        [self insertDictData];
        if (!_insertFdtDataIsSucceed) {
            return NO;
        }
        NSDate *after = [NSDate date];
        LogInfo(@"insertDictData耗时:%f",[after timeIntervalSinceDate:date]);
        
        [uploadMgr postRequestAcvtData:postData
                          notifyName:notifyID
                                 md5:self.md5
                  isSynchronizeRequest:NO];
    }
    return YES;
}

-(NSDictionary*)md5Param
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:[super md5Param]];
    NSString* memo=nil;
    if (!self.abnormalReasonDict) {
        memo=self.currentFuncs.iParentFuncsBean.fc;
    }
    
    NSString *superMemo = [dic objectForKey:@"memo"];
    
    if (memo
        && [memo length] > 0
        && superMemo
        && [superMemo length] > 0) {
        memo = [NSString stringWithFormat:@"%@_%@",superMemo,memo];
        [dic setValue:memo forKey:@"memo"];
    }else if(memo
             && [memo length] > 0){
        [dic setValue:memo forKey:@"memo"];
    }
    
    
    return dic;
}

-(BOOL)uploadPhotos{
    
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    if (self.abnormalReasonDict) {
        for (NSString *key in [self.photoDataDic allKeys]) {
            
            NSMutableArray *acvtImagePathDicArray = [[NSMutableArray alloc] init];
            
            for (NSString *imageID in [self.photoDataDic objectForKey:key]) {
                
                NSString *filePath = [[SDImageCache sharedImageCache] imagePathFromKey:imageID];
                if (filePath)
                {
                    NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
                    NSDictionary *params = [WSJSONBuilder buildImageParamsDicByImageID:imageID];
                    
                    NSString *photoFileName = [[SDImageCache sharedImageCache] cacheFileNameForKey:imageID];
                    BOOL insertPhotoDataIsSucceed = [self insertUploadMedia:[params JSONString] Type:kOfflineTableDataType_P URL:URL_IMAGEUPLOAD MD5:key IsPhoto:YES NotifyName:notifyID photoFileName:photoFileName];
                    if (!insertPhotoDataIsSucceed) {
                        return insertPhotoDataIsSucceed;
                    }
                    [uploadMgr uploadImageWithFilePath:filePath
                                                params:params
                                                   url:URL_IMAGEUPLOAD
                                            notifyName:notifyID
                                                   md5:key];
                    
                    NSArray* array=[NSArray arrayWithObjects:key,imageID,[WSAppData getObjectbyKey:APPDATA_BIZDATE],[WSCurrentTime getDateTime],@"0",nil];
                    [acvtImagePathDicArray addObject:array];
                }
            }
            if (acvtImagePathDicArray && [acvtImagePathDicArray count] > 0) {
                [[WSImagePathTable sharedTable] updateWithImageIDX:key withValuesArray:acvtImagePathDicArray];
            }
        }
    }
    else {
        NSString* imageIndex=[NSString stringWithFormat:@"%@_%@",self.currentFuncs.fc,self.md5];


        NSMutableArray *dicValueArray = [[NSMutableArray alloc] init];
        
        for (NSString *imageID in self.photoBrowseView.imageIDArray) {
        
            NSString *filePath = [[SDImageCache sharedImageCache] imagePathFromKey:imageID];
            if (filePath)
            {
                NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
                NSDictionary *params = [WSJSONBuilder buildImageParamsDicByImageID:imageID];
                
                NSString *photoFileName = [[SDImageCache sharedImageCache] cacheFileNameForKey:imageID];
                BOOL insertPhotoDataIsSucceed = [self insertUploadMedia:[params JSONString] Type:kOfflineTableDataType_P URL:URL_IMAGEUPLOAD MD5:imageIndex IsPhoto:YES NotifyName:notifyID photoFileName:photoFileName];
                if (!insertPhotoDataIsSucceed) {
                    return insertPhotoDataIsSucceed;
                }
                
                NSArray* array=[NSArray arrayWithObjects:imageIndex,imageID,[WSAppData getObjectbyKey:APPDATA_BIZDATE],[WSCurrentTime getDateTime],@"0",nil];
                
                [dicValueArray addObject:array];
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
        if (dicValueArray && [dicValueArray count] > 0) {
            [[WSImagePathTable sharedTable] updateWithImageIDX:imageIndex withValuesArray:dicValueArray];
        }
        else
        {
            [[WSImagePathTable sharedTable] deleteWithImageIDX:imageIndex];
        }
    }
    
    if (![self uploadPhotosInButton]) {
        return NO;
    }
    return YES;
}

- (BOOL)uploadPhotosInButton {
    NSInteger iMax = [self.datas count];
    NSInteger jMax = [self.currentFuncs.paramArray count];
    NSString *ds = @"dictsId";
    
    for (int i = 0; i < iMax; i++) {
        NSArray *subdatas = [self.datas objectAtIndex:i];
        WSDictBean *dictBean = [self.m_dataSources objectAtIndex:i];
        if ([subdatas isKindOfClass:[NSArray class]]) {
            NSMutableDictionary *celldic = [[NSMutableDictionary alloc] initWithCapacity:[self.currentFuncs.paramArray count]];
            [celldic setObject:[NSString stringWithFormat:@"%@@ ",dictBean.Id] forKey:ds];
            for (int j = 0; j < jMax; j++) {
                id o = [subdatas objectAtIndex:j+1];
                if ([o isKindOfClass:[PhotoTypeButton class]]) {
                    PhotoTypeButton *button = (PhotoTypeButton *)o;
                        
                    for (NSString *imageID in button.photoIDArray)
                    {
                        @autoreleasepool {

                            NSString *filePath = [[SDImageCache sharedImageCache] imagePathFromKey:imageID];
                            if (filePath) {
                                
                                NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
                                NSDictionary *params = [WSJSONBuilder buildImageParamsDicByImageID:imageID];
                                
                                NSString *photoFileName = [[SDImageCache sharedImageCache] cacheFileNameForKey:imageID];
                                BOOL insertPhotoDataIsSucceed = [self insertUploadMedia:[params JSONString] Type:kOfflineTableDataType_P URL:URL_IMAGEUPLOAD MD5:button.imageMD5 IsPhoto:YES NotifyName:notifyID photoFileName:photoFileName];
                                if (!insertPhotoDataIsSucceed) {
                                    return insertPhotoDataIsSucceed;
                                }
                                WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
                                
                                [uploadMgr uploadImageWithFilePath:filePath
                                                            params:params
                                                               url:URL_IMAGEUPLOAD
                                                        notifyName:notifyID
                                                               md5:button.imageMD5];
                            }
                        }
                    }
                }
            }
        }
    }
    return YES;
}


//modify by wangdongyan 03-22 for 更改md5来确定是单张还是多张照片
- (void)upload{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    //判断是否未必填项
    if ([self.currentFuncs.required isEqualToString:@"R"]) 
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *storeString=[[NSString alloc]initWithFormat:@"%@.plist",self.currentStore.name];;
        NSString *WorkListFile=[documentsDirectory stringByAppendingPathComponent:storeString];
        
        NSMutableDictionary *WorkListDic=[[NSMutableDictionary alloc]initWithContentsOfFile:WorkListFile];;
        for (int i=0; i<[[WorkListDic allKeys] count]; i++) 
        {
            if ([self.currentFuncs.name isEqualToString:[[WorkListDic allKeys]objectAtIndex:i]]) 
            {
                if (![[WorkListDic objectForKey:[[WorkListDic allKeys]objectAtIndex:i]] isEqualToString:@"1"]) 
                {
                    
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    
                    NSString *storeString=[[NSString alloc]initWithFormat:@"%@.plist",self.currentStore.name];;
                    
                    NSString *WorkListFile=[documentsDirectory stringByAppendingPathComponent:storeString];
                    
                    [WorkListDic setValue:@"1" forKey:[[WorkListDic allKeys]objectAtIndex:i ]];
                    
                    [WorkListDic writeToFile:WorkListFile atomically:YES];
                    break;
                }
            }
        }
    }
    
    /*校验数据是否合法*/
    if (![self validateData]) {
        return;
    }
    
    /*requried为R时,表格为必填（至少有一个元素填写）*/
    if (![self isValidateGridRequried]) {
        return;
    }
    
//    if (![self executeValidateLuaScrip]) {
//        return;
//    }
    
    //modify By wangdongyan 2012-02-27 for 当拍多张图片时，可以选择任意一张上传
    if ([self.currentFuncs.opt.isPic isEqualToString:QST_TYPE_R] && [self.photoBrowseView.imageIDArray count] < 1) {
        NSString *TakePhotoString = NSLocalizedString(@"pls_take_photo",nil);
        
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:TakePhotoString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        
        return;
    }
    
    NSString *error = [self checkContentBeforeUpload];
    if (error != nil) {
        NSString *format = NSLocalizedString(@"not_filled", nil);
        NSString *str = [NSString stringWithFormat:format, error];
        
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:str tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"uploading_prompt", nil)  tips:NSLocalizedString(@"please_wait", nil) tapTarget:self action:nil];
    
    [self performSelector:@selector(doUpload) withObject:nil afterDelay:0.01];
    
    
}

- (void)doUpload
{
    NSDate *before = [NSDate date];
    if (![self uploadDatas]) {
        [self showDBErrorTipAndHidAllHud];
        return;
    }
    
    NSDate *after2 = [NSDate date];
    LogInfo(@"uploadDatas耗时：%f秒", [after2 timeIntervalSinceDate:before]);
    if (![self uploadPhotos]) {
        [self showDBErrorTipAndHidAllHud];
        return;
    }
    [super uploadVisitAction];
    NSDate *after3 = [NSDate date];
    LogInfo(@"uploadPhotos耗时：%f秒", [after3 timeIntervalSinceDate:after2]);
    LogInfo(@"doUpload耗时：%f秒", [after3 timeIntervalSinceDate:before]);
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    NSString *tip = NSLocalizedString(@"add_upload_queue", nil);
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tip tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
    
    [self backToParent];
}


- (NSArray *)getImagePathFromDataBase
{
    NSMutableArray *imagePathArray = nil;
    
    NSArray *imageObjectArray = [[WSFdtTable sharedTable] queryFdtImagePathWithStoreId:self.currentStore.Id fc:self.currentFuncs.fc srid:[self getSrid]];
    if (imageObjectArray && [imageObjectArray count] > 0) {
        imagePathArray = [[NSMutableArray alloc] init];
        for (WSImagePathObject *object in imageObjectArray) {
            NSString *imageID = object.img_path;
            if (imageID && [imageID length] > 0) {
                [imagePathArray addObject:imageID];
            }
        }
    }
    
    return imagePathArray;
}
 
-(NSArray*)getDataBaseDatas
{
    NSArray* l_array = [[WSFdtTable sharedTable] queryDictWithStoreId:self.currentStore.Id fc:self.currentFuncs.fc srid:[self getSrid] withMd5:self.md5];
    return l_array;
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

-(NSArray*)getDatasSources
{
    
    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
    NSArray *filterArray = [service queryDictsForAcvtGridWithFilter:self.currentFuncs.filter];
    
    return filterArray;
}

-(NSString*)getDataSourcesWithIndex:(NSNumber*)aIndex Other:(NSArray*)aDicts
{
    WSDictBean* l_dict = [aDicts objectAtIndex:[aIndex intValue]];
    return l_dict.name;
}

-(NSString*)getDataSourcesIdWithIndex:(NSNumber*)aIndex Other:(NSArray*)aDicts
{
    WSDictBean* l_dict = [aDicts objectAtIndex:[aIndex intValue]];
    return l_dict.Id;
}

-(NSString*)getDefaultDataWithParam:(WSFuncsBean_Param*)aParam Others:(WSDictBean*)aDict
{
    if (!aParam.redis || aParam.redis.length==0)
    {
        if (aParam.idefault != nil && [aParam.idefault isKindOfClass:[NSString class]]) {
            return aParam.idefault;
        }else{
           return @"";
        }
    }
    
    if ([WSEnvrionment  getStoreDataFromDb]) {
        WSBaseStoreDictDisTable *baseStoreDictDisTable = [WSBaseStoreDictDisTable sharedTable];
        NSArray *names = @[@"store_id",@"func_code",@"dict_id"];
        NSArray *values = @[[NSString stringNotNilWithValue:self.currentStore.Id],[NSString stringNotNilWithValue:self.currentFuncs.fc],[NSString stringNotNilWithValue:aDict.Id]];
        NSArray *querys = [baseStoreDictDisTable  queryWithNames:names ArgumentsValue:values];
        WSBaseStoreDictDisObject *baseStoreDictDisObject = [querys firstObject];
        
        BOOL hasColProperty = [self getVariableWithClass:[baseStoreDictDisObject class] varName:aParam.col];
        if (hasColProperty) {
            
            /*此处取值不对 先查看下面逻辑 要dictIdAndFC 查找值*/
            return [baseStoreDictDisObject valueForKey:aParam.col];
        }
    }else {
        /*
         内存中取表格回显数据的代码（） 以后删除
         */
        WSStoredDictDisArray *storedDictArray = [WSAppData getObjectbyKey:STOREDICTDIS];
        NSMutableArray *storedictArray = [[NSMutableArray alloc] init];
        for (WSStoredDictDisBean *item in storedDictArray.storedDictDisArray)
        {
            if ([[item.m_p firstObject] isEqualToString:self.currentStore.Id])
            {
                [storedictArray addObject:item];
            }
        }
        NSString *dictIdAndFC = [NSString stringWithFormat:@"%@@%@",aDict.Id,self.currentFuncs.fc];
        for (WSStoredDictDisBean *item in storedictArray)
        {
            if ([[item.m_p objectAtIndex:1] isEqualToString:dictIdAndFC])
            {
                if ([aParam.redis isEqualToString:@"1"])
                {
                    NSInteger index = [[aParam.col stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]] integerValue] + 1;
                    return [item.m_p objectAtIndex:index];
                }
                else
                {
                    NSInteger index = [[aParam.redis stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]] integerValue] + 1;
                    return [item.m_p objectAtIndex:index];
                }
            }
        }
    }
    
    return @"";
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (void)updataButtonTitle
{
    if (self.resonButtons == nil)
        return;
    
    NSMutableDictionary *dicOtherInfo = [self returnDicOtherInfo];
    

    NSString *path = [[NSBundle mainBundle]pathForResource:@"WCOptionalSource" ofType:@"plist"];
    NSDictionary *sourceDic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString *updateType = [sourceDic objectForKey:@"dicttitleupdatetype"];
    if ([updateType isEqualToString:@"photo"]) {
        NSMutableArray *datasArray = [NSMutableArray arrayWithArray:self.datas];
        if (self.abnormalReasonDict)
        {
            [datasArray addObject:self.abnormalReasonDict];
        }
        NSString *postData = [WSJSONBuilder buildDictDetailbyFuncs:self.currentFuncs
                                                         isPhoto:0 datas:datasArray
                                                         dataIDs:self.m_dataSources
                                                           Store:self.currentStore
                                                             md5:@""
                                                            memo:self.memoData
                                                       otherInfo:dicOtherInfo];
        NSDictionary *jsonData = [[postData objectFromJSONString] objectForKey:@"jsonData"];
        NSArray *paramArray = [jsonData objectForKey:@"param"];
        
        for (NSInteger i = 0; i < [paramArray count]; i++)
        {
            NSDictionary *dic = [paramArray objectAtIndex:i];
            NSString *otherdictsDic = [dic objectForKey:@"otherdicts"];
            
            UIButton *button = [self.resonButtons objectAtIndex:i];
            NSInteger num = 0;
            if (otherdictsDic)
            {
                NSString *photoKey = [[otherdictsDic objectFromJSONString] objectForKey:@"photo"];
                if ([button isKindOfClass:[UIButton class]])
                {
                    num = [(NSArray *)[self.photoDataDic objectForKey:photoKey] count];
                }
            }
            
            NSString *title = [NSString stringWithFormat:@"拍照(%ld)", (long)num];
            [button setTitle:title forState:UIControlStateNormal];
            
        }
    }

}

-(UIButton*)setGrideViewDataKindOfBadReason:(WSFuncsBean_Param*)aParam
{
    if([aParam.tpy isEqualToString:COL_TYPBUTTON])
    {
        if (self.resonButtons == nil)
        {
            self.resonButtons = [[NSMutableArray alloc] init];
        }
        WSAcvtButtonForTB *button = [WSAcvtButtonForTB buttonWithType:UIButtonTypeCustom];
        button.layer.cornerRadius = 5.0f;
        button.backgroundColor = [UIColor lightGrayColor];
        button.titleLabel.font = [UIFont systemFontOfSize:12.0f];
//        button.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245/255.0 blue:245/255.0 alpha:1];;
        button.frame = CGRectMake(0, 0, aParam.wcol, 29);
        button.tag = [self getSpecIndexbyParam:aParam];
        [button setTitle:aParam.buttonname forState:UIControlStateNormal];
        [button addTarget:self action:@selector(productReason:) forControlEvents:UIControlEventTouchUpInside];
        
        self.badReasonParam = aParam;
        [self.resonButtons addObject:button];
        return button;
    }
    return nil;
}

-(void)productReason:(id)sender
{
    NSString *filter = self.badReasonParam.filter;

    WSAcvtButtonForTB *button = (WSAcvtButtonForTB *)sender;
    
    WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];
    NSArray *l_acvts = [baseAcvtDBService queryAcvtsWithStoreId:self.currentStore.Id filter:filter];
    
    WSAcvtBean* l_acvt ;
    if([l_acvts count]>0)
        l_acvt = [l_acvts firstObject];
    
    WSAbnormalDetailAcvtViewController* l_avc = [[WSAbnormalDetailAcvtViewController alloc]initWithAcvt:l_acvt Funcs:self.currentFuncs Store:self.currentStore Section:((UIButton *)sender).tag + 1 andIdentify:button.iIdentifyId];
    l_avc.parentGridVC = self;
    l_avc.dictRow = ((UIButton *)sender).tag;
    
    [self.navigationController pushViewController:l_avc animated:YES];
}

#pragma mark - View lifecycle

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
    
    _isFirstLoadView = YES;

}

- (void)setFuncsOtherBeanViewData
{
    //回显other数据
    WSFdtObject *object = nil;
    if ([self.currentFuncs.otherArray count]) {
        object = [[[WSFdtTable sharedTable] queryFdtWithStoreId:self.currentStore.Id fc:self.currentFuncs.fc srid:[self getSrid]] firstObject ];
    }
    if(object){
        for (int i = 0; i < [self.currentFuncs.otherArray count]; i++) {
            WSFuncsBean_other *other = [self.currentFuncs.otherArray objectAtIndex:i];
            if (([other.tpy isEqualToString:OTHER_TPY_N] || [other.tpy isEqualToString:OTHER_TPY_T]) &&
                [other.col hasPrefix:@"memo"]) {
                
                UIView *infoView = [self.view viewWithTag:(OTHER_TEXTFIELD_TAG + i)];
                if ([infoView isKindOfClass:[UITextField class]]) {
                    UITextField *field = (UITextField *)infoView;
                    NSString *value = [object valueForKey:other.col];
                    if ([value isKindOfClass:[NSString class]]) {
                        field.text = value;
                    }
                }else if ([infoView isKindOfClass:[UITextView class]]) {
                    UITextView *textView = (UITextView *)infoView;
                    NSString *value = [object valueForKey:other.col];
                    if ([value isKindOfClass:[NSString class]]) {
                        textView.text = value;
                    }
                }
            }
            else if ([other.tpy isEqualToString:OTHER_TPY_C] && [other.col hasPrefix:@"memo"])
            {
                NSString *value = [object valueForKey:other.col];
                
                
                WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
                NSArray *dictBeanArray = [service queryDictsForAcvtGridWithFilter:other.filter];
                
                for (NSInteger optionIndex = 0; optionIndex < dictBeanArray.count; optionIndex++ ){
                    WSDictBean* option_temp = [dictBeanArray objectAtIndex:optionIndex];
                    if([value rangeOfString:option_temp.Id].location !=NSNotFound){
                        UIView  *option_btn = [self.view viewWithTag:5000+optionIndex*1000];
                        UIButton* option_btn_=(UIButton*)option_btn;
                        option_btn_.selected=YES;
                    }
                }
            }
        }
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updataButtonTitle];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_isFirstLoadView) {
        CGFloat storeNameLabelHeight =  INTERFACE_IS_PHONE ? self.storeNameLabel.height : 0;
        
        [self reDrawGrideWithHeight:self.view.bounds.size.height -  SPACEHEIGTH - storeNameLabelHeight];
        [self setFuncsOtherBeanViewData];
        
        _isFirstLoadView = NO;
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    NSLog(@"%d---%s", __LINE__, __FUNCTION__);
}


#pragma mark - add by wxt
#pragma mark - add wxt
- (NSString *)getIdentifyFromData:(WSDictBean *)aData
{
    return aData.Id;
}

- (BOOL)shouldCustomInteractivePopGestureRecognizerDelegate
{
    return YES;
}

- (BOOL)shouldPauseBackAction
{
    if ([self respondsToSelector:@selector(isValueChange)]) {
        if ([self performSelector:@selector(isValueChange)]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)backAction {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    if ([self respondsToSelector:@selector(isValueChange)] && !self.currentStore.inReadonlyMode) {
        if ([self performSelector:@selector(isValueChange)]) {
            
            BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"back_confirm2", nil)];
            
            [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:nil];
            [alert addButtonWithTitle:NSLocalizedString(@"upload_label", nil) block:^{
                [self upload];
            }];
            [alert addButtonWithTitle:NSLocalizedString(@"give_up", nil) block:^{
                [self.navigationController popViewControllerAnimated:YES];
                
            }];
            [alert show];
            return;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark alert Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (alertView == _datasChangeAlertView)
    {
        switch (buttonIndex)
        {
            case 0:
                
                break;
            case 1:
                [self upload];
                break;
            case 2:
                [self.navigationController popViewControllerAnimated:YES];
                break;
            default:
                break;
        }
    }
}


@end

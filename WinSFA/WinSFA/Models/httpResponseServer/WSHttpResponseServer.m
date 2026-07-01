//
//  HttpResponseServer.m
//  WinChannelFrameWork
//
//  Created by Zheng Jiepeng on 12-12-31.
//
//

#import "WSHttpResponseServer.h"
#import "WSCurrentTime.h"
#import "WSAddStoreTable.h"
#import "WSFacTable.h"

@implementation WSHttpResponseServer

- (BOOL)dealWithResponse:(NSDictionary*)resposeDataDictionary localInfo:(WCBaseRequestLocalInfo *)localInfo
{
    switch (localInfo.uploadType)
    {
        case WCDatasUploadTypeAddNewStore:
            [self dealWithAddNewStoreRespose:resposeDataDictionary localInfo:localInfo];
            break;
            
        case WCDatasUploadTypeModifyAddedNewStore:
            [self dealWithModifyAddedNewStoreRespose:resposeDataDictionary localInfo:localInfo];
            break;
        case WCDatasUploadTypeAddAcvt:
            [self dealWithModifyAddedAcvtRespose:resposeDataDictionary localInfo:localInfo];
            break;
        default:
            break;
    }
    return TRUE;
}

// ------------------------ WCDatasUploadTypeAddNewStore ------------------------
- (void)dealWithModifyAddedAcvtRespose:(NSDictionary*)resposeDataDictionary localInfo:(WCBaseRequestLocalInfo *)localInfo
{
    
    NSString *resultStr = [resposeDataDictionary objectForKey:@"result"];
        
    BOOL isSuccess = NO;
    
    NSArray *namesArray;
    NSArray *valuesArray;
    
    if ([resultStr isEqualToString:@"1"] || [resultStr isEqualToString:@"0"]) {
        
        NSString *uploadFlag;
        
        if ([resultStr isEqualToString:@"1"]) {
            uploadFlag = [[NSNumber numberWithInteger:WCDatasUploadStatusSuccess] stringValue];
            isSuccess = YES;
        }else if ([resultStr isEqualToString:@"0"]) {
            uploadFlag = [[NSNumber numberWithInteger:WCDatasUploadStatusInvaild] stringValue];
        }
        
        namesArray = [NSArray arrayWithObjects:@"UPLOAD_FLAG", nil];
        valuesArray = [NSArray arrayWithObjects:uploadFlag, nil];
        
        
    }else {
        
        NSDictionary *resultDictioary = [resultStr objectFromJSONString];
        NSString *flag = [NSString stringWithValue:[resultDictioary objectForKey:@"flag"]];
        if ([flag isEqualToString:@"1"]) {
            
            isSuccess = YES;
            
            NSString *newStoreId = [NSString stringWithValue:[resultDictioary objectForKey:@"storeId"]];
            
            if ([newStoreId length] > 0) {
                namesArray = [NSArray arrayWithObjects:@"UPLOAD_FLAG",@"acvt_newStoreId", nil];
                valuesArray = [NSArray arrayWithObjects:[[NSNumber numberWithInteger:WCDatasUploadStatusSuccess] stringValue],[NSString stringNotNilWithValue:newStoreId],nil];
            }else {
                namesArray = [NSArray arrayWithObjects:@"UPLOAD_FLAG", nil];
                valuesArray = [NSArray arrayWithObjects:[[NSNumber numberWithInteger:WCDatasUploadStatusSuccess] stringValue], nil];
            }

        }else {
            
            namesArray = [NSArray arrayWithObjects:@"UPLOAD_FLAG", nil];
            valuesArray = [NSArray arrayWithObjects:[[NSNumber numberWithInteger:WCDatasUploadStatusInvaild] stringValue], nil];

        }
    }
    
    
//    NSArray *whereNamesArray = [NSArray arrayWithObjects:@"EMP_ID",@"MD5", nil];
//    NSArray *whereValuesArray = [NSArray arrayWithObjects:[resposeDataDictionary objectForKey:@"empId"],localInfo.m_identifiter, nil];
    
//    [[WSAddAcvtTable sharedTable] updateWithNames:namesArray values:valuesArray whereName:whereNamesArray whereValue:whereValuesArray];
    
//    if (isSuccess) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:NEWADDACVTSUCCEED object:nil];
//    }
}

- (void)dealWithAddNewStoreRespose:(NSDictionary*)senderDictionary localInfo:(WCBaseRequestLocalInfo *)localInfo
{
    LogTrace();
    NSString *flag = nil;
    NSString *storeid = nil;
   
    NSString *resultString = nil;
    NSString *temp = [senderDictionary objectForKey:@"result"];
    resultString = temp;
    
    LogInfo(@"resultString = %@", resultString);
    
    // time update
    NSString *timeupdate = [senderDictionary objectForKey:@"timeUpdate"];
    if (timeupdate == nil)
    {
        timeupdate = [WSCurrentTime getDateTime];
    }
    else
    {
        NSDateFormatter* formatTime = [NSDateFormatter standardDateFormatter];
        [formatTime setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        double timeval = [timeupdate doubleValue] / 1000;
        timeupdate = [formatTime stringFromDate: [NSDate dateWithTimeIntervalSince1970: timeval]];
    }
    
    if (resultString && [resultString isEqualToString:@"0"]) {
        //！！问卷数据库表重构，与Android保持一致逻辑，去除WSAddStoreTable表，统一使用visit_store_acvt_data,以下逻辑应该不需要了。
        
//        NSArray* setnames = [[NSArray alloc] initWithObjects:@"UPLOAD_DATE", @"UPLOAD_FLAG", nil];
//        NSArray* setvalues = [[NSArray alloc] initWithObjects:timeupdate, [NSNumber numberWithInteger:WCDatasUploadStatusInvaild], nil];
//        NSArray* wherenames = [[NSArray alloc] initWithObjects:@"UPDATE_MD5ID", nil];
//        NSString* nid = [NSString stringWithValue: localInfo.m_identifiter];
//        NSArray* wherevalues = [[NSArray alloc] initWithObjects:nid, nil];
//        [[WSAddStoreTable sharedTable] updateWithNames:setnames values:setvalues whereName:wherenames whereValue:wherevalues];
        // show message
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"fail_upload",nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }else if (resultString && [resultString isEqualToString:@"1"]) {
        //update

//        NSArray* setnames = [[NSArray alloc] initWithObjects:@"UPLOAD_DATE", @"UPLOAD_FLAG",nil];
//        NSArray* setvalues = [[NSArray alloc] initWithObjects:timeupdate, [NSNumber numberWithInteger:WCDatasUploadStatusSuccess],nil];
//        NSArray* wherenames = [[NSArray alloc] initWithObjects:@"UPDATE_MD5ID", nil];
//        NSString* nid = [NSString stringWithValue: localInfo.m_identifiter];
//        NSArray* wherevalues = [[NSArray alloc] initWithObjects:nid, nil];
//        [[WSAddStoreTable sharedTable] updateWithNames:setnames values:setvalues whereName:wherenames whereValue:wherevalues];
        
    }else {

        // 三棵树/STD(标准)上传成功返回数据中flag的值为1(NSNumber类型)
        NSDictionary *resultDictioary = [resultString objectFromJSONString];
        flag = [NSString stringWithFormat:@"%@",[resultDictioary objectForKey:@"flag"]];
        storeid = [resultDictioary objectForKey:@"storeId"];
        if ([storeid isKindOfClass:[NSNumber class]]) {
            storeid = [[resultDictioary objectForKey:@"storeId"] stringValue];
        }
//        NSString *storeName = [resultDictioary objectForKey:@"name"];
        // 新增门店显示时候去掉Code
        // 在新增门店的时候。
        // 根据服务器返回的addtype决定是否新增即拜访(立即可以在计划外拜访)
        // 若 addType = @"5",则新增即拜访（进主数据）,
        // 若 addType = @"6" 则新增不立即拜访（不进主数据）
//        NSString *addType = [resultDictioary objectForKey:@"addtype"];
        
        
        // 要增加门店类型(storeType)字段
        NSString *storeType = [resultDictioary objectForKey:@"type"];
        if (!storeType)
        {
            LogInfo(@"新增门店，服务器返回门店类型为空");
        }
        /*!
         *  非常重要！不可删除
         *  为中粮稽核暂时回滚到之前的新增逻辑
         */
        //    NSDictionary *resultDic = [resultString objectFromJSONString];
        //
        //    flag = [NSString stringWithValue:[resultDic objectForKey:@"flag"]];
        //    flag = (flag ? flag : @"0");
        //
        //    storeid = [NSString stringWithValue:[resultDic objectForKey:@"storeId"]];
        //
        //    storeName = [NSString stringWithValue:[resultDic objectForKey:@"name"]];
        
        if(storeid == nil)
        {
            storeid = localInfo.m_identifiter;
        }
        if ([flag isEqualToString:@"1"])
        {
            //！！问卷数据库表重构，与Android保持一致逻辑，去除WSAddStoreTable表，统一使用visit_store_acvt_data,以下逻辑应该不需要了。
//            /*
//             Because some old project don't return store id. like xmlt, so do this.
//             May be it will generate errors
//             */
//            NSString* nid = [NSString stringWithValue: localInfo.m_identifiter];
//            /*增加更新WSAddStoreTable表的对应的店的信息的条件，
//             1. STORE_ID 与 UPDATE_MD5ID一致的。
//             2. STORE_ID 没有值
//             */
//            NSArray *storesArray = [[WSAddStoreTable sharedTable] queryWithNames:@[@"UPDATE_MD5ID"] ArgumentsValue:@[nid]];
//            WSAddStoreObject *addStoreObject = (WSAddStoreObject *)[storesArray firstObject];
//            BOOL allowUpdate = NO;
//            if (addStoreObject
//                && (addStoreObject.store_id && [addStoreObject.store_id length] > 0)
//                && (nid && [nid length] > 0)
//                && [addStoreObject.store_id isEqualToString:nid]) {
//                allowUpdate = YES;
//            }
//            
//            if (addStoreObject
//                && (!addStoreObject.store_id || [addStoreObject.store_id length] < 1)){
//                allowUpdate = YES;
//            }
//            allowUpdate=YES;
//            
//            if (allowUpdate) {
//                LogInfo(@"dealWithAddNewStoreRespose old storeid = %@  new storeid = %@" , addStoreObject.store_id , storeid);
//                //update
//                NSArray* setnames = [[NSArray alloc] initWithObjects:@"UPLOAD_DATE", @"UPLOAD_FLAG", @"STORE_ID", @"STORE_NAME",@"STORE_TYPE",@"ADD_TYPE",nil];
//                NSArray* setvalues = [[NSArray alloc] initWithObjects:timeupdate, [NSNumber numberWithInteger:WCDatasUploadStatusSuccess],[NSString stringNotNilWithValue:storeid],[NSString stringNotNilWithValue:storeName],[NSString stringNotNilWithValue:storeType],[NSString stringNotNilWithValue:addType] ,nil];
//                NSArray* wherenames = [[NSArray alloc] initWithObjects:@"UPDATE_MD5ID", nil];
//                NSString* nid = [NSString stringWithValue: localInfo.m_identifiter];
//                NSArray* wherevalues = [[NSArray alloc] initWithObjects:nid, nil];
//                
//                if ([[WSAddStoreTable sharedTable] updateWithNames:setnames values:setvalues whereName:wherenames whereValue:wherevalues]) {
//                    
//                    [[WSFacTable sharedTable] upadteAcvtInfo: localInfo.m_identifiter andStoreId:[NSString stringNotNilWithValue:storeid]];
//                }
//            }
            
        }
        else
        {
            //！！问卷数据库表重构，与Android保持一致逻辑，去除WSAddStoreTable表，统一使用visit_store_acvt_data,以下逻辑应该不需要了。
//            NSArray* setnames = [[NSArray alloc] initWithObjects:@"UPLOAD_DATE", @"UPLOAD_FLAG", @"STORE_ID",@"STORE_TYPE", nil];
//            NSArray* setvalues = [[NSArray alloc] initWithObjects:timeupdate, [NSNumber numberWithInteger:WCDatasUploadStatusInvaild], storeid,[NSString stringNotNilWithValue:storeType], nil];
//            NSArray* wherenames = [[NSArray alloc] initWithObjects:@"UPDATE_MD5ID", nil];
//            NSString* nid = [NSString stringWithValue: localInfo.m_identifiter];
//            NSArray* wherevalues = [[NSArray alloc] initWithObjects:nid, nil];
//            [[WSAddStoreTable sharedTable] updateWithNames:setnames values:setvalues whereName:wherenames whereValue:wherevalues];
            // show message
            //MN-3266 2018-07-14
            if(resultString == nil || resultString.length <= 0)
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"fail_upload", nil) tips:nil tapTarget:nil
                                       action:nil type:MBProgressHUDMessageTypeFailed];
        }
    }
    //  SFA 项目 SFA-5682   注释 在WSAddNewStoreViewController 里 发通知
//    [[NSNotificationCenter defaultCenter] postNotificationName:newStoreNotification object:nil];
}

// ------------------------ WCDatasUploadTypeModifyAddedNewStore ------------------------
- (void)dealWithModifyAddedNewStoreRespose:(NSDictionary*)senderDictionary localInfo:(WCBaseRequestLocalInfo *)localInfo
{
//    NSString *flag = nil;
//    NSString *storeid = nil;
    NSLog(@"senderDictionary: %@", senderDictionary);
    
    NSString *resultString = nil;
    NSString *temp = [senderDictionary objectForKey:@"result"];
    resultString = temp;
    
    NSLog(@"resultString = %@", resultString);
    
    NSString *timeupdate = [senderDictionary objectForKey:@"timeUpdate"];
    if (timeupdate == nil)
    {
        timeupdate = [WSCurrentTime getDateTime];
    }
    else
    {
        NSDateFormatter* formatTime = [NSDateFormatter standardDateFormatter];
        [formatTime setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        double timeval = [timeupdate doubleValue] / 1000;
        timeupdate = [formatTime stringFromDate: [NSDate dateWithTimeIntervalSince1970: timeval]];
    }
    
    if (resultString && [resultString isEqualToString:@"0"]) {
        //！！问卷数据库表重构，与Android保持一致逻辑，去除WSAddStoreTable表，统一使用visit_store_acvt_data,以下逻辑应该不需要了。
//        NSArray* setnames = [[NSArray alloc] initWithObjects:@"UPLOAD_FLAG", nil];
//        NSArray* setvalues = [[NSArray alloc] initWithObjects:[NSNumber numberWithInteger:WCDatasUploadStatusFail], nil];
//        NSArray* wherenames = [[NSArray alloc] initWithObjects:@"UPDATE_MD5ID", @"UPLOAD_FLAG", nil];
//        NSString* nid = [NSString stringWithValue: localInfo.m_notify];
//        NSArray* wherevalues = [[NSArray alloc] initWithObjects:nid, [NSNumber numberWithInteger:WCDatasUploadStatusUploading], nil];
//        [[WSAddStoreTable sharedTable] updateWithNames:setnames values:setvalues whereName:wherenames whereValue:wherevalues];
        
        
        // show message
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"fail_upload", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
    else if (resultString && [resultString isEqualToString:@"1"]) {
        //！！问卷数据库表重构，与Android保持一致逻辑，去除WSAddStoreTable表，统一使用visit_store_acvt_data,以下逻辑应该不需要了。
        //update
//        NSArray* setnames = [[NSArray alloc] initWithObjects:@"UPLOAD_DATE", @"UPLOAD_FLAG",nil];
//        NSArray* setvalues = [[NSArray alloc] initWithObjects:timeupdate, [NSNumber numberWithInteger:WCDatasUploadStatusSuccess],nil];
//        NSArray* wherenames = [[NSArray alloc] initWithObjects:@"UPDATE_MD5ID", nil];
//        NSString* nid = [NSString stringWithValue: localInfo.m_identifiter];
//        NSArray* wherevalues = [[NSArray alloc] initWithObjects:nid, nil];
//        [[WSAddStoreTable sharedTable] updateWithNames:setnames values:setvalues whereName:wherenames whereValue:wherevalues];
        
    }
    else {

        //！！问卷数据库表重构，与Android保持一致逻辑，去除WSAddStoreTable表，统一使用visit_store_acvt_data,以下逻辑应该不需要了。
        
//        NSDictionary *resultDictioary = [resultString objectFromJSONString];
//        flag = [NSString stringWithFormat:@"%@",[resultDictioary objectForKey:@"flag"]];
//        storeid = [resultDictioary objectForKey:@"storeId"];
//        if ([storeid isKindOfClass:[NSNumber class]]) {
//            storeid = [[resultDictioary objectForKey:@"storeId"] stringValue];
//        }
//        NSString *storeName = [resultDictioary objectForKey:@"name"];
//        NSString *addType = [resultDictioary objectForKey:@"addtype"];
//        
//        NSString *storeType = [resultDictioary objectForKey:@"type"];
//        if (!storeType)
//        {
//            LogError(@"新增门店，服务器返回门店类型为空");
//        }
//        
//        if ([flag isEqualToString:@"1"])
//        {
//            /*
//             Because some old project don't return store id. like xmlt, so do this.
//             May be it will generate errors
//             */
//            //update
//            NSArray* setnames = [[NSArray alloc] initWithObjects:@"UPLOAD_DATE", @"UPLOAD_FLAG", @"STORE_ID", @"STORE_NAME",@"STORE_TYPE",@"ADD_TYPE",nil];
//            NSArray* setvalues = [[NSArray alloc] initWithObjects:timeupdate, [NSNumber numberWithInteger:WCDatasUploadStatusSuccess],[NSString stringNotNilWithValue:storeid],[NSString stringNotNilWithValue:storeName],[NSString stringNotNilWithValue:storeType],[NSString stringNotNilWithValue:addType] ,nil];
//            NSArray* wherenames = [[NSArray alloc] initWithObjects:@"UPDATE_MD5ID", nil];
//            NSString* nid = [NSString stringWithValue: localInfo.m_identifiter];
//            NSArray* wherevalues = [[NSArray alloc] initWithObjects:nid, nil];
//            [[WSAddStoreTable sharedTable] updateWithNames:setnames values:setvalues whereName:wherenames whereValue:wherevalues];
//            [[WSFacTable sharedTable] upadteAcvtInfo: localInfo.m_identifiter andStoreId:[NSString stringNotNilWithValue:storeid]];
//        
//            /*更新WSAddAcvtTable 适用对店的新增门店（史克医院）*/
//            NSArray *wNames = @[@"md5"];
//            NSArray *wValues = @[localInfo.m_identifiter];
//            NSArray *sNames = @[@"upload_flag"];
//            NSArray *sValue = @[@"1"];
//            [[WSAddAcvtTable sharedTable] updateWithNames:sNames values:sValue whereName:wNames whereValue:wValues];
//        }
//        else
//        {
//            NSArray* setnames = [[NSArray alloc] initWithObjects:@"UPLOAD_FLAG", nil];
//            NSArray* setvalues = [[NSArray alloc] initWithObjects:[NSNumber numberWithInteger:WCDatasUploadStatusFail], nil];
//            NSArray* wherenames = [[NSArray alloc] initWithObjects:@"UPDATE_MD5ID", @"UPLOAD_FLAG", nil];
//            NSString* nid = [NSString stringWithValue: localInfo.m_notify];
//            NSArray* wherevalues = [[NSArray alloc] initWithObjects:nid, [NSNumber numberWithInteger:WCDatasUploadStatusUploading], nil];
//            [[WSAddStoreTable sharedTable] updateWithNames:setnames values:setvalues whereName:wherenames whereValue:wherevalues];
//            
//            // show message
//            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"fail_upload", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
//        }
    }
    

//    [[NSNotificationCenter defaultCenter] postNotificationName:newStoreNotification object:nil];
}

@end

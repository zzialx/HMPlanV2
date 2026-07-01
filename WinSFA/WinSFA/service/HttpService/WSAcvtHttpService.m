//
//  WSAcvtHttpService.m
//  WinSFA
//
//  Created by yang on 15/12/22.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSAcvtHttpService.h"
#import "WSRequestHelper.h"
#import "WSStoreDataProcessService.h"
#import "WSStoreAcvtDisBean.h"
#import "WSBaseAcvtdisDBService.h"

#define kWSAcvtHttpServiceNotifyName @"kWSAcvtHttpServiceNotifyName"

@interface WSAcvtHttpService ()

@property (nonatomic, copy) WSAcvtHttpServiceCompletionBlock completionBlock;

@end

@implementation WSAcvtHttpService

- (void)dealloc
{
    NSLog(@"%@ dealloc", [self class]);
}

- (NSString *)getEmpID
{
    if ([self.jsEmpID length] > 0) {
        return self.jsEmpID;
    }
    
    return [super getEmpID];
    
}

- (NSString *)getObjID
{
    //参考Androidl逻辑如下：
//    if (StringUtils.isNotBlank(mEditObjId)) {
//        return mEditObjId;
//    }
//    if (mPosId != -1) {
//        return StoreRealtimeDataManager. ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME;
//    }
//    String objId = AcvtManager.getAcvtNodeByGenId(mGenId);
//    if (!StringUtils.isNotBlank(objId)) {
//        objId = ServerNode.STORE_ACVT_DIS;
//    }
    
    if ([self.objID length] > 0) {
        return self.objID;
    }
    
    if ([self.storeBean.Id length] > 0) {
        return  ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME;
    }
    
    //String objId = AcvtManager.getAcvtNodeByGenId(mGenId); 暂不实现
    
    return STOREACVTDIS;
}

- (NSDictionary *)getParametersDic
{
    //参考Androidl逻辑如下：
//    showProgressDialog(R.string.stockprice_prompt_loading_message, null);
//    mNetworkManagerLock = NetworkManager.getInstance();
//    mNetworkManagerLock.setListener(mReqCodeLock, mLockListener);
//    JSONObject json = new JSONObject();
//    try {
//        mEditObjId = getEditObjid();
//        if (mPosId == -1) {
//            json.put("genId", mGenId);
//        } else {
//            json.put(Constants.JSON_STORE, mPosId + "");
//            json.put(Constants.JSON_STORE_ID, mPosId + "");
//            json.put("orderCode", mGenId);
//        }
//        json.put("objId", mEditObjId);
//        json.put("empId", getPageEmpId());
//        BaseStore mBaseStore = VisitInOutStoreManager.getNewStoreByGenId(mGenId);
//        if (mBaseStore == null) {
//            mBaseStore = AcvtQstManager.getNewAcvtStore(mGenId);
//        }
//        if (mBaseStore != null) {
//            json.put("newStoreId", mBaseStore.mId);
//        }
//    } catch (JSONException e) {
//        e.printStackTrace();
//    }
//    String mUpdateUrl = BaseManager.getUpdateUri();
//    mNetworkManagerLock.sendInfo(mReqCodeLock, mUpdateUrl, json.toString());
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    if ([self.storeBean.Id length] > 0) {
        [dic setObject:self.storeBean.Id forKey:JSON_STORE];
        [dic setObject:self.storeBean.Id forKey:JSON_STOREID];
        if (self.genID) {
            [dic setObject:self.genID forKey:JSON_ORDER_CODE];
            [dic setObject:self.genID forKey:JSON_GENID];
        }
    }else {
        if (self.genID) {
            [dic setObject:self.genID forKey:JSON_GENID];
        }
    }
    if (self.acvtBean && [self.acvtBean acvtId].length > 0) {
        [dic setObject:[self.acvtBean acvtId] forKey:@"extra_acvtId"];
    }

    
    [dic setObject:[self getObjID] forKey:JSON_OBJID];
    [dic setObject:[self getEmpID] forKey:JSON_EMPID];
    
    return dic;
    
}

- (void)getAcvtDataWithCompletionBlock:(WSAcvtHttpServiceCompletionBlock)completionBlock
{
    self.completionBlock = completionBlock;
    
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    
    [uploadMgr postRequestData:[self getParametersDic] notifyName:kWSAcvtHttpServiceNotifyName];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishRequest:)
                                                 name:kWSAcvtHttpServiceNotifyName
                                               object:nil];
}


-(void)finishRequest:(NSNotification *)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kWSAcvtHttpServiceNotifyName object:nil];
    
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error)
    {
        self.completionBlock(nil,error);
        return;
    }
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSDictionary  *dataDic = [info objectFromJSONString];
    
    if([dataDic objectForKey:STOREACVTDIS]) //对店
    {
        WSBaseAcvtdisDBService *baseAcvtDisSerice = [[WSBaseAcvtdisDBService alloc] init];
        [baseAcvtDisSerice replaceToTableWithDicts:[dataDic objectForKey:STOREACVTDIS] FromNode:STOREACVTDIS hasNewData:YES storeID:self.storeBean.Id genId:self.genID];
    }
    else if([dataDic objectForKey:ACVTDIS]) //对人
    {
        WSBaseAcvtdisDBService *baseAcvtDisSerice = [[WSBaseAcvtdisDBService alloc] init];
        [baseAcvtDisSerice replaceToTableWithDicts:[dataDic objectForKey:ACVTDIS] FromNode:ACVTDIS hasNewData:YES storeID:self.storeBean.Id genId:self.genID];
    }
    else if([dataDic objectForKey: ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME])
    {
        NSObject *tmpObject = [dataDic objectForKey: ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME];
        NSDictionary *storeDicInfo = nil;
        if ([tmpObject isKindOfClass:[NSDictionary class]]) {
            storeDicInfo = (NSDictionary *)tmpObject;
        }else if ([tmpObject isKindOfClass:[NSArray class]]) {
            storeDicInfo = [(NSArray *)tmpObject firstObject];
        }
        [WSStoreDataProcessService processStoreInfoDataToDbWith:self.storeBean info:storeDicInfo genId:self.genID];
    }
    else if ([dataDic objectForKey:[self objID]])
    {
        if ([[self objID] hasPrefix:ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME])
        {
            NSObject *tmpObject = [dataDic objectForKey:[self objID]];
            NSDictionary *storeDicInfo = nil;
            if ([tmpObject isKindOfClass:[NSDictionary class]])
                storeDicInfo = (NSDictionary *)tmpObject;
            else if ([tmpObject isKindOfClass:[NSArray class]])
                storeDicInfo = [(NSArray *)tmpObject firstObject];
            
            [self.storeBean reSetStore:dataDic Key:[self objID]];
            [WSStoreDataProcessService processStoreInfoDataToDbWith:self.storeBean info:storeDicInfo genId:self.genID];
        }
        else if([[self objID] hasPrefix:ACVTDIS])
        {
            WSBaseAcvtdisDBService *baseAcvtDisSerice = [[WSBaseAcvtdisDBService alloc] init];
            [baseAcvtDisSerice replaceToTableWithDicts:[dataDic objectForKey:[self objID]] FromNode:[self objID] hasNewData:YES storeID:self.storeBean.Id genId:self.genID];
        }
        else
        {
            NSObject *tmpObject = [dataDic objectForKey:[self objID]];
            NSDictionary *storeDicInfo = nil;
            if ([tmpObject isKindOfClass:[NSDictionary class]])
                storeDicInfo = (NSDictionary *)tmpObject;
            else if ([tmpObject isKindOfClass:[NSArray class]])
                storeDicInfo = [(NSArray *)tmpObject firstObject];
            
            [self.storeBean reSetStore:dataDic Key:[self objID]];
            [WSStoreDataProcessService processStoreInfoDataToDbWith:self.storeBean info:storeDicInfo genId:self.genID];
        }
    }
    
    self.completionBlock(dataDic, nil);
}

@end

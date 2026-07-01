//
//  WSStoreDataService.m
//  WinSFA
//
//  Created by mac on 17/6/29.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSStoreDataService.h"
#import "WSBaseStoreDBService.h"
#import "NSArray+SQL.h"

@interface WSStoreDataService ()

@property (nonatomic, strong) WSLocationDescribe *locationDescribe;
@property (nonatomic, copy) NSString *subEmpId;
@property (nonatomic, copy) NSString    *objID;
@property (nonatomic, strong) WSFuncsBean *currentFuncs;

@end

@implementation WSStoreDataService

static WSStoreDataService *storeDataService = nil;

+(instancetype)shareInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storeDataService = [[WSStoreDataService alloc] init];
    });
    
    return storeDataService;
}

-(BOOL)updateStoreTableWithStoreArray:(NSArray *)storeArray locationDescribe:(WSLocationDescribe *)locationDescribe FC:(NSString *)funcCode{
    
    NSString * locationString =[NSString stringWithFormat:@"%f,%f",locationDescribe.location.coordinate.latitude, locationDescribe.location.coordinate.longitude];
    NSMutableDictionary * locationDic = [[[NSUserDefaults standardUserDefaults] objectForKey:LAST_UPDATE_LOCATION_MESSAGE] mutableCopy];
    if (!locationDic || [locationDic isKindOfClass:[NSString class]]) {
        locationDic = [[NSMutableDictionary alloc]init];
    }
    [locationDic setObject:locationString forKey:funcCode];
    
    [[NSUserDefaults standardUserDefaults] setObject:locationDic forKey:LAST_UPDATE_LOCATION_MESSAGE];
    [[NSUserDefaults standardUserDefaults] synchronize];

//    NSMutableArray * updateSqlArray = [NSMutableArray arrayWithCapacity:storeArray.count];
    NSString *sqlstrings = @"UPDATE ws_base_store_table SET distances = CASE store_Id";
    NSArray *sidArray =  [storeArray valueForKeyPath:@"Id"];
    for (WSStoreBean * tempStore in storeArray) {
        if (locationDescribe && tempStore.latitude >0 && tempStore.longitude > 0) {
            @autoreleasepool {
                CLLocation * storeLocation = [[CLLocation alloc]initWithLatitude:tempStore.latitude longitude:tempStore.longitude];
                double f_distance= [[WSLocationManager getInstance] distanceUserLocattion:locationDescribe.location fromStoreLocation:storeLocation];
                NSString * distance = [NSString stringWithFormat:@"%.0f",f_distance];
//                NSString * sqlString = [NSString stringWithFormat:@"UPDATE ws_base_store_table SET distances = '%@' WHERE store_Id = '%@' ",distance,tempStore.Id];
//                [updateSqlArray addObject:sqlString];
                sqlstrings = [sqlstrings stringByAppendingFormat:@" WHEN '%@' THEN '%@' ",tempStore.Id,distance];

            }
            
        }
        
    }
    
    //  YIHAIKERRY-3616
    // SFA 益海嘉里-传统渠道【200家门店列表】门店下载中心下载4w家门店后，返回门店列表，门店列表更新缓慢（超过10秒），需要优化
    sqlstrings = [NSString stringWithFormat:@" %@ END WHERE store_Id %@ ", sqlstrings, [sidArray getInSqlString]]; //批量处理更新距离 ，用一句SQL执行
    
    BOOL isSuccess = YES;
    
    if (sidArray.count > 0) {
        isSuccess = [[[WSSqliteUtil alloc]init] executeUpdateWithSqls:@[sqlstrings]];
        if (!isSuccess) {
            LogError(@"计算距离插入数据库失败");
        }else{
            LogInfo(@"计算距离插入数据库成功");
        }
    }
    return isSuccess;

}

-(BOOL)isNeedUpdateStoreDistanceWith:(WSLocationDescribe *)locationDescribe {
    // YIHAIKERRY-2098 与安卓统一，新增门店后如果不刷新会导致新增的门店没有距离
    return YES;
    
    /*
    // 上一次记录的位置
//    NSString * locationString =  [[NSUserDefaults standardUserDefaults] objectForKey:LAST_UPDATE_LOCATION_MESSAGE];
    NSDictionary * locationDic = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_UPDATE_LOCATION_MESSAGE];
    NSString * locationString ;
    if ([locationDic isKindOfClass:[NSDictionary class]]) {
        locationString = [locationDic objectForKey:funcCode];
    }
    // 没有位置 则需要更新
    if (locationString.length == 0) {
        return YES;
    }
    
    NSArray * locationArray = [locationString componentsSeparatedByString:@","];
    NSString * lat = locationArray[0];
    NSString * lon = locationArray[1];
    
    CLLocation *   location = [[CLLocation alloc]initWithLatitude:[lat doubleValue] longitude:[lon doubleValue]];
    
    if (location) {
        CLLocationDistance distance = [location distanceFromLocation:locationDescribe.location];
        if (distance > ENTER_STORE_VALID_DISTANCE) {
            return YES;
        }
    }
    
    return NO;
     */
}

- (void)locationFinished:(NSNotification *)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:locationAddressManagerDidUpdatedFinishedNotification object:nil];
    
    NSDictionary *userInfo = [sender userInfo];
    
    NSError *error = [userInfo objectForKey:locationAddressManagerDidUpdatedFinishedNotificationErrorKey];
    WSLocationDescribe *tmpLocationDescribe = [userInfo objectForKey:locationAddressManagerDidUpdatedFinishedKey];
    
    if (error) {
        LogError(@"（WSStoreDataService）定位失败：checkAndUpdateStoreDistanceWithCurrentFuncs--------计算距离插入数据库失败");
        if (self.updateFinishBlock)
        {
            self.updateFinishBlock(self.locationDescribe,NO);
            self.updateFinishBlock = nil;
        }
    }else{
        LogInfo(@"（WSStoreDataService）定位成功：aLocationDescribe=====%@",tmpLocationDescribe);
        if (tmpLocationDescribe.location && (tmpLocationDescribe.location.coordinate.longitude != 0 && tmpLocationDescribe.location.coordinate.latitude != 0)) {
            self.locationDescribe = tmpLocationDescribe;
            
            if ([self isNeedUpdateStoreDistanceWith:tmpLocationDescribe]) {
                [self updateStoreListWithDistanceToDBWithCurrentFuncs:self.currentFuncs];
            }
            //SFA-14575 2017-11-29
            else{
                if (self.updateFinishBlock)
                {
                    self.updateFinishBlock(self.locationDescribe,NO);
                    self.updateFinishBlock = nil;
                }
            }
        }
    }
    
}



- (void)checkAndUpdateStoreDistanceWithCurrentFuncs:(WSFuncsBean *)currentFuncs andSubEmpId:(NSString *)subEmpId andObjectId:(NSString *)objID withBlock:(updateFinish)updateFinishBlock
{
    
    DDLogInfo(@"使用通知方式获取定位回调");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationFinished:) name:locationAddressManagerDidUpdatedFinishedNotification object:nil];
    [[WSLocationManager getInstance] startUpdatingLocationWithActive:YES];
    
    self.subEmpId = subEmpId;
    self.currentFuncs = currentFuncs;
    self.objID = objID;
    
    if (updateFinishBlock) {
        self.updateFinishBlock = updateFinishBlock;
    }

    
//    NSString *useNewLocation = [WSPlistHelper valueForKey:@"useNewLocation" withPlistName:kConfilgFileName];
//    if ([useNewLocation isEqualToString:@"1"]) {
//
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationFinished:) name:locationAddressManagerDidUpdatedFinishedNotification object:nil];
//        [[WSLocationManager getInstance] startUpdatingLocationWithActive:YES];
//
//        self.subEmpId = subEmpId;
//        self.currentFuncs = currentFuncs;
//
//        if (updateFinishBlock) {
//            self.updateFinishBlock = updateFinishBlock;
//        }
//
//    }else{
//        LogInfo(@"lishuli--updateFinishBlock=====%@",updateFinishBlock);
//        if (updateFinishBlock) {
//            self.updateFinishBlock = updateFinishBlock;
//        }
//        __weak typeof(self)weakSelf = self;
//        [[WSLocationManager getInstance] startUpdateUserLocationWithBlock:^(WSLocationDescribe *aLocationDescribe, NSError *error) {
//            if (error) {
//                LogError(@"lishuli--定位失败：checkAndUpdateStoreDistanceWithCurrentFuncs--------计算距离插入数据库失败");
//            }else{
//                LogInfo(@"lishuli---定位成功：aLocationDescribe=====%@",aLocationDescribe);
//                if (aLocationDescribe.location && (aLocationDescribe.location.coordinate.longitude != 0 && aLocationDescribe.location.coordinate.latitude != 0)) {
//                    weakSelf.locationDescribe = aLocationDescribe;
//                    weakSelf.subEmpId = subEmpId;
//                    LogInfo(@"lishuli---是否需要刷新当前位置：isNeedUpdateStoreDistance =====%d,currentFuncs.name=%@",[self isNeedUpdateStoreDistanceWith:aLocationDescribe],currentFuncs.name);
//
//                    if ([self isNeedUpdateStoreDistanceWith:aLocationDescribe]) {
//                        [weakSelf updateStoreListWithDistanceToDBWithCurrentFuncs:currentFuncs];
//                    }
//                    //SFA-14575 2017-11-29
//                    else
//                    {
//                        if (self.updateFinishBlock)
//                        {
//                            self.updateFinishBlock(self.locationDescribe,NO);
//                            self.updateFinishBlock = nil;
//                        }
//                    }
//                }
//            }
//        }];
//    }
}

// 定位完成后计算门店距离，并把距离入库，再刷新门店列表
- (void)updateStoreListWithDistanceToDBWithCurrentFuncs:(WSFuncsBean *)currentFuncs
{
    NSString *currenteEmpId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *subEmpId = self.subEmpId;
    NSString *empId = subEmpId?:currenteEmpId;
    
    NSString * search_objId = STORES;
    //SFA 项目SFA-22684 【SFA泸州老窖】【iOS】客户列表中有的门店没有显示当前定位与门店位置的距离(客户列表的数据是根据filter查询的,此处添加filter,统一规则)
    if ([currentFuncs.ds length] > 0 && ![currentFuncs.ds isEqualToString:@"acvt"]) {
        search_objId = currentFuncs.ds;
    }else if ([currentFuncs.filter length] > 0){
        search_objId = currentFuncs.filter;
    }else if (self.objID.length > 0){
        search_objId = self.objID;
    }
    
    NSArray * storeListArray = [[WSBaseStoreDBService shareInstance]queryAllStoreToUpdataDistanceWith:empId objId:search_objId styp:currentFuncs.styp];
    
        //SFA-22771 加载卡死，原因是：多个线程同时写入或读取数据库时，导致应用程序崩溃。 改为同步执行 --zhangmin
        //SFA-14575 2017-11-29
        [self updateStoreTableWithStoreArray:storeListArray locationDescribe:self.locationDescribe FC:currentFuncs.fc];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.updateFinishBlock)
            {
                self.updateFinishBlock(self.locationDescribe,YES);
                self.updateFinishBlock = nil;
            }
    });
}

@end

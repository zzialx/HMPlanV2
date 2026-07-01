//
//  WSGetDataByMethod.m
//  WinSFA
//
//  Created by yang on 16/1/11.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSGetDataByMethodExecutor.h"
#import "WSDataSourceManager.h"
#import "WSBaseModel.h"
#import "WSDictBean.h"
#import "WSInterAction.h"
#import "WSNestedAcvtModel.h"
#import "WSLocationManager.h"
#import "WSBaseDictsDBService.h"
#import "WSAcvtView.h"
#import "WSSqliteUtil.h"
#import "WSEnvrionment.h"
#import "RSAEncryptor.h"
#import "WSBaseStoreDBService.h"
#import "WSBaseAcvtDBService.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSCustomEnterStoreTimeObject.h"
#import "WSCustomTimeTable.h"
#import "NSDate+Category.h"
#import "WSBaseFunsDBService.h"
#import "WSBaseProductDBService.h"
#import "NSString+Util.h"
#import "Md5Manager.h"
#import "WSVisitStoreAcvtDataTable.h"
#import "WSCalendarEventTools.h"
#import "WSAcvtViewController.h"
#import "WSEnterOrLeaveStoreBaseAcvtViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "WinJSBridgeViewController.h"

#define kParamSeparator       @"[@]"


//2017-0929-yuanji-add
#pragma mark - WSGetDataByMethodExecutor 延展(工具)
@interface WSGetDataByMethodExecutor (Tools)

- (NSString *)replaceBase_store_tableAndId:(NSString *)objString; //替换Base_store_table与id方法

- (NSString*)getStatus:(NSString*)status; //转换拜访状态

#pragma mark - 获取新的genid方法 param:参数
- (NSString *)getNewGenId:(NSString *)param;

@end

@implementation WSGetDataByMethodExecutor

-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    __weak __typeof(self) wself = self;
    
    LuaScriptWithParamsExpandBlock   paramExpanedBlock = ^NSString *(id firstObj, ...) {
        
        __strong __typeof(wself) sself = wself;
        
        NSString *firstObjectString = [NSString stringWithFormat:@"%@" ,firstObj];
        
        va_list argsList;
        va_start(argsList, firstObj);
        id secondObj = va_arg(argsList, id);
        va_end(argsList);
        
        NSString *secondObjString =[NSString stringWithFormat:@"%@",secondObj];
        NSString *result = @"";
        
        if ([firstObjectString isEqualToString:@"getTime"]) { //获取当前时间：yyyy-MM-dd HH:mm:ss
            
            result = [WSCurrentTime getDateTime];
            
        }else if ([firstObjectString isEqualToString:@"getTimeMillis"]){
            result = [WSCurrentTime getTimeMillisString];
        }
        else if ([firstObjectString isEqualToString:@"getCurrentDate"]) {
            result = [WSCurrentTime getDateString];
        }else if ([firstObjectString isEqualToString:@"getGps"]) { //获取GPS坐标
            
        }
        else if ([firstObjectString isEqualToString:@"getAddrReserve"]) { //经纬度
            
            if ([WSEnvrionment getUseBaiduMap] || [WSEnvrionment getuseGeoAmap]) {
                
                NSDictionary *dic = @{@"geoCodeSearch" : secondObjString};
                [[NSNotificationCenter defaultCenter] postNotificationName:kWinPOISearchNotifi object:dic];
            }
            else {
                
                NSString *str = @"";
                NSArray *array = [secondObjString componentsSeparatedByString:@"8"];
                if (array && array.count > 0) {
                    str = [array firstObject];
                }
                CLGeocoder *geocoder = [[CLGeocoder alloc] init];
                [geocoder geocodeAddressString:str completionHandler:^(NSArray *placemarks, NSError *error) {
                     
                    if (error || 0 == placemarks.count) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"noticeAddress" object:nil];
                    }
                    else {
                        CLPlacemark *firstPlacemark = [placemarks firstObject];
                        NSString *longitudeLabel = [NSString stringWithFormat:@"%.6f", firstPlacemark.location.coordinate.longitude];
                        NSString *latitudeLabel  = [NSString stringWithFormat:@"%.6f", firstPlacemark.location.coordinate.latitude];
                        NSDictionary *dic = @{@"long":longitudeLabel,@"lat":latitudeLabel};
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"noticeAddress" object:dic];
                    }
                }];
            }
        }else if ([firstObjectString isEqualToString:@"getGpsReserve"]) { //经纬度逆地理查询备用方案
            
            if ([WSEnvrionment getUseBaiduMap] || [WSEnvrionment getuseGeoAmap]) {
                
                NSDictionary *dic = @{@"geoCodeSearch" : secondObjString};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"geoCodeSearchAddress" object:dic];
                
            }
            else {
                
                NSString *str = @"";
                NSArray *array = [secondObjString componentsSeparatedByString:@"8"];
                if (array && array.count > 0) {
                    str = [array firstObject];
                }
                CLGeocoder *geocoder = [[CLGeocoder alloc] init];
                [geocoder geocodeAddressString:str completionHandler:^(NSArray *placemarks, NSError *error) {
                     
                    if (error || 0 == placemarks.count) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"noticeAddress" object:nil];
                    }
                    else {
                        CLPlacemark *firstPlacemark = [placemarks firstObject];
                        NSString *longitudeLabel = [NSString stringWithFormat:@"%.6f", firstPlacemark.location.coordinate.longitude];
                        NSString *latitudeLabel  = [NSString stringWithFormat:@"%.6f", firstPlacemark.location.coordinate.latitude];
                        NSDictionary *dic = @{@"long":longitudeLabel,@"lat":latitudeLabel};
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"noticeAddress" object:dic];
                    }
                }];
            }
        }else if ([firstObjectString isEqualToString:@"uploadThenNotFinishView"]) { //通知页面上传数据但是不退出当前页面
            
            WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
            model.uploadThenNotFinishView = YES;
            
        }else if ([firstObjectString isEqualToString:@"uploadThenSelectedTabIndex"]) { //通知页面上传数据但是不退出当前页面
            
            WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
            model.uploadThenSelectedTabIndex = [secondObjString integerValue];
            
        } else if ([firstObjectString isEqualToString:@"showAcvtTabByIndex"]) {
            if ([secondObjString length] > 0) {
                WSAcvtView *acvtView = (WSAcvtView *)wself.delegate;
                [acvtView gotoTabWithIndex:[secondObjString integerValue]];
            }
        } else if ([firstObjectString isEqualToString:@"currentDateAddDays"]) { //以当前日期为基准计算指定天数的日期. 备注：负数为向前计算日期
            
        }else if ([firstObjectString rangeOfString:@"compareDateWithCurrentDate"].location != NSNotFound) { //获取当前日期与指定日期之间的天数. 备注：大于当天返回正数
            if ([secondObjString length] > 0) {
                NSString *currentDateString = [WSCurrentTime currentDay];
                
                NSDateFormatter *dateFormatter = [NSDateFormatter standardDateFormatter];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                NSDate *paramDate = [dateFormatter dateFromString:secondObjString];
                NSDate *curentDate = [dateFormatter dateFromString:currentDateString];
                
                NSInteger diffDate = [curentDate daysBeforeDate:paramDate];
                result = [NSString stringWithFormat:@"%ld", (long)diffDate];
            }
        }else if ([firstObjectString isEqualToString:@"queryDictNameByCode"]){
            
            WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
            WSDictBean *aDictBean = [service queryDictWithCod:secondObjString];
            
            return aDictBean.dtyp;
            
        }else if ([firstObjectString isEqualToString:@"queryDictCodeByTyp"]){

            WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
            NSArray *dictArray = [service queryDictsForAcvtGridWithFilter:secondObjString];
            return [[dictArray firstObject] cod];
            
        }else if ([firstObjectString isEqualToString:@"queryDictNameByTyp"]){
            
            WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
            NSArray *dictArray = [service queryDictsForAcvtGridWithFilter:secondObjString];
            return [[dictArray firstObject] name];
            
        }else if ([firstObjectString isEqualToString:@"uploadExtraData"]) {
            
            if ([secondObjString length] > 0) {
                WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
                model.extralData = secondObjString;
                if ([model isKindOfClass:[WSNestedAcvtModel class]]) {
                    WSNestedAcvtModel *nestModel = (WSNestedAcvtModel *)model;
                    nestModel.parentModel.extralData = secondObjString;
                }
            }
            
//            NSObject *params = nil;
//            if ([sself.currentTargetObject respondsToSelector:@selector(getOtherLuaExecuteParams)]) {
//                params = [sself.currentTargetObject getOtherLuaExecuteParams];
//            }
            
            WSInterAction  *interaction =[[WSInterAction alloc] init];
            [interaction setExecute_method:@selector(beginToVisitStore:)];
            [interaction setExecute_method_param:nil];
//            [interaction setExecute_method_param:params];
            [interaction setDirect_type:DIRECT_TYPE_METHOD_WITH_SINGLEPARAM];
            
            __strong typeof (sself.delegate) strongDelegate = sself.delegate;
            
            if ([sself.delegate respondsToSelector:@selector(executeInterAction:)]) {
                [sself.delegate executeInterAction:interaction];
            }
            
            strongDelegate = nil;
            
        }else if ([firstObjectString isEqualToString:@"getCurrentAcvtID"]){
            
            WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
            NSString *acvtID = nil;
            if ([model isKindOfClass:[WSAcvtModel class]]) {
                WSAcvtModel *acvtModel = (WSAcvtModel *)model;
                acvtID = acvtModel.currentAcvtBean.acvtId;
            }
            return acvtID;
        }else if ([firstObjectString isEqualToString:@"getCurrentAcvtID"]){
            
            WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
            NSString *acvtID = nil;
            if ([model isKindOfClass:[WSAcvtModel class]]) {
                WSAcvtModel *acvtModel = (WSAcvtModel *)model;
                acvtID = acvtModel.currentAcvtBean.acvtId;
            }
            return acvtID;
        }else if ([firstObjectString isEqualToString:@"getAcvtQstIDByQstCode"]) {
            WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];
            WSAcvtBean *acvtBean = [baseAcvtDBService queryAcvtWithQstCod:secondObjString];
            WSAcvtBean_qst *qstBean = [acvtBean getQstBeanByQstCod:secondObjString];
            return qstBean.acvtQstId;
        }else if ([firstObjectString isEqualToString:@"getCurrentParentFuncsCode"]){
            WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
            NSString *parentFuncsCode = nil;
            if ([model isKindOfClass:[WSAcvtModel class]]) {
                WSAcvtModel *acvtModel = (WSAcvtModel *)model;
                WSBaseFunsDBService *db = [[WSBaseFunsDBService alloc]init];
                parentFuncsCode = [db getParentFuncsCode:acvtModel.currentFuncs.fc];
            }
            return parentFuncsCode;
        }
        //2017-0929-yuanji-modify
        else if ([firstObjectString isEqualToString:@"getCurrentStoreId"] || [firstObjectString isEqualToString:@"getStoreId"])
        {
            WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
            NSString *storeId = nil;
            if ([model isKindOfClass:[WSAcvtModel class]]) {
                WSAcvtModel *acvtModel = (WSAcvtModel *)model;
                storeId = acvtModel.currentStore.Id;
            }
            return storeId ? storeId : @"";
        }
        else if ([firstObjectString isEqualToString:@"getAcvtEdit"])
        {
            WSAcvtView * acvtView = (WSAcvtView *)wself.delegate;
            NSString * state = @"true";
            if ([acvtView.delegate isKindOfClass:[WSAcvtViewController class]])
            {
                if ([acvtView.delegate respondsToSelector:@selector(getAcvtEdit)])
                {
                    state =  [(WSAcvtViewController *)acvtView.delegate getAcvtEdit];
                }
            }
            return state;
        }
        else if ([firstObjectString isEqualToString:@"excuseReturnValue"]){
            
            if ([wself.currentTargetObject respondsToSelector:@selector(setValueForCurrentObject:)]) {
                [wself.currentTargetObject setValueForCurrentObject:secondObjString];
            }
        }else if ([firstObjectString isEqualToString:@"getDistanceBetweenRealAndStore"]){
            
            
            //lanAndLonPointS(latValue,lonValue,latStore,lonStore)
            NSArray *lanAndLonPointS =[secondObj componentsSeparatedByString:@","];
            
            double currentlatitude =[[lanAndLonPointS objectAtIndex:0] doubleValue];
            double currentlongitude =[[lanAndLonPointS objectAtIndex:1] doubleValue];
            double storelatitude =[[lanAndLonPointS objectAtIndex:2] doubleValue];
            double storelongitude =[[lanAndLonPointS objectAtIndex:3] doubleValue];
            
            MKMapPoint currentPoint = MKMapPointForCoordinate(CLLocationCoordinate2DMake(currentlatitude,currentlongitude));
            
            MKMapPoint storePoint = MKMapPointForCoordinate(CLLocationCoordinate2DMake(storelatitude,storelongitude));
            
            CLLocationDistance distance = MKMetersBetweenMapPoints(currentPoint, storePoint);
            LogInfo(@"距离---->%lf",distance);
            return [NSString stringWithFormat:@"%lf",distance];
            
        }else if ([firstObjectString isEqualToString:@"compareDateWithCurrentTime"]){
            
            NSString *currentTime = [WSCurrentTime getTimeStringbyMills:[[WSCurrentTime getServerTime] doubleValue]];
            
            NSString *serverTime = secondObjString ;
            
            NSInteger  duration = [WSCurrentTime getDurationWithFomeDateStr:currentTime withEndDateStr:serverTime];
            
            return [NSString stringWithFormat:@"%ld",(long)duration];
            
        }else if ([firstObj isEqualToString:@"getGpsGeoInfo"]){
            
            WSLocationDescribe *locationDesrible = [WSLocationManager getInstance].lastLocation;
            if ([secondObjString isEqualToString:@"city"] && [locationDesrible.cityName length] > 0) {
                result = locationDesrible.cityName ;
            }else if ([secondObjString isEqualToString:@"province"] && [locationDesrible.provinceName length] > 0){
                result = [locationDesrible.provinceName substringToIndex:locationDesrible.provinceName.length ]; //YIHAIKERRY-4017
            } else if ([secondObjString isEqualToString:@"address"] && [locationDesrible.detailAddress length] > 0) {
                result = locationDesrible.detailAddress;
                //                  YIHAIKERRY-847 对应获取取不到地址修改
            }
            else if ([secondObjString isEqualToString:@"district"] && [locationDesrible.district length] > 0){
                result = locationDesrible.district;
            }

//            NSArray *locationCache = [[WSLocationManager getInstance] getLoctionCache];
//
//            for (NSInteger i = [locationCache count] - 1; i >= 0; i--) {
//                WSLocationDescribe *locationDesrible = locationCache[i];
//                if ([secondObjString isEqualToString:@"city"] && [locationDesrible.cityName length] > 0) {
//                    result = locationDesrible.cityName ;
//                    break;
//
//                }else if ([secondObjString isEqualToString:@"province"] && [locationDesrible.provinceName length] > 0){
//                    result = [locationDesrible.provinceName substringToIndex:locationDesrible.provinceName.length - 1];
//                    break;
//                } else if ([secondObjString isEqualToString:@"address"] && [locationDesrible.detailAddress length] > 0) {
//                    result = locationDesrible.detailAddress;
////                  YIHAIKERRY-847 对应获取取不到地址修改
//                    break;
//                }
//            }
            
        }else if ([firstObj isEqualToString:@"getPreVisitDate"]){
            
            WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
            result = model.prepareVisitDate;
        }else if ([firstObjectString isEqualToString:@"compareTime1WithTime2"]){
            
            NSArray *dateArray = [secondObj componentsSeparatedByString:@"@#"];
            
            if ([dateArray count] > 1) {
                NSDateFormatter *formatTime = [NSDateFormatter standardDateFormatter];
                if ([dateArray[0] rangeOfString:@":"].location != NSNotFound) {
                    
                    NSArray *timeArray = [dateArray[0] componentsSeparatedByString:@":"];
                    
                    if ([timeArray count] > 2) {
                        [formatTime setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    }else {
                        [formatTime setDateFormat:@"yyyy-MM-dd HH:mm"];
                    }
                    
                }else {
                    [formatTime setDateFormat:@"yyyy-MM-dd"];
                }
                
                NSDate *time1 = [formatTime dateFromString:dateArray[0]];
                NSDate *time2 = [formatTime dateFromString:dateArray[1]];
                
                NSTimeInterval interval = [time2 timeIntervalSinceDate:time1];
                
                result = [NSString stringWithFormat:@"%lld",(long long)interval * 1000];
            }
            
        }else if ([firstObjectString isEqualToString:@"getAcvtFilledQstsCountByType:"]) {
       
            if ([wself.delegate respondsToSelector:@selector(getAcvtFilledQstsCountByType:)]) {
                result = [(WSAcvtView *)wself.delegate getAcvtFilledQstsCountByType:secondObjString];
            }
        }else if ([firstObjectString isEqualToString:@"getAcvtQstsCountByType:"]) {
            
            if ([wself.delegate respondsToSelector:@selector(getAcvtQstsCountByType:)]) {
                result = [(WSAcvtView *)wself.delegate getAcvtQstsCountByType:secondObjString];
            }
        }else if ([firstObjectString isEqualToString:@"executeSql:"])
        {
            WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
            
            //2017-0929-yuanji-modify
            NSString *replaceStr = [self replaceBase_store_tableAndId:secondObjString];
            NSArray *dicts = [sqliteUtil queryDicDatasBySql:replaceStr argumentsValues:nil];
            NSArray *dictsKeys = [sqliteUtil queryDicKeysBySql:replaceStr argumentsValues:nil];
            
            for (NSInteger i = 0; i < [dicts count]; i++) {
                NSDictionary *dictioanry = dicts[i];
                // YIHAIKERRY-4045 dictsKeys 获取 key 的有序数组，替换 allKeys 的方式避免脚本按照顺序获取数据出错
                for (NSString *key in dictsKeys) {
//                for (NSString *key in [dictioanry allKeys]) {
                    //    donghong MN-2552 防止nill出现
                    NSString *value = dictioanry[key] == [NSNull null] ? @"" : [NSString stringWithFormat:@"%@",dictioanry[key]];
                    result = [result stringByAppendingFormat:@"%@,%@@",key,value];
                }
                result = [result stringByAppendingFormat:@"|"];
            }
            LogInfo(@"result-%@",result);
        }else if ([firstObjectString isEqualToString:@"getStatus"])
        {
            result = [self getStatus:secondObjString];
     
        }else if ([firstObjectString isEqualToString:@"exitApp"]) {
            exit(0);
        }else if ([firstObjectString isEqualToString:@"getRSAEncryptedString"]) {
            
            NSArray *params = [secondObj componentsSeparatedByString:@","];
            if ([params count] == 2) {
                result = [RSAEncryptor encryptString:params[0] publicKey:params[1]];
            }
            
        }else if ([firstObjectString isEqualToString:@"getTimestampString"]) {
            
            result = [WSCurrentTime getTimestampString];
            
        }else if ([firstObjectString isEqualToString:@"getMD5String"]) {
            
            if ([secondObj length] > 0) {
                result = [secondObj md5];
            }
            
        }else if ([firstObjectString isEqualToString:@"getURLEncodeString"]) {
            
            if ([secondObj length] > 0) {
                result = [secondObj mk_urlEncodedString];
                NSLog(@"result ---%@",result);
            }
            
        }else if ([firstObjectString  isEqualToString:@"replaceString:withStirng:inString:"]){
            
            if ([secondObjString rangeOfString:@"[@]"].location != NSNotFound) {
                NSArray *params = [secondObjString componentsSeparatedByString:@"[@]"];
                if ([params count] == 3) {
                    NSString *OccurrencesString = [params firstObject];
                    NSString *replaceString = params[1];
                    NSString *inString = params[2];
                    result = [inString stringByReplacingOccurrencesOfString:OccurrencesString withString:replaceString];
                }
            }
        } else if ([firstObjectString  isEqualToString:@"isTodayAddStore"]) {
            // SFA-5701 需要判断是否是当天新增的二级门店
            BOOL isTodayAddStore = NO;
            WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
            if ([model isKindOfClass:[WSAcvtModel class]]) {
                WSAcvtModel *acvtModel = (WSAcvtModel *)model;
                BOOL isNewAcvt = acvtModel.isNewAddAcvt;
                if (!isNewAcvt && acvtModel.currentNewStore) {
                    WSBaseStoreDBService *storeService = [[WSBaseStoreDBService alloc] init];
                    WSBaseStoreObject *baseStoreObj = [storeService queryStoreWithId:acvtModel.currentNewStore.Id];
                    if (!baseStoreObj) {
                        isTodayAddStore = YES;
                    } else if ([baseStoreObj.acvt_genid isEqualToString:acvtModel.updateGenId]) {
                        isTodayAddStore = YES;
                    }
                } else {
                    isTodayAddStore = YES;
                }
                result = isTodayAddStore ? @"1" : @"0";
            }
        } else if ([firstObjectString  isEqualToString:@"isNewAddAcvt"]) {
            
            //SFA-6680    需要判断是否是新增问卷
            WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
            if ([model isKindOfClass:[WSAcvtModel class]]) {
                WSAcvtModel *acvtModel = (WSAcvtModel *)model;
                BOOL isNewAcvt = NO;
                if (acvtModel.isNewAddAcvt && !acvtModel.updateGenId) {
                    isNewAcvt = YES;
                }
                
                result = isNewAcvt ? @"1" : @"0";
            }
        } else if ([firstObjectString  isEqualToString:@"queryDictInfoByParam"]) {
            
            //类似于getStoreInfoByCod，三个参数逗号拼接， dtyp,id,value，查询id为value的字典项的dtyp
            NSArray *params = [secondObjString componentsSeparatedByString:@","];
            
            if (params.count == 3) {
                NSString *infoType = params[0];  //查询信息类型
                NSString *valueType = params[1]; //条件类型
                NSString *value = params[2];     //条件值
                
                WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
                WSDictBean *dictBean;
                if ([valueType isEqualToString:@"id"] || [valueType isEqualToString:@"_id"]) {
                    dictBean = [service queryDictWithID:value];
                }else if ([valueType isEqualToString:@"cod"] || [valueType isEqualToString:@"code"]) {
                    dictBean = [service queryDictWithCod:value];
                }
                
                // SFA-17367 新增_id,pid,dictId三个参数的模式
                if ([valueType isEqualToString:@"pid"]) {
                    dictBean = [[service queryDictWithPid:value] firstObject];
                }
                //YIHAIKERRY-4873
                if ([infoType isEqualToString:@"dtyp"]) {
                    result = dictBean.dtyp;
                } else if ([infoType isEqualToString:@"name"]) {
                    result = dictBean.name;
                } else if ([infoType isEqualToString:@"cod"]) {
                    result = dictBean.cod;
                } else if ([infoType isEqualToString:@"id"] || [infoType isEqualToString:@"_id"]) {
                    result = dictBean.Id;
                } else if ([infoType isEqualToString:@"col1"]) {
                    result = dictBean.col1;
                } else if ([infoType isEqualToString:@"col2"]) {
                    result = dictBean.col2;
                }
            }
            
        } else if ([firstObjectString isEqualToString:@"getQstDataByQstCode"]) {
            NSArray *params = [secondObjString componentsSeparatedByString:@"[@]"];
            if (params.count >= 2) {
                NSString *qstCode = params[0];
                NSString *isGetLastValueString = params[1];
                BOOL isGetLastValue = [isGetLastValueString isEqualToString:@"last"] ? YES : NO;
                
                WSBaseAcvtDBService *acvtService = [[WSBaseAcvtDBService alloc] init];
                WSAcvtBean_qst *qstBean = [acvtService queryQstWithAcvtQstCode:qstCode];
                
                WSBaseAcvtdisDBService *disService = [[WSBaseAcvtdisDBService alloc] init];
                result = [disService queryQstLocalValueWithStoreId:nil acvtId:nil acvtQstId:qstBean.acvtQstId genId:nil bizDate:nil isGetLastValue:isGetLastValue];
            }
        } else if ([firstObjectString isEqualToString:@"storeMedia"]) {
            // MSTD-5197 截屏后保存图片
            NSArray *params = [secondObjString componentsSeparatedByString:@"[@]"];
            if (params.count == 2) {
                if ([[WSDataSourceManager sharedInstance].currentActiveModel isKindOfClass:[WSAcvtModel class]]) {
                    WSAcvtModel *acvtModel = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
                    
                    if (acvtModel.feedbackPhotoId) {
                        NSString *imageIndex = params[0];
                        NSString *qstCode = params[1];
                        
                        UIImage *screenImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:acvtModel.feedbackPhotoId];
                        if (screenImage) {
                            [[SDImageCache sharedImageCache] storeImage:screenImage
                                                   imageImgCompress:@1
                                                             forKey:imageIndex
                                                             toDisk:YES
                                                         toDocument:YES
                                                     isSynchronized:YES];
                        
                        
                            WSBaseAcvtDBService *acvtService = [[WSBaseAcvtDBService alloc] init];
                            WSAcvtBean_qst *qstBean = [acvtService queryQstWithAcvtQstCode:qstCode];
                            acvtModel.hasLocalData = YES;
                            [acvtModel.qstDBValueDictionary setObject:imageIndex forKey:qstBean.acvtQstId];
                        
                            // Android 需要返回个标志
                            result = @"true";
                            
                            acvtModel.feedbackPhotoId = nil;
                        }
                    }
                }
            }
        } else if ([firstObjectString isEqualToString:@"uploadLog"]) {
             [[WCLogManager sharedInstance] startUploadLog:UploadLogTypedAll];
            
        } else if ([firstObjectString isEqualToString:@"getAllowedPeriod"]) {
            
            NSArray *array = [WSAppData getObjectbyKey:BASE_DATA_ENTRY];
            NSString *empIdStr = [WSAppData getObjectbyKey:APPDATA_EMPID];
            for (WSCustomEnterStoreTimeObject *obj in array) {
                if ([obj.empIdStr isEqualToString: empIdStr]) {
                    result = obj.timeLimitStr;
                    break;
                }
            }
            
        } else if ([firstObjectString isEqualToString:@"getCustomEnterStoreDateAndTime"]) {
            
            WSBaseModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;

            if ([[WSCustomTimeTable sharedTable] isCustomTimeWithStoreId:model.currentStore.Id withNeedNoLeaveStore:YES withVisitId:model.md5] ) {
                NSArray *array = [[WSCustomTimeTable sharedTable] queryCustomDateAndTimeWithStoreId:model.currentStore.Id withNeedNoLeaveStore:YES withVisitId:model.md5];
                if ([array count] == 2) {
                    result = [array componentsJoinedByString:@","];
                }
            }
            
        } else if ([firstObjectString isEqualToString:@"setAlert"] || [firstObjectString isEqualToString:@"setAlert:"]) {
            
             [WSLuaExecutorManager shareInstance].isErrorFromScript = YES;
            
            // 提示语[@]标题[@]确定[:]确认执行的方法名[@]取消[@]null，不需要取消就减少一组
            NSArray *params = [secondObjString componentsSeparatedByString:@"[@]"];
            if ([params count] == 3 || [params count] == 4 || [params count] == 5) {
                
                NSString *msg = params[0];
                if ([msg length] == 0) {
                    msg = NSLocalizedString(@"标题",nil);
                }
                
                NSString *title = params[1];
                if ([title length] == 0) {
                    title = NSLocalizedString(@"js_alert_title",nil);
                }
                
                NSString *okParams = params[2];
                NSString *okMethod = nil;
                NSString *ok = NSLocalizedString(@"confirm", nil);;
                if ([okParams length] > 0) {
                    NSArray *okArray = [okParams componentsSeparatedByString:@"[:]"];
                    if ([okArray count] == 2 || [okArray count] == 3) {
                        if ([okArray[0] length] > 0) {
                            ok = okArray[0];
                        }
                        okMethod = okArray[1];
                    } else {
                        ok = okParams;
                    }
                }
    
                BlockAlertView *blockAlertView = [BlockAlertView alertWithTitle:title message:msg];
                WSInterAction  *interaction = [[WSInterAction alloc] init];
                [blockAlertView addButtonWithTitle:ok block:^{
                    
                    if (okMethod) {
                        
                        NSObject *params = nil;
                        if ([sself.currentTargetObject respondsToSelector:@selector(getOtherLuaExecuteParams)]) {
                            params = [sself.currentTargetObject getOtherLuaExecuteParams];
                        }
                        
                        if ([okMethod isEqualToString:@"upload"] || [okMethod isEqualToString:@"onlyUpload"]) {
                            [interaction setExecute_method:@selector(executeRealWillUpload:)];
                            
                        }
                        else if ([okMethod isEqualToString:@"deleteStore"]) {
                            [interaction setExecute_method:@selector(deleteButtonClick:)];
                        }
                        else if ([okMethod isEqualToString:@"cancel"]) {
                            [interaction setExecute_method:@selector(backButtonClick)];
                        }
                        else if ([okMethod isEqualToString:@"refeshLocation"]){
                            [interaction setExecute_method:@selector(refeshLocation:)];
                        }
                        [self setExecuteMethodParamAndDirect_typeByInteraction:interaction params:params];
                    }
                }];
                //  SFA-22221 SFA-立白-IOS-新增订单/门店拜访订单-添加产品数量超过库存量时点确定按钮上传，不能分享和打印
                if ([params count] == 5) {
                    NSString *cancel = params[3];
                    if ([cancel length] == 0) {
                        cancel = NSLocalizedString(@"cancel_label", nil);
                    } else {
                        NSArray *cancelArray = [cancel componentsSeparatedByString:@"[:]"];
                        if ([cancelArray count] == 2 || [cancelArray count] == 3) {
                            if ([cancelArray[0] length] > 0) {
                                cancel = cancelArray[0];
                            }
                        }
                    }

                    [blockAlertView addButtonWithTitle:cancel block:^{
                        [interaction setExecute_method:@selector(alertCancleAction)];
                        [self setExecuteMethodParamAndDirect_typeByInteraction:interaction params:params];
                    }];
                }
                [blockAlertView show];

            }
        } else if ([firstObjectString isEqualToString:@"showTipAlert"]) {

            BlockAlertView *blockAlertView = [BlockAlertView alertWithTitle:@"提示" message:secondObjString];
            [blockAlertView addButtonWithTitle:@"知道了" block:^{
            }];
            [blockAlertView show];
        }
        else if ([firstObjectString isEqualToString:@"getEnterOrLeaveStoreModuleFc"]) {
            WSAcvtView *acvtView = (WSAcvtView *)wself.delegate;
            NSString *moduleFc = @"";
            if ([acvtView.delegate isKindOfClass:[WSEnterOrLeaveStoreBaseAcvtViewController class]]) {
                WSEnterOrLeaveStoreBaseAcvtViewController *vc = (WSEnterOrLeaveStoreBaseAcvtViewController *)acvtView.delegate;
                moduleFc = [vc getEnterOrLeaveStoreModuleFc];
            }
            result = moduleFc;
        } else if ([firstObjectString isEqualToString:@"getEmpId"]) {
            result = [WSAppData getObjectbyKey:APPDATA_EMPID];
        }else if ([firstObjectString isEqualToString:@"getUserName"]){
             result = [WSAppData getObjectbyKey:APPDATA_EMPNAME];
        }
        else if ([firstObjectString isEqualToString:@"getUserAccount"]){
            result = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_BEGIN_LOGIN];
        }
        else if ([firstObjectString isEqualToString:@"getBizDate"]){
            result = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
        }
        else if ([firstObjectString isEqualToString:@"finishView"]) {
            WSAcvtView *acvtView = (WSAcvtView *)wself.delegate;
            if (acvtView.viewController.navigationController) {
                [acvtView.viewController.navigationController popViewControllerAnimated:YES];
            }
        }else if ([firstObjectString isEqualToString:@"getCurrentHHmm"]){
            result =  [WSCurrentTime getShortTimeString];
        }else if([firstObjectString isEqualToString:@"hiddenAcvtTab"]){
            WSAcvtView *acvtView = (WSAcvtView *)wself.delegate;
            [acvtView hiddenAcvtTab:secondObjString];
        }
        else if([firstObjectString isEqualToString:@"timeFormat"])
        {
            
            NSArray *dateArray = [secondObj componentsSeparatedByString:@"@#"];
            if(dateArray.count > 1)
            {
                NSDateFormatter *formatTime = [NSDateFormatter standardDateFormatter];
                [formatTime setDateFormat:dateArray[0]];
                NSString *str = dateArray[1];
                result = [formatTime stringFromDate:[NSDate dateWithTimeIntervalSince1970:[str integerValue]]];

            }
           else if ([secondObjString length] > 0)
            {
                NSDate *currentDate = [WSCurrentTime getCurrentServerDate];
                NSDateFormatter *formatTime = [NSDateFormatter standardDateFormatter];
                [formatTime setDateFormat:secondObjString];
                result = [formatTime stringFromDate:currentDate];
            }
            else
                result = [WSCurrentTime getDateTime];
        } else if ([firstObjectString isEqualToString:@"setStoreCurrentAddress"]) {
            if ([secondObjString length] > 0) {
                WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
                if ([model isKindOfClass:[WSAcvtModel class]]) {
                    NSArray *params = [secondObjString componentsSeparatedByString:kParamSeparator];
                    if ([params count] == 2) {
                        NSString *storeId = params[0];
                        WSAcvtModel *acvtModel = (WSAcvtModel *)model;
                        //SFA 项目SFA-22215 开始拜访时拍照的水印显示的是门店地址而不是当前定位
                        if ([storeId isEqualToString:acvtModel.currentStore.Id] && ![params[1] isEqualToString:@""]) {
                            acvtModel.currentStore.currentAddress = params[1];
                            LogInfo(@"脚本获取地址后赋值---%@",params[1]);
                        }
                    }
                }
            }
        } else if ([firstObjectString isEqualToString:@"setAcvtRequired"]) {
            WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
            if ([secondObjString length] > 0) {
                if ([secondObjString isEqualToString:@"1"] || [secondObjString isEqualToString:@"0"]) {
                    
                }else{
                    if ([[secondObjString lowercaseString] isEqualToString:@"true"] || [[secondObjString lowercaseString] isEqualToString:@"y"] || [[secondObjString lowercaseString] isEqualToString:@"yes"]) {
                        secondObjString = @"1";
                        model.isReqFromLua = YES;
                    }else{
                        secondObjString = @"0";
                    }
                }
                
                [model.currentAcvtBean setIsReq:secondObjString];

            }
        }else if ([firstObjectString isEqualToString:@"getProdInfoByIdAndParam"]){
            NSArray *IdAndParam = [secondObj componentsSeparatedByString:@"@#"];
            NSString *proId = [IdAndParam firstObject];
            NSString *param = [IdAndParam lastObject];
            WSBaseProductDBService *dbService = [[WSBaseProductDBService alloc]init];
            WSProdBean *prodBean = [dbService queryProductByID:proId];
            result = [dbService queryStoreValueWithParamCol:param prodBean:prodBean];
        }else if ([firstObjectString isEqualToString:@"getAcvtInfoByParam"]){
            WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
            NSString *infoType = secondObjString ; //查询信息类型
            if (infoType.length > 0) {
                WSBaseAcvtDBService *serVice = [[WSBaseAcvtDBService alloc] init];
                result = [serVice queryAcvtValueWithParamCol:infoType acvtBean:model.currentAcvtBean];
            }
        }else if ([firstObjectString isEqualToString:@"getFuncsInfoByParam"]){
            WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
            NSString *infoType = secondObjString ; //查询信息类型
            if (infoType.length > 0) {
                WSBaseFunsDBService *service = [[WSBaseFunsDBService alloc]init];
                result = [service queryFuncsValueWithParamCol:infoType funcsBean:model.currentFuncs];
            }
        } else if ([firstObjectString isEqualToString:@"getShortUuid"]) {
            NSInteger length = [secondObjString integerValue];
            result = [NSString shortUniqueStringByLength:length];
        }
        else if ([firstObjectString isEqualToString:@"getNewGenId"])
        {
            result = [self getNewGenId:secondObjString];
        }
        else if ([firstObjectString isEqualToString:@"exeInsertSql"]) {
            NSArray *dataArray = [secondObjString componentsSeparatedByString:@"@#"];
            // dataArray cout 仅支持 2 和 3。 2的时候数据添加到 visit_store_acvt_data，3的时候添加到第三个参数的表名上
            if ([dataArray count] < 2 || [dataArray count] > 3) {
                LogError(@"exeInsertSql 参数个数错误");
                return @"";
            }
            
            NSString *keyString = dataArray[0];
            NSString *valueString = dataArray[1];
            
            NSArray *keyArray = [keyString componentsSeparatedByString:@"@@"];
            NSArray *valueArray = [valueString componentsSeparatedByString:@"@@"];
            if ([keyArray count] == [valueArray count]) {
                if ([dataArray count] == 2) {
                    [self insertVisitStoreAcvtDataWithKeyArray:keyArray valueArray:valueArray];
                } else {
                    // 暂不需要，需要的时候再实现
                }
            }
        } else if ([firstObjectString isEqualToString:@"onlyExecuteSql"]) {
            // SFA-16048 添加新的脚本方法,直接执行完整的sql语句
            NSString *sqlStr = secondObjString;
            
            WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
            
            [sqliteUtil executeUpdateWithSqls:@[sqlStr]];
            
        }else if ([firstObjectString isEqualToString:@"getAcvtGenId"] ||[firstObjectString isEqualToString:@"getGenId"] ) {
            
            WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
            
            result = model.md5;
        }else if ([firstObjectString isEqualToString:@"deleteEventTip"]) {
            if ([secondObjString rangeOfString:@"[@]"].location != NSNotFound) {
                NSArray *params = [secondObjString componentsSeparatedByString:@"[@]"];
                if ([params count] == 2) {
                    NSString *timeStr = [params firstObject];
                    NSString *description = params[1];
                    [[WSCalendarEventTools sharedManager] deleteCalendarEventWithTimeStr:timeStr andDescription:description];
                }
            }
        }else if ([firstObjectString isEqualToString:@"getSimpleJsonValueByKey"]) {
            /*{"empId":127129,"empCode":"dg003","attendanceRange":2000}@Lua#attendanceRange*/
            NSString * empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
            NSString * separator = @"@Lua#";
            // MN-1711  2018-4-20
            if ([secondObjString rangeOfString:separator].location != NSNotFound && [secondObjString rangeOfString:empId].location != NSNotFound ) {
                NSArray *params = [secondObjString componentsSeparatedByString:separator];
                if ([params count] == 2) {
                    NSString *jsonString = [params firstObject];
                    NSString * keyString = params[1];
                    NSDictionary * dict = [jsonString objectFromJSONString];
                    return [NSString stringNotNilWithValue:dict[keyString]];
                }
            }
            return @"";
        }else if ([firstObjectString isEqualToString:@"excuseFromServer"]) {
            WSAcvtView * acvtView = (WSAcvtView *)wself.delegate;
            if ([acvtView.delegate isKindOfClass:[WSAcvtViewController class]])
            {
                if ([acvtView.delegate respondsToSelector:@selector(excuseFromServer:)])
                {
                    [(WSAcvtViewController *)acvtView.delegate excuseFromServer:secondObjString];
                }
            }
        }
        else if ([firstObjectString isEqualToString:@"getProperty"])
        {
            NSDictionary *dictionary = [[NSUserDefaults standardUserDefaults] objectForKey:kPropertyUserDefaultsKey];
            result = [dictionary objectForKey:secondObjString];
        }
        else if ([firstObjectString isEqualToString:@"setProperty"])
        {
            NSArray *dataArray = [secondObjString componentsSeparatedByString:@"@#"];
            if(dataArray.count > 1)
            {
                NSString *key = (NSString *)[dataArray objectAtIndex:0];
                NSString *value = (NSString *)[dataArray objectAtIndex:1];
                NSDictionary *dictionary = [[NSUserDefaults standardUserDefaults] objectForKey:kPropertyUserDefaultsKey];
                NSMutableDictionary *newDictionary = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
                [newDictionary setObject:value forKey:key];
                
                [[NSUserDefaults standardUserDefaults] setObject:newDictionary forKey:kPropertyUserDefaultsKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        // MSTD-7860 以后如果有多个参数拼接，请使用"|"
        else if ([firstObjectString isEqualToString:@"getHardwareInfo"])
        {
            result = [[UIDevice currentDevice] modelName];
        }
        
        else if ([firstObjectString isEqualToString:@"getLastOutTime"])
        {
            WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
            NSArray *dicts = [sqliteUtil queryDicDatasBySql:[NSString stringWithFormat:@"select OUTTIME from wch_inoutStore where EMP_ID ='%@' and FUNC_CODE = 'F20S01_01' order by ID desc limit 1",[WSAppData getObjectbyKey:APPDATA_EMPID]] argumentsValues:nil];
            //SFA 项目SFA-22431 【SFA泸州老窖】【iOS】没有进店状态时，进入其他工作的默认显示开始时间不正确(如果查出数据为空，就返回)
            if (dicts.count == 0) {
                return  @"";
            }
            NSString *value = @"";
            for (NSInteger i = 0; i < [dicts count]; i++) {
                NSDictionary *dictioanry = dicts[i];
                for (NSString *key in [dictioanry allKeys]) {
                    value = dictioanry[key] == [NSNull null] ? @"" : [NSString stringWithFormat:@"%@",dictioanry[key]];
                }
            }
            
            NSDateFormatter *formatTime = [NSDateFormatter standardDateFormatter];
            [formatTime setDateFormat:secondObjString];
            result = [formatTime stringFromDate:[NSDate dateWithTimeIntervalSince1970:[value integerValue]]];
            LogInfo(@"result-%@",result);
            
            
        } else if ([firstObjectString isEqualToString:@"getLastMonth"]) {
            
            return [NSString stringNotNilWithValue:[WSCurrentTime getLastMonthString]];
        } else if ([firstObjectString isEqualToString:@"getSubProdData"]) {
        
            NSMutableString *value = [NSMutableString string];
            NSArray *dataArray = [secondObjString componentsSeparatedByString:@"@#"];
            if(dataArray.count > 1) {
                
                NSString *groupId = (NSString *)[dataArray objectAtIndex:0];
                NSInteger num = [(NSString *)[dataArray objectAtIndex:1] integerValue];
                NSString *outputMark = (dataArray.count > 2) ? ((NSString *)[dataArray objectAtIndex:2]) : @"dis";
                
                WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
                NSString *sqlStr = [NSString stringWithFormat:@"select prod.name name,prod.cod cod,prodRelation.item3 item3,prod.memo4 memo4 from base_product prod join base_store_other_data prodRelation on prod._id = prodRelation.item2 and prodRelation.type = 'prodRelationship' and prodRelation.item1 = '%@'", groupId];
                NSArray *prodInfos = [sqliteUtil queryDicDatasBySql:sqlStr argumentsValues:nil];

                for (int i = 0; i < prodInfos.count; i++) {
                    NSDictionary *prodDict = [prodInfos objectAtIndex:i];
                    NSString *name = [prodDict objectForKey:@"name"];
                    NSString *code = [prodDict objectForKey:@"cod"];
                    NSInteger item3 = [[prodDict objectForKey:@"item3"] integerValue];
                    NSString *memo4 = [prodDict objectForKey:@"memo4"];
                    NSString *item3Str = [NSString stringWithFormat:@"%ld%@",item3*num,memo4];
                    if ([outputMark isEqualToString:@"dis"]) {
                        [value appendFormat:@"%@%@\n          %@ \n", name, code, item3Str];
                    } else {
                        [value appendFormat:@"%@%@\n    %@ \n",name, code, item3Str];
                    }
                }
            }

            result = value;
            LogInfo(@"result-%@",result);
        } else if ([firstObjectString isEqualToString:@"jumpActivity"]) {
            
            if ([secondObjString rangeOfString:@"@#"].location != NSNotFound) {
                NSArray *params = [secondObjString componentsSeparatedByString:@"@#"];
                if ([params count] == 2) {
                    NSString *fv = params[1];
                    WSAcvtView * acvtView = (WSAcvtView *)wself.delegate;
                    if ([acvtView.delegate isKindOfClass:[WSAcvtViewController class]])
                    {
                        if ([acvtView.delegate respondsToSelector:@selector(jumpActivityWithFv:)])
                        {
                            [(WSAcvtViewController *)acvtView.delegate jumpActivityWithFv:fv];
                        }
                    }
                }
            }
        }else if ([firstObjectString  isEqualToString:@"isOpenGps"]) {
            
            result = @"true";
            if (![[WSLocationManager getInstance] currentLocationServicesEnabled]) {
                result = @"false";
            }
            
        }else if ([firstObjectString  isEqualToString:@"isNetValid"]) {
            
            result = @"true";
            NetworkStatus status = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
            if (status == NotReachable)
            {
                result = @"false";
            }
        }else if ([firstObjectString  isEqualToString:@"getRoutId"]) {
            
            result = @"";
            result = [[NSUserDefaults standardUserDefaults] objectForKey:@"routeId"];
        }
        else if ([firstObjectString  isEqualToString:@"getParentFuncCode"]) {
            
            WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
            NSString *parentFuncsCode = nil;
            if ([model isKindOfClass:[WSAcvtModel class]]) {
                WSAcvtModel *acvtModel = (WSAcvtModel *)model;
                WSBaseFunsDBService *db = [[WSBaseFunsDBService alloc]init];
                parentFuncsCode = [db getParentFuncsCode:acvtModel.currentFuncs.fc];
                parentFuncsCode = [db getParentFuncsCode:parentFuncsCode];

            }
            result =  parentFuncsCode;
        }
        else if ([firstObjectString  isEqualToString:@"jumpWebView"]) {
            
            NSArray *dataArray = [secondObjString componentsSeparatedByString:@"@#"];
            
            WinJSBridgeViewController *vc = [[WinJSBridgeViewController alloc] init];
            if (dataArray.count > 0) {
                NSString *str = [NSString stringNotNilWithValue:[dataArray objectAtIndex:0]];
                str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                vc.externalOpenUrl = [NSString stringNotNilWithValue:str];
            }
            
            NSMutableDictionary *parameterDic = [[NSMutableDictionary alloc] init];
            if (dataArray.count > 1) {
                NSString *str = [NSString stringNotNilWithValue:[dataArray objectAtIndex:1]];
                str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                [parameterDic setValue:str forKey:Win_JSBridge_Parameter_VisitStoreDuration_Mark];
            }
            if (dataArray.count > 2) {
                NSString *str = [NSString stringNotNilWithValue:[dataArray objectAtIndex:2]];
                str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                [parameterDic setValue:str forKey:Win_JSBridge_Parameter_VisitStoreRemind_Mark];
            }
            vc.externalInfoDic = parameterDic;
            
            LogInfo(@"WSGetDataByMethodExecutor getLuaScriptWithParamsExpandBlock jumpWebView 1 secondObjString=%@ externalOpenUrl=%@ externalInfoDic=%@", secondObjString, vc.externalOpenUrl, vc.externalInfoDic);
                
            WSInterAction *interaction = [[WSInterAction alloc] init];
            [interaction setDirect_type:DIRECT_TYPE_PUSH];
            [interaction setExecute_controller:vc];
            if ([self.delegate respondsToSelector:@selector(executeInterAction:)]) {
                [self.delegate executeInterAction:interaction];
            }
            return @"";
        }else if([firstObjectString isEqualToString:@"setNewAcvtTitle"]){
            WSAcvtView * acvtView = (WSAcvtView *)wself.delegate;
            if (acvtView.acvtViewDelegate&& [acvtView.acvtViewDelegate respondsToSelector:@selector(acvtViewReloadHeaderTitle:)]) {
                [acvtView.acvtViewDelegate acvtViewReloadHeaderTitle:secondObjString];
            }
        }else if ([firstObjectString  isEqualToString:@"setStoreExitTime"]) {
            
            WSAcvtView *acvtView = (WSAcvtView *)wself.delegate;
            if ([acvtView.delegate isKindOfClass:[WSEnterOrLeaveStoreBaseAcvtViewController class]]) {
                WSEnterOrLeaveStoreBaseAcvtViewController *vc = (WSEnterOrLeaveStoreBaseAcvtViewController *)acvtView.delegate;
                //转换时间，参考进离店时间转换方式
                NSTimeInterval timeInterval = [secondObjString longLongValue]/1000;
                [vc setStoreExitTime:[NSString stringWithFormat:@"%f",timeInterval]];
            }
            result = @"";
        } else if ([firstObjectString  isEqualToString:@"getHHmmssByTime"]) {
            //参考进离店时间算法，[WSCurrentTime getServerTime]
            NSTimeInterval timeInterval = [secondObjString longLongValue]/1000;
            NSString * time = [WSCurrentTime getTimeStringbyMills:timeInterval];
            result = time;
        }
        if (result && [result length] > 0) {
            return result;
        }
        return @"";
    };
    
    return [paramExpanedBlock copy];
}

- (void)setExecuteMethodParamAndDirect_typeByInteraction:(WSInterAction *)interaction  params:(NSObject *)params
{
    [interaction setExecute_method_param:params];
    [interaction setDirect_type:DIRECT_TYPE_METHOD_WITH_SINGLEPARAM];
    if ([self.delegate respondsToSelector:@selector(executeInterAction:)]) {
        [self.delegate executeInterAction:interaction];
    }
    self.delegate = nil;
}

- (void)insertVisitStoreAcvtDataWithKeyArray:(NSArray *)keyArray valueArray:(NSArray *)valueArray {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[keyArray count]];
    for (NSInteger i = 0; i < [keyArray count]; i++) {
        NSString *value = valueArray[i];
        if ([value length] > 0) {
            dic[keyArray[i]] = valueArray[i];
        } else {
            if ([keyArray[i] isEqualToString:@"biz_date"]) {
                dic[keyArray[i]] = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
            } else {
                dic[keyArray[i]] = [NSNull null];
            }
        }
    }
    // sid,acvtid,acvtqstid,acvt_qst_answer,gen_id,assetid,opt_value,emp_id,biz_date,newStoreId,mClickTime
    NSMutableArray *qstDatas = [NSMutableArray arrayWithCapacity:[keyArray count]];
    [qstDatas addObject:dic[@"sid"]];
    [qstDatas addObject:dic[@"acvtId"]];
    [qstDatas addObject:dic[@"acvtQstId"]];
    [qstDatas addObject:dic[@"acvt_qst_answer"]];
    [qstDatas addObject:dic[@"gen_id"]];
    [qstDatas addObject:dic[@"assetId"]];
    [qstDatas addObject:dic[@"opt_value"]];
    [qstDatas addObject:dic[@"emp_id"]];
    [qstDatas addObject:dic[@"biz_date"]];
    [qstDatas addObject:[NSNull null]]; // newstoreid
    [qstDatas addObject:[NSNull null]];  //mClickTime
    
    [[WSVisitStoreAcvtDataTable sharedTable] insertWithArgumentsValue:qstDatas];
}

@end

//2017-0929-yuanji-add
#pragma mark - WSGetDataByMethodExecutor 延展(工具)
@implementation WSGetDataByMethodExecutor (Tools)

#pragma mark - 替换Base_store_table与id方法
- (NSString *)replaceBase_store_tableAndId:(NSString *)objString
{
    if(!objString || objString.length <= 0)
        return objString;
    
    NSString *firstStr = [objString stringByReplacingOccurrencesOfString:@" base_store_table" withString:@" ws_base_store_table"];
    NSString *secondStr = [firstStr stringByReplacingOccurrencesOfString:@" ws_base_store_table._id" withString:@" ws_base_store_table.store_Id"];
    NSString * threeStr = [secondStr stringByReplacingOccurrencesOfString:@" ws_base_store_table.cod" withString:@" ws_base_store_table.code"];
     threeStr = [threeStr stringByReplacingOccurrencesOfString:@" base_store_visitplan" withString:@" ws_base_store_visitplan"];

    // 安卓的 visit_store_acvt_data 中的acvtQstId 为 问题的 qsttype与问题acvtQstId 拼起来的
    NSString * latStr = [threeStr stringByReplacingOccurrencesOfString:@"(qst.qsttype || qst._id) as" withString:@""];
    // 安卓的acvt_qst_opt的id是acvtQstId的qstid，ios是acvtqstid
    if([latStr containsString:@"opt.acvtQstId=baq.qstId"]){
       NSString* latStr1 = [latStr stringByReplacingOccurrencesOfString:@"opt.acvtQstId=baq.qstId" withString:@"opt.acvtQstId=baq._id"];
        return latStr1;
    }
    return latStr;
}
//donghong YIHAIKERRY-2654
- (NSString*)getStatus:(NSString*)status
{
    if ([status isEqualToString:ActionNotStart]) {
        status = ActionDone;
    } else if ([status isEqualToString:ActionDone]){
        status = ActionWorking;
    }else if ([status isEqualToString:ActionWorking]){
        status = ActionNotStart;
    }
return status;
}

#pragma mark - 获取新的genid方法 param:参数
- (NSString *)getNewGenId:(NSString *)param
{
    NSString *md5 = [Md5Manager getMd5ByEmpId:((param.length > 0) ? param : @"") sotreId:nil bizDate:nil funcCode:nil acvtId:nil memo:nil dateType:@"E"];
    return md5;
}

@end

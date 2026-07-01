//
//  WSStatisticsManager.m
//  WinSFA
//
//  Created by yang on 17/6/1.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSStatisticsManager.h"
#import "WSUserBehaviorDBService.h"
#import "WSJSONBuilder.h"
#import "WSRequestHelper.h"
#import "WSEnvrionment.h"

static WSStatisticsManager *_instance;

@interface WSStatisticsManager ()


@property (nonatomic, strong) NSMutableDictionary *uploadDataIDDic;

//@property (nonatomic, strong) dispatch_queue_t uploadStatisticsQueue;

@end

@implementation WSStatisticsManager

+ (WSStatisticsManager*)sharedInstance
{
    if (!_instance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[WSStatisticsManager alloc] init];
            _instance.uploadDataIDDic = [NSMutableDictionary dictionary];
//            _instance.uploadStatisticsQueue = dispatch_queue_create("net.winchannel.sfa.UploadStatisticsQueue", DISPATCH_QUEUE_SERIAL);
        });
    }
    
    return _instance;
}

+ (NSString *)getGenId {
    
    return [[WSJSONBuilder gen_uuid] md5];
}

- (BOOL)insertLoginSenceEventWithID:(NSString *)eventID
                          startTime:(NSString *)startTime
                            endTime:(NSString *)endTime
                         eventValue:(NSString *)eventValue
                              genId:(NSString *)genId
{
    if (![WSEnvrionment isOpenUserStatistics]) {
        return NO;
    }
    
    return [WSUserBehaviorDBService insertWithUserAccount:[[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_BEGIN_LOGIN]
                                    parentFuncBean:nil
                                   currentFuncBean:nil
                                             store:nil
                                           sceneId:SCENE_LOGIN
                                           eventId:eventID
                                         startTime:startTime
                                           endTime:endTime
                                        eventValue:eventValue
                                             genId:genId];
}

- (BOOL)insertWebPageSenceEventWithID:(NSString *)eventID
                       parentFuncBean:(WSFuncsBean *)parentFuncBean
                      currentFuncBean:(WSFuncsBean *)currentFuncBean
                                store:(WSStoreBean *)store
                            startTime:(NSString *)startTime
                              endTime:(NSString *)endTime
                                genId:(NSString *)genId
{
    if (![WSEnvrionment isOpenUserStatistics]) {
        return NO;
    }
    
    return [WSUserBehaviorDBService insertWithUserAccount:nil
                                    parentFuncBean:parentFuncBean
                                   currentFuncBean:currentFuncBean
                                             store:store
                                           sceneId:SCENE_WEB_PAGE
                                           eventId:eventID
                                         startTime:startTime
                                           endTime:endTime
                                        eventValue:nil
                                             genId:genId];
}

- (BOOL)insertNormalPageSenceEventWithID:(NSString *)eventID
                          parentFuncBean:(WSFuncsBean *)parentFuncBean
                         currentFuncBean:(WSFuncsBean *)currentFuncBean
                                   store:(WSStoreBean *)store
                               startTime:(NSString *)startTime
                                 endTime:(NSString *)endTime
                                   genId:(NSString *)genId
{
    if (![WSEnvrionment isOpenUserStatistics]) {
        return NO;
    }
    
    return [WSUserBehaviorDBService insertWithUserAccount:nil
                                    parentFuncBean:parentFuncBean
                                   currentFuncBean:currentFuncBean
                                             store:store
                                           sceneId:SCENE_NORMAL_PAGE
                                           eventId:eventID
                                         startTime:startTime
                                           endTime:endTime
                                        eventValue:nil
                                             genId:genId];
}

- (BOOL)insertMenuPageSenceEventWithID :(NSString *)eventID
                        parentFuncBean :(WSFuncsBean *)parentFuncBean
                        currentFuncBean :(WSFuncsBean *)currentFuncBean
                                 store :(WSStoreBean *)store
                            eventValue :(NSString *)eventValue
                              startTime :(NSString *)startTime
                                endTime :(NSString *)endTime
                                  genId :(NSString *)genId
{
    if (![WSEnvrionment isOpenUserStatistics]) {
        return NO;
    }
    
    return [WSUserBehaviorDBService insertWithUserAccount:nil
                                           parentFuncBean:parentFuncBean
                                          currentFuncBean:currentFuncBean
                                                    store:store
                                                  sceneId:SCENE_MENU
                                                  eventId:eventID
                                                startTime:startTime
                                                  endTime:endTime
                                               eventValue:eventValue
                                                    genId:genId];
}

- (BOOL) insertAddProductSenceEventWithID :(NSString *)eventID
                           parentFuncBean :(WSFuncsBean *)parentFuncBean
                          currentFuncBean :(WSFuncsBean *)currentFuncBean
                                    store :(WSStoreBean *)store
                               eventValue :(NSString *)eventValue
                                startTime :(NSString *)startTime
                                  endTime :(NSString *)endTime
                                    genId :(NSString *)genId
{
    
    if (![WSEnvrionment isOpenUserStatistics]) {
        return NO;
    }
    
    return [WSUserBehaviorDBService insertWithUserAccount:nil
                                           parentFuncBean:parentFuncBean
                                          currentFuncBean:currentFuncBean
                                                    store:store
                                                  sceneId:SCENE_ADDPRODUCT
                                                  eventId:eventID
                                                startTime:startTime
                                                  endTime:endTime
                                               eventValue:eventValue
                                                    genId:genId];
}

- (BOOL) insertStoreInfoSenceEventWithID :(NSString *)eventID
                          parentFuncBean :(WSFuncsBean *)parentFuncBean
                         currentFuncBean :(WSFuncsBean *)currentFuncBean
                                   store :(WSStoreBean *)store
                                senceId :(NSString *)senceId
                              eventValue :(NSString *)eventValue
                               startTime :(NSString *)startTime
                                 endTime :(NSString *)endTime
                                   genId :(NSString *)genId;
{
    if (![WSEnvrionment isOpenUserStatistics]) {
        return NO;
    }
    
    return [WSUserBehaviorDBService insertWithUserAccount:nil
                                           parentFuncBean:parentFuncBean
                                          currentFuncBean:currentFuncBean
                                                    store:store
                                                  sceneId:senceId
                                                  eventId:eventID
                                                startTime:startTime
                                                  endTime:endTime
                                               eventValue:eventValue
                                                    genId:genId];
}


- (BOOL)updateEndTime:(NSString *)endTime withGenID:(NSString *)genID {
    
    if (![WSEnvrionment isOpenUserStatistics]) {
        return NO;
    }
    
    return [WSUserBehaviorDBService updateEndTime:endTime withGenID:genID];
}

- (BOOL)updateStartTime:(NSString *)startTime withGenID:(NSString *)genID {
    
    if (![WSEnvrionment isOpenUserStatistics]) {
        return NO;
    }
    
    return [WSUserBehaviorDBService updateStartTime:startTime withGenID:genID];
}

- (void)uploadStatisticsLogs {
    
    if (![WSEnvrionment isOpenUserStatistics]) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSArray *objArray = [WSUserBehaviorDBService queryAllDicArray];
        
        if ([objArray count] > 0) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSMutableArray *dataArray  = [NSMutableArray array];
                
                for (NSDictionary *dic in objArray) {
                    NSMutableDictionary *dicMutable = [dic mutableCopy];
                    NSArray *keyArray = [dicMutable allKeys];
                    for (NSString *key in keyArray) {
                        id obj = [dicMutable objectForKey:key];
                        if ([obj isKindOfClass:[NSNull class]] ) {
                            [dicMutable removeObjectForKey:key];
                        }
                    }
                    [dataArray addObject:dicMutable];
                }
                
                LogInfo(@"上传统计数据%lu条", (unsigned long)[dataArray count]);
                
                
                NSString *notifyID = [NSString stringWithFormat:@"%@%@", kOfflineTableNotifyIdPrefix, [WSJSONBuilder gen_uuid]];
                
                NSArray *idArray = [dataArray valueForKey:@"_id"];
                [self.uploadDataIDDic setObject:idArray forKey:notifyID];
                
                NSDictionary *postDataDic = [WSJSONBuilder buildStatisticsDatas:dataArray];
                
                [[WSRequestHelper shareInstance] uploadStatisticsDatas:postDataDic notifyName:notifyID];
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadStatisticsDataFinish:) name:notifyID object:nil];

            });

        }
    });
    
    
}

- (void)uploadStatisticsDataFinish:(NSNotification *)notification {
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notification.name object:nil];
    
    NSArray *idArray = [self.uploadDataIDDic objectForKey:notification.name];
    [self.uploadDataIDDic removeObjectForKey:notification.name];
    
    NSError *error = [[notification userInfo] objectForKey:ERROR];
    if (error)
    {
        LogError(@"上传统计数据失败：%@", error);
        return;
    }
    
    LogInfo(@"上传统计数据成功，%lu条", (unsigned long)idArray.count);
    
    NSString *info = [[notification userInfo] objectForKey:DATAS];
    NSDictionary *infoDic = [info objectFromJSONString];
    NSString *result = [infoDic objectForKey:@"result"];
    
    if ([result isEqualToString:@"1"]) {
        [WSUserBehaviorDBService deleteDataWithIDArray:idArray];
    }
    
    
}

@end

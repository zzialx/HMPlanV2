//
//  WSUserBehaviorDBService.h
//  WinSFA
//
//  Created by yang on 17/5/27.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSDBService.h"

@interface WSUserBehaviorDBService : WSDBService

+ (BOOL)insertWithUserAccount:(NSString *)userAccount
               parentFuncBean:(WSFuncsBean *)parentFuncBean
              currentFuncBean:(WSFuncsBean *)currentFuncBean
                        store:(WSStoreBean *)store
                      sceneId:(NSString *)sceneId
                      eventId:(NSString *)eventId
                    startTime:(NSString *)startTime
                      endTime:(NSString *)endTime
                   eventValue:(NSString *)eventValue
                        genId:(NSString *)genId;

+ (BOOL)updateEndTime:(NSString *)endTime withGenID:(NSString *)genID;

+ (BOOL)updateStartTime:(NSString *)startTime withGenID:(NSString *)genID;

+ (NSArray *)queryDicArrayForYestoday;

+ (BOOL)deleteDataForYestoday;

+ (NSArray *)queryAllDicArray;

+ (BOOL)deleteDataWithIDArray:(NSArray *)idArray;

@end

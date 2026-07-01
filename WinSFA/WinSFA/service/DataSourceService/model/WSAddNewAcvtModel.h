//
//  WSAddNewAcvtModel.h
//  WinSFA
//
//  Created by yang on 15/8/19.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSAcvtModel.h"

@interface WSAddNewAcvtModel : WSAcvtModel

@property (nonatomic ,strong) NSArray *acvtNewStoreQstInfos;


- (NSString *)getAcvtNewStoreServeRedisValueForStoreByQstId:(NSString *)qstId;

- (NSMutableArray *)getTAServerRedisValueForStoreByQstId:(NSString *)qstId;


@end

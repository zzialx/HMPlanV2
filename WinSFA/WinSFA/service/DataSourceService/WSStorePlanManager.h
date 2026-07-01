//
//  WSStorePlanManager.h
//  WinSFA
//
//  Created by mac on 2019/1/17.
//  Copyright © 2019年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WSVisitStorePlanObject;

@interface WSStorePlanManager : NSObject

+ (WSStorePlanManager*)sharedInstance;

@property (nonatomic, strong) WSVisitStorePlanObject *currentActiveModel;

@property (nonatomic, strong) NSMutableArray *storePlanArr;

@property (nonatomic, strong) NSMutableArray *storePlanTime;

@property (nonatomic, strong) NSMutableDictionary *fcTime;

@property (nonatomic, strong) NSMutableDictionary *isChangeDic;


@property (nonatomic, strong) NSMutableArray *storePlanOldArr;

@property (nonatomic, assign) BOOL isChange;



- (void)deleteData;

@end

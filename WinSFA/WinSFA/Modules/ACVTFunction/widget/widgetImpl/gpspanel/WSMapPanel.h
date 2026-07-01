//
//  WSMapPanel.h
//  WinSFA
//
//  Created by winchannel on 15/3/12.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSWidget.h"
@class WSLocationDescribe;
@class WSStoreBean;
//=============================================================================================================================================================

@interface WSMapPanel : WSWidget

@property (nonatomic, strong) WSLocationDescribe *locationDescribe;
@property (nonatomic, strong) WSStoreBean *currentStore;
@property (nonatomic, strong) NSDate *mapInitDate;
@property (nonatomic, assign) BOOL hasRedisLocation;
@property (nonatomic, assign) BOOL isGpsReady;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, copy) NSString *mapReadOnly;

- (void)refeshLocation:(NSString *)params;

@end
//=============================================================================================================================================================

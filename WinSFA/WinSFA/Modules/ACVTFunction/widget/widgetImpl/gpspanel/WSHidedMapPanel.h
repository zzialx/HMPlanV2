//
//  WSHidedMapPanel.h
//  WinSFA
//
//  Created by xiajl on 15/3/24.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSWidget.h"

@class WSLocationDescribe;

@interface WSHidedMapPanel : WSWidget

@property (nonatomic, strong) WSLocationDescribe *locationDescribe;
/**
 *  位置信息 上传时校验用
 */
@property (nonatomic, strong) CLLocation                *location;

//Latitude and Longitude is ready
@property (nonatomic, assign) BOOL isGpsReady;

@end

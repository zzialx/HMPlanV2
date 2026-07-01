//
//  WCBaseGeographicInfo.h
//  WinSFA
//
//  Created by xiaotang.wang on 7/19/13.
//  Copyright (c) 2013 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSBaseGeographicInfo : NSObject

@property (nonatomic, copy)NSString *iPid;
@property (nonatomic, copy)NSString *iId;
@property (nonatomic, copy)NSString *iPName;
@property (nonatomic, copy)NSString *iName;
@property (nonatomic, copy)NSString *iLevelCode;
@property (nonatomic, copy)NSString *iType; // 省，市，区
@property (nonatomic, strong)NSMutableArray *iGeographicInfos;

- (id)initWithObject:(id)aObject;

@end

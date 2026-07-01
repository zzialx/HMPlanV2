//
//  WSPointInfoArray.h
//  WinSFA
//
//  Created by xiaotang.wang on 9/5/13.
//  Copyright (c) 2013 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    WSPointInfoBrandType,
    
    WSPointInfoAuditType,
    
    WSPointInfoAuditProjectType,
    
    WSPointInfoClassType
    
}WSPointInfoType;


@interface WSPointInfo : NSObject

@property (nonatomic, copy)NSString *iPointPid;
@property (nonatomic, copy)NSString *iPointId;
@property (nonatomic, copy)NSString *iPointName;
@property (nonatomic, assign)WSPointInfoType iPointInfoType;
@property (nonatomic, strong)NSMutableArray *iPointInfoArray;


- (id)initWithObject:(NSDictionary *)aObj withPointInfoType:(WSPointInfoType) aType;

@end

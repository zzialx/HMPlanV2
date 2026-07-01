//
//  WSPointInfoArray.m
//  WinSFA
//
//  Created by xiaotang.wang on 9/5/13.
//  Copyright (c) 2013 WinChannel. All rights reserved.
//

#import "WSPointInfo.h"

NSString *const kWSPointInfoPid = @"pId";
NSString *const kWSPointInfoId = @"id";
NSString *const kWSPointInfoName = @"name";
NSString *const kWSPointInfoAudittype = @"audittype";
NSString *const kWSPointInfoAuditproject = @"auditproject";
NSString *const kWSPointInfoClasstype = @"classtype";

@implementation WSPointInfo

@synthesize iPointPid = _iPointPid;
@synthesize iPointId = _iPointId;
@synthesize iPointName = _iPointName;
@synthesize iPointInfoType = _iPointInfoType;
@synthesize iPointInfoArray = _iPointInfoArray;

- (id)initWithObject:(NSDictionary *)aObj withPointInfoType:(WSPointInfoType) aType
{
    self = [super init];
    if (self != nil) {
        id obj = [aObj objectForKey:kWSPointInfoPid];
        if (obj != nil) {
            _iPointPid = [[NSString stringWithValue: obj] copy];
        }
        
        obj = [aObj objectForKey:kWSPointInfoId];
        if (obj != nil) {
            _iPointId = [[NSString stringWithValue: obj] copy];
        }
        
        obj = [aObj objectForKey:kWSPointInfoName];
        if (obj != nil) {
            _iPointName = [obj copy];
        }
        _iPointInfoType = aType;
        
        NSString *keyname = nil;
        WSPointInfoType type = WSPointInfoBrandType;
        if (aType == WSPointInfoBrandType) {
            keyname = kWSPointInfoAudittype;
            type = WSPointInfoAuditType;
        }else if (aType == WSPointInfoAuditType){
            keyname = kWSPointInfoAuditproject;
            type = WSPointInfoAuditProjectType;
        }else if (aType == WSPointInfoAuditProjectType){
            keyname = kWSPointInfoClasstype;
            type = WSPointInfoClassType;
        }else{
            // Do nothing
        }
        if (keyname != nil) {
            NSArray *infoArray = [aObj objectForKey:keyname];
            if (infoArray != nil && [infoArray count] > 0) {
                if (_iPointInfoArray == nil) {
                    _iPointInfoArray = [[NSMutableArray alloc] initWithCapacity:4];
                }
                for (NSDictionary *dic in infoArray) {
                    WSPointInfo *info = [[WSPointInfo alloc] initWithObject:dic withPointInfoType:type];
                    [_iPointInfoArray addObject:info];
                }
            }
        }
    }
    return self;
}


@end

//
//  WCBaseGeographicInfo.m
//  WinSFA
//
//  Created by xiaotang.wang on 7/19/13.
//  Copyright (c) 2013 WinChannel. All rights reserved.
//

#import "WSBaseGeographicInfo.h"

@implementation WSBaseGeographicInfo

@synthesize iPid = _iPid;
@synthesize iId = _iId;
@synthesize iPName = _iPName;
@synthesize iName = _iName;
@synthesize iLevelCode = _iLevelCode;
@synthesize iType = _iType;
@synthesize iGeographicInfos = _iGeographicInfos;

- (id)initWithObject:(id)aObject
{
    if (aObject == nil || ![aObject isKindOfClass:[NSDictionary class]]) return nil;
    
    self = [super init];
    if (self != nil) {
        
        _iGeographicInfos = [[NSMutableArray alloc] init];
        
        NSDictionary *dic = (NSDictionary *)aObject;
        
        NSNumber *pid = [dic objectForKey:GEOPID];
        _iPid = [pid stringValue];
        
        NSNumber *objid = [dic objectForKey:GEOID];
        _iId = [objid stringValue];
        
        _iPName = [dic objectForKey:GEOPNAME];
        _iName = [dic objectForKey:GNAME];
        
        NSNumber *levelCode = [dic objectForKey:GEOLEVELCODE];
        _iLevelCode = [levelCode stringValue];
        
        NSArray *infos = nil;
        if ((infos = [dic objectForKey:GEOCITYS]) != nil) {
            _iType = @"province";
            
        }else if((infos = [dic objectForKey:AREAS]) != nil)
        {
            _iType = @"city";
        }
        
        if (infos == nil) {
            _iType = @"area";
        }
        
        for (NSDictionary *dic in infos) {
            WSBaseGeographicInfo *item = [[WSBaseGeographicInfo alloc] initWithObject:dic];
            [_iGeographicInfos addObject:item];
        }
        
    }
    
    return self;
    
}

@end

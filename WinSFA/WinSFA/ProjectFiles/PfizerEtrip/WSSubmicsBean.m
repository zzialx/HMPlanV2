//
//  WSSubmicsBean.m
//  WinSFA
//
//  Created by zhangke on 14-5-16.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSSubmicsBean.h"

@implementation WSSubmicsBean
@synthesize empId = _empId;
@synthesize id_ = _id_;
@synthesize name = _name;
@synthesize code = _code;
@synthesize level_code = _level_code;
@synthesize sub_level_code = _sub_level_code;
@synthesize subempStoreArray = _subempStoreArray;
@synthesize org_id = _org_id;
@synthesize org_name = _org_name;



- (id)initWithObject:(id)object
{
    if (nil == object) {
        return nil;
    }
    self = [super init];
    if (self) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *dic = (NSDictionary *)object;
            _empId = [[NSString stringWithValue:[dic objectForKey:SUBMICS_EMPID]] copy];
            _id_ = [[NSString stringWithValue:[dic objectForKey:SUBMICS_ID]] copy];
            _name = [[NSString stringWithValue:[dic objectForKey:SUBMICS_NAME]] copy];
            _code = [[NSString stringWithValue:[dic objectForKey:SUBMICS_CODE]] copy];
            _level_code = [[NSString stringWithValue:[dic objectForKey:SUBMICS_LEVEL_CODE]] copy];
            _sub_level_code = [[NSString stringWithValue:[dic objectForKey:SUBMICS_SUB_LEVEL_CODE]] copy];
            _org_id = [[NSString stringWithValue:[dic objectForKey:SUBMICS_ORG_ID]] copy];
            _org_name = [[NSString stringWithValue:[dic objectForKey:SUBMICS_ORG_NAME]] copy];

            _subempStoreArray=[[WSSubempstoreBeanArray alloc] initWithObject:dic noteName:SUBMICS_IN];

        }
    }
    
    return self;
}


- (id)copyWithZone:(NSZone *)zone {
    WSSubmicsBean *copy = [[[self class] allocWithZone:zone] init];
    
    copy.empId = [self.empId copy];
    copy.id_ = [self.id_ copy];
    copy.code = [self.code copy];
    copy.name = [self.name copy];
    copy.level_code = [self.level_code copy];
    copy.sub_level_code = self.sub_level_code;
    copy.code = [self.code copy];
    copy.org_id = [self.org_id copy];
    copy.org_name = [self.org_name copy];
    copy.subempStoreArray = self.subempStoreArray;
    
    return copy;
}



@end

//
//  WSOrgBean.m
//  WinSFA
//
//  Created by heju on 16/9/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSOrgBean.h"


@implementation WSOrgBean

- (id)initWithObject:(id)object{
    
    if (object == nil) {
        return nil;
    }
    self = [super init];
    if (self) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            
            _selectedChildren = [[NSMutableArray alloc] init];
        
            _orgId = [NSString stringWithValue:object[@"orgId"]];
            
            _name =[NSString stringWithValue:[object objectForKey:@"name"]];
            
            _parentId = [NSString stringWithValue:object[@"parentId"]];
            
            _empId = [NSString stringWithValue:object[@"empId"]];
            
            _orgType = [NSString stringWithValue:[object objectForKey:@"orgType"]];
            
            _level = [NSString stringWithValue:[object objectForKey:@"level"]];
        }
        
     }
    return self;
}

#pragma mark - I_W_OptionDataItem


- (void)setSelectedStatus:(BOOL)status {
    _status = status;
}

- (BOOL)getSelectedStatus {
    return self.status;
}

- (NSString *)getDataItemID{
    
    return self.orgId;
}
- (NSString *)getDataItemName{
    
    return self.name;
}




#pragma mark - I_W_Children_DataSource

- (NSMutableArray *)getChildren {
    return self.childen;
}


@end

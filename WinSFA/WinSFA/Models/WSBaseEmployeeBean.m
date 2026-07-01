//
//  WSBaseEmployeeBean.m
//  WinSFA
//
//  Created by winchannel on 15/12/28.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSBaseEmployeeBean.h"

@implementation WSBaseEmployeeBean

- (id)initWithObject:(id)object{

    if (object == nil) {
        return nil;
    }
    self = [super init];
    if (self) {
        
        self.empId = [NSString stringNotNilWithValue:[object objectForKey:@"empId"]];
        self.Id =[NSString stringNotNilWithValue:[object objectForKey:@"id"]];
        self.name = [NSString stringNotNilWithValue:[object objectForKey:@"name"]];
        self.type = [NSString stringNotNilWithValue:[object objectForKey:@"type"]];
        self.pid = [NSString stringNotNilWithValue:[object objectForKey:@"pid"]];
    
    }
    return self;
}

#pragma mark - I_W_OptionDataItem
- (NSString *)getDataItemID{
    
    return self.Id;
}
- (NSString *)getDataItemName{
    
    return self.name;
}
@end

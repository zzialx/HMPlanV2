//
//  WSBaseEmployeeBeanArray.m
//  WinSFA
//
//  Created by winchannel on 15/12/28.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSBaseEmployeeBeanArray.h"
#import "WSBaseEmployeeBean.h"
@implementation WSBaseEmployeeBeanArray

- (id)initWithObject:(id)object{
    if (object == nil) {
        return nil;
        
    }
    self = [super init];
    if (self) {
        NSMutableArray *array =[[NSMutableArray alloc]init];
        
        NSArray *employeeBean =[object objectForKey:@"baseemployee"];
        
        for (NSDictionary *beanDic in employeeBean) {
            WSBaseEmployeeBean *bean = [[WSBaseEmployeeBean alloc]initWithObject:beanDic];
            
            if (bean) {
                
                [array addObject:bean];
            }
        }
        _baseEmployeeBeanArray = [[NSMutableArray alloc]initWithArray:array];
    }
    return self;
}
@end

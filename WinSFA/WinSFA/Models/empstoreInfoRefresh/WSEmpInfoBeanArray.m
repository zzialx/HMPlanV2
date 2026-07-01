//
//  EmpInfoBeanArray.m
//  WinChannelFrameWork
//
//  Created by ZhengJiepeng on 13-6-25.
//
//

#import "WSEmpInfoBeanArray.h"
#import "WSEmpInfoBean.h"

@implementation WSEmpInfoBeanArray

@synthesize empInfoBeanArray = _empInfoBeanArray;

- (id)initWithObject:(id)object {
    if (![object isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [super init];
    if(self != nil) {
        NSArray *array = [object objectForKey:EMPINFO];
        NSMutableArray *beanArray = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in array) {
            WSEmpInfoBean *empBean = [[WSEmpInfoBean alloc] initWithObject:dic];
            if (empBean) {
                [beanArray addObject:empBean];
            }
        }
        _empInfoBeanArray = [NSMutableArray arrayWithArray:beanArray];
        
//            NSArray *Array = [object objectForKey:EMPINFOREFRESHS];
//            [self initEmpinforefreshWithArray:Array];
//        }
        return self;
    }
    return nil;
    
    
}

@end

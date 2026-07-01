//
//  WSStoreAcvtArray.m
//  WinSFA
//
//  Created by yang on 15/10/14.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSStoreAcvtArray.h"
#import "WSStoreAcvtBean.h"

@implementation WSStoreAcvtArray {
    NSMutableDictionary *acvtArrayDic;
}

- (NSString *)getDefaultParseKey
{
    return STORE_ACVT_RELATION;
}

- (Class)getBeanSubclass
{
    return nil;
}

- (instancetype)initWithObject:(id)object {
    self = [super initWithObject:object];
    
    if (self) {
        [self processData];
        return self;
    }
    
    return nil;
}

- (instancetype)initWithObject:(id)object andKey:(NSString *)parserkey {
    self = [super initWithObject:object andKey:parserkey];
    
    if (self) {
        [self processData];
        return self;
    }
    
    return nil;
}

- (void)processData {
    
    acvtArrayDic = [NSMutableDictionary dictionary];
    
    for (NSDictionary *dic in self.beanArray) {
        if ([dic objectForKey:@"sid"] && ![[dic objectForKey:@"sid"] isKindOfClass:[NSNull class]]) {
            NSString *storeID = [NSString stringWithValue:[dic objectForKey:@"sid"]];
            NSMutableArray *array = [acvtArrayDic objectForKey:storeID];
            if (!array) {
                array = [NSMutableArray array];
                [acvtArrayDic setObject:array forKey:storeID];
            }
            
            [array addObject:dic];
        }
        
    }
}

- (NSArray *)getAcvtArrayWithStoreID:(NSString *)storeID {
    return [acvtArrayDic objectForKey:storeID];
}

@end

//
//  WSAcvtDisArray.m
//  WinSFA
//
//  Created by zhangke on 15/3/19.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSAcvtDisArray.h"



#import "WSAcvtDisQstBean.h"

@implementation WSAcvtDisArray
@synthesize acvtDisArray = _acvtDisArray;

-(id)initWithObject:(id)object {
    self = [super init];
    if (self) {
        /*
        NSArray *acvtdis = [object objectForKey:ACVTDIS];
        if (!acvtdis) {
            NSLog(@"acvtdis node  is nil");
            return nil;
        }
         */
        __block NSMutableArray *acvtdiss = [NSMutableArray array];
        if ([object isKindOfClass:[NSDictionary class]]) {
            [(NSDictionary *)object enumerateKeysAndObjectsUsingBlock:^(id   key, id  obj, BOOL *  stop) {
                if (key && [key isKindOfClass:[NSString class]] && ([key  isEqualToString:ACVTDIS] || [key rangeOfString:@"acvtdis:"].location != NSNotFound)) {
                    [acvtdiss addObjectsFromArray:(NSArray *)obj];
                }
            }];
        }
        if ([acvtdiss count] > 0) {
            [self initAcvtDisBeansWith:acvtdiss];
        }
        return self;
    }
    return nil;
}
- (id)initWithObjectForSer:(id)object notName:(NSString *)aNotName{
    
    if (nil == object) {
        return nil;
    }
    
    self = [super init];
    if (self != nil) {
         //_acvtDisArray = [[NSMutableArray alloc] init];
        if (aNotName) {
             __block NSMutableArray *array = [NSMutableArray array];
            if ([object isKindOfClass:[NSDictionary class]]) {
                [(NSDictionary *)object enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    if (key && [key isKindOfClass:[NSString class]] && [key hasPrefix:aNotName]) {
                        [array addObjectsFromArray:(NSArray *)obj];
                    }
                }];
                [self initAcvtDisBeansWith:array];
            }
        }
        return self;
    }
    return nil;
    
    
}
- (void)initAcvtDisBeansWith:(NSArray *)acvtdis {
    
    _acvtDisArray = [[NSMutableArray alloc] init];
    
    [acvtdis enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSDictionary *dictionary = (NSDictionary *)obj;
        
        WSAcvtDisQstBean *qstBean = [[WSAcvtDisQstBean alloc] initWithObject:dictionary];
        
        if (qstBean.acvtId && qstBean.qstId) {
            
            if ([_acvtDisArray count] == 0)
            {
                WSAcvtDisBean *acvtdisBean = [[WSAcvtDisBean alloc] initWithObject:dictionary];
                [acvtdisBean addQstDisBean:qstBean];
                [_acvtDisArray addObject:acvtdisBean];
            }
            else if([_acvtDisArray count] > 0)
            {
                BOOL findAcvtDisBean = NO;
                
                for (WSAcvtDisBean *acvtdisBean in _acvtDisArray)
                {
                    NSString *acvt_empId = acvtdisBean.empId;
                    NSString *acvt_Id = acvtdisBean.acvtId;
                    NSString *acvt_Gen_id = acvtdisBean.gen_id;
                    if ([qstBean.m_empId isEqualToString:acvt_empId] &&
                        [qstBean.acvtId isEqualToString:acvt_Id] &&
                        [qstBean.gen_id isEqualToString:acvt_Gen_id]) {
                        
                        [acvtdisBean addQstDisBean:qstBean];
                        
                        findAcvtDisBean = YES;
                        break;
                    }
                }
                if (!findAcvtDisBean)
                {
                    WSAcvtDisBean *tmpAcvtdisBean = [[WSAcvtDisBean alloc] initWithObject:dictionary];
                    [tmpAcvtdisBean addQstDisBean:qstBean];
                    [_acvtDisArray addObject:tmpAcvtdisBean];
                }
            }
        }
        
    }];
    
}

- (WSAcvtDisBean *)filterAcvtdisBeanWith:(NSString *)md5 {
    
    __block  WSAcvtDisBean *acvtdisBean = nil;
    [_acvtDisArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        WSAcvtDisBean *tmpAcvtdisBean = (WSAcvtDisBean *)obj;
        NSString *gen_id = tmpAcvtdisBean.gen_id;
        if ( gen_id && [md5 isEqualToString:gen_id]) {
            acvtdisBean = tmpAcvtdisBean;
        }
    }];
    return acvtdisBean;
}

- (WSAcvtDisBean *)filterAcvtdisBeanWith:(NSString *)md5 withAcvtId:(NSString *)acvtId{
    
    __block  WSAcvtDisBean *acvtdisBean = nil;
    
    [_acvtDisArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        WSAcvtDisBean *tmpAcvtdisBean = (WSAcvtDisBean *)obj;
        NSString *gen_id = tmpAcvtdisBean.gen_id;
        NSString *disAcvtId = tmpAcvtdisBean.acvtId;
        if ( gen_id && [md5 isEqualToString:gen_id] && disAcvtId  && [disAcvtId isEqualToString:acvtId]) {
            acvtdisBean = tmpAcvtdisBean;
        }
    }];
    return acvtdisBean;
}


- (WSAcvtDisBean *)filterAcvtdisBeanWithAcvtId:(NSString *)acvtId {
    __block  WSAcvtDisBean *acvtdisBean = nil;
    
    [_acvtDisArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        WSAcvtDisBean *tmpAcvtdisBean = (WSAcvtDisBean *)obj;
        NSString *disAcvtId = tmpAcvtdisBean.acvtId;
        if ( [disAcvtId isEqualToString:acvtId]) {
            acvtdisBean = tmpAcvtdisBean;
        }
    }];
    return acvtdisBean;
}

/*
-(id)initWithObject:(id)object
{
    if([object isKindOfClass:[NSDictionary class]])
    {
        self = [super init];
        if(self)
        {
            NSArray *Array = [object objectForKey:ACVTDIS];
            [self initStoreAcvtDisWithArray:Array];
        }
    }
    return self;
}

-(void)initStoreAcvtDisWithArray:(NSArray*)array
{
    _acvtDisArray = [[NSMutableArray alloc] init];
    if ([array isKindOfClass:[NSArray class]]){
        
        if (array != nil){
            int i_arrayCount = [array count];
            for (int i = 0; i < i_arrayCount; i++)
            {
                WSAcvtDisQstBean* f_sad = [[WSAcvtDisQstBean alloc]initWithObject:[array objectAtIndex:i]];
                [_acvtDisArray addObject:f_sad];
                f_sad = nil;
            }
        }
    }
}
 */



@end

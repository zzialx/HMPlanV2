//
//  AcvtBeanArray.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSAcvtBeanArray.h"
#import "WSAcvtBean.h"

@implementation WSAcvtBeanArray
@synthesize acvtArray = _acvtArray;


-(void)initAcvtWithArray:(NSArray*)array
{
    if (!_acvtArray) {
        _acvtArray = [[NSMutableArray alloc] init];
    }
    
    if ([array isKindOfClass:[NSArray class]]){
        
        if (array != nil){ 
            
            for (int i = 0; i < [array count]; i++) {
                WSAcvtBean *dict = [[WSAcvtBean alloc] initWithObject:[array objectAtIndex:i]];
                
                
                [self.acvtArray insertObject:dict atIndex:i];
            }
        }
    }
}
-(id)initWithObject:(id)object
{
    self = [super init];
    if(self != nil)
    {
        if ([object isKindOfClass:[NSDictionary class]]){
            
            [(NSDictionary *)object enumerateKeysAndObjectsUsingBlock:^(id  key, id  obj, BOOL * stop) {
                
                if (key && [key isKindOfClass:[NSString class]] ) {
                    if ([key isEqualToString:@"acvt"] || [key hasPrefix:@"acvt:"]) {
                        NSArray *Array = [object objectForKey:key];
                        [self initAcvtWithArray:Array];
                    }

                }
            }];
        }
        return self;
    }
    return nil;
}

- (NSArray*)getDistinctAcvtsWithFilter:(NSString*)filter
{
    NSMutableArray *Array = [[NSMutableArray alloc]init];
    
    NSMutableArray *acvtIDArray = [[NSMutableArray alloc] init];
    
    for(WSAcvtBean* ab in self.acvtArray)
    {
        if([ab.typ isEqualToString:filter])
        {
            if (![acvtIDArray containsObject:ab.acvtId] && [ab.acvtId length] > 0) {
                [Array addObject:ab];
                [acvtIDArray addObject:ab.acvtId];
            }
        }
        
    }
    return Array;
}


- (NSArray*)getAcvtsWithFilter:(NSString*)filter
{
    NSMutableArray* Array = [[NSMutableArray alloc]init];
    for(WSAcvtBean* ab in self.acvtArray)
    {
        if([ab.typ isEqualToString:filter])
        {
            [Array addObject:ab];
        }
            
    }
    return Array;
}

-(NSArray*)getAcvtsWithFilter:(NSString*)filter withEmpid:(NSString*)empid
{
    NSMutableArray* Array = [[NSMutableArray alloc]init];
    for(WSAcvtBean* ab in self.acvtArray)
    {
        if([ab.typ isEqualToString:filter])
        {
            if(ab.submitempid!=nil && ab.submitempid.length>0){
                if([empid isEqualToString:ab.submitempid]){
                    [Array addObject:ab];
                    
                }
                
            }
            else{
                [Array addObject:ab];
                
            }
        }
    }
    return Array;
}

-(WSAcvtBean*)getAcvtWithFilter:(NSString*)filter withAcvtCode:(NSString*)acvtCode
{
    __block WSAcvtBean *acvtBean = nil;
    if (acvtCode && ![acvtCode isEqualToString:@"Y"] && ![acvtCode isEqualToString:@"N"]) {
        [self.acvtArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            WSAcvtBean *tmp = (WSAcvtBean*)obj;
            if (tmp.acvtCode && [tmp.acvtCode isEqualToString:acvtCode]) {
                *stop = YES;
                acvtBean = tmp;
            }
        }];
    }
    
    if (!acvtBean && filter) {
        [self.acvtArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            WSAcvtBean *tmp = (WSAcvtBean*)obj;
            if (tmp.typ && [tmp.typ isEqualToString:filter]) {
                acvtBean = tmp;
                *stop = YES;
            }
        }];
        
        if (!acvtBean) {
            LogError(@"acvt filter is empty");
        }
    }else {
        LogError(@"acvt filter is empty");
    }
    
    return acvtBean;
}

-(NSArray *)getAcvtArrayWithFilter:(NSString*)filter withAcvtCode:(NSString*)acvtCode
{
    NSMutableArray *array = [NSMutableArray array];
    
    if (acvtCode && ![acvtCode isEqualToString:@"Y"] && ![acvtCode isEqualToString:@"N"]) {
        [self.acvtArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            WSAcvtBean *tmp = (WSAcvtBean*)obj;
            NSArray *acvtCodeArray = [acvtCode componentsSeparatedByString:@","];
            
            if (tmp.acvtCode && [acvtCodeArray containsObject:tmp.acvtCode]) {
                [array addObject:tmp];
            }

        }];
    }
    
    if ([array count] == 0 && filter) {
        [self.acvtArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            WSAcvtBean *tmp = (WSAcvtBean*)obj;
            if (tmp.typ && [tmp.typ isEqualToString:filter]) {
                [array addObject:tmp];
            }
        }];
    }
    
    return array;
    
}


-(WSAcvtBean*)getAcvtById:(NSString*)anAcvtId
{
    if(anAcvtId == nil)
        return nil;
    for(WSAcvtBean* ab in self.acvtArray)
    {
        if([ab.acvtId isEqualToString:anAcvtId])
            return ab;
    }
    return nil;
}

- (NSArray *)getAcvtsById:(NSString *)anAcvtId
{
    if(anAcvtId == nil)
        return nil;
    NSMutableArray *array = [NSMutableArray array];
    for(WSAcvtBean* ab in self.acvtArray)
    {
        if([ab.acvtId isEqualToString:anAcvtId]){
            [array addObject:ab];
        }
    }
    
    if ([array count] > 0) {
        return array;
    }
    
    return nil;
}

- (WSAcvtBean *)getAcvtByQstCod:(NSString *)qstCod
{
    if (!qstCod || [qstCod length] == 0) {
        return nil;
    }
    
    for (WSAcvtBean *acvtBean in self.acvtArray) {
        for (WSAcvtBean_qst *qst in acvtBean.qsts) {
            if ([qst.qstCod isEqualToString:qstCod]) {
                return acvtBean;
            }
        }
    }
    
    return nil;
}

- (WSAcvtBean *)matchAcvtCodeWithFilter:(NSString *)filter {
    if (!filter || [filter length] == 0) {
        return nil;
    }
    
    for (WSAcvtBean *acvtBean in self.acvtArray) {
        if ([acvtBean.acvtCode isEqualToString:filter]) {
            return acvtBean;
        }
    }
    
    return nil;
}

@end

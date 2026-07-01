//
//  StoreAcvtDisArray.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-4-9.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSStoreAcvtDisArray.h"
#import "WSStoreAcvtDisBean.h"


@implementation WSStoreAcvtDisArray
@synthesize storeAcvtDisArray = _storeAcvtDisArray;


-(void)initStoreAcvtDisWithArray:(NSArray*)array
{
    _storeAcvtDisArray = [[NSMutableArray alloc] init];
    if ([array isKindOfClass:[NSArray class]]){
        
        if (array != nil){ 
            NSInteger i_arrayCount = [array count];
            for (int i = 0; i < i_arrayCount; i++) 
            {
                WSStoreAcvtDisBean* f_sad = [[WSStoreAcvtDisBean alloc]initWithObject:[array objectAtIndex:i]];
                [_storeAcvtDisArray addObject:f_sad];
                f_sad = nil;
            }
        }
    }
}


-(id)initWithObject:(id)object
{
    if([object isKindOfClass:[NSDictionary class]])
    {
        self = [super init];
        if(self)
        {
            
            __block NSMutableArray *storeAcvtDisArray = [NSMutableArray array];
            if ([object isKindOfClass:[NSDictionary class]]) {
                [(NSDictionary *)object enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    if (key && [key isKindOfClass:[NSString class]] && ([key hasPrefix:STOREACVTDIS] && ![key isEqualToString:STOREACVTDIS_VISITPLAN])) {
                        [storeAcvtDisArray addObjectsFromArray:(NSArray *)obj];
                    }
                }];
            }

            [self initStoreAcvtDisWithArray:storeAcvtDisArray];
        }
    }
     return self;
}

-(id)initWithObject:(id)object andKey:(NSString *)parserkey{
    
    
    if([object isKindOfClass:[NSDictionary class]])
    {
        self = [super init];
        if(self)
        {
            NSArray *Array = [object objectForKey:parserkey];
            [self initStoreAcvtDisWithArray:Array];
        }
    }
    return self;
}

- (NSString *)getAcvtDisValueByAcvtId:(NSString *)acvtID acvtQstId:(NSString *)acvtQstId storeId:(NSString *)storeId
{
    if (!acvtID || !acvtQstId ) {
        return nil;
    }
    
    for(WSStoreAcvtDisBean* f_sad in self.storeAcvtDisArray)
    {
        if([f_sad.m_p count] > 3)
        {
            
            NSString* i_storeId = [f_sad.m_p objectAtIndex:ACVTDIS_STOREID];
            NSString* i_acvtId = [f_sad.m_p objectAtIndex:ACVTDIS_ACVTID];
            NSString* i_acvtQstId = [f_sad.m_p objectAtIndex:ACVTDIS_QSTID];
            NSString* i_value = [f_sad.m_p objectAtIndex:ACVTDIS_VALUE];
            
            if ([storeId length] > 0) {
                if ([i_storeId isEqualToString:storeId] && [i_acvtId isEqualToString:acvtID] && [i_acvtQstId isEqualToString:acvtQstId]) {
                    return i_value;
                }
            }else {
                if ([i_acvtId isEqualToString:acvtID] && [i_acvtQstId isEqualToString:acvtQstId]) {
                    return i_value;
                }
            }
        }
    }
    
    return nil;
}

@end

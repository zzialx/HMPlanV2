//
//  WSStoreBeans.m
//  WinSFA
//
//  Created by winchannel on 15/8/7.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSStoreBeans.h"
#import "WSVisitPlanArray.h"
#import "WSVisitPlanBean.h"
#import "WSStoreAcvtArray.h"

@interface WSStoreBeans ()

@property (nonatomic,assign) BOOL isInitForWSAppData;

@property (nonatomic, strong) NSMutableArray *inPlanArray;

@property (nonatomic, strong) NSMutableArray *outPlanArray;

@end

@implementation WSStoreBeans


- (void)addStoresWithArray:(NSArray *)array noteName:(NSString *)noteName
{
    if ([array isKindOfClass:[NSArray class]]){

        if (array != nil){
            
            if (!_inPlanArray) {
                _inPlanArray = [[NSMutableArray alloc] init];
            }
            if (!_outPlanArray) {
                _outPlanArray = [[NSMutableArray alloc] init];
            }

            for (int i = 0; i < [array count]; i++) {
                NSDictionary *storeDic = [array objectAtIndex:i];
                if (storeDic && [storeDic isKindOfClass:[NSDictionary class]]) {
                    NSString *storeID = [NSString stringWithValue:[storeDic objectForKey:@"id"]];
                    BOOL isInPlan = [self isInplanStore: storeID];
                    
                    WSStoreBean *store = nil;
                    
                    //辉瑞医院门店走特殊节点hos,计划内门店从hos结点读取。
                    if (isInPlan && [WSAppData getObjectbyKey:HOS]) {
                        WSInPlanStoreBean *inplanStore = [WSAppData getObjectbyKey:HOS];
                        for (WSStoreBean *storeBean in inplanStore.storesArray) {
                            if ([storeBean.Id isEqualToString:storeID]) {
                                store = storeBean;
                                break;
                            }
                        }
                    }
                    
                    if (!store) {
                        if (self.isInitForWSAppData) {
                            store = [[WSStoreBean alloc] initStoreForWSAppDataWithObject:[array objectAtIndex:i] IsPlan:isInPlan noteName:noteName];
                        }else{
                            store = [[WSStoreBean alloc] initStoreWithObject:[array objectAtIndex:i] IsPlan:isInPlan noteName:noteName];
                        }

                        if ([noteName rangeOfString:@"subemp"].location != NSNotFound) {
                            store.storeAccessMode = WSStoreAccessModeSubEmp;
                        }
                        WSStoreAcvtArray *acvtArray = [WSAppData getObjectbyKey:STORE_ACVT_RELATION];
                        [store addAcvtArrayFromStores:[acvtArray getAcvtArrayWithStoreID:store.Id]];
                    }
                    
                    store.noteName = noteName;
 
                    [self.storesArray insertObject:store atIndex:i];
                    
                    
                    if (isInPlan) {
                        [_inPlanArray addObject:store];
                    }else {
                        [_outPlanArray addObject:store];
                    }
                }
                
            }
            
            if ([_inPlanArray count] > 0) {
                WSInPlanStoreBean *inPlanStore = [[WSInPlanStoreBean alloc] initWithStoreArray:_inPlanArray];
                if (inPlanStore) {
                    [[WSAppData sharedManager].datas setObject:inPlanStore forKey:INPLANSTORE];
                }
            }
            
            if ([_outPlanArray count] > 0) {
                WSOutPlanStoreBean *outPlanStore = [[WSOutPlanStoreBean alloc] initWithStoreArray:_outPlanArray];
                if (outPlanStore) {
                    [[WSAppData sharedManager].datas setObject:outPlanStore forKey:OUTPLANSTORE];
                }
            }
            
        }
    }
}

- (void)initWithStoreArrayForSer:(NSArray *)array{
    
    if ([array isKindOfClass:[NSArray class]]){
        
        if (array != nil){
            
            for (int i = 0; i < [array count]; i++) {
                NSDictionary *storeDic = [array objectAtIndex:i];
                if (storeDic && [storeDic isKindOfClass:[NSDictionary class]]) {
                   
                    WSStoreBean *store = nil;
                    if (!store) {
           
                        store =[[WSStoreBean alloc]initStoreWithObjectForSer:[array objectAtIndex:i]];
                     }
                    
                    [self.storesArray insertObject:store atIndex:i];
                }
                
            }
            
        }
    }
}

- (BOOL)isInplanStore:(NSString *)storeID {
    
    WSVisitPlanArray *visitPlanArray = [WSAppData getObjectbyKey:STOREACVTDIS_VISITPLAN];
    return [visitPlanArray isInplanStore:storeID];
    
}

-(id)initWithObject:(id)object andParseKey:(NSString *)parseKey
{
    return [self initWithObject:object noteName:parseKey];
}

-(id)initWithObjectForWSAppData:(id)object andParseKey:(NSString *)parseKey
{
    self.isInitForWSAppData = YES;
    
    return [self initWithObject:object noteName:parseKey];
}

- (id)initWithObjectForSer:(id)object andParseKey:(NSString *)parseKey{
    
    return [self initWithObjectForSer:object notName:parseKey];
    
}
@end

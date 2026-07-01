//
//  ProdBeanArray.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSProdBeanArray.h"
#import "WSProdBean.h"

@implementation WSProdBeanArray
@synthesize prodArray = _prodArray;

-(void)initProdWithArray:(NSArray*)array
{
    _prodArray = [[NSMutableArray alloc] init];
    
    if ([array isKindOfClass:[NSArray class]]){
        
        if (array != nil){ 
            
            for (int i = 0; i < [array count]; i++) {
                WSProdBean *prod = [[WSProdBean alloc] initWithObject:[array objectAtIndex:i]];
                [self.prodArray insertObject:prod atIndex:i];
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
            NSArray *Array = [object objectForKey:PRODS];
            [self initProdWithArray:Array];
        }
        return self;
    }
    return nil;
}


-(NSArray*)getProdsWithFilter:(NSString*)filter
{
    NSMutableArray* array = [[NSMutableArray alloc]init];
    for(WSProdBean* pb in self.prodArray)
    {
        if([pb.pTyp isEqualToString:filter])
        {
            [array addObject:pb];
        }
    }
    return array;
    
}

-(WSProdBean*)getProdWithPid:(NSString*)pid
{
    for(WSProdBean* pb in self.prodArray)
    {
        NSString* prodid = [NSString stringWithValue:pb.Id];
        if([prodid isEqualToString:pid])
        {
            return pb;
        }
    }
    return nil;
}

/*aBrandId  过滤产品的brand   【但立白需求 过滤其pTyp（同类型的产品可包含不同品牌）（因其更多产品需要显示不同的的品牌）】*/
- (NSArray *)getProdsWithBrandId:(NSString *)aBrandId
{
    if (aBrandId != nil && [aBrandId isKindOfClass:[NSString class]]) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [self.prodArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            WSProdBean* pb = (WSProdBean *)obj;
            if ( (pb.brand != nil && [pb.brand isKindOfClass:[NSString class]] && [pb.brand isEqualToString:aBrandId]) ||
                (pb.pTyp != nil && [pb.pTyp isKindOfClass:[NSString class]] && [pb.pTyp isEqualToString:aBrandId])) {
                [array addObject:pb];
            }
        }];
        return array;
    }
    return nil;
}


- (NSArray *)getProdsWithBrandType:(NSString *)aBrandType
{    
    if (aBrandType == nil || ![aBrandType isKindOfClass:[NSString class]]){
        return nil;
    }
    
    __block NSMutableArray *infoarray = [[NSMutableArray alloc] initWithCapacity:8];
    
    [self.prodArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        WSProdBean *bean = (WSProdBean *)obj;
        if (bean.brandType != nil && [bean.brandType isKindOfClass:[NSString class]] && [bean.brandType length] > 0) {
            if ([bean.brandType isEqualToString:aBrandType]) {
                [infoarray addObject:bean];
            }
        }
    }];
    
    return infoarray;
}

- (NSArray *)getProdsWithBrandId:(NSString *)aBrandId andProductType:(NSString *)aProductType
{
    NSString *type = nil;
    if (aProductType != nil && [aProductType isEqualToString:DS_PRODC]) {
        type = @"2";
    }else if (aProductType != nil && [aProductType isEqualToString:DS_PROD]){
        type = @"1";
    }
    
    if (aBrandId != nil && [aBrandId isKindOfClass:[NSString class]]) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [self.prodArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            WSProdBean* pb = (WSProdBean *)obj;
            if (pb.brand != nil && [pb.brand isKindOfClass:[NSString class]] && [pb.brand isEqualToString:aBrandId]) {
                if (type != nil) {
                    if ([pb.pTyp isEqualToString:type]) {
                        [array addObject:pb];
                    }
                }else{
                    [array addObject:pb];
                }
            }
        }];
        return array;
    }
    
    return nil;
}










@end

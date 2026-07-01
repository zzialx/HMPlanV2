//
//  WSSuggestDataFactory.m
//  WinSFA
//
//  Created by huzepei on 16/9/6.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSuggestDataFactory.h"
#import "WSBaseDictsTable.h"
#import "WSBrandModel.h"
#import "WSSuggestWholesale.h"

@implementation WSSuggestDataFactory

+ (NSArray *)suggestBrandForType:(NSString *)suggestType
{
    NSString *str = [NSString stringWithFormat:@"SELECT * FROM base_dicts AS dicts WHERE dicts.typ = 'prodBrand' AND dicts.dtyp = '%@';",suggestType];
    
    NSMutableArray *brandArray = [[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:str andClassName:@"WSBrandModel"];
    
    return [brandArray copy];
}

+(NSArray *)suggestCategory
{
    NSString *str = @"SELECT * FROM base_dicts AS dicts WHERE dicts.typ = 'prodType';";
    
    NSMutableArray *cateArray = [[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:str andClassName:@"WSCateModel"];
    
    return [cateArray copy];
}

+ (NSArray *)suggestProForBrand:(NSString *)brand cate:(NSString *)cate className:(NSString *)className
{
    NSString *str = [NSString stringWithFormat:@"SELECT * FROM base_product AS pro WHERE pro.brand = '%@' AND pro.memo1 = '%@';",brand,cate];
    
    NSMutableArray *proArray = [[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:str andClassName:className];
    
    return [proArray copy];
}

+ (NSArray *)suggestAVProType:(NSString *)suggestType className:(NSString *)className
{
    NSString *str = [NSString stringWithFormat:@"SELECT * FROM base_product AS pro WHERE pro.pTyp = '%@' ORDER BY seq;",suggestType];
    
    NSMutableArray *proArray = [[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:str andClassName:className];
    
    return [proArray copy];
}

@end

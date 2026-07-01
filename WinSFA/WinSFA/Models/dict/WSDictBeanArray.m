//
//  DictBeanArray.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSDictBeanArray.h"
#import "WSDictBean.h"
#import "WSDictBrand.h"

@implementation WSDictBeanArray
@synthesize dictArray = _dictArray;

-(void)initDictWithArray:(NSArray*)array
{
    _dictArray = [[NSMutableArray alloc] init];
    
    if ([array isKindOfClass:[NSArray class]]){
        
        if (array != nil){ 
            
            for (int i = 0; i < [array count]; i++) {
                WSDictBean *dict = [[WSDictBean alloc] initWithObject:[array objectAtIndex:i]];
                [self.dictArray insertObject:dict atIndex:i];
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
            /*
              节点名字包含 'dicts:'的数据都放入  以 DICTS 为key 的内存中
             */
            __block NSMutableArray *dicts = [NSMutableArray array];
            if ([object isKindOfClass:[NSDictionary class]]) {
                [(NSDictionary *)object enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    if (key && [key isKindOfClass:[NSString class]] && ([key  isEqualToString:DICTS] || [key rangeOfString:@"dicts:"].location != NSNotFound)) {
                        [dicts addObjectsFromArray:(NSArray *)obj];
                    }
                }];
            }
            [self initDictWithArray:dicts];
        }
        return self;
    }
    return nil;
}

#pragma mark 方法
-(NSArray*)getDictsWithFilter:(NSString*)filter
{
    //code added By zhangke for Bug MSTD-698
    //comment added By chenyangyang for Bug MSTD-674, MSTD-698 和 MSTD-674 这两个bug是同一个问题引起的
    //使用filter在dicts中过滤产品品牌时，根据马强的描述，filter一般应该配成“prodBrand@SKU”这样的格式，其中prodBrand代表品牌，@SKU代表在prodBrand所代表的所有品牌中，匹配btyp为@SKU的品牌。（一般用于区分本品品牌和竞品品牌）
    //由于以前有些测试童鞋配置的不太规范，所以filter就直接配成某一个品牌了，但是如果以后还不按照此格式配置，可以要求测试按此格式配置。
    //但是为了兼容以前的配置和做一些容错，我们应该两种格式都支持。
    //根据一明给的逻辑修改
    
    NSPredicate* pre=nil;
    
    if([filter rangeOfString:@"@"].location!=NSNotFound){
        NSArray* array=[filter componentsSeparatedByString:@"@"];
        NSString* typString=[array objectAtIndex:0];
        NSString* btypString=[NSString stringWithFormat:@"@%@",[array objectAtIndex:1]];
        NSPredicate* pre=[NSPredicate predicateWithFormat:@"typ==%@ and btyp==%@",typString,btypString];
        
        NSMutableArray* beanArray=[NSMutableArray array];
        for(WSDictBean* bean in self.dictArray){
            if(bean.p==nil){
                [beanArray addObject:bean];
            }
        }
        return [beanArray filteredArrayUsingPredicate:pre];

    }else{
        //兼容filter 以逗号间隔方式配置多个 typ
        NSArray *pTypArray = [filter componentsSeparatedByString:@","];
        
        NSMutableArray *filterResulteArray = [NSMutableArray arrayWithCapacity:1];
        
        for (NSString *stringTyp in pTypArray) {
             NSPredicate* pre=[NSPredicate predicateWithFormat:@"typ==%@",stringTyp];
            [filterResulteArray addObjectsFromArray:[self.dictArray filteredArrayUsingPredicate:pre]];
        }
        
        return filterResulteArray;
    }

    return [self.dictArray filteredArrayUsingPredicate:pre];
}

- (NSArray *)getDictsWithParentId:(NSString *)aId andFilter:(NSString *)afilter
{
    if (afilter == nil) return self.dictArray;
    
    NSMutableArray *arrys = [[NSMutableArray alloc] init ];
    
    NSString *pid = (aId != nil && [aId length] > 0) ? aId : nil;
    NSArray *filterArray = [afilter componentsSeparatedByString:@","];
    [self.dictArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        WSDictBean* dict = (WSDictBean*)obj;
        
        BOOL isFilterMatch = NO;
        if ([afilter rangeOfString:@"@"].location != NSNotFound) {
            
            NSArray *btypFilterArray = [afilter componentsSeparatedByString:@"@"];
            if ([btypFilterArray[0] isEqualToString:dict.typ] && [btypFilterArray[1] isEqualToString:dict.btyp]) {
                isFilterMatch = YES;
            }
            
        }else {
            isFilterMatch = [filterArray containsObject:dict.typ];
        }
        
        if (isFilterMatch) {
            // 通过pid过滤
            if (pid)
            {
                if ([pid isEqualToString:dict.p])
                {
                    [arrys addObject:dict];
                }
            }
            else
            {
                if (dict.p == nil) {
                    /*dict.p == nil说明其为多级联动的最高级别*/
                    [arrys addObject:dict];
                }
                
            }
        }
    }];
    
    return arrys;
}

-(NSArray*)getProdsBrandByFilter:(NSString*)filter
{
    //根节点
    NSMutableArray* rootArray = [[NSMutableArray alloc]init];
    NSMutableArray* brandArray = [[NSMutableArray alloc]init ];
    NSArray* dictsArray = [NSArray arrayWithArray:[self getDictsWithFilter:filter]];
    //NSLog(@"dictsArray count is %d",[dictsArray count]);

    for(WSDictBean* db in dictsArray)
    {
        if(nil == db.p || [db.p isKindOfClass:[NSNull class]])
        {
            [rootArray addObject:db];
            
        }
    }
    //NSLog(@"root array count is %d",[rootArray count]);

    for(WSDictBean* db in rootArray)
    {
        WSDictBrand* dict_brand = [[WSDictBrand alloc]initWithDict:db DictArray:dictsArray];
        [brandArray addObject:dict_brand];
    }
    //NSLog(@"brand array count is %d",[brandArray count]);
    return brandArray;
}


- (NSString *)getBrandIdByFilter:(NSString *)aFilter  searchQuestion:(NSString *)searchQuestion{
    
    for(WSDictBean* dict in self.dictArray) {
        
        if ([searchQuestion isKindOfClass:[NSString class]] && [searchQuestion length] > 0) {
            
            if ([searchQuestion isEqualToString:@"brand"]) {
                if ([dict.Id isEqualToString:aFilter]) {
                    return dict.Id;
                }
            }else if ([searchQuestion isEqualToString:@"brandcode"]) {
                if ([dict.cod isEqualToString:aFilter]) {
                    return dict.Id;
                }
            }
        }
        
    }
    return nil;
}
- (WSDictBean *)getDictWithByDictCode:(NSString *)filter{
    
    for (WSDictBean *dict in self.dictArray) {
        if ([filter isEqualToString:dict.cod]) {
            return dict;
        }
    }
    return nil;
}
@end

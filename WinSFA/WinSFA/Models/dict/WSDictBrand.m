//
//  DictBrand.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSDictBrand.h"
#import "WSProdBeanArray.h"
#import "WSProdBean.h"
#import "WSAppData.h"

@implementation WSDictBrand
@synthesize dictBean = _dictBean;
@synthesize subDictBrandsArray = _subDictBrandsArray;
@synthesize prodArray = _prodArray;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(id)initWithDict:(WSDictBean*)dict DictArray:(NSArray*)dictArray
{
    if(dict == nil||[dictArray count]<1)
        return nil;
    
    self = [super init];
    if(self != nil)
    {
        self.dictBean = dict;
        NSMutableArray* array = [[NSMutableArray alloc]init];
        self.subDictBrandsArray = array;
        
        NSMutableArray* dictsBeanArray = [[NSMutableArray alloc]init ];
        NSString* dict_id = [NSString stringWithValue:dict.Id];
        for(WSDictBean* db in dictArray)
        {
            NSString* dict_p = [NSString stringWithValue:db.p];
            if([dict_id isEqualToString:dict_p])
            {
                [dictsBeanArray addObject:db];
            }
        }
        //如果小于 1 去添加产品
        if([dictsBeanArray count]<1)
        {
            _prodArray = [[NSMutableArray alloc]init];
            WSProdBeanArray* pba = [WSAppData getObjectbyKey:PRODS];
            NSString* dict_id = [NSString stringWithValue: self.dictBean.Id];
            for(WSProdBean* pb in pba.prodArray)
            {
                NSString* prod_brand = [NSString stringWithValue:pb.brand];
                if([dict_id isEqualToString:prod_brand])
                {
                    [self.prodArray addObject:pb];
                }
            }
        }
        else    //生成子 brands
        {
            for(WSDictBean* dictbean in dictsBeanArray)
            {
                WSDictBrand* db = [[WSDictBrand alloc]initWithDict:dictbean DictArray:dictArray];
                [self.subDictBrandsArray addObject:db];
            }
            
        }
        return self;
    }
    return nil;
}

@end

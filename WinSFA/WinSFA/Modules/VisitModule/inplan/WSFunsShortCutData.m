//
//  WSFunsShortCutData.m
//  WinSFA
//
//  Created by winchannel on 15/9/7.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSFunsShortCutData.h"
#import "WSServerIPList.h"
#import "WSJSONBuilder.h"
#import <SDImageCache.h>

@implementation WSFunsShortCutData

- (id)init{
    
    self = [super init];
    if (self) {
        _funcsBean =[[ WSFuncsBean alloc]init ];
        _shortCutArray = [[NSMutableArray alloc]init];
    }
    return self ;
}

- (NSArray *)filterShortCutData:(WSFuncsBean *)funcsBean{
    
    NSMutableArray *shortCutArray = [[NSMutableArray alloc]init];
    
    for (int index = 0 ; index < funcsBean.funcsArray.count; index ++) {
        WSFuncsBean *bean = [funcsBean.funcsArray objectAtIndex:index];
        
        if (bean.opt.isShortCut) {
            
            [shortCutArray addObject:bean];
        }
    }
    
    return shortCutArray ;
    
}

@end

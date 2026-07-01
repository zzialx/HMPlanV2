//
//  WSTableItem.m
//  WinSFA
//
//  Created by ZhengJiepeng on 13-7-24.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import "WSTableItem.h"
#import "NSDictionary+Additional.h"
#import "WSFuncsBean.h"
#import "WSFuncsBean_opt.h"
#import "WSFuncsBean_Param.h"

#define MC @"mc"
#define V  @"v"
#define FCHARNUM @"FcharNum"
#define NAME @"name"
#define OPT  @"opt"
#define FILTER @"filter"
#define PARAM @"param"
#define REQUIRED @"required"
#define MAXROW @"maxRow"
#define DS @"ds"
#define DATETYPE @"dateTyp"
#define ISMORE @"isMore"

@implementation WSTableItem


- (id)initWithObject:(id)object {
    if (![object isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [super init];
    if (self) {
        
        NSDictionary *dic = (NSDictionary *)object;
        
        _mc = [dic getStringValueWithKeyName:MC];
        
        NSDictionary  *vInfo = [[object objectForKey:V] objectFromJSONString];
        
        _fCharNum = [NSString stringWithValue:[vInfo objectForKey:FCHARNUM]];
        _opt = [[WSFuncsBean_opt alloc] initFuncs_optWithObject:[vInfo objectForKey:OPT]];
        _filter = [NSString stringWithValue:[vInfo objectForKey:FILTER]];
        _required = [NSString stringWithValue:[vInfo objectForKey:REQUIRED]];
        _maxRow = [NSString stringWithValue:[vInfo objectForKey:MAXROW]];
        _ds = [NSString stringWithValue:[vInfo objectForKey:DS]];
        _dateTyp = [NSString stringWithValue:[vInfo objectForKey:DATETYPE]];
        _isMore = [NSString stringWithValue:[vInfo objectForKey:ISMORE]];
        _showThumbnail = [NSString stringWithValue:[vInfo objectForKey:FUNCS_SHOWTHUMBNAIL]];
        
        NSArray *paramDicArray = [vInfo objectForKey:PARAM];
        if ([paramDicArray isKindOfClass:[NSArray class]]) {
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:[paramDicArray count]];
            for (NSDictionary *paramDic in paramDicArray) {
                WSFuncsBean_Param *param = [[WSFuncsBean_Param alloc] initFuncs_ParamWithObject:paramDic];
                [array addObject:param];
            }
            
            _paramArray = [NSArray arrayWithArray:array];
        } else {
            _paramArray = [NSArray array];
        }

    }
    return self;
}

- (instancetype)initWithFuncsBean:(WSFuncsBean *)funcsBean
{
    self = [super init];
    
    if (self) {
        _mc = [funcsBean.fc copy];
        _fCharNum = [[NSNumber numberWithInt:funcsBean.fCharNum] stringValue];
        _opt = funcsBean.opt;
        _filter = [funcsBean.filter copy];
        _required = [funcsBean.required copy];
        
        if (funcsBean.maxRow != 0) {
            _maxRow = [[NSNumber numberWithInt:funcsBean.maxRow] stringValue];
        }
        _ds = [funcsBean.ds copy];
        _dateTyp = [funcsBean.dateTyp copy];
        _showThumbnail = funcsBean.showThumbnail;
        _paramArray = [[NSArray alloc] initWithArray:funcsBean.paramArray copyItems:YES];;
        
        _funcsBean = funcsBean;
        
        return self;
    }
    
    return nil;
}


- (instancetype)initWithFuncsBean:(WSFuncsBean *)funcsBean param:(NSArray *)params;
{
    if (self = [self initWithFuncsBean:funcsBean]) {
        _paramArray = params;
        _funcsBean = funcsBean;
        return self;
    }
    return nil;
}

@end

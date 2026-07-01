//
//  FuncsBean_other.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-5-4.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSFuncsBean_other.h"

@implementation WSFuncsBean_other
@synthesize col = _col;
@synthesize name = _name;
@synthesize tpy = _tpy;
@synthesize wcol = _wcol;
@synthesize max = _max;
@synthesize min = _min;
@synthesize pcs = _pcs;
@synthesize readonly = _readonly;
@synthesize redis = _redis;
@synthesize ds = _ds;
@synthesize filter = _filter;
@synthesize isSupperLocalPhoto = _isSupperLocalPhoto;
@synthesize maxPhoto = _maxPhoto;

- (id)initFuncsOtherBeanObject:(id)object
{
    if (object== nil)
        return nil;
    self = [super init];
    if(self)
    {
        //??? Declare the 
        if ([object isKindOfClass:[NSDictionary class]]){
            NSDictionary *paramDictionary = (NSDictionary *)object;
            _col = [[NSString stringWithValue:[paramDictionary objectForKey:FUNCS_OTHER_COL]] copy];
            _name = [[NSString stringWithValue:[paramDictionary objectForKey:FUNCS_OTHER_NAME]] copy];
            _tpy = [[NSString stringWithValue:[paramDictionary objectForKey:FUNCS_OTHER_TPY]] copy];
            _wcol = [[paramDictionary objectForKey:FUNCS_OTHER_WCOL] intValue];
            _max = [[NSString stringWithValue:[paramDictionary objectForKey:FUNCS_OTHER_MAX]] copy];
            _min = [[NSString stringWithValue:[paramDictionary objectForKey:FUNCS_OTHER_MIN]] copy];
            _pcs = [[NSString stringWithValue:[paramDictionary objectForKey:FUNCS_OTHER_PCS]] copy];
            _readonly = [[paramDictionary objectForKey:FUNCS_OTHER_READONLY] intValue];
            _redis = [[NSString stringWithValue:[paramDictionary objectForKey:FUNCS_OTHER_REDIS]] copy];
            
            _value = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_OTHER_VALUE]];
            
            _ds = [[NSString stringWithValue:[paramDictionary objectForKey:FUNCS_DS]] copy];
            _filter = [[NSString stringWithValue:[paramDictionary objectForKey:FUNCS_FILTER]] copy];
            
            _reg = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_OTHER_REG]];
            _regname = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_OTHER_NAME]];
            
            id tmp = [paramDictionary objectForKey:FUNCS_OTHER_isSupperLocalPhoto];
            if (tmp && ![tmp isKindOfClass:[NSNull class]]) {
                _isSupperLocalPhoto = [tmp intValue];
            }else {
                _isSupperLocalPhoto = 0;
            }
            
            tmp = [paramDictionary objectForKey:FUNCS_OTHER_maxPhoto];
            if (tmp && ![tmp isKindOfClass:[NSNull class]]) {
                _maxPhoto = [tmp intValue];
            }else {
                _maxPhoto = 0;
            }
            
            tmp = [paramDictionary objectForKey:FUNCS_OTHER_default];
            if (tmp && ![tmp isKindOfClass:[NSNull class]]) {
                _mdefault = [[NSString stringWithValue:tmp] copy];
            }
        }
    }
    return self;
}



@end

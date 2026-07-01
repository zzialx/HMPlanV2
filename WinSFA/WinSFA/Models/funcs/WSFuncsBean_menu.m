//
//  FuncsBean_menu.m
//  WinChannelFrameWork
//
//  Created by Niu Zhaowang on 7/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSFuncsBean_menu.h"

@implementation WSFuncsBean_menu

@synthesize col = _col , name = _name , tpy = _tpy, isplanlist = _isplanlist, filter = _filter;

- (id)initFuncs_MenuWithObject:(id)object
{
    if (nil == object) {
        return nil;
    }
    self = [super init];
    
    if (self) {
        if ([object isKindOfClass:[NSDictionary class]]){
            NSDictionary *paramDictionary = (NSDictionary *)object;
            _col = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PARAM_COL]];
            _name = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PARAM_NAME]];
            _tpy = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PARAM_TPY]];
            _isplanlist = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PARAM_ISPLANLIST]];
            _filter = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PRARM_FILTER]];
        }
    }
    return self;
}


@end

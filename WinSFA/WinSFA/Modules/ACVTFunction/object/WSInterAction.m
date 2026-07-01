//
//  WSInterAction.m
//  WinSFA
//
//  Created by winchannel on 15/3/20.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSInterAction.h"

@implementation WSInterAction

@synthesize acvt_qust_id;

@synthesize direct_type;

@synthesize execute_class;

@synthesize execute_class_param;

@synthesize execute_result;

@synthesize execute_method_ns;

@synthesize execute_method_param;

@synthesize inner_param;

@synthesize viewId;

@synthesize inner_id;

@synthesize env_context_setting;

@synthesize execute_class_param_title;

-(id)init{
    
    self = [super init];
    if (self) {
    
        env_context_setting =[[NSMutableDictionary alloc] init];
        
        return self;
    }
    return nil;
}


-(void)setEnvValue:(NSObject *)value forKey:(NSString *)key{
    
    [env_context_setting setObject:value forKey:key];
    
}

-(NSObject *)getEnvValueForKey:(NSString *)key{
    
    return [env_context_setting objectForKey:key];
}
@end

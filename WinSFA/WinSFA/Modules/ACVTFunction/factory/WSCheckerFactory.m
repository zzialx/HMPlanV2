//
//  WSFileCheckerFactory.m
//  WinSFA
//
//  Created by winchannel on 15/6/3.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSCheckerFactory.h"
#import "I_CheckerInfo.h"

@implementation WSCheckerFactory

static WSCheckerFactory *checkFactory;

+(id)shareInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        checkFactory =[[WSCheckerFactory alloc] init];
        
    });
    
    return checkFactory;
}

-(id)init{
    
    self =[super init];
    if (self) {
        
        NSString  *checker_config_path = [[NSBundle mainBundle] pathForResource:@"checkerConfig" ofType:@"plist"];
        
        checkerReigst=[[NSMutableDictionary alloc] initWithContentsOfFile:checker_config_path];
        
        return self;
    }
    return nil;
}

-(NSObject<I_Checker> *)createChecker:(NSObject<I_CheckerInfo> *)checkerInfo{
    
    NSString *class_name = [checkerReigst valueForKey:[[checkerInfo getCheckerType] lowercaseString]];
    
    if (!class_name) {
        return nil;
    }
    
    NSObject<I_Checker> *checker =[[NSClassFromString(class_name) alloc] init];
    
    return checker;
    
}

@end

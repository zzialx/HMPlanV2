//
//  WSFileCheckerFactory.h
//  WinSFA
//
//  Created by winchannel on 15/6/3.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "I_Checker.h"


@protocol I_Checker;

@protocol I_CheckerInfo;

@interface WSCheckerFactory : NSObject{
    
    NSMutableDictionary  *checkerReigst;
    
}

+(id)shareInstance;

-(NSObject<I_Checker> *)createChecker:(NSObject<I_CheckerInfo> *)checkerInfo;

@end

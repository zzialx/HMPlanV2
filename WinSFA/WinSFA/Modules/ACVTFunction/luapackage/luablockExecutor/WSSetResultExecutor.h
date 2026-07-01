//
//  WSSetResultExecutor.h
//  WinSFA
//
//  Created by lishuli on 2018/12/21.
//  Copyright © 2018 WinChannel. All rights reserved.
//

#import "WSLuaExecutor.h"

@interface WSSetResultExecutor : WSLuaExecutor

@property (nonatomic,copy) NSString *result;

@property (nonatomic,copy) NSString *luaScript;

+ (instancetype)sharedInstance;

@end

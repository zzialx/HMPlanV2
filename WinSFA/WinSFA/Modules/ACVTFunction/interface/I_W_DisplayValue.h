//
//  I_W_DisplayValue.h
//  WinSFA
//
//  Created by yang on 15-3-24.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#ifndef WinSFA_I_W_DisplayValue_h
#define WinSFA_I_W_DisplayValue_h

@protocol I_W_DisplayValue <NSObject>

-(NSObject *)getDisplayValueFor:(NSObject<I_W_BuildInfo> *)buildInfo;

@optional
- (NSObject *)getServerRedisValue:(NSObject<I_W_BuildInfo> *)buildInfo;
- (NSObject *)getDefaultValue:(NSObject<I_W_BuildInfo> *)buildInfo;
@end


#endif

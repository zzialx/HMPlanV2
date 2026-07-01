//
//  I_W_Validate.h
//  WinSFA
//
//  Created by winchannel on 15/3/13.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#ifndef WinSFA_I_W_Validate_h
#define WinSFA_I_W_Validate_h

@class WSWidget;

@protocol I_W_BuildInfo;

@protocol I_W_Validate <NSObject>

@optional
//执行验证 －－设计过量
-(BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo ;
//执行验证 －－设计过量
-(BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo withValue:(NSObject *)value;
//执行验证 
-(BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo withWidget:(WSWidget *)widget;


@end

#endif

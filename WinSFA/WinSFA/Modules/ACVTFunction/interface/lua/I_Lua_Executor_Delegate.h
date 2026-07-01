
//
//  I_Lua_Executor_Delegate.h
//  WinSFA
//
//  Created by winchannel on 15/4/9.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#ifndef WinSFA_I_Lua_Executor_Delegate_h
#define WinSFA_I_Lua_Executor_Delegate_h

@class WSInterAction;

@protocol I_Lua_Executor_Delegate <NSObject>

@optional
//返回所有name 和 widget的名字映射
-(NSMutableDictionary *)getQstNameAndWidgetMapping;

-(NSMutableDictionary *)getQstCodeAndWidgetMapping;


//返回所有 id 和 widget的标示映射
-(NSMutableDictionary *)getQstIdAndWidgetMapping;

//返回所有问卷控件数组
-(NSMutableArray *)getQstWidgetArray;


//设置上传按钮隐藏/显示
- (void)setUploadButtonHidden:(BOOL)isHidden;

- (void)setUploadButtonEnable:(BOOL)isEnable;

- (void)executeInterAction:(WSInterAction *)interaction;

@end
#endif

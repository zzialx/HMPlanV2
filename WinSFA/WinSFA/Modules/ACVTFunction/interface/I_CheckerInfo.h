//
//  I_CheckerInfo.h
//  WinSFA
//
//  Created by winchannel on 15/6/4.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#ifndef WinSFA_I_CheckerInfo_h
#define WinSFA_I_CheckerInfo_h

@protocol I_CheckerInfo <NSObject>


//获得被检测的类型
-(NSString *)getCheckerType;

//获得被检测的对象
-(NSObject *)getCheckerObject;

//设置检测类型
-(void)setCheckerType:(NSString *)checkerType;

//设置检测对象
-(void)setCheckerObject:(NSObject *)checkerObject;

@end

#endif

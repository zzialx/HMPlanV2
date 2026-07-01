//
//  I_Checker.h
//  WinSFA
//
//  Created by winchannel on 15/6/4.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#ifndef WinSFA_I_Checker_h
#define WinSFA_I_Checker_h 

@protocol I_Checker_Delegate;


@protocol I_Checker <NSObject>

-(BOOL)checkObjectIsValidate:(NSObject *)checkobject;

-(void)setCheckDelegate:(NSObject<I_Checker_Delegate> *)chekerDelegates;

@end

@protocol I_Checker_Delegate <NSObject>

-(void)checkEnd:(NSObject<I_Checker> *)checker;

-(void)checkEndWithError:(NSObject<I_Checker> *)checker;

@optional
-(void)checkBegin:(NSObject<I_Checker> *)checker;

-(void)checkInProid:(NSObject<I_Checker> *)checker;



@end


#endif

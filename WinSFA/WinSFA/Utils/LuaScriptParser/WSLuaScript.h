//
//  WSLuaScript.h
//  TestLua2
//
//  Created by dujinfeng481 on 14-8-26.
//  Copyright (c) 2014年 djf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSLuaScriptContext.h"


@interface WSLuaScript : NSObject

+ (WSLuaScript*) getInstance;

/**
 *  初始化lua环境
 *
 *  @param parserObj 解析上下文环境
 *
 *  @return 环境创建成功or失败
 */
-(BOOL) initializationLuaWithObject:(WSLuaScriptContext*)parserObj;

-(NSString*) onSubmit;
-(NSString *)onCheck;
- (NSString *) onComputeSumToTarget;

/**
 *  支持包含关系运算符，算数运算符的表达式计算
 *
 *  @param expression 表达式
 *
 *  @return nil or 运算结果
 */
- (NSString*) arithmeticExpressions:(NSString*)expression;

/**
 *  允许考试
 */
- (NSString *) allowExam;


-(NSString *)generateURL;


-(NSString *)getMeetingApplicantInfo;


-(NSString *)checkProductValidateInTable;

-(NSString *) excuseAction;

- (NSString *)changeQstValueDependentOnAcvtGrid;

- (NSString *)runLuaFunctionByName:(NSString *)functionName param:(NSString *)param;

- (void)setLuaFunctionName:(NSString *)functionName;

- (NSString *)getLuaFunctionName;

@end

//
//  WSLuaScriptEnter.h
//  TestLua2
//
//  Created by dujinfeng481 on 14-8-26.
//  Copyright (c) 2014年 djf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSLuaScriptContext.h"

@class WSFuncsBean;
@class WSStoreBean;

@interface WSLuaScriptEnter : NSObject


/**
 *  初始化lua环境
 *
 *  @param scriptParserObj WSLuaScriptContext 对象
 *
 *  @return 环境创建成功or失败
 */
-(BOOL) initializationLuaContextWithLuaScriptContext:(WSLuaScriptContext*)scriptParserObj;

/**
 *  执行onSubmit方法
 */
-(NSString*) runOnSumbit;


/**
 *  执行onCheck方法
 */
-(NSString*) runOnCheck;

/**
 * 执行ComputeSumToTarget方法
 *
 */
-(NSString *) runComputeSumToTarget;


/**
 *
 */
-(NSString *) runAllowExam;

-(NSString *) runGenerateURL;

-(NSString *) runMeetingApplicantInfo;


-(NSString *) runCheckProductValidateInTable;
-(NSString *)runExcuseAction;

-(NSString *)runChangeQstValueDependentOnAcvtGrid;

-(NSString *)runUniversalLuaFunction:(NSString *)value;


 @end

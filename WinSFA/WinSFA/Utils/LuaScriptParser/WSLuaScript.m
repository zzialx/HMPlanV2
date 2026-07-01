//
//  WSLuaScript.m
//  TestLua2
//
//  Created by dujinfeng481 on 14-8-26.
//  Copyright (c) 2014年 djf. All rights reserved.
//

#import "WSLuaScript.h"
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#import "WSLuaDefine.h"

#define isLoadFromFile  NO

@interface WSLuaScript() {
    WSLuaScriptContext   *contextScriptParserObj;
    lua_State           *lua;
    lua_State           *expressionLua; //运算表达式专用
    NSString            *_functionName; // 当前执行函数的函数名
}
@end

@implementation WSLuaScript

 
+ (WSLuaScript*) getInstance
{
    static WSLuaScript *instance = nil;
    @synchronized(self){
        if (instance == nil) {
            instance = [[WSLuaScript alloc] init];
        }
        
        return instance;
    }
}

-(id) init
{
    self = [super init];
    if (self) {
        
        expressionLua = NULL;
        
        lua = [self generateLua];
    }
    
    return self;
}

- (void)dealloc
{
    [self closeLua];
}

#pragma mark - public method
- (NSString*) onSubmit
{
    if (lua) {
        lua_register(lua, LUA_GET_TABLE_FIRST_COLS_FUNCTION, getTableFirstCols);
        lua_register(lua, LUA_GET_CUR_STORE_INFO_FUNCTION, getCurStoreWithParamInfo);
        lua_register(lua, LUA_GET_CUR_STORE_INFO_BY_PARAM_FUNCTION, getCurStoreInfoByParam);
        lua_register(lua, LUA_CALL_QST_WIDGET_METHOD_BY_QSTNAME_FUNCTION, callQstWidgetMethodByQstName);
        lua_register(lua, LUA_CALL_QST_WIDGET_METHOD_BY_QSTCODE_STARTS_FUNCTION, callQstWidgetMethodByQstCodeStarts);
        lua_register(lua, LUA_FIND_ELEMENT_BY_NAME_FUNCTION, findElementByName);
        lua_register(lua, LUA_SET_TIP_FUNCTION,setTip);
        lua_register(lua, LUA_SET_RESULT_FUNCTION,setResult);
        lua_register(lua, LUA_SEND_SMS_FUNCTION, sendSMS);
        
        lua_register(lua, LUA_DELETE_STORE_ACTION, deleteStoreAction);
        lua_register(lua, LUA_CREATE_AND_VISIT_STORE_ACTION, createAndVisitStoreAction);
        lua_register(lua, LUA_SAVE_ACVT_DATA, saveAcvtData);
        lua_register(lua, LUA_CHECK_MUST_FILL_ONE, checkMustFillOne);
        lua_register(lua, LUA_CHECK_MUST_FILL_ANY_MODE, checkMustFillAnyMode);
        
        lua_getglobal(lua, LUA_ON_SUBMIT_FUNCTION);
        
        int Error = lua_pcall(lua,0,1,0 );    //第二个参数：方法参数，第三个参数：方法返回值
        if (Error == 0) {
            NSString *resultStr = nil;
            if (lua_isstring(lua, -1)) {
                resultStr = [NSString stringWithUTF8String:lua_tostring(lua, -1)];
            }
            NSLog(@"success resultStr：%@", resultStr);
//            [self closeLua];
            return resultStr;
        }
        else {
            NSLog(@"error: %s \n" , lua_tostring(lua, -1));
//            [self closeLua];
        }
    }
    
    return nil;
}

-(NSString *) onCheck
{
    if (lua) {
        
        lua_register(lua, LUA_MODIFY_QST_REQUIREDSTATE_BY_SELECTEDITEM_FUNCTION, modifyQstRequiredStateBySelectedItem);
        lua_register(lua, LUA_MODIFY_CONTENT_REQUIREDSTATE_BY_BOOLEANEXPRESSION_FUNCTION, modifyContentRequiredStateByBooleanExpression);
        lua_getglobal(lua, LUA_ON_CHECK_FUNCTION);
        
        int Error = lua_pcall(lua,0,1,0 );    //第二个参数：方法参数，第三个参数：方法返回值
        if (Error == 0) {
            NSString *resultStr = nil;
            if (lua_isstring(lua, -1)) {
                resultStr = [NSString stringWithUTF8String:lua_tostring(lua, -1)];
            }
            NSLog(@"success resultStr：%@", resultStr);
//            [self closeLua];
            return resultStr;
        }
        else {
            NSLog(@"error: %s \n" , lua_tostring(lua, -1));
//            [self closeLua];
        }
    }
    
    return nil;

}

- (NSString *) onComputeSumToTarget
{
    if (lua) {
        
        lua_register(lua, LUA_COMPUTE_TABLE_SUM_FUNCTION, computeTableSum);
        lua_register(lua, LUA_COMPUTE_COL_SUM_FUNCTION, computeColSum);
        lua_register(lua, LUA_CALL_QST_WIDGET_METHOD_BY_QSTNAME_FUNCTION, callQstWidgetMethodByQstName);
        lua_register(lua, LUA_CALL_QST_WIDGET_METHOD_BY_QSTCODE_STARTS_FUNCTION, callQstWidgetMethodByQstCodeStarts);
        lua_getglobal(lua, LUA_COMPUTE_SUM_TO_TARGET_FUNCTION);
        
        int Error = lua_pcall(lua,0,1,0 );    //第二个参数：方法参数，第三个参数：方法返回值
        if (Error == 0) {
            NSString *resultStr = nil;
            if (lua_isstring(lua, -1)) {
                resultStr = [NSString stringWithUTF8String:lua_tostring(lua, -1)];
            }
            NSLog(@"success resultStr：%@", resultStr);
//            [self closeLua];
            return resultStr;
        }
        else {
            NSLog(@"error: %s \n" , lua_tostring(lua, -1));
//            [self closeLua];
        }
    }

    return nil;
}

-(NSString *)generateURL
{
    if (lua) {
        NSString *resultStr = nil;
        
        lua_getglobal(lua, LUA_GENERATE_URL_FUNCTION);
        lua_register(lua, LUA_GENERATE_URL_STRING_WITH_PARAMS_FUNCTION, generateURLStringWithParams);
        int Error = lua_pcall(lua,0,0,0 );
        //第二个参数：方法参数，第三个参数：方法返回值
        if (Error == 0) {
            //                    if (lua_isstring(lua, -1)) {
            //                        resultStr = [NSString stringWithUTF8String:lua_tostring(lua, -1)];
            //                    }
//            NSLog(@"success resultStr：%@", resultStr);
            
        }else {
            NSLog(@"error: %s \n" , lua_tostring(lua, -1));
        }
        
//        [self closeLua];
        return resultStr;
    }
    
    return nil;

}
- (NSString *) allowExam
{
    if (lua) {
        NSString *resultStr = nil;
        
        lua_getglobal(lua, LUA_ALLOW_EXAM_FUNCTION);
        lua_register(lua, LUA_CALL_QST_WIDGET_METHOD_BY_QSTNAME_FUNCTION, callQstWidgetMethodByQstName);
        lua_register(lua, LUA_CALL_QST_WIDGET_METHOD_BY_QSTCODE_STARTS_FUNCTION, callQstWidgetMethodByQstCodeStarts);
        int Error = lua_pcall(lua,0,0,0 );
        //第二个参数：方法参数，第三个参数：方法返回值
                if (Error == 0) {
//                    if (lua_isstring(lua, -1)) {
//                        resultStr = [NSString stringWithUTF8String:lua_tostring(lua, -1)];
//                    }
//                    NSLog(@"success resultStr：%@", resultStr);
        
                }else {
                    NSLog(@"error: %s \n" , lua_tostring(lua, -1));
                }
        
//        [self closeLua];
        return resultStr;
    }
    
    return nil;
}

- (NSString *)getMeetingApplicantInfo {
    if (lua) {
        NSString *resultStr = nil;
        
        lua_getglobal(lua, LUA_MEETING_APPLICANT_INFO);
        lua_register(lua, LUA_SET_CURRENT_QST_VALUE_WITH_TYPE, getMeetingApplicantInfo);
        int Error = lua_pcall(lua,0,0,0 );
        //第二个参数：方法参数，第三个参数：方法返回值
        if (Error == 0) {
            //                    if (lua_isstring(lua, -1)) {
            //                        resultStr = [NSString stringWithUTF8String:lua_tostring(lua, -1)];
            //                    }
            //                    NSLog(@"success resultStr：%@", resultStr);
            
        }else {
            NSLog(@"error: %s \n" , lua_tostring(lua, -1));
        }
        
//        [self closeLua];
        return resultStr;
    }
    
    return nil;

}


-(NSString *) excuseAction
{
    if (lua) {
        NSString *resultStr = nil;
        lua_getglobal(lua, LUA_EXCUSE_ACTION_FUNCTION);
        lua_register(lua, LUA_WEChAT_IMG_SHARE_ACTION , exceseWeChatImgShare);
         lua_register(lua, LUA_CREATE_AND_VISIT_STORE_ACTION, createAndVisitStoreAction);
        lua_register(lua, LUA_SAVE_ACVT_DATA, saveAcvtData);

        int Error = lua_pcall(lua,0,0,0 );
        //第二个参数：方法参数，第三个参数：方法返回值
        if (Error == 0) {
            
        }else {
            LogError(@"error: %s \n" , lua_tostring(lua, -1));
        }
        
//        [self closeLua];
        return resultStr;
    }
    
    return nil;
    
}

- (NSString *)checkProductValidateInTable
{
    if (lua) {
        NSString *resultStr = nil;
        
        lua_getglobal(lua, LUA_CHECK_PRODUCT_VALIDATE_IN_TABLE);
        lua_register(lua, LUA_CHECK_PRODUCT_VALIDATE, checkProductValidate);
        int Error = lua_pcall(lua,0,0,0 );
        //第二个参数：方法参数，第三个参数：方法返回值
        if (Error == 0) {
            
        }else {
            LogError(@"error: %s \n" , lua_tostring(lua, -1));
        }
        
//        [self closeLua];
        return resultStr;
    }
    
    return nil;
}


- (NSString*) changeQstValue
{
    if (lua) {
        lua_register(lua, LUA_GET_TABLE_FIRST_COLS_FUNCTION, getTableFirstCols);
        lua_register(lua, LUA_GET_CUR_STORE_INFO_FUNCTION, getCurStoreWithParamInfo);
        lua_register(lua, LUA_GET_CUR_STORE_INFO_BY_PARAM_FUNCTION, getCurStoreInfoByParam);
        lua_register(lua, LUA_CALL_QST_WIDGET_METHOD_BY_QSTNAME_FUNCTION, callQstWidgetMethodByQstName);
        lua_register(lua, LUA_CALL_QST_WIDGET_METHOD_BY_QSTCODE_STARTS_FUNCTION, callQstWidgetMethodByQstCodeStarts);
        lua_register(lua, LUA_FIND_ELEMENT_BY_NAME_FUNCTION, findElementByName);
        lua_register(lua, LUA_SET_TIP_FUNCTION, setTip);
        lua_register(lua, LUA_SET_RESULT_FUNCTION, setResult);
        lua_register(lua, LUA_SEND_SMS_FUNCTION, sendSMS);
        
        lua_register(lua, LUA_DELETE_STORE_ACTION, deleteStoreAction);
        lua_register(lua, LUA_CREATE_AND_VISIT_STORE_ACTION, createAndVisitStoreAction);
        lua_register(lua, LUA_SAVE_ACVT_DATA, saveAcvtData);

        
        lua_getglobal(lua, LUA_ON_SUBMIT_FUNCTION);
        int Error = lua_pcall(lua,0,1,0 );    //第二个参数：方法参数，第三个参数：方法返回值
        if (Error == 0) {
            NSString *resultStr = nil;
            if (lua_isstring(lua, -1)) {
                resultStr = [NSString stringWithUTF8String:lua_tostring(lua, -1)];
            }
            NSLog(@"success resultStr：%@", resultStr);
//            [self closeLua];
            return resultStr;
        }
        else {
            NSLog(@"error: %s \n" , lua_tostring(lua, -1));
//            [self closeLua];
        }
    }
    
    return nil;
}
/**
 问卷中 表格产品列的值改变 计算 问卷中关联的问题值
 */
- (NSString *)changeQstValueDependentOnAcvtGrid {
    if (lua) {
        lua_register(lua, LUA_GET_COL_MAX_VALUE_IN_TABLE, getColMaxValueInTable);
        lua_register(lua, LUA_COMPUTE_ROW_AND_COL_SUM,computeRowAndColSum);
        lua_register(lua, LUA_CALL_QST_WIDGET_METHOD_BY_QSTNAME_FUNCTION, callQstWidgetMethodByQstName);
        lua_register(lua, LUA_CALL_QST_WIDGET_METHOD_BY_QSTCODE_STARTS_FUNCTION, callQstWidgetMethodByQstCodeStarts);
        lua_getglobal(lua, LUA_CHANGE_QST_VALUE);
        int Error = lua_pcall(lua,0,1,0 );    //第二个参数：方法参数，第三个参数：方法返回值
        if (Error == 0) {
            NSString *resultStr = nil;
            if (lua_isstring(lua, -1)) {
                resultStr = [NSString stringWithUTF8String:lua_tostring(lua, -1)];
            }
            NSLog(@"success resultStr：%@", resultStr);
//            [self closeLua];
            return resultStr;
        }
        else {
            NSLog(@"error: %s \n" , lua_tostring(lua, -1));
//            [self closeLua];
        }
    }
    
    return nil;

}

- (NSString *)runLuaFunctionByName:(NSString *)functionName param:(NSString *)param
{
    if (lua) {

        NSString *resultStr = nil;
        
        const char *functionNameCString = [functionName UTF8String];
        
        lua_getglobal(lua, functionNameCString);
        
        lua_register(lua, LUA_CALL_QST_WIDGET_METHOD_BY_QSTNAME_FUNCTION, callQstWidgetMethodByQstName);
        lua_register(lua, LUA_SET_UPLOAD_BUTTON_HIDDEN, setUploadButtonHidden);
        lua_register(lua, LUA_GET_TABLE_FIRST_COLS_FUNCTION, getTableFirstCols);
        lua_register(lua, LUA_GET_CUR_STORE_INFO_FUNCTION, getCurStoreWithParamInfo);
        lua_register(lua, LUA_GET_CUR_STORE_INFO_BY_PARAM_FUNCTION, getCurStoreInfoByParam);
        lua_register(lua, LUA_FIND_ELEMENT_BY_NAME_FUNCTION, findElementByName);
        lua_register(lua, LUA_SET_TIP_FUNCTION,setTip);
        lua_register(lua, LUA_SET_RESULT_FUNCTION,setResult);
        lua_register(lua, LUA_SEND_SMS_FUNCTION, sendSMS);
        lua_register(lua, LUA_DELETE_STORE_ACTION, deleteStoreAction);
        lua_register(lua, LUA_CREATE_AND_VISIT_STORE_ACTION, createAndVisitStoreAction);
        lua_register(lua, LUA_SAVE_ACVT_DATA, saveAcvtData);

        lua_register(lua, LUA_MODIFY_QST_REQUIREDSTATE_BY_SELECTEDITEM_FUNCTION, modifyQstRequiredStateBySelectedItem);
        lua_register(lua, LUA_MODIFY_CONTENT_REQUIREDSTATE_BY_BOOLEANEXPRESSION_FUNCTION, modifyContentRequiredStateByBooleanExpression);
        lua_register(lua, LUA_COMPUTE_TABLE_SUM_FUNCTION, computeTableSum);
        lua_register(lua, LUA_COMPUTE_COL_SUM_FUNCTION, computeColSum);
        lua_register(lua, LUA_GENERATE_URL_STRING_WITH_PARAMS_FUNCTION, generateURLStringWithParams);
        lua_register(lua, LUA_SET_CURRENT_QST_VALUE_WITH_TYPE, getMeetingApplicantInfo);
        lua_register(lua, LUA_WEChAT_IMG_SHARE_ACTION , exceseWeChatImgShare);
        lua_register(lua, LUA_CHECK_PRODUCT_VALIDATE, checkProductValidate);
        lua_register(lua, LUA_GET_COL_MAX_VALUE_IN_TABLE, getColMaxValueInTable);
        lua_register(lua, LUA_COMPUTE_ROW_AND_COL_SUM,computeRowAndColSum);
        lua_register(lua, LUA_GET_SERVER_QST_VALUE_BY_QST_CODE,getServerQstValueByQstCode);
        lua_register(lua, LUA_GET_ENTER_STORE_TIME,getEnterStoreTime);
        lua_register(lua, LUA_GET_EXIT_STORE_TIME,getExitStoreTime);
        lua_register(lua, LUA_GET_DURATION_STORE_TIME,getDurationStoreTime);
        lua_register(lua, LUA_REFRESH_ACVT_DIS_DATA_AND_VIEW,refreshAcvtDisDataAndView);
        lua_register(lua, LUA_GET_DATA_BY_METHOD, getDataByMethod);
        lua_register(lua, LUA_GET_STORE_ID, getStoreId);
        lua_register(lua, LUA_GET_STORE_INFO_BY_COD, getStoreInfoByCod);
        lua_register(lua, LUA_GET_STORE_LAT_LON, getEnterStoreLatLon);
        lua_register(lua, LUA_CALL_QST_WIDGET_METHOD_BY_QSTCODE_FUNCTION, callQstWidgetMethodByQstCode);
        lua_register(lua, LUA_CALL_QST_WIDGET_METHOD_BY_QSTCODE_STARTS_FUNCTION, callQstWidgetMethodByQstCodeStarts);
        lua_register(lua, LUA_SET_VALUE_TO_TARGET, setValueToTarget);
        lua_register(lua, LUA_CALL_GRID_METHOD_BY_ROWID_AND_COL, callGridMethodByRowIdAndCol);
        lua_register(lua, LUA_CHECK_MUST_FILL_ONE, checkMustFillOne);
        lua_register(lua, LUA_CHECK_MUST_FILL_ANY_MODE, checkMustFillAnyMode);
        lua_register(lua, LUA_GET_TABLE_COL_VALUE_BY_PROD_ID, getTableColValueByProId);
        lua_register(lua, LUA_SET_TABLE_COL_VALUE_BY_PROD_ID, setTableColValueByProId);
        lua_register(lua, LUA_SET_TABLE_COL_BY_OTHER_TABLE_COL, setTableColByOtherTableCol);
        lua_register(lua, LUA_GET_QST_SERVER_DATA_BY_QST_NAME_AND_GENID, getQstServerDataByQstNameAndGenid);
        lua_register(lua, LUA_GET_QST_SERVER_DATA_BY_QST_CODE_AND_GENID, getQstServerDataByQstCodeAndGenid);
        lua_register(lua, LUA_GET_QST_DATA_BY_QST_CODE_AND_GENID, getQstDataByQstCodeAndGenid);
        lua_register(lua, LUA_SET_COL_DEFAULT_VALUE_WITH_COL_NAME_AND_INDEX, setColDefaultValueWithColNameAndIndex);
        lua_register(lua, LUA_HANDLE_ACVT_METHOD, handleAcvtMethod);
        lua_register(lua, LUA_RESET_MD5_BY_CUSTOM_DATE_STRING, resetMd5ByCustomDateString);
        lua_register(lua, LUA_SAVE_CUSTOM_ENTER_LEAVE_TIME, saveCustomEnterLeaveTime);
        lua_register(lua, LUA_GET_EMP_NAME, getEmpName);
        lua_register(lua, LUA_SET_ACVT_ENABLE_BY_QSTVALUE, setAcvtEnableByQstValue);
        lua_register(lua, LUA_EXCESE_BLUE_TOOTH_PRINT, exceseBlueToothPrint);

        int paramCount = 0;
        
        NSArray *paramArray = [param componentsSeparatedByString:LUA_SEPARATOR];
        for (int i =0 ; i < paramArray.count ; i++  ) {
            NSString *paramStr = [paramArray objectAtIndex:i];
           lua_pushstring(lua, [paramStr UTF8String]);
            paramCount ++;
        }
        
        int Error = lua_pcall(lua,paramCount,0,0 );
        //第二个参数：方法参数，第三个参数：方法返回值
        if (Error == 0) {
            if (lua_isstring(lua, -1)) {
                resultStr = [NSString stringWithUTF8String:lua_tostring(lua, -1)];
            }
        }else {
            LogError(@"error: %s \n" , lua_tostring(lua, -1));
        }
        
//        [self closeLua];
        return resultStr;
    }
    
    return nil;
}




-(BOOL) initializationLuaWithObject:(WSLuaScriptContext*)parserObj
{
    if (!parserObj || !parserObj.luaScriptStr) {
        return NO;
    }
    
    contextScriptParserObj = parserObj;
    int iError;
    if (isLoadFromFile) {
        NSString *scritpFileName = @"script.lua";
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask, YES);
        NSString *regionLuaFile = [[paths objectAtIndex:0] stringByAppendingPathComponent:scritpFileName];
        LogInfo(@"regionLuaFile:%@", regionLuaFile);
        BOOL isSuccess = [parserObj.luaScriptStr writeToFile:regionLuaFile
                                                  atomically:YES
                                                    encoding:NSUTF8StringEncoding
                                                       error:&error];
        if (!isSuccess) {
            //        [self closeLua];
            return NO;
        }
        
        //    lua = [self generateLua];
        //    if (NULL == lua) {
        //        return NO;
        //    }
        iError = luaL_loadfile(lua, regionLuaFile.UTF8String);
        if (iError){
            printf("load script fail1!\n");
            
            LogError(@"error: %s \n luaScript:%@" , lua_tostring(lua, -1), parserObj.luaScriptStr);
            //        [self closeLua];
            return NO;
        }
    } else {
        iError = luaL_loadstring(lua, [parserObj.luaScriptStr UTF8String]);
        if (iError) {
            LogError(@"load lua string error:%s", lua_tostring(lua, -1));
            return NO;
        }
    }
    iError = lua_pcall(lua, 0, 0, 0);
    if (iError){
        LogError("execute script fail2!\n luaScript:%@", parserObj.luaScriptStr);
//        [self closeLua];
        return NO;
    }
    
    return YES;
}

#pragma mark - private method
/**
 *  通过lua脚本，解析内容; 首先初始化lua环境，解析脚本，注册方法。然后，解析出内容。
 *
 *  @param parserObj 解析上下文环境
 *
 *  @return 解析后的内容，如果失败则为nil
 */
- (NSString*) parserContentWithObject:(WSLuaScriptContext*)parserObj
{
    if (!parserObj) {
        return nil;
    }
    
//    contextScriptParserObj = parserObj;
//    NSString *luaFunctionStr = [[NSString alloc] initWithFormat:@"function %s()\n   %@\nend", LUA_START_FUNCTION, contextScriptParserObj.luaScriptStr];
    BOOL isSuccess = [self initializationLuaWithObject:parserObj];
    if (isSuccess) {
        //register sms lua function
        
        lua_register(lua, LUA_FIND_ELEMENT_IN_OTHER_FUNCTION, findElementInOther);
        lua_register(lua, LUA_GET_TABLE_FIRST_COLS_FUNCTION, getTableFirstCols);
        lua_register(lua, LUA_FIND_ELEMENT_IN_ACVT_QSTS_FUNCTION, findElementInAcvtQsts);
        lua_getglobal(lua, LUA_START_FUNCTION);
        
        int Error = lua_pcall(lua,0,1,0 );    //第二个参数：方法参数，第三个参数：方法返回值
        if (Error == 0) {
            NSString *resultStr = [NSString stringWithUTF8String:lua_tostring(lua, -1)];
            NSLog(@"success resultStr：%@", resultStr);
//            [self closeLua];
            return resultStr;
        }
        else {
            NSLog(@"error: %s \n" , lua_tostring(lua, -1));
//            [self closeLua];
        }
    }
    
    return nil;
}
-(lua_State*) generateLua
{
    if (NULL == lua) {
        lua_State *L = luaL_newstate();
        if (L == NULL)
        {
            NSLog(@"error: %s \n" , lua_tostring(L, -1)); //lua程序执行有错误，此处会打印lua的错误行数，下同
            return NULL;
        }
        
        luaopen_base(L);
        luaopen_table(L);
        luaL_openlibs(L);
        luaopen_string(L);
        luaopen_math(L);
        
        lua = L;
    }
    return lua;
}

-(lua_State*) generateExpressionLua
{
    lua_State *L = luaL_newstate();
    if (L == NULL)
    {
        LogError(@"error: %s \n" , lua_tostring(L, -1)); //lua程序执行有错误，此处会打印lua的错误行数，下同
        return NULL;
    }
    
    luaopen_base(L);
    luaopen_table(L);
    luaL_openlibs(L);
    luaopen_string(L);
    luaopen_math(L);
    return L;
}

- (void) closeLua
{
    if (lua) {
        lua_close(lua);
        lua = NULL;
    }
}

- (void) closeExpressionLua
{
    if (expressionLua != NULL) {
        lua_close(expressionLua);
        expressionLua = NULL;
    }
}

#pragma mark - parser birdge method
/**
 *  other中查找方法的birdge
 *
 *  @param filterParamStr 过滤条件 "col=memo3"
 *  @param returnParamStr 返回的字段 “name”
 *
 *  @return 返回结果
 */
- (NSString *)findElementInOtherWithFilterParam:(NSString*)filterParamStr
                                withReturnParam:(NSString*)returnParamStr
{
    if (contextScriptParserObj) {
        return [contextScriptParserObj findElementInOtherWithFilterParam:filterParamStr
                                                         withReturnParam:returnParamStr];
    }
    return nil;
}

- (NSString *)findElementInAcvtTBWithFilterParam:(NSString*)filterParamStr
                                 withReturnParam:(NSString*)returnParamStr
{
    if (contextScriptParserObj) {
        return [contextScriptParserObj findElementInAcvtTBWithFilterParam:filterParamStr
                                                          withReturnParam:returnParamStr];
    }
    return nil;
}

- (NSString *)getCurStoreInfoWithFilterParam:(NSString*)filterParamStr
{
    if (contextScriptParserObj) {
        return [contextScriptParserObj getCurStoreInfoWithFilterParam:filterParamStr];
    }
    return nil;
}

- (NSString *)setTip:(NSString*)nameStr
{
    if (!nameStr || nameStr.length == 0) {
        return nil;
    }
    
    if (contextScriptParserObj) {
        return [contextScriptParserObj setTip:nameStr];
    }
    return nil;
}

- (NSString *)setResult:(NSString*)nameStr
{
    if (!nameStr || nameStr.length == 0) {
        return nil;
    }
    
    if (contextScriptParserObj) {
        return [contextScriptParserObj setResult:nameStr];
    }
    return nil;
}

- (NSString *)findElementByName:(NSString*)nameStr
{
    if (!nameStr || nameStr.length == 0) {
        return nil;
    }
    
    if (contextScriptParserObj) {
        return [contextScriptParserObj findElementContentByName:nameStr];
    }
    return nil;
}


- (NSString *)getColMaxValueInTable:(NSString*)nameStr
{
    if (!nameStr || nameStr.length == 0) {
        return nil;
    }
    
    if (contextScriptParserObj) {
        return [contextScriptParserObj getColMaxValueInTable:nameStr];
    }
    return nil;
}

- (NSString *)computeRowAndColSumWith:(NSString *)prodNames item:(NSString *)colItem {
    if (!prodNames || prodNames.length == 0) {
        return nil;
    }
    
    if (contextScriptParserObj) {
        return [contextScriptParserObj computeRowAndColSumWith:prodNames item:colItem];
    }
    return nil;
}

- (NSString *)doSendSmsWithContent:(NSString*)smsContentStr
{
    if (contextScriptParserObj) {
        return [contextScriptParserObj doSendSmsWithContent:smsContentStr];
    }
    return nil;
}

- (NSString *)findElementInAcvtQstsWithFilterParam:(NSString*)filterParamStr
                                   withReturnParam:(NSString*)returnParamStr
{
    if (contextScriptParserObj) {
        return [contextScriptParserObj findElementInAcvtQstsWithFilterParam:filterParamStr
                                                            withReturnParam:returnParamStr];
    }
    return nil;
}


- (NSString *)doDeleteStoreAction
{
    if (contextScriptParserObj) {
        return [contextScriptParserObj deleteStoreAction];
    }
    return nil;
}

- (NSString *)doCreateAndVisitStoreActionWithTips:(NSString *)tips
{
    if (contextScriptParserObj) {
        return [contextScriptParserObj createAndVisitStoreActionWithTips:tips];
    }
    return nil;
}
- (NSString *)doSaveAcvtData
{
    if (contextScriptParserObj) {
        return [contextScriptParserObj saveAcvtData];
    }
    return nil;
}
-(NSString *)doExceseWeChatImgShare:(NSString *)shareNum{
    if (contextScriptParserObj) {
        shareNum = [shareNum stringByReplacingOccurrencesOfString:LUA_EXTRA withString:@""];
        return [contextScriptParserObj exceseWeChatImgShare:shareNum];
    }
    return nil;
    
}
- (NSString *)doModifyQstRequiredStateBySelectedItem:(NSString*)qstNames withSelectStr:(NSString *)selectedItems
{
    if (contextScriptParserObj) {
        return [contextScriptParserObj modifyQstRequiredStateBySelectedItem:qstNames withSelectStr:selectedItems];
    }
    return nil;
}


- (NSString *)doModifyContentRequiredStateByBooleanExpression:(NSString*)colName withBooleanExpression:(NSString*)expression
{
    if (contextScriptParserObj) {
        return [contextScriptParserObj modifyContentRequiredStateByBooleanExpression:colName withBooleanExpression:expression];
    }
    return nil;
}

- (NSString *)doComputeTableSum:(NSString *)expression
{
    if (contextScriptParserObj) {
        return [contextScriptParserObj computeTableSum:expression];
    }
    return nil;
}


- (NSString *)doComputeColSum:(NSString *)item_col {
    if (contextScriptParserObj) {
        return [contextScriptParserObj computeColSum:item_col];
    }
    return nil;

}

- (NSString *)doCallQstWidgetMethodByQstName:(NSString *)qstName widgetMethod:(NSString *)method methodArgs:(NSArray *)args
{
    if (contextScriptParserObj) {
        return [contextScriptParserObj callQstWidgetMethodByQstName:qstName widgetMethod:method methodArgs:args];
    }
    return nil;
    
}

- (NSString *)doGenerateURLStringWithParams:(NSString *)qstName params:(NSString *)params
{
    if (contextScriptParserObj) {
        return [contextScriptParserObj generateURLStringWithParams:qstName params:params];
    }
    return nil;
    
}

-(NSString *)doGetMeetingApplicationinfoWith:(NSString *)qstName  params:(NSString *)param {
    if (contextScriptParserObj) {
        return [contextScriptParserObj getMeetingApplicantInfoWith:qstName param:param];
    }
    return nil;
}

-(NSString *)doSetUploadButtonHidden:(NSString *)hidden {
    if (contextScriptParserObj) {
        return [contextScriptParserObj setUploadButtonHidden:hidden];
    }
    return nil;
}

-(NSString *)doCheckProductValidateWithDependTableFc:(NSString *)dependFc  dependCol:(NSString *)dependCol validateGroups:(NSString *)validateGroups currentCol:(NSString *)currentCol{
    if (contextScriptParserObj) {
        return [contextScriptParserObj checkProductValidateWithDependTableFc:dependFc dependCol:dependCol validateGroups:validateGroups currentCol:currentCol];
    }
    return nil;
}

- (NSString *)doGetServerQstValueByQstCode:(NSString *)qstCode isStoreIDRelated:(NSString *)isStoreIDRelated
{
    if (contextScriptParserObj) {
        return [contextScriptParserObj getServerQstValueByQstCode:qstCode isStoreIDRelated:isStoreIDRelated];
    }
    return nil;
    
}

- (NSString *)doRefreshAcvtDisDataAndViewByObjId:(NSString *)objId param:(NSString *)param qstCodArgs:(NSArray *)args{
    
    if (contextScriptParserObj) {
        return [contextScriptParserObj refreshAcvtDisDataAndViewByObjId:objId param:param qstCodArgs:args];
    }
    return nil;
}

- (NSString *)doGetEnterStoreTime {
    if (contextScriptParserObj) {
        return [contextScriptParserObj getEnterStoreTime];
    }
    return nil;
}
- (NSString *)doGetEnterStoreLatLon:(NSString *)storeId {
    if (contextScriptParserObj) {
        return [contextScriptParserObj getEnterStoreLatLon:storeId];
    }
    return nil;
}
- (NSString *)doGetExitStoreTime {
    if (contextScriptParserObj) {
        return [contextScriptParserObj getExitStoreTime];
    }
    return nil;
}

- (NSString *)doGetDurationStoreTime {
    if (contextScriptParserObj) {
        return [contextScriptParserObj getDurationStoreTime];
    }
    return nil;
}

- (NSString *)doGetDataByMethod:(NSString *)methodName param:(NSString *)param {
    if (contextScriptParserObj) {
        return [contextScriptParserObj getDataByMethod:methodName param:param];
    }
    return nil;
}

- (NSString *)setValueToTargetWith:(NSString *)value qstName:(NSString *)name {
    if (contextScriptParserObj) {
        return [contextScriptParserObj setValueToTargetWith:value qstName:name];
    }
    return nil;
}

- (NSString *)doCallGridMethodByRow:(NSString *)rowId col:(NSString *)col method:(NSString *)methodName param:(NSString *)param {
    if (contextScriptParserObj) {
        return [contextScriptParserObj callGridMethodByRow:rowId col:col method:methodName param:param];
    }
    return nil;
}



- (NSString *)doGetStoreId{
    
    if (contextScriptParserObj) {
        return [contextScriptParserObj getStoreId];
    }
    return nil;
}

- (NSString *)doGetStoreInfoByCod:(NSString *)cod withQueryName:(NSString *)queryName withArgumentValue:(NSString *)argumentValue{
    
    if (contextScriptParserObj) {
        return [contextScriptParserObj getStoreInfoByCod:cod withQueryName:queryName withArgumentValue:argumentValue];
    }
    return nil;
}

- (NSString *)doCallQstWidgetMethodByQstCode:(NSString *)qstCode widgetMethod:(NSString *)method methodArgs:(NSArray *)args
{
    if (contextScriptParserObj) {
        return [contextScriptParserObj callQstWidgetMethodByQstCode:qstCode widgetMethod:method methodArgs:args];
    }
    return nil;
    
}
- (NSString *)doCallQstWidgetMethodByQstCodeStarts:(NSString *)qstCode widgetMethod:(NSString *)method methodArgs:(NSArray *)args
{
    if (contextScriptParserObj) {
        return [contextScriptParserObj callQstWidgetMethodByQstCodeStarts:qstCode widgetMethod:method methodArgs:args];
    }
    return nil;
    
}

- (NSString *)checkMustFillOneWithQstNames:(NSArray *)qstNames{
    
    if (contextScriptParserObj) {
        return [contextScriptParserObj checkMustFillOneWithQstNames:qstNames];
    }
    return nil;
    
}

- (NSString *)checkMustAnyModeWithMethod:(NSString *)method methodParam:(NSString *)param{
    
    if (contextScriptParserObj) {
        return [contextScriptParserObj checkMustAnyModeWithMethod:method param:param];
    }
    return nil;
    
}

- (NSString *)getTableColValueByProId:(NSString *)prodId col:(NSString *)paramCol {
    if (contextScriptParserObj) {
        return [contextScriptParserObj getTableColValueByProId:prodId col:paramCol];
    }
    return nil;
}


- (NSString *)setTableColValueByProId:(NSString *)prodId textValue:(NSString *)value col:(NSString *)paramCol {
    if (contextScriptParserObj) {
        return [contextScriptParserObj setTableColValueByProId:prodId textValue: value col:paramCol];
    }
    return nil;
}

- (NSString *)setTableColByOtherTableCol:(NSString *)otherTableParmCol funcCode:(NSString *)funcCode  acvtQstCode:(NSString *)acvtQstCode
{
    if (contextScriptParserObj) {
        return [contextScriptParserObj setTableColByOtherTableCol:otherTableParmCol funcCode:funcCode acvtQstCode:acvtQstCode];
    }
    return nil;
}

- (NSString *)doGetQstServerDataByQstName:(NSString *)qstName genId:(NSString *)genId
{
    if (contextScriptParserObj) {
        return [contextScriptParserObj getQstServerDataByQstName:qstName genId:genId];
    }
    return nil;
    
}

- (NSString *)doGetQstServerDataByQstCode:(NSString *)qstCode genId:(NSString *)genId
{
    if (contextScriptParserObj) {
        return [contextScriptParserObj getQstServerDataByQstCode:qstCode genId:genId];
    }
    return nil;
    
}

- (NSString *)doGetQstDataByQstCode:(NSString *)qstCode genId:(NSString *)genId
{
    if (contextScriptParserObj) {
        return [contextScriptParserObj getQstDataByQstCode:qstCode genId:genId];
    }
    return nil;
    
}


- (NSString *)setColDefaultValueWithColName:(NSString *)colName andIndex:(NSString *)index {
    if (!colName || colName.length == 0 || !index || index.length == 0) {
        return nil;
    }
    
    if (contextScriptParserObj) {
        return [contextScriptParserObj setColDefaultValueWithColName:colName andIndex:index];
    }
    return nil;
}

- (NSString *)handleAcvtMethod:(NSString *)methodName  param:(NSString *)param{
    if (!methodName ) {
        return nil;
    }
    if (contextScriptParserObj) {
        return [contextScriptParserObj handleAcvtMethod:methodName param:param];
    }
    return nil;
}

- (NSString *)resetMd5ByCustomDateString:(NSString *)dateString{

    if (contextScriptParserObj) {
        return [contextScriptParserObj resetMd5ByCustomDateString:dateString];
    }
    return nil;
}

- (NSString *)saveCustomEnterLeaveTime:(NSString *)enterdatetime type:(NSString *)type{
    
    if (!enterdatetime) {
        return nil;
    }
    
    if (contextScriptParserObj) {
        return [contextScriptParserObj saveCustomEnterLeaveTime:enterdatetime type:type];
    }
    return nil;
}

- (NSString *)doGetEmpName {
    if (contextScriptParserObj) {
        return [contextScriptParserObj getEmpName];
    }
    return nil;
}

- (NSString *)doSetAcvtEnableByQstValueWithParam:(NSString *)param {
    if (contextScriptParserObj) {
        return [contextScriptParserObj setAcvtEnableByQstValueWithParam:param];
    }
    return nil;
}
- (NSString *)exceseBlueToothPrint:(NSString *)printData withParam:(NSString *)param{
    
    if (contextScriptParserObj) {
        return [contextScriptParserObj exceseBlueToothPrintData:printData withParam:param];
    }
    return nil;
}
#pragma mark - lua tools



- (NSString*) arithmeticExpressions:(NSString*)expression
{
    NSString *scriptContent = [NSString stringWithFormat:@"function arithmeticExpressions()\n    return %@ ;\nend",expression];
    BOOL isSuccess = [self loadLuaEnvironmentWithContent:scriptContent];
    if (isSuccess) {
        lua_getglobal(expressionLua, LUA_ARITHMETIC_EXPRESSIONS_FUNCTION);
        int Error = lua_pcall(expressionLua,0,1,0 );    //第二个参数：方法参数，第三个参数：方法返回值
        if (Error == 0) {
            NSString *resultStr = nil;
            
            if (lua_isboolean(expressionLua, -1)) {
                
                resultStr = [NSString stringWithFormat:@"%d",lua_toboolean(expressionLua, -1)];
                NSLog(@"lua_isboolean : %@" ,resultStr);
            }else if (lua_isstring(expressionLua, -1)){
                
                resultStr = [NSString stringWithUTF8String:lua_tostring(expressionLua, -1)];
                NSLog(@"lua_isstring : %@" ,resultStr);
            }else if (lua_isnumber(expressionLua, -1)){
            
                resultStr = [NSString stringWithFormat:@"%f",[[NSNumber numberWithInteger:lua_toboolean(expressionLua, -1)] doubleValue]];
                NSLog(@"lua_isnumber : %@" ,resultStr);
            }
            NSLog(@"success resultStr：%@", resultStr);
            [self closeExpressionLua];
            return resultStr;
        }
        else {
            NSLog(@"error: %s \n" , lua_tostring(expressionLua, -1));
            [self closeExpressionLua];
        }
    }
    
    return nil;
}

- (BOOL)loadLuaEnvironmentWithContent:(NSString *)content{
    if (expressionLua == NULL) {
        expressionLua = [self generateExpressionLua];
    }
    
    if (NULL == expressionLua) {
        return NO;
    }
    
    int iError;
    if (isLoadFromFile) {
        NSString *scritpFileName = @"expressionScript.lua";
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask, YES);
        NSString *regionLuaFile = [[paths objectAtIndex:0] stringByAppendingPathComponent:scritpFileName];
        LogInfo(@"regionLuaFile:%@", regionLuaFile);
        BOOL isSuccess = [content writeToFile:regionLuaFile
                                   atomically:YES
                                     encoding:NSUTF8StringEncoding
                                        error:&error];
        if (!isSuccess) {
            [self closeExpressionLua];
            return NO;
        }

        iError = luaL_loadfile(expressionLua, regionLuaFile.UTF8String);
        if (iError){
            printf("load script fail1!\n");
            [self closeExpressionLua];
            return NO;
        }
    } else {
        iError = luaL_loadstring(expressionLua, [content UTF8String]);
        if (iError){
            LogError(@"load lua string failed: %s", lua_tostring(lua, -1));
            return NO;
        }
    }
    
    iError = lua_pcall(expressionLua, 0, 0, 0);
    if (iError){
        printf("execute script fail2!\n");
        [self closeExpressionLua];
        return NO;
    }
    
    return YES;


}
#pragma mark - lua function method
/**
 *  SMS lua脚本解析的具体实现
 *
 *  @param L lua环境,携带两个参数
 *
 *  @return lua 返回1
 */
int findElementInOther(lua_State *L)
{
    NSString *filterStr = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    NSString *returnStr = [NSString stringWithUTF8String:lua_tostring(L, 2)];
    
    NSString *outStr = [[WSLuaScript getInstance] findElementInOtherWithFilterParam:filterStr
                                                                    withReturnParam:returnStr];
    if (outStr) {
        lua_pushstring(L, [outStr UTF8String]);
    }else {
        lua_pushstring(L, "");
    }
    
    return 1;
}

int getTableFirstCols(lua_State *L)
{
    NSString *filterStr = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    NSString *returnStr = nil;//[NSString stringWithUTF8String:lua_tostring(L, 2)];
    
    NSString *outStr = [[WSLuaScript getInstance] findElementInAcvtTBWithFilterParam:filterStr
                                                                     withReturnParam:returnStr];
    if (outStr) {
        lua_pushstring(L, [outStr UTF8String]);
    }else {
        lua_pushstring(L, "");
    }
    
    return 1;
}

int getCurStoreWithParamInfo(lua_State *L)
{
    NSString *filterStr = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    
    NSString *outStr = [[WSLuaScript getInstance] getCurStoreInfoWithFilterParam:filterStr];
    if (outStr) {
        lua_pushstring(L, [outStr UTF8String]);
    }else {
        lua_pushstring(L, "");
    }
    
    return 1;
}

int getCurStoreInfoByParam (lua_State *L) {
    NSString *filterStr = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    
    NSString *outStr = [[WSLuaScript getInstance] getCurStoreInfoWithFilterParam:filterStr];
    if (outStr) {
        lua_pushstring(L, [outStr UTF8String]);
    }else {
        lua_pushstring(L, "");
    }
    
    return 1;

}

int setTip(lua_State *L) {
    NSString *nameStr = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    NSString *outStr = [[WSLuaScript getInstance] setTip:nameStr];
    if (outStr) {
        lua_pushstring(L , [outStr UTF8String]);
    }else {
        lua_pushnil(L);
    }
    return 1;
    
}

int setResult(lua_State *L) {
    NSString *nameStr = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    NSString *outStr = [[WSLuaScript getInstance] setResult:nameStr];
    if (outStr) {
        lua_pushstring(L , [outStr UTF8String]);
    }else {
        lua_pushnil(L);
    }
    return 1;
    
}

int findElementByName(lua_State *L)
{
    NSString *nameStr = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    
    NSString *outStr = [[WSLuaScript getInstance] findElementByName:nameStr];
    if (outStr) {
        lua_pushstring(L, [outStr UTF8String]);
    }else {
        lua_pushnil(L);
    }
    
    return 1;
    
    
//    lua_pushstring(L,"arri");
//    lua_newtable(L);
//    {
//        //a trick:otherwise the lua engine will crash. This element is invisible in Lua script
//        lua_pushnumber(L,-1);
//        lua_rawseti(L,-2,0);
//        for(int i = 0; i < 5;i++)
//        {
//            //            lua_pushnumber(L,i);
//            lua_pushstring(L, "HHHHH");
//            lua_rawseti(L,-2,i+1);
//        }
//    }
//    
//    
//    lua_getglobal(L, "background");
//    float f = getField("r", L);
//    float f1 = getField("g", L);
//    float f2 = getField("b", L);
//    
//    lua_getglobal(L, "testdata");
//    lua_pushnil(L);
//    while (lua_next(L, -2) != 0)
//    {
//        if(lua_isnumber(L,-1)) //判断元素类型，也可能是string
//        {
//            
//            float result = (float)lua_tonumber(L, -1);
//            
//        }else {
//            NSString *filterStr = [NSString stringWithUTF8String:lua_tostring(L, -1)];
//        }
//        
//        lua_remove(L,-1);
//    }
//    lua_remove(L,-1);//删除NIL5.如何从C返回数据给Lua脚本
    
    return 1;
}

int getColMaxValueInTable(lua_State *L)
{
    NSString *nameStr = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    
    NSString *outStr = [[WSLuaScript getInstance] getColMaxValueInTable:nameStr];
    if (outStr) {
        lua_pushstring(L, [outStr UTF8String]);
    }else {
        lua_pushnil(L);
    }
    
    return 1;
}


int computeRowAndColSum(lua_State *L)
{
    
    NSString *prodNames = nil;
    
    NSString *colItem = nil; // TB表格的列
    
    if (lua_isstring(L, 1)) {
        prodNames = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    }
    
    if (lua_isstring(L, 2)) {
        colItem = [NSString stringWithUTF8String:lua_tostring(L, 2)];
    }
    
    NSString *outStr = [[WSLuaScript getInstance] computeRowAndColSumWith:prodNames item:colItem];
    if (outStr) {
        lua_pushstring(L, [outStr UTF8String]);
    }else {
        lua_pushnil(L);
    }
    
    return 1;
}



float getField (const char *key, lua_State *L)
{
    float result = 0.0f;
    lua_pushstring(L, key);
    lua_gettable(L, -2);
    result = (float)lua_tonumber(L, -1);
    lua_pop(L, 1);
    return result;
}


int sendSMS(lua_State *L)
{
    NSString *smsContentStr = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    
    NSString *outStr = [[WSLuaScript getInstance] doSendSmsWithContent: smsContentStr];
    if (outStr) {
        lua_pushstring(L, [outStr UTF8String]);
    }else {
        lua_pushnil(L);
    }
    
    return 1;
}

int findElementInAcvtQsts(lua_State *L)
{
    NSString *filterStr = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    NSString *returnStr = [NSString stringWithUTF8String:lua_tostring(L, 2)];
    
    NSString *outStr = [[WSLuaScript getInstance] findElementInAcvtQstsWithFilterParam:filterStr
                                                                       withReturnParam:returnStr];
    if (outStr) {
        lua_pushstring(L, [outStr UTF8String]);
    }else {
        lua_pushstring(L, "");
    }
    
    return 1;
}


int deleteStoreAction(lua_State *L)
{
    NSString *outStr = [[WSLuaScript getInstance] doDeleteStoreAction];
    if (outStr) {
        lua_pushstring(L, [outStr UTF8String]);
    }else {
        lua_pushnil(L);
    }
    
    return 1;
}

int createAndVisitStoreAction(lua_State *L)
{
    NSString *tips = nil;
    
    if (lua_isstring(L, 1)) {
        tips = [NSString stringWithUTF8String:lua_tostring(L, 1)];
        if ([tips rangeOfString:LUA_EXTRA].location != NSNotFound) {
            tips = [tips stringByReplacingOccurrencesOfString:LUA_EXTRA withString:@""];
        }
    }

    NSString *outStr = [[WSLuaScript getInstance] doCreateAndVisitStoreActionWithTips:tips];
    if (outStr) {
        lua_pushstring(L, [outStr UTF8String]);
    }else {
        lua_pushnil(L);
    }
    
    return 1;
}
int saveAcvtData(lua_State *L)
{
    NSString *outStr = [[WSLuaScript getInstance] doSaveAcvtData];
    if (outStr) {
        lua_pushstring(L, [outStr UTF8String]);
    }else {
        lua_pushnil(L);
    }
    
    return 1;
}
int exceseWeChatImgShare(lua_State *L){
    NSString *shareNum = nil;
    if (lua_tostring(L, 1)) {
        shareNum = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    }
    NSString *outStr = [[WSLuaScript getInstance] doExceseWeChatImgShare:shareNum];
    if (outStr) {
        lua_pushstring(L, [outStr UTF8String]);
    }else {
        lua_pushnil(L);
    }
    
    return 1;
}

int modifyQstRequiredStateBySelectedItem(lua_State *L)
{
    
    NSString *qstNames = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    NSString *selectedItems = [NSString stringWithUTF8String:lua_tostring(L, 2)];
    
    NSString *outStr = [[WSLuaScript getInstance] doModifyQstRequiredStateBySelectedItem:qstNames withSelectStr:selectedItems];
    if (outStr) {
        lua_pushstring(L, [outStr UTF8String]);
    }else {
        lua_pushnil(L);
    }
    
    return 1;
}


int modifyContentRequiredStateByBooleanExpression(lua_State *L)
{
    
    NSString *colName = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    NSString *booleanExpression = [NSString stringWithUTF8String:lua_tostring(L, 2)];
    
    NSString *outStr = [[WSLuaScript getInstance] doModifyContentRequiredStateByBooleanExpression:colName withBooleanExpression:booleanExpression];
    if (outStr) {
        lua_pushstring(L, [outStr UTF8String]);
    }else {
        lua_pushnil(L);
    }
    
    return 1;
}

int computeTableSum(lua_State *L){
    
    NSString *expression = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    NSString *outStr = [[WSLuaScript getInstance] doComputeTableSum:expression];
    if (outStr) {
         lua_pushstring(L, [outStr UTF8String]);
    }else {
        
        lua_pushnil(L);
    }
    
    return 1;
}

int computeColSum(lua_State *L){
    
    NSString *item_col = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    NSString *outStr = [[WSLuaScript getInstance] doComputeColSum:item_col];
    if (outStr) {
        lua_pushstring(L, [outStr UTF8String]);
    }else {
        
        lua_pushnil(L);
    }
    
    return 1;
}

int callQstWidgetMethodByQstName(lua_State *L){
    
    NSString *qstName = nil;
    NSString *method = nil;
    BOOL isAllowExam = NO;
    
    NSString *resultValue = nil;
    
    if (lua_isstring(L, 1)) {
        qstName = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    }
    
    if (lua_isstring(L, 2)) {
        method = [NSString stringWithUTF8String:lua_tostring(L, 2)];
    }
    
    if (!lua_isnil(L, 3)) {
        
        NSString *parameterString;
        
        if (lua_isboolean(L, 3)) {
            isAllowExam = lua_toboolean(L, 3);
            parameterString = @"0";
            if (isAllowExam) {
                parameterString = @"1";
            }
        }else if(lua_isstring(L, 3)) {
            parameterString = [NSString stringWithUTF8String:lua_tostring(L, 3)];
            parameterString = [parameterString stringByReplacingOccurrencesOfString:@"\"" withString:@""];

            parameterString = [parameterString stringByReplacingOccurrencesOfString:LUA_EXTRA withString:@""];
        }
        
        resultValue = [[WSLuaScript getInstance] doCallQstWidgetMethodByQstName:qstName widgetMethod:method methodArgs:[NSArray arrayWithObject:[NSString stringNotNilWithValue:parameterString]]];
    }else {
        resultValue = [[WSLuaScript getInstance] doCallQstWidgetMethodByQstName:qstName widgetMethod:method methodArgs:nil];
    }
    
    
    if (resultValue) {
        lua_pushstring(L, [resultValue UTF8String]);
    }else {
        lua_pushnil(L);
    }

    return 1;
}

int generateURLStringWithParams(lua_State *L){
    
    NSString *qstName = nil;
    NSString *params = nil;
    if (lua_isstring(L, 1)) {
        qstName = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    }
    
    if (lua_isstring(L, 2)) {
        params = [NSString stringWithUTF8String:lua_tostring(L, 2)];
    }
    if (qstName ) {
         [[WSLuaScript getInstance] doGenerateURLStringWithParams:qstName params:params];
    }
    return 1;
}

int getMeetingApplicantInfo(lua_State *L){
    
    NSString *qstName = nil;
    NSString *param = nil;
    if (lua_isstring(L, 1)) {
        qstName = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    }
    if (lua_isstring(L, 2)) {
        param = [NSString stringWithUTF8String:lua_tostring(L, 2)];
    }
    
    if (qstName) {
        [[WSLuaScript getInstance] doGetMeetingApplicationinfoWith:qstName params:param];
    }
    return 1;
}

int setUploadButtonHidden(lua_State *L){
    
    BOOL isEnable = NO;
    
    if (!lua_isnil(L, 1)) {
        
        NSString *parameterString;
        
        if (lua_isboolean(L, 1)) {
            isEnable = lua_toboolean(L, 1);
            parameterString = @"0";
            if (isEnable) {
                parameterString = @"1";
            }
        }else if(lua_isstring(L, 1)) {
            parameterString = [NSString stringWithUTF8String:lua_tostring(L, 1)];
        }
        
        [[WSLuaScript getInstance] doSetUploadButtonHidden:parameterString];
        
    }
    
    return 1;
}


int checkProductValidate(lua_State *L){
    
    NSString *dependTableFc = nil;
    NSString *dependCol = nil;
    NSString *ValidateGroups = nil;
    NSString *currentCol = nil;
    
    
    if (lua_isstring(L, 1)) {
        dependTableFc = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    }
    
    if (lua_isstring(L, 2)) {
        dependCol = [NSString stringWithUTF8String:lua_tostring(L, 2)];
    }
    
    if (lua_isstring(L, 3)) {
        ValidateGroups = [NSString stringWithUTF8String:lua_tostring(L, 3)];
    }
    
    if (lua_isstring(L, 4)) {
        currentCol = [NSString stringWithUTF8String:lua_tostring(L, 4)];
    }

        
    [[WSLuaScript getInstance] doCheckProductValidateWithDependTableFc:dependTableFc dependCol:dependCol validateGroups:ValidateGroups currentCol:currentCol];
        

    return 1;
}



int getServerQstValueByQstCode(lua_State *L){
    
    NSString *qstCode = nil;
    NSString *isStoreIDRelated = nil;
    
    
    if (lua_isstring(L, 1)) {
        qstCode = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    }
    
    if (lua_isstring(L, 2)) {
        isStoreIDRelated = [NSString stringWithUTF8String:lua_tostring(L, 2)];
    }
    
    if (qstCode && isStoreIDRelated) {
        
        NSString *value = [[WSLuaScript getInstance] doGetServerQstValueByQstCode:qstCode isStoreIDRelated:isStoreIDRelated];
        lua_pushstring(L ,[value UTF8String]);
    }
    
    return 1;
}

int getEnterStoreTime(lua_State *L) {
    
        
    
    NSString *value = [[WSLuaScript getInstance] doGetEnterStoreTime];
    lua_pushstring(L ,[value UTF8String]);
    return 1;
}
int getEnterStoreLatLon(lua_State *L){
    
    NSString *qstNames = [NSString stringWithUTF8String:lua_tostring(L , 1)];
    NSString *value = [[WSLuaScript getInstance] doGetEnterStoreLatLon:[NSString stringNotNilWithValue:qstNames]];
    
    if (value) {
        lua_pushstring(L , [value UTF8String]);
    }else {
        lua_pushnil(L);
    }
    return 1;
}
int getExitStoreTime(lua_State *L) {
    NSString *value = [[WSLuaScript getInstance] doGetExitStoreTime];
    lua_pushstring(L ,[value UTF8String]);
    return 1;
    
}

int getDurationStoreTime(lua_State *L) {
    NSString *value = [[WSLuaScript getInstance] doGetDurationStoreTime];
    lua_pushstring(L ,[value UTF8String]);
    return 1;
}


int refreshAcvtDisDataAndView(lua_State *L){
    
    NSString *objId = nil;
    NSString *param = nil;
    NSString *qstCodStr = nil;
    
    if (lua_isstring(L,1)) {
        objId = [NSString stringWithUTF8String:lua_tostring(L , 1)];
    }
    if (lua_isstring(L,2)) {
        param = [NSString stringWithUTF8String:lua_tostring(L, 2)];
    }
    if (lua_isstring(L, 3)) {
        qstCodStr = [NSString stringWithUTF8String:lua_tostring(L, 3)];
    }
    
    qstCodStr = [NSString stringNotNilWithValue:qstCodStr];
    
    NSArray *qstCodArg =[qstCodStr componentsSeparatedByString:@","];
    
    NSString *value =[[WSLuaScript getInstance] doRefreshAcvtDisDataAndViewByObjId:objId param:param qstCodArgs:qstCodArg];
    
    if (value) {
        lua_pushstring(L , [value UTF8String]);
    }else {
        lua_pushnil(L);
    }
    
    return 1;
}
int getDataByMethod(lua_State *L){
    
    NSString *methodName = nil;
    NSString *params = nil;
    
    if (lua_isstring(L,1)) {
        methodName = [NSString stringWithUTF8String:lua_tostring(L , 1)];
    }
    if (lua_isstring(L,2)) {
        params = [NSString stringWithUTF8String:lua_tostring(L, 2)];
    }
    
    params = [params stringByReplacingOccurrencesOfString:LUA_EXTRA withString:@""];
    
    NSString *value =[[WSLuaScript getInstance] doGetDataByMethod:methodName param:params];
    
    if (value) {
        lua_pushstring(L , [value UTF8String]);
    }else {
        lua_pushnil(L);
    }
    
    return 1;
}

int getStoreId(lua_State *L) {
    
    NSString *value = [[WSLuaScript getInstance] doGetStoreId];
    lua_pushstring(L ,[value UTF8String]);
    return 1;
}

int getStoreInfoByCod(lua_State *L){
    
    NSString *storeCod = nil;
    NSString *queryName = nil;
    NSString *argumentValue = nil;
    
    if (lua_isstring(L,1)) {
        storeCod = [NSString stringWithUTF8String:lua_tostring(L , 1)];
    }
    if (lua_isstring(L,2)) {
        queryName = [NSString stringWithUTF8String:lua_tostring(L, 2)];
    }
    if (lua_isstring(L, 3)) {
        argumentValue = [NSString stringWithUTF8String:lua_tostring(L, 3)];
    }
    
    NSString *value = [[WSLuaScript getInstance] doGetStoreInfoByCod:storeCod withQueryName:queryName withArgumentValue:argumentValue];
    
    if (value) {
        lua_pushstring(L , [value UTF8String]);
    }else {
        lua_pushnil(L);
    }

    return 1;
}

int callQstWidgetMethodByQstCode(lua_State *L){
    
    NSString *qstCode = nil;
    NSString *method = nil;
    BOOL isAllowExam = NO;
    
    NSString *resultValue = nil;
    
    if (lua_isstring(L, 1)) {
        qstCode = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    }
    
    if (lua_isstring(L, 2)) {
        method = [NSString stringWithUTF8String:lua_tostring(L, 2)];
    }
    
    if (!lua_isnil(L, 3)) {
        
        NSString *parameterString;
        
        if (lua_isboolean(L, 3)) {
            isAllowExam = lua_toboolean(L, 3);
            parameterString = @"0";
            if (isAllowExam) {
                parameterString = @"1";
            }
        }else if(lua_isstring(L, 3)) {
            parameterString = [NSString stringWithUTF8String:lua_tostring(L, 3)];
            parameterString = [parameterString stringByReplacingOccurrencesOfString:@"\"" withString:@""];

            parameterString = [parameterString stringByReplacingOccurrencesOfString:LUA_EXTRA withString:@""];
        }
        
        resultValue = [[WSLuaScript getInstance] doCallQstWidgetMethodByQstCode:qstCode widgetMethod:method methodArgs:[NSArray arrayWithObject:[NSString stringNotNilWithValue:parameterString]]];
    }else {
        resultValue = [[WSLuaScript getInstance] doCallQstWidgetMethodByQstCode:qstCode widgetMethod:method methodArgs:nil];
    }
    
    
    if (resultValue) {
        lua_pushstring(L, [resultValue UTF8String]);
    }else {
        lua_pushnil(L);
    }
    
    return 1;
}

int callQstWidgetMethodByQstCodeStarts(lua_State *L){
    
    NSString *qstCode = nil;
    NSString *method = nil;
    BOOL isAllowExam = NO;
    
    NSString *resultValue = nil;
    
    if (lua_isstring(L, 1)) {
        qstCode = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    }
    
    if (lua_isstring(L, 2)) {
        method = [NSString stringWithUTF8String:lua_tostring(L, 2)];
    }
    
    if (!lua_isnil(L, 3)) {
        
        NSString *parameterString;
        
        if (lua_isboolean(L, 3)) {
            isAllowExam = lua_toboolean(L, 3);
            parameterString = @"0";
            if (isAllowExam) {
                parameterString = @"1";
            }
        }else if(lua_isstring(L, 3)) {
            parameterString = [NSString stringWithUTF8String:lua_tostring(L, 3)];
            parameterString = [parameterString stringByReplacingOccurrencesOfString:@"\"" withString:@""];

            parameterString = [parameterString stringByReplacingOccurrencesOfString:LUA_EXTRA withString:@""];
        }
        


        resultValue = [[WSLuaScript getInstance] doCallQstWidgetMethodByQstCodeStarts:qstCode widgetMethod:method methodArgs:[NSArray arrayWithObject:[NSString stringNotNilWithValue:parameterString]]];
    }else {
        resultValue = [[WSLuaScript getInstance] doCallQstWidgetMethodByQstCodeStarts:qstCode widgetMethod:method methodArgs:nil];
    }
    
    
    if (resultValue) {
        lua_pushstring(L, [resultValue UTF8String]);
    }else {
        lua_pushnil(L);
    }
    
    return 1;
}

int setValueToTarget(lua_State *L){
    
    NSString *colSum  = nil;
    NSString *qstName = nil;
    
    if (lua_isstring(L,1)) {
        colSum = [NSString stringWithUTF8String:lua_tostring(L , 1)];
    }
    if (lua_isstring(L,2)) {
        qstName = [NSString stringWithUTF8String:lua_tostring(L, 2)];
    }

    NSString *value =[[WSLuaScript getInstance] setValueToTargetWith:[NSString stringWithFormat:@"%0.2f",[colSum floatValue]] qstName:qstName];
    
    if (value) {
        lua_pushstring(L , [value UTF8String]);
    }else {
        lua_pushnil(L);
    }
    
    return 1;
}

int callGridMethodByRowIdAndCol(lua_State *L) {
    NSString *rowId = nil;
    NSString *col = nil;
    NSString *methodName = nil;
    NSString *param = nil;
    
    if (lua_isstring(L, 1)) {
        rowId = [NSString stringWithUTF8String:lua_tostring(L, 1)];
        if ([rowId rangeOfString:LUA_EXTRA].location != NSNotFound) {
            rowId = [rowId stringByReplacingOccurrencesOfString:LUA_EXTRA withString:@""];
        }
    }
    
    if (lua_isstring(L, 2)) {
        col = [NSString stringWithUTF8String:lua_tostring(L, 2)];
        if ([col rangeOfString:LUA_EXTRA].location != NSNotFound) {
            col = [col stringByReplacingOccurrencesOfString:LUA_EXTRA withString:@""];
        }
    }
    
    if (lua_isstring(L, 3)) {
        methodName = [NSString stringWithUTF8String:lua_tostring(L, 3)];
        if ([methodName rangeOfString:LUA_EXTRA].location != NSNotFound) {
            methodName = [methodName stringByReplacingOccurrencesOfString:LUA_EXTRA withString:@""];
        }
    }
    
    if (lua_isstring(L, 4)) {
        param = [NSString stringWithUTF8String:lua_tostring(L, 4)];
        if ([param rangeOfString:LUA_EXTRA].location != NSNotFound) {
            param = [param stringByReplacingOccurrencesOfString:LUA_EXTRA withString:@""];
        }
    }
    
    NSString *resultValue =[[WSLuaScript getInstance] doCallGridMethodByRow:rowId col:col method:methodName param:param];
    if (resultValue) {
        lua_pushstring(L, [resultValue UTF8String]);
    }else {
        lua_pushnil(L);
    }
    
    return 1;
}

int checkMustFillOne(lua_State *L){
    
    NSString *qstNames = [NSString stringWithUTF8String:lua_tostring(L , 1)];
    NSString *value = [[WSLuaScript getInstance] checkMustFillOneWithQstNames:[NSArray arrayWithObject:[NSString stringNotNilWithValue:qstNames]]];
    
    if (value) {
        lua_pushstring(L , [value UTF8String]);
    }else {
        lua_pushnil(L);
    }
    return 1;
}

int checkMustFillAnyMode(lua_State *L){
    
    NSString *methodName = nil;
    NSString *params = nil;
    
    if (lua_isstring(L,1)) {
        methodName = [NSString stringWithUTF8String:lua_tostring(L , 1)];
    }
    if (lua_isstring(L,2)) {
        params = [NSString stringWithUTF8String:lua_tostring(L, 2)];
    }
    
    params = [params stringByReplacingOccurrencesOfString:LUA_EXTRA withString:@""];
    
    NSString *value = [[WSLuaScript getInstance] checkMustAnyModeWithMethod:methodName methodParam:params];
    
    if (value) {
        lua_pushstring(L , [value UTF8String]);
    }else {
        lua_pushnil(L);
    }
    return 1;
}

int getTableColValueByProId(lua_State *L) {
    
    NSString *prodId = nil;
    NSString *colForGridParam = nil;
    
    if (lua_isstring(L, 1)) {
        prodId = [NSString stringWithUTF8String:lua_tostring(L , 1)];
    }
    
    if (lua_isstring(L, 2)) {
        colForGridParam = [NSString stringWithUTF8String:lua_tostring(L, 2)];
    }
    
    NSString *value = [[WSLuaScript getInstance] getTableColValueByProId:prodId col:colForGridParam];
    
    if (value) {
        lua_pushstring(L, [value UTF8String]);
    }else {
        lua_pushnil(L);
    }
    return 1;
    
}


int setTableColValueByProId(lua_State *L) {
    NSString *prodId = nil;
    NSString *textValue = nil;
    NSString *colForGridParam = nil;
    
    if (lua_isstring(L, 1)) {
        prodId = [NSString stringWithUTF8String:lua_tostring(L , 1)];
    }
    
    if (lua_isstring(L, 2)) {
        textValue = [NSString stringWithUTF8String:lua_tostring(L , 2)];
    }
    
    if (lua_isstring(L, 3)) {
        colForGridParam = [NSString stringWithUTF8String:lua_tostring(L, 3)];
    }
    
    NSString *value = [[WSLuaScript getInstance] setTableColValueByProId:prodId textValue:textValue col:colForGridParam];
    
    if (value) {
        lua_pushstring(L, [value UTF8String]);
    }else {
        lua_pushnil(L);
    }
    return 1;
}

int setTableColByOtherTableCol(lua_State *L) {
    NSString *funcCode = nil;
    NSString *otherTableColParam = nil;
    NSString *acvtQstCode = nil;
    
    if (lua_isstring(L, 1)) {
        funcCode = [NSString stringWithUTF8String:lua_tostring(L , 1)];
    }
    
    if (lua_isstring(L, 2)) {
        otherTableColParam = [NSString stringWithUTF8String:lua_tostring(L , 2)];
    }
    
    if (lua_isstring(L, 3)) {
        acvtQstCode = [NSString stringWithUTF8String:lua_tostring(L, 3)];
    }
    
    NSString *value = [[WSLuaScript getInstance] setTableColByOtherTableCol:otherTableColParam funcCode:funcCode acvtQstCode:acvtQstCode];
    
    if (value) {
        lua_pushstring(L, [value UTF8String]);
    }else {
        lua_pushnil(L);
    }
    return 1;
}

int getQstServerDataByQstNameAndGenid(lua_State *L){
    
    NSString *qstName = nil;
    NSString *genid = nil;
    
    
    if (lua_isstring(L, 1)) {
        qstName = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    }
    
    if (lua_isstring(L, 2)) {
        genid = [NSString stringWithUTF8String:lua_tostring(L, 2)];
    }
    
    if (qstName && genid) {
        NSString *value = [[WSLuaScript getInstance] doGetQstServerDataByQstName:qstName genId:genid];
        if (value) {
            lua_pushstring(L ,[value UTF8String]);
        }else {
            lua_pushnil(L);
        }
        
    }
    
    return 1;
}

int getQstServerDataByQstCodeAndGenid(lua_State *L){
    
    NSString *qstName = nil;
    NSString *genid = nil;
    
    
    if (lua_isstring(L, 1)) {
        qstName = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    }
    
    if (lua_isstring(L, 2)) {
        genid = [NSString stringWithUTF8String:lua_tostring(L, 2)];
    }
    
    if (qstName && genid) {
        NSString *value = [[WSLuaScript getInstance] doGetQstServerDataByQstCode:qstName genId:genid];
        if (value) {
            lua_pushstring(L ,[value UTF8String]);
        }else {
            lua_pushnil(L);
        }
        
    }
    
    return 1;
}

int getQstDataByQstCodeAndGenid(lua_State *L){
    
    NSString *qstName = nil;
    NSString *genid = nil;
    
    
    if (lua_isstring(L, 1)) {
        qstName = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    }
    
    if (lua_isstring(L, 2)) {
        genid = [NSString stringWithUTF8String:lua_tostring(L, 2)];
    }
    
    if (qstName && genid) {
        NSString *value = [[WSLuaScript getInstance] doGetQstDataByQstCode:qstName genId:genid];
        if (value) {
            lua_pushstring(L ,[value UTF8String]);
        }else {
            lua_pushnil(L);
        }
        
    }
    
    return 1;
}

int setColDefaultValueWithColNameAndIndex(lua_State *L)
{
    
    NSString *colName = nil;
    
    NSString *index = nil; // TB表格的列
    
    if (lua_isstring(L, 1)) {
        colName = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    }
    
    if (lua_isstring(L, 2)) {
        index = [NSString stringWithUTF8String:lua_tostring(L, 2)];
    }
    
    NSString *outStr = [[WSLuaScript getInstance] setColDefaultValueWithColName:colName andIndex:index];
    if (outStr) {
        lua_pushstring(L, [outStr UTF8String]);
    }else {
        lua_pushnil(L);
    }
    
    return 1;
}


int handleAcvtMethod(lua_State *L)
{

    NSString *methodName = nil;
    
    NSString *param = nil;
    
    if (lua_isstring(L, 1)) {
         methodName= [NSString stringWithUTF8String:lua_tostring(L, 1)];
    }
    
    if (lua_isstring(L, 2)) {
        param = [NSString stringWithUTF8String:lua_tostring(L, 2)];
    }
    
    NSString *outStr = [[WSLuaScript getInstance] handleAcvtMethod:methodName param:param];
    if (outStr) {
        lua_pushstring(L, [outStr UTF8String]);
    }else {
        lua_pushnil(L);
    }
    
    return 1;
}

int resetMd5ByCustomDateString(lua_State *L)
{
    
    NSString *param = nil;
    
    if (lua_isstring(L, 1)) {
        param = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    }
    
    NSString *outStr = [[WSLuaScript getInstance] resetMd5ByCustomDateString:param];
    if (outStr) {
        lua_pushstring(L, [outStr UTF8String]);
    }else {
        lua_pushnil(L);
    }
    
    return 1;
}

int saveCustomEnterLeaveTime(lua_State *L)
{
    
    NSString *param = nil;
    
    if (lua_isstring(L, 1)) {
        param = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    }
    
    NSString *type = nil;
    if (lua_isstring(L, 2)) {
        type = [NSString stringWithUTF8String:lua_tostring(L, 2)];
    }
    
    NSString *outStr = [[WSLuaScript getInstance] saveCustomEnterLeaveTime:param type:type];
    if (outStr) {
        lua_pushstring(L, [outStr UTF8String]);
    }else {
        lua_pushnil(L);
    }
    
    return 1;
}

int getEmpName(lua_State *L) {
    NSString *value = [[WSLuaScript getInstance] doGetEmpName];
    lua_pushstring(L ,[value UTF8String]);
    return 1;
}

int setAcvtEnableByQstValue(lua_State *L) {
    NSString *param = nil;
    
    if (lua_isstring(L, 1)) {
        param = [NSString stringWithUTF8String:lua_tostring(L, 1)];
        if ([param rangeOfString:LUA_EXTRA].location != NSNotFound) {
            param = [param stringByReplacingOccurrencesOfString:LUA_EXTRA withString:@""];
        }
    }
    NSString *value = [[WSLuaScript getInstance] doSetAcvtEnableByQstValueWithParam:param];
    lua_pushstring(L ,[value UTF8String]);
    return 1;
}

int exceseBlueToothPrint(lua_State *L){
    NSString *printData = nil;
    
    if (lua_isstring(L, 1)) {
        printData = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    }
    
    NSString *param = nil;
    if (lua_isstring(L, 2)) {
        param = [NSString stringWithUTF8String:lua_tostring(L, 2)];
    }
    
    NSString *outStr = [[WSLuaScript getInstance] exceseBlueToothPrint:printData withParam:param];
    if (outStr) {
        lua_pushstring(L, [outStr UTF8String]);
    }else {
        lua_pushnil(L);
    }
    
    return 1;

}

-(void)setLuaFunctionName:(NSString *)functionName{
    _functionName = functionName;
}

-(NSString *)getLuaFunctionName{
    return _functionName;
}
@end

//
//  WSLuaScriptContext.m
//  TestLua2
//
//  Created by dujinfeng481 on 14-8-26.
//  Copyright (c) 2014年 djf. All rights reserved.
//

#import "WSLuaScriptContext.h"
#import "WSFuncsBean.h"
#import "WSStoreBean.h"
#import "WSAcvtBean.h"
#import "WSAcvtDataGridComponentDataSource.h"
#import "WSLuaPackageDefine.h"
#import "I_Lua_Executor.h"
#import "WSLuaExecutorManager.h"
#import "WSLuaDefine.h"
#import "WSDataSourceManager.h"
#import "WSBaseModel.h"
#import "WCURLUILabel.h"
@interface WSLuaScriptContext()
@property (nonatomic, strong) WSFuncsBean   *contextFuncsBean;
@property (nonatomic, strong) WSStoreBean   *contextStoreBean;
@property (nonatomic, strong) WSAcvtBean    *contextAcvtBean;

@property (nonatomic, copy) LuaScriptWithParamsExpandBlock expandBlockWithVariableParams;
@end

@implementation WSLuaScriptContext

-(id) initWithFuncsBean:(WSFuncsBean*)funcsBean
          withStoreBean:(WSStoreBean*)storeBean
               withAcvt:(WSAcvtBean*)acvtBean
{
    self = [super init];
    if (self) {
        self.contextFuncsBean = funcsBean;
        self.contextStoreBean = storeBean;
        self.contextAcvtBean  = acvtBean;
    }
    
    return self;
}

- (void) initializationWithVariableParamsBlock:(LuaScriptWithParamsExpandBlock)block
{
    self.expandBlockWithVariableParams = block;
}

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
    NSLog(@"WSLuaScriptContext filterParamStr:%@", filterParamStr);
    NSLog(@"WSLuaScriptContext returnParamStr:%@", returnParamStr);
    
    __block NSString *outputStr = nil;
    NSArray *params = [filterParamStr componentsSeparatedByString:@"="];
    if (params && params.count == 2) {
        
        if (!self.contextFuncsBean) {
            if (self.expandBlockWithVariableParams) {
                outputStr = self.expandBlockWithVariableParams(WSLUA_FUNCTION_ACVTTBCONTEXT_RETURN_ARRAY);
            }
        }else{
            NSArray *otherArray = self.contextFuncsBean.otherArray;
            
            //从other 数组中遍历
            [otherArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSString *vlaue = [obj valueForKey:[params objectAtIndex:0]];
                if ([vlaue isEqualToString:[params objectAtIndex:1]]) {
                    if ([returnParamStr isEqualToString:@"inputContent"]) {
                        if (self.expandBlockWithVariableParams) {
                            outputStr = self.expandBlockWithVariableParams(WSLUA_FUNCTION_EXPANDBLOCK_PARAM_ACVTBEANQST_RETURN_STRING,obj);
                        }
                    }else {
                        outputStr = [obj valueForKeyPath:returnParamStr];
                    }
                    *stop = YES;
                }
            }];
        }
    }
    
    NSLog(@"returnParamStr %@=%@", returnParamStr, outputStr);
    return outputStr;
}

- (NSString *)findElementInAcvtTBWithFilterParam:(NSString*)filterParamStr
                                 withReturnParam:(NSString*)returnParamStr
{
    NSLog(@"WSLuaScriptContext filterParamStr:%@", filterParamStr);
    
    NSMutableString *outputStr = [[NSMutableString alloc] init];
    NSArray *tables = [filterParamStr componentsSeparatedByString:@","];
    for (NSString *paramItem in tables) {
        NSArray *params = [paramItem componentsSeparatedByString:@"="];
        if (params && params.count == 2 && self.expandBlockWithVariableParams) {
//            WSAcvtDataGridComponentDataSource *acvtDataSource = self.acvtTBContextBlock();
            NSArray *tableSources = self.expandBlockWithVariableParams(WSLUA_FUNCTION_ACVTTBCONTEXT_RETURN_ARRAY);
            if (tableSources) {
                NSUInteger tabIdEndLocation = [[params objectAtIndex:0] rangeOfString:@"["].location;
                NSUInteger indexEndLocation = [[params objectAtIndex:0] rangeOfString:@"]"].location;
                NSString *tableId = [[params objectAtIndex:0] substringWithRange:NSMakeRange(0, tabIdEndLocation)]; //mc
                NSString *indexStr = [[params objectAtIndex:0] substringWithRange:NSMakeRange(tabIdEndLocation+1, indexEndLocation-tabIdEndLocation-1)];
                int colIndex = [indexStr intValue] -1;
                
                for (WSAcvtDataGridComponentDataSource *acvtDataSource in tableSources) {
                    if([acvtDataSource.currentTableItem.ds isEqualToString:DS_PROD] || [acvtDataSource.currentTableItem.ds isEqualToString:DS_PRODC]) {
                        if (acvtDataSource.currentQst && acvtDataSource.currentQst.mc && [acvtDataSource.currentQst.mc isEqualToString:tableId]) {
                            
                            //查找每一条数据对应的列是否满足单选，选中
                            for (NSArray *dataItems in acvtDataSource.data) {
                                if (dataItems.count > colIndex) {
                                    id colObj = [dataItems objectAtIndex:colIndex];
                                    if ([colObj isKindOfClass:[WSCheckBox class]]) {    //检测是单选列表
                                        WSCheckBox *checkBox = (WSCheckBox *)colObj;
                                        BOOL selected = checkBox.selected;
                                        if ((selected && [[params objectAtIndex:1] caseInsensitiveCompare:@"true"]
                                             == NSOrderedSame) ||
                                            (!selected && [[params objectAtIndex:1] caseInsensitiveCompare:@"false"] == NSOrderedSame)) {
                                            id titleView = [dataItems objectAtIndex:0];
                                            if ([titleView isKindOfClass:[UILabel class]]) {
                                                UILabel *label = (UILabel*)titleView;
                                                if (outputStr.length > 0) {
                                                    [outputStr appendString:@","];
                                                }
                                                [outputStr appendString:[label text]];
                                            }else {
                                                NSLog(@"Error: one low is not UILabel");
                                            }
                                        }
                                    }else if ([colObj isKindOfClass:[WCURLUILabel class]]){
                                        WCURLUILabel * label = (WCURLUILabel *)colObj;
                                        if (outputStr.length > 0) {
                                            [outputStr appendString:@","];
                                        }
                                        [outputStr appendString:[label text]];
                                    }
                                    else {
                                        NSLog(@"Error: no check box");
                                    }
                                }
                                else {
                                    NSLog(@"Error: colIndex > count");
                                }
                            }
                        }
                    }
                    else {
                        LogError(@"ds is dicts type, no supper :%@", acvtDataSource.currentTableItem.ds);
                    }
                }
            }
            else {
                LogError(@"acvtTBContextBlock is empty!");
            }
        }
    }
    
    
    if (outputStr.length == 0) {
        self.isCanceled = YES;
    }
    
    NSLog(@"returnParamStr %@=%@", returnParamStr, outputStr);
    return outputStr;
}

//- (NSString *)findElementInAcvtTBWithFilterParam:(NSString*)filterParamStr
//                                 withReturnParam:(NSString*)returnParamStr
//{
//    NSLog(@"WSLuaScriptContext filterParamStr:%@", filterParamStr);
//    NSLog(@"WSLuaScriptContext returnParamStr:%@", returnParamStr);
//    
//    NSMutableString *outputStr = [[NSMutableString alloc] init];
//    NSArray *params = [filterParamStr componentsSeparatedByString:@"="];
//    if (params && params.count == 2 && self.acvtTBContextBlock) {
//        WSAcvtDataGridComponentDataSource *acvtDataSource = self.acvtTBContextBlock();
//        if (acvtDataSource) {
//            if([acvtDataSource.ds isEqualToString:DS_PROD] || [acvtDataSource.ds isEqualToString:DS_PRODC]) {
//                int colIndex = 0;
//                for (WSFuncsBean_Param *paramItem in acvtDataSource.paramsArray) {
//                    NSString *vlaue = [paramItem valueForKey:[params objectAtIndex:0]];
//                    //查找到了列对应的index
//                    if ([vlaue isEqualToString:[params objectAtIndex:1]]) {
//                        
//                        //查找每一条数据对应的列是否满足单选，选中
//                        for (NSArray *dataItems in acvtDataSource.data) {
//                            if (dataItems.count > (colIndex+1)) {
//                                id colObj = [dataItems objectAtIndex:colIndex+1];
//                                if ([colObj isKindOfClass:[WSCheckBox class]]) {    //检测是单选列表
//                                    WSCheckBox *checkBox = (WSCheckBox *)colObj;
//                                    BOOL selected = checkBox.selected;
//                                    if (selected) {
//                                        id titleView = [dataItems objectAtIndex:0];
//                                        if ([titleView isKindOfClass:[UILabel class]]) {
//                                            UILabel *label = (UILabel*)titleView;
//                                            if (outputStr.length > 0) {
//                                                [outputStr appendString:@","];
//                                            }
//                                            [outputStr appendString:[label text]];
//                                        }else {
//                                            NSLog(@"Error: one low is not UILabel");
//                                        }
//                                    }
//                                }else {
//                                    NSLog(@"Error: no check box");
//                                }
//                            }
//                            else {
//                                NSLog(@"Error: colIndex > count");
//                            }
//                        }
//                        
//                    }
//                    ++colIndex;
//                }
//            }
//            else {
//                LogError(@"ds is dicts type, no supper");
//            }
//        }
//    }
//    
//    if (outputStr.length == 0) {
//        self.isCanceled = YES;
//    }
//    
//    NSLog(@"returnParamStr %@=%@", returnParamStr, outputStr);
//    return outputStr;
//}

- (NSString *)findElementInAcvtQstsWithFilterParam:(NSString*)filterParamStr
                                   withReturnParam:(NSString*)returnParamStr
{
    NSLog(@"WSLuaScriptContext filterParamStr:%@", filterParamStr);
    NSLog(@"WSLuaScriptContext returnParamStr:%@", returnParamStr);
    
    __block NSString *outputStr = nil;
    NSArray *params = [filterParamStr componentsSeparatedByString:@"="];
    if (params && params.count == 2) {
        if (self.contextAcvtBean) {
            NSArray *otherArray = self.contextAcvtBean.qsts;
            
            //从other 数组中遍历
            [otherArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSString *vlaue = [obj valueForKey:[params objectAtIndex:0]];
                if ([vlaue isEqualToString:[params objectAtIndex:1]]) {
                    if ([returnParamStr isEqualToString:@"inputContent"]) {
                        if (self.expandBlockWithVariableParams) {
                            outputStr = self.expandBlockWithVariableParams(WSLUA_FUNCTION_EXPANDBLOCK_PARAM_ACVTBEANQST_RETURN_STRING,obj);
                        }
                    }else {
                        outputStr = [obj valueForKeyPath:returnParamStr];
                    }
                    *stop = YES;
                }
            }];
        }
        
        if (self.expandBlockWithVariableParams) {
            
        }else{
            
        }
    }
    
    if (!outputStr) {
        self.isCanceled = YES;
    }
    
    NSLog(@"returnParamStr %@=%@", returnParamStr, outputStr);
    return outputStr;
}

- (NSString *)getCurStoreInfoWithFilterParam:(NSString*)filterParamStr
{
    
    NSString *outResult = nil;
    
    NSObject <I_Lua_Executor>* luaExecutor = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_GET_CUR_STORE_IFNO_BY_PARAM encoding:NSUTF8StringEncoding]];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(filterParamStr);
    }else if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(filterParamStr);
    }
    return outResult;
    
    /*
    NSLog(@"WSLuaScriptContext getCurStoreInfoWithFilterParam:%@", filterParamStr);
    __block NSString *outputStr = nil;
    if (filterParamStr && filterParamStr.length > 0) {
        
        WSBaseModel *baseModel = [[WSDataSourceManager sharedInstance] currentActiveModel];
        if (self.contextStoreBean) {
            outputStr = [NSString stringWithValue: [self.contextStoreBean valueForKey:filterParamStr]];
        }else if ([baseModel currentStore]) {
            outputStr = [NSString stringWithValue: [[baseModel currentStore] valueForKey:filterParamStr]];
        }
    }
    
    if (!outputStr) {
        self.isCanceled = YES;
    }
    
    NSLog(@"returnParamStr %@=%@", filterParamStr, outputStr);
    return outputStr;
     */
}

- (NSString *)setTip:(NSString *)nameStr
{
    NSString *outResult = nil;
    
    NSString *funcName = [NSString stringWithCString:LUA_SET_TIP_FUNCTION encoding:NSUTF8StringEncoding];
    NSObject <I_Lua_Executor>* luaExecutor = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:funcName];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(funcName,nameStr);
    }else if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(funcName,nameStr);
    }
    return outResult;
}

- (NSString *)setResult:(NSString *)nameStr
{
    NSString *outResult = nil;
    
    NSString *funcName = [NSString stringWithCString:LUA_SET_RESULT_FUNCTION encoding:NSUTF8StringEncoding];
    NSObject <I_Lua_Executor>* luaExecutor = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:funcName];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(funcName,nameStr);
    }else if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(funcName,nameStr);
    }
    return outResult;
}

- (NSString *)findElementContentByName:(NSString*)nameStr
{
    NSLog(@"WSLuaScriptContext findElementContentByName:%@", nameStr);
    
    __block NSString *outputStr = nil;
    if (self.contextAcvtBean) {
        NSArray *otherArray = self.contextAcvtBean.qsts;
        
        //从other 数组中遍历
        [otherArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[WSAcvtBean_qst class]]) {
                WSAcvtBean_qst *acvtBeanQst = (WSAcvtBean_qst*)obj;
                if (acvtBeanQst.qstName && [acvtBeanQst.qstName hasPrefix:nameStr]) {
                    if (self.expandBlockWithVariableParams) {
                        outputStr = self.expandBlockWithVariableParams(WSLUA_FUNCTION_EXPANDBLOCK_PARAM_ACVTBEANQST_RETURN_STRING,obj);
                    }else {
                        LogInfo(@"expandBlock is empty");
                    }
                    
                    if (!outputStr) {
                        outputStr = @"";
                    }
                    
                    *stop = YES;
                }
            }
        }];
    }
    
    if (!outputStr) {
        self.isCanceled = YES;
    }
    
    NSLog(@"returnParamStr %@=%@", nameStr, outputStr);
    return outputStr;
}


- (NSString *)getColMaxValueInTable:(NSString *)item{
    /* 旧实现方式，稍后删除
    NSString *outResult = nil;
    if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(@"getColMaxValueInTable",item);
    }
    return outResult;
     */
    NSString *outResult = nil;
    NSString *funcName = [NSString stringWithCString:LUA_GET_COL_MAX_VALUE_IN_TABLE encoding:NSUTF8StringEncoding];
    NSObject <I_Lua_Executor>* luaExecutor = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:funcName];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(funcName,item);
    }else if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(funcName,item);
    }
    
    return outResult;
}

- (NSString *)computeRowAndColSumWith:(NSString *)prodNames item:(NSString *)colItem {
    /*
    NSString *outResult = nil;
    if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(@"computeRowAndColSum",prodNames,colItem);
    }
    return outResult;
     */
    
    NSString *outResult = nil;
    NSString *funcName = [NSString stringWithCString:LUA_COMPUTE_ROW_AND_COL_SUM encoding:NSUTF8StringEncoding];
    NSObject <I_Lua_Executor>* luaExecutor = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:funcName];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(funcName,prodNames,colItem);
    }else if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(funcName,prodNames,colItem);
    }
    
    return outResult;
}


- (NSString *)doSendSmsWithContent:(NSString*)smsContentStr
{
    NSString *outResult = nil;
    if (self.smsContentPage) {
        NSString *phoneNumbers = [self findElementContentByType:QST_TYPE_MI];
        if (phoneNumbers) {
            int result = [self.smsContentPage presentSMSPageWithPhones:phoneNumbers.length == 0 ? nil : [phoneNumbers componentsSeparatedByString:@","]
                                                           withContent:smsContentStr
                                                          withIscanned:self.isCanceled];
            outResult = [NSString stringWithFormat:@"%d", result];
        }
    }
    
    return outResult;
}

- (NSString *)computeRowAndColSum:(NSString *)prodNames colume:(NSString *)colItem {
    NSString *outResult = nil;
    if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(@"computeRowAndColSum",prodNames,colItem);
    }
    
    return outResult;
}


- (NSString *)deleteStoreAction
{
    NSString *outResult = nil;
    
    NSString *funcName = [NSString stringWithCString:LUA_DELETE_STORE_ACTION encoding:NSUTF8StringEncoding];
    
    NSObject <I_Lua_Executor>* luaExecutor = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:funcName];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(funcName);
    }else if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(funcName);
    }
    
    return outResult;
}

-(NSString *)exceseWeChatImgShare:(NSString *)shareNum{
    NSString *outResult = nil;

    NSString *funcName = [NSString stringWithCString:LUA_WEChAT_IMG_SHARE_ACTION encoding:NSUTF8StringEncoding];
    
    NSObject <I_Lua_Executor>* luaExecutor = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:funcName];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(funcName,shareNum);
    }else if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(funcName);
    }
    
    return outResult;
}

- (NSString *)createAndVisitStoreActionWithTips:(NSString *)tips
{
    NSString *outResult = nil;
    
    NSString *funcName = [NSString stringWithCString:LUA_CREATE_AND_VISIT_STORE_ACTION encoding:NSUTF8StringEncoding];
    
    NSObject <I_Lua_Executor>* luaExecutor = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:funcName];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(funcName, tips);
    }else if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(funcName, tips);
    }
    
    return outResult;
}
- (NSString *)saveAcvtData
{
    NSString *outResult = nil;
    
    NSString *funcName = [NSString stringWithCString:LUA_SAVE_ACVT_DATA encoding:NSUTF8StringEncoding];
    
    NSObject <I_Lua_Executor>* luaExecutor = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:funcName];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(funcName);
    }else if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(funcName);
    }
    
    return outResult;
}

- (NSString *)modifyQstRequiredStateBySelectedItem:(NSString*)objName withSelectStr:(NSString*)str
{
    NSString *outResult = nil;
    @try {
        
        NSObject <I_Lua_Executor>* luaExecutor = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_MODIFY_QST_REQUIREDSTATE_BY_SELECTEDITEM_FUNCTION encoding:NSUTF8StringEncoding]];
        LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
        
        if (luaExecutor && luaBlock) {
            outResult = luaBlock(objName,str);
        }else if (self.expandBlockWithVariableParams) {
            
            outResult = self.expandBlockWithVariableParams(objName,str);
            
        }
    
    }
    @catch (NSException *exception) {
        
        LogInfo(@"lua execute error :/n%@",exception);
    
    }
    @finally {
        
    }
    
    
    return outResult;
}
- (NSString *)modifyContentRequiredStateByBooleanExpression:(NSString*)colName withBooleanExpression:(NSString*)expression
{

    NSString *outResult = nil;
    if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(colName,expression);
    }
    return outResult;
}

- (NSString *)computeTableSum:(NSString *)expression
{
    NSString *outResult = nil;
    if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(@"computeTableSum",expression);
    }
    NSObject <I_Lua_Executor>* luaExecutor = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_COMPUTE_TABLE_SUM_FUNCTION encoding:NSUTF8StringEncoding]];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(@"computeTableSum",expression);
    }else if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(@"computeTableSum",expression);
    }

    return outResult;
}


- (NSString *)computeColSum:(NSString *)item_col
{
    NSString *outResult = nil;
    if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(@"computeColSum",item_col);
    }
    
    NSObject <I_Lua_Executor>* luaExecutor = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_COMPUTE_COL_SUM_FUNCTION encoding:NSUTF8StringEncoding]];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(@"computeColSum",item_col);
    }else if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(@"computeColSum",item_col);
    }
    
    
    return outResult;
}

 

#pragma mark - private method
- (NSString *)findElementContentByType:(NSString*)type
{
    NSLog(@"WSLuaScriptContext findElementContentByType:%@", type);
    
    __block NSString *outputStr = nil;
    if (self.contextAcvtBean && type) {
        NSArray *otherArray = self.contextAcvtBean.qsts;
        
        //从other 数组中遍历
        [otherArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[WSAcvtBean_qst class]]) {
                WSAcvtBean_qst *acvtBeanQst = (WSAcvtBean_qst*)obj;
                if (acvtBeanQst.qstType && [acvtBeanQst.qstType isEqualToString:type]) {
                    if (self.expandBlockWithVariableParams) {
                        outputStr = self.expandBlockWithVariableParams(WSLUA_FUNCTION_EXPANDBLOCK_PARAM_ACVTBEANQST_RETURN_STRING,obj);
                    }else {
                        LogInfo(@"expandBlock is empty");
                    }
                    
                    if (!outputStr) {
                        outputStr = @"";
                    }
                    
                    *stop = YES;
                }
            }
        }];
    }
    
    if (!outputStr) {
        self.isCanceled = YES;
    }
    
    NSLog(@"returnParamStr %@=%@", type, outputStr);
    return outputStr;
}

- (NSString *) callQstWidgetMethodByQstName:(NSString *)qstName widgetMethod:(NSString *)method methodArgs:(NSArray *)args
{
    NSString *outResult = nil;
    
    NSObject <I_Lua_Executor>* luaExecutor = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_CALL_QST_WIDGET_METHOD_BY_QSTNAME_FUNCTION encoding:NSUTF8StringEncoding]];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(qstName,method,args);
    }else if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(qstName,method,args);
    }
    return outResult;
    
}

-(NSString *) generateURLStringWithParams:(NSString *)qstName params:(NSString *)params
{
    NSString *outResult = nil;
    if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(qstName,params);
    }
    return outResult;
}

- (NSString *)getMeetingApplicantInfoWith:(NSString *)qstName param:(NSString *)param {
    NSString *outResult = nil;
    if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(qstName,param);
    }
    return outResult;
}

- (NSString *)setUploadButtonHidden:(NSString *)isHidden{
    NSString *outResult = nil;
    
    NSString *funName = [NSString stringWithCString:LUA_SET_UPLOAD_BUTTON_HIDDEN encoding:NSUTF8StringEncoding];
    
    NSObject <I_Lua_Executor>* luaExecutor = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:funName];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(funName,isHidden);
    }else if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(funName,isHidden);
    }
    
    return outResult;
}

- (NSString *)checkProductValidateWithDependTableFc:(NSString *)dependFc  dependCol:(NSString *)dependCol validateGroups:(NSString *)validateGroups currentCol:(NSString *)currentCol {
    NSString *outResult = nil;
    if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(dependFc, dependCol, validateGroups, currentCol);
    }
    return outResult;
}

- (NSString *)getServerQstValueByQstCode:(NSString *)qstCode isStoreIDRelated:(NSString *)isStoreIDRelated
{
    NSString *outResult = nil;
    
    NSObject <I_Lua_Executor>* luaExecutor = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_GET_SERVER_QST_VALUE_BY_QST_CODE encoding:NSUTF8StringEncoding]];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(qstCode,isStoreIDRelated);
    }else if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(qstCode,isStoreIDRelated);
    }
    return outResult;
    
}

- (NSString *)getEnterStoreTime {
    
    NSString *outResult = nil;
    
    NSObject <I_Lua_Executor>* luaExecutor = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_GET_ENTER_STORE_TIME encoding:NSUTF8StringEncoding]];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(@"getEnterStoreTime");
    }else if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(@"getEnterStoreTime");
    }
    return outResult;
}

- (NSString *)getExitStoreTime  {
    
    NSString *outResult = nil;
    
    NSObject <I_Lua_Executor>* luaExecutor = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_GET_EXIT_STORE_TIME encoding:NSUTF8StringEncoding]];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(@"getExitStoreTime");
    }else if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(@"getExitStoreTime");
    }
    return outResult;
}

- (NSString *)getDurationStoreTime {
    
    NSString *outResult = nil;
    
    NSObject <I_Lua_Executor>* luaExecutor = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_GET_DURATION_STORE_TIME encoding:NSUTF8StringEncoding]];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(@"getDurationStoreTime");
    }else if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(@"getDurationStoreTime");
    }
    return outResult;
}

- (NSString *)refreshAcvtDisDataAndViewByObjId:(NSString *)objId param:(NSString *)param qstCodArgs:(NSArray *)args{
    NSString *outResult = nil ;
    
    NSObject<I_Lua_Executor> *luaExecutor =[[WSLuaExecutorManager shareInstance]getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_REFRESH_ACVT_DIS_DATA_AND_VIEW encoding:NSUTF8StringEncoding]];
    
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(objId,param,args);
    }else if (self.expandBlockWithVariableParams){
        outResult = self.expandBlockWithVariableParams(objId,param,args);
    }
    return outResult;
}

- (NSString *)getDataByMethod:(NSString *)method param:(NSString *)param{
    NSString *outResult = nil ;
    
    NSObject<I_Lua_Executor> *luaExecutor =[[WSLuaExecutorManager shareInstance]getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_GET_DATA_BY_METHOD encoding:NSUTF8StringEncoding]];
    
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(method,param);
    }else if (self.expandBlockWithVariableParams){
        outResult = self.expandBlockWithVariableParams(method,param);
    }
    return outResult;
}

- (NSString *)setValueToTargetWith:(NSString *)value qstName:(NSString *)qstName {
    NSString *outResult = nil ;
    NSObject<I_Lua_Executor> *luaExecutor =[[WSLuaExecutorManager shareInstance]getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_SET_VALUE_TO_TARGET encoding:NSUTF8StringEncoding]];
    
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(value,qstName);
    }else if (self.expandBlockWithVariableParams){
        outResult = self.expandBlockWithVariableParams(value,qstName);
    }
    return outResult;
}

- (NSString *)callGridMethodByRow:(NSString *)rowId col:(NSString *)col method:(NSString *)methodName param:(NSString *)param {
    NSString *outResult = nil ;
    NSObject<I_Lua_Executor> *luaExecutor =[[WSLuaExecutorManager shareInstance]getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_CALL_GRID_METHOD_BY_ROWID_AND_COL encoding:NSUTF8StringEncoding]];
    
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(rowId,col,methodName,param);
    }else if (self.expandBlockWithVariableParams){
        outResult = self.expandBlockWithVariableParams(rowId,col,methodName,param);
    }
    return outResult;
}

- (NSString *)getStoreId{
    
    NSString *outResult = nil ;
    NSObject<I_Lua_Executor> *luaExecutor = [[WSLuaExecutorManager shareInstance]getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_GET_STORE_ID encoding:NSUTF8StringEncoding]];
     LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(@"getStoreId");
    }else if (self.expandBlockWithVariableParams){
        outResult = self.expandBlockWithVariableParams(@"getStoreId");
    }
    return outResult;
    
}
- (NSString *)getEnterStoreLatLon:(NSString *)storeId{
    NSString *outResult = nil ;
    NSObject<I_Lua_Executor> *luaExecutor = [[WSLuaExecutorManager shareInstance]getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_GET_STORE_LAT_LON encoding:NSUTF8StringEncoding]];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(@"getEnterStoreLatLon",storeId);
    }else if (self.expandBlockWithVariableParams){
        outResult = self.expandBlockWithVariableParams(@"getEnterStoreLatLon",storeId);
    }
    return outResult;
}

- (NSString *)getStoreInfoByCod:(NSString *)cod withQueryName:(NSString *)queryName withArgumentValue:(NSString *)ArgumentValue{
    
    NSString *outResult = nil;
    
    NSObject <I_Lua_Executor>* luaExecutor = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_GET_STORE_INFO_BY_COD encoding:NSUTF8StringEncoding]];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(cod ,queryName,ArgumentValue);
    }else if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(cod,queryName,ArgumentValue);
    }
    return outResult;
}
- (NSString *) callQstWidgetMethodByQstCode:(NSString *)qstCode widgetMethod:(NSString *)method methodArgs:(NSArray *)args{

    NSString *outResult = nil;
    
    NSObject <I_Lua_Executor>* luaExecutor = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_CALL_QST_WIDGET_METHOD_BY_QSTCODE_FUNCTION encoding:NSUTF8StringEncoding]];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(qstCode,method,args);
    }else if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(qstCode,method,args);
    }
    return outResult;
}
- (NSString *) callQstWidgetMethodByQstCodeStarts:(NSString *)qstCode widgetMethod:(NSString *)method methodArgs:(NSArray *)args{
    NSString *outResult = nil;
    
    NSObject <I_Lua_Executor>* luaExecutor = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_CALL_QST_WIDGET_METHOD_BY_QSTCODE_STARTS_FUNCTION encoding:NSUTF8StringEncoding]];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(qstCode,method,args);
    }else if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(qstCode,method,args);
    }
    return outResult;
}

- (NSString *)checkMustFillOneWithQstNames:(NSArray *)qstNames{
    
    NSString *outResult = nil;
    
    NSObject <I_Lua_Executor>* luaExector = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_CHECK_MUST_FILL_ONE encoding:NSUTF8StringEncoding]];
    LuaScriptWithParamsExpandBlock luaBlock =[luaExector getLuaScriptWithParamsExpandBlock];
    
    if (luaExector && luaBlock) {
        outResult = luaBlock(qstNames);
    }else if (self.expandBlockWithVariableParams){
        
        outResult = self.expandBlockWithVariableParams(qstNames);
    }
    return outResult;
    
}

- (NSString *)checkMustAnyModeWithMethod:(NSString *)method param:(NSString *)param{

    NSString *outResult = nil;
    
    NSObject <I_Lua_Executor>* luaExecutor = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_CHECK_MUST_FILL_ANY_MODE encoding:NSUTF8StringEncoding]];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(method,param);
    }else if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(method,param);
    }
    return outResult;
}

- (NSString *)getTableColValueByProId:(NSString *)prodId  col:(NSString *)parmCol {
    NSString *outResult = nil;
    
    NSObject <I_Lua_Executor>* luaExector = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_GET_TABLE_COL_VALUE_BY_PROD_ID encoding:NSUTF8StringEncoding]];
    LuaScriptWithParamsExpandBlock luaBlock =[luaExector getLuaScriptWithParamsExpandBlock];
    
    if (luaExector && luaBlock) {
        outResult = luaBlock(prodId,parmCol);
    }else if (self.expandBlockWithVariableParams){
        
        outResult = self.expandBlockWithVariableParams(prodId,parmCol);
    }
    return outResult;
}

- (NSString *)setTableColValueByProId:(NSString *)prodId textValue:(NSString *)text col:(NSString *)paramCol {
    NSString *outResult = nil;
    
    NSObject <I_Lua_Executor>* luaExector = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_SET_TABLE_COL_VALUE_BY_PROD_ID encoding:NSUTF8StringEncoding]];
    LuaScriptWithParamsExpandBlock luaBlock =[luaExector getLuaScriptWithParamsExpandBlock];
    
    if (luaExector && luaBlock) {
        outResult = luaBlock(prodId,text,paramCol);
    }else if (self.expandBlockWithVariableParams){
        
        outResult = self.expandBlockWithVariableParams(prodId,text,paramCol);
    }
    return outResult;
}

- (NSString *)setTableColByOtherTableCol:(NSString *)otherTableParmCol funcCode:(NSString *)funcCode  acvtQstCode:(NSString *)acvtQstCode {
    NSString *outResult = nil;
    
    NSObject <I_Lua_Executor>* luaExector = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_SET_TABLE_COL_BY_OTHER_TABLE_COL encoding:NSUTF8StringEncoding]];
    LuaScriptWithParamsExpandBlock luaBlock =[luaExector getLuaScriptWithParamsExpandBlock];
    
    if (luaExector && luaBlock) {
        outResult = luaBlock(funcCode,otherTableParmCol,acvtQstCode);
    }else if (self.expandBlockWithVariableParams){
        
        outResult = self.expandBlockWithVariableParams(funcCode,otherTableParmCol,acvtQstCode);
    }
    return outResult;
}

- (NSString *)getQstServerDataByQstName:(NSString *)qstName genId:(NSString *)genId
{
    NSString *outResult = nil;
    
    NSObject <I_Lua_Executor>* luaExecutor = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_GET_QST_SERVER_DATA_BY_QST_NAME_AND_GENID encoding:NSUTF8StringEncoding]];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(qstName,genId);
    }else if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(qstName,genId);
    }
    return outResult;
    
}

- (NSString *)getQstServerDataByQstCode:(NSString *)qstCode genId:(NSString *)genId
{
    NSString *outResult = nil;
    
    NSObject <I_Lua_Executor>* luaExecutor = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_GET_QST_SERVER_DATA_BY_QST_CODE_AND_GENID encoding:NSUTF8StringEncoding]];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(qstCode,genId);
    }else if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(qstCode,genId);
    }
    return outResult;
    
}

- (NSString *)getQstDataByQstCode:(NSString *)qstCode genId:(NSString *)genId
{
    NSString *outResult = nil;
    
    NSObject <I_Lua_Executor>* luaExecutor = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_GET_QST_DATA_BY_QST_CODE_AND_GENID encoding:NSUTF8StringEncoding]];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(qstCode,genId);
    }else if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(qstCode,genId);
    }
    return outResult;
    
}

- (NSString *)setColDefaultValueWithColName:(NSString *)colName andIndex:(NSString *)index
{
    NSString *outResult = nil;
    
    NSObject <I_Lua_Executor>* luaExecutor = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_SET_COL_DEFAULT_VALUE_WITH_COL_NAME_AND_INDEX encoding:NSUTF8StringEncoding]];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(colName,index);
    }else if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(colName,index);
    }
    return outResult;
    
}

- (NSString *)handleAcvtMethod:(NSString *)methodName param:(NSString *)param {
    NSString *outResult = nil;
    
    NSObject <I_Lua_Executor>* luaExecutor = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_HANDLE_ACVT_METHOD encoding:NSUTF8StringEncoding]];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(methodName,param);
    }else if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(methodName,param);
    }
    return outResult;
}

- (NSString *)resetMd5ByCustomDateString:(NSString *)dateString {
    NSString *outResult = nil;
    
    NSObject <I_Lua_Executor>* luaExecutor = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_RESET_MD5_BY_CUSTOM_DATE_STRING encoding:NSUTF8StringEncoding]];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(dateString);
    }
    
    return outResult;
}

- (NSString *)saveCustomEnterLeaveTime:(NSString *)enterdatetime type:(NSString *)type{
    NSString *outResult = nil;
    
    NSObject <I_Lua_Executor>* luaExecutor = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_SAVE_CUSTOM_ENTER_LEAVE_TIME encoding:NSUTF8StringEncoding]];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(enterdatetime,type);
    }
    
    return outResult;
}

- (NSString *)getEmpName {
    NSString *outResult = nil ;
    NSObject<I_Lua_Executor> *luaExecutor = [[WSLuaExecutorManager shareInstance]getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_GET_EMP_NAME encoding:NSUTF8StringEncoding]];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(@"getEmpName");
    }else if (self.expandBlockWithVariableParams){
        outResult = self.expandBlockWithVariableParams(@"getEmpName");
    }
    return outResult;
    
}

- (NSString *)setAcvtEnableByQstValueWithParam:(NSString *)param {
    NSString *outResult = nil ;
    NSObject<I_Lua_Executor> *luaExecutor = [[WSLuaExecutorManager shareInstance]getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_SET_ACVT_ENABLE_BY_QSTVALUE encoding:NSUTF8StringEncoding]];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(@"setAcvtEnableByQstValue", param);
    }else if (self.expandBlockWithVariableParams){
        outResult = self.expandBlockWithVariableParams(@"setAcvtEnableByQstValue", param);
    }
    return outResult;
    
}

- (NSString *)exceseBlueToothPrintData:(NSString *)printData withParam:(NSString *)param{
    NSString *outResult = nil;
    
    NSObject <I_Lua_Executor>* luaExecutor = [[WSLuaExecutorManager shareInstance] getLuaExecutorWithFunctionName:[NSString stringWithCString:LUA_EXCESE_BLUE_TOOTH_PRINT encoding:NSUTF8StringEncoding]];
    LuaScriptWithParamsExpandBlock luaBlock = [luaExecutor getLuaScriptWithParamsExpandBlock];
    
    if (luaExecutor && luaBlock) {
        outResult = luaBlock(printData,param);
    }else if (self.expandBlockWithVariableParams) {
        outResult = self.expandBlockWithVariableParams(printData,param);
    }
    return outResult;

    
}
@end

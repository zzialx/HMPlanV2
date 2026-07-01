//
//  WSLuaScriptContext.h
//  TestLua2
//
//  Created by dujinfeng481 on 14-8-26.
//  Copyright (c) 2014年 djf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSSmsController.h"
#import <Foundation/NSObjCRuntime.h>

#define  WSLUA_FUNCTION_ACVTTBCONTEXT_RETURN_ARRAY @"acvtTBContextBlock"
#define  WSLUA_FUNCTION_EXPANDBLOCK_PARAM_ACVTBEANQST_RETURN_STRING @"acvtbeanqst"

@class WSFuncsBean;
@class WSStoreBean;
@class WSAcvtBean;
@class WSAcvtDataGridComponentDataSource;


//typedef NSString*(^LuaScriptExpandBlock)(id keyObj);
//typedef NSArray*(^LuaScriptAcvtTBCotextBlock)();        //WSAcvtDataGridComponentDataSource
//typedef NSString*(^LuaScriptWithParamsExpandBlock)(id firstObj,... ); //不定参数 最少一个
typedef id(^LuaScriptWithParamsExpandBlock)(id firstObj,... );

@interface WSLuaScriptContext : NSObject

@property (nonatomic, strong) NSString          *luaScriptStr;          //字符串脚本内容，将其封装成lua function。 eg："%local name=findElementInOther(\"col=memo3\",\"name\");return name;"
@property (nonatomic, strong) WSSmsController   *smsContentPage;
@property (nonatomic, assign) BOOL              isCanceled;

@property (nonatomic, strong) NSString          *parsedContentStr;
@property (nonatomic, strong) NSString          *functionNameExecution;



-(id) initWithFuncsBean:(WSFuncsBean*)funcsBean
          withStoreBean:(WSStoreBean*)storeBean
               withAcvt:(WSAcvtBean*)acvtBean;


/**
 *  设置输入查找的方法
 *
 *  @param block 操作界面需要实现的方法
 */
- (void) initializationWithVariableParamsBlock:(LuaScriptWithParamsExpandBlock)block;

/**
 *  other中查找方法的birdge
 *
 *  @param filterParamStr 过滤条件 "col=memo3"
 *  @param returnParamStr 返回的字段 “name”
 *
 *  @return 返回结果
 */
- (NSString *)findElementInOtherWithFilterParam:(NSString*)filterParamStr
                                withReturnParam:(NSString*)returnParamStr;


/**
 *  解析acvt嵌套表格数据
 *
 *  @param filterParamStr 过滤条件 "col=memo3"
 *  @param returnParamStr 返回的字段 “name”
 *
 *  @return 返回结果
 */
- (NSString *)findElementInAcvtTBWithFilterParam:(NSString*)filterParamStr
                                 withReturnParam:(NSString*)returnParamStr;

- (NSString *)setTip:(NSString *)nameStr;

- (NSString *)setResult:(NSString *)nameStr;

- (NSString *)findElementContentByName:(NSString*)nameStr;

- (NSString *)getColMaxValueInTable:(NSString *)item;

- (NSString *)computeRowAndColSumWith:(NSString *)prodNames item:(NSString *)colItem;

- (NSString *)getCurStoreInfoWithFilterParam:(NSString*)filterParamStr;

- (NSString *)findElementInAcvtQstsWithFilterParam:(NSString*)filterParamStr
                                   withReturnParam:(NSString*)returnParamStr;


- (NSString *)doSendSmsWithContent:(NSString*)smsContentStr;

- (NSString *)deleteStoreAction;
- (NSString *)createAndVisitStoreActionWithTips:(NSString *)tips;
- (NSString *)saveAcvtData;

- (NSString *)exceseWeChatImgShare:(NSString *)shareNum;

/**
 *  qst问题必填依赖于下拉选择控件选中的内容被str字符串包含。
 *
 *  @param objName ,间隔的问题Name字符串
 *  @param str     ,间隔的选择内容字符串
 *
 *  @return 结果
 */
- (NSString *)modifyQstRequiredStateBySelectedItem:(NSString*)objName withSelectStr:(NSString*)str;

/**
 *  col的列是否必填依赖布尔表达式的值 （TB问题表格）
 *
 *  @param colName          表格列名称
 *  @param expression       表达式
 *
 *  @return 结果
 */
- (NSString *)modifyContentRequiredStateByBooleanExpression:(NSString*)colName withBooleanExpression:(NSString*)expression;

/**
 *  计算 列和 废弃.
 *
 *  @param expression 表达式
 *
 *  @return 
 */
- (NSString *)computeTableSum:(NSString *)expression;

/**
 *  计算 列和 最新
 *
 *  @param expression 表达式
 *
 *  @return
 */

- (NSString *)computeColSum:(NSString *)item_col;


- (NSString *) callQstWidgetMethodByQstName:(NSString *)qstName widgetMethod:(NSString *)method methodArgs:(NSArray *)args;

-(NSString *) generateURLStringWithParams:(NSString *)qstName params:(NSString *)params;


/*
    params脚本方法参数  例如:  params = "userId" 或 "userName" 表示该问题的答案是用户名 或者用户问题
 */

- (NSString *)getMeetingApplicantInfoWith:(NSString *)qstName param:(NSString *)param;

- (NSString *)setUploadButtonHidden:(NSString *)isHidden;

- (NSString *)checkProductValidateWithDependTableFc:(NSString *)dependFc  dependCol:(NSString *)dependCol validateGroups:(NSString *)validateGroups currentCol:(NSString *)currentCol;

- (NSString *)getServerQstValueByQstCode:(NSString *)qstCode isStoreIDRelated:(NSString *)isStoreIDRelated;
- (NSString *)getEnterStoreTime;
- (NSString *)getExitStoreTime;
- (NSString *)getDurationStoreTime;
- (NSString *)refreshAcvtDisDataAndViewByObjId:(NSString *)objId param:(NSString *)param qstCodArgs:(NSArray *)args;

- (NSString *)getDataByMethod:(NSString *)method param:(NSString *)param;

- (NSString *)getStoreId;

- (NSString *)getEnterStoreLatLon:(NSString *)storeId;

- (NSString *)getStoreInfoByCod:(NSString *)cod withQueryName:(NSString *)queryName withArgumentValue:(NSString *)ArgumentValue;

- (NSString *) callQstWidgetMethodByQstCode:(NSString *)qstCode widgetMethod:(NSString *)method methodArgs:(NSArray *)args;

- (NSString *) callQstWidgetMethodByQstCodeStarts:(NSString *)qstCode widgetMethod:(NSString *)method methodArgs:(NSArray *)args;

/*
 function computeSumToTarget()
 return setValueToTarget(tostring(computeColSum("item2")),"金额总计");
 end
 */
- (NSString *)setValueToTargetWith:(NSString *)value qstName:(NSString *)qstName;

- (NSString *)callGridMethodByRow:(NSString *)rowId col:(NSString *)col method:(NSString *)methodName param:(NSString *)param;

- (NSString *)checkMustFillOneWithQstNames:(NSArray *)qstNames;

- (NSString *)checkMustAnyModeWithMethod:(NSString *)method param:(NSString *)param;

- (NSString *)getTableColValueByProId:(NSString *)prodId  col:(NSString *)parmCol;

- (NSString *)setTableColValueByProId:(NSString *)prodId textValue:(NSString *)text col:(NSString *)paramCol;
- (NSString *)setTableColByOtherTableCol:(NSString *)otherTableParmCol funcCode:(NSString *)funcCode  acvtQstCode:(NSString *)acvtQstCode;

- (NSString *)getQstServerDataByQstName:(NSString *)qstName genId:(NSString *)genId;

- (NSString *)getQstServerDataByQstCode:(NSString *)qstCode genId:(NSString *)genId;

- (NSString *)getQstDataByQstCode:(NSString *)qstCode genId:(NSString *)genId;

- (NSString *)setColDefaultValueWithColName:(NSString *)colName andIndex:(NSString *)index;

- (NSString *)handleAcvtMethod:(NSString *)methodName param:(NSString *)param;

- (NSString *)resetMd5ByCustomDateString:(NSString *)dateString;

- (NSString *)saveCustomEnterLeaveTime:(NSString *)enterdatetime type:(NSString *)type;

- (NSString *)getEmpName;

- (NSString *)setAcvtEnableByQstValueWithParam:(NSString *)param;

- (NSString *)exceseBlueToothPrintData:(NSString *)printData withParam:(NSString *)param;

@end

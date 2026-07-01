//
//  I_Lua_Operator.h
//  WinSFA
//
//  Created by winchannel on 15/4/10.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#ifndef WinSFA_I_Lua_Target_Operator_h
#define WinSFA_I_Lua_Target_Operator_h

@protocol I_Lua_Target_Operator <NSObject>

@optional

//获取当前对象的值
-(NSObject *)getValueForCurrentObject;

//获取他的值显示内容
-(NSObject *)getValuePresentationForCurrentObject;

//设置当前的计算后的值
-(void)setValueForCurrentObject:(NSObject *)objvalue;

//是否需要设置验证
-(void)reSetNeedValidate:(BOOL)needvalidate;

//lua脚本执行校验
- (NSObject *)getResultExecuteCheck;

//执行验证
-(void)executeValidate;

- (NSObject *)getOtherLuaExecuteParams;

//用于表格，获取某一列的数值之和
- (double)getSumByColName:(NSString *)colName;

//用于表格 获取整个表格计算的值
- (double)getSumByExpression:(NSString *)tableExpression;

/*获取表格某列的最大值*/
- (NSString *)getColMaxValueInTableByItem:(NSString *)item;

- (NSString *)computeRowAndColSumWith:(NSString *)prodNames item:(NSString *)colItem;

- (NSString *)getDescriptionForCurrentObject;

//设置表格某列的默认值为第index个选项
- (void)setColDefaultValueWithColName:(NSString *)colName index:(NSInteger)index;

//特殊处理tip提示,yes 已特殊处理，NO未处理，继续执行后面代码
- (BOOL)specialHandleLuaTip:(NSString *)tip;

@end

#endif

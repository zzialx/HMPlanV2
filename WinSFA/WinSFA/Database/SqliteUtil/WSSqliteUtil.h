//
//  WSSqliteUtil.h
//  WinChannelFrameWork
//
//  Created by wdy on 12-1-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSFMDatebase.h"

//以下皆为批量插入时各个本地字段的可选配置
extern  NSString *kMapKey_serverKey; //对应的服务器端字段名称
extern  NSString *kMapKey_placeHolder;//若服务器端没有该字段，则使用该值替换
extern  NSString *kMapKey_autoIncrement;//若服务器端没有此字段，则本地自动递增，需要配置成非0，表示从哪个数开始递增？如果为0则无效

@interface WSSqliteUtil : NSObject


/**
 *  @author weida
 *
 *  @brief 根据names数组中的字段从表中批量删除记录
 *
 *  @param names  字段数组(表示根据哪些字段进行删除)
 *  @param values 由数组组成的数组。每个元素与分别对应names的元素。
 *  values中的所有数组大小应该保持一致，否则不足的部分将以该数组最后一个元素代替
 *
 *  @return 成功返回TRUE，失败返回FALSE
 */
-(BOOL)batchDeleteFromTableWithNames:(NSArray*)names ArgumentsValues:(NSArray*)values;

/**
 *  @author weida
 *
 *  @brief 将dicts字典数组批量插入表中
 *
 *  @param Map  本地表字段Key与服务器字段Value映射字典(如果字段不同必须写,不写默认相同)
 *             key : 本地表字段名称
 *            value: 一个字典
 *  @param dicts 要插入表的字段数组
 *
 *  @return 成功返回TRUE，失败返回FALSE
 */
-(BOOL)batchInsertToTableWithMap:(NSDictionary *)Map  Dicts:(NSArray *)dicts;


//开关数据库
//- (BOOL)openDataBase:(NSString *)dbName;
//- (BOOL)closeDataBase:(NSString *)dbName;

//增
-(BOOL)insertWithArgumentsValue:(NSArray *)values;

//批量插入
- (BOOL)insertWithSql:(NSString *)insertSql withArgumentsInArrays:(NSArray *)values;

-(BOOL)batchInsertWithArgumentsValuesArray:(NSArray *)valuesArray;

// use executeUpdateWithSqls:
- (BOOL)insertWithSqls:(NSArray *)aSqlsArray; //JF_DEPRECATED
- (BOOL)executeUpdateWithSqls:(NSArray *)aSqlsArray;

//删
-(BOOL)deleteWithNames:(NSArray *)names ArgumentsValue:(NSArray *)values;
-(BOOL)deleteAll;
//批量删除
- (BOOL)deleteProdstWithSqls:(NSArray *)aSqlsArray;

- (BOOL)deleteWithNames:(NSArray *)names ArgumentsValues:(NSArray *)values notInName:(NSString *)notInName notInValues:(NSArray *)notInValues;

/**
 *  @author weida
 *
 *  @brief 根据namesArray中的names，对应valuesArray中的values  拼接sql，批量删除记录
 *  @param namesarray  由数组组成的数组。
 *  @param valuesArray 由数组组成的数组。每个元素与分别对应namearray的元素。
 *
 *  @return 成功返回TRUE，失败返回FALSE
 */
- (BOOL)batchDeleteDataWithNamesArray:(NSArray *)namesArray ArgumentsValuesArray:(NSArray *)valuesArray;

//改
-(BOOL)updateWithNames:(NSArray *)names values:(NSArray *)values whereName:(NSArray *)whereNames whereValue:(NSArray *)whereValues;

//查
-(NSArray *)queryWithNames:(NSArray *)names ArgumentsValue:(NSArray *)values;

-(NSInteger)queryCountWithNames:(NSArray *)names ArgumentsValue:(NSArray *)values;

-(NSInteger)queryCountWithSql:(NSString *)sql;


//根据sql及类名查询一组对象
-(NSMutableArray *)queryAndReturnInfosBySql:(NSString *)sql andClassName:(NSString *)class_name;

//根据sql和类名查询一个对象
-(NSObject *)queryAndReturnSingleInfoBySql:(NSString *)sql andClassName:(NSString *)class_name;

- (BOOL)executeUpdateWithSqls:(NSArray *)sqlArray withArgumentsInArray:(NSArray *)valuesArray;

//sql查询原始数据 sql 查询语句, 数组: 要查询的列名数组
-(NSMutableArray *)queryDatasBySql:(NSString *)sql columnArr:(NSArray *)array;

//查询单列的值
-(NSArray *)queryColValues:(NSString *)colName withName:(NSArray *)names ArgumentsValue:(NSArray *)values isDistinct:(BOOL)isDistinct;

//根据sql及类名查询一组对象 ,sql中可以包含占位符“？”
-(NSArray *)queryObjectsBySql:(NSString *)sql argumentsValues:(NSArray *)values className:(NSString *)className;
//根据sql查询数据 ,sql中可以包含占位符“？”，数据以NSDictionary形式返回
- (NSArray *)queryDicDatasBySql:(NSString *)sql argumentsValues:(NSArray *)values;
//获取queryDicDatasBySql:argumentsValues 的 keys 数组，按照查询数据返回
- (NSArray *)queryDicKeysBySql:(NSString *)sql argumentsValues:(NSArray *)values;



/**
 新增查询不同模块下相同门店是否未离开的sql查询方法
 */
-(NSArray *)queryPrentTypeWithNames:(NSArray *)names ArgumentsValue:(NSArray *)values;


/**

 查询所需字符串
 @param sql
 @return
 */
-(NSString *)queryTableInfoWithSql:(NSString*)sql;



/**
 查询当前节点的同一级的fc数组

 @param currentfc
 @return
 */
- (NSArray *)queryParentfcWithCurrentfc:(NSString*)currentfc;

@end

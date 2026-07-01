//
//  WSDBService.h
//  WinSFA
//
//  Created by weida on 15/12/28.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSDBService : NSObject

@property(nonatomic,assign)BOOL isLoginSendNode;///<登录下发节点

/**
*  @author weida
*
*  @brief 这个函数由子类去实现，父类什么都不做
*
*  @param dicts    需要保存的数据
*  @param nodeName 数据来自哪个节点?
*
*  @return 成功返回YES，失败返回NO
*/

- (BOOL)hasVariableWithClass:(Class) myClass varName:(NSString *)name;

- (BOOL)replaceToTableWithDicts:(NSArray*)dicts FromNode:(NSString*)nodeName hasNewData:(BOOL)hasNewData;

- (BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData storeID:(NSString *)storeID;

- (BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData storeID:(NSString *)storeID genId:(NSString *)genId;

- (NSArray *)queryObjectsWith:(Class)cls plistKey:(NSString *)key  keyArray:(NSArray *)keyArray valueArray:(NSArray *)valueArray;

- (NSString *)getSQLWithPlistKey:(NSString *)key  keyArray:(NSArray *)keyArray valueArray:(NSArray *)valueArray;

// SFA-13944 配置中的查询语句用 replacement 代替原来的 target
- (NSArray *)queryObjectsWith:(Class)cls plistKey:(NSString *)key keyArray:(NSArray *)keyArray valueArray:(NSArray *)valueArray replacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement;

- (NSString *)getSQLWithPlistKey:(NSString *)key keyArray:(NSArray *)keyArray valueArray:(NSArray *)valueArray replacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement;

- (NSArray *)queryDictsWithParentId:(NSString *)pId filter:(NSString *)filter memo:(NSString*)memo;

// 将名称转为拼音并返回带拼音的新数组
- (NSArray *)addPinyinFromNameToDicts:(NSArray *)dicts;
// 将field字段值(如name)转为拼音并返回带拼音的新数组
- (NSArray *)addPinyinFromField:(NSString *)field toDicts:(NSArray *)dicts;

@end

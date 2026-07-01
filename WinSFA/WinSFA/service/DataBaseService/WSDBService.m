//
//  WSDBService.m
//  WinSFA
//
//  Created by weida on 15/12/28.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSDBService.h"
#import "ChineseToPinyin.h"
#import <objc/runtime.h>

@implementation WSDBService


- (BOOL)hasVariableWithClass:(Class) myClass varName:(NSString *)name{
    if (name == nil) {
        return NO;
    }
    unsigned int outCount, i;
    Ivar *ivars = class_copyIvarList(myClass, &outCount);
    for (i = 0; i < outCount; i++) {
        Ivar property = ivars[i];
        NSString *keyName = [NSString stringWithCString:ivar_getName(property) encoding:NSUTF8StringEncoding];
        keyName = [keyName stringByReplacingOccurrencesOfString:@"_" withString:@""];
        if ([keyName isEqualToString:name]) {
            free(ivars);
            return YES;
        }
    }
    free(ivars);
    return NO;
}

-(BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData
{
    return [self replaceToTableWithDicts:dicts FromNode:nodeName hasNewData:hasNewData storeID:nil];
}

- (BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData storeID:(NSString *)storeID {
    
    return [self replaceToTableWithDicts:dicts FromNode:nodeName hasNewData:hasNewData storeID:storeID genId:nil];
}

- (BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData storeID:(NSString *)storeID genId:(NSString *)genId {
    
    LogInfo(@"这个函数需要子类实现，父类啥也不做");
    return NO;
}

- (NSArray *)queryObjectsWith:(Class)cls plistKey:(NSString *)key  keyArray:(NSArray *)keyArray valueArray:(NSArray *)valueArray {
    
    return [self queryObjectsWith:cls plistKey:key keyArray:keyArray valueArray:valueArray replacingOccurrencesOfString:nil withString:nil];
}

- (NSArray *)queryObjectsWith:(Class)cls plistKey:(NSString *)key keyArray:(NSArray *)keyArray valueArray:(NSArray *)valueArray replacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement {
    WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
    return  [sqliteUtil queryAndReturnInfosBySql:[self getSQLWithPlistKey:key keyArray:keyArray valueArray:valueArray replacingOccurrencesOfString:target withString:replacement] andClassName:[cls className]];
}

- (NSString *)getSQLWithPlistKey:(NSString *)key keyArray:(NSArray *)keyArray valueArray:(NSArray *)valueArray {
    return [self getSQLWithPlistKey:key keyArray:keyArray valueArray:valueArray replacingOccurrencesOfString:nil withString:nil];
}


- (NSString *)getSQLWithPlistKey:(NSString *)key keyArray:(NSArray *)keyArray valueArray:(NSArray *)valueArray replacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement
{
    if ([keyArray count] != [valueArray count]) {
        NSLog(@"keyArray count  != valueArray count !");
        return nil;
    }
    NSString * path = [[NSBundle mainBundle]pathForResource:@"QuerySql.plist" ofType:nil];
    NSDictionary  *plistDict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString * sql = [plistDict objectForKey:key];
    if ([target length] > 0 && [replacement length] > 0) {
        sql = [sql stringByReplacingOccurrencesOfString:target withString:replacement];
    }
    for (int i = 0; i < keyArray.count ; i++) {
        sql =  [sql stringByReplacingOccurrencesOfString:keyArray[i] withString:valueArray[i]];
    }
    
    return sql;
}

- (NSArray *)addPinyinFromNameToDicts:(NSArray *)dicts {
    return [self addPinyinFromField:@"name" toDicts:dicts];
}

- (NSArray *)addPinyinFromField:(NSString *)field toDicts:(NSArray *)dicts {
    if ([field length] == 0) {
        LogError(@"addPinyinFieldFromField without field");
        return dicts;
    }
    if ([[UIDevice getPreferredLanguage] isEqualToString:@"zh_CN"]) {
        NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:dicts.count];
        for (NSDictionary *dic in dicts) {
            //YIHAIKERRY-1360
            //【IOS】登录直接闪退，帮忙查询原因 dic[field] 有可能不是string 类型
            NSString *name = [NSString stringWithFormat:@"%@",dic[field]];
            NSMutableDictionary *newDic = [dic mutableCopy];
            newDic[@"pinyin"] =  [ChineseToPinyin getPinyinFromName:name];
            [newArray addObject:newDic];
        }
        return [newArray copy];
    } else {
        return dicts;
    }
}
@end

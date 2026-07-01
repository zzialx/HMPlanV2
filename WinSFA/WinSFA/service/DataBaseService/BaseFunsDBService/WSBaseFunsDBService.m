//
//  WSBaseFunsDBService.m
//  WinSFA
//
//  Created by weida on 15/12/28.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSBaseFunsDBService.h"
#import "WSBaseFunsTable.h"

#define kbaseFunKey_spec        (@"spec")

@implementation WSBaseFunsDBService

-(BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData
{
    BOOL ret = FALSE;
    WSBaseFunsTable *table = [WSBaseFunsTable sharedTable];
    NSMutableArray *mutableArry = [NSMutableArray arrayWithCapacity:dicts.count];
    
    for (NSDictionary*dict in dicts)
    {
        NSString *specJson = dict[kbaseFunKey_spec];
        
        if ([specJson isKindOfClass:[NSString class]] && specJson.length)
        {
            // MENGNIU-1627 脚本字符问题导致Json解析失败，此处换成系统的解析并做忽略部分特殊字符处理
            NSError *jsonError = nil;

            NSData * data = [[self removeUnescapedCharacter:specJson] dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *spec = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
//            NSDictionary *spec = [specJson objectFromJSONString];
            NSMutableDictionary *mutable = dict.mutableCopy;
            [mutable addEntriesFromDictionary:spec];
            [mutableArry addObject:mutable];
        }else
        {
            [mutableArry addObject:dict];
        }
    }

    [table deleteAll];
    
    ret = [table batchInsertToTableWithMap:@{@"_id":@{kMapKey_serverKey:@"pk"},
                                             @"parentId":@{kMapKey_serverKey:@"fk"}} Dicts:mutableArry];
    return ret;
    
}

- (NSString *)removeUnescapedCharacter:(NSString *)inputStr
{
    NSCharacterSet *controlChars = [NSCharacterSet controlCharacterSet];//获取那些特殊字符
    //    NSString *tempStr = inputStr;
    inputStr = [inputStr stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    NSRange range = [inputStr rangeOfCharacterFromSet:controlChars];//寻找字符串中有没有这些特殊字符
    if (range.location != NSNotFound)
    {
        NSMutableString *mutable = [NSMutableString stringWithString:inputStr];
        while (range.location != NSNotFound)
        {
            [mutable deleteCharactersInRange:range];//去掉这些特殊字符
            range = [mutable rangeOfCharacterFromSet:controlChars];
        }
        return mutable;
    }
    return inputStr;
}

- (NSString *)getFuncsIdWithCurrentFc:(NSString *)currentFc{
    
    NSString *sql = [NSString stringWithFormat:@"select *from base_funcs where fc = '%@'",currentFc];
    FMResultSet *rs = [[WSFMDatebase getInstance]executeQueryWithSql:sql];
    NSMutableArray *names = [NSMutableArray array];
    while ([rs next]) {
        NSString *acvtName = [rs stringForColumn:@"_id"];
        [names addObject:acvtName];
    }
    //    LogInfo(@"names--%@",[names JSONString]);
    NSString *parentId = [names firstObject];
    return parentId;

}

- (NSString *)getParentFuncsCode:(NSString *)currentFc{
    
    NSString *sql = [NSString stringWithFormat:@"select bf.fc from base_funcs bf join base_funcs bf2 on bf._id = bf2.parentId and bf2.fc = '%@'",currentFc];
    FMResultSet *rs = [[WSFMDatebase getInstance]executeQueryWithSql:sql];
    NSMutableArray *names = [NSMutableArray array];
    while ([rs next]) {
        NSString *acvtName = [rs stringForColumn:@"fc"];
        [names addObject:acvtName];
    }
    //    LogInfo(@"names--%@",[names JSONString]);
    NSString *funCode = [names firstObject];
    return funCode;
}

- (NSString *)getFuncsNameWithFilter:(NSString *)filter{
    
    NSString *sql = [NSString stringWithFormat:@"select bf.name from base_funcs bf where bf.filter = '%@'",filter];
    FMResultSet *rs = [[WSFMDatebase getInstance]executeQueryWithSql:sql];
    NSMutableArray *names = [NSMutableArray array];
    while ([rs next]) {
        NSString *acvtName = [rs stringForColumn:@"name"];
        [names addObject:acvtName];
    }
    //    LogInfo(@"names--%@",[names JSONString]);
    NSString *funName = [names firstObject];
    return funName;
}

- (NSString *)queryFuncsValueWithParamCol:(NSString *)col funcsBean:(WSFuncsBean *)aFuncsBean{
    
    if (!aFuncsBean || !col || [col length] == 0) {
        return nil;
    }
    if ([self hasVariableWithClass:[WSFuncsBean class] varName:col]) {
        return [NSString stringWithValue:[aFuncsBean valueForKey:col]];
    }
    return nil;
    
}


- (NSArray *)queryShortCutFuncs {
    NSString *sql = @"select * from base_funcs where opt like '%isShortcut = 1%'";
    NSArray *columnArr = @[@"fc", @"name"];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    FMResultSet  *rs =  [[WSFMDatebase getInstance] executeQueryWithSql:sql];
    while ([rs next]) {
        
        for (NSString *str in columnArr) {
            id ob = [rs objectForColumnName:str];
            [array addObject:ob];
        }
    }
    return array;
}

// 判断菜单是否是对店的菜单
- (BOOL)isStoreFuncsWithFC:(NSString *)fc {
    // 当前菜单的兄弟菜单里是否有进店节点
    NSString *sql = [NSString stringWithFormat:@"select * from base_funcs where parentId = (select parentId from base_funcs where fc = '%@')  and  fv = '%@'", fc, ENTERSTORE_FV];
    
    NSInteger count = 0;
    FMResultSet *rs = [[WSFMDatebase getInstance] executeQueryWithSql:sql];
    while ([rs next]) {
        count = [rs intForColumnIndex:0];
    }
    
    if (count == 0) {
        // 当前菜单的兄弟菜单没有进店菜单节点并且当前没有进店菜单则是对店菜单
        sql = [NSString stringWithFormat:@"select * from base_funcs where fv = '%@'", ENTERSTORE_FV];
        FMResultSet *rs = [[WSFMDatebase getInstance] executeQueryWithSql:sql];
        while ([rs next]) {
            count = [rs intForColumnIndex:0];
        }
        return count == 0 ? YES : NO;
    } else {
        return YES;
    }
}

- (NSString *)getParentFCWithSonFC:(NSString *)fc {
    NSString *parentFC = nil;
    NSString *sql = [NSString stringWithFormat:@"select fc from base_funcs where _id = (select parentId from base_funcs where fc = '%@')", fc];
    
    FMResultSet  *rs =  [[WSFMDatebase getInstance] executeQueryWithSql:sql];
    while ([rs next]) {
        parentFC = [rs objectForColumnName:@"fc"];
    }
    return parentFC;
}


@end

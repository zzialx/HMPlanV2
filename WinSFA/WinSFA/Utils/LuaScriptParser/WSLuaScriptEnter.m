//
//  WSLuaScriptEnter.m
//  TestLua2
//
//  Created by dujinfeng481 on 14-8-26.
//  Copyright (c) 2014年 djf. All rights reserved.
//

#import "WSLuaScriptEnter.h"
#import "WSLuaScript.h"
#import "WSLuaScriptContext.h"
#import "WSLuaExecutorManager.h"

@interface WSLuaScriptEnter ()

@property (nonatomic, strong) WSLuaScriptContext *scriptParserObj;

@end

@implementation WSLuaScriptEnter

-(BOOL) initializationLuaContextWithLuaScriptContext:(WSLuaScriptContext*)scriptParserObj
{
    if (!scriptParserObj) {
        return NO;
    }
    
    self.scriptParserObj  = scriptParserObj;
    
    scriptParserObj.isCanceled = NO;
    return [[WSLuaScript getInstance] initializationLuaWithObject:scriptParserObj];
}

-(NSString*) runOnSumbit
{
    return [[WSLuaScript getInstance] onSubmit];
}

-(NSString*) runOnCheck
{
    return [[WSLuaScript getInstance] onCheck];
}

-(NSString *) runComputeSumToTarget
{
     return [[WSLuaScript getInstance] onComputeSumToTarget];
}

-(NSString*) runAllowExam
{
    return [[WSLuaScript getInstance] allowExam];
}

-(NSString*) runGenerateURL
{
    return [[WSLuaScript getInstance] generateURL];
}

- (NSString *)runMeetingApplicantInfo {
    return [[WSLuaScript getInstance]  getMeetingApplicantInfo];
}


- (NSString *)runCheckProductValidateInTable
{
    return [[WSLuaScript getInstance] checkProductValidateInTable];
}
-(NSString *)runExcuseAction
{
    return [[WSLuaScript getInstance] excuseAction];
}

-(NSString *)runChangeQstValueDependentOnAcvtGrid
{
    return [[WSLuaScript getInstance]  changeQstValueDependentOnAcvtGrid];
}


-(NSString *)runUniversalLuaFunction:(NSString *)value
{
    if (_scriptParserObj.functionNameExecution) {
        [self luaFunctionName:_scriptParserObj.functionNameExecution param:value];
        return nil;
    }
    NSString  *functionName = nil;
    
    NSString *script = _scriptParserObj.luaScriptStr;
    while ( script) {
        NSRange range = [script rangeOfString:@"function "];
        if (range.location != NSNotFound) {
            NSInteger begin = range.location + range.length;
            NSInteger end = [script indexOfString:@"("];
            NSRange  range=  NSMakeRange(begin, end - begin);

            functionName = [script substringWithRange:range]; //获取方法名称
            NSString *tempStr = [script substringWithRange:NSMakeRange(begin, script.length - begin)];

            NSRange rang2 = [tempStr rangeOfString:@"function "];
            if (rang2.location != NSNotFound) {
                //SFA-14489 2017-11-27
                //script = [script substringWithRange:NSMakeRange(rang2.location, tempStr.length - rang2.location)];
                script = [tempStr substringWithRange:NSMakeRange(rang2.location, tempStr.length - rang2.location)];
            }else{
                script = nil;
            }
        
            functionName = [functionName stringByTrimmingWhitespace];
            if (functionName) {
                [self luaFunctionName:functionName param:value];
            }
        }
    }
    return nil;

}
- (void)luaFunctionName:(NSString*)functionName param:(NSString*)param
{
    [[WSLuaScript getInstance] setLuaFunctionName:functionName];
    [[WSLuaScript getInstance] runLuaFunctionByName:functionName param:param];
}
#pragma mark - private method
/**
 *  Lua解析环境
 *
 *  @param scriptStr 从服务器获得的解析脚本 （eg："你好啊,<%local name=findElementInOther(\"col=memo3\",\"name\");return name;%>。"）
 *  @param scriptParserObj WSLuaScriptContext 对象
 *
 *  @return 解析后的内容，失败为nil。
 */
-(NSString*) getContentWithLuaScript:(NSString*)scriptStr
                withLuaScriptContext:(WSLuaScriptContext*)scriptParserObj
{
    if (!scriptStr || !scriptParserObj) {
        return nil;
    }
    
    NSMutableArray *luaScriptArray = [NSMutableArray arrayWithCapacity:2];
    NSString *tmpStr = [self recursionParserScript:scriptStr toLuaArray:luaScriptArray];
    if (!tmpStr) {
        NSLog(@"解析脚本失败");
        return nil;
    }
    
    scriptParserObj.isCanceled = NO;
    NSMutableString *outputStr = [NSMutableString stringWithString:tmpStr];
//    for (int i = 0; i < [luaScriptArray count]; ++i) {
//        scriptParserObj.luaScriptStr = [luaScriptArray objectAtIndex:i];
//        
//        NSString *luaParserStr = [[WSLuaScript getInstance] parserContentWithObject:scriptParserObj];
//        if (luaParserStr) {
//            [outputStr replaceOccurrencesOfString:[NSString stringWithFormat:@"%@%d%@", @"<%", i, @"%>"]
//                                       withString:luaParserStr
//                                          options:NSCaseInsensitiveSearch
//                                            range:NSMakeRange(0, [outputStr length])];
//        }else {
//            NSLog(@"lua 环境获取数据失败：%@", scriptParserObj);
//            return nil;
//        }
//    }

    NSLog(@"WSLuaScriptEnter outputStr:%@", outputStr);
    return outputStr;
}

/**
 *  递归解析脚本，将lua脚本取出放到luaArray中
 *
 *  @param scriptStr 原始的字符串
 *  @param luaArray  需要解析的lua脚本
 *
 *  @return 去掉lua内容的字符串
 */
-(NSString*) recursionParserScript:(NSString*)scriptStr toLuaArray:(NSMutableArray*) luaArray
{
    NSMutableString *outputStr = [[NSMutableString alloc] init];
    
    NSRange range = [scriptStr rangeOfString:@"<%"];
    if (range.location == NSNotFound) {
        [outputStr appendString:scriptStr];  //没有可解析的lua数据，直接输出
    }
    else {
        [outputStr appendString:[scriptStr substringToIndex: range.location + range.length]];
        
        //解析%>
        NSString *otherStr = [scriptStr substringFromIndex:range.location + range.length];
        NSRange rangeOther = [otherStr rangeOfString:@"%>"];
        if (otherStr && rangeOther.location != NSNotFound) {
            [outputStr appendString:[NSString stringWithFormat:@"%lu%@", (unsigned long)[luaArray count], @"%>"]];
            [luaArray addObject:[otherStr substringToIndex:rangeOther.location]];
            
            if (rangeOther.length + rangeOther.location < otherStr.length) {
                NSString *tmpStr = [self recursionParserScript:[otherStr substringFromIndex:rangeOther.location + range.length]
                                                    toLuaArray:luaArray];
                if (tmpStr) {
                    [outputStr appendString:tmpStr];
                }else {
                    NSLog(@"Error 解析出错:%@, rangeOther:%@", [otherStr substringFromIndex:rangeOther.location + range.length], NSStringFromRange(rangeOther));
                    return nil;
                }
            }
        }else {
            NSLog(@"解析出错:%@, range:%@", scriptStr, NSStringFromRange(range));
            return nil;
        }
    }
    
    return outputStr;
}

+(void) testEnter
{
//    NSMutableString *tmp = [NSMutableString stringWithString:@"你好啊,<%1%>。eeee<%1%>xxxx"];
//    NSLog(@"tmp:%@", tmp);
//    
////    NSString *s1 = [tmp stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@%d%@", @"<%", 1, @"%>"]
////                                         withString:@"1123"];
//    
//    int i = [tmp replaceOccurrencesOfString:[NSString stringWithFormat:@"%@%d%@", @"<%", 1, @"%>"]
//                                 withString:@"2222"
//                                    options:NSCaseInsensitiveSearch
//                                      range:NSMakeRange(0, [tmp length])];
//    NSLog(@"tmp:%@", tmp);
//    return;
//    
    
    
//    WSLuaScriptEnter *enter = [[WSLuaScriptEnter alloc] init];
//    [enter getContentWithLuaScript:@"你好啊,<%local name=findElementInOther(\"col=memo3\",\"name\");return name;%>。"
//                     withFuncsBean:nil
//                     withStoreBean:nil];
}

@end

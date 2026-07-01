//
//  WSRegularTool.m
//  WinSFA
//
//  Created by lishuli on 2018/11/8.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSRegularTool.h"

@implementation WSRegularTool

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSString *)getFactorArrayWithInputString:(NSString *)inpuStr{
    
    NSArray *kgUnitArray = @[@"KG",@"kg",@"Kg",@"kG",@"千克"];
    NSArray *gUnitArray = @[@"g",@"G",@"克"];
    
    NSString *appendStr = [self getfactorString:kgUnitArray];
    NSArray *tmpArray = [self checkAndDealWithString:inpuStr andFactor:appendStr];

    NSMutableArray *resultArray = [NSMutableArray new];
    for (int i = 0; i < tmpArray.count; i ++) {
        
        NSMutableArray *tArray = [NSMutableArray new];
        for (int j = 0; j < gUnitArray.count; j++) {
            NSString *gString = [NSString stringWithFormat:@"%.f%@",[tmpArray[i] floatValue] * 1000,gUnitArray[j]];
            [tArray addObject:gString];
        }
        for (int k = 0; k < kgUnitArray.count; k ++) {
            NSString *kgString = [NSString stringWithFormat:@"%@%@",tmpArray[i],kgUnitArray[k]];
            [tArray addObject:kgString];
        }
        
        [resultArray addObject:tArray];
    }
    
    //如果大单位已经筛选到结果，没有必要再筛选小单位
    if (tmpArray.count == 0) {
        
        NSString *appendStrOne = [self getfactorString:gUnitArray];
        NSArray *gTmpArray = [self checkAndDealWithString:inpuStr andFactor:appendStrOne];
        
        for (int i = 0; i < gTmpArray.count; i ++) {
            
            NSMutableArray *tArray = [NSMutableArray new];
            for (int j = 0; j < gUnitArray.count; j++) {
                NSString *gString = [NSString stringWithFormat:@"%@%@",gTmpArray[i],gUnitArray[j]];
                [tArray addObject:gString];
            }
            for (int k = 0; k < kgUnitArray.count; k ++) {
                NSString *kgString = [NSString stringWithFormat:@"%@%@",@([gTmpArray[i] floatValue] / 1000),kgUnitArray[k]];
                [tArray addObject:kgString];
            }
            [resultArray addObject:tArray];
        }
    }
    
    NSString *replaceString = [NSString stringWithString:inpuStr];
    NSString *searchString = [[NSString alloc] init];
    NSMutableArray *replaceArray = [NSMutableArray new];
    
    if (resultArray.count > 0) {
        NSArray *array = resultArray[0];
        for (int i = 0; i < array.count; i ++) {
            if ([replaceString containsString:array[i]]) {
                for (NSString *reStr in array) {
                    NSString *tmpStr = [replaceString stringByReplacingOccurrencesOfString:array[i] withString:reStr];
                    [replaceArray addObject:tmpStr];
                    
                }
            }
        }
    }else{
        return searchString;
    }
    
    for (NSString *string in replaceArray) {
        searchString = [searchString stringByAppendingFormat:@" %@",string];
    }
    return searchString;
}

- (NSString*)removeFloatAllZeroByString:(NSString *)valueString{
    NSString * outNumber = [NSString stringWithFormat:@"%@",@(valueString.floatValue)];
    return outNumber;
}

//获取正则表达式
- (NSString *)getfactorString:(NSArray *)factorArray{
    NSString *appendStr = [[NSString alloc] init];
    for (int i = 0; i < factorArray.count; i ++) {
        NSString *tmpString = [NSString stringWithFormat:@"(\\d+\\.?\\d*)+%@",factorArray[i]];
        if (i == 0) {
            appendStr = tmpString;
        }else{
            appendStr = [appendStr stringByAppendingString:[NSString stringWithFormat:@"|%@",tmpString]];
        }
    }
    return appendStr;
}

//传入字符串，使用表达式过滤，返回匹配的结果
- (NSArray *)checkAndDealWithString:(NSString *)valueString andFactor:(NSString *)factor{
    
    NSArray<NSString *> *parts = [self  arrayOfCheckStringWithRegularExpression:factor checkString:valueString];
//    NSLog(@"%@", parts);
    return parts;
}

- (NSArray<NSString *> *)arrayOfCheckStringWithRegularExpression:(NSString *)regex checkString:(NSString *)checkString {
    if (!checkString) {
        return nil;
    }
    NSError *error = NULL;
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:regex
                                                                                       options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                                                                         error:&error];
    NSArray *resultArray =
    [regularExpression matchesInString:checkString options:NSMatchingReportProgress range:NSMakeRange(0, [checkString length])];
    
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (int i = 0; i < resultArray.count; i ++) {
        NSTextCheckingResult *result = [resultArray objectAtIndex:i];
        for (NSInteger i = 1; i < [result numberOfRanges]; i++) {
            NSString *matchString;
            
            NSRange range = [result rangeAtIndex:i];
            
            if (range.location != NSNotFound) {
                matchString = [checkString substringWithRange:[result rangeAtIndex:i]];
                [arr addObject:matchString];
            }
        }
    }
    
    return [arr copy];
}

@end

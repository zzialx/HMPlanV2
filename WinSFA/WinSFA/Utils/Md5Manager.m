//
//  Md5Manager.m
//  WinChannelFrameWork
//
//  Created by ZhengJiepeng on 13-3-5.
//
//

#import "Md5Manager.h"
#import "GetMD5byStr.h"

@implementation Md5Manager

// SFA-14945 按照安卓的规则添加 dateType
+ (NSString *)getMd5ByEmpId:(NSString *)aEmpId
                    sotreId:(NSString *)aStoreId
                    bizDate:(NSString *)aBizeDate
                   funcCode:(NSString *)aFuncCode
                     acvtId:(NSString *)aAcvtId
                       memo:(NSString *)aMemo
                   dateType:(NSString *)dateType {
    
    NSString *genStr = @"";
    genStr = [self appendKey:genStr newKey:aEmpId];
    genStr = [self appendKey:genStr newKey:aStoreId];
    genStr = [self appendKey:genStr newKey:aBizeDate];
    genStr = [self appendKey:genStr newKey:aFuncCode];
    genStr = [self appendKey:genStr newKey:aAcvtId];
    genStr = [self appendKey:genStr newKey:aMemo];
    
    if ([dateType length] > 0) {
        if ([dateType isEqualToString:@"E"]) {
            NSString *dateValue = [WSCurrentTime getTimeMillisStringForDevice];
            genStr = [self appendKey:genStr newKey:dateValue];
        }
    }
    
    if ([genStr length] > 0) {
        
        NSString *md5String = [[NSString md5:genStr] lowercaseString];
        
        LogInfo(@"+++createMD5, before:%@, after:%@", genStr, md5String);
        
        return md5String;
    }
    
    return nil;
}


// 此部分逻辑与 Android V2 版本保持一致
+ (NSString *)getMd5ByEmpId:(NSString *)aEmpId
                    sotreId:(NSString *)aStoreId
                    bizDate:(NSString *)aBizeDate
                   funcCode:(NSString *)aFuncCode
                     acvtId:(NSString *)aAcvtId
                       memo:(NSString *)aMemo {
    
    return [Md5Manager getMd5ByEmpId:aEmpId sotreId:aStoreId bizDate:aBizeDate funcCode:aFuncCode acvtId:aAcvtId memo:aMemo dateType:nil];
    
}

+ (NSString *)appendKey:(NSString *)aKey newKey:(NSString *)aNewKey {
    if ([aNewKey isKindOfClass:[NSString class]]) {
        aKey = [aKey stringByAppendingString:@"_"];
        aKey = [aKey stringByAppendingString:aNewKey];
    }
    return aKey;
}

@end

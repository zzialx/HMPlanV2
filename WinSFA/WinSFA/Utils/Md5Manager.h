//
//  Md5Manager.h
//  WinChannelFrameWork
//
//  Created by ZhengJiepeng on 13-3-5.
//
//

#import <Foundation/Foundation.h>

@interface Md5Manager : NSObject

+ (NSString *)getMd5ByEmpId:(NSString *)aEmpId
                    sotreId:(NSString *)aStoreId
                    bizDate:(NSString *)aBizeDate
                   funcCode:(NSString *)aFuncCode
                     acvtId:(NSString *)aAcvtId
                       memo:(NSString *)aMemo;



+ (NSString *)getMd5ByEmpId:(NSString *)aEmpId
                    sotreId:(NSString *)aStoreId
                    bizDate:(NSString *)aBizeDate
                   funcCode:(NSString *)aFuncCode
                     acvtId:(NSString *)aAcvtId
                       memo:(NSString *)aMemo
                   dateType:(NSString *)dateType;


@end

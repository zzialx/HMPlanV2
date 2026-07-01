//
//  WSAcvtDisLogicService.h
//  WinSFA
//
//  Created by Stephanie on 16/8/29.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSAcvtDisLogicService : NSObject

/**
 *  通过问题值的ID获取值的name
 *
 *  @param valueID value
 *  @param qstBean qstBean
 *
 *  @return value presentation
 */
+ (NSString *)getQstValuePresentationWithValueID:(NSString *)valueID qstBean:(WSAcvtBean_qst *)qstBean;


+ (NSString *)getOPTValueByID:(NSString *)valueID qstBean:(WSAcvtBean_qst *)qstBean;

+ (NSString *)getOPTValueByID:(NSString *)valueID acvtQstID:(NSString *)acvtQstID;

+ (NSString *)getDSValueByID:(NSString *)valueID ds:(NSString *)ds filter:(NSString *)filter;

@end

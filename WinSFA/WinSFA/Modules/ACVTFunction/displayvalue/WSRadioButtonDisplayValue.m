//
//  WSRadioButtonDisplayValue.m
//  WinSFA
//
//  Created by yang on 15-3-24.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSRadioButtonDisplayValue.h"

@implementation WSRadioButtonDisplayValue

- (NSObject *)getDisplayValueFor:(NSObject<I_W_BuildInfo> *)buildInfo
{
//    // 选项只有一个 且别填则选中
//    if (ab_qst.is_req && [ab_qst.is_req isEqualToString:@"R"] && ab_qst.opt.count == 1) {
//        WSAcvtBean_qst_opt *optTmp = [ab_qst.opt objectAtIndex:0];
//        redisSelectName = optTmp.optName;
//    }else {
//        
//        if ([self nativeRedis]) {
//            //从markDictionary中查询选中项
//            [ab_qst.opt enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                WSAcvtBean_qst_opt *optTmp = obj;
//                NSString* key = [NSString stringWithFormat:@"%@,%@",ab_qst.acvtQstId, optTmp.optId];
//                if ([self.markDictionary objectForKey:key]) {
//                    redisSelectName = optTmp.optName;
//                    *stop = YES;
//                }
//            }];
//        }
//        if(!self.isNewAddAcvt){
//            //回显服务器数据
//            if (!redisSelectName && [self serverRedis]) {
//                NSString *value = [self getAcvtDisValueByAcvtQstId:ab_qst.acvtQstId];
//                if (value && [value length] > 0) {
//                    [ab_qst.opt enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                        WSAcvtBean_qst_opt *optTmp = obj;
//                        if ([value isEqualToString:optTmp.optId]) {
//                            redisSelectName = optTmp.optName;
//                            *stop = YES;
//                        }
//                    }];
//                }
//            }
//            
//            // 兼容回显新增不拜访的历史数据,（回显的是option_tmp的id）
//            if (!redisSelectName) {
//                NSString *optId = [self.markDictionary objectForKey:ab_qst.acvtQstId];
//                if (optId) {
//                    [ab_qst.opt enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                        WSAcvtBean_qst_opt *optTmp = obj;
//                        if ([optTmp.optId isEqualToString:optId]) {
//                            [self removeObjectFromMarkDictionaryforQst:ab_qst];
//                            redisSelectName = optTmp.optName;
//                            *stop = YES;
//                        }
//                    }];
//                }
//            }
//        }
//        //显示默认值
//        if (!redisSelectName && ab_qst.defaultValue) {
//            [ab_qst.opt enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                WSAcvtBean_qst_opt *optTmp = obj;
//                if ([ab_qst.defaultValue isEqualToString:optTmp.optId]) {
//                    redisSelectName = optTmp.optName;
//                    *stop = YES;
//                }
//            }];
//        }
//    }
}

@end

//
//  WSLoginDataProcessService+DB.h
//  WinSFA
//
//  Created by weida on 16/1/12.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSLoginDataProcessService.h"

@interface WSLoginDataProcessService (DB)

/**
 *  @author weida
 *
 *  @brief 将服务器数据保存到本地数据库中
 *
 *  @param dic 服务器返回的字典数据
 */
-(void)saveToDataBase:(NSDictionary*)dic;



/**
 清除主数据（注销时调用）
 */
+ (void)clearBaseDatas;


/**
 清除旧的拜访数据 (登录成功后调用)
 */
+ (void)clearOldVisitDatas;

@end

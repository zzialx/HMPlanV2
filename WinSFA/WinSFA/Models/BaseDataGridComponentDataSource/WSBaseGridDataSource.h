//
//  WSBaseGridDataSource.h
//  WinSFA
//
//  Created by Alicia on 2018/7/3.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSBaseGridDataSource : NSObject

- (NSArray *)getDataSourceByMd5:(NSString *)md5 brandId:(NSString *)brandId pType:(NSString *)pType funcs:(WSFuncsBean *)funcs store:(WSStoreBean *)store acvtId:(NSString *)acvtId qstBean:(WSAcvtBean_qst *)qstBean;

- (NSArray *)getDataBaseDatasByMd5:(NSString *)md5 funcs:(WSFuncsBean *)funcs store:(WSStoreBean *)store qstId:(NSString *)qstId;

- (NSArray *)getLocalDatasByMd5:(NSString *)md5 funcs:(WSFuncsBean *)funcs store:(WSStoreBean *)store qstId:(NSString *)qstId;

- (NSArray *)getServerDatasByMd5:(NSString *)md5 brandId:(NSString *)brandId pType:(NSString *)pType funcs:(WSFuncsBean *)funcs store:(WSStoreBean *)store qstBean:(WSAcvtBean_qst *)qstBean;

- (BOOL)serverRedisWith:(WSFuncsBean_Param *)param;


- (NSArray *)getServerRedisDatasByMd5:(NSString *)md5 brandId:(NSString *)brandId pType:(NSString *)pType funcs:(WSFuncsBean *)funcs store:(WSStoreBean *)store qstBean:(WSAcvtBean_qst *)qstBean;



@end

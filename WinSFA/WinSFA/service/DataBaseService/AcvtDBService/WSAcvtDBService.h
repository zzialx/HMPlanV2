//
//  WSAcvtDBService.h
//  WinSFA
//
//  Created by yang on 15/4/14.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WSAcvtQstValueDicKeyType){
    WSAcvtQstValueDicKeyTypeQstTypeAndAcvtqstID = 0,
    WSAcvtQstValueDicKeyTypeAcvtqstID,
};


@class WSFuncsBean,WSStoreBean,WSSubempstoreBean,WSAcvtBean;

@interface WSAcvtDBService : NSObject

+ (BOOL)insertAcvtDatasToDBWithStore:(WSStoreBean *)storeBean
                            acvtBean:(WSAcvtBean *)acvtBean
                         qstValueDic:(NSDictionary *)qstValueDic
                  qstValueDicKeyType:(WSAcvtQstValueDicKeyType)keyType
                             funcCod:(NSString *)fc
                                 md5:(NSString *)md5;

+ (BOOL)insertAcvtDatasToDBWithStore:(WSStoreBean *)storeBean
                        newStoreBean:(WSStoreBean *)newStoreBean
                            acvtBean:(WSAcvtBean *)acvtBean
                         qstValueDic:(NSDictionary *)qstValueDic
                  qstValueDicKeyType:(WSAcvtQstValueDicKeyType)keyType
                             funcCod:(NSString *)fc
                                 md5:(NSString *)md5;

+ (BOOL)insertAcvtDatasToDBWithStore:(WSStoreBean *)storeBean
                        newStoreBean:(WSStoreBean *)newStoreBean
                            acvtBean:(WSAcvtBean *)acvtBean
                         qstValueDic:(NSDictionary *)qstValueDic
                  qstValueDicKeyType:(WSAcvtQstValueDicKeyType)keyType
                             funcCod:(NSString *)fc
                                 md5:(NSString *)md5
                             bizDate:(NSString *)bizDate;


+ (BOOL)deleteVisitStoreAcvtDataWithGenId:(NSString *)genId;

@end

//
//  WSBaseAcvtDBService.h
//  WinSFA
//
//  Created by weida on 15/12/23.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSDBService.h"

@interface WSBaseAcvtDBService : WSDBService


- (NSArray *)queryQstsWithAcvtId:(NSString *)acvtId;

- (WSAcvtBean_qst *)queryQstWithAcvtQstId:(NSString *)acvtQstId;

- (WSAcvtBean_qst *)queryQstWithAcvtQstCode:(NSString *)acvtQstCode;

- (NSArray *)queryAcvtsWithStoreId:(NSString *)storeId filter:(NSString *)fitler;

- (NSArray *)queryAcvtsWithfilter:(NSString *)fitler notInStoreId:(NSString *)storeId;

- (NSArray *)queryAcvtsWithfilter:(NSString *)fitler addedToStoreId:(NSString *)storeId;

- (WSAcvtBean *)queryAcvtWithAcvtCode:(NSString *)acvtCode;

- (WSAcvtBean *)queryAcvtWithAcvtID:(NSString *)acvtID;

- (WSAcvtBean *)queryAcvtWithQstCod:(NSString *)qstCod;

- (WSAcvtBean *)queryAcvtWithStoreId:(NSString *)storeId withAcvtCode:(NSString *)acvtCode;
- (WSAcvtBean *)queryAcvtWithStoreId:(NSString *)storeId withAcvtTyp:(NSString *)acvtTyp;   //MMSH-7467

- (NSString *)queryNotFillFromMustFillAcvtStoreId:(NSString *)storeId withParentId:(NSString *)parentId withStoreType:(NSString *)styp;

- (NSString *)queryNotFillFromMustFillAcvtStoreId:(NSString *)storeId withCurrentFc:(NSString *)currentFc withStoreType:(NSString *)styp;

- (NSString *)queryOptNameByID:(NSString *)optID acvtQstID:(NSString *)acvtQstID;

- (NSString *)queryOptPicByID:(NSString *)optID acvtQstID:(NSString *)acvtQstID;

- (NSString *)queryOptPicByOptName:(NSString *)optName;

- (WSAcvtBean *)queryAcvtByFilter:(NSString *)filter acvtCode:(NSString *)acvtCode;

- (NSArray *)queryAcvtsByFilter:(NSString *)filter acvtCode:(NSString *)acvtCode;

- (BOOL)processAcvtQstLuaScript;
- (NSString *)queryAcvtValueWithParamCol:(NSString *)col acvtBean:(WSAcvtBean *)acvtBean;

- (NSArray *)queryQstWithStoreId:(NSString *)storeId acvtCode:(NSString *)acvtCode qstCode:(NSString *)qstCode;
//根据问题cod 查询问题
- (WSAcvtBean_qst *)queryQstWithQstCod:(NSString *)qstCod;

@end

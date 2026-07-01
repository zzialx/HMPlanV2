//
//  WSEditableAcvtQstDBService.h
//  WinSFA
//
//  Created by heju on 16/3/12.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSDBService.h"

#import "WSEditableAcvtQstBean.h"

#import "WSBaseStoreOtherDataTable.h"


@interface WSEditableAcvtQstDBService : WSDBService


+ (BOOL)insertEditableAcvtQstToDb:(WSEditableAcvtQstBean *)acvtQstBean;

+ (BOOL)insertOrUpdateEditableAcvtQstWithValue:(NSString *)value  gen_id:(NSString *)gen_id acvtId:(NSString *)acvtID acvtQstId:(NSString *)acvtQstId qstId:(NSString *)qstId;

+ (BOOL)deleteEditableAcvtQstWithGen_id:(NSString *)gen_id acvtId:(NSString *)acvtID acvtQstId:(NSString *)acvtQstId;

+ (WSEditableAcvtQstBean *)queryObjectWithGen_id:(NSString *)gen_id acvtId:(NSString *)acvtID acvtQstId:(NSString *)acvtQstId;





@end

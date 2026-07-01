//
//  WSAddStoreQstTable.m
//  WinSFA
//
//  Created by zhangke on 14/9/16.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSAddStoreQstTable.h"
#import "WSBaseDictsDBService.h"
#import "WSBaseProductDBService.h"
#import "WSAcvtDisLogicService.h"

@implementation WSAddStoreQstTable

//static WSAddStoreQstTable *addStoreTable=nil;
//+ (WSAddStoreQstTable *)sharedTable
//{
//    if (addStoreTable==nil) {
//        
//        addStoreTable= [[WSAddStoreQstTable alloc]init];
//    }
//    return  addStoreTable;
//}
//
//- (NSArray *)queryStoreQstsByIds:(NSArray *)acvtIds {
//    if ([acvtIds count] == 0) {
//        NSLog(@"acvtIds is nil");
//        return nil;
//    }
//    
//    NSString *inString = @" (";
//    
//    for (NSInteger i = 0; i < [acvtIds count]; i++) {
//        NSString *acvtId = acvtIds[i];
//        if (i == 0) {
//            inString = [inString stringByAppendingFormat:@"'%@'",acvtId];
//        }else {
//            inString = [inString stringByAppendingFormat:@",'%@'",acvtId];
//        }
//    }
//    inString = [inString stringByAppendingFormat:@")"];
//    
//    NSString *sql = [NSString stringWithFormat:@"select * from wch_addStoreQst wchqst join base_acvt acvt on (wchqst.acvt_id = acvt._id and acvt._id in %@)",inString];
//    NSArray *redisQsts = [[WSAddStoreQstTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSAddStoreQstObject"];
//    return redisQsts;
//}
//
//- (NSArray*)queryStoreQstById:(NSString*)aIdValue
//{
//    return  [self queryWithNames:@[@"ANS_ID"] ArgumentsValue:@[aIdValue]];
//}
//
//- (WSAddStoreQstObject *)queryQstObjectByMd5:(NSString *)md5 acvtId:(NSString *)acvtId acvtQstId:(NSString *)acvtQstId
//{
//    if (!md5 || !acvtId || !acvtQstId) {
//        return nil;
//    }
//    
//    return  [[self queryWithNames:@[@"ANS_ID",@"ACVT_ID",@"QST_ID"] ArgumentsValue:@[md5,acvtId,acvtQstId]] firstObject];
//}
//
//
//- (NSString *)queryQstValuePresentationByMd5:(NSString *)md5 acvtId:(NSString *)acvtId qstBean:(WSAcvtBean_qst *)qstBean{
//    WSAddStoreQstObject *qstObj = [self queryQstObjectByMd5:md5 acvtId:acvtId acvtQstId:qstBean.acvtQstId];
//    
//    __block NSString *value = nil;
//    
//    if (qstObj) {
//        value = [WSAcvtDisLogicService getQstValuePresentationWithValueID:qstObj.opt_val qstBean:qstBean];
//    }
//    
//    return value;
//}
//
//
//
//- (NSArray*)queryStoreQstByMd5:(NSString*)md5 andAcvtQstId:(NSString *)acvtQstId andQstType:(NSString *)qstType
//{
//    
//    if (!md5 || !acvtQstId || !qstType) {
//        return [NSArray array];
//    }
//    
//    return  [self queryWithNames:@[@"ANS_ID",@"QST_ID",@"QST_TYPE"] ArgumentsValue:@[md5,acvtQstId,qstType]];
//}
//
//- (void)insertNoVisitNewAddStoreRedisAcvtDatas {
//    NSArray *acvtRedisDatas = [WSAppData getObjectbyKey:ACVTDIS];
//    if (acvtRedisDatas) {
//        for (NSInteger i = 0; i < [acvtRedisDatas count]; i++) {
//            NSDictionary *qstInfo = [acvtRedisDatas objectAtIndex:i];
//            NSString *ans_id = [NSString stringNotNilWithValue:[qstInfo objectForKey:@"gen_id"]];
//            NSString *pString = [qstInfo objectForKey:@"p"];
//            NSArray *pArray = [pString componentsSeparatedByString:@","];
//            NSString *qstId = [NSString stringNotNilWithValue:[pArray objectAtIndex:1]];
//            NSString *qstValue = [NSString stringNotNilWithValue:[pArray objectAtIndex:2]];
//            NSArray *values = [NSArray arrayWithObjects:ans_id,qstId,@"",qstValue,@"", nil];
//            [self deleteWithNames:@[@"ANS_ID",@"QST_ID",@"OPT_VAL"] ArgumentsValue:@[ans_id,qstId,qstValue]];
//            [self insertWithArgumentsValue:values];
//        }
//    }
//
//}
//
//
//- (BOOL)insertOrReplaceStoreQstInfo:(NSArray *)array
//{
//    BOOL isUpdate = NO;
//    if ([array count] < 1) {
//        isUpdate = YES;
//        return isUpdate;
//    }
//    
//    NSString* dbTableName=[WSPlistHelper valueForKey:[self className] withPlistName:kDataBaseMappingFileName];
//    NSString* insertSql=[WSPlistHelper valueForKey:dbTableName withPlistName:kInsertTablesFileName];
//    NSString *delSql=[NSString  stringWithFormat:@"delete from %@ where %@ = ? ",dbTableName,@"ANS_ID"];
//    
//    NSArray* values = [array firstObject];
//    [[WSFMDatebase getInstance] executeUpdateWithSql:delSql withArgumentsInArray:@[[values firstObject]]];
//    
//    return [[WSFMDatebase getInstance] insertWithSql:insertSql withArgumentsInArrays:array];
//}
//
//- (BOOL)insertStoreQstByMd5:(NSString *)md5 acvtId:(NSString *)acvtId qstBean:(WSAcvtBean_qst *)qstBean value:(NSString *)value
//{
//    [self deleteWithNames:@[@"ANS_ID",@"QST_ID",@"acvt_id"] ArgumentsValue:@[md5,qstBean.acvtQstId,acvtId]];
//    
//    if (value) {
//        
//        NSMutableArray* val = [[NSMutableArray alloc] init];
//        [val addObject:md5];
//        
//        [val addObject:qstBean.acvtQstId];
//        [val addObject:value];
//        [val addObject:value];
//        [val addObject:qstBean.qstType];
//        [val addObject:qstBean.isAcvtName];
//        [val addObject:[NSNull null]];
//        [val addObject:acvtId];
//        
//        return [self insertWithArgumentsValue:val];
//    }
//    
//    return YES;
//}
//
//
//- (BOOL)deleteQstNotInAddStoreTable
//{
//    NSArray *md5s = [[WSAddStoreTable sharedTable] queryColValues:@"update_md5id" withName:nil ArgumentsValue:nil isDistinct:YES];
//    
//    if ([md5s count] > 0) {
//        return [self deleteWithNames:nil ArgumentsValues:nil notInName:@"ans_id" notInValues:md5s];
//    }else {
//        return [self deleteAll];
//    }
//}


@end

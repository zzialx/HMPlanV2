//
//  WSEditableAcvtQstDBService.m
//  WinSFA
//
//  Created by heju on 16/3/12.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSEditableAcvtQstDBService.h"

#import "WSBaseStoreOtherDataTable.h"

/*表中字段*/

#define K_BASE_OTHER_ITEM1 (@"item1")  //对应服务器字段 @"id"  (gen_id)
#define K_BASE_OTHER_ITEM2 (@"item2")  //对应服务器字段 @"value"
#define K_BASE_OTHER_ITEM3 (@"item3")  //对应服务器字段 @"empId"
#define K_BASE_OTHER_ITEM4 (@"item4")  //对应服务器字段 @"acvtId"
#define K_BASE_OTHER_ITEM5 (@"item5")  //对应服务器字段 @"acvtQstId"
#define K_BASE_OTHER_ITEM6 (@"item6")  //对应服务器字段 @"qst_id"

#define K_BASE_OTHER_SERVER_NODE (@"type")


#define K_MAP_PLACEHOLDER  @"placeHolder"


@implementation WSEditableAcvtQstDBService


- (BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData{
    BOOL ret = NO;
    WSBaseStoreOtherDataTable *baseStoreOtherTable = [WSBaseStoreOtherDataTable sharedTable];
//    NSArray *ids = [dicts valueForKey:@"id"];
    NSArray *server_nodes = @[nodeName];
    
//    [baseStoreOtherTable batchDeleteFromTableWithNames:@[K_BASE_OTHER_ITEM1,K_BASE_OTHER_SERVER_NODE] ArgumentsValues:@[ids,server_nodes]];
    [baseStoreOtherTable batchDeleteFromTableWithNames:@[K_BASE_OTHER_SERVER_NODE] ArgumentsValues:@[server_nodes]];
    
    NSDictionary *mappingDic = @{K_BASE_OTHER_ITEM1 : @{kMapKey_serverKey:@"id"},
                                 K_BASE_OTHER_ITEM2 : @{kMapKey_serverKey:@"value"},
                                 K_BASE_OTHER_ITEM3 : @{kMapKey_serverKey:@"empId"},
                                 K_BASE_OTHER_ITEM4 : @{kMapKey_serverKey:@"acvtId"},
                                 K_BASE_OTHER_ITEM5 : @{kMapKey_serverKey:@"acvtQstId"},
                                 K_BASE_OTHER_ITEM6 : @{kMapKey_serverKey:@"qst_id"},
                                 K_BASE_OTHER_SERVER_NODE : @{K_MAP_PLACEHOLDER:nodeName}};
    ret = [baseStoreOtherTable batchInsertToTableWithMap:mappingDic Dicts:dicts];
    
    return ret;
}

/*增*/
+ (BOOL)insertEditableAcvtQstToDb:(WSEditableAcvtQstBean *)acvtQstBean {
    
    NSString *gen_id = [NSString stringNotNilWithValue:acvtQstBean.genID];
    NSString *value = [NSString stringNotNilWithValue:acvtQstBean.value];
    NSString *empId = [NSString stringNotNilWithValue:acvtQstBean.empId];
    NSString *acvtId = [NSString stringNotNilWithValue:acvtQstBean.acvtId];
    NSString *acvtQstId = [NSString stringNotNilWithValue:acvtQstBean.acvtQstId];
    NSString *qstId = [NSString stringNotNilWithValue:acvtQstBean.qstId];
    NSArray *values = @[@"",@"",@"",gen_id,value,empId,acvtId,acvtQstId,qstId,@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@""];
    
    NSArray *qNames = @[@"item1",@"item3",@"item4",@"item5"];
    NSArray *qValues = @[[NSString stringNotNilWithValue:gen_id],[NSString stringNotNilWithValue:empId],[NSString stringNotNilWithValue:acvtId],[NSString stringNotNilWithValue:acvtQstId]];
    NSArray *querys = [[WSBaseStoreOtherDataTable sharedTable] queryWithNames:qNames ArgumentsValue:qValues];
    if ([querys count] > 0) {
        [[WSBaseStoreOtherDataTable sharedTable] deleteWithNames:qNames ArgumentsValue:qValues];
    }
    
    return [[WSBaseStoreOtherDataTable sharedTable] insertWithArgumentsValue:values];
    
}

+ (BOOL)insertOrUpdateEditableAcvtQstWithValue:(NSString *)value gen_id:(NSString *)gen_id acvtId:(NSString *)acvtID acvtQstId:(NSString *)acvtQstId qstId:(NSString *)qstId
{
    NSString *genIDStr = [NSString stringNotNilWithValue:gen_id];
    NSString *valueStr = [NSString stringNotNilWithValue:value];
    NSString *empIDStr = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    NSString *acvtIdStr = [NSString stringNotNilWithValue:acvtID];
    NSString *acvtQstIdStr = [NSString stringNotNilWithValue:acvtQstId];
    NSString *qstIdStr = [NSString stringNotNilWithValue:qstId];
    NSArray *values = @[@"",@"",@"editableAcvtQst",genIDStr,valueStr,empIDStr,acvtIdStr,acvtQstIdStr,qstIdStr,@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@""];
    
    NSArray *qNames = @[@"item1",@"item3",@"item4",@"item5"];
    NSArray *qValues = @[[NSString stringNotNilWithValue:genIDStr],[NSString stringNotNilWithValue:empIDStr],[NSString stringNotNilWithValue:acvtIdStr],[NSString stringNotNilWithValue:acvtQstIdStr]];
    NSArray *querys = [[WSBaseStoreOtherDataTable sharedTable] queryWithNames:qNames ArgumentsValue:qValues];
    if ([querys count] > 0) {
        [[WSBaseStoreOtherDataTable sharedTable] deleteWithNames:qNames ArgumentsValue:qValues];
    }
    
    return [[WSBaseStoreOtherDataTable sharedTable] insertWithArgumentsValue:values];
}

/*删*/

+ (BOOL)deleteEditableAcvtQstWithGen_id:(NSString *)gen_id acvtId:(NSString *)acvtId acvtQstId:(NSString *)acvtQstId {
    NSArray *names = @[@"item1",@"item3",@"item4",@"item5"];
    NSArray *values = @[gen_id,[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]],acvtId,acvtQstId];
    return [[WSBaseStoreOtherDataTable sharedTable] deleteWithNames:names ArgumentsValue:values];
}

/*改*/
+ (BOOL)updateEditableAcvtQstToValue:(NSString *)value  WithGen_id:(NSString *)gen_id empId:(NSString *)empId acvtId:(NSString *)acvtID acvtQstId:(NSString *)acvtQstId {
    NSArray *uNames = @[@"item2"];
    NSArray *uValues = @[[NSString stringNotNilWithValue:value]];
    NSArray *wNames = @[@"item1",@"item3",@"item4",@"item5"];
    NSArray *wValues = @[[NSString stringNotNilWithValue:gen_id],[NSString stringNotNilWithValue:empId],[NSString stringNotNilWithValue:acvtID],[NSString stringNotNilWithValue:acvtQstId]];
    return [[WSBaseStoreOtherDataTable sharedTable] updateWithNames:uNames values:uValues whereName:wNames whereValue:wValues];
}


/*查*/
+ (WSEditableAcvtQstBean *)queryObjectWithGen_id:(NSString *)gen_id acvtId:(NSString *)acvtId acvtQstId:(NSString *)acvtQstId {
    if (gen_id == nil) {
        return nil;
    }
    
    NSString *empID = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    
    NSArray *names = @[@"item1",@"item3",@"item4",@"item5"];
    NSArray *values = @[gen_id,empID,acvtId,acvtQstId];
    NSArray *objArray = [[WSBaseStoreOtherDataTable sharedTable] queryWithNames:names ArgumentsValue:values];
    
    WSBaseStoreOtherDataObject *object = [objArray firstObject];
    
    WSEditableAcvtQstBean *qstBean = nil;
    
    if (object) {
        qstBean = [[WSEditableAcvtQstBean alloc] init];
        qstBean.genID = object.item1;
        qstBean.value = object.item2;
        qstBean.empId = object.item3;
        qstBean.acvtId = object.item4;
        qstBean.acvtQstId = object.item5;
        qstBean.qstId = object.item6;
    }
    
    return qstBean;
}



@end

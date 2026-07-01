//
//  WSRouteStoreViewModel.m
//  WinSFA
//
//  Created by zzialx on 2022/10/24.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import "WSRouteStoreViewModel.h"
#import "WSRequestTools.h"
#import "WSRequestHelper.h"
#import "YYModel.h"
#import "WSEditableAcvtQstDBService.h"
#import "WSTskfRouteTjModel.h"

@implementation WSRouteStoreViewModel

- (void)resuetRouteListSucess:(sucess)block failure:(failure)failure{
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:APPDATA_EMPIDBIGI];
    [infoDic setObject:@"getMySpeRouteInfo" forKey:@"objId"];
    NSString * searckKeyWord = self.keyWord?self.keyWord:@"";
    [infoDic setObject:searckKeyWord forKey:@"keyWord"];
    [WSRequestTools requestStoreRouteListWithParameters:infoDic success:^(WSNewRouteListModel *listModel) {
        if(block){
            block(listModel.getMySpeRouteInfo);
        }
        } failure:^(NSString *errorTips) {
            if(failure){
                failure(errorTips);
            }
        }];
}

- (void)requestStoreListWithRequestObjId:(NSString*)requestObjId docDate:(NSString*)docDate sucess:(sucess)success failure:(failure)failure{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:APPDATA_EMPIDBIGI];
    [parameters setObject:requestObjId forKey:@"objId"];
    [parameters setObject:docDate forKey:@"docDate"];
    [[WSRequestHelper shareInstance] postRequestRouteListWithParametes:parameters success:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
        NSDictionary * resultDic = [response jsonResponse];
        if(resultDic){
            WSTskfRouteModel * model = [WSTskfRouteModel yy_modelWithDictionary:resultDic];
            //路线存储门店 base_store_other_data
            WSEditableAcvtQstDBService *service  = [[WSEditableAcvtQstDBService alloc] init];
            NSMutableArray *storeArr = [NSMutableArray arrayWithCapacity:0];
            for (WSTskfRouteStoreModel *routeDataInfoModel in model.getMySpeRouteStore) {
                [storeArr addObject:@{@"store_id":routeDataInfoModel.storeId,@"value":routeDataInfoModel.docDate,@"id":routeDataInfoModel.docDate,@"type":VISIT_PLAN_ROUTE,@"empId":ISNULL(routeDataInfoModel.sort)}];
            }
            [service replaceToTableWithDicts:storeArr FromNode:VISIT_PLAN_ROUTE hasNewData:YES];
            if(success){
                success(model.getMySpeRouteStore);
            }
        }else{
            if(failure){
                failure(@"接口没有返回数据");
            }
        }
        } failure:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
            if(failure){
                failure(response.error.titleForError);
            }
        }];

}
- (void)getStoreListWithRouteId:(NSString*)routeId sucess:(sucess)block failure:(failure)failure{
    
}

- (void)getRouteStatisticsInfoSucess:(sucess)block failure:(failure)failure{
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:APPDATA_EMPIDBIGI];
    [infoDic setObject:@"getMySpeRouteTotal" forKey:@"objId"];
    [WSRequestTools requestRouteTjInfoWithParameters:infoDic success:^(NSObject *listModel) {
        WSTskfRouteTJModel * model  = (WSTskfRouteTJModel*)listModel;
        if(block){
            block(model.getMySpeRouteTotal);
        }
        } failure:^(NSString *errorTips) {
            if(failure){
                failure(errorTips);
            }
        }];
}


@end

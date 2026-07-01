//
//  WSAttanceViewModel.m
//  WinSFA
//
//  Created by zzialx on 2022/10/19.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import "WSAttanceViewModel.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSBaseAcvtDBService.h"
#import "WSBaseStoreAcvtDisTable.h"

@implementation WSAttanceViewModel

- (WSAttenanceModel*)getAttendanceStateListWithKqList:(NSArray*)kqList withDateStr:(NSString*)dateStr{

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"day CONTAINS %@",dateStr];
    NSArray * filteredArray = [kqList filteredArrayUsingPredicate:predicate];
    WSAttenanceModel * attanceModel = filteredArray.firstObject;
    if(attanceModel.approveName.length>0&&![attanceModel.approveName containsString:@"审批状态"]){
        attanceModel.approveName = [NSString stringWithFormat:@"审批状态：%@",attanceModel.approveName];
    }
    return attanceModel;
}

- (NSMutableArray*)getPlanRouteListWithTableData:(NSArray*)tableData withDateStr:(NSString*)dateStr {
    
    NSMutableArray * planRouteList = [NSMutableArray arrayWithCapacity:0];
    for (WSPlanCalendarDataInfoModel *dataModel in tableData) {
        
        if ([dataModel.day isEqualToString:dateStr]) {
            if (dataModel.visitList.count > 0) {
                planRouteList = [NSMutableArray arrayWithArray:dataModel.visitList];
            }
            else {
                WSPlanCalendarRouteDataInfoModel *routeDataInfo = [[WSPlanCalendarRouteDataInfoModel alloc] init];
                routeDataInfo.routeName = @"无";
                [planRouteList addObject:routeDataInfo];
            }
        }
    }
    
    return planRouteList;
}

- (NSMutableArray*)getScheduleListWithTableData:(NSArray*)tableData withDateStr:(NSString*)dateStr {
    
    NSMutableArray *scheduleList = [NSMutableArray arrayWithCapacity:10];
    for (WSPlanCalendarDataInfoModel *dataModel in tableData) {
        
        if ([dataModel.day isEqualToString:dateStr]) {
            
            if (dataModel.forenoon) {
                [scheduleList addObject:[NSString stringWithFormat:@"上午   %@",dataModel.forenoon]];
            }
            if (dataModel.afternoon) {
                [scheduleList addObject:[NSString stringWithFormat:@"下午   %@",dataModel.afternoon]];
            }
            if (dataModel.allday) {
                [scheduleList addObject:[NSString stringWithFormat:@"全天   %@",dataModel.allday]];
            }
            
            break;
        }
    }
    
    return scheduleList;
}

- (NSMutableArray*)getDayWorkPlanListWithPlanStoreList:(NSArray*)planStoreList withDateStr:(NSString*)dateStr {
    
    NSMutableArray *dayWorkPlanList = [NSMutableArray arrayWithCapacity:planStoreList.count];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"day CONTAINS %@", dateStr];
    NSArray *filteredArray = [planStoreList filteredArrayUsingPredicate:predicate];
    dayWorkPlanList = filteredArray.mutableCopy;
    return dayWorkPlanList;
}

- (NSString *)getOldRoleApproveStateWithTableData:(NSArray*)tableData withDateStr:(NSString*)dateStr {
    
    NSString *approveState = @"";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"day CONTAINS %@",dateStr];
    NSArray *filteredArray = [tableData filteredArrayUsingPredicate:predicate];
    WSPlanCalendarDataInfoModel * model = filteredArray.firstObject;
    approveState = model.approveName?model.approveName:@"";
    return approveState;
}

+ (NSString *)getLoginUserRole {
    
    NSString *sql = @"select base_store_acvt_dis.acvt_qst_answer from base_store_acvt_dis join base_acvt_qst on base_acvt_qst.acvtId = base_store_acvt_dis.acvtId and base_acvt_qst.acvtQstId = base_store_acvt_dis.acvtQstId where 1=1 and base_acvt_qst.qstCod = 'wt_selectrole'";
    NSArray *dataArray = [[WSBaseStoreAcvtDisTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSBaseStoreAcvtDisObject"];
    WSBaseStoreAcvtDisObject *obj = [dataArray firstObject];
    NSString *role = obj.acvt_qst_answer;
    return role;
    
//    WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc]init];
//    WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];
//    WSAcvtBean *acvtBean = [baseAcvtDBService queryAcvtWithQstCod:@"wt_selectrole"];
//    WSAcvtBean_qst *qstBean = [acvtBean getQstBeanByQstCod:@"wt_selectrole"];
//    NSString *role =  [service queryQstServerValueWithStoreId:@"" acvtId:acvtBean.acvtId acvtQstId:qstBean.acvtQstId genId:nil];
//    LogInfo(@"登录用户角色：%@", role);
//    return role;
}

@end



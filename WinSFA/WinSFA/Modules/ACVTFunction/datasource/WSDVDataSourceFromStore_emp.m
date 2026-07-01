//
//  WSDVDataSourceFromStore_emp.m
//  WinSFA
//
//  Created by winchannel on 15/12/28.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSDVDataSourceFromStore_emp.h"
#import "WSBaseEmployeeBeanArray.h"
#import "WSBaseEmployeeBean.h"
#import "WSBaseModel.h"
#import "WSDataSourceManager.h"
#import "WSSubempstoreBeanArray.h"
#import "WSBaseEmployeTable.h"

@implementation WSDVDataSourceFromStore_emp

- (NSObject *)getDataSourceFor:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    WSBaseModel *model = (WSBaseModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    
    if ([[buildInfo getDataSource] isEqualToString:STORE_EMP]) {
        
        WSBaseEmployeeBeanArray *employeeBeanArray = [WSAppData getObjectbyKey:STORE_EMP];
        
        NSMutableArray *tempSourceArray = [[NSMutableArray alloc] init];
        
        for (WSBaseEmployeeBean *bean in employeeBeanArray.baseEmployeeBeanArray) {
            
            if ([model.currentStore.Id isEqualToString:bean.pid] && [bean.type isEqualToString:[buildInfo getFilterCondition]]) {
                [tempSourceArray addObject:bean];

            }else if ([bean.pid isEqualToString:@""] && [bean.type isEqualToString:[buildInfo getFilterCondition]]){
                [tempSourceArray addObject:bean];
                
            }

        }
        self.dataSourceArray = tempSourceArray;

    }else if ([[buildInfo getDataSource] isEqualToString:SUB_EMP]) {
        
        WSSubempstoreBeanArray *subempStoreBeanArray = [WSAppData getObjectbyKey:SUBEMPSTORES];
        
        NSMutableArray *subempStores = [[NSMutableArray alloc] init];
        
        for (WSSubempstoreBean *subempStore  in subempStoreBeanArray.subempstoreArray) {
            
            /*如果filer 为 nil 则默认数据源SUBEMPSTORES节点下所有数据 */
            NSString *qstFilter = [buildInfo getFilterCondition];
            if ([qstFilter length] == 0) {
                [subempStores addObject:subempStore];
            } else {
                if ([subempStore.styp isEqualToString:qstFilter]) {
                    [subempStores addObject:subempStore];
                }
            }
            
        }
        self.dataSourceArray = subempStores;
        
    }else if ([[buildInfo getDataSource] isEqualToString:EMP]) {
        
        //        SFA-18818 董宏 应该用Filter 但是兼容立白 emp
        self.dataSourceArray = [[WSBaseEmployeTable sharedTable]queryWithType:[buildInfo getFilterCondition].length > 0 ? [buildInfo getFilterCondition] : EMP];
    }

    return self.dataSourceArray;
}
@end

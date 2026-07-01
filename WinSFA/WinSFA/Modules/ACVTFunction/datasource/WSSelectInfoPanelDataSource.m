//
//  WSSelectInfoPanelDataSource.m
//  WinSFA
//
//  Created by winchannel on 15/5/14.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSSelectInfoPanelDataSource.h"
#import "I_W_DataSource.h"
#import "WSPeopleListDatasource.h"
#import "WSBaseAcvtDBService.h"
#import "WSAcvtListDataItem.h"
#import "WSAcvtQstDisItem.h"

@implementation WSSelectInfoPanelDataSource

@synthesize currentStore;

-(NSObject *)getDataSourceFor:(NSObject<I_W_BuildInfo> *)buildInfo{
    

    
    WSPeopleListDatasource  *datasource =[[WSPeopleListDatasource alloc] init];
    
    datasource.currentStore = currentStore;
    
    NSMutableArray  *dataArray =[[NSMutableArray alloc] init];
    
    NSArray *querydataSource = (NSArray *)[datasource getDataSourceFor:buildInfo];
    
    for(WSAcvtListDataItem *acvtItem in querydataSource){
        
        BOOL needAdd=NO;
        
        for (WSAcvtQstDisItem *qstItem in acvtItem.qstDisArray) {
  
            if ([qstItem.isacvtname isEqualToString:@"6"] && qstItem.acvtanswer!=nil && ![qstItem.acvtanswer isEqualToString:@"-1"]) {

                needAdd = YES;
                break;
                
            }
        }
        
        if (needAdd==YES) {
             [dataArray addObject:acvtItem];
        }
        
    }

    self.dataSourceArray = dataArray;
    
    return dataArray;
    
}

@end

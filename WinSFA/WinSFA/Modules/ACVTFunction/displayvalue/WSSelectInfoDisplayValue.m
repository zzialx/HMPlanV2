//
//  WSSelectInfoDisplayValue.m
//  WinSFA
//
//  Created by winchannel on 15/5/13.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSSelectInfoDisplayValue.h"
#import "WSPeopleListDatasource.h"
#import "WSStoreBean.h"
#import "WSBaseModel.h"
#import "WSDataSourceManager.h"
#import "I_W_BuildInfo.h"



@implementation WSSelectInfoDisplayValue

-(NSObject *)getDisplayValueFor:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    NSArray *queryarray = nil;
    
    WSPeopleListDatasource* peopledata=[[WSPeopleListDatasource alloc] init];
 
    peopledata.currentStore = [[WSDataSourceManager sharedInstance] currentActiveModel].currentStore;
    
    queryarray = (NSArray *)[peopledata  getDataSourceFor:buildInfo];
    
    return queryarray;
}

@end

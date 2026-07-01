//
//  WSDataSourceFromOrg.m
//  WinSFA
//
//  Created by heju on 16/9/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSDataSourceFromOrg.h"

#import "WSOrgBeanArray.h"

@implementation WSDataSourceFromOrg

- (NSObject *)getDataSourceFor:(NSObject<I_W_BuildInfo> *)buildInfo {
    
    WSOrgBeanArray *orgBeanArray;
    
    if ([[buildInfo getDataSource] isEqualToString:ORG_RELATION] ) {
        
         orgBeanArray = [WSAppData getObjectbyKey:ORG_RELATION];
        
        self.dataSourceArray = orgBeanArray.orgBeans;
        
        self.orgLevels = orgBeanArray.difLevelNum;
    }
    
    return orgBeanArray.orgBeans;
}


@end

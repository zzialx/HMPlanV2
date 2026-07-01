//
//  WSDataSourceFromDSProduct.m
//  WinSFA
//
//  Created by Stephanie on 16/8/25.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSDataSourceFromDSProduct.h"
#import "WSBaseProductDBService.h"

@implementation WSDataSourceFromDSProduct

- (NSObject *)getDataSourceFor:(NSObject<I_W_BuildInfo> *)buildInfo
{
    if ([buildInfo getDataSource] && [[buildInfo getDataSource] isEqualToString:@"prod"]) {
        
        WSBaseProductDBService *service = [[WSBaseProductDBService alloc] init];
        
        if ([[buildInfo getFilterCondition] length] > 0) {
            self.dataSourceArray = [service queryProductsWithCondition:[buildInfo getFilterCondition]];
            
        }else {
            self.dataSourceArray = [service queryAllProducts];
        }
        
    }
    return self.dataSourceArray;
}

@end

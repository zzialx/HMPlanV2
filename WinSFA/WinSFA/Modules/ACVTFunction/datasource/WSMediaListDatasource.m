//
//  WSMediaListDatasource.m
//  WinSFA
//
//  Created by winchannel on 15/4/20.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSMediaListDatasource.h"
#import "I_W_DataSource.h"
#import "WSMediaInfo.h"



@implementation WSMediaListDatasource

-(NSObject *)getDataSourceFor:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    
    NSMutableArray  *datasource = [[NSMutableArray alloc] init];
    
    WSMediaInfo  *mediaInfo = nil;
    for (int i=0; i<=10; i++) {
        
        mediaInfo =[[WSMediaInfo alloc] init];
        
        [mediaInfo setMedia_file_id:[NSString stringWithFormat:@"Media_%d",i]];
        
        [mediaInfo setMedia_file_name:[NSString stringWithFormat:@"培训课件%d.pdf",i]];
        
        [mediaInfo setMedia_file_url:[NSString stringWithFormat:@"http://www.baidu.com"]];
        
        if (i%2==0) {
            [mediaInfo setMedia_file_type:@"ppt"];
        }else{
            
            [mediaInfo setMedia_file_type:@"pdf"];
        }
        
        
        [datasource addObject:mediaInfo];
        
    }
    
    
    return datasource;
}

@end

//
//  WSCellContentView.m
//  WinSFA
//
//  Created by winchannel on 15/4/23.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSCellContentView.h"
#import "I_W_Cell.h"
#import "I_W_BuildInfo.h"
#import "WSWidget.h"
#import "WSWidgetFactory.h"
#import "WSConstant.h"


@implementation WSCellContentView



-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self){
       
       
        return self;
    }
    return nil;
}


-(void)buildDisplayContent{
    
    
}
//载入构建信息
-(void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    
    [self loadBuildInfo:buildInfo];
    
}
//载入数据源对象
-(void)loadDataSource:(NSObject<I_W_DataSource> *)datasource{
    
    [self loadDataSource:datasource];
    
}

-(void)clearContent{
  
   
    
}

//载入内容
-(void)loadDisplayContent:(NSObject<I_W_Cell> *)content{
  
    
    
  
}

-(NSObject<I_W_BuildInfo> *)getBuildInfoByType:(NSInteger)buildInfoInd{
    
    NSObject<I_W_BuildInfo> *buildInfo = nil;
    
    for (int i=0; i<[_contentArray count]; i++) {
        
        buildInfo = [_contentArray objectAtIndex:i];
        
        if ([[buildInfo getQuestPos] integerValue]==buildInfoInd) {
            
            return buildInfo;
        }
    }
    return buildInfo;
    
}


-(void)resetViewContent{
    
    
}

- (void)onChangeEvent {
    
}

@end

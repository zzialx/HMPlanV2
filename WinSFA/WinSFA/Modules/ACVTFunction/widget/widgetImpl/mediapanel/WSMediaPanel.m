//
//  WSMediaPanel.m
//  WinSFA
//
//  Created by winchannel on 15/4/15.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSMediaPanel.h"
#import "I_Media.h"
#import "I_Media_Info.h"
#import "I_Media_OperationDelegate.h"

@implementation WSMediaPanel

@synthesize media_Info;

@synthesize mediaOperationDelegate;

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        return self;
    }
    return nil;
}

-(id)initMediaFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        return self;
    }
    return nil;
}

-(void)loadDataSource:(NSObject<I_W_DataSource> *)datasource{
    
    [super loadDataSource:datasource];
    
}

-(void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    [super loadBuildInfo:buildInfo];
    
}


-(void)buildDisplayContent{
    

    
}

//设置媒体信息
-(void)setMediaInfo:(NSObject<IAttachment> *)mediaInfo{
    
    media_info = mediaInfo;
    
    [self buildDisplayContent];
    
}

//执行媒体播放
-(void)playTheMeida{
    
    
}

//设置媒体操作代理
-(void)setMediaPlayDelegate:(NSObject<I_Media_OperationDelegate> *)operationDelegate{
    
    mediaOperationDelegate = operationDelegate;
}

@end

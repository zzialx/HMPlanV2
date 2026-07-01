//
//  WSDownloaderService.h
//  WinSFA
//
//  Created by winchannel on 15/4/29.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSBaseService.h"
#import "I_W_BuildInfo.h"



@class WSInterAction;

@interface WSDownloaderService : WSBaseService{
    
    NSObject<I_W_BuildInfo> *currentbuildInfo;
    
    WSInterAction  *currentInteraction;
    
    NSMutableDictionary  *interactionMap;//这个interactionMap的作用是把所有的操作都记录下来，然后根据映射机制来查找对应的interaction并插入结果，这样才能返回到上层界面以显示正确的结果
    
}


-(void)executeFileDownload:(WSInterAction *)interaction;


-(void)executeGetFileStatus:(WSInterAction *)interaction;

@end

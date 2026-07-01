//
//  WSSaveAcvtDataExecutor.m
//  WinSFA
//
//  Created by mac on 2018/5/17.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSSaveAcvtDataExecutor.h"
#import "WSAcvtView.h"
#import "WSAcvtViewController.h"

@implementation WSSaveAcvtDataExecutor

-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    __weak __typeof(self) wself = self;
    
    LuaScriptWithParamsExpandBlock   paramExpanedBlock=^NSString *(id firstObj, ...) {
        
        __strong __typeof(wself) sself = wself;
        
            if ([firstObj isEqualToString:@"saveAcvtData"]) {
                
                WSAcvtView * acvtView = (WSAcvtView *)sself.delegate;
                if ([acvtView.delegate isKindOfClass:[WSAcvtViewController class]])
                {
                    if ([acvtView.delegate respondsToSelector:@selector(saveAcvtDatasToDB)])
                    {
                        [(WSAcvtViewController *)acvtView.delegate saveAcvtDatasToDBToPop];
                    }
                }
                
            }
        return @"";
    };
    
    return [paramExpanedBlock copy];
    
}
@end

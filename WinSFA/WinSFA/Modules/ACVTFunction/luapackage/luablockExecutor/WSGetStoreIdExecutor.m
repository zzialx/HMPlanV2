//
//  WSGetStoreIdExecutor.m
//  WinSFA
//
//  Created by winchannel on 16/4/10.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSGetStoreIdExecutor.h"
#import "WSAppData.h"
#import "WSStoreBean.h"
#import "WSAcvtView.h"
#import "WSAcvtViewController.h"
#import "WSBaseModel.h"

@implementation WSGetStoreIdExecutor


-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    __weak __typeof(self) wself = self;
    
    LuaScriptWithParamsExpandBlock paramExpanedBlock = ^NSString *(id firstObj,...){
        
        __strong __typeof(wself) sself = wself;
        
        if (sself.delegate) {
            WSAcvtView *acvtView = (WSAcvtView *)sself.delegate;
            WSAcvtViewController *acvtViewController = (WSAcvtViewController *)acvtView.delegate;
            
            WSInPlanStoreBean *inPlanStoreArray = [WSAppData getObjectbyKey:INPLANSTORE];
            
            if (inPlanStoreArray.storesArray.count == 1) {
                
                WSStoreBean *storeBean =[inPlanStoreArray.storesArray firstObject];
                
                acvtViewController.currentStore = storeBean;
                acvtViewController.model.currentStore = storeBean;
                
                return storeBean.Id;
            }
            
            
        }

        return @"";
    };
    
    return [paramExpanedBlock copy];
}
@end

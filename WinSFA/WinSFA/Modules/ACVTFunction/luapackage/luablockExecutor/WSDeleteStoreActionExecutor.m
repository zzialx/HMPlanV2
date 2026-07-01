//
//  WSDeleteStoreActionExecutor.m
//  WinSFA
//
//  Created by yang on 15/12/11.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSDeleteStoreActionExecutor.h"
#import "WSInoutStoreTable.h"
#import "WSDataSourceManager.h"
#import "WSBaseModel.h"
#import "WSInterAction.h"

@implementation WSDeleteStoreActionExecutor


-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    __weak __typeof(self) wself = self;
    
    LuaScriptWithParamsExpandBlock   paramExpanedBlock=^NSString *(id firstObj, ...) {
        
        __strong __typeof(wself) sself = wself;
        
        if (firstObj) {
            WSInoutStoreObject *inOutStoreObj = [[WSInoutStoreTable sharedTable] anyStorehaveNotLeave];
            WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
            NSString *unLeavedStoreName = inOutStoreObj.memo1;
            
            if ([firstObj isEqualToString:@"deleteStoreAction"]) {
                NSString *currentStoreId;
                if (model.currentNewStore) {
                    currentStoreId = model.currentNewStore.Id;
                } else {
                    currentStoreId = model.currentStore.Id;
                }
                if (unLeavedStoreName && [unLeavedStoreName length] > 0 &&
                    [currentStoreId isEqualToString:inOutStoreObj.store_id] && ![model currentNewStore]) {
                    NSString *LeaveString = NSLocalizedString(@"not_leave_store",nil);
                    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:[NSString stringWithFormat:@"%@%@",unLeavedStoreName,LeaveString] tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                } else {
                    
                    NSObject *params = nil;
                    if ([sself.currentTargetObject respondsToSelector:@selector(getOtherLuaExecuteParams)]) {
                        params = [sself.currentTargetObject getOtherLuaExecuteParams];
                    }
                    
                    WSInterAction  *interaction =[[WSInterAction alloc] init];
                    [interaction setExecute_method:@selector(deleteButtonClick:)];
                    [interaction setExecute_method_param:params];
                    [interaction setDirect_type:DIRECT_TYPE_METHOD_WITH_SINGLEPARAM];
                    if ([sself.delegate respondsToSelector:@selector(executeInterAction:)]) {
                        [sself.delegate executeInterAction:interaction];
                    }
                }
                
            }
            
        }
        return @"";
    };
    
    return [paramExpanedBlock copy];
    
}

@end

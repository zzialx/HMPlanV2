//
//  WSCheckMustFillAnyModeExecutor.m
//  WinSFA
//
//  Created by winchannel on 2017/9/18.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSCheckMustFillAnyModeExecutor.h"
#import "WSBaseAcvtDBService.h"

@implementation WSCheckMustFillAnyModeExecutor

-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    
    __weak __typeof(self) wself = self;
    
    LuaScriptWithParamsExpandBlock   paramExpanedBlock = ^NSString *(id firstObj, ...) {
        
        __strong __typeof(wself) sself = wself;
        NSString *firstObjectString = [NSString stringWithFormat:@"%@" ,firstObj];
        va_list argsList;
        va_start(argsList, firstObj);
        id secondObj = va_arg(argsList, id);
        va_end(argsList);
        
        NSString *secondObjString =[NSString stringWithFormat:@"%@",secondObj];
        NSString *result = @"";
        
        if ([firstObjectString isEqualToString:@"checkNotFillFromMustFillAcvt"]){
            NSArray *params = [secondObjString componentsSeparatedByString:@"[@]"];
            if ( params.count >=  3 ) {
                NSString *currentFc = [params firstObject];
                NSString *styp = [params objectAtIndex:1];
                NSString *storeId = [params objectAtIndex:2];
                WSBaseAcvtDBService *acvt_service = [[WSBaseAcvtDBService alloc]init];
                result = [acvt_service queryNotFillFromMustFillAcvtStoreId:storeId withCurrentFc:currentFc withStoreType:styp];
            }
        }else if ([firstObjectString isEqualToString:@"queryNotFillBrotherFuncsFormMustFillFuncs"]){
            NSArray *params = [secondObjString componentsSeparatedByString:@"[@]"];
            if ( params.count >=  3 ) {
                NSString *currentFc = [params firstObject];
                NSString *styp = [params objectAtIndex:1];
                NSString *storeId = [params objectAtIndex:2];
                result = [[WSVisitStoreActionTable sharedTable] queryNotCompleteBrotherFuncsFromMustFillFuncsWithCurrentFc:currentFc withStype:styp withStoreId:storeId ];
            }
            
        }
        if (result && [result length] > 0) {
            return result;
        }else {
            return @"";
        }
    };
    return [paramExpanedBlock copy];
    
}
@end

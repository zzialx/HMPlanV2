//
//  WSGetEnterStoreLatLonExecutor.m
//  WinSFA
//
//  Created by 董宏 on 2020/11/27.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import "WSGetEnterStoreLatLonExecutor.h"
#import "WSInoutStoreTable.h"

@implementation WSGetEnterStoreLatLonExecutor
-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    LuaScriptWithParamsExpandBlock paramExpanedBlock = ^NSString *(id firstObj,...){
//        NSString *firstObjectString = [NSString stringWithFormat:@"%@" ,firstObj];
        va_list argsList;
        va_start(argsList, firstObj);
        id secondObj = va_arg(argsList, id);
        va_end(argsList);
        
        NSString *secondObjString =[NSString stringWithFormat:@"%@",secondObj];
        NSString *result = @"";
        WSInoutStoreObject * notleaveStore = [[WSInoutStoreTable sharedTable] getNotLeaveStoreByStoreId:secondObjString moduleFc:nil];
        if(notleaveStore)
        {
            result = [NSString stringWithFormat:@"%@,%@",notleaveStore.in_lat,notleaveStore.in_lon];
        }
        return result;
    };
    
    return [paramExpanedBlock copy];
}
@end

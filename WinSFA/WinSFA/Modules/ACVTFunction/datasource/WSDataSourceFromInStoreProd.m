//
//  WSDataSourceFromInStoreProd.m
//  WinSFA
//
//  Created by Alicia on 2017/4/11.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSDataSourceFromInStoreProd.h"
#import "WSBaseDictsDBService.h"
#import "WSDataSourceManager.h"
#import "WSBaseModel.h"
#import "WSBaseStoreDBService.h"
#import "WSBaseProductDBService.h"

@implementation WSDataSourceFromInStoreProd

- (NSObject *)getDataSourceFor:(NSObject<I_W_BuildInfo> *)buildInfo
{
    if ([[buildInfo getDataSource] isEqualToString:INSTOREPROD]) {
        
        WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;

        NSString *brand = self.parentSelectedItemID;

        NSString *pType = [buildInfo getFilterCondition];
        
        NSString *storeId = model.currentStore.Id ? model.currentStore.Id : @"-1";
        NSString *drId = model.currentStore.drId ? model.currentStore.drId : storeId;
        
        NSString *idStr = drId;
        if (!idStr) {
            WSBaseStoreDBService *baseStorDBService = [[WSBaseStoreDBService alloc] init];
            idStr = [baseStorDBService queryDrIdWithStoreId:@"-1"];
        }
        WSBaseProductDBService *baseProductDBSerice = [[WSBaseProductDBService alloc] init];
        
        NSArray *dataArray = [baseProductDBSerice queryMoreProductsWithStoreId:idStr brand:brand pType:pType params:@[] appendprop:model.currentFuncs.opt.appendprop];
        if ([dataArray count] > 0) {
            self.dataSourceArray = dataArray;
        }
        
    }
    
    return self.dataSourceArray;
}

@end

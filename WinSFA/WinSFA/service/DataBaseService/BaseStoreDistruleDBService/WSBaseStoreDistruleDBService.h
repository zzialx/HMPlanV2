//
//  WSBaseStoreDistruleDBService.h
//  WinSFA
//
//  Created by yang on 17/5/26.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSDBService.h"

@interface WSBaseStoreDistruleDBService : WSDBService

- (NSArray *)queryDrIdByStoreId:(NSString *)storeId;

@end

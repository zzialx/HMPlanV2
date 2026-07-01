//
//  WSBaseStoreAcvtDBService.h
//  WinSFA
//
//  Created by weida on 15/12/23.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSDBService.h"

@interface WSBaseStoreAcvtDBService : WSDBService


- (BOOL)replaceToTableWithDicts:(NSArray *)dicts withStoreId:(NSString *)storeID;
@end

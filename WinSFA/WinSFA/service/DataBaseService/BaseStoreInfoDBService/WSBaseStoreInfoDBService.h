//
//  WSBaseStoreInfoDBService.h
//  WinSFA
//
//  Created by HZH on 2017/11/24.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSDBService.h"
#import "WSStoreInfoBean.h"

@interface WSBaseStoreInfoDBService : WSDBService

+ (instancetype)shareInstance;

- (WSStoreInfoBean *)queryStoreInfoByStoreId:(NSString *)storeId andType:(NSString *)type;

@end

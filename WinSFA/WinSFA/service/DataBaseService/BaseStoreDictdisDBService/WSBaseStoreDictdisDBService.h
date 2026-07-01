//
//  WSBaseStoreDictdisDBService.h
//  WinSFA
//
//  Created by heju on 16/3/9.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSDBService.h"

@interface WSBaseStoreDictdisDBService : WSDBService

#pragma mark - 查询门店字典项回显方法 genID:唯一标示 storeId:门店id dictIds:需要查询字典项的id组
- (NSArray *)queryStoreDictdisWithGenId:(NSString *)genID storeId:(NSString *)storeId dictIds:(NSString *)dictIds;

@end

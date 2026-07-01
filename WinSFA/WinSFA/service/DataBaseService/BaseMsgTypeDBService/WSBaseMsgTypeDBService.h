//
//  WSBaseMsgTypeDBService.h
//  WinSFA
//
//  Created by weida on 15/12/26.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSDBService.h"

@interface WSBaseMsgTypeDBService : WSDBService

// 根据消息的cod 查该类消息的条数
-(NSInteger)queryMsgCountByCod:(NSString *)filter;


- (BOOL)updateMsgStoreTable:(NSArray*)storemsgList storeId:(NSString*)storeId;
@end

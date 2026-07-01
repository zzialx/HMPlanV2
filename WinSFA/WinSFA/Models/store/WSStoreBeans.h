//
//  WSStoreBeans.h
//  WinSFA
//
//  Created by winchannel on 15/8/7.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSAbstArrayStoreBean.h"

@interface WSStoreBeans : WSAbstArrayStoreBean

-(id)initWithObject:(id)object andParseKey:(NSString *)parseKey;

-(id)initWithObjectForWSAppData:(id)object andParseKey:(NSString *)parseKey;

- (id)initWithObjectForSer:(id)object andParseKey:(NSString *)parseKey;

- (BOOL)isInplanStore:(NSString *)storeID;

@end

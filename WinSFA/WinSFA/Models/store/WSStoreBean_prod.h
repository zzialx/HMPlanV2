//
//  StoreBean_prod.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSStoreBean_prod : NSObject

@property (nonatomic, strong, readonly) NSString        *sid;
@property (nonatomic, strong, readonly) NSString        *pid;
@property (nonatomic, strong, readonly) NSMutableArray  *item;
@property (nonatomic, strong, readonly) NSMutableArray  *itemV;
@property (nonatomic, strong, readonly) NSString        *dt;
@property (nonatomic, strong, readonly) NSString        *dn;

// -(id)initWithSid:(NSString*)aSid Pid:(NSString*)aPid;
- (id)initWithSid:(NSString *)aSid Pid:(NSString *)aPid Prods:(NSArray *)aProds Dis:(NSArray *)aDis;
@end

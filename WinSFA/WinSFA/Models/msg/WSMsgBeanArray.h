//
//  MsgBeanArray.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSMsgBeanArray : NSObject

@property (nonatomic, strong) NSMutableArray *msgArray;

- (id)initWithObject:(id)object;
- (id)initWithObject:(id)object storeId:(NSString*)store;

- (NSArray *)getMsgsBeansWithFilter:(NSString *)filter;
- (NSArray *)getMsgsBeansWithStyp:(NSString *)styp;

@end

//
//  SugReplyBeanArray.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-2-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSSugReplyBeanArray : NSObject {
    NSMutableArray  *sugReplyArray;
    NSMutableArray  *optArray;
}

@property (nonatomic, strong) NSMutableArray    *sugReplyArray;
@property (nonatomic, strong) NSMutableArray    *optArray;

- (id)initWithObject:(id)object;

@end

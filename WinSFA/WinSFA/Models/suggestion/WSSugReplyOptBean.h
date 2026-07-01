//
//  SugReplyOptBean.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-2-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSSugReplyOptBean : NSObject {}
@property (nonatomic, copy, readonly) NSString  *m_sugid;
@property (nonatomic, copy, readonly) NSString  *m_pk;
@property (nonatomic, copy, readonly) NSString  *m_name;

- (id)initWithObject:(id)object;

@end

//
//  SugReplyBean.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-2-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSSugReplyBean : NSObject {}
@property (nonatomic, copy, readonly) NSString  *m_REPLY;
@property (nonatomic, copy, readonly) NSString  *m_empName;
@property (nonatomic, copy, readonly) NSString  *m_uploadDate;
@property (nonatomic, copy, readonly) NSString  *m_sugid;
- (id)initWithObject:(id)object;

@end

//
//  MsgReceiver.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-3-21.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSMsgReceiver : NSObject

@property (nonatomic, readonly) NSString    *m_msgId;
@property (nonatomic, readonly) NSString    *m_empId;
@property (nonatomic, readonly) NSString    *m_orgName;
@property (nonatomic, readonly) NSString    *m_empName;

- (id)initWithObject:(id)object;
@end

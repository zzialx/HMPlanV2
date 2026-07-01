//
//  SuggestListBean.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-2-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define SUG_LIST_ID         @ "ID"
#define SUG_LIST_TOPIC      @ "topic"
#define SUG_LIST_MEMO       @ "memo"
#define SUG_LIST_BIZ_DATE   @ "biz_date"
#define SUG_LIST_EMP_NAME   @ "emp_name"
#define SUG_LIST_REPLYCOUNT @ "replyNum"

@interface WSSuggestListBean : NSObject

@property (nonatomic, copy, readonly) NSString  *m_id;
@property (nonatomic, copy, readonly) NSString  *m_topic;
@property (nonatomic, copy, readonly) NSString  *m_memo;
@property (nonatomic, copy, readonly) NSString  *m_biz_date;
@property (nonatomic, copy, readonly) NSString  *m_emp_name;
@property (nonatomic, copy, readonly) NSString  *m_replyCount;
- (id)initWithObject:(id)object;

@end

//
//  MsgsBean_msg.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import  "I_W_BuildInfo.h"

@interface WSMsgsBean_msg : NSObject

@property (nonatomic, copy, readonly) NSString  *cont;
@property (nonatomic, copy, readonly) NSString  *empId;
@property (nonatomic, copy, readonly) NSString  *Id;
@property (nonatomic, copy, readonly) NSString  *isread;
@property (nonatomic, copy, readonly) NSString  *pid;
@property (nonatomic, copy, readonly) NSString  *pubdate;
@property (nonatomic, copy, readonly) NSString  *s;
@property (nonatomic, copy, readonly) NSString  *title;
@property (nonatomic, copy, readonly) NSString  *typcode;
@property (nonatomic, strong) NSString          *url;
@property (nonatomic, strong) NSString *headrail;
@property (nonatomic, copy, readonly) NSString  *acvtId;
@property (nonatomic, copy)NSString *categoryTitle;
@property (nonatomic, assign)NSUInteger categoryIndex;
@property (nonatomic, assign)BOOL isViewed;
@property (nonatomic, strong) NSString *fileUrl;
@property (nonatomic, strong) NSMutableArray *componentMsgs;
@property (nonatomic, copy, readonly) NSString *fileName;
@property (nonatomic, copy, readonly) NSString *visitAddress;

// 数据库中有,但是没有添加的属性 add by zhiqing
@property (nonatomic, copy, readonly) NSString *video_url;
@property (nonatomic, copy, readonly) NSString *video_path;
@property (nonatomic, copy, readonly) NSString *sound_url;
@property (nonatomic, copy, readonly) NSString *sound_path;
@property (nonatomic, copy, readonly) NSString *update_time;
@property (nonatomic, copy, readonly) NSString *organization;
@property (nonatomic, copy, readonly) NSString *publisher;
@property (nonatomic, copy, readonly) NSString *pinyin;
@property (nonatomic, copy, readonly) NSString *store_id;
@property (nonatomic, copy, readonly) NSString *seq;

@property (nonatomic, copy)NSString * msgType;



- (id)initWithObject:(id)object;


- (NSMutableArray *)generateComponentMsgsWith:(WSMsgsBean_msg *)object fileUrl:(NSString *)fileUrl;

@end

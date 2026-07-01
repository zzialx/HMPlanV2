//
//  WSNoticeNumFcService.h
//  WinSFA
//
//  Created by wangzhiwei on 2018/5/17.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSDBService.h"
#import "WSSqliteUtil.h"
@interface WSNoticeNumFcService : WSDBService
//获取所以门店的内容标识
-(NSDictionary *)getAllStoreMenuNotice;

@end

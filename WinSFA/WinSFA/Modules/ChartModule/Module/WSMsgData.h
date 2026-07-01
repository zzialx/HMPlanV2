//
//  WSMsgData.h
//  WinSFA
//
//  Created by LIBB on 16/12/16.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 *类说明：聊天数据结构
 */
@interface WSMsgData : NSObject

@property (nonatomic, strong) NSString * local_ImageID;
@property (nonatomic, strong) NSString * storeImg;
@property (nonatomic, strong) NSString * storeName;
@property (nonatomic, strong) NSString * storeID;
@property (nonatomic, strong) NSString * row_number;
@property (nonatomic, strong) NSString * msgContent;
@property (nonatomic, strong) NSString * msgTime;
@property (nonatomic, strong) NSString * msgNumber;
@property (nonatomic, strong) NSString * msConversationID;//所属的会话或群ID
@property (nonatomic, assign) NSInteger  msgUnreadNum;
@property (nonatomic, assign) EMMessageBodyType msgType;
@property (nonatomic, strong) NSString * toChatImg;
@property (nonatomic, strong) NSString * toChatName;


@end

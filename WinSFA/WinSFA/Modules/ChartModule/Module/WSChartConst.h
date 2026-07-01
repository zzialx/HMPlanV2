//
//  WSChartConst.h
//  WinSFA
//
//  Created by huzepei on 16/12/20.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#ifndef WSChartConst_h
#define WSChartConst_h

#define WS_CHARTMODULE_USERNAME @"WS_CHARTMODULE_USERNAME"  //聊天用户名
#define WS_CHARTMODULE_PASSWORD @"WS_CHARTMODULE_PASSWORD"  //聊天系统用户密码
#define WS_CHARTMODULE_STORICONURL @"WS_CHARTMODULE_STORICONURL" //店图片下载地址
#define WS_CHARTMODULE_STORNAME @"WS_CHARTMODULE_STORNAME" //店名称
#define WS_CHARTMODULE_LOCALIMAGEID @"WS_CHARTMODULE_LOCALIMAGEID" //店本地图片
#define WS_CHARTMODULE_USERNICKNAME @"WS_CHARTMODULE_USERNICKNAME" //当前登录用户聊天昵称
#define  WS_CHARTMODULE_USERHEADIMAGE @"WS_CHARTMODULE_USERHEADIMAGE" //当前登录用户聊天头像

/* 消息体中的相关信息KEY */

#define WS_MSG_fromChatHeadImgUrl  @"fromChatHeadImgUrl"
#define WS_MSG_fromChatrealName    @"fromChatrealName"
#define WS_MSG_toChatHeadImgUrl    @"toChatHeadImgUrl"
#define WS_MSG_toChatrealName      @"toChatrealName"
#define WS_MSG_toStoreUrl          @"toStoreUrl"
#define WS_MSG_toStoreName         @"toStoreName"
#define WS_MSG_toStoreId           @"toStoreId"         // 注意：这里虽然是门店ID 但是作用应该是会话ID
#define WS_MSG_sourceFrom          @"sourceFrom"
#define WS_MSG_protyKey            @"chat_userinfo_attribute"

/* 消息相关的通知 */
#define WS_MSG_SOURCENEEDNOTIFICATION      @"sourceNeedNotification"
#define WS_MSG_SOURCENOTNEEDNOTIFICATION      @"sourceNotNeedNotification"

#define WS_CHATNOTIFY_RESETUNREADNUMBER @"WS_CHATNOTIFY_RESETUNREADNUMBER"

#define WS_MSG_NO_STORE_VALUE       @"-1"       // 聊天中没有门店的 toStoreId 传该值

#endif /* WSChartConst_h */

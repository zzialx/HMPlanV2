//
//  WSBaseAcvtQstTable.h
//  WinSFA
//
//  Created by weida on 15/12/23.
//  Copyright © 2015年 WinChannel. All rights reserved.
//
#import "WSSqliteUtil.h"

//服务器返回字段名称
#define kQstKey_is_req              (@"is_req")
#define kQstKey_readonly            (@"readonly")
#define kQstKey_acvtId              (@"acvtId")
#define kQstKey_qstId               (@"qstId")
#define kQstKey_qstName             (@"qstName")
#define kQstKey_qstDesc             (@"qstDesc")
#define kQstKey_qstType             (@"qstType")
#define kQstKey_mlen                (@"mlen")
#define kQstKey_dlen                (@"dlen")
#define kQstKey_mnum                (@"mnum")
#define kQstKey_snum                (@"snum")
#define kQstKey_seq                 (@"seq")
#define kQstKey_acvtQstId           (@"acvtQstId")
#define kQstKey_qstCod              (@"qstCod")
#define kQstKey_ds                  (@"ds")
#define kQstKey_filter              (@"filter")
#define kQstKey_parent              (@"parent")
#define kQstKey_color               (@"color")
#define kQstKey_groupName           (@"groupName")
#define kQstKey_mc                  (@"mc")
#define kQstKey_isDefaultClick      (@"isDefaultClick")
#define kQstKey_isAcvtName          (@"isAcvtName")
#define kQstKey_defaultValue        (@"defaultValue")
#define kQstKey_acvtNestedId        (@"acvtNestedId")
#define kQstKey_func                (@"func")
#define kQstKey_alertTitle          (@"alertTitle")
#define kQstKey_parentQstId         (@"parentQstId")
#define kQstKey_orientation         (@"orientation")
#define kQstKey_ishidden            (@"ishidden")
#define kQstKey_Js                  (@"Js")
#define kQstKey_countrule           (@"countrule")
#define kQstKey_isallowadd          (@"isallowadd")
#define kQstKey_hint                (@"hint")
#define kQstKey_charNum             (@"charNum")
#define kQstKey_redis               (@"redis")
#define kQstKey_Value               (@"Value")
#define kQstKey_isMutex             (@"isMutex")
#define kQstKey_dependon            (@"dependon")
#define kQstKey_REG                 (@"REG")
#define kQstKey_tip                 (@"tip")
#define kQstKey_buttonname          (@"buttonname")
#define kQstKey_align               (@"align")
#define kQstKey_is_not_water_mark   (@"is_not_water_mark")

@interface WSBaseAcvtQstTable : WSSqliteUtil

+ (WSBaseAcvtQstTable *)sharedTable;


@end

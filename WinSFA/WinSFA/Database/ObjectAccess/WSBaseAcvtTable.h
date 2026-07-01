//
//  WSBaseAcvtTable.h
//  WinSFA
//
//  Created by weida on 15/12/23.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSSqliteUtil.h"

//服务器端acvt节点字段
#define kAcvtKey_acvtId           (@"acvtId")//对应本地数据库字段_id
#define kAcvtKey_acvtName         (@"acvtName")
#define kAcvtKey_acvtObj          (@"acvtObj")
#define kAcvtKey_typ              (@"typ")
#define kAcvtKey_s                (@"s")
#define kAcvtKey_seq              (@"seq")
#define kAcvtKey_isblock          (@"isblock")
#define kAcvtKey_originalAcvtId   (@"originalAcvtId")
#define kAcvtKey_isReq            (@"isReq")
#define kAcvtKey_ispreview        (@"ispreview")
#define kAcvtKey_ftext            (@"ftext")
#define kAcvtKey_acvtCode         (@"acvtCode")
#define kAcvtKey_organization     (@"organization")
#define kAcvtKey_publisher        (@"publisher")
#define kAcvtKey_qst              (@"qst") //数组元素
#define kAcvtKey_opt              (@"opt") //数组元素,qst的子节点

@interface WSBaseAcvtTable : WSSqliteUtil

+ (WSBaseAcvtTable *)sharedTable;

@end

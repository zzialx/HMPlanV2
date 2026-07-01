//
//  WSAcvtDisArray.h
//  WinSFA
//
//  Created by zhangke on 15/3/19.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WSAcvtDisBean.h"

@interface WSAcvtDisArray : NSObject

@property (nonatomic, strong) NSMutableArray *acvtDisArray;

- (id)initWithObject:(id)object;

- (id)initWithObjectForSer:(id)object notName:(NSString *)aNotName;

- (WSAcvtDisBean *)filterAcvtdisBeanWith:(NSString *)gen_id;

- (WSAcvtDisBean *)filterAcvtdisBeanWith:(NSString *)md5 withAcvtId:(NSString *)acvtId;

/*第一次新增这个问卷的时候, 问卷的回显（非新增之后问卷的回显）*/
- (WSAcvtDisBean *)filterAcvtdisBeanWithAcvtId:(NSString *)acvtId;

@end

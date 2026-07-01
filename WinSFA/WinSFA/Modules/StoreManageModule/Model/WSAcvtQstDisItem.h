//
//  WSAcvtQstDisItem.h
//  WinSFA
//
//  Created by yang on 16/11/2.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSAcvtQstDisItem : NSObject

@property (nonatomic, copy) NSString *genId;

@property (nonatomic, copy) NSString *acvtQstId;

@property (nonatomic, copy) NSString *answer;

@property (nonatomic, copy) NSString *isacvtname;

@property (nonatomic, copy) NSString *qsttype;

@property (nonatomic, copy) NSString *acvtId;

@property (nonatomic, copy) NSString *qstName;

@property (nonatomic, copy) NSString *qstCode;

@property (nonatomic, copy) NSString *countrule;

@property (nonatomic, copy) NSString *getTime;

@property (nonatomic, copy) NSString *acvtanswer;

@property (nonatomic, copy) NSString *status;

@property (nonatomic, copy) NSString *newstoreid;

@property (nonatomic, assign) BOOL unRead;


// SFA-17888 汉高项目为了 TAB_V6001 已经要废弃的逻辑和安卓统一添加的逻辑 storeName storeCode storeId
@property (nonatomic, copy) NSString *storeName;

@property (nonatomic, copy) NSString *storeCode;

@property (nonatomic, copy) NSString *storeId;

@end

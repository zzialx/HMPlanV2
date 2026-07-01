//
//  WSEmbeddedAcvtViewController.h
//  WinSFA
//
//  Created by xiajl on 14-11-6.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSAcvtViewController.h"
#import "WSEmbeddedAcvtViewControllerDelegate.h"

@class WSAcvtModel;

@interface WSEmbeddedAcvtViewController : WSAcvtViewController

@property (nonatomic, strong) WSAcvtModel *parentModel;

@property (nonatomic, copy) NSString *memo2; //陈列协议配了该字段需要取最新的值

@property (nonatomic, weak) id<WSEmbeddedAcvtViewControllerDelegate> delegate;

//创建一个方法 获取该问卷的acvtdata  --zhangmin MMSH-8185
- (NSDictionary *)getAcvtData ;

@end




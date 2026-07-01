//
//  WSUserInfo.h
//  WinSFA
//
//  Created by huzepei on 16/12/24.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 *类功能：聊天相关用户信息数据结构
 */
@interface WSUserInfo : NSObject
@property (strong,nonatomic) NSString * wschatID;       //聊天账号ID
@property (strong,nonatomic) NSString * wsheadImageURL; //头像
@property (strong,nonatomic) NSString * wsname;         //姓名
@property (strong,nonatomic) NSString * wsphone;        //联系电话
@property (strong,nonatomic) NSString * wsdePartID;      //营业部
@property (strong,nonatomic) NSString * wsmanigerID;     //门店负责人ID
@property (strong,nonatomic) NSString * wsempID;         //业代ID
@property (strong,nonatomic) NSString * wsempCode;       //人员编码
@property (strong,nonatomic) NSString * wsroleName;      //人员角色

@end

//
//  WSContactsBookServiceDataModel.h
//  WinSFA
//
//  Created by yuanji on 2018/5/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
//===================================================================================================================================================================

#pragma mark - 联系人标准信息协议
@protocol WSContactsStandardInfo

@end
//===================================================================================================================================================================

#pragma mark - 联系人详细信息协议
@protocol WSContactsDetailInfo

@end
//===================================================================================================================================================================

#pragma mark - 通讯录服务器数据模型
@interface WSContactsBookServiceDataModel : JSONModel

@property (nonatomic, strong) NSArray<WSContactsStandardInfo>* contactsArray;       //联系人数组
@property (nonatomic, strong) NSArray<WSContactsStandardInfo>* storeContactsArray;  //门店联系人数组

@end
//===================================================================================================================================================================

#pragma makr - 联系人标准信息
@interface WSContactsStandardInfo : JSONModel

@property (nonatomic, copy) NSString *contactsId;                           //联系人id
@property (nonatomic, copy) NSString *level_code;                           //等级编码
@property (nonatomic, copy) NSString *parentId;                             //父级id
@property (nonatomic, copy) NSString *leafNode;                             //是否叶节点
@property (nonatomic, copy) NSString *name;                                 //姓名
@property (nonatomic, copy) NSString *empId;                                //登陆人id
@property (nonatomic, copy) NSString *headPhoto;                            //头像链接
@property (nonatomic, copy) NSString *jobTitle;                             //职称
@property (nonatomic, strong) NSArray<WSContactsDetailInfo>* detailArray;   //详情数组

@end
//===================================================================================================================================================================

#pragma makr - 联系人详细信息
@interface WSContactsDetailInfo : JSONModel

@property (nonatomic, copy) NSString *contactsId;   //联系人id
@property (nonatomic, copy) NSString *name;         //姓名
@property (nonatomic, copy) NSString *phone;        //电话
@property (nonatomic, copy) NSString *code;         //编码
@property (nonatomic, copy) NSString *orgName;      //机构名称
@property (nonatomic, copy) NSString *hxCode;       //环信编码
@property (nonatomic, copy) NSString *entryTime;    //入职时间
@property (nonatomic, copy) NSString *jobTitle;     //职称
@property (nonatomic, copy) NSString *headPhoto;    //头像链接
@property (nonatomic, copy) NSString *address;      //地址

@end
//===================================================================================================================================================================

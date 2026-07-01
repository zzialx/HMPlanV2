//
//  SubempstoreBean.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSAcvtBean.h"
#import "I_W_Cell.h"
#import "I_W_OptionDataItem.h"

#pragma mark - 联系人详细信息协议
@protocol WSDetailInfo

@end

@interface WSSubempstoreBean : NSObject<I_W_Cell, I_W_OptionDataItem, NSCopying>

@property (nonatomic, copy) NSString  *empId;
@property (nonatomic, copy) NSString  *Id;
@property (nonatomic, copy) NSString  *parentId;
@property (nonatomic, copy) NSString  *name;
@property (nonatomic, copy) NSMutableArray      *InArray;
@property (nonatomic, strong) NSMutableArray    *outPlanStoreArray;
@property (nonatomic, copy) NSMutableArray      *acvtArray;
@property (nonatomic, copy) NSString *cod;
@property (nonatomic, copy) NSString *styp;
@property (nonatomic, copy) NSString *orgId;
@property (nonatomic, copy) NSString *orgName;//人员名
@property (nonatomic, copy) NSString *orgCode;
@property (nonatomic, copy) NSString *level_code;
@property (nonatomic, copy) NSString *sub_level_code;
@property (nonatomic, copy) NSString *jobTitle; // 职务名称
@property (nonatomic, copy) NSArray   *InArr;
@property (nonatomic, strong) NSArray *outArr;
@property (nonatomic, copy) NSArray   *acvtArr;
@property (nonatomic, assign) BOOL isOption;
@property (nonatomic, copy) NSString *leafNode;

@property (nonatomic, assign) BOOL bPlanned;   //Etrip新增，拜访计划设置
//本地使用，用于对门店排序
@property (nonatomic, copy) NSString    *actionState;
@property (nonatomic, assign) BOOL isExpland;   //是否可以展开
@property (nonatomic, assign) BOOL isAllExpand; // 是否展开所有子节点
@property (nonatomic, copy) NSMutableArray *sonBean;
@property (nonatomic, copy) NSString *imgUrl; //SFA-20170 列表上图标

//用于联系人详情
@property (nonatomic, strong) NSMutableArray<WSDetailInfo>* detailArray;   //详情数组

@property (nonatomic, assign) BOOL hasVisitPlan; // SFA-20169 是否做过拜访计划


- (id)initWithObject:(id)object;

- (void)setSubempStore:(WSBaseStoreObject *)baseStore;

@end


#pragma makr - 联系人详细信息
@interface WSDetailInfo : NSObject<NSCopying>

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

- (id)initWithObject:(id)object;

@end


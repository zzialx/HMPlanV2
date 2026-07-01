//
//  WSStoreFollowUpDataModel.h
//  WinSFA
//
//  Created by 董宏 on 2020/4/22.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class WSStoreFollowUpInfoDataModel;
@interface WSStoreFollowUpDataModel : NSObject
@property (nonatomic, copy)    NSArray <WSStoreFollowUpInfoDataModel *>*followUpList;//随访门店集合
@property (nonatomic, assign)  NSInteger planNum;//计划数量
@property (nonatomic, assign)  NSInteger endNum;//已随访数量
@property (nonatomic, assign)  NSInteger noFollowUpNum; //未随访数量
@end

@interface WSStoreFollowUpInfoDataModel : NSObject
@property (nonatomic, copy)  NSString *empName;//下属人员
@property (nonatomic, copy)  NSString *empId;//下属人员id
@property (nonatomic, copy)  NSString *superiorEmpName;//主管名称
@property (nonatomic, copy)  NSString *endTime;//结束日期
@property (nonatomic, copy)  NSString *storeAddr;//门店地址
@property (nonatomic, copy)  NSString *storeName;//门店名称
@property (nonatomic, copy)  NSString *storeId;//门店ID
@property (nonatomic, copy)  NSString *state;//随访状态
@property (nonatomic, copy)  NSString *leaderId;//主管id

@end
NS_ASSUME_NONNULL_END

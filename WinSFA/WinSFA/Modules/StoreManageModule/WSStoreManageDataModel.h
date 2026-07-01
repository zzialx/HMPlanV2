//
//  WSStoreManageDataModel.h
//  WinSFA
//
//  Created by 董宏 on 2019/12/12.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WSStoreManageDataInfoModel;
//========================================================================================================================================================================

NS_ASSUME_NONNULL_BEGIN

@interface WSStoreManageDataModel : NSObject

@property (nonatomic, copy) NSArray <WSStoreManageDataInfoModel *> *spestorelist;

@end

@interface WSStoreManageDataInfoModel : NSObject

@property (nonatomic, copy) NSString *applyTime;//申请时间
@property (nonatomic, copy) NSString *storeAddr;//门店地址
@property (nonatomic, copy) NSString *storeName;//门店名称
@property (nonatomic, copy) NSString *changeFlage;//修改标志（0不显示修改和撤销，1显示修改和撤销，2显示重新编辑）
@property (nonatomic, copy) NSString *refuseReason;//拒绝原因
@property (nonatomic, copy) NSString * changeType; //变更类型 (0倒闭，1合并，2更新，3新增)
@property (nonatomic, assign) NSInteger emp_id;//未执行客户数
@property (nonatomic, assign) NSInteger status;//门店状态（0已拒绝，1已提交，2已通过，3已撤销
@property (nonatomic, assign) NSInteger acvtId; //总在途时间/预计总在途时间 如果已执行客户数0（未计划）是预计总在途时间
@property (nonatomic, assign) NSInteger genId; //genid

@end

NS_ASSUME_NONNULL_END
//========================================================================================================================================================================

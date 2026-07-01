//
//  WSStoresSearchDataModel.h
//  WinSFA
//
//  Created by 董宏 on 2019/12/14.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class WSStoresSearchDataInfoModel;

@interface WSStoresSearchDataModel : NSObject

@property (nonatomic, copy)   NSArray <WSStoresSearchDataInfoModel *>*spestoreSearchList;

@end

@interface WSStoresSearchDataInfoModel : NSObject
@property (nonatomic, copy)  NSString *code;//编码
@property (nonatomic, copy)  NSString *ts;// 0 给提示。  该门店本月已提交过申请或存在待审批申请，不能在提交申请  非0 请求
@property (nonatomic, copy)  NSString *cpyCode;//0没箭头    是否显示箭头。   没箭头提示 其他业代的客户不能进行更新操作
@property (nonatomic, copy)  NSString *empName;//业代
@property (nonatomic, copy)  NSString *lvlcode;//等级
@property (nonatomic, copy)  NSString *name;//名字
@property (nonatomic, copy)  NSString *addr;//地址

@property (nonatomic, assign)  NSInteger storeId;//未执行客户数
@end

NS_ASSUME_NONNULL_END

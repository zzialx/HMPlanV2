//
//  HosBean.h
//  WinChannelFrameWork
//
//  Created by ZhengJiepeng on 13-6-15.
//
//

#import <Foundation/Foundation.h>

@interface WSHosBean : NSObject

@property (nonatomic, copy, readonly) NSString *sid;
@property (nonatomic, copy, readonly) NSString *Id;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *cod;
// SFA-16206 服务器查询出之前此医生问卷是否是已填写状态
@property (nonatomic, copy, readonly) NSString *state;

@property (nonatomic, assign, readonly) BOOL isPlan;
@property (nonatomic, copy) NSString *detail_info;  // 根据医生是否有这个字段显示医生列表的标题。后台在stores节点下发  SFA-16198

@property (nonatomic, strong, readonly) NSMutableArray *hosBeanArray;

@property (nonatomic, strong, readonly)NSString *iconUrl;

- (id)initHosWithObject:(id)object isPlan:(BOOL)isPlan;

//- (id)initHosWihDict:(WSDictBean *)dict storeId:(NSString *)storeId  isPlan:(BOOL)isPlan;

- (id)initHosWihDepartmentId:(NSString *)departmentId departmentName:(NSString *)departmentName storeId:(NSString *)storeId  isPlan:(BOOL)isPlan iconUrl:(NSString *)iconUrl;

- (id)initHosWihStore:(WSStoreBean *)doctStore storeId:(NSString *)hosStoreId isPlan:(BOOL)isPlan;

@end

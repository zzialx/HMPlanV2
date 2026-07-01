//
//  WSRouteStoreViewModel.h
//  WinSFA
//
//  Created by zzialx on 2022/10/24.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import "WSBaseViewModel.h"
#import "WSTskfRouteModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^sucess)(NSArray<NSObject*>*list);

typedef void(^failure)(NSString*tips);

@interface WSRouteStoreViewModel : WSBaseViewModel

@property(nonatomic,copy)NSString * keyWord;/// 搜索关键字

/// Tskf角色获取路线
/// - Parameters:
///   - block: 成功回调
///   - failure: 失败回调
- (void)resuetRouteListSucess:(sucess)block failure:(failure)failure;

/// SR角色获取特定路线下的门店列表
/// - Parameters:
///   - docDate: 日期
///   - requestObjId: 请求节点
///   - block: 成功回调
///   - failure: 失败回调
- (void)requestStoreListWithRequestObjId:(NSString*)requestObjId docDate:(NSString*)docDate sucess:(sucess)block failure:(failure)failure;

/// SR角色获取特定路线下的门店列表
/// - Parameters:
///   - routeId: 路线id
///   - block: 成功回调
///   - failure: 失败回调
- (void)getStoreListWithRouteId:(NSString*)routeId sucess:(sucess)block failure:(failure)failure;


/// 获取tskf角色的路线统计信息
/// - Parameters:
///   - block:成功回调
///   - failure:失败回调
- (void)getRouteStatisticsInfoSucess:(sucess)block failure:(failure)failure;

@end

NS_ASSUME_NONNULL_END

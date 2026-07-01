//
//  WSRequestTools.h
//  WinSFA
//
//  Created by admin on 2022/10/22.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSNewRouteModel.h"

typedef void(^storeTimeLengthBlock)(NSString * hhStr,NSString * mmStr,NSString * ssStr,NSString *  errorMsg);

typedef void(^getRouteList)(WSNewRouteListModel * listModel);

typedef void(^success)(NSObject * model);

typedef void(^failure)(NSString*errorTips);

typedef void(^completeSuccess)(BOOL success);

typedef void(^expiredChat)(BOOL success);

typedef void(^agreeCollectUserLocaytion)(BOOL success);

typedef void(^rongIMTokenSuccess)(NSString * token);

NS_ASSUME_NONNULL_BEGIN

@interface WSRequestTools : NSObject


/// 请求在店时长
/// - Parameter notice:
+ (void)requestInStoreTimelengthWithNotice:(NSString *)notice block:(storeTimeLengthBlock)block;

/// 请求路线
/// - Parameter OBJName:节点名字
/// - Parameter success:成功回调
+ (void)requestStoreRouteListWithParameters:(NSDictionary*)parameters success:(getRouteList)success failure:(failure)failure;


/// 请求路线
/// - Parameters:
///   - parameters: 参数
///   - success: 成功回调
///   - failure: 失败回调
+ (void)requestStoreDateListWithParameters:(NSDictionary*)parameters success:(getRouteList)success failure:(failure)failure;

/// 请求路线统计信息
/// - Parameters:
///   - parameters: 参数
///   - success: 成功回调
///   - failure: 失败回调
+ (void)requestRouteTjInfoWithParameters:(NSDictionary*)parameters success:(success)success failure:(failure)failure;



/// 退出登录解绑 devicetoken
/// - Parameters:
///   - success: 解绑成功
///   - failure: 解绑失败提醒
+ (void)requestUnBindDeviceTokenSuccess:(completeSuccess)success failure:(failure)failure;

/// 请求推送消息是否超时
/// - Parameters:
///   - success:
///   - failure:
+ (void)reqestChatMsgExpiredWithTaskId:(NSString*)taskId success:(expiredChat)success failure:(failure)failure;

/// 请求同意收集用户定位信息接口
/// - Parameters:
///   - success:
///   - failure:
+ (void)requestAgreeAppCollectingPrivacySuccess:(agreeCollectUserLocaytion)success;

/// 请求融云IM Token接口
/// - Parameters:
///   - success:
///   - failure:
+ (void)requestRongIMTokenSuccess:(rongIMTokenSuccess)success;

/// 请求CNY活动接口
/// - Parameters:
///   - success:
///   - failure:
+ (void)reuqestCNYActivityWithStoreId:(NSString*)storeId success:(success)success;


/// 下载文件
/// - Parameters:
///   - url: 文件路径url
///   - destinationPath: 下载路径
///   - progressBlock: 进度回调
///   - completionBlock: 下载完成回调
+ (void)downloadFileFromURL:(NSURL *)url toDestinationPath:(NSString *)destinationPath progress:(void (^)(NSProgress *downloadProgress))progressBlock completion:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionBlock;


/// 请求建议订单弹框内容
/// - Parameters:
///   - objId: 节点
///   - storeInfo: 门店信息
///   - success: 请求成功的回调
///   - failure: 请求失败的回调
+ (void)reqestSuggestOrderListWithObjId:(NSString*)objId storeInfo:(WSStoreBean*)storeInfo success:(success)success failure:(failure)failure;


@end

NS_ASSUME_NONNULL_END

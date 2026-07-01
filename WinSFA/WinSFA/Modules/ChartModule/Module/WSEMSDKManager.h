//
//  WSEMSDKManager.h
//  WinSFA
//
//  Created by huzepei on 16/12/19.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSUserInfo.h"
/*
 *类功能：环信聊天注册，登录，保存等综合管理类
 */
@interface WSEMSDKManager : NSObject

@property (assign,nonatomic,readonly) BOOL isLoginSucess;
@property (assign,nonatomic,readonly) BOOL isLogin; //是否曾经尝试过登录
@property (strong,nonatomic) NSMutableDictionary * loginNameDic;

+ (instancetype)sharedInstance;

/*
 *函数功能：注册APPKey
 *参数：application
 *参数：launchOptions
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

/*
 *函数功能：聊天用户登录 异步调用
 *参数：username 用户名
 *参数：password 密码
 */
-(void)loginUserName:(NSString*)username PassWord:(NSString*)password completion:(void (^)(NSString *aUsername, EMError *aError))aCompletionBlock;
-(void)loginChartSys;
/*
 *函数功能：解除设备绑定
 *参数：aIsUnbindDeviceToken 是否解除device token的绑定，解除绑定后设备不会再收到消息推送
 *         如果传入YES, 解除绑定失败，将返回error
 *参数： aCompletionBlock 完成的回调

 */
- (void)logout:(BOOL)aIsUnbindDeviceToken
    completion:(void (^)(EMError *aError))aCompletionBlock;

/*
 *函数功能：取得当前登录状态
 */
-(BOOL)getLoginState;
/*
 *函数功能：取得当前登录用户
 */
-(NSString *)getLoginName;
/*
 *函数功能：取得当前登录用户昵称
 */
-(NSString *)getChatNickName;
/*
 *函数功能：取得当前登录用户头像下载地址
 */
-(NSString *)getChatHeadImageLRL;
/*
 *函数功能：根据商店ID,取得商店业代的用户信息
 *参数：storeID,商店ID
 *参数：storeEmpId,商店Empid
 */
-(WSUserInfo*) getUserInfoWithStoreID:(NSString*)storeID andEmpId:(NSString *)storeEmpId;
/*
 *函数功能：取得登录用户信息
 *参数：storeID,商店ID
 */
-(WSUserInfo*) getUserInfo;
/*
 清楚登录信息
*/
-(void)clearCacheData;

// 检测用户是否第一次登陆，并下载聊天数据
-(void)checkUserIsFirstLoadAndDownLoadMessageRecord;

// 上传用户的七天的聊天信息
-(void)uploadBackupFor7Day;
@end

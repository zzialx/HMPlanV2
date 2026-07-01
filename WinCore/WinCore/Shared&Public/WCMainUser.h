//
//  XNMainUser.h
//  xiaonei
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//


@interface WCMainUser : NSObject <NSCoding>


@property (nonatomic,strong) NSNumber* userId;
/**
 * 表示当前登录用户是否需要完善资料。
 */
@property BOOL checkIsNewUser;

/**
 * 表示当前登录用户是否需要设置独立的私信帐号密码
 */
@property BOOL needSetIndependentPwd;

/**
 * jid中的domain
 */
@property(nonatomic, copy) NSString* domainName;



/**
 * 表示登录时填写的登录帐号。
 */
@property (copy)NSString* loginAccount;

/**
 * 表示登录时填写的登录密码的md5。
 */
@property (copy) NSString* md5Password;

/**
 * 表示人人开放平台的ticket。登录人人开放平台成功后获得。
 */
@property (copy)NSString* ticket;

/**
 * 表示3G手机开放平台的session key。登录3G手机开放平台成功后获得。
 */
@property (copy)NSString* sessionKey;

/**
 * 表示3G手机开放平台的private secret key。登录3G手机开放平台成功后获得。
 */
@property (copy)NSString* mprivateSecretKey;


// socket用
@property (copy) NSString *sessionId;

// 是否为第一次登录
@property (copy) NSString *isFirstLogin;


/**
 * 持久化存档。
 */
- (void)persist;

// 从持久化数据中读取mainUser
+ (WCMainUser *)readFromDisk:(NSNumber *)userId;

/**
 * 创建一个Main User对象.
 * 首先从持久化层.初始化,如果没有的话,那么直接生成新的对象.
 */
+ (WCMainUser *)getInstance;

/**
 * 登出动作，仅修改了MainUser的状态和数值。
 */
- (void)logout;

/**
 * 清空MainUser对象数据。一般在切换登录用户时，或者登出时使用。
 */
- (void) clear;

/**
 * 判断是否为登录用户的id.
 *
 * @param userId 被判断的用户id
 * @return 如果是登录用户,返回TRUE,否则返回FALSE.
 */
- (BOOL)isMainUserId:(NSNumber*)userId;
- (BOOL) checkLoginInfo;

// 一些相关目录

// App Document 路径
+ (NSString *)documentPath;
// 持久化路径
+ (NSString *)persistPath:(NSNumber *)userId;
@end



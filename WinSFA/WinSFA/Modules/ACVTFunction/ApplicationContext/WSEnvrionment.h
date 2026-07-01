//
//  WSEnvrionment.h
//  WinSFA
//
//  Created by winchannel on 15/4/29.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
//============================================================================================================================================

#pragma mark - 系统环境变量
@interface WSEnvrionment : NSObject

+ (WSEnvrionment *)shareInstance;       //共享实例方法
+ (BOOL)getuseGeoAmap;                  //是否使用高德SDK方法
+ (BOOL)getUseBaiduMap;                 //是否使用百度地图SDK方法
+ (BOOL)getUseAliyun;                   //图片是否上传到阿里云
+ (BOOL)getUserGesturePassword;         //是否启用手势密码
+ (BOOL)getUseDebugTool;                //是否使用调试工具
+ (BOOL)getParamInLoginData;            //登录向后台请求一次数据还是两次 MSTD-4883
+ (BOOL)getUseOfflineLoginWhenLaunch;   //启动后非首次登录则不向后台请求数据
+ (BOOL)isOpenUserStatistics;
+ (BOOL)onlyAlertWhenUpgrade;           //升级时仅提示。选择1：升级时仅提示，不跳转。选择0：升级时提示信息，点击确定跳转至下载页。
+ (BOOL)getLoginReject;                 //登录页面是否显示拒绝按钮
+ (BOOL)getIsBottomMenu;                //亚宝部分升级所以要求通过打包配置调整
+ (BOOL)getHideRetrievePassword;
+ (BOOL)getHideModifyPassword;
+ (NSString *)getUpgradeMessage;        //需要升级时的提示语
+ (NSString *)getOnlineConsultation;    //在线咨询链接
+ (NSString *)getLoginPlayVideo;        //登录前播放视频,1版本不同的时候
+ (NSString *)getSaasUrl;               //统一平台地址，如果有该地址则登录统一平台
+ (NSString *)getLoginCountdownTime;    //登录按钮不可操作到可操作状态的倒计时时间
+ (NSString *)getAliyunUrl;             //获取阿里云图片地址
+ (NSString *)getHotline;
+ (NSString *)getServerIp;              //获得ip地址
+ (NSInteger)getStoreDataFromDb;
+ (NSInteger)getShortCut;               //辉瑞零售 门店列表新增快捷按钮通道
+ (NSInteger)getNotUseTabBarItemTitle;
+ (NSArray *)getWWCHAT_SHARE_ID;        //获得注册企业微信的ID
+ (NSDictionary *)getEnvMapping;        //获得系统环境变量
+ (NSString *)getAppSystemVersion;      //获取app系统版本号方法
+ (NSString *)getAppRongCludKey;
@end
//============================================================================================================================================

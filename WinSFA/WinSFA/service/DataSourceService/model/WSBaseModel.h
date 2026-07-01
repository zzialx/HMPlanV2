//
//  WSBaseModel.h
//  WinSFA
//
//  Created by yang on 15/3/31.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DATE_MD5_PARAM_KEY @"l_dateStr"
#define MEMO_MD5_PARAM_KEY @"memo"

@class WSFuncsBean,WSStoreBean,WSSubempstoreBean,WSAcvtViewController;

@interface WSBaseModel : NSObject

@property (nonatomic, strong) WSFuncsBean *currentFuncs;

@property (nonatomic, strong) WSStoreBean *currentStore;

@property (nonatomic, strong) WSSubempstoreBean *currentSubEmpStore;

@property (nonatomic, strong) NSString *md5;

@property (nonatomic, strong) NSArray *datasFromDB;

@property (nonatomic, strong) WSVisitStoreActionObject *currentVisitAction;

@property (nonatomic, weak) WSAcvtViewController *ownAcvtViewController;

@property (nonatomic ,strong) NSString *realParentFuncsCode;


/**
 对调查问卷新增的门店
 */
@property (nonatomic, strong) WSStoreBean *currentNewStore;

/**
 * 是否来自实时请求数据，实时请求时，服务器回显数据优先级高，只显示服务回显数据
 */
@property (nonatomic, assign) BOOL isFromRealTimeData;


/**
 * 是否来自修改门店，修改门店的页面不需要判断是否配置服务器回显，SFA-9217 按照安卓逻辑添加
 */
@property (nonatomic, assign) BOOL isFromModifyStore;



/**
 * 标识页面上传数据但是不退出当前页面，从脚本设置
 **/
@property (nonatomic, assign) BOOL uploadThenNotFinishView;
/**
 * 标识页面上传数据后跳转的Tab页，从脚本设置
 **/
@property (nonatomic, assign) NSInteger uploadThenSelectedTabIndex;

@property (nonatomic, strong) NSString *extralData;

@property (nonatomic, strong) NSString *prepareVisitDate;

///错误信息
@property(nonatomic,strong)NSString * errorTips;

- (void)loadDataFromDataBase;

- (void)createMD5With:(NSDictionary*)param;

- (NSDictionary*)md5Param;


/**
 *  @brief 是否支持本地回显。
 *
 *  @return
 */
- (BOOL)nativeRedis;

/**
 *  @brief 是否支持服务端回显。
 *
 *  @return
 */
- (BOOL)serverRedis;


@end

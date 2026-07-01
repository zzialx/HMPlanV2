//
//  WinJSBridgeViewController.h
//  NIVEA
//
//  Created by yuanji on 2022/10/9.
//

#import <UIKit/UIKit.h>
#import "WCBaseViewController.h"
#pragma "WSStoreBean.h"

#define Win_JSBridge_URL_Replacing_RouteId_Mark         @"routeId"              //路线id标识
#define Win_JSBridge_URL_Replacing_VisitDate_Mark       @"visitDate"            //拜访时间标识
#define Win_JSBridge_Parameter_VisitStoreDuration_Mark  @"visitStoreDuration"   //拜访门店持续时间标识
#define Win_JSBridge_Parameter_VisitStoreRemind_Mark    @"visitStoreRemind"     //拜访门店提醒标识
#define Win_JSBridge_URL_Replacing_MSGID_Mark           @"messId"               //路线id标识

typedef void(^BackBlcok)(void);
//====================================================================================================================================

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 注册协议
@protocol RegisterHandlerProtocol <NSObject>

- (void)registerHandler_close;                      //关闭协议
- (void)registerHandler_getCurrentLocation;         //获取当前位置协议
- (void)registerHandler_openOptionsNavigation;      //打开选项导航协议
- (void)registerHandler_jumpStoreTask;              //跳转门店任务协议
- (void)registerHandler_completeOrangeAcquisition;  //完成橙色采集协议
- (void)registerHandler_completeOtoAcquisition;     //完成oto采集协议
- (void)registerHandler_getExitStoreData;           //获取退出门店数据协议
- (void)registerHandler_completeVisitStore;         //获取完成拜访数据协议
- (void)registerHandler_jumpWebView;                //跳转网页协议
- (void)registerHandler_saveStoreAction;            //保存门店动作协议
- (void)registerHandler_readFinish;                 //消息阅读交互协议
- (void)registerHandler_openTraxCameraTask;         //打开Trax相机协议
- (void)registerHandler_getLocalPicture;            //本地相册交互协议
- (void)registerHandler_updateFuncsCount;           //更新菜单活动数量协议

@end
//====================================================================================================================================

#pragma mark - js桥接视图管理器
@interface WinJSBridgeViewController : WCBaseViewController

@property (nonatomic, copy) NSString *externalOpenUrl;      //外部打开URL标识
@property (nonatomic, strong) NSDictionary *externalInfoDic;//外部信息字典
@property (nonatomic, strong) WSStoreBean *currentStore;    //当前门店
@property (nonatomic, assign) BOOL isNotAllowSideslipBack;  //是否允许侧滑返回
@property (nonatomic, copy)BackBlcok backBlcok;

- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store; //自定义初始化方法

@end

NS_ASSUME_NONNULL_END
//====================================================================================================================================

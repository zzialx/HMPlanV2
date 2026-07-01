//
//  WCBaseViewController.h
// Core
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WSEmptyView.h"
#import "WSNavigationBar.h"
#import "WSRefreshLoginHttpService.h"
#import "WSLuaExecutorManager.h"
#import "WSRequestTools.h"

@class BaseViewController;
@class WSInterAction;
@class WSSplitViewController;

typedef void(^backFreshOrangeState)(void);
typedef void (^PersonalizationRedirectFinishBlock)(void);



@protocol WCBaseViewControllerDelegate <NSObject>

@optional
- (void)callBackWhenFinishTask:(WSInterAction *)interaction;
- (void)controllerNeedDismiss;
- (void)refreshedAllSubviewsWithRealtimeDatas;
- (void)executeInterAction:(WSInterAction *)interaction;

@end

@interface WCBaseViewController : UIViewController <UIGestureRecognizerDelegate> {
    
    WSLuaExecutorManager  *wsLuaExecutor;
}

+ (WCBaseViewController *)getControllerWithFuncsBean:(WSFuncsBean *)fb realSubFuncsBean:(WSFuncsBean *)realSubFuncsBean;
- (id)initWithFuncs:(WSFuncsBean *)funcs;
- (void)doDynamicCalling:(id)instance method:(SEL)selector andParam:(NSObject *)param;
- (void)addEmptyView;
- (void)backAction;
- (void)showOnlineConsultationBtn;
- (void)querying_messageTips;
- (void)addChencShowAlertTipsWithMsg:(NSString*)msg;
- (void)HYPageViewButtonClickEvent;
- (void)beginRefreshData;
- (void)addNotAllowSlidBack;
- (void)addCollectUserLocationPlaclyAlert:(completeSuccess)successBlock;
- (void)pushViewWithFuncsBean:(WSFuncsBean *)fb realSubFuncsBean:(WSFuncsBean *)realSubFuncsBean;   //弹出视图方法
- (void)homePersonalizationFinish;                                                                  //首页个性化完成方法
- (BOOL)isPersonalizationRedirect;                                                                  //是否个性化重定向方法
- (void)executePersonalizationRedirect;                                                             //展示个性化重定向方法
- (BOOL)shouldCustomInteractivePopGestureRecognizerDelegate;
- (BOOL)shouldPauseBackAction;
- (BOOL)backToParent;
- (BOOL)parentForceToDone;
- (BOOL)manageActionStatus:(WSVisitStoreActionObject *)visitAction;
- (BOOL)isNeedUpdateParentStatus:(WSVisitStoreActionObject *)aAction;
- (BOOL)isHiddenCurrentTab;
- (BOOL)executeValidateLuaScripWithFb:(WSFuncsBean *)fb;
- (BOOL)executeValidateLuaScripWithFb:(WSFuncsBean *)fb functionName:(NSString *)functionName params:(NSString *)params;
- (CGFloat)contentHeight;
- (UINavigationController *)getNavigationController;
- (UINavigationItem *)getNavigationItem;
- (NSInteger)markBadgeForMessage;
- (NSString *)getBadgeValue;


@property (nonatomic, weak) id<WCBaseViewControllerDelegate> wcBaseViewdelegate;
@property (nonatomic, weak) UIViewController  *ownParentViewController;
@property (nonatomic, weak) WSSplitViewController *wsSplitController;
@property (nonatomic, assign) BOOL hasSegment;
@property (nonatomic, assign) BOOL isTabMode;
@property (nonatomic, assign) BOOL firstEnterView;
@property (nonatomic, assign) BOOL isPageSegmentView;
@property (nonatomic, strong) WSFuncsBean *currentFuncs;
@property (nonatomic, strong) WSInterAction *executeParam;
@property (nonatomic, strong) WSRefreshLoginHttpService *refreshService;
@property (nonatomic, strong) WSEmptyView *empty;
@property (nonatomic, strong) UILabel *storeNameLabel;
@property (nonatomic, strong) UIViewController *tempChildController;
@property (nonatomic, copy) NSString *itemCode;
@property (nonatomic, copy) NSString *input_reflect_code;
@property (nonatomic, copy) NSString *realParentFuncsCode;
@property (nonatomic, copy) NSString *bizDate;
@property (nonatomic, copy) NSString *kqArrange;
@property(nonatomic,  assign) BOOL isNotShowStoreNameLabel;///默认为NO,是显示门店名字  YES不显示门店名字
@property (nonatomic, copy) backFreshOrangeState backFreshOrangeState;                          //请求橙色采集状态
@property (nonatomic, copy) PersonalizationRedirectFinishBlock homePersonalizationFinishBlock;  //首页个性化完成闭包

@end

//
//  AcvtViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>

#import "BaseViewController.h"
#import "WSFuncsBean_opt.h"
#import "WSAcvtBean.h"
#import "ZBarReaderViewController.h"
#import "WSSingleSelectViewController.h"
#import "ZJPAddressPickerView.h"
#import "WSAddressSelectViewController.h"
#import "WCStartEndDateView.h"
#import "WSHTextField.h"
#import "WSSelectListView.h"
#import "PhotoTypeButton.h"
#import "WSPhotoGalleryViewController.h"
#import "WSBaseGrideViewController.h"
#import "RatingView.h"
#import "WSLuaScriptEnter.h"
#import "WSSerieLinkHeadView.h"
#import "WSGridLinkPopupView.h"
#import "WSHosBean.h"
#import "WSCalendarPanel.h"
#import "WSANNestedAcvtPanel.h"
#import "WSBaseView.h"
#import "WSServiceDispatcher.h"
#import "WSAcvtView.h"
#import "WSWidget.h"
#import "SEPrinterManager.h"
#import "HLPrinter.h"
#import "WSBlueToothListActionSheet.h"

@class WSNewProductBean;
@class WSEnvrionment;
@class WSAcvtService;
@class WSAcvtTempView;

typedef NS_ENUM (NSInteger, WSUploadDataActionType) {
    WSNormalActionType = 0,
    WSVisitActionType,
    WSDeleteActionType
};

typedef NS_ENUM (NSInteger, WSOperationAcvtType) {
    WSUploadAcvtDateNormalType = 0,     //正常的上传数据
    WSOnlySaveAcvtDataForCalendarType,  //有日历控件时的只保存数据到本地 不进行上传(然后更新日历控件)
    WSUploadAcvtDataForCalendarType     //有日历控件时上传
};
//==========================================================================================================================================================================

#pragma mark - 调查问卷视图管理器
@interface WSAcvtViewController : BaseViewController
<WSBaseViewDelegate, WCBaseViewControllerDelegate, WSWidgetDelegate, WSServiceDispatcherDelegate, WSAcvtViewDelegate, SEPrinterManagerDelegate> {
    
    BOOL isLoaded;
    WSServiceDispatcher *serviceDispatcher;
    WSAcvtService *acvt_service;
    NSString *prentAcvtQstId;
}

@property (nonatomic, assign) NSInteger mySection;                              //mySection的索引？？？
@property (nonatomic, strong) UITableView *tableView;                           //表格
@property (nonatomic, strong) WSAcvtBean *m_currentAcvt;                        //当前的acvt数据对象
@property (nonatomic, strong) NSMutableDictionary *m_othersDic;                 //对acvt的补充
@property (nonatomic, assign) NSInteger m_height;                               //高度？？？
@property (nonatomic, strong) WSLuaScriptContext *luaParserObj;                 //lua脚本上下文
@property (nonatomic, assign) BOOL isNeedRedisFromServer;                       //服务端回显 并且给参数
@property (nonatomic, strong) NSArray *imageArray;                              //上传照片的数组
@property (nonatomic, assign) BOOL isValueChange;                               //是否有值改变
@property (nonatomic, weak) UIViewController *parentController;                 //父级节点
@property (nonatomic, strong) NSMutableDictionary *anJsonDataDictionary;
@property (nonatomic, assign) BOOL isNewAddAcvt;                                //新增调查问卷
@property (nonatomic, copy) NSString *submitempid;                              //对人的随访 不在门店内
@property (nonatomic, strong) UITextField *currentInputTextField;               //当前文本录入区域
@property (nonatomic, strong) NSMutableDictionary *titlesDictionary;
@property (nonatomic, strong) WSAcvtView *acvtview;
@property (nonatomic, assign) BOOL uploadBtnEnable;
@property (nonatomic, assign) BOOL uploadBtnHidden;
@property (nonatomic, assign) WSUploadDataActionType currentUploadActionType;
@property (nonatomic, copy) NSString *iID;
@property (nonatomic, strong) WSStoreBean *currentNewStore;
@property (nonatomic, copy) NSString *updateGenID;
@property (nonatomic, copy) NSString *acvtNameMainTitle;                        //列表里显示的主标题的值 用于上传
@property (nonatomic, assign) BOOL isShowStoreName;
@property (nonatomic, assign) BOOL hideUploadAlert;
@property (nonatomic, assign) BOOL hideNoDataAlert;
@property (nonatomic, assign) WSOperationAcvtType operationAcvtType;
@property (nonatomic, copy) NSString *currentUsingNewMd5WhenAcvtHasCalendar;
@property (nonatomic, copy) NSString *calendarKeyId;
@property (nonatomic, copy) NSString *currentCalendarValue;
@property (nonatomic, strong) NSMutableArray *jsonArray;
@property (nonatomic, strong) WSCalendarPanel *calendarPanel;                   //排班日历panenl
@property (nonatomic, strong) NSMutableArray *calendarSelectedDates;
@property (nonatomic, assign) BOOL deleteDBAcvtDatas;
@property (nonatomic, strong) NSMutableArray *md5sForCalendarPattern;
@property (nonatomic, copy) NSString *selectedEmployeeId;
@property (nonatomic, copy) NSString *objID;
@property (nonatomic, copy) NSString *uploadStyle;
@property (nonatomic,assign) BOOL loadAcvtViewFormViewDidLoad; //MMSH-8185 特殊处理，其他功能慎用
@property (nonatomic,assign) BOOL isAsView; //MMSH-8185 yes：表示当前问卷控制器 作为一个view，添加到其他其他视图上
//是否显示了建议订单弹框（默认为NO）
@property (nonatomic,assign) BOOL isShowSuggestionOrderAlertView;
//类方法
+ (void)backPromptWithFuncs:(WSFuncsBean *)funcs saveBlock:(void (^)())saveblock uploadBlock:(void (^)())uploadBlock giveupBlock:(void (^)())giveupBlock; //返回弹出保存上传放弃的提示

//初始化acvt
- (id)initWithAcvt:(WSAcvtBean *)anAcvt Funcs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store;
- (id)initWithAcvt:(WSAcvtBean *)anAcvt Funcs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store SubEmpId:(NSString *)subEmpId;
- (id)initWithAcvt:(WSAcvtBean *)anAcvt Funcs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store hosBean:(WSHosBean *)hosBean;
- (id)initWithAcvt:(WSAcvtBean *)anAcvt Funcs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store acvtNewStore:(WSStoreBean *)acvtNewStore;
- (id)initWithAcvt:(WSAcvtBean *)anAcvt Funcs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store Section:(int)section;
- (id)initWithAcvt:(WSAcvtBean *)anAcvt Funcs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store md5:(NSString *)acvtMd5;
- (id)initWithAcvt:(WSAcvtBean *)anAcvt Funcs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store md5:(NSString *)acvtMd5 isFromRealTimeData:(BOOL)isFromRealTimeData;
- (id)initWithAcvt:(WSAcvtBean *)anAcvt Funcs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store md5:(NSString *)acvtMd5 isFromRealTimeData:(BOOL)isFromRealTimeData
          SubEmpId:(NSString *)subEmpId;
- (id)initWithAcvt:(WSAcvtBean *)anAcvt Funcs:(WSFuncsBean *)funcs subEmpStore:(WSSubempstoreBean*)store;

//其它
- (void)initAcvtModel;                                                  //初始化问卷模型数据方法

- (void)weChatImgShareButtonClick:(id)sender;                           //微信分享
- (void)weChatImgShareToWeChart:(UIButton *)sender;                     //跳转微信应用
- (void)addAcvtshowBeansToView:(UIView *)aView viewHight:(int *)aHight;
- (void)deleteButtonClick:(UIButton *)sender;
- (void)popToParentOrHome;
- (void)initANOfUploadDatasBeforeUpload;                                //上传前初始化AN类型的数据
- (void)addGPSData;                                                     //添加gps数据
- (void)executeAnyOperationWith:(WSInterAction *)interaction;
- (void)executeUpload;                                                  //开始执行上传动作，先校验
- (BOOL)executeValidate;                                                //执行校验
- (void)executeRealUpload;                                              //校验通过，开始真正上传数据图片等
- (NSArray *)getTableDatasWithNewAcvtMD5:(NSString *)acvtMd5;           //获取和存储表格数据 (表格数据与调查问卷一起上传) 上传时需要生成新的id时，需要把新id传过来，重新生成表格id
- (BOOL)uploadAcvtDatas;                                                //上传数据
- (BOOL)uploadPhotos;
- (BOOL)uploadPhotosForTable;                                           //上传表格照片
- (BOOL)uploadPhotosForAcvtView:(BOOL)isUpload;                         //上传照片
- (void)clearValueChangeData;
- (BOOL)isShowBackPrompt;                                               //后退是否需要弹出提示
- (void)backToSave;                                                     //返回保存
- (void)backToGiveup;                                                   //返回放弃修改
- (void)beginToVisitStore:(NSString *)tips;
- (BOOL)uploadNewAcvtDeletePhotos;
- (BOOL)newAcvtHasPhoto;
- (BOOL)getIsUpdateCalendarDataFromLua;                                 //是否是脚本调用的update方法
- (NSMutableDictionary *)getNewAcvtGpsInfo;
- (NSObject *)getNewAcvtMapPanelView;
- (void)saveAcvtDatasToDB;
- (void)saveTBAcvtDatasToDB;
- (void)executeRealWillUpload:(NSNumber *)numberParam;
- (void)updateCalendarData:(NSString *)param;
- (void)processNestAcvtGenIdWhenNewId:(NSMutableDictionary *)dic;
- (NSString *)generateMd5WhenAcvtHasCalendar:(NSString *)dateStr;
- (void)saveANDeleteWhenUpload;                                         //在上传时删除AN嵌套问卷删除的子问卷
- (void)deleteANNewAddWhenBack;                                         //未上传直接返回时 删除AN新增的那些子问卷
- (void)setAcvtReadOnly;                                                //设置调查问卷为只读 所有问题不可编辑 隐藏上传按钮
- (BOOL)getAcvtReadOnly;
- (void)setAcvtReadOnlyByParam:(NSString *)param;
- (void)resetSteadyViewHiddenOrNot;
- (void)checkSameMainTitleTipAndUpload;
- (void)showBlueToothListViewWithParam:(NSString *)str;                 //弹出蓝牙选择列表
- (void)excuseFromServer:(NSString *)param;                             //脚本执行刷新问卷回显
- (void)saveAcvtDatasToDBToPop;
- (void)doRealtimeRefreshAcvtDatasWithParamDic:(NSDictionary *)paramDic;//外部调用实时获取问卷数据的方法
- (void)updateGenidData:(NSString *)param;                              //更新genid数据方法 param:参数
- (void)alertCancleAction;
- (void)showSameStoreList:(NSArray *)storeArray;
- (void)reloadAcvtview;
- (void)showIsVisitTipWithCurrentStore:(WSStoreBean *)storeBean;
- (void)jumpActivityWithFv:(NSString *)fv;
- (NSString *)getAcvtEdit;
- (void)refeshLocation:(NSString *)param;                               //刷新位置方法

/* 数据格式如下
 {\"FAC_004_AT02_cfa7a7ce9807d0afe2ec71b0497b89771203\":\"039ebfb335c05eb09db7f0822db2db23.jpg,8ac4f3739c4e2b7c7dbe81a8ba70bde1.jpg\",\"FAC_004_AT02_cfa7a7ce9807d0afe2ec71b0497b89771206\":\"59109ff9024a680ad6e706e17c5c2e82.jpg,fb369026bb50d8421664a7efdafab562.jpg\"}
 */
- (NSString *)generatePhotoNamesData;
/**
 更新离店操作事件，同步服务器事件

 @return 
 */
- (void)updateExitUpLoadAction;
@end
//==========================================================================================================================================================================

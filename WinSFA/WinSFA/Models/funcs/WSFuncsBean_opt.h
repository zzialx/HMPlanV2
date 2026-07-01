//
//  FuncsBean_opt.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, WSHidePlanOrBit) {
    WSHidePlanOrBitPlan = 1,            // 计划内轨迹隐藏
    WSHidePlanOrBitActually = 1 << 1,   // 已拜访轨迹隐藏
    WSHidePlanOrBitOutPlan = 1 << 2,    // 计划外按钮隐藏
    WSHidePlanOrBitLine = 1 << 3,       // 计划外轨迹显示
};




@interface WSFuncsBean_opt : NSObject

@property (nonatomic, readonly, strong) NSString *isPic;
@property (nonatomic, readonly, strong) NSString *isGps;
@property (nonatomic, readonly, strong) NSString *automaticDeparture;
@property (nonatomic, readonly, strong) NSString *typGps;
@property (nonatomic, readonly, strong) NSString *isMemo;
@property (nonatomic, readonly, assign) int numMemo;
@property (nonatomic, readonly, strong) NSString *label;
@property (nonatomic, readonly, strong) NSString *isCode;           //是否进行校验
@property (nonatomic, readonly, strong) NSString *isMore;
@property (nonatomic, readonly, strong) NSString *isScan;
@property (nonatomic, readonly, strong) NSString *isSeq;
@property (nonatomic, readonly, strong) NSString *isAdd;
@property (nonatomic, readonly, strong) NSString *isRedisMoreHome;
@property (nonatomic, readonly, strong) NSString *isAttendance;     //考勤日期样式
@property (nonatomic, readonly, copy)   NSString *isIntentToStore;  //计划内/计划外点击门店时，如果isIntentToStore是Y，则进入分店列表；否则，进入门店拜访项
@property (nonatomic, readonly, strong) NSString *isOpenGeo;        //是否显示搜索框左侧的地理位置店执行动作列表（WorkFlowVC）
@property (nonatomic, strong) NSString *showdetails;                //是否显示详细信息
@property (nonatomic, readonly, strong) NSString *isShortCut;       //门店列表快捷方式新增
@property (nonatomic, readonly, assign) BOOL isUseParentFunc;       //UBOX-121新增及拜访成功后，在客户拜访中不标识该门店 默认时用moudul_fc作为查询条件，只有为1时不去考虑用moudul_FC作为查询条件。
@property (nonatomic, readonly, assign) BOOL isTodayVisit;          //KIMBERYHOS-39【金佰利医渠】拜访计划设置，可以修改当天拜访计划。
@property (nonatomic, readonly, assign) BOOL isHideTitle;
@property (nonatomic, readonly, assign) BOOL isExhibitionNavTitle;  //是否展示导航栏标题(用户WinJSBridgeViewController控制)
@property (nonatomic, readonly, assign) BOOL isShowFootNavigate;    //是否显示Toolbar
@property (nonatomic, readonly, assign) BOOL isQstName;

// 表格左上角名称，同时兼容 title 和 name 两个字段
// Jira: MSTD-131
@property (nonatomic, readonly, strong) NSString *title;
@property (nonatomic, readonly, strong) NSString *name;

@property (nonatomic, readonly, assign)   NSInteger   isSupperLocalPhoto;       //是否支持从本地选择照片(1标示支持从本地读取照片，0标示不支持，默认为0)
@property (nonatomic, readonly, assign)   NSInteger   maxPhoto;                 //可提交的照片最大数量(未指定为0，标示没有限制)
@property (nonatomic, readonly, strong) NSString *isSearchable;          // 是否显示搜索框，新增门店列表
@property (nonatomic, readonly, strong) NSString *storeFiletr;          // 门店维度
@property (nonatomic, readonly, strong) NSString *searchTag;         // 内容为以空格分隔的多个词，手机会在搜索条下方显示每个搜索词
@property (nonatomic, readonly, strong) NSString *searchHint;
@property (nonatomic, readonly, strong) NSString *sendRequest;  // 为适应 Android, 将之前 funcs 下的 sendRequest 改到 opt 下
@property (nonatomic, readonly, strong) NSString *updateMenu;
@property (nonatomic, readonly, strong) NSString *unreadNumFlag;


// 配置短信沟通功能。
@property (nonatomic, copy)NSString *SMS;

@property (nonatomic, strong) NSString      *isReturnHome;      //调查问卷直接返回主页的按钮是否存在，0(不显示),1(显示)，默认为1

// 搜索新增即拜访回显的门店
// 0 匹配门店名字  1匹配门店答案 2匹配门店名字及答案
@property (nonatomic, strong)NSString *searchSource;

//妮维雅首发 opt配置中增加配置参数 needSelect，在只有一级筛选的页面（如：选择系类的页面），配置参数值为1，在有两级筛选的页面（如：先选择品牌，再选择系类的页面），配置参数值为2.
@property (nonatomic,readonly, copy)NSString *needSelect;

@property (nonatomic,readonly, assign) BOOL isMap;
@property (nonatomic,readonly,assign)  BOOL isShowUpdated;
@property (nonatomic,readonly,assign)  BOOL removeDay;

@property (nonatomic,readonly, copy) NSString *parentStoreFc;


//辉瑞ECALL首发：编辑新增的调查问卷时，是否在提交时生成一个新的ID（辉瑞ECALL首次使用，为了完成会议流程的流转，每次更新问卷的状态时，生成一条新的记录，但是所有记录submitId是一样的），"Y":使用新ID
@property (nonatomic,readonly,copy) NSString *isUseNewId;
//辉瑞ECALL首发：是否展示actionTip图标， "Y":展示
@property (nonatomic,readonly,copy) NSString *isShowActionTip;

// 辉瑞ECALL 添加
/*当WSNewStoreListViewController显示回显（新增问卷）的问卷数大于此值，则显示搜索框*/
@property (nonatomic,strong,readonly) NSString *serverCount;

// 辉瑞ECALL 添加
/*对搜索标签的提示字符*/
@property (nonatomic,strong) NSString *searchTagAlert;

/** 箭牌添加
 * 配置在拜访项上，如果visitedFlag为Y，则只要该拜访项拜访过，就代表该门店完成（显示拜访完成的标识）
 **/
@property (nonatomic, readonly, copy) NSString *visitedFlag;
 

/*
   配置新增门店拜访项，是否需要刷新，
 */
@property (nonatomic, copy) NSString *isRefresh;

@property (nonatomic, copy, readonly) NSString *searchQuestion;

@property (nonatomic,copy) NSString *acvtSearch;

//SND-46 【施耐德】手机端显示未读调查问卷条数  是否统计已读-isRead 1
@property (nonatomic, assign) BOOL isRead;

@property (nonatomic, copy) NSString *autoJumpNext;

@property (nonatomic, copy) NSString *autoAddMore;

@property (nonatomic, copy) NSString *deleteButton;/*配置删除按钮（新）*/

/**
 *  施耐德添加，地图是否显示人员位置及轨迹
 */
@property (nonatomic, assign) BOOL isOpenSubTrackMap;

/**
 *  立白添加， 值为@"calendar" 时，显示日历模式
 */
@property (nonatomic,readonly,copy) NSString *addType;

/**
 *  立白添加，新增问卷列表排序方式，1：所有问卷按照原服务器下发顺序排序，0或者不配置：本地操作过的问卷排在前面，如果配置为3 只显示服务器的
 */
@property (nonatomic,readonly,copy) NSString *acvtSort;

@property (nonatomic,readonly,copy) NSString *tagBottom;

/**
 *  聊天增加，是否允许发起聊天
 */
@property (nonatomic,readonly,copy) NSString * isChat;

/**
 *  是否是益海嘉里使用的定制view
 */
@property (nonatomic,readonly,copy) NSString * showStyle;

/**
 *  是否是辉瑞医院门店列表删选条件定制view
 */
@property (nonatomic,readonly,copy) NSString * filterStyle;

/**
 *    SFA 箭牌 WRIGLEY-1702  详情见wiki ：http://wiki.winchannel.net/xwiki/bin/view/交付平台/SFA交付/SFA客户端文档/开发文档/门店详情/导航按钮/   不配正常显示
 */
@property(nonatomic,copy) NSString *naviDis;

@property (nonatomic , copy) NSString *distancesSort ;  // 是否按距离排序 1 按距离排序， 2 按后台下发的顺序排序   默认不排序

@property (nonatomic , copy) NSString *visitTimeSort ;  // 是否按最近拜访时间排序 1排序 默认不排序


@property (nonatomic , copy) NSString *downByMap ;  // 是否启用缓存门店数据  1 启用

@property (nonatomic , copy) NSString *isCountry ;  


@property(nonatomic,copy) NSString *refreshNodeName;

@property (nonatomic , copy) NSString * hidePlanOrbit ; // SFA 项目 SFA-7649 值与对应显示的路线按位与，1代表计划路线隐藏 2代表实际路线隐藏 4 代表计划外路线隐藏    如果三种路线都隐藏 则只显示 全部门店的坐标点，不显示路线

/**
 *  RN模板相关
 */
@property (nonatomic, copy) NSString *rn_iosv;
@property (nonatomic, copy) NSString *rn_formcode;
@property (nonatomic, copy) NSString *rn_androidv;
@property (nonatomic, copy) NSString *rn_url;
@property (nonatomic, copy) NSString *rn_rptcode;

//http://192.168.1.15/jira/browse/MSTD-4015
//判断有准备功能关联弹出框新参数定义为contextMenu
@property(nonatomic,copy) NSString *contextMenu;

//http://192.168.1.15/jira/browse/MSTD-4015
//isTipsmenu这个参数控制是否为提示菜单
@property (nonatomic, copy) NSString *isTipsMenu;


@property (nonatomic, copy) NSString *isOnlySub;

//拜访计划设置做计划日历取值范围
@property (nonatomic, strong) NSString *minWeek;

@property (nonatomic, strong) NSString *maxWeek;

// 门店列表数量是否隐藏
@property (nonatomic , copy) NSString *hideCount;

@property (nonatomic , copy) NSString *isJumpCallPlan;

@property (nonatomic, copy) NSString *prodtrees;

@property (nonatomic, copy) NSString *mapIconType;

@property (nonatomic, strong) NSString *jumpToInput; //跳转新页面填写数据标示("1"为可跳转 其它值忽略)

@property (nonatomic, strong) NSString *searchCondReqNode;

// 如果有值 九宫格模块背景色为此颜色
@property (nonatomic, copy) NSString *menuBgColor;

@property (nonatomic, copy) NSString *gpsCityLevel;

//SFA-13944 SQL 查询需要在名字后面追加的字段
@property (nonatomic, copy) NSString *appendprop;

//MENGNIU-1834 添加产品页面cell是否需要显示底下的展开调查问卷
@property (nonatomic, copy) NSString *hNewStyleProdSelect;

// SFA-16206 菜单需要显示已填写状态
@property (nonatomic, copy) NSString *isShowAlreadyFilledStatus;

// SFA-15154 新增调查问卷是否支持列表删除
@property (nonatomic, readonly, copy) NSString *isAcvtListCanDelete;
// 门店列表使用，用来配置门店列表展示的其他选项 例如，泸州老 窖终端联系人(无小图标)。 SFA-15299 add by zhiqing
@property (nonatomic , copy) NSString *storeListAcvtCode;

//未签退点返回键，取消离店提示信息 leaveStoreTip 为0时不提示
@property (nonatomic, readonly, strong) NSString    *leaveStoreTip;

//返回保存问卷,不需要校验
@property (nonatomic, copy) NSString *isSaveData_back;

// 按钮位置，1 显示在底部，underTitle 显示在标题下
@property (nonatomic, copy, readonly) NSString *uploadInTheFollowing;

// 添加产品页面显示样式 (cell展开是调查问卷配置成：acvtList  展开是安卓华为样式配置成：list  展开是表格样式配置成：grid  不配置默认显示表格样式)
@property (nonatomic, copy) NSString *isAddProductStyle;
// MN-2522 收藏按钮展示风格
@property (nonatomic, copy) NSString *isCollectionStyle;

@property (nonatomic, copy) NSString *followStore;  //关注门店标示(只显示关注门店)
@property (nonatomic, copy) NSString *showSub;      //业代标示(是否显示业代)

// SFA-16705 SFA史克医院：医生分级问卷功能，医院和医生之间需要添加科室  科室是否显示已填写图片
@property (nonatomic, copy) NSString *isHiddenFilledOutStatusImageView;

@property (nonatomic, copy) NSString *addFilterType; // MN-511
@property (nonatomic, copy) NSString *isShowSubArea; // MN-600  是否显示下属区域
@property (nonatomic, copy) NSString *acvtVisitStatus;// MN-2149

@property (nonatomic, copy) NSString *cusMailList;  //SFA-17537
@property (nonatomic, copy) NSString *refresh;      // MN-2821

// SFA-17491 同步安卓添加离店可编辑字段
@property (nonatomic, copy) NSString *leaveModify;

//SFA-16171 列表显示几列 listStyleShowColNum 默认为1列，（“1”就显示1列，“2”就显示2列...）
@property (nonatomic, copy) NSString *listStyleShowColNum;

@property (nonatomic, copy) NSString *batchUpload;  // YIHAIKERRY-1816 Tab 页同时上传

@property (nonatomic, copy) NSString *uploadStyle;  // YIHAIKERRY-2364 上传按钮样式

@property (nonatomic, assign) BOOL isCurrentGeo;

@property (nonatomic, copy) NSString *hiddenCode; //隐藏编码 SFA-19954

@property (nonatomic, assign) BOOL isSetFocus; // SFA-20258 设置编辑框焦点

@property (nonatomic, copy) NSString *loginUrl;         //登陆url
@property (nonatomic, copy) NSString *password;         //密码
@property (nonatomic, copy) NSString *passwordEncrypt;  //密码加密
@property (nonatomic, copy) NSString *username;         //用户名

@property (nonatomic, strong) NSString *moreProdType;
@property (nonatomic, copy) NSString *backDialog_tip; //问卷返回时是否有上传选项
@property (nonatomic, copy) NSString *uploadDialog_tip; //上传问卷时提示
@property (nonatomic, copy) NSString *notReqCheck_tip;  //非必填验证提示
@property (nonatomic, copy) NSString *nextAcvtNode; //跳转到下一级的问卷节点

@property (nonatomic, copy) NSString *isUploadCheckReplace; //MN-3248 是否上传检查替换标示

@property (nonatomic, copy) NSString *downloadInfoNum; //益海嘉里200家门店新需求，下载门店详情的最大数量
@property (nonatomic, copy) NSString *leaveStoreTipFunc; //益海嘉里200家门店新需求,签退时，需要提示的菜单的编码。
@property (nonatomic, assign) NSInteger requestTimeout; // YIHAIKERRY-3586 请求超时时间

@property (nonatomic, copy) NSString *isUpdateStoreIcon; //YIHAIKERRY-2279 SFA益海嘉里【门店信息】修改门头照需求
@property (nonatomic, copy) NSString *needRepeatProd; // YIHAIKERRY-3512 益海嘉里允许表格里添加相同产品

@property (nonatomic, copy) NSString *checkCallingStore;
@property (nonatomic, copy) NSString *leaveTipFlag; // YIHAIKERRY-4192 离店提示

@property (nonatomic, copy) NSString *isVisitCompleteModuleReadonlyTip; //是否显示拜访完成模块只读提示开关
@property (nonatomic, copy) NSString *prodtree_checked_name; //快捷选择产品列

@property (nonatomic, copy) NSString *isNeedShowStoreName; //SFA-24536 判断门店信息是否显示

@property (nonatomic, assign) BOOL isCancelSearchCode; //是否取消79码搜索条件

@property (nonatomic, copy) NSString *subTitleBgColor; // 代表副标题背景色

//促销详情 SFA-24274 SFA立白【经销商】订单-添加产品促销活动信息显示需求
@property (nonatomic, copy) NSString *remoteOrderProductInfo; // 判断添加产品页面的促销详情按钮是否显示

@property (nonatomic, copy) NSString *customFormatImgName;  //YIHAIKERRY-4758 是否上传照片特殊命名标示

@property (nonatomic, assign) BOOL isBranchStoreDownload;//是否是分公司门店下载

@property (nonatomic, copy) NSString *isNeedBack;//是否需要返回上一级

@property (nonatomic, copy) NSString *imgCompress;      //图片压缩比
@property (nonatomic, copy) NSString *imgShootWidth;    //图片宽度
@property (nonatomic, copy) NSString *imgCompress_iOS;  //图片压缩比(iOS专属)
@property (nonatomic, copy) NSString *imgShootWidth_iOS;//图片宽度(iOS专属)
@property (nonatomic, copy) NSString *isSrid;
@property (nonatomic, copy) NSString *isSingleQstToAutoJump;//问卷中只有一个问题时，能跳转的话，自动跳转进去
@property (nonatomic, copy) NSString *isCheckEnterStore;    //是否检查进店
@property (nonatomic, copy) NSString *isCheckPushView;      //是否检查推出视图

@property (nonatomic, copy) NSString * isCurrEmpId;///<是否取用户empid

@property (nonatomic, copy) NSString * resourceForm;///<角色判断 PCH'的时候走3.0的，resourceForm='TSKF'的走之前2.0的,空也走2.0逻辑

@property (nonatomic, copy) NSString * showReqTips;///<1代表显示显示弹框  0不显示

///路线管理的门店列表
@property (nonatomic, copy) NSString *routeVisitFC;
@property (nonatomic, copy) NSString *independentShowSub;   //独立展示子系统标识
@property (nonatomic, copy) NSString *jumpUrlLink;          //跳转url链接
@property (nonatomic, copy) NSString *routeSearchurl;       //跳转路线查询url链接
@property (nonatomic, copy) NSString *addRouteUrl;          //跳转路线新增url链接
@property (nonatomic, copy) NSString *batchModifyUrl;       //跳转路线修改url链接
@property (nonatomic, copy) NSString *visitMax;             //门店拜访次数限制
@property (nonatomic, copy) NSString *jumpStoreInfoUrl;     //跳转门店信息卡url
@property (nonatomic, copy) NSString *webBackUpdateJS;      //网页返回更新js
@property (nonatomic, copy) NSString *saveNode;             //保存数据节点

@property (nonatomic, copy) NSString *isReminderVisit;      //是否提醒拜访(针对门店列表点击)
@property (nonatomic, copy) NSString *isReminderOperate;    //是否提醒操作(针对门店列表点击)

///否按回显数据排列：mOrderByDis  "1"按回显数据排列
@property (nonatomic, readonly, strong) NSString *mOrderByDis;

/// 是否弹出来位置隐私协议弹框
@property (nonatomic, copy) NSString * jumpPrivacyAgreement;

///助销菜单
@property (nonatomic, copy) NSString * salesAssistanceMenu;

@property (nonatomic, copy) NSString * isUseNewPage;
@property (nonatomic, copy) NSString *isBackgroundCache;    //是否后台缓存标识("1"为开启)

///建议订单弹框请求
@property (nonatomic, copy)  NSString * suggestOrderNode;
///是否隐藏返回按钮  1为隐藏  0为不隐藏
@property (nonatomic, copy) NSString * isHiddenBack;
/// POSM type
@property (nonatomic, copy) NSString * funcTipType;


- (id)initFuncs_optWithObject:(id)object;

@end

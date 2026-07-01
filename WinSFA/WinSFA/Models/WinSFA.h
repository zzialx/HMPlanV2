//
//  WinSFA.h
//  WinChannelIPhone
//
//  Created by Chen Angus on 11-7-19.
//  Copyright 2011年 dumbrock. All rights reserved.
//

#ifndef WinChannelIPhone_WinchannelIPhone_h
#define WinChannelIPhone_WinchannelIPhone_h
#pragma mark -notify


// 定义这个常量，就可以不用在开发过程中使用"mas_"前缀。
//MSTD-7772 po控制台冲突
//#define MAS_SHORTHAND
// 定义这个常量，就可以让Masonry帮我们自动把基础数据类型的数据，自动装箱为对象类型。
#define MAS_SHORTHAND_GLOBALS
#import "Masonry.h"

#define OpenAppByOtherApps @"openByOtherApps"

#define NOTYFY_PHOTO    @ "photo"
#define LEAVESTORE      @ "leaveStore"
#define MESSAGE         @ "message"
#define ACVTVIEW        @ "acvt"

#pragma mark -loginViewController

#define USERNAME            @"username"
#define PASSWORD            @"password"
#define AUTHORIZATIONCODE   @"authorizationCode"
#define SSOUSERNAME         @"ssoUserName"
#define SSOCODE             @"ssocode"
#define SSOLOGINSTATE       @"ssoLoginState"

#define USERNAME_BEGIN_LOGIN    @"USERNAME_BEGIN_LOGIN"

/*区别于PASSWORD   解决当登陆开始时如果没有配置记住密码，则NSUserDefaults中以PASSWORD为key值remove掉,下拉刷新取密码值错误问题*/
#define PASSWORD_FOR_CACHE_DATA_VERSION @"password_for_cache_data_version"


#define USERNAME_CALL_APP    @ "usernameForCallingApp"
#define PASSWORD_CALL_APP     @ "passwordForCallingApp"

#define USERNAME_LAST_LOGIN    @ "USERNAME_LAST_LOGIN"
#define PASSWORD_LAST_LOGIN    @ "PASSWORD_LAST_LOGIN"

// YIHAIKERRY-1231 记录手势密码正确与否的状态
#define SWIPE_PASSWORD_IS_RIGHT        @"SwipePasswordIsRight"

#define IS_IN_OFFLINE_LOGIN     @ "IS_IN_OFFLINE_LOGIN"

#define LOGIN_CONFIG_PARAMS     @"loginConfigParams"

#define SELECTED_CITY_NAME      @"selected_cityName"

#pragma mark  -网络地址方法

#define kSFANaviFileUrl @"http://go.winmdm.com/2013/sfai_winchannel.jpg"

#define SERVERURL       @ "serverURL"

#define NT_EXPECTION    @ "exceptionNotify"

#pragma mark  -网络访问notification
    // notifiction name
#define LOGINSUCCESS    @ "loginSuccess"
#define REQUESTSUCCESS  @ "requestSuccess"
#define REQUESTFAILED   @ "requestFailed"
#define REQUESTCANCEL   @ "requestCancel"
#define REQUESTFINISHED @ "requestFinished"
#define ERROR           @ "error"
#define LOGOUT          @ "exit_account"

#define CNY_ACTIVITY_NOT    @"CNY_ACTIVITY_NOT"

#define ALERT_UNLEAVED_STORE    @ "ALERT_UNLEAVED_STORE"
#define ALERT_UNUPLOADDATA_COUNT @"ALERT_UNUPLOADDATA_COUNT"
#define AUTOMATIC_DEPARTURE    @ "AUTOMATIC_DEPARTURE"
#define END_STORE         @ "END_STORE"
#define AUTO_END_STORE    @ "AUTO_END_STORE"
#define JUMP_CHAT_NOTIFI  @"JUMP_CHAT_NOTIFI"


#pragma mark -数据结构单节点

#define DATAS                   @"datas"
#define APPDATA_BIZDATE         @"bizDate"
#define APPDATA_TASKINFO        @"taskInfo"
#define APPDATA_MAIL_LIST       @"mailList"
#define APPDATA_CUS_MAIL_LIST   @"cusMailList"
#define APPDATA_EMPID           @"empid"
#define APPDATA_EMPIDBIGI       @"empId"
#define APPDATA_TIMEMS          @"timems"
#define APPDATA_OBJID           @"objId"
#define APPDATA_KEYWORD         @"keyWord"
#define APPDATA_EMPNAME         @"empName"
#define APPDATA_LOGINTIME       @"logintime"
#define APPDATA_LOCALOBJECTKEY  @"appLocalObjectKey"
#define APPDATA_TIME_UPDATE     @"timeUpdate"
#define APPDATA_UPDATEURL       @"updateurl" // 旧的用于生成下载本app的二维码的url
#define APPDATA_QR_URL          @"appUrl"   // 新的用于生成下载本app的二维码的url,
#define APPDATA_SIGNKEY         @"securityKey"
#define APPDATA_WELCOME_SKIP_TIME   @"WELCOMEPAGE_SKIP_TIME" // 欢迎页跳过时间
#define SERVERREQUIRE           @"serverRequire"
//登陆数据版本串 MSTD-717 2014-09-15
#define CACHE_DATA_VERSION_NODE    @"cacheDataVersion"
#define APPDATA_LOGIN_REDIRECT_FC  @"loginRedirectFc"
#define APPDATA_LOGIN_REDIRECT_FC_CACHE @"loginRedirectFcCache"
#define ROUTE_PLAN_ID  @"routePlanId" //SFA-13481  路线计划的id
#define APPDATA_EXTRA_REMINDER_NODE_NAME @"extraReminderNodeName"   //额外提醒节点名称
#define APPDATA_EXTRA_REMINDER_NODE_NAME_KEY @"activityNotic"       //额外提醒节点名称key
#define NEED_SEARCH_PROD_RECORD @"NEED_SEARCH_PROD_RECORD"          //需要检索记录标示

// prodspecdis 用来区别：非分销且要在分销产品页面中回显的产品 所属的拜访项
// prodspec 分销规则
#define PRODSPEC                @ "prodspec"            //
#define PRODSPECDIS             @ "prodspecdis"         //
#define STOREPRODDIS            @ "storeproddis"        // prod表回显
#define STOREDICTDIS            @ "storedictdis"        // 字典表回显数据排列
#define STOREACVTDIS            @ "storeacvtdis"        // acvt回显 storeacvtdis

#define STOREACVTDIS_STORE      @ "storeacvtdis:store"  // storeacvtdis:store 对storeacvtdis的扩展
#define STORES                  @ "stores"
#define STORES_SUBEMPINSTORE    @"stores:subempoutstores"
#define STORES_SUBEMPOUTSTORE   @"stores:subempinstores"
#define STORE_INFO              @"storeInfo"
#define STORES_OVERLAY              @"stores:overlay"
#define LOGIN_TIP               @"loginTip"

#define INSTOREPROD             @ "instoreprod"         // 计划内分销规则
#define OUTSTOREPROD            @ "outstoreprod"        // 计划外分销规则
#define FORCEEXITTIME           @ "forceExitTime"
#define SUBEMPTASK              @ "subemptask"
#define TASKREMIND              @ "taskRemind"
#define ACVTDIS                 @ "acvtdis" // 回显新增不拜访调查问卷数据的节点
#define ACVTDIS_SPESTORE_UPDATAEECHO              @ "acvtdisSpestoreUpdateEcho" // 回显史克
#define STORE_MSG               @ "storemsg" //门店和消息的关联表
#define ACVTDIS_BSC             @ "acvtdis:bsc"

#define STOREACVTDIS_VISITPLAN  @ "storeacvtdis:visitplan" //  拜访计划
#define STOREACVTDIS_NEWSTOREID @ "newStoreId"  
#define STORE_ACVT_RELATION     @ "store_acvt"    //门店-acvt关系
#define STORE_DICTS_RELATION    @ "store_dicts"    //门店-DICTS关系
#define STORE_DICTS_RELATION_NEW    @ "storeDicts"    //门店-DICTS关系
#define ORG_RELATION            @"orgRelation"


#define STORES_SUBEMP_ORG_TREE   @ "subempstore:orgTree" // 组织树层结构

#define PRODUCT_VALIDATE         @ "productValidate"  //箭牌用来校验产品的数据

#define VISITED_MENU             @ "visitedMenu"  //箭牌用来标识一个门店下的某个菜单已上传过数据

#define EDITABLE_ACVTQST         @ "editableAcvtQst" //施耐德用于标记从哪个问题开始

#define IS_LOGIN_EASEMOB         @ "is_login_easemob"  //施耐德，是否需要登录环信

#define REDIS_DATA         @ "REDIS_DATA"  //调差问卷显示回显的提示语  MSTD-3313  CLONE - SFA项目-回显数据添加提醒

#define STORE_TIPS_INFO         @"STORE_TIPS_INFO"  // 门店提示信息，值为 fc,acvtcode,qstcode SFA-15017

#define SEARCH_STORE_RANGE @"SEARCH_STORE_RANGE" //搜索存储范围 YIHAIKERRY-2888 默认2500米



#define SPE_FUMEITI        @"spe_fumeiti"

#define STORES_SELECT           @"stores:storeselect"

#define ACVTINFO                @"acvtinfo"
#define ACVT                    @"acvt"

#define STORE_DISTRULE          @"store_distrule"

#define CALENDAR_ALARM          @"calendarAlarm"
#define STORE_CHANNEL_TYPE      @"storeChannelType"
#define FUNC_TIP                @"funcTip"
#define FUNC_Count_TIP          @"fcCountTip"
#define FUNC_TIP_DIS            @"funcTip:"
#define FUNC_TIP_POSM           @"funcTip:posm"

#define PRODUNIT                    @"prodUnit"
#define PROMOTION                   @"promotion"
#define PROMOTION_PINFO             @"promotion:pinfo"
#define PROMOTION_STORE             @"promotion:store"
#define SPE_ROUTE                   @"spe_route"
#define SUBMENUIMG                  @"subMenuImg"
#define SUBMENUIMGCOORDINATE        @"subMenuImgCoordinate"
#define EMPLOYEEINFORMATION         @"employeeinformation"
#define ELECTRONICMEMO              @"electronicMemo"
#define PRODUCT_COL                 @"productcol"
#define PRODUCT_COL_STORE           @"productcol:stores"
#define STORE_FILTER                @"store_filter"
#define EMP_AREA                    @"emp_area"
#define EMP_ORG                     @"emp_org"
#define STRPTYPDST                  @"strptypdst"
#define PRODPRICE                   @"prodprice"

#define PROD_SPEC_IMG               @"prodspec_img"
#define STORE_NOT_REQUEST           @"storeNotRequest"
#define STORE_PROD_RELATION_SHIP    @"prodRelationship"
#define STORE_UPDATE_FLAG           @"storeUpdateFlag"
#define STORE_ROUTE_VISIT_STATE     @"storeRouteVisitState"

static const  NSInteger  WSACVTDIS_P_Componet_count = 3;

// 辉瑞系列 考勤模块 查看考勤记录功能 数据节点
#define  DUTY_ATTENDANCEDETAIL  @"attendancedetail"
//sanofi 考勤模块 查看已设置的考勤计划
#define  DUTY_OTHERSATTENDANCE  @"othersAttendance"

//是否支持本地选择时间
#define BASE_DATA_ENTRY         @"dataEntry"
#define EMPID                   @"empId"
#define ALLOWED_PERIOD          @"allowedPeriod"        //允许的时间段（djf，-(负数)代表向前时间范围，（正数)代表向后时间范围）

#define GEOVERSION                  @"geoVersion"
#define GEOVERSIONVERSIONID         @"VersionId"

#pragma mark  -数据结构Acvt
#define ACVT_ID                 @ "acvtId"
#define ACVT_CODE               @ "acvtCode"
#define ACVT_NAME               @ "acvtName"
#define ACVT_OBJ                @ "acvtObj"
#define ACVT_EMPID              @ "empId"
#define ACVT_QST                @ "qst"
#define ACVT_IS_BLOCK           @ "isblock"         //Note： 是否为同步请求标识（djf）
#define ACVT_MEMO               @ "memo"
#define ACVT_GENID              @ "gen_id"
#define ACVT_ISREQ              @"isReq"


#define ACVT_QSTID              @ "qstId"
#define ACVT_QSTCOD             @ "qstCod"
#define ACVT_DLEN               @ "dlen"
#define ACVT_MLEN               @ "mlen"
#define ACVT_MNUM               @ "mnum"
#define ACVT_OPT                @ "opt"
#define ACVT_OPTID              @ "optId"
#define ACVT_OPTNAME            @ "optName"
#define ACVT_OPTPIC             @ "optPic"
#define ACVT_QSTTYPE            @ "qstType"
#define ACVT_ALIGN              @"align"

#define ACVT_TYP                @ "typ"
#define ACVT_DATE_TYP           @ "dateTyp"
#define ACVT_PUBLISHER          @ "publisher"

#define ACVT_STATE              @ "state"

#define ACVT_QST_ISREQ          @"is_req"
#define ACVT_QSTDESC            @ "qstDesc"
#define ACVT_QSTNAME            @ "qstName"
#define ACVT_QSTTYPE            @ "qstType"
#define ACVT_SNUM               @ "snum"
#define ACVT_QST_isSupperLocalPhoto    @"isSupperLocalPhoto"
#define ACVT_QST_maxPhoto              @"maxPhoto"
#define ACVT_QST_ISHIDDEN       @"ishidden"
// lua调用新增门店 "立即拜访" 和 "删除门店" 按钮点击事情的字段
#define ACVT_QST_SCRIPT         @"script"
#define ACVT_QST_JS             @"Js"
#define ACVT_QST_ORIENTATION    @"orientation"  // 标题与UI控件是否上下显示
#define ACVT_QST_HINT           @"hint"
#define ACVT_QST_ICONURL        @"qstIconUrl"
#define ACVT_QST_COUNTRULE      @"countrule"
#define ACVT_QST_TAB            @"tab"
#define ACVT_QST_HIDEQSTNAME    @"hideQstName"
#define ACVT_QST_HIDEQSTOPTNAME @"hideQstOptName"
#define ACVT_QST_REG            @"reg"
#define ACVT_QST_DISPLAYMODE    @"displayMode"
#define ACVT_QST_HIDE_BOTTOM_LINE @"hiddenbuttomline"
#define ACVT_QST_WIDTH_PERCENT    @"widthPercent"
#define ACVT_QST_IS_COVER_NEW_ID  @"isCoverNewId"
#define ACVT_QST_LOCATION_TYPE  @"locationType"
#define ACVT_QST_colKey  @"colKey"
#define ACVT_QST_VERTICAL_GROUP_NAME    @"verticalGroupName"
#define ACVT_QST_LAYOUT_GRAVITY  @"layout_gravity"


#define ACVT_QST_TITLE_READ_COLOR  @"titleReadColor"
#define ACVT_QST_VALUE_READ_COLOR  @"valueReadColor"
#define ACVT_QST_VALUE_COLOR  @"valueColor"
#define ACVT_QST_TITLE_SIZE  @"titleSize"
#define ACVT_QST_VALUE_SIZE  @"valueSize"
#define ACVT_QST_DEPENDON  @"dependon"


#define ACVT_FTEXT              @"ftext"       //FUNCTION TEXT
#define ACVT_MC                 @ "mc"
#define ACVT_RANGE              @ "ranges"
#define ACVT_FUNC               @ "func"
#define ACVT_DDS                @ "dds"

#define ACVT_RANGE2             @ "ranges2"
#define ACVT_FUNC2              @ "func2"
#define ACVT_DDS2               @ "dds2"

#define ACVT_FILTER             @ "filter"
#define ACVT_CHECKTYPE          @ "checkType"
#define ACVT_READONLY           @ "readonly"
#define ACVT_ORIGINALACVTID     @ "originalAcvtId"
#define ACVT_GROUPNAME          @ "groupName"
#define ACVT_PARENT             @ "parent"
#define ACVT_PARENT_QST_ID      @ "parentQstId"
#define ACVT_ACVTQSTID          @ "acvtQstId"
#define ACVT_ACVTDS             @ "ds"
#define IS_ACVT_NAME            @"isAcvtName"
#define ACVT_QST_AlertTitle     @ "alertTitle"

#define ACVT_QST_MEMO           @"memo"
#define ACVT_QST_MEMO1          @"memo1"
#define ACVT_QST_MEMO2          @"memo2"
#define ACVT_QST_MEMO3          @"memo3"
#define ACVT_QST_MEMO4          @"memo4"
#define ACVT_QST_CHARNUM        @"charNum"
#define ACVT_ACVTNESTEDID       @ "acvtNestedId"
#define ACVT_COLOR              @ "color"
#define ACVT_BGCOLOR            @ "bgColor"
#define ACVT_QST_IS_NOT_WATER_MARK           @"is_not_water_mark"

#define QST_DEFAULTVALUE        @"defaultValue"

#define QST_TYPE_AC             @ "AC"           ///验证码
#define QST_TYPE_C              @ "C"           ///check，多选
#define QST_TYPE_CN             @ "CN"       // C,R 类型没有title其他都一样
#define QST_TYPE_CE             @ "CE"      // 带展开收起选项的多选框，其他都一样
#define QST_TYPE_R              @ "R"      ///radio，单选
#define QST_TYPE_P              @ "P"     ///拍照
#define QST_TYPE_DP             @ "DP"     ///网咯图片
#define QST_TYPE_N              @ "N"  // 数值
#define QST_TYPE_NR             @ "NR"      // 数值，带校验规则
#define QST_TYPE_L              @ "L"     ///纯label
#define QST_TYPE_LT             @ "LT"      // 文本描述
#define QST_TYPE_T              @ "T"    ///textfield，显示文字，字母，数字
#define QST_TYPE_TV             @ "TV"                                     ///没对应创建，垃圾
#define QST_TYPE_W              @ "W"    ///显示时间的label
#define QST_TYPE_GG             @ "GG"  //GPS隐藏
#define QST_TYPE_GF             @ "GF"  //GPS显示
#define QST_TYPE_SCAN           @ "B"       //条形码（同下，这个是旧字段，不确定是否要删除。）
#define QST_TYPE_I              @ "I"       //二维码按钮
#define QST_TYPE_V              @ "V"     ///视频播放
#define QST_TYPE_D              @ "D"       //日期类型
#define QST_TYPE_DT             @ "DT"       //时间控件类型
#define QST_TYPE_DTT             @ "DTT"       //开始结束时间控件类型
#define QST_TYPE_WF             @"WF"         ///时间选择，点击
#define QST_TYPE_GE             @"GE"       ///联动选择，地理位置
#define QST_TYPE_SS             @"SS"      //弹出框单选
#define QST_TYPE_PT             @"PT"     ///照片展示
#define QST_TYPE_SED            @"SE"     //开始结束日期控件
#define QST_TYPE_TB             @"TB"      // ACVT 中表格
#define QST_TYPE_RD             @"RD"      //单选，从dicts中过滤数据
#define QST_TYPE_CD             @"CD"      //从dicts中取数据
#define QST_TYPE_SM             @"SM"       //下拉框多选
#define QST_TYPE_DM             @"DM"       //下拉框多选，从dicts中取数据
#define QST_TYPE_DV             @"DV"      //新增类型，支持多级联动的下拉框
#define QST_TYPE_RB             @"RB"      //星级评价
#define QST_TYPE_PI             @"PI"      //pushinfo信息显示 中粮方便面【试吃活动】首发 ZLFBM-13
#define QST_TYPE_PA             @"PA"      //图片 : 门店拜访->会员注册->新增会员首发.
#define QST_TYPE_M              @"M"       //手机号输入文本 : 门店拜访->会员注册->新增会员首发.
#define QST_TYPE_AN             @"AN"      //调查问卷中内嵌问卷
#define QST_TYPE_ANX            @"ANX"     //嵌套问卷 （对店的）

#define QST_TYPE_MI             @"MI"      //多手机号码
#define QST_TYPE_BTN            @"BN"     //"删除门店"和"新增即拜访"用到的类型(lua调用按钮的点击事件).
#define QST_TYPE_PE             @"PE"     //拍照可编辑
#define QST_TYPE_LC             @"LC"     //文档类型，多媒体列表
#define QST_TYPE_DA             @"DA"     //

#define QST_TYPE_RA             @"RA"     //下拉问卷嵌套列表
#define QST_TYPE_DA             @"DA"     //选人

#define QST_TYPE_BN             @"BN"     //选人

#define QST_TYPE_TA              @"TA"

#define QST_TYPE_AM              @"AM"

#define QST_TYPE_ST              @"ST"

#define QST_TYPE_UR              @"UR"

#define QST_TYPE_GS              @ "GS"     ///签名

#define QST_TYPE_ICO              @ "ICO"     ///头像

#define QST_TYPE_BQ              @"BQ"      // 空白问题
#define QST_TYPE_BO              @"BO"      // 空白问题，兼容安卓
#define QST_TYPE_NFC             @"NFC"
#define QST_TYPE_YM              @"YM"
#define QST_TYPE_RP              @"RP"      // 手动获取GPS信息
#define QST_TYPE_SB              @"SB"      // 滑杆
#define QST_TYPE_IR              @"IR"      // 范围

#define QST_AUXILIARY_INPUT @"add_sub" //辅助输入(输入框两侧是否存在+-号操作)

#define QST_DISPLAYMODE_SMALL       @"small"    // 用于设置较小字体
#define QST_DISPLAYMODE_QUARTILE    @"quartile" // 千分位
#define QST_DISPLAYMODE_BN          @"BN"       // 按钮样式
#define QST_DISPLAYMODE_MULTIMENU   @"useMultilevelMenu"
#define QST_DISPLAYMODE_LABEL       @"label"    // 按钮样式，和 BN 的区别是按钮宽度是自适应的（安卓定义的名称）
#define QST_DISPLAYMODE_CENTER      @"center"
#define QST_DISPLAYMODE_HORIZONTAL_SCROLL     @"hScroll" // 水平滚动显示模式
#define QST_DISPLAYMODE_ROW_LIST_VERTICAL     @"isRowListVertical" //表格列表垂直模式

#pragma mark -数据结构Prod

#define PRODS_BRAND     @ "brand"

#define PRODS_SERIES    @"series"

#define PRODS_COD       @ "cod"
#define PRODS_ID        @ "id"
#define PRODS_NAME      @ "name"
#define PRODS_PTYP      @ "pTyp"
#define PRODS_SEARCHCOD @ "searchcod"
#define PRODS_URL       @ "url"
#define PRODS_REALTIME_IMG_URL       @ "IMG_URL"
#define PRODS_BRANDTYPE @ "brandType" //品牌类别中粮稽核使用 用作filter
#define PRODS_MEMO5     @ "memo5"       // 中粮稽核用于产品校验时过滤产品
#define PRODS_PRODNAME  @ "prodName"
#define PRODS_BRANDNAME @ "brandname" //中绿品牌字段
#define PRODS_PRICE @ "price"
#define PRODS_MEMO      @ "memo"
#define PRODS_MEMO1     @ "memo1"
#define PRODS_MEMO2     @ "memo2"
#define PRODS_MEMO3     @ "memo3"
#define PRODS_MEMO4     @ "memo4"
#define PRODS_MEMO6     @ "memo6"
#define PRODS_MEMO7     @ "memo7"
#define PRODS_MEMO8     @ "memo8"
#define PRODS_MEMO9     @ "memo9"
#define PRODS_MEMO10    @ "memo10"
#define PRODS_BARCOD    @ "barcod"
#define PRODS_BARCODE   @ "barcode"
#define PRODS_BARCODE2  @ "barcode2"
#define PRODS_TREES   @ "prodtrees"
#define PRODS_PINYIN    @ "pinyin"
#define PRODS_EXPIRYDATE @"expirydate"
#define PRODS_BIGAGE    @"bigage"

#pragma mark -数据结构Msg
#define MSGS_COD        @ "cod"
#define MSGS_EMPID      @ "empId"
#define MSGS_ID         @ "id"
#define MSGS_K          @ "k"
#define MSGS_NAME       @ "name"
#define MSGS_ICON_URL   @ "icon_url"
#define MSGS_MSG        @ "msg"
    // add url 2012-03-23 yanguoshuai
#define MSGS_URL        @ "url"

#define MSGS_CONT       @ "cont"
#define MSGS_ISREAD     @ "isread"
#define MSGS_PID        @ "pid"
#define MSGS_PUBDATA    @ "pubdate"
#define MSGS_S          @ "s"
#define MSGS_TITLE      @ "title"
#define MSGS_TYPCODE    @ "typcode"
#define MSGS_ACVTID     @ "ACVT_ID"
#define MSGS_FILEURL    @"fileurl"
#define MSGS_FILENAME   @"filename"
#define MSGS_VISIT_ADDRESS   @"visit_address"
#define MSGS_HEADRAIL   @"headRail"
#define MSGS_PINYIN     @"pinyin"
#define MSGS_STORE_ID   @"store_id"



#pragma mark -数据结构Dict

#define DICTS_ID    @ "id"
#define DICTS_DTYP  @ "dtyp"
#define DICTS_BTYP  @ "btyp"
#define DICTS_NAME  @ "name"
#define DICTS_COD  @ "cod"
#define DICTS_P     @ "p"
#define DICTS_TYP   @ "typ"
#define DICTS_FL    @"fl"
#define DICTS_SEQ    @"SEQ"
#define DICTS_LEVEL_CODE    @"levelCode"
#define DICTS_ICON_URL    @"iconUrl"
#define DICTS_DICTS_SEQENCE    @"dicts_sequence"

#pragma mark -数据结构Prom

#define PROMS_EFRDAT    @ "efrdat"
#define PROMS_EFTDAT    @ "eftdat"
#define PROMS_EMPID     @ "empId"
#define PROMS_ID        @ "id"
#define PROMS_NAME      @ "name"
#define PROMS_OPT       @ "opt"
#define PROMS_OPT_PID   @ "pid"
#define PROMS_OPT_QID   @ "qid"

#pragma mark -数据结构Store
#define Store_GEO           @"geo"

#define Store_id            @"id"
#define Store_drId          @"drId" //门店组的id
#define Store_sid           @"sid"
#define Store_parentsid     @"parentsid"
#define Store_n             @"n"
#define Store_name          @"name"
#define Store_cod           @"cod"
#define Store_genid         @"acvt_genId"

#define Store_isPlaned      @"isPlaned"
#define Store_pid           @"pid"
#define Store_cellid        @"cl"
#define Store_empId         @"empId"
#define Store_procTypId     @"procTypId"
#define Store_typ           @"styp"
#define Store_addr          @"addr"
#define Store_lat           @"lat"// 门店纬度
#define Store_lon           @"lon"// 门店经度
#define Store_detail_info   @"detail_info"// SND-47【施耐德】工程师地图--stores:emploc中添加子节点detail_info，值为1点显示红色，否则显示蓝色
#define Store_seq           @"seq"
#define Store_phone         @"phone"
#define Store_storeprod     @"storeprod"
#define Store_proms         @"proms"
#define Store_acvts         @"acvts"
#define Store_compt         @"compt"
#define Store_prods         @"prods"
#define Store_acvt          @"acvt"
#define Store_styp          @"styp"
#define Store_t9            @"t9"
#define Store_linkman       @"linkman"
#define Storelinktel        @"linktel"
#define Store_hos           @"hos"
#define Store_payDisplay    @"payDisplay"
#define Store_sv            @"sv"
#define Store_cl            @"cl"
#define Store_in            @"in"
#define Store_bfnum         @"bfnum"
#define Store_sfnum         @"sfnum"
#define Store_beacon_uuid   @"beacon_uuid"
#define Store_srid          @"srid"
#define Store_miniumalDuration  @"miniumalDuration"
#define Store_filter  @"storesFilter"
#define Store_item_name @"item_name"
#define Store_departmentId @"department_id"
#define Store_last_man @"last_man"
#define Store_last_date @"last_date"
#define Store_last_num_q @"last_num_q"
#define Store_last_transaction @"last_transaction"
#define Store_follow @"follow"
#define Store_qrcode @"qrcode"
#define Store_distance @"distances"
#define Store_cityId @"cityId"
#define Store_ctyp  @"ctyp"
#define Store_custCode @"custCode"
#define Store_orgId  @"orgId"

#define Store_row_number @"row_number"
#define Store_img           @"storeImg"
// 添加AppConfig节点 by yanguoshuai at 2012－04－16
#pragma Mark -数据结构AppConfig

#define APPCONFIG                   @ "AppConfig"
#define APPCONFIG_EMPID             @ "empId"
#define APPCONFIG_INFOBK            @ "InfoBk"
#define APPCONFIG_COLOR             @ "Color"
#define APPCONFIG_PUSH              @ "Push"
#define APPCONFIG_APP               @ "App"
#define APPCONFIG_SENSOR            @ "Sensor"
#define APPCONFIG_LOG               @ "Log"
#define APPCONFIG_APPINFO           @ "AppInfo"
#define APPCONFIG_CALLHIST          @ "CallHist"
#define APPCONFIG_ADDRBOOK          @ "AddrBook"
#define APPCONFIG_SMSBK             @ "SmsBK"
#define APPCONFIG_TEXTVIEW_COLOR    @ "TEXTVIEW_COLOR"
#define APPCONFIG_CHECKBOX_COLOR    @ "CHECKBOX_COLOR"
#define APPCONFIG_GALLERY_COLOR     @ "GALLERY_COLOR"
#define APPCONFIG_LISTVIEW_COLOR    @ "LISTVIEW_COLOR"
#define APPCONFIG_RADIOBUTTON_COLOR @ "RADIOBUTTON_COLOR"
#define APPCONFIG_Y                 @ "Y"
#define APPCONFIG_U                 @ "U"
#define APPCONFIG_D                 @ "D"
#define APPCONFIG_APP_VALUE         @ "value"
#define APPCONFIG_SENSOR_VALUE      @ "value"
#define APPCONFIG_LOG_VALUE         @ "value"

#define UNLEAVED_STORE              @"UNLEAVED_STORE"
#define UNUPLOAD_DATA_COUNT               @"UNUPLOAD_DATA_COUNT"

#pragma mark -数据结构Funcs

// 凡是fv以"TB_开头的资源一律认为是主页显示的资源
#define FUNCS_FV_HAS_TB     @"TB_"
#define FUNCS_FV_HAS_TAB     @"TAB_"
#define FUNCS               @ "funcs"
// 在funcs2数组中,若funcs02的fk等于funcs01的pk
// 则认为 funcs02 为funcs01的子节点
#define FUNCS2              @"funcs2"
#define FUNCS_FK            @"fk"
#define FUNCS_PK            @"pk"
#define PSW_VALID_DAY_MSG   @"pswValidDayMsg"
#define MENUACVTLISTFLAG    @"menuAcvtListFlag"
#define MENUACVTLISTFLAGECHO   @"menuAcvtListFlagEcho"
#define VISITPRIVACYPOLOCY     @"visitPrivacyPolicy"
#define VISITPRIVACYFLAG       @"visitPrivacyPolicyFlag"
#define VISITPRIVACYMESSAGE    @"visitPrivacyPolicyMessage"
#define VISITPRIVACYVERRSION   @"visitPrivacyPolicyVERSION"
#define SUGGEST_ORDER_KEY      @"suggestOrder"
#define STOCK_OUT_KEY          @"stockOutKey"


#define FUNCS_FC            @ "fc"
#define FUNCS_NAME          @ "name"
#define FUNCS_FV            @ "fv"
#define FUNCS_SPEC          @ "spec"
#define FUNCS_FUNCS         @ "funcs"
#define FUNCS_READONLY      @ "readonly"            /**限制此界面为只读*/
#define FUNCS_REQUIRED      @ "required"
#define FUNCS_UNREDO        @ "unredo"              /**限制此界面只能上传一次*/
#define FUNCS_REDIS         @ "redis"               /**声明此界面可以回显*/
#define FUNCS_OPT           @ "opt"
#define FUNCS_ICON          @ "icon"
#define FUNCS_ICONOFDONE    @ "iconOfDone"
#define FUNCS_SHORTCUTURL   @ "shortcutURL"
#define FUNCS_DS            @ "ds"
#define FUNCS_PARAM         @ "param"
#define FUNCS_OTHER         @ "other"
#define FUNCS_FILTER        @ "filter"
#define FUNCS_DISPLAY       @ "display"
#define FUNCS_SQLW          @ "sqlw"
#define FUNCS_SUBMENU       @ "submenu"
#define FUNCS_WFCOL         @ "wfcol"
#define FUNCS_METHOD        @ "method"
#define FUNCS_DEFAULT       @ "default"

#define FUNCS_SCRIPT        @"script"

#define FUNCS_LEVELCODE     @"levelCode"


#define FUNCS_SPEC_VALUE    @ "Value"               //区分新增门店进入计划外还是新门店，9标示进入新门店，dujinfeng。

#define FUNCS_SPEC_JUMP_URL  @ "jumpurl"

#define FUNCS_SPEC_IOS_OPEN_URL    @"ios"

#define FUNCS_SPEC_SEARCH_SOURCE   @"searchSource"

#define FUNCS_SPEC_TOP_TIP           @"topTip"

#define FUNCS_SPEC_PAGE_TAG          @"pageTag"


//2018-01-17-MSTD-7535
#define FUNCS_SPEC_DEFAULT @"default"
#define FUNCS_SPEC_DEFAULT_IMAGE_URL @"defaultImageUrl"

#define FUNCS_MORE_GRID_STYLE       @"gridMoreStyle"

#define FUNCS_HOME_GRID_STYLE       @"gridHomepage"


// 第一列最小列宽(用于字体个数表示表格列宽)
#define SHORT_COLUMN_WIDTH          @"100"

#define ALLDAY_COLUMN_WIDTH @"80"

// 第一列默认列宽(用于字体个数表示表格列宽)
#define DEFAULT_COLUM_WIDTH          @"150"

// 首列宽度 单位：字数（汉字算2位   字母 标点 数字算一位）
#define FUNCS_fCharNum      @"FcharNum"

// 默认单位字符的宽度
#define  UNIT_WIDTH_DEFAULT  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 10 : 20)

//产品采集项（表格的列）（N，C，CHT，R，D，P，DT，SD, CA 类型）的单位字符宽度
#define  UINIT_WIDTH_OTHER   ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 10 : 16)

//产品采集项（表格的列）（T类型）的单位字符宽度
#define  UINIT_WIDTH_T       ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 15 : 30)

//产品采集项（表格的列）（B类型）的单位字符宽度
#define  UINIT_WIDTH_B       ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 20 : 40)

//产品采集项控件距离单元格的两边的留白宽度
#define UINIT_SPACE_WIDTH ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 2.5 : 5)

// 列宽度 单位：字数（汉字算2位   字母 标点 数字算一位）
#define FUNCS_CharNum     @"charNum"

#define FUNCS_AnswerColor     @"answerColor"

//


#define FUNCS_MAXROW        @ "maxRow"
#define FUNCS_COLNUM        @ "colNum"
#define FUNCS_REPEATVISIT   @ "repeatvisit"         /*中粮特有：离店后是否可以再次点击门店*/
#define FUNCS_LOCKCOL       @ "lockCol"
#define FUNCS_LOCKLEVEL       @ "lockLevel"
#define FUNCS_SHOWTYP       @ "showtyp"
#define FUNCS_DATETYP       @ "dateTyp"
#define FUNCS_STYP          @ "styp"                /*用来配置工作列表*/
#define FUNCS_COCALL        @ "cocall"              /*主管随访的查询条件*/
#define FUNCS_COCHK         @ "cochk"               /*主管检查的查询条件*/
#define FUNCS_ISACVTLIST    @ "isAcvtList"          /*是否进入活动list*/
#define FUNCS_EMPTYP        @ "empTyp"              /*主管检察时，empid是放主管的还是业代的
*/
#define FUNCS_TYP           @ "typ"                 /*控制funcs类型*/
#define FUNCS_STOREINFO     @ "storeinfo"           /*是否要门店信息功能*/
#define FUNCS_ISMORE         @"isMore"
#define FUNCS_MENU           @"menu"
#define FUNCS_ISADD          @"isAdd"
#define FUNCS_NULLVALUE          @ "nullvalue"                /*用来配置空值是否上传*/
#define FUNCS_SPEC_BUTTONNAME   @"buttonName"
#define FUNCS_SENDREQUEST       @"sendRequest"
#define FUNCS_MENU_LAYOUT             @"menuLayout"
#define FUNCS_STORES_FILTER           @"storesFilter"
#define FUNCS_ALIGNBOTTOM           @"alignBottom"
#define FUNCS_SHOWTHUMBNAIL         @"showThumbnail"
#define FUNCS_MENUTYPE         @"menuType"
//menustyle 为196196 显示图片
#define FUNCS_MENUSTYLE         @"menuStyle"
#define FUNCS_SORT              @"sort"
#define FUNCS_HIDDEN_EMPTY              @"hiddenEmpty"
#define FUNCS_NOTICENUMFC             @"noticeNumFc"


// menustyle 的值
#define FUNCS_MENUSTYLE_LIST            @"list"
#define FUNCS_MENUSTYLE_GRID            @"gridStyle"
#define FUNCS_MENUSTYLE_PAGE_TITLE      @"pageChangeStyle_Title"

#pragma mark -数据结构SugBean

#define SUG                             @"sugemplist"
#define SUG_EMPID                       @"empId"
#define SUG_PK                          @"pk"
#define SUG_NAME                        @"name"

#define REQUIRED_R                      @"R"       /*必须*/
#define REQUIRED_O                      @"O"       /*可选*/
#define REQUIRED_N                      @"N"       /*不要*/
#define REQUIRED_RO                     @"RO"      /*可以看到但是不能编辑*/
#define REQUIRED_E                      @"E"       /*可以看到但是不能编辑*/
#define REQUIRED_G                      @"G"
#define REQUIRED_V                      @"V"      /*isGps的V:先隐藏拍照，获取GPS，如果30秒内取到了GPS，则无需拍照；否则，显示拍照按钮，并拍照*/
#define REQUIRED_D                      @"D"

/*进店且 isGps = @"D"时，要检测当前位置与门店位置距离是否在500米范围为内*/
#define ENTER_STORE_VALID_DISTANCE  500.f
// 进店或离店后刷新门店列表
#define ENTER_OR_LEAVESTORE_RELOAD_STORE_LIST  @"enterOrLeaveStoreReloadStoreList"
// 更改门头照后刷新门店列表
#define CHANGE_STOREICON_RELOAD_STORE_LIST  @"changeStoreIconReloadStoreList"
//下载或清除城市门店刷新列表
#define DOWN_OR_ClEAR_RELOAD_STORE_LIST  @"downloadOrClearReloadStoreList"
// 上一次更新门店距离的位置信息
#define LAST_UPDATE_LOCATION_MESSAGE  @"lastUpdateLocationMessage"

/*empTyp 可能的值*/
#define EMPTYPE_EMP                     @"emp"
#define EMPTYPE_SR                      @"sr"

/*ds 可能的值*/
#define DS_ACVT                         @"acvt"
#define DS_PROM                         @"prom"
#define DS_PROD                         @"prod"
#define DS_PRODC                        @"prodc"
#define DS_STOREINFO                    @"storeInfo" //中粮业务新增

// Funcs_param
#define FUNCS_PARAM_COL                 @"col"
#define FUNCS_PARAM_NAME                @"name"
#define FUNCS_PARAM_TPY                 @"tpy"
#define FUNCS_PARAM_WCOL                @"wcol"
#define FUNCS_PARAM_MAX                 @"max"
#define FUNCS_PARAM_MIN                 @"min"
#define FUNCS_PARAM_PCS                 @"pcs"         // 精度--小数点后几位
#define FUNCS_PARAM_REDIS               @"redis"       // 此列是否回显上一次的数值
#define FUNCS_PARAM_READONLY            @"readonly"    // 是否移除控件的监听
#define FUNCS_PARAM_VALUE               @"Value"
#define FUNCS_PARAM_LISTENER            @"listener"
#define FUNCS_PRARM_FILTER              @"filter"
#define FUNCS_PRARM_ISMUTEX             @"isMutex"
#define FUNCS_BUTTONNAME                @"buttonname"          /*异常按钮名称*/
#define FUNCS_PARAM_ISREQ               @"is_req"
#define FUNCS_PARAM_ISPLANLIST          @"isplanlist"
#define FUNCS_PARAM_DEFAULT             @"default"
#define FUNCS_PARAM_DS                  @"ds"
#define FUNCS_PARAM_DEPENDON            @"dependon"
#define FUNCS_PARAM_ALERT               @"alert"
#define FUNCS_PARAM_REG                 @"REG"          //正则表达式 add by xiajl 2014-07-15
#define FUNCS_PARAM_GONE                @"gone" /*列是否隐藏 add by hj 2015 11 18*/
#define FUNCS_PARAM_TIP                 @"tip" /*当配tip时候 且 填写的最大值超过max表达式计算的值时 给出tip提示*/

#define FUNCS_PARAM_VALUE               @"Value"

#define FUNS_PARAM_SLDS @"slds" // single selection list
#define FUNS_PARAM_SLDFINDEX @"sldfindex" // single selection list default index

#define FUNCS_PRARM_ISSUPPERLOCALPHOTO             @"isSupperLocalPhoto"
#define FUNCS_PRARM_ISSUPPORTEDIT             @"isSupportEdit"
#define FUNCS_PRARM_HINTS               @"hints"
#define FUNCS_PRARM_SORT                @"sort"
#define FUNCS_PARAM_ISREALTIME          @"isRealtime"
#define FUNCS_PRARM_ALIGN               @"align"
#define FUNCS_PRARM_DESCRIPT            @"paramDescript"
#define FUNCS_PRARM_GROUPNAME           @"groupName"
#define FUNCS_PRARM_WIDTH_PERCENT       @"widthPercent"
#define FUNCS_PRARM_HIDE_QST_NAME       @"hideQstName"
#define FUNCS_PRARM_ADD_EDIT            @"AddEdit"
#define FUNCS_PRARM_NEED_VALIDATE_MORE_PROD_REDIS_VALUE       @"needValidateMoreProdRedisValue"
#define FUNCS_PRARM_PARENT              @"parent"
#define FUNCS_PRARM_REDIS_NO_MORE_HOME  @"isRedisNoMoreHome"
#define FUNCS_PRARM_ISNOTUPLOADEMPTY    @"isNotUploadEmpty"
#define FUNCS_PRARM_COLJUMPINPUT        @"coljumpinput"
#define FUNCS_PRARM_ISPOPUP             @"ispopup"



// Funcs_other
#define FUNCS_OTHER_COL                 @ "col"
#define FUNCS_OTHER_NAME                @ "name"
#define FUNCS_OTHER_TPY                 @ "tpy"
#define FUNCS_OTHER_WCOL                @ "wcol"
#define FUNCS_OTHER_MAX                 @ "max"
#define FUNCS_OTHER_MIN                 @ "min"
#define FUNCS_OTHER_PCS                 @ "pcs"         // 精度--小数点后几位
#define FUNCS_OTHER_REDIS               @ "redis"       // 此列是否回显上一次的数值
#define FUNCS_OTHER_READONLY            @ "readonly"    // 是否移除控件的监听
#define FUNCS_OTHER_DS                  @ "ds"
#define FUNCS_OTHER_FILTER              @ "filter"
#define FUNCS_OTHER_VALUE               @ "Value"       // MSTD-944 计算公式表达式 add by xiajl 2014-07-14
#define FUNCS_OTHER_REG                 @ "REG"         //正则表达式
#define FUNCS_OTHER_isSupperLocalPhoto  @"isSupperLocalPhoto"
#define FUNCS_OTHER_maxPhoto            @"maxPhoto"
#define FUNCS_OTHER_default             @"default"

/**
 * L--label;C--checkbox;N--numeric;D-double
 */
#define FUNCS_PARAM_typ_label           @"L"
#define FUNCS_PARAM_typ_numeric         @"N"
#define FUNCS_PARAM_typ_text            @"T"
#define FUNCS_PARAM_typ_checkbox        @"C"
#define FUNCS_PARAM_typ_button          @"B"
#define FUNCS_PARAM_typ_checkboxgroup   @"M"           // 多选
#define FUNCS_PARAM_typ_choiceboxgroup  @"R"           // 单选
#define FUNCS_PARAM_typ_photo           @"P"           // 拍照
#define FUNCS_PARAM_typ_date            @"D"           // 输入时间

#define COL_TYPNUM                      @"N"
#define COL_TYPCHECKBOX                 @"C"
#define COL_TYPCHECKBOXALL              @"CA"          //全选 add by xiajl 2014-06-30
#define COL_TYPBUTTON                   @"B"
#define COL_TYPTEXT                     @"T"           //文本 表格中的字母文本只能输入数字和字母
#define COL_TYPCHT                      @"CHT"
#define COL_TYPL                        @"L"
#define COL_TYPCHTS                     @"CHTS"
#define COL_TYPPHOTO                    @"P"
#define COL_TYPDATE                     @"D"
#define COL_TYPYM                       @"YM"
#define COL_TYPY                        @"Y"
#define COL_TYPR                        @"R"
#define COL_TYPLNR                      @"LNR"         //回显不上传控件 WUHE-4首发
#define COL_TYPTIME                     @"TIME"        //time 类型
#define COL_TYPQR                        @"QS"         // 条码扫描


// add by wangdongyan 04-10 for 信息查询内的业绩查询

// single selection list type
#define COL_TYPDT                       @"DT"

// 多选
#define COL_TYPSD                       @"SD"

#define COL_TYPTDIMG                    @"tdImg"

#pragma mark -数据结构Funcs
#define FUNCS_OPT_filterStyle @ "filterStyle"
#define FUNCS_OPT_showStyle @ "showStyle"
#define FUNCS_OPT_isPic     @ "isPic"
#define FUNCS_OPT_isGps     @ "isGps"
#define FUNCS_OPT_automaticDeparture     @ "automaticDeparture"

#define FUNCS_OPT_typGps    @ "typGps"
#define FUNCS_OPT_isMemo    @ "isMemo"
#define FUNCS_OPT_numMemo   @ "numMemo"
#define FUNCS_OPT_label     @ "label"
#define FUNCS_OPT_isCode    @ "isCode"
#define FUNCS_OPT_isMore    @ "isMore"
#define FUNCS_OPT_isScan    @ "isScan"
#define FUNCS_OPT_isSeq     @ "isseq"
#define FUNCS_OPT_title     @ "title"
#define FUNCS_OPT_name      @ "name"
#define FUNCS_OPT_isAdd     @ "isAdd"
#define FUNCS_OPT_isRedisMoreHome       @"isRedisMoreHome"
#define FUNCS_OPT_isAttendance     @ "isAttendance"
#define FUNCS_OPT_isIntentToStore  @ "isIntentToStore"
#define FUNCS_OPT_isSupperLocalPhoto    @"isSupperLocalPhoto"
#define FUNCS_OPT_maxPhoto              @"maxPhoto"
#define FUNCS_OPT_IsOpenGeo             @"isgeoopen"
#define FUNCS_OPT_IsSearchable          @"isSearchable"
#define FUNCS_OPT_StoreFiletr           @"storeFiletr"
#define FUNCS_OPT_Local                 @"local"
#define FUNCS_OPT_Auto                  @"auto"
#define FUNCS_OPT_Remote                @"remote"
#define FUNCS_OPT_MultilevelMenuSearch  @"multilevelMenuSearch"
#define FUNCS_OPT_SearchTag             @"searchTag"
#define FUNCS_OPT_SMS                   @"SMS"
#define FUNCS_OPT_ISRETURNHOME          @"isreturnhome"
#define FUNCS_OPT_NEEDSELECT            @"needSelect"
#define FUNCS_OPT_ISMAP                 @"isMap"
#define FUNCS_OPT_REMOVEDAY             @"removeDay"
#define FUNCS_OPT_ISSHOWUPDATED         @"isShowUpdated"
#define FUNCS_OPT_ISUSENEWID            @"isUseNewId"
#define FUNCS_OPT_ISSHOWACTIONTIP       @"isShowActionTip"
#define FUNCS_OPT_SERVERCOUNT           @"serverCount"
#define FUNCS_OPT_SEARCH_TAG_ALERT      @"searchTagAlert"
#define FUNCS_OPT_SHOW_DETAILS          @"showdetails"
#define FUNCS_OPT_ISSHORTCUT            @"isShortCut"
#define FUNCS_OPT_VISITEDFLAG           @"visitedFlag"
#define FUNCS_OPT_SEARCH_HINT           @"search_hint"
#define FUNCS_OPT_isRefresh             @"isRefresh"
#define FUNCS_OPT_isRead                @"isRead"
#define FUNCS_OPT_SEARCH_QUESTION       @"searchQuestion"
#define FUNCS_OPT_IS_COLLECTION_IMG     @"onlyCollectionImg"
#define FUNCS_OPT_ACVT_SEARCH           @"acvtSearch"
#define FUNCS_OPT_IS_USE_PARENT_FUNC    @"isUseParentFunc"
#define FUNCS_OPT_IS_Today_Visist       @"isTodayVisit"
#define FUNCS_OPT_AUTO_JUMP_NEXT        @"autoJumpNext"
#define FUNCS_OPT_AUTO_Add_MORE         @"autoAddMore"
#define FUNCS_OPT_IS_HIDE_TITLE         @"isHideTitle"
#define FUNCS_OPT_IS_EXHIBITION_NAV_TITLE @"isExhibitionNavTitle"
#define FUNCS_OPT_IS_QST_NAME           @"isQstName"
#define FUNCS_OPT_IS_SHOW_FOOT_NAV      @"isShowFootNavigate"
#define FUNCS_OPT_IS_HIDE_PLAN_OR_BIT   @"hidePlanOrbit"
#define FUNCS_OPT_IS_COLECTION_STYLE    @"isColectionStyle"

#define FUNCS_OPT_DELETE_BUTTON         @"deleteButton"
#define FUNCS_OPT_IS_OPEN_SUB_TRACKMAP  @"isOpenSubTrackMap"
#define FUNCS_OPT_ADD_TYPE              @"addtype"
#define FUNCS_OPT_ACVT_SORT             @"acvtSort"
#define FUNCS_OPT_ACVT_TAGBOTTOM        @"tagBottom"
#define FUNCS_OPT_CHAT_VISIBLE          @"isChat"
#define FUNCS_OPT_SENDREQUEST           @"sendRequest"
#define FUNCS_OPT_ISJUMPCALLPLAN        @"isJumpCallPlan"
#define FUNCS_OPT_UPDATEMENU            @"updateMenu"
#define FUNCS_OPT_UNREADNUMFLAG           @"unreadNumFlag"
#define FUNCS_OPT_PARENT_STORE_FC            @"parentStoreFc"

#define FUNCS_OPT_JUMP_TO_INPUT         @"jumpToInput"
#define FUNCS_OPT_SEARCH_COND_REQ_NODE  @"searchCondReqNode"
#define FUNCS_OPT_MENU_BG_COLOR         @"menuBgColor"
#define FUNCS_OPT_GPS_CITY_LEVEL        @"GpsCityLevel"
#define FUNCS_OPT_APPENDPROP            @"appendprop"
#define FUNCS_OPT_IS_ACVTLIST_CAN_DELETE            @"isAcvtListCanDelete"
#define FUNCS_OPT_IS_SHOW_ALREADY_FILLED_STATUS           @"isShowAlreadyFilledStatus"
#define FUNCS_OPT_NEW_STYLE_PROD_SELECT            @"newStyleProdSelect"
#define FUNCS_OPT_IS_SET_FOCUS          @"isSetFocus"
#define FUNCS_OPT_MORE_PROD_TYPE        @"moreProdType"
#define FUNCS_OPT_BACK_DIALOG_TIP       @"backDialog_tip"
#define FUNCS_OPT_UPLOADDIALOG_TIP      @"uploadDialog_tip"
#define FUNCS_OPT_NOT_REQ_CHECK_TIP     @"notReqCheck_tip"
#define FUNCS_OPT_IS_NEED_SHOW_STORENAME        @"isNeedShowStoreName"
#define FUNCS_OPT_SUB_TITLE_BG_COLOR       @"subTitleBgColor"
#define FUNCS_OPT_REMOTE_ORDER_PRODUCT_INFO       @"remoteOrderProductInfo"
#define FUNCS_OPT_IS_NEED_BACK      @"isNeedBack"

#define FUNCS_OPT_REMOTE_RESOURCEFORM   @"resourceForm"
#define FUNCS_OPT_SHOWTIPS              @"showReqTips"
#define FUNCS_OPT_ROUYEVISITFC          @"routeVisitFC"
#define FUNCS_OPT_INDEPENDENT_SHOW_SUB  @"independentShowSub"
#define FUNCS_OPT_JUMP_URL_LINK         @"jumpUrlLink"
#define FUNCS_OPT_SEARCHROUTE_URL       @"routeSearchurl"
#define FUNCS_OPT_VISIT_MAX             @"visitMax"
#define FUNCS_OPT_STOREINOF_URL         @"jumpStoreInfoUrl"
#define FUNCS_OPT_WEB_BACK_UPDATE_JS    @"webBackUpdateJS"
#define FUNCS_OPT_SAVENODE              @"saveNode"
#define FUNCS_OPT_MORDERDIS             @"mOrderByDis"

#define FUNCS_OPT_IS_REMINDER_VISIT     @"isReminderVisit"
#define FUNCS_OPT_IS_REMINDER_OPERATE   @"isReminderOperate"
#define FUNCS_OPT_ADDROUTE              @"addRouteUrl"
#define FUNCS_OPT_BATCH_UPDATE_ROUTE    @"batchModifyUrl"


// WRIGLEY-1471 后台下发是大写
#define FUNCS_OPT_NAVDIS_VISIBLE          @"NaviDis"
#define FUNCS_OPT_LOWER_NAVDIS_VISIBLE          @"naviDis"

#define FUNCS_OPT_ADD_TYPE_CALENDER     @"calendar"

#define FUNCS_OPT_CONTEXT_MENU     @"contextMenu"
#define FUNCS_OPT_IS_TIPS_MENU     @"isTipsMenu"
#define FUNCS_OPT_DISTANCES_SORT     @"distancesSort"
#define FUNCS_OPT_VISIT_TIME_SORT     @"visitTimeSort"
#define FUNCS_OPT_DOWN_BY_MAP     @"downByMap"
#define FUNCS_OPT_IS_COUNTRY     @"isCountry"

#define FUNCS_OPT_REFRESH_NODE_NAME     @"refreshNodeName"
#define FUNCS_OPT_IS_ONLYSUB     @"isOnlySub"

#define FUNCS_OPT_HELP_SALES            @"salesAssistanceMenu"
#define FUNCS_OPT_ISUSERNEW_PAGE        @"isUseNewPage"
// RN模板相关FUNCS_OPT
#define FUNCS_OPT_RN_IOSV               @"rn_iosv"
#define FUNCS_OPT_RN_FORMCODE           @"rn_formcode"
#define FUNCS_OPT_RN_ANDROIDV           @"rn_androidv"
#define FUNCS_OPT_RN_URL                @"rn_url"
#define FUNCS_OPT_RN_RPTCODE            @"rn_rptcode"


#define FUNCS_OPT_SELECTDATE   @"selectDate"
#define FUNCS_OPT_SELECTDATE_MINWEEK   @"minWeek"
#define FUNCS_OPT_SELECTDATE_MMXWEEK   @"maxWeek"
#define FUNCS_OPT_HIDE_COUNT   @"hideCount"
#define FUNCS_OPT_PROD_TREES   @"prodtrees"
#define FUNCS_OPT_MAP_ICON_TYPE   @"mapIconType"
#define FUNCS_OPT_LEAVESTORE_TIP   @"leaveStoreTip"
#define FUNCS_OPT_IS_SAVE_DATA_BACK @"isSaveData_back"
#define FUNCS_OPT_UPLOAD_IN_THE_FOLLOWING   @"uploadIntheFollowing"
#define FUNCS_OPT_IS_ADD_PRODUCT_STYLE @"isAddProductStyle"
#define FUNCS_OPT_IS_Hidden_FilledOutStatusImageView @"isHiddenFilledOutStatusImageView"

#define FUNCS_OPT_FOLLOW_STORE          @"followStore"
#define FUNCS_OPT_SHOW_SUB              @"showSub"
#define FUNCS_OPT_ADD_FILTER_TYPE       @"addFilterType"
#define FUNCS_OPT_IS_SHOW_SUBAREA       @"isShowSubArea"
#define FUNCS_OPT_CUS_MAIL_LIST         @"cusMailList"
#define FUNCS_OPT_ACVT_VISIT_STATUS     @"acvtVisitStatus"
#define FUNCS_OPT_LEAVE_MODIFY          @"leaveModify"
#define FUNCS_OPT_LIST_STYLE_SHOW_COL_NUM @"listStyleShowColNum"
#define FUNCS_OPT_BATCH_UPLOAD          @"batchUpload"
#define FUNCS_OPT_UPLOAD_STYLE          @"uploadStyle"
#define FUNCS_OPT_IS_CURRENT_GEO        @"isCurrentGeo"
#define FUNCS_OPT_HIDDEN_CODE           @"hiddenCode"
#define FUNCS_OPT_REFRESH               @"refresh"
#define FUNCS_OPT_CANCEL_SEARCH_CODE  @"cancelSearchCode"

#define FUNCS_OPT_LOGIN_URL         @"loginUrl"
#define FUNCS_OPT_PASS_WORD         @"password"
#define FUNCS_OPT_PASS_WORD_ENCRYPT @"passwordEncrypt"
#define FUNCS_OPT_USER_NAME         @"username"
#define FUNCS_OPT_NEXT_ACVT_NODE           @"nextAcvtNode"

#define FUNCS_OPT_IMG_COMPRESS              @"imgCompress"
#define FUNCS_OPT_SHOOT_WIDTH               @"imgShootWidth"
#define FUNCS_OPT_IMG_COMPRESS_IOS          @"imgCompress_IOS"
#define FUNCS_OPT_SHOOT_WIDTH_IOS           @"imgShootWidth_IOS"
#define FUNCS_OPT_IS_SRID                   @"isSrid"
#define FUNCS_OPT_IS_SINGLE_QST_TO_AUTOJUMP @"isSingleQstToAutoJump"
#define FUNCS_OPT_IS_CHECK_ENTER_STORE      @"isCheckEnterStore"
#define FUNCS_OPT_IS_CHECK_PUSH_VIEW        @"isCheckPushView"
#define FUNCS_OPT_IS_CHECK_EMPID            @"isCheckEMPID"

#define FUNCS_OPT_IS_UPLOAD_CHECK_REPLACE @"isUploadCheckReplace"
#define FUNCS_OPT_DOWNLOAD_INFO_NUM     @"downloadInfoNum"
#define FUNCS_OPT_LEAVESTORE_TIPFUNC    @"leaveStoreTipFunc"
#define FUNCS_OPT_REQUEST_TIMEOUT       @"requestTimeout"
#define FUNCS_OPT_Is_Update_Store_Icon  @"isUpdateStoreIcon"
#define FUNCS_OPT_NEED_REPEATE_PROD     @"needRepeatProd"
#define FUNCS_OPT_CHECK_CALLING_STORE     @"checkCallingStore"
#define FUNCS_OPT_LEAVE_TIP_FLAG        @"leaveTipFlag"
#define FUNCS_OPT_CUSTOM_FORMAT_IMG_NAME @"customFormatImgName"
#define FUNCS_OPT_IS_BRANCH_STORE_DOWNLOAD   @ "isBranchStoreDownload" /*门店下载*/

#define FUNCS_OPT_IS_VISIT_COMPLETE_MODULE_READONLY_TIP @"isVisitCompleteModuleReadonlyTip"
#define FUNCS_OPT_PRODTREE_CHECKED_NAME @"prodtree_checked_name"
#define FUNCS_OPT_IS_BACKGROUND_CACHE @"isBackgroundCache"

#define FUNC_OPT_SUGGEST_ORDER_NODE      @"suggestOrderNode"

#define FUNC_OPT_ISHIDDEN_BACK           @"isHiddenBack"

#define FUNC_OPT_FUNCTIP_TYPE            @"funcTipType"

// required type
#define REQUIRED_REQUIRED   @ "R"
#define REQUIRED_OPTION     @ "O"
#define REQUIRED_NEGATIVE   @ "N"

#pragma mark 联系人
#define POSTCARDRECEIVE     @ "postCardreceive"

#pragma mark 新增门店 & 修改
#define newStoreNotification                @ "newStoreNotification"
#define modifyStoreNotification                @ "modifyStoreNotification"
#define kAddNewStoreApply                @"kAddNewStoreApply"  //申请门店的通知

#pragma mark - 修改门店信息-WSModifyStoreViewController页面使用
#define ModifyStoreInfoNotification                @ "ModifyStoreInfoNotification"

#pragma mark - 解绑门店成功后提示上一界面刷新通知 //2017-09-29-yuanji-add
#define RelieveStoreRefreshNotification @"RelieveStoreRefreshNotification"

#pragma mark - 解绑门店成功后刷新门店列表
#define ModifyStoreRefreshNotification      @"ModifyStoreRefreshNotification"

#pragma mark - 业务检查审阅完成后返回门店列表自动刷新门店列表
#define CustomerQueryRefreshNotification    @"CustomerQueryRefreshNotification"

#pragma mark 新增产品
#define NEWPRODUCT                          @"newProduct"

#pragma mark 新增调查问卷

#define NEWADDACVTSUCCEED      @ "newAddAcvtSucceed"

#define SAVEACVTDATA      @ "saveAcvtData"



//add by wangdongyan 03-14 for 再主管拜访内的主管协防内要先获取主管人，再点击进入子目录
#pragma mark  -数据结构Subempstore
#define SUBEMPSTORE_EMPID           @ "empId"
#define SUBEMPSTORE_ID              @ "id"
#define SUBEMPSTORE_NAME            @ "name"
#define SUBEMPSTORE_IN              @ "in"
#define SUBEMPSTORE_OUT             @ "out"
#define SUBEMPSTORE_ACVT            @ "acvt"
#define SUBEMPSTORE_COD             @ "cod"
#define SUBEMPSTORE_STYP            @ "styp"
#define SUBEMPSTORE_ORGID           @ "orgId"
#define SUBEMPSTORE_ORGNAME         @ "orgName"
#define SUBEMPSTORE_ORGCODE         @ "orgCode"
#define SUBEMPSTORE_LEVELCODE       @ "level_code"
#define SUBEMPSTORE_SUBLEVELCODE    @ "sub_level_code"
#define SUBEMPSTORE_PARENTID        @ "parentId"
#define SUBEMPSTORE_ORGCODE         @ "orgCode"
#define SUBEMPSTORE_IMGURL          @ "imgUrl"
#define SUBEMPSTORE_LEAFNODE        @ "leafNode"

#pragma mark GPS
#define GPS_TYPE                    @"lt"  //GPS位置信息类型：wgs84/gcj02
#define GPS_LAT                     @"lat" //纬度
#define GPS_LON                     @"lon" //经度
#define GPS_LOC_ADDR                @"loc_addr" //地址信息
#define GPS_PROVINCE                @"province"
#define GPS_CITY                    @"city"
#define GPS_DISTRICT                @"district"
#define GPS_HEI                     @"hei" // 海拔
#define GPS_HO                      @"ho"   //水平精度
#define GPS_VO                      @"vo"   //竖直精度
#define GPS_S                       @"s"    //水平速度
#define GPS_D                       @"d"    //朝向：以北开始顺时针方向
#define GPS_LOC_TIME                @"locTime" //时间戳
#define GPS_CACHE_DURATION          @"cacheDuration"    //缓存间隔
#define GPS_ENABLE_GPS              @"enable_gps" // gps是否可用

#pragma mark NetWork
#define NETWORK_VALID               @"netValid" //网络是否可用：1/0
#define NETWORK_ENABLE_MOBILE       @"enable_mobile" //2G/3G网络
#define NETWORK_ENABLE_WIFI         @"enable_wifi"   //WIFI
#define NETWORK_TYPE                @"net_type" //网络类型


#pragma mark CustomerQuary
#define CQ_KEYWORD                  @ "keyWord"
#define NT_NAME                     @ "notifyName"

#pragma mark MsgReceiver
#define MSG_RCV_ID                  @ "msgId"
#define MSG_RCV_EMPID               @ "empId"
#define MSG_RCV_ORGNAME             @ "orgName"
#define MSG_RVC_EMPNAME             @ "empName"

#pragma mark empAcvtDis
#define EAD_P                       @ "p"
#define EAD_EMPID                   @ "empId"

// add by wangdongyan 04-10 for 6200信息查询内的业绩查询的数据
#pragma mark  -数据结构  empinforefresh
#define EMPINFOREFRESH_EMPID    @ "empId"
#define EMPINFOREFRESH_COL1     @ "col1"
#define EMPINFOREFRESH_COL2     @ "col2"
#define EMPINFOREFRESH_COL3     @ "col3"
#define EMPINFOREFRESH_COL4     @ "col4"
#define EMPINFOREFRESH_COL5     @ "col5"
#define EMPINFOREFRESH_COL6     @ "col6"
#define EMPINFOREFRESH_COL7     @ "col7"
#define EMPINFOREFRESH_COL8     @ "col8"
#define EMPINFOREFRESH_TYP      @ "typ"
#define EMPINFOREFRESH_TYPID    @ "typid"

#pragma mark  -数据结构  submics
#define SUBMICS_EMPID             @ "empId"
#define SUBMICS_ID                 @ "id"
#define SUBMICS_NAME             @ "name"
#define SUBMICS_CODE             @ "code"
#define SUBMICS_LEVEL_CODE       @ "level_code"
#define SUBMICS_SUB_LEVEL_CODE     @ "sub_level_code"
#define SUBMICS_IN                 @ "in"
#define SUBMICS_ORG_ID            @ "ORG_ID"
#define SUBMICS_ORG_NAME         @ "ORG_NAME"


#pragma mark  -数据结构  storeInfo
#define STOREINFO_EMPID         @ "empId"
#define STOREINFO_STOREID       @ "storeId"
#define STOREINFO_COL1          @ "col1"
#define STOREINFO_COL2          @ "col2"
#define STOREINFO_COL3          @ "col3"
#define STOREINFO_COL4          @ "col4"
#define STOREINFO_COL5          @ "col5"
#define STOREINFO_TYP           @ "typ"
#define STOREINFO_TYPID         @ "typid"

#pragma mark  -数据结构  salespersonInfo
#define SALESPERSONINFO_EMPID         @ "empId"
#define SALESPERSONINFO_COL1          @ "COL1"
#define SALESPERSONINFO_COL2          @ "COL2"
#define SALESPERSONINFO_COL3          @ "COL3"
#define SALESPERSONINFO_COL4          @ "COL4"
#define SALESPERSONINFO_COL5          @ "COL5"
#define SALESPERSONINFO_TYP           @ "typ"

#pragma mark UncaughtExceptionHandler
#define EexceptionKey           @ "exception"

#pragma mark baseview
#define OTHER_TPY_D             @ "D"
#define OTHER_TPY_T             @ "T"
#define OTHER_TPY_C             @ "C"
#define OTHER_TPY_S             @ "S"
#define OTHER_TPY_N             @ "N"
#define OTHER_TPY_TL            @ "TL"
#define OTHER_TPY_R             @ "R"
#define OTHER_TPY_P             @ "P"
#define OTHER_TPY_TC            @ "TC"
#define OTHER_TPY_L             @ "L"
#define OTHER_TPY_CS             @ "CS"
#define OTHER_TPY_CHT             @ "CHT"

#pragma mark gps
#define kGlobalLatitude         @ "global_latitude"
#define kGlobalLongitude        @ "global_longitude"
#define kGlobalCityName         @ "global_cityName"

#pragma mark - clean warnings
#define PRODS   @"prods"
#define MSGS    @"msgs"
#define MSG_REAL @"realStoreMsgs"

#define DICTS   @"dicts"
#define STORE   @"store"
#define STORES_VIP   @"stores:vip"

#define STORE_DICTS   @"storeDicts"

#define ACVTSHOW @"acvtshow"
#define STORE_EMP @"store_emp"
#define SUB_EMP @"sub_emp"
#define EMP @"emp"



#define BASE_EMPLOYEE        @"baseemployee"

#pragma mark - Geographic information 
#define GEOINFO     @"geographicInfo"
#define GEOPID      @"pId"
#define GEOID       @"id"
#define GEOPNAME    @"pName"
#define GNAME       @"name"
#define GEOLEVELCODE @"levelCode"
#define GEODISTRICT @"district"
#define GEOCITYS     @"citys"
#define AREAS       @"areas"
#define GEOPOINTCITYNAMES @"pointcitynames"
#define GEOPOINTINFO @"pointinfo"
#define GEONAME      @"geoName"

#pragma mark - scheduleBrand information
#define SCHEDULEBRAND_NODE @"scheduleBrand"
#define SCHEDULEBRAND_ID   @"id"
#define SCHEDULEBRAND_NAME @"name"

#pragma mark - 登录请求回来的参数
#define ENABLE_PASSIVE_LOCATION @"ENABLE_PASSIVE_LOCATION"
#define LOCATION_CHECK_TIME     @"LOCATION_CHECK_TIME"
#define LOCATION_START_TIME     @"LOCATION_START_TIME"
#define LOCATION_END_TIME       @"LOCATION_END_TIME"
//开启程序时，是否检查GPS的开启状态，0不检查；1提示开启；2提示开启，未开启不允许登陆系统。默认LOGIN_CHECK_GPS = 0
#define LOGIN_CHECK_GPS         @"LOGIN_CHECK_GPS"

#define ENABLE_LOCATION @"ENABLE_LOCATION"          //app是否开启坐标服务(GPS)，默认0，关闭
#define OPEN_WIFI_ON_GET_GPS @"OPEN_WIFI_ON_GET_GPS"//采集GSP信息时 是否要开启WIFI检测 0关闭

#define TAKE_PHOTO_ALBUM @"TAKE_PHOTO_ALBUM" //SFA-23687 照相后是否保存到相册

#define BEACON_FOUND_DATE       @"BEACON_FOUND_DATE"


#define ROOT_CONFIG_USERDEFAULT_KEY @"ROOT_CONFIG_USERDEFAULT_KEY"

// 是否记住密码
#define REMEMBER_PASSWORD @"REMENBER_PASSWORD"
// 是否勾选“记住用户名”
#define REMEMBER_ME_KEY   @"remember_me_key"

#define REMEMBER_USERNAME_LOCAL   @"remember_username_local"

//用户无操作行为（点击，触摸等）超过一定时间，弹出锁屏页面
#define LOCK_TIMEOUT   @"LOCK_TIMEOUT"
//程序切到后台运行，再次返回前台时，弹出锁屏页面
#define LOCK_RUN_IN_BACKGROUND   @"LOCK_RUN_IN_BACKGROUND"

//登陆界面是否有修改密码
#define IS_LOGIN_PASSWORD @"IS_LOGIN_PASSWORD"

#define POA_NOTIFICATION_INTERVAL @"POA_NOTIFICATION_INTERVAL"

// app 是否开启定时更新公告信息内容
#define INFORMATION_PUSH @"INFORMATION_PUSH"

//是否使用系统相机
#define USE_SYSTEM_CAMERA @"USE_SYSTEM_CAMERA"

//配置数据若有节点且值存在,则用此节点值作为登陆地址
#define WEB_ADDRESS @"WEB_ADDRESS"

// 进离开店是否显示出经纬度以外的地址
#define IS_SHOW_GPS_ADDRESS @"IS_SHOW_GPS_ADDRESS"

// 主页列数
#define  HOMEPAGE_COLUMNS @"HOMEPAGE_COLUMNS"
#define  HOMEPAGE_COLUMNS_DEFAULT @"3"

//是否将下发的坐标转为02坐标，值为0时不转换 （蒙牛项目使用）
#define  GAODE2WGS84 @"GAODE2WGS84"

// 配置为 1 代表使用单位转换（规格只包含：KG、kg、Kg、kG、g、G、克、千克） （立白项目）
#define  NEED_WEIGHT_CONVERSION @"NEED_WEIGHT_CONVERSION"

//root config
#define IMAGE_WIDTH @"IMAGE_WIDTH"
#define IMAGE_WATERMARK @"IMAGE_WATERMARK"

// 是否显示引导页
#define WELCOME_PAGE_OPTION @"WelcomePageOption"

//是否开始beacon功能 1-开始，0-不开启。默认值为0，不开启。
#define ENABLE_BEACON       @"ENABLE_BEACON"

//上报时间间隔   时间间隔(单位：秒)。默认值为1800（30分钟)
#define BEACON_CHECK_TIME   @"BEACON_CHECK_TIME"

//扫描间隔默认值暂定15分钟
#define BEACON_SCAN_TIME    @"BEACON_SCAN_TIME"

//开始上报时间
#define BEACON_START_TIME   @"BEACON_START_TIME"

//上报结束时间
#define BEACON_END_TIME     @"BEACON_END_TIME"

#define BEACON_UUID         @"BEACON_UUID"

#define WINCHANNEL_HOTLINE  @"WINCHANNEL_HOTLINE"


// 包含了用户名，组织和SAAS 平台返回的登录地址
#define LOGIN_SAAS_WEB_ADDRESS  @"LOGIN_SAAS_WEB_ADDRESS"

// SAAS 平台返回的登录地址
#define SAAS_WEB_ADDRESS        @"SAAS_WEB_ADDRESS"

// SAAS 登录参数是否传递版本号 MSTD-6717
#define LOGIN_SAAS_SEND_VERSION             @"sendVersion"                  // 本地记录的是否上传版本号key
#define LOGIN_SAAS_SEND_VERSION_YES         @"1"                            // 登录传递版本号
#define LOGIN_SAAS_SEND_VERSION_NO          @"0"                            // 登录不传递版本号

//是否开启检测附近peer的功能，由于之前的项目增加此功能没有加参数控制，大部分项目不需要此功能，每次都启动multipeerManager有些浪费,故加此参数控制，如后面发现需要此功能的项目没有开启，增加参数即可，1为开启，0为关闭，默认为关闭。
#define ENABLE_MULTIPEER    @"ENABLE_MULTIPEER"

//is_offline_landing 值含义，1 or 2
//1:有网登录过一次app，日后不论哪天只要当时手机记录的账号密码信息正确均可以离线登录，且不校验业务日期，晚上不会强退，且手机端上传均采用的手机端时间(示例项目：施耐德)
//2:每天有网登录一次，之后当天可离线登录，需要校验业务日期，晚上强制退出系统(示例项目：联合利华)
#define IS_OFFLINE_LANDING  @"is_offline_landing"

#define BOTTOM_MENU  @"BOTTOM_MENU"

#define IS_FORCE_EXIT  @"is_force_exit"   //配置为0则不使用强退功能

#define USE_STORE_PHOTOS  @"USE_STORE_PHOTOS"


#define IS_BRAND_MORE @"BRAND_IN_MORE"

#define EXTERNAL_PIC_FOLDER @"EXTERNAL_PIC_FOLDER" //备份到本地相册

#define LOCATION_TIMEOUT @"LOCATION_TIMEOUT"  //定位问题必填时，未定位成功需等待的秒数

#define LOCATION_ACCURACY @"LOCATION_ACCURACY"  //定位精度，小于此精度时会重试

#define IS_SHOW_RICHMEDIA_HOME @"isShowRichMediaHome"  // 是否显示富媒体首页

#define ONLINE_CONSULTATION @"Online_Consultation"

#define ONLINE_CONSULTATION_SERVER @"Online_Consultation_Server"
#define IS_SUPPORT_MESSAGE_BACKUP @"IS_SUPPORT_MESSAGE_BACKUP" // 开启环信聊天记录同步

#define CHECK_LEAVE_STORE @"CHECK_LEAVE_STORE"  //是否校验离店， 配置为0时，不离店也可以做其他店的进店操作, 默认为1

// MN-802 调查问卷textfield是否全选文字。1为全选，0为不全选，默认为0.
#define SELECT_ALL_ON_FOCUS @"SELECT_ALL_ON_FOCUS"

//登陆数据版本
//#define CACHE_DATA_VERSION @"CACHE_DATA_VERSION"
//存储用户登陆数据版本的key
#define CACHE_DATA_VERSION_KEY_BYUSER(userid) [NSString stringWithFormat:@"CACHE_DATA_VERSION_%@",[[userid stringByTrimmingWhitespace] lowercaseString]]
//存储登陆数据的文件名
#define LOGIN_DATA_FILENAME_BYUSER(userid) [NSString stringWithFormat:@"LOGIN_DATA_%@.txt",[[userid stringByTrimmingWhitespace] lowercaseString]]


//是否从缓存加载登录数据
#define LOGIN_DATA_IS_FROMCACHE @"LOGIN_DATA_IS_FROMCACHE"

//存储storeAcvts的key(用于辉瑞零售存储acvt剩余上传次数)
#define STORE_ACVTS_KEY_BY_EMPID(userid) [NSString stringWithFormat:@"STORE_ACVTS_%@",userid]
//存储上一次的BIZDATE
#define LAST_BIZ_DATE_KEY @"LAST_BIZ_DATE_KEY"


#pragma mark - 是否开启自动上传
#define MOBILE_AUTO_UPLOAD @"mobileAutoUpload"

#pragma mark - CHECK_UPLOADED_DATA
/**
 * 登陆时检查是否有未上传数据，如果有未上传数据则要求用户上传完成后（也就是停留在上传界面），再进入SFA主界面。默认1。取值意义如下：
 * 0表示不检查是否有未上传数据。
 * 1表示检查是否有未上传数据，如果有则显示上传界面，但是不强制要求用户必须上传完毕，用户可以随时点“返回”到主界面。
 * 2表示检查是否有未上传数据，如果有则显示上传界面，而且强制要求用户必须上传完毕，才能点“返回”到主界面。
 **/
#define CHECK_UPLOADED_DATA @"CHECK_UPLOADED_DATA"

//应用上次退出状态键
#define EXIT_APP_STATUS_USERDEFAULT_KEY @"EXIT_APP_STATUS_USERDEFAULT_KEY"
//应用退出时的时间戳
#define EXIT_APP_TIMESTAMP_USERDEFAULT_KEY @"EXIT_APP_TIMESTAMP_USERDEFAULT_KEY"
//应用退出时的ACCOUNT
#define EXIT_APP_ACCOUNT_USERDEFAULT_KEY @"EXIT_APP_ACCOUNT_USERDEFAULT_KEY"
//应用退出时的AKU
#define EXIT_APP_AKU_USERDEFAULT_KEY @"EXIT_APP_AKU_USERDEFAULT_KEY"
//应用退出时的VERSION
#define EXIT_APP_VERSION_USERDEFAULT_KEY @"EXIT_APP_VERSION_USERDEFAULT_KEY"
//应用退出时的日期
#define EXIT_APP_SYNCDATE_USERDEFAULT_KEY @"EXIT_APP_SYNCDATE_USERDEFAULT_KEY"
typedef enum
{
    ExitAppStatusException = 0, // "异常退出"
    ExitAppStatusNormal = 1, // "正常退出"
    ExitAppStatusForce = 2, // "强制退出（登陆时间不程序提供服务的的范围，用户Id异常）"
    ExitAppStatusBizdateError = 3 // "手机日期（天）和服务器业务日期不符"
}ExitAppStatus;

//geographicInfo

// 界面相关
#define UI_NAVIGATION_BAR_HEIGHT        44
#define UI_TOOL_BAR_HEIGHT              44
#define UI_TAB_BAR_HEIGHT               49
#define UI_STATUS_BAR_HEIGHT            20
#define IPHONE_X (@available(iOS 11.0, *) ? [[[UIApplication sharedApplication] delegate] window].safeAreaInsets.bottom > 0.0 : NO )
#define IOS7_OR_LATER ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)
#define IOS8_OR_LATER ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending)
#define IOS9_OR_LATER ([[[UIDevice currentDevice] systemVersion] compare:@"9.0" options:NSNumericSearch] != NSOrderedAscending)

#define IOS10_OR_LATER ([[[UIDevice currentDevice] systemVersion] compare:@"10.0" options:NSNumericSearch] != NSOrderedAscending)
#define IOS11_OR_LATER ([[[UIDevice currentDevice] systemVersion] compare:@"11.0" options:NSNumericSearch] != NSOrderedAscending)


// IPHONE_4S
#define IS_IPHONE_4S ([UIScreen instancesRespondToSelector:@selector(currentMode)] \
? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size)\
: NO)

// IPHONE_5
#define IS_IPHONE_5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] \
? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size)\
: NO)

// IPHONE_6
#define IS_IPHONE_6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] \
? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size)\
: NO)

// IPHONE_6_PLUS
#define IS_IPHONE_6_PLUS ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(1125, 2001), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size)) : NO)

#define UI_XFactor ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 1 : ((self.view.bounds.size.height)/320.0f))
#define UI_YFactor ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 1 : ((self.view.bounds.size.height)/480.0f))
#define UI_Font  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 15.0f : 17.0f)
#define UI_Enhance_Font  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 17.0f : 20.0f)
#define UI_LeftView_Font  (16)
#define UI_Login_Font  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 14.0f : 17.0f)

#define UI_KEYBOARD_VIEW_HEIGHT ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 36.0f : 36.0f)

#define PanelTextFieldColor        ([UIColor colorForKey:@"AcvtViewPanelText"] ?  : MAIN_TEXT_COLOR)
#define PanelTextFieldFont         ([UIFont fontForKey:@"AcvtViewPanelText"] ?  : [UIFont systemFontOfSize:UI_Font])
#define PanelTextFieldColorReadonly        ([UIColor colorForKey:@"AcvtViewPanelTextReadonly"] ?  : MAIN_TEXT_DISABLE_COLOR)


#define UI_SEGMENTCONTROL_FONT [UIFont mainFontOfSize:INTERFACE_IS_PHONE ? 15 : 17]

#define STORE_LIST_WIDTH_DIFFERENCE 115

#define TITLE_MAX_LENGTH ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 5 : 20)
#define TITLE_MAX_WIDTH ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 100 : 300)

#define kSegmentedControlHeight (INTERFACE_IS_PHONE ? 34.0f : 33.0f)
#define kSegmentedControlTopGap (INTERFACE_IS_PHONE ? 5.0f : 15.0f)
#define kSegmentedControlBottomGap (INTERFACE_IS_PHONE ? 5.0f : 15.0f)

#define kApplicationWinddow ((WSAppDelegate *)[UIApplication sharedApplication].delegate).window

#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568 < 0)? NO:YES)

#define APP_DISPLAY_NAME    ([[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"] ? [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"] : [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"])

// 进离店和调查问卷显示地图相关
#define k_MapViewXOffset  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 10:10.0f)
#define k_MapViewHeight  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 220:320.0f)
#define k_MapViewMargin ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 10:10.0f)
#define k_MapViewWidth  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 300 :(1024 - 160)

#define kEnterOrLeaveStoreFuncBtnTopPadding     10.0
#define kEnterOrLeaveStoreFuncBtnLeftPadding     15.0
#define kEnterOrLeaveStoreFuncBtnHeight      44.0

#define FLOAT_IS_EQUAL(x,y) (fabs(x - y) < 0.0001 ? YES : NO)


// start ----------------------- 数据上传过程优化 -----------------------
//typedef enum
//{
//    WCDatasUploadTypeDefault = 0,
//    WCDatasUploadTypeAddNewStore = 1,
//    WCDatasUploadTypeModifyAddedNewStore = 2,
//    WCDatasUploadTypeAddAcvt = 3
//}WCDatasUploadType;

typedef enum
{
    WCDatasUploadStatusUploading = 0,
    WCDatasUploadStatusSuccess = 1,
    WCDatasUploadStatusFail = 2,
    WCDatasUploadStatusInvaild = 3
}WCDatasUploadStatus;

typedef enum
{
    WCDatasTypeNone = 0,
    WCDatasTypeTxt = 1,
    WCDatasTypeImage = 2,
    WCDatasTypeVideo = 3
}WCDatasType;

// end   ----------------------- 数据上传过程优化 -----------------------

// start ----------------------- 服务器和本地时间相差时间 -----------------------
#define WCForceQuiteTimeInterval 20 // 服务器和本地时间相差20分强制退出
// end   ----------------------- 服务器和本地时间相差时间 -----------------------

// start -----------------------服务器时间 -----------------------
#define WCSERVERTIME                   @ "servertime"
// end   ----------------------- 服务器时间 -----------------------

#define kOfflineTableNotifyIdPrefix                         @"WSOffline"
#define kOfflineTableNotifyIdPrefix_AddedNewsStore          @"WSOffline_AddedNewsStore"
#define kOfflineTableNotifyIdPrefix_ModifyAddedNewStore     @"WSOffline_ModifyAddedNewStore"
#define kOfflineTableNotifyIdPrefix_AddedNewsAcvt           @"WSOfflineTableNotifyIdPrefix_AddedNewsAcvt"
#define kOfflineTableNotifyIdPrefix_DeleteNewsAcvt          @"WSOfflineTableNotifyIdPrefix_DeleteNewsAcvt"
#define APP_EXITSTATUS_NOTIFY                               @"WSOffline_APP_EXITSTATUS_NOTIFY"
#define kForcibleSynchronizeRequest                         @"forcibleSynchronizeRequest"      //Note: 强制同步请求（djf）


#define kWSMessageDomainName @"WSMessageDomainName"
#define kWSMessageBizDate    @"WSMessageBizDate"
#define kWSMessageEmpId      @"WSMessageEmpId"

//notify name
#define LOGIN_NOTIFY                                        @"login"
#define GETROOTCONFIG_NOTIFY                                @"getrootconfig"
#define CHANGE_NOTIFY                                       @"ChangePassWord"
#define UPLOAD_ACVT_NOTIFY                                  @"UploadAcvtNotify"
#define LOGIN_SAAS_RETRIEVE_PWD_NOTIFY                      @"loginSaasRetrievePwd"

#define LOGIN_REMIND_NOTIFY                                 @"login_REMIND"


#define store_visit_record_notify  @"store_visit_record_notify"

// 登录web后台的请求通知
#define login_web_notify        @"login_web_notify"
#define opt_login_web_notify    @"opt_login_web_notify"


#define kAutoUploadCount 20

#define kUploadFailedDataErrorDomain @"UploadErrorDomain"

#define UPLOAD_UNLEAVED_STORE       @"UPLOAD_UNLEAVED_STORE"

#define NeighborStore_notify        @"NeighborStore_notify"

typedef enum
{
    EUploadFailedDataImageIDInvalid = 0,
    EUploadFailedDataImageDataInvalid = 1
}WSUploadFailedDataErrorCode;

//离线上传数据库表的data_type
//@"P" 代表普通照片
#define kOfflineTableDataType_P @"P"


#pragma mark - global state



#pragma mark  - Encrpytion
//  登陆密码 des加密方式下的私钥
#define LOGIN_PASSWORD_DES_PRIVATE_KEY  @"aRe2so3W"
//  是否加密密码
#define PasswordEncrypt @"PasswordEncrypt"


#endif // ifndef WinChannelIPhone_WinchannelIPhone_h

// 新增立即拜访的FC
#define IMMEDIATELY_VISIT_STORE_FC   @"IMMEDIATELY_VISIT_STORE_FC"

#define PARTNERSMSG_NOTIFY    @"partnerMsg"

#pragma mark - 门店拜访工作流
#define LEAVESTORE_FV @"V20S99"
#define ENTERSTORE_FV @"V20S01"

// YIHAIKERRY-3087 日常拜访
#define DAY_VISIT     @"V20A01"

#define RN_KEYIN_FV @"RN_001"

#define UNILEVERREADYCALLPLAN_FV @"spe_unileverReadyCallPlan"

#define UNILEVERORDERTEMPLATE_FV @"spe_unileverOrderTemplate"

//通知MainViewController更新badge
#define MAIN_VC_NEED_UPDATE_BADGE_NOTIFY @"MAIN_VC_NEED_UPDATE_BADGE_NOTIFY"
// IPAD 分屏的时候点击某一条信息发出通知
#define MYMSG_DETAIL_DIDSELECT_MESSAGE  @"MYMSG_DETAIL_DIDSELECT_MESSAGE"
// 公告信息界面返回的时候
#define DELETE_DETAILMSG_OR_REVERT_VIEW @"DELETE_DETAILMSG_OR_REVERT_VIEW"

#define WSAcvtDataGridComponentDataSource_NOTIFY_ISVALUECHANGE @"WSAcvtDataGridComponentDataSourceNOTIFYISVALUECHANGE"

#define CELL_DETAIL_TEXTCOLOR   ([UIColor colorForKey:@"StoreCellDetailColor"] ? [UIColor colorForKey:@"StoreCellDetailColor"] : [UIColor colorWithRed:163.0f/255 green:163.0f/255 blue:163.0f/255 alpha:1.0f] )

#define kSubmitAndTotalAcountColor         [UIColor colorForKey:@"SubmitAndTotalAcountColor"] ? [UIColor colorForKey:@"SubmitAndTotalAcountColor"]:[UIColor colorWithHexString:@"#3e86f5"]

// 是否登录成功，用于标记关于页面 "退出账户"按钮是否显示
#define APP_LOGIN_SUCCESS @"AppLoginSuccess"

// 表格页面与导航栏的间隙
#define SPACEHEIGTH         ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 10.0f : 15.0f)

// --------新逻辑 测试代码开关
//WSNewMsgViewController
#define MessageCellButtonClickedNotification @"MessageCellButtonClickedNotification"
//离线定位地址保存
#define LOCATION_ADDRESS  @"locationAddress"


// 显示宪章的配置（0为首次安装弹出，1为每次登陆弹出）
#define OPEN_TC_EVERY_TIME  @"OPEN_TC_EVERY_TIME"
// 删除门店成功的通知名称
#define DeleteNewAddStoreSucceed @"deleteNewAdddStoreSucceed"
// 删除门店md5的key
#define DelteStoreMD5_Key            @"deleteStoreMD5_Key"

#define SELECT_MAP_STORE_NOTIFICATION @"SelectMapStoreNotifcation"

#define SELECTED_MAP_STORE              @"SelectedMapStore"
// 门店分页数
#define  kStoreListPageCount   50

#define DROPLIST_TEXT_FONT [UIFont systemFontOfSize:14]

//消除ARC环境下使用performSelector出现的警告信息
#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

//

#define ALLSTOREOFINPLAN @"allStoreOfInPlan"
#define ALLSTOREOFOUTPLAN @"allStoresOfOutPlan"
#define CUSTOMQUERYSTORES @"customQueryStores"

#define k_SearchBarBorderColor  [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor]
#define k_SearchBarBgColor [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:0.8]

/*自定义Cell*/
#define WBC_Top_Margin ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 5 : 8)

#define WBC_Bottom_Margin WBC_Top_Margin

#define WBC_Left_Icon_Margin ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 10 : 15)

#define WBC_Title_Space ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 6 : 9)

#define WBC_Left_Icon_Width ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 40 : 60)

#define WBC_Left_Icon_Height ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 50 : 70)

#define WBC_Right_Button_Margin WBC_Left_Icon_Margin

#define WBC_Right_Button_Width ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 30 : 40)

#define WBC_Right_Button_Height WBC_Right_Button_Width

#define WBC_MAX_HEIGHT 3000

#define OUT_PAN_SEARCH_STORE @"OUTPAN_PLAN_SEARCH"

#define WSASVC_OUTPLANSTORE_REQUESTED_FLAG @"wsasvc_outplanstore_requested_flag"

#define WSCQVC_QUERY_STORE_SEARCH_OBJ_STR_FLAG @"wscqvc_query_store_search_obj_str_flag"

#define WSCQVC_QUERY_STORE_CITY_LIST @"wscqvc_query_store_city_list"
#define WSCQVC_QUERY_STORE_ORG_LIST @"wscqvc_query_store_org_list"
#define VISIT_PLAN_ROUTE @"visit_plan_route"

#define WSRF_DOWNLOAD_SEARCH_OBJ_STR_FLAG @"downloadFileUrlName"

#define  WINSFA_SHARE_DATA_TYPE    @"winsfa_share_data"

#define REQUEST_IS_FOR_PHOTO     @"requestIsForPhoto"

#define MAIN_NOTICE_HEIGHT      40

static const NSInteger WSDistanceInvliadAlertTag = 1009;

#define kRepairEnterStoreDateKey        @"repairEnterStoreDateKey"      //补录进店日期（年-月-日）
#define kRepairEnterStoreTimeKey        @"repairEnterStoreTimeKey"      //补录进店日期（时:分:秒）

#define IS_CONFIRM_LEAVE_STORE @"是否确定离店"
/*
获取立即拜访门店的拜访项相关数据的通知名称
 */
#define UPDATE_IMMEDIATELY_STORE_NOTIFY    @"update_immediately_store_notify"
#define ACVT_IS_FOR_TABLE @"acvt_is_for_table"

#define LUA_EXTRA @"@luaExtra"

#define kMjetLoginInfo @"MjetLoginInfo"
#define kMjetCookies   @"MjetCookies"

//拜访状态
#define ActionNotStart @"0"
#define ActionDone @"1"
#define ActionWorking @"2"
#define ActionAlreadyFilledOut @"3"
#define ActionFollow @"4" //MN-288 2018-02-03 关注动作


#define kNormalContentTextColor [UIColor colorForKey:@"NormalContentTextColor"]

#define kNormalContentTextFont  [UIFont fontForKey:@"NormalContentTextFont"]

#define BROWSERVC_WIDTH 1024

#define BROWSERVC_HEIGNT 768

//根据后台配置设置表格的宽度,用小a计算,下面同android相同.
#define DATAGRID_TITLE_UNITSIZE  (INTERFACE_IS_PHONE ? 14.0 : 16.0)
#define DETAILSIZEWIDTH [@"a" ws_sizeWithFont:[UIFont systemFontOfSize:DATAGRID_TITLE_UNITSIZE] constrainedToWidth:MAXFLOAT].width

#define DEFAULT_APP_PAGE_COUNT @"3"

#define GAIN_KEYBORE_HEIGHT_NOTIFICTION_NAME @"gain_keybord_height_notification_name"

#define WS_KEYBORD_HEIGTH @"ws_keybord_height"

#define WS_ACVT_VIEW_MOVE_HEIGHT @"ws_acvt_view_move_height"


#define kBlankItemID @"-1"
#define kBlankItemName @""

#define kCancelItemId @"-2"
#define kCancelItemName NSLocalizedString(@"cancel_label", nil)

#define PHOTO_NAMES            @"photonames"
#define ADD_ACVT_STORE_ISADD    @"isAdd"

#define ACVT_INIT_LUA_FUNCTION_HEAD @"function"

#define StoreIDFormat  @"{storeId}"
#define EmpIDFormat    @"{empId}"
#define SrIDFormat     @"{srId}"
#define AcvtIDFormat   @"{acvtId}"
#define BizDateFormat   @"{bizdate}"
#define QueryKeyFormat   @"{queryKey}"

#define LOGIN_MODIFY_PWD 14

#define GET_DATA_FROM_DATABASE  0

#define CALL_TEL_FV @"FV_TEL"
#define MORE_FV     @"FV_MORE"
#define REPOPRT_FV  @"FV_mobile_report"

//菜单显示形式
#define MENU_LAYOUT_LEFT       @"left"        //左侧
#define MENU_LAYOUT_NEXTSTEPS  @"nextSteps"   //底部下一步形式
#define MENU_LAYOUT_TAB        @"tabPanel"    //tab页


#define VISIT_TYPE_ACVT_CODE  @"visitType"
#define STORE_PREPARE_ACVT_CODE @"stores_zbzt"

#define PREPARE_STATE_READY  @"yzb"
#define PREPARE_STATE_NOT_PREPARE  @"wzb"

#define STORE_KPI_ACVT_CODE     @"storeKPI"


#define K_SEARCHBAR_BG_COLOR [UIColor colorWithRed:236.0f/255 green:240.0f/255 blue:241.0f/255 alpha:1.0f]

#define K_SEARCHBAR_HEIGHT 44.0f

#define LeftBarWidth 80.0

#define ANNOTATION_LABEL_WIDTH 15

#define ANNOTATION_LABEL_HEIGHT 8

#define  ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME  @"allplanstoreotherinfoontime"

#define CHANGE_ACVTSCROLLVIEW_OFFSET_NOTIFICATION  @"ChangeAcvtScrollViewOffSetNotification"

#define WSTEXTVIEWPANEL_CHANGED_HEIGHT   @"WSTextViewPannel_Changed_Height"

#define TITLE_TAB_VIEW_HEIGHT 55


#define CALENDER_LIMIT_DAY 6

#define SPLITVIEW_LEFT_DEFAULT_WIDTH 350


#define k_TopMsgViewWHRatio     0.47

#define k_MainkLeftVieWidth 200.0f

#pragma mark - log key

#define LOG_GET_ROOT_CONFIG_DATA              @"请求配置数据"
#define LOG_PROCESS_ROOT_CONFIG_DATA          @"处理配置数据"
#define LOG_GET_LOGIN_DATA                    @"请求登录数据"
#define LOG_CREATE_AND_UPDATE_DATABASE        @"创建和升级数据库"
#define LOG_PROCESS_JSON_DATA                 @"处理登录数据(合并)"
#define LOG_PROCESS_APP_DATA                  @"处理登录数据AppData"
#define LOG_LOGIN_CLEAR_DATA                  @"登录清理数据"
#define LOG_LOGIN_DATA_INSERT_DATABASE        @"登录数据入库"
#define LOG_PROCESS_STOREACVT_DIS_VALUE       @"处理storeacvtdis的id-value映射"
#define LOG_LOGIN_ALL_TIME                    @"登录总时间"

#define FV_TAB_V21001  @"TAB_V21001"

#define PHOTO_WALL_IMAGE_URL_PREFIX  @"sfa_Imgurl;"  // 照片强选中照片后拼接的前缀

#define kLevel2Password  @"level2Password"
#define USER_GESTURE_PASSWORD  @"USER_GESTURE_PASSWORD"
#define USER_GESTURE_PASSWORD_EXPIRED_DAYS  @"USER_GESTURE_PASSWORD_EXPIRED_DAYS"
#define USER_GESTURE_PASSWORD_LAST_USED_DATE  @"USER_GESTURE_PASSWORD_LAST_USED_DATE"
#define IS_UPDATE_STORE_ICON  @"isUpdateStoreIcon"

#define SUB_ACVT_USER_NEWID @"subAcvtUseNewId"

#define IMAGES_BUNDLE @"images.bundle"

#define ONLINE_CONSULTATION_SWITCH_STATE @"onlineConsultationSwitchState"



#define PHOTOTYPE_ALIYUN            @"aliyun:"
#define PHOTOTYPE_HTTP              @"http"
#define ALL_COLLECTED_PRODIDS       @"allCollectedProdIds"
#define PHOTO_JPG_SUFFIX            @".jpg"


#define LUA_SEPARATOR               @"@#"
#define QST_SEARCH_RANGE_SEPARATOR  @"@#"
#define QST_SEARCH_DISTANCE         @"distance|"


#define FRIEND_COMMUNITY_HAS_NEW_COMMENT          @"circle_01"
#define FRIEND_COMMUNITY_HAS_NEW_MESSAGE          @"circle_02"
#define FRIEND_COMMUNITY_NEW_MESSAGE_NOTIFICATION   @"friendNewMessageNotification"
#define FRIEND_COMMUNITY_DELETE_MESSAGE_NOTIFICATION   @"friendDeleteMessageNotification"

#define WeChatImgType @"link"
#define SCAN_BARCODE @"barcode"
#define SAVE_QSTCODE_AND_GENID @"SAVE_QSTCODE_AND_GENID"

#define LOG_FILE_COUNT @"LOG_FILE_COUNT"  //日志保存的最大数量，登录时下发
#define APPENDING_STRING_TAG @"¥¥"  //拼接字符串的分割符
//问卷和问卷上的图片上传成功后，重新加载webview的通知
#define ACVT_UPLOAD_SUCEESS_REFRESH_WEBVIEW_NOTIFY    @"acvtUploadSuccessRefreshWebviewNotify"

#define kBaseDictKey_seq            (@"dicts_sequence")

#define WeChat_SEPARATOR             @"#"

//跳转指定界面的通知
#define TAB_JUMP_NOTIFY    @"TabJumpNotify"
//跳转到指定的fc
#define TAB_JUMP_FC        @"TabJumpFC"
//条码分割符
#define PRODUCT_BARCODE_SEPARATOR @","

#define ALBUM_KEYANDID  @"album_keyandid"


#define kPropertyUserDefaultsKey @"kPropertyUserDefaultsKey"
//获取自动跳转时间
#define kAddAcvtAutoJumpTime @"addAcvtAutoJumpTime"
//菜单中Requrid 配置此参数，门店未拜访时直接进入
#define kRequrid_Directaccess  @"directaccess"

//史克地图角色
#define APPUSERINFOTYPE_PCH           @"PCH"
#define APPUSERINFOTYPE_TSKF          @"TSKF"
#define MAIN_TIPS                     @"maintips"


#define kWinStoreRouteResponseObjId @"storesRouteNames"
#define kWinStoreRouteInfoNodeObjId @"storesRouteActivityInfos"

#define kWinPOISearchNotifi         @"geoPoiSearchAddress"

/*位置隐私弹框*/
static NSString * const FUNCS_OPT_JUMPPRIVACYAGREEMENT         =  @"jumpPrivacyAgreement";



//助销
#define kHelpSales_Name                     @"助销"

#define kHelpSales_Complete_Name            @"已助销"

#define kVisit_Name                         @"拜访"


#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

// 判断是否为iPhone X及以上机型
#define IS_IPHONE_X \
({ \
BOOL isPhoneX = NO; \
if (@available(iOS 11.0, *)) { \
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject]; \
    if (window.safeAreaInsets.bottom > 0.0) { \
        isPhoneX = YES; \
    } \
} \
isPhoneX; \
})



#define USER_DEFAULT_OBJECT(key, defaultValue) [[NSUserDefaults standardUserDefaults] objectForKey:(key)] ?: (defaultValue)


#define USER_DEFAULT_SAFE_STRING(key) ([USER_DEFAULT_OBJECT(key, nil) isKindOfClass:[NSString class]] ? USER_DEFAULT_OBJECT(key, nil) : @"")

#define SET_USER_DEFAULT_OBJECT(value, key) [[NSUserDefaults standardUserDefaults] setObject:(value) forKey:(key)]; [[NSUserDefaults standardUserDefaults] synchronize]

//
//  AcvtBean_qst.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Iprintable.h"
#import "I_W_BuildInfo.h"
#import "IAttachment.h"

#define kAcvtNameMainTitle          @"1"
#define kAcvtNameSubTitle           @"2"
#define kAcvtNameLeftTitle          @"3"
#define kAcvtNameRightTitle         @"4"
#define kAcvtNameLeftImg            @"9"
#define kAcvtNameCalendarRightImg   @"10"
#define kAcvtNameCalendar           @"11"
#define kAcvtNameCalendarBottomImg  @"12"
#define kAcvtNameCalendarRightBottomImg   @"13"
#define kAcvtNameRightTitleColor    @"15"
//YIHAIKERRY-1142益海嘉里深圳分组需求
#define kAcvtNameGroupName          @"16"
#define kAcvtNameGroupSummary       @"17"
#define KAcvtNameGroupExPression    @"18"
//史克otc新增
#define KAcvtNameRequiredLogo    @"6"



#define kDisplayModeAddSub          @"add_sub"

//acvt问题的描述，有qst问题类型，数据源key，筛选key，opt选项数组，是否回显。


@class WSStoreBean;
@class WSFuncsBean;

@interface WSAcvtBean_qst : NSObject<Iprintable,I_W_BuildInfo,IAttachment,NSCopying>

@property (nonatomic, strong) NSString          *defaultValue;// 默认值
@property (nonatomic, copy/*, readonly*/) NSString          *dlen; // 最小长度
@property (nonatomic, copy/*, readonly*/) NSString          *mlen; // 最大长度
@property (nonatomic, copy/*, readonly*/) NSString          *mnum; // 最大值
@property (nonatomic, copy/*, readonly*/) NSString          *qstDesc; // 问题描述
@property (nonatomic, copy/*, readonly*/) NSString          *qstId;  // 问题的id
@property (nonatomic, copy/*, readonly*/) NSString          *acvtQstId; // 关联到acvtid
@property (nonatomic, copy/*, readonly*/) NSString          *qstCod; // 问题的编码
@property (nonatomic, copy/*, readonly*/) NSString          *qstName; // 问题title
@property (nonatomic, copy/*, readonly*/) NSString          *qstType; // 问题类型
@property (nonatomic, copy/*, readonly*/) NSString          *snum;  // 最小值
@property (nonatomic, strong/*, readonly*/) NSMutableArray  *opt;   // 答案
@property (nonatomic, copy/*, readonly*/) NSString          *ds;    // 数据源key
@property (nonatomic, copy/*, readonly*/) NSString          *align; // 为1 则显示大图
@property (nonatomic, strong) NSString *colKey;//益海嘉里计算总价折扣率用记录哪一列


/*
 <option value="1">1-主标题</option>
 <option value="2">2-副标题</option>
 <option value="3">3-左标题</option>
 <option value="4">4-右标题</option>
 <option value="5">5-主标题&内容</option>
 <option value="6">6-副标题&内容</option>
 <option value="7">7-左标题&内容</option>
 <option value="8">8-右标题&内容</option>
 */

@property (nonatomic, copy/*, readonly*/) NSString*           isAcvtName;// isAcvtName 1为主标题 2为副标题 （jira NESTLE-5）



@property (nonatomic/*, readonly*/, assign)   NSInteger     isSupperLocalPhoto;       //是否支持从本地选择照片(1标示支持从本地读取照片，0标示不支持，默认为0)

@property (nonatomic/*, readonly*/, assign)   NSInteger     maxPhoto;                 //可提交的照片最大数量(未指定为0，标示没有限制)

@property (nonatomic/*, readonly*/, copy) NSString *acvtNestedId; //问卷内嵌套问卷ID MSTD-1069首发

@property (nonatomic,assign) CGRect  posAndFrame;


/*
 * 辉瑞零售:is_rep为2时，代表groupName相同的一组内只要有一项填了就可以
 */
@property (nonatomic, copy) NSString          *is_req;

// 对于问题含附件类型的
@property (nonatomic,strong) NSObject<IAttachment> * attachment;

/*!
 *  校验逻辑相关  --老夏
 */
@property (nonatomic, copy /*, readonly*/) NSString         *mc; //菜单编码

@property (nonatomic, copy/*, readonly*/) NSString          *range; //

@property (nonatomic, copy/*, readonly*/) NSString          *func; //

@property (nonatomic, copy/*, readonly*/) NSString          *dds; //

/*!
 *  同时支持 2 条校验逻辑
 *  杨总 拍板
 */

@property (nonatomic, copy/*, readonly*/) NSString          *range2; //

@property (nonatomic, copy/*, readonly*/) NSString          *func2; //

@property (nonatomic, copy/*, readonly*/) NSString          *dds2;//


@property (nonatomic, copy/*, readonly*/) NSString          *filter; //对于数据源的筛选条件

@property (nonatomic, copy) NSString          *readonly; //只读

/*
 *  中粮稽核添加，用于校验时过滤产品，暂定 checkType 字段
 */
@property (nonatomic, copy/*, readonly*/) NSString          *checkType; //????

/*
 * 辉瑞零售添加，代表分组，表示同一组内有若干项必填的逻辑
 */
@property (nonatomic, copy/*, readonly*/) NSString          *groupName; // 多个问题的关联关系

//用于DV类型，多级联动的下拉框
@property (nonatomic, copy/*, readonly*/) NSString          *parent; //父级？？？

@property (nonatomic, copy/*, readonly*/) NSString          *parentQstId; //父级问题编号


@property (nonatomic, copy /*, readonly*/) NSString *alertTitle; //PA类型 首发 //???


@property (nonatomic, copy /*, readonly*/) NSString *color; //文本内容颜色

@property (nonatomic, copy /*, readonly*/) NSString *bgColor; //背景颜色

@property (nonatomic, copy/*, readonly*/) NSString *isHidden; //是否隐藏
@property (nonatomic, copy/*, readonly*/) NSString *needUploadData; //是否需要上传数据

@property (nonatomic, copy /*, readonly*/) NSString *script; //lua脚本字符串
//@property (nonatomic, copy) NSString *script; //lua脚本字符串

@property (nonatomic, copy /*, readonly*/) NSString *orientation; // 标题和UI控件是否上下显示（默认是上下，配置为1是水平）

@property (nonatomic, copy/*, readonly*/) NSString *hint;  //提示 （placeholder）

@property (nonatomic, copy /*, readonly*/) NSString *memo;

@property (nonatomic, copy /*, readonly*/) NSString *memo1;

@property (nonatomic, copy /*, readonly*/) NSString *memo2;

@property (nonatomic, copy /*, readonly*/) NSString *memo3;

@property (nonatomic, copy /*, readonly*/) NSString *memo4;

@property (nonatomic, copy /*, readonly*/) NSString *qstIconUrl;

@property (nonatomic, copy /*, readonly*/) NSString *charNum;

@property (nonatomic, copy /*, readonly*/) NSString *answerColor;

@property (nonatomic, copy /*, readonly*/) NSString *countrule;

@property (nonatomic, copy/*, readonly*/) NSString *buttonname;

@property (nonatomic, copy/*, readonly*/) NSString *displayMode; // 显示模式   新加 这个值 useMultilevelMenu 玛氏显示多级菜单用 DV类型

@property (nonatomic, copy ) NSString *tab;

@property (nonatomic, copy ) NSString *hideQstName;

@property (nonatomic, copy ) NSString *hideQstOptName;

@property (nonatomic, copy ) NSString *reg;

@property (nonatomic, copy) NSString *hiddenBottomline;

@property (nonatomic, copy) NSString *widthPercent;  //多个问题在一行显示时，每个问题占总宽度的百分比， 比Q1=0.2,Q2=0.3,Q3=0.5，同一行的所有问题相加必须=1


@property (nonatomic, copy) NSString *isCoverNewId;  //照片回显删除保存方式

@property (nonatomic, copy) NSString *widgetType;

@property (nonatomic, copy) NSString *acvtId;
@property (nonatomic, copy) NSString *dependon;

/*
 locationType，定位类型，值有三种：
 0：不允许定位，只显示回显的位置，坐标和地址均为回显位置。（无回显时显示空）（定位按钮不可点击）
 1：自动定位 （缺省值），初始化后自动定位一次（与原有方式一致）
 2：手动定位，初始化后只显示回显位置，坐标和地址均为回显位置，只有手动点击“定位”按钮才定位，手动定位后地址显示为当前位置。（无回显时，初始化时自动定位一次）
 
 locationType为3时，蒙牛项目门头照 和 退货订单中 照片显示经纬度  MN-4294

 注意事项:
 
 整个菜单为只读时，应该设置定位问题locationType为0，因为整个菜单都为只读，肯定不需要定位功能。
 
 上传时，locationType为2，且手动定位成功后，应该上传定位位置；如果没有手动定位或定位失败，上传回显位置。
 
 配置为必填时，如果没有定位默认会强制等待xx秒，如果locationType为2，且有回显值，代表之前已有位置，不需要修改，因此即使未手动定位也不需要等待xx秒。
 
 该参数逻辑与是否readonly无关，readonly跟原来逻辑一样，仅控制地图是否可以拖动。
 
 */
@property (nonatomic, copy) NSString *locationType;


@property (nonatomic, copy) NSString *verticalGroupName; // 纵向分组名称

/**
 可配 top,bottom  问题固定顶部或者底部
 */
@property (nonatomic, copy) NSString *layout_gravity;
@property (nonatomic, copy) NSString *is_not_water_mark;//是否有水印

@property (nonatomic, assign) BOOL isNoInset; // 文字和边框是否有间距

@property (nonatomic, copy) NSString *titleReadColor;
@property (nonatomic, copy) NSString *valueReadColor;
@property (nonatomic, copy) NSString *valueColor;
@property (nonatomic, copy) NSString *titleSize;
@property (nonatomic, copy) NSString *valueSize;

- (id)initWithObject:(id)object;

- (id)initAcvtQstWithFuncsParam:(WSFuncsBean_Param *)funcsBeanParam withAcvtId:(NSString *)acvtId;

- (void)setCheckType:(NSString*)checkType;

@end

//
//  FuncsBean.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSFuncsBean_opt.h"

@class WSFuncsBean_opt;

@interface WSFuncsBean : NSObject

    
@property (nonatomic, strong, readonly) NSString        *fc;
@property (nonatomic, strong, readonly) NSString        *name;
@property (nonatomic, strong, readonly) NSString        *fv;
@property (nonatomic, strong) NSString        *required;
@property (nonatomic, strong, readonly) WSFuncsBean_opt   *opt;
@property (nonatomic, strong, readonly) NSString        *ds;
@property (nonatomic, strong, readonly) NSMutableArray  *paramArray;
@property (nonatomic, strong, readonly) NSMutableArray  *otherArray;
@property (nonatomic, strong, readonly) NSString        *filter;
@property (nonatomic, strong, readonly) NSString        *sqlw;
@property (nonatomic, strong, readonly) NSString        *submenu;
@property (nonatomic, strong, readonly) NSString        *styp;
@property (nonatomic, strong, readonly) NSString        *showtyp;
@property (nonatomic, strong, readonly) NSString        *dateTyp;
@property (nonatomic, strong, readonly) NSString        *cocall;
@property (nonatomic, strong, readonly) NSString        *cochk;
@property (nonatomic, strong, readonly) NSString        *empTyp;
@property (nonatomic, strong, readonly) NSString        *typ;
@property (nonatomic, assign, readonly) int             readonly;
@property (nonatomic, copy, readonly)   NSString        *redis;
@property (nonatomic, strong, readonly) NSString        *unredo;
@property (nonatomic, strong, readonly) NSString        *method;
@property (nonatomic, strong, readonly) NSString        *defaultString;
@property (nonatomic, strong, readonly) NSString        *value;
@property (nonatomic, strong, readonly) NSString *icon;
@property (nonatomic, strong, readonly) NSString *iconOfDone;
@property (nonatomic, strong, readonly) NSString *shortCutURL;
@property (nonatomic, assign, readonly) NSInteger       sort;
// showing subfunctions
@property (nonatomic, strong, readonly) NSString *display;
/**first col width 首列宽  单位：像素*/
@property (nonatomic, assign, readonly) int         wfcol;
/**first col width 首列宽  单位：字数 */
@property (nonatomic, assign, readonly) int         fCharNum;


/**列宽  单位：字数 */
@property (nonatomic, assign, readonly) int         charNum;
//是否上传空值的字段
@property (nonatomic, assign, readonly) int         nullvalue;



@property (nonatomic, assign, readonly) int         maxRow;
@property (nonatomic, assign, readonly) BOOL        lockCol;

@property (nonatomic, assign, readonly) int         colNum;

//史克医院 RM-MR评分中应该只能给MR评分，点击DM不应该进入下级评分页面 层级锁定
@property (nonatomic, assign, readonly) BOOL        lockLevel;
@property (nonatomic, strong, readonly) NSString    *isAcvtList;
@property (nonatomic, strong, readonly) NSString    *isStoreInfo;

// 中粮特有，离店后是否可以再次点击门店
@property (nonatomic, copy, readonly) NSString *repeatvisit;

@property (nonatomic, strong, readonly) NSDictionary *otherInfoDictionary;
/**用来保存子funcs*/
@property (nonatomic, strong) NSMutableArray *funcsArray;

@property(nonatomic,strong,readonly) NSMutableArray* menuArray;

/**according this flag showing the more button 1:showing 0:not showing default is 1*/
@property(nonatomic,strong,readonly) NSString* is_more;

@property (nonatomic, strong)WSFuncsBean *iParentFuncsBean;

//仅供本地使用，用于iPad横版时，存储左侧每一个对应cell的dadge标识，防止cell重用时，该数据丢失
@property (nonatomic, copy)NSString *eventIdentifer;

@property (nonatomic, strong)NSString   *buttonName;

@property (nonatomic, strong)NSString *jumpUrl;

@property (nonatomic, assign) BOOL      isHomePageWillShow;
@property (nonatomic, assign) BOOL      isloginRedirectFcWillShow; // loginRedirectFc即将弹出的页面

@property (nonatomic, strong)NSString *iosOpenUrl;

@property (nonatomic, copy, readonly) NSString *script;

@property (nonatomic, strong )NSString *levelCode;

@property (nonatomic, strong )NSString *sendRequest;

//SFALHLH-100【ios联合利华】增加参数menuLayout控制菜单导航显示 left左侧导航 ,nextSteps为下一步底部导航
@property (nonatomic, strong)NSString *menuLayout;

//SFALHLH-112 [联合利华]菜单新增参数storeFilter控制通过门店某个属性筛选门店
@property(nonatomic,copy) NSString *storesFilter;

/**
 *  SFALHLH-184	[l联合利华]添加菜单参数alignBottom控制功能左侧导航位置是否从下往上显示
 */
@property(nonatomic,copy) NSString *alignBottom;

@property(nonatomic,copy) NSString *showThumbnail;

@property(nonatomic,copy) NSString *menuType;

@property(nonatomic, copy) NSString *menuStyle;

@property(nonatomic,copy) NSString *pk;

@property(nonatomic,copy) NSString *fk;
//用以隐藏空菜单
@property (nonatomic, strong) NSString *hiddenEmpty;

@property (nonatomic, strong) NSString *topTip; // 置顶提醒

@property(nonatomic,copy) NSString *pageTag;


//2018-01-17-MSTD-7535
@property (nonatomic, copy) NSString *defaultInfo;      //默认信息(无数据情况展示使用)
@property (nonatomic, copy) NSString *defaultImageUrl;  //默认图片url(无数据情况展示使用)
@property (nonatomic, copy) NSString *noticeNumFc;//字段noticeNumFc 用于标识 上级菜单要给哪个下级菜单统计

//SFA-34430
@property(nonatomic,copy) NSString *kqArrange;///<考勤安排

- (id)initFuncsWithObject:(id)object;

/**
 * 用于以表格形式展示acvt列表（箭牌增加）
 **/
- (void)setParamArrayFromOut:(NSArray *)paramArray;

@end

//
//  StoreBean.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PayDisPlayBeanArray.h"
#import "I_W_OptionDataItem.h"
#import "I_W_Cell.h"
#import "WSMappingObject.h"

typedef NS_ENUM(NSUInteger, WSStoreAccessMode) {
    
    WSStoreAccessModeNormal,//正常拜访的店(计划内，计划外)
    WSStoreAccessModeSubEmp //随访下属的店(计划内，计划外)
};

typedef enum {
    ACCESS_STATUS_TYPE_UN_BEGIN,//0未开始
    ACCESS_STATUS_TYPE_IN,      //1进店
    ACCESS_STATUS_TYPE_OUT,     //2离店
}
ACCESS_STATUS_TYPE;

@interface WSStoreBean : NSObject <NSCopying, I_W_OptionDataItem, I_W_Cell>

@property (nonatomic, assign) BOOL isRestSrid;                                       //是否重制过 srid
@property (nonatomic, strong) NSString *empId;
@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSString *sid;
@property (nonatomic, strong) NSString *n;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *shortName;
@property (nonatomic, assign) BOOL plan;
@property (nonatomic, strong) NSString *is_plan;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *acvt_genId;
@property (nonatomic, strong) NSString *pid;
@property (nonatomic, strong) NSString *cellid;
@property (nonatomic, strong) NSString *procTypId;
@property (nonatomic, strong) NSString *typ;
@property (nonatomic, strong) NSString *addr;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *styp;
@property (nonatomic, strong) NSString *linkman;
@property (nonatomic, strong) NSString *linktel;
@property (nonatomic, copy) NSString *srid;                                         //主管拜访时，所拜访门店的下属id
@property (nonatomic, copy) NSString *orgId;                                        //主管拜访时，所拜访门店的下属岗位id
@property (nonatomic, copy) NSString *miniumalDuration;                             //时间间隔
@property (nonatomic, strong) NSString *canClick;                                   //泸州老窖 代表点击不可跳转
@property (nonatomic, copy) NSString *bfnum;                                        //辉瑞Etrip新增，门店当月拜访次数
@property (nonatomic, copy) NSString *sfnum;                                        //辉瑞Etrip新增，门店当月随访次数
@property (nonatomic, strong) NSString *sv;
@property (nonatomic, assign) BOOL bPlanned;                                        //Etrip新增，拜访计划设置
@property (nonatomic, strong) NSString *drId;                                       //分销规则组的id,根据此id查找属于此门店的产品，若无则根据门店id查找
@property (nonatomic, assign) ACCESS_STATUS_TYPE access_status;
@property (nonatomic, assign) BOOL isaccessed;
@property (nonatomic, copy) NSString *storesFilter;                                 //[联合利华]菜单新增参数storeFilter控制通过门店某个属性筛选门店
@property (nonatomic, strong) NSMutableArray *storeprodArray;
@property (nonatomic, strong) NSMutableArray *promsArray;
@property (nonatomic, strong) NSMutableArray *acvtsArray;
@property (nonatomic, strong) NSMutableArray *acvtDisArray;
@property (nonatomic, strong) NSMutableArray *comptArray;
@property (nonatomic, strong) NSMutableArray *hosArray;
@property (nonatomic, strong) NSString *noteName;
@property (nonatomic, assign) BOOL isEnter;
@property (nonatomic, assign) BOOL isLeave;
@property (nonatomic, copy) NSString *update_md5id;
@property (nonatomic, strong) NSNumber *seq;
@property (nonatomic, strong) NSString *cpyCode;
@property (nonatomic, strong) NSString *py;
@property (nonatomic, strong) NSString *custIdf;
@property (nonatomic, strong) NSString *tel;
@property (nonatomic, strong) NSString *locCode;
@property (nonatomic, strong) NSString *icrat;
@property (nonatomic, strong) NSString *isSelect;
@property (nonatomic, strong) NSMutableArray *saleProdArray;
@property (nonatomic, strong) NSMutableArray *shiptoArray;                          // 送货地址
@property (nonatomic, strong) NSMutableArray *equArray;                             // 设备信息
@property (nonatomic, strong) NSMutableArray *salepromArray;                        // 促销活动
@property (nonatomic, strong) NSMutableArray *rebateArray;                          // 返利活动
@property (nonatomic, strong) NSMutableArray *prodArray;                            // 产品信息  销售产品
@property (nonatomic, strong) NSMutableArray *invProdArray;                         // 库存价格采集产品列表
@property (nonatomic, strong) NSMutableArray *cmdArray;                             // 指令集
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double actualVisitLongitude;
@property (nonatomic, assign) double actualVisitLatitude;
@property (nonatomic, strong) NSMutableArray *inArray;
@property (nonatomic, copy) NSString *iStoreIdentify;                               //医生id
@property (nonatomic, assign) WSStoreAccessMode storeAccessMode;
@property (nonatomic, retain, readonly) PayDisPlayBeanArray *payDisplayBeanArray;
@property (nonatomic, copy) NSString *actionState;
@property (nonatomic, copy) NSString *optName;                                      //<拜访状态服务器的状态
@property (nonatomic, copy) NSString *monthVisitNumber;                             //<本月拜访次数
@property (nonatomic, copy) NSString *answer;                                       //<橙色采集本地的结果
@property (nonatomic, strong) NSString *beaconUUId;
@property (nonatomic, strong) NSString *level_code;
@property (nonatomic, strong) NSMutableArray *sonBean;
@property (nonatomic, assign) BOOL isExpland;                                       //当前节点下有子节点被展开
@property (nonatomic, assign) BOOL isAllExpand;                                     //是否展开所有子节点
@property (nonatomic, assign) BOOL isOption;
@property (nonatomic, strong) NSString *colorStr;
@property (nonatomic, strong) NSString *detail_info;
@property (nonatomic, strong) NSString *mappingStoreListFV;
@property (nonatomic, strong) NSString *mappingStoreListFC;
@property (nonatomic, strong) NSString *mappingStoreFc;
@property (nonatomic, assign) BOOL inReadonlyMode;
@property (nonatomic, copy) NSString *storeImg;
@property (nonatomic, strong) NSString *item_name;
@property (nonatomic, strong) NSString *departmentId;
@property (nonatomic, strong) NSString *prepareState;
@property (nonatomic, strong) NSString *visitType;
@property (nonatomic, strong) NSString *visitPlanMapOrder;
@property (nonatomic, strong) NSString *last_man;
@property (nonatomic, copy) NSString *last_date;
@property (nonatomic, copy) NSString *last_transaction;
@property (nonatomic, copy) NSString *store_month_visit_time;
@property (nonatomic, copy) NSString *last_num_q;
@property (nonatomic, strong) NSString *distance;
@property (nonatomic, assign) double f_distance;
@property (nonatomic, copy) NSString *row_number;
@property (nonatomic, strong) NSString *local_ImageID;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, assign) BOOL hasGetStateData;
@property (nonatomic, assign) BOOL isSubEmpInfo;
@property (nonatomic, copy) NSString *attri;                                        //门店图片集合
@property (nonatomic, copy) NSString *mapPicDis;                                    //地图回显的小图标
@property (nonatomic, copy) NSString *dotDisplay;                                   //地图回显的小图标的文字
@property (nonatomic, copy) NSString *visitcontent;                                 //泸州老窖 工作轨迹 拜访内容显示
@property (nonatomic, assign) BOOL isShowMapCallout;                                //是否需要显示 气泡
@property (nonatomic, assign) BOOL isShowStoreDetailCallout;                        //显示经纬度，名称 地址
@property (nonatomic, assign) BOOL isFakeStore;                                     //不是真正的门店，后台没有下发该门店数据
@property (nonatomic, copy) NSString *isRouteStore;                                 //是否为路线内的门店,如果为 路线计划内的店要走计划外请求逻辑
@property (nonatomic, copy) NSString *follow;                                       //是否关注
@property (nonatomic, copy) NSString *currentAddress;
@property (nonatomic, assign) BOOL isAcctuallyRouteStore;                           //是否是实际路线 ,MN-286 适用于实时点名功能的拜访轨迹
@property (nonatomic, assign) BOOL isAcctuallyAndInPlanStore;                       //是实际路线并且属于计划内的店,大头针紫色显示
@property (nonatomic, strong) NSArray *auxiliaryInfoArray;                          //辅助信息数组
@property (nonatomic, copy) NSString *inTime;                                       //进店时间
@property (nonatomic, copy) NSString *outTime;                                      //离店时间
@property (nonatomic, copy) NSString *instore_time;                                 //在店时间
@property (nonatomic, copy) NSString *qrcode;                                       //门店信息二维码
@property (nonatomic, copy) NSString *custCode;                                     //辅助编码
@property (nonatomic, copy) NSString *ctyp;                                         //门店渠道
@property (nonatomic, assign) BOOL isToadyVisit;                                    //是否今日拜访
@property (nonatomic, assign) BOOL isMonthVisit;                                    //是否当月已拜访
@property (nonatomic, assign) BOOL isOrangeStoreVisit;                              //是否橙色门店已拜访
@property (nonatomic, copy) NSString *routeVisitState;                              //访问路线标识
@property (nonatomic, copy) NSString *routeName;
@property (nonatomic, copy) NSString *monthHelpVisitNumber;                         //<本月拜访次数
@property (nonatomic, copy) NSString *fromModuleName;

- (instancetype)initStoreWithObject:(id)object IsPlan:(BOOL)isPlan;
- (instancetype)initStoreWithObjectForSer:(id)object;
- (instancetype)initStoreWithObject:(id)object IsPlan:(BOOL)isPlan storeAccessMode:(WSStoreAccessMode)accessMode;
- (instancetype)initStoreWithObject:(id)object IsPlan:(BOOL)isPlan noteName:(NSString *)aNoteName;
- (instancetype)initstoreWithBaseStoreObject:(WSBaseStoreObject *)baseStoreObject isPlan:(BOOL)isPlan;
- (instancetype)initStoreForWSAppDataWithObject:(id)object IsPlan:(BOOL)isPlan noteName:(NSString *)aNoteName;
- (instancetype)initStoreWithId:(NSString *)aStoreId andName:(NSString *)aName andPlan:(BOOL)aIsPlan;
- (void)reSetStore:(id)object Key:(NSString *)key;
- (WSStoreBean *)initNeighborStoreWithDic:(NSDictionary*)dic;
- (NSDictionary *)calcAllAcvts:(NSString *)acvtId;
- (void)addAcvtArrayFromStores:(NSArray *)acvtArray;
- (void)setStoreWith:(WSBaseStoreObject *)storeObject;
- (void)addAcvtDis:(NSDictionary *)objectDic;
- (void)modifyStoreInfo:(NSDictionary *)storeInfo;
- (NSString *)getDisplayNameAndCode;

@end

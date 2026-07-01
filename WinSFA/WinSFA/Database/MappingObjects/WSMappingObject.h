//
//  WSMappingObject.h
//  WinSFA
//
//  Created by zhangke on 14/9/2.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark ---------WSAddAcvtObject


//@interface WSAddAcvtObject : NSObject
//
//@property (assign) int                  ID;
//@property (strong, nonatomic) NSString  *emp_id;
//@property (strong, nonatomic) NSString  *biz_date;
//@property (strong, nonatomic) NSString  *name;
//@property (strong, nonatomic) NSString  *upload_flag;
//@property (strong, nonatomic) NSString  *func_code;
//@property (strong, nonatomic) NSString  *acvt_datas;
//@property (strong, nonatomic) NSString  *store_id;
//@property (strong, nonatomic) NSString  *md5;
//@property (strong, nonatomic) NSString  *acvt_id;
//@property (strong, nonatomic) NSString  *func_view;
///**
// 对店的调查问卷新增为作为店（史克医院）
// */
//@property (strong, nonatomic) NSString  *acvt_newstoreid;
//
//@property (strong, nonatomic) NSString *islocal;
//
//
//
//@end


@interface WSAddProductObject : NSObject

@property (assign) int                  ID;
@property (strong, nonatomic) NSString  *sr_id;
@property (strong, nonatomic) NSString  *acvt_id;
@property (strong, nonatomic) NSString  *emp_id;
@property (strong, nonatomic) NSString  *espn_id;
@property (strong, nonatomic) NSString  *store_id;
@property (strong, nonatomic) NSString  *product_id;
@property (strong, nonatomic) NSString  *biz_date;
@property (strong, nonatomic) NSString  *upload_flag;
@property (strong, nonatomic) NSString  *upload_date;
@property (strong, nonatomic) NSString  *img_idx;
@property (strong, nonatomic) NSString  *func_code;
@property (strong, nonatomic) NSString  *func_view;
@property (strong, nonatomic) NSString  *memo;
@property (strong, nonatomic) NSString  *serverrequire;
@property (strong, nonatomic) NSString  *update_md5id;

@end



@interface WSAddProductQstObject : NSObject

@property (assign) int                  ID;
@property (strong, nonatomic) NSString  *ans_id;
@property (strong, nonatomic) NSString  *qst_id;
@property (strong, nonatomic) NSString  *opt_id;
@property (strong, nonatomic) NSString  *opt_val;
@property (strong, nonatomic) NSString  *qst_type;


@end


//@interface WSAddStoreObject : NSObject <NSCopying>{
//}
//
//@property (assign) int                  ID;
//@property (strong, nonatomic) NSString  *sr_id;
//@property (strong, nonatomic) NSString  *acvt_id;
//@property (strong, nonatomic) NSString  *emp_id;
//@property (strong, nonatomic) NSString  *rspn_id;
//@property (strong, nonatomic) NSString  *store_id;
//@property (strong, nonatomic) NSString  *biz_date;
//@property (strong, nonatomic) NSString  *upload_flag;
//@property (strong, nonatomic) NSString  *upload_date;
//@property (strong, nonatomic) NSString  *img_idx;
//@property (strong, nonatomic) NSString  *func_code;
//@property (strong, nonatomic) NSString  *func_view;
//@property (strong, nonatomic) NSString  *is_planed;
//@property (strong, nonatomic) NSString  *memo;
//@property (strong, nonatomic) NSString  *update_md5id;
//@property (strong, nonatomic) NSString  *store_type;
//@property (strong, nonatomic) NSString  *store_name;
//@property (strong, nonatomic) NSString  *add_type;
//@property (strong, nonatomic) NSString  *is_local;
////非数据库字段 标识该店是否被选中（WSNewStoreListViewController）。
//@property (assign, nonatomic) BOOL isChecked;
//
//@property (strong, nonatomic) NSString *store_code;
//@end
//
//
//
//@interface WSAddStoreQstObject : NSObject<NSCopying>
//
//@property (assign) int                  ID;
//@property (strong, nonatomic) NSString  *ans_id;
//@property (strong, nonatomic) NSString  *qst_id;
//@property (strong, nonatomic) NSString  *opt_id;
//@property (strong, nonatomic) NSString  *opt_val;
//@property (strong, nonatomic) NSString  *qst_type;
//@property (strong, nonatomic) NSString  *acvt_id;
//@property (strong, nonatomic) NSString  *titletype;
//@property (strong, nonatomic) NSString  *newstoreid;
//
//
//@end





@interface WSBaseStoreDataObject : NSObject

@property (assign) int                  ID;
@property (strong, nonatomic) NSString  *emp_id;
@property (strong, nonatomic) NSString  *store_id;
@property (strong, nonatomic) NSString  *type;
@property (strong, nonatomic) NSString  *biz_date;
@property (strong, nonatomic) NSString  *item1;
@property (strong, nonatomic) NSString  *item2;
@property (strong, nonatomic) NSString  *item3;
@property (strong, nonatomic) NSString  *item4;
@property (strong, nonatomic) NSString  *item5;
@property (strong, nonatomic) NSString  *item6;
@property (strong, nonatomic) NSString  *item7;
@property (strong, nonatomic) NSString  *item8;
@property (strong, nonatomic) NSString  *item9;
@property (strong, nonatomic) NSString  *item10;

@end


@interface WSCustomTimeObject : NSObject

@property (assign) int                  ID;
@property (strong, nonatomic) NSString  *emp_id;
@property (strong, nonatomic) NSString  *store_id;
@property (strong, nonatomic) NSString  *enter_store_fc;
@property (strong, nonatomic) NSString  *upload_flag;
@property (strong, nonatomic) NSString  *enter_dispose_time;
@property (strong, nonatomic) NSString  *custom_enter_date;
@property (strong, nonatomic) NSString  *custom_enter_time;
@property (strong, nonatomic) NSString  *leave_dispose_time;
@property (strong, nonatomic) NSString  *custom_leave_data;
@property (strong, nonatomic) NSString  *custom_leave_time;
@property (strong, nonatomic) NSString  *biz_date;
@property (strong, nonatomic) NSString  *memo1;
@property (strong, nonatomic) NSString  *memo2;
@property (strong, nonatomic) NSString  *memo3;

@end


@interface WSDictObject : NSObject <I_W_OptionDataItem>


@property (assign) int                  ID;
@property (strong, nonatomic) NSString  *idx;
@property (strong, nonatomic) NSString  *dict_id;
@property (strong, nonatomic) NSString  *col1;
@property (strong, nonatomic) NSString  *col2;
@property (strong, nonatomic) NSString  *col3;
@property (strong, nonatomic) NSString  *col4;
@property (strong, nonatomic) NSString  *col5;
@property (strong, nonatomic) NSString  *col6;
@property (strong, nonatomic) NSString  *col7;
@property (strong, nonatomic) NSString  *col8;
@property (strong, nonatomic) NSString  *col9;
@property (strong, nonatomic) NSString  *col10;
@property (strong, nonatomic) NSString  *col11;
@property (strong, nonatomic) NSString  *col12;
@property (strong, nonatomic) NSString  *fl;

@end


//@interface WSFacObject : NSObject
//
//
//@property (assign) int                  ID;
//@property (strong, nonatomic) NSString  *sr_id;
//@property (strong, nonatomic) NSString  *acvt_id;
//@property (strong, nonatomic) NSString  *emp_id;
//@property (strong, nonatomic) NSString  *rspn_id;
//@property (strong, nonatomic) NSString  *store_id;
//@property (strong, nonatomic) NSString  *biz_date;
//@property (strong, nonatomic) NSString  *upload_flag;
//@property (strong, nonatomic) NSString  *upload_date;
//@property (strong, nonatomic) NSString  *img_idx;
//@property (strong, nonatomic) NSString  *func_code;
//@property (strong, nonatomic) NSString  *func_view;
//@property (strong, nonatomic) NSString  *is_planed;
//@property (strong, nonatomic) NSString  *memo;
//@property (strong, nonatomic) NSString  *p_gen_id;
//
//@end
//
//
//@interface WSFacQstObject : NSObject
//
//@property (assign) int                  ID;
//@property (strong, nonatomic) NSString  *ans_id;
//@property (strong, nonatomic) NSString  *qst_id;
//@property (strong, nonatomic) NSString  *opt_id;
//@property (strong, nonatomic) NSString  *opt_val;
//@property (strong, nonatomic) NSString  *qst_type;
//
//@end


@interface WSFdtObject : NSObject

@property (assign) int                  ID;
@property (strong, nonatomic) NSString  *func_code;
@property (strong, nonatomic) NSString  *func_view;
@property (strong, nonatomic) NSString  *is_planed;
@property (strong, nonatomic) NSString  *org_id;
@property (strong, nonatomic) NSString  *store_id;
@property (strong, nonatomic) NSString  *emp_id;
@property (strong, nonatomic) NSString  *biz_date;
@property (strong, nonatomic) NSString  *upload_date;
@property (strong, nonatomic) NSString  *upload_flag;
@property (strong, nonatomic) NSString  *img_idx;
@property (strong, nonatomic) NSString  *sr_id;
@property (strong, nonatomic) NSString  *memo;
@property (strong, nonatomic) NSString  *memo1;
@property (strong, nonatomic) NSString  *memo2;
@property (strong, nonatomic) NSString  *memo3;
@property (strong, nonatomic) NSString  *memo4;
@property (strong, nonatomic) NSString  *memo5;
@property (strong, nonatomic) NSString  *memo6;
@property (strong, nonatomic) NSString  *memo7;
@property (strong, nonatomic) NSString  *memo8;
@property (strong, nonatomic) NSString  *memo9;
@property (strong, nonatomic) NSString  *memo10;
@property (strong, nonatomic) NSString  *title;

@end

@interface WSFptObject : NSObject


@property (assign) int                  ID;
@property (strong, nonatomic) NSString  *func_code;
@property (strong, nonatomic) NSString  *func_view;
@property (strong, nonatomic) NSString  *is_planed;
@property (strong, nonatomic) NSString  *org_id;
@property (strong, nonatomic) NSString  *store_id;
@property (strong, nonatomic) NSString  *emp_id;
@property (strong, nonatomic) NSString  *biz_date;
@property (strong, nonatomic) NSString  *upload_date;
@property (strong, nonatomic) NSString  *upload_flag;
@property (strong, nonatomic) NSString  *img_idx;
@property (strong, nonatomic) NSString  *sr_id;
@property (strong, nonatomic) NSString  *memo;
@property (strong, nonatomic) NSString  *memo1;
@property (strong, nonatomic) NSString  *memo2;
@property (strong, nonatomic) NSString  *memo3;
@property (strong, nonatomic) NSString  *memo4;
@property (strong, nonatomic) NSString  *memo5;
@property (strong, nonatomic) NSString  *memo6;
@property (strong, nonatomic) NSString  *memo7;
@property (strong, nonatomic) NSString  *memo8;
@property (strong, nonatomic) NSString  *memo9;
@property (strong, nonatomic) NSString  *memo10;
@property (strong, nonatomic) NSString  *title;


@end



@interface WSImagePathObject : NSObject

@property (assign) int                  ID;
@property (strong, nonatomic) NSString  *img_idx;
@property (strong, nonatomic) NSString  *img_path;
@property (strong, nonatomic) NSString  *biz_date;
@property (strong, nonatomic) NSString  *upload_date;
@property (strong, nonatomic) NSString  *upload_flag;

@end


@interface WSInoutStoreObject : NSObject

@property (assign) int                  ID;
@property (strong, nonatomic) NSString  *store_id;
@property (strong, nonatomic) NSString  *emp_id;
@property (strong, nonatomic) NSString  *is_planed;
@property (strong, nonatomic) NSString  *biz_date;
@property (strong, nonatomic) NSString  *intime;
@property (strong, nonatomic) NSString  *outtime;
@property (strong, nonatomic) NSString  *img_idx;
@property (strong, nonatomic) NSString  *memo;
@property (strong, nonatomic) NSString  *upload_date;
@property (strong, nonatomic) NSString  *upload_flag;
@property (strong, nonatomic) NSString  *in_lon;
@property (strong, nonatomic) NSString  *in_lat;
@property (strong, nonatomic) NSString  *out_lon;
@property (strong, nonatomic) NSString  *out_lat;
@property (strong, nonatomic) NSString  *in_callid;
@property (strong, nonatomic) NSString  *out_callid;
@property (strong, nonatomic) NSString  *sr_id;
@property (strong, nonatomic) NSString  *func_code;
@property (strong, nonatomic) NSString  *memo1;
@property (strong, nonatomic) NSString  *memo2;
@property (strong, nonatomic) NSString  *memo3;
@property (strong, nonatomic) NSString  *memo4;
@property (strong, nonatomic) NSString  *memo5;
@property (strong, nonatomic) NSString  *memo6;
@property (strong, nonatomic) NSString  *memo7;
@property (strong, nonatomic) NSString  *memo8;
@property (strong, nonatomic) NSString  *memo9;
@property (strong, nonatomic) NSString  *memo10;
@property (strong, nonatomic) NSString  *title;
@property (copy, nonatomic) NSString *visit_id;
@property (copy, nonatomic) NSString *modulefc;
@property (strong, nonatomic) NSString *local_image;
@property (copy, nonatomic) NSString *needtip;
@property (copy, nonatomic) NSString *name;

@end



@interface WSOffLineUploadObject : NSObject

@property (assign) int  ID;
@property (strong, nonatomic) NSString  *emp_id;
@property (strong, nonatomic) NSString  *biz_date;
@property (strong, nonatomic) NSString  *upload_flag;
@property (strong, nonatomic) NSString  *upload_data;
@property (strong, nonatomic) NSString  *url;
@property (strong, nonatomic) NSString  *img_idx;
@property (strong, nonatomic) NSString  *is_photo;
@property (strong, nonatomic) NSString  *notify;
@property (strong, nonatomic) NSString  *data_type;
@property (strong, nonatomic) NSString  *photo_filename;

@end


@interface WSProductObject : NSObject <I_W_OptionDataItem>


@property (assign) int                  ID;
@property (strong, nonatomic) NSString  *idx;
@property (strong, nonatomic) NSString  *prod_id;
@property (strong, nonatomic) NSString  *dist;
@property (strong, nonatomic) NSString  *pri;
@property (strong, nonatomic) NSString  *inv;
@property (strong, nonatomic) NSString  *aging;
@property (strong, nonatomic) NSString  *disp;
@property (strong, nonatomic) NSString  *sdisp;
@property (strong, nonatomic) NSString  *cmpt;
@property (strong, nonatomic) NSString  *oos;
@property (strong, nonatomic) NSString  *mtd;
@property (strong, nonatomic) NSString  *ord;
@property (strong, nonatomic) NSString  *gofa;
@property (strong, nonatomic) NSString  *otherdicts;
@property (strong, nonatomic) NSString  *item1;
@property (strong, nonatomic) NSString  *item2;
@property (strong, nonatomic) NSString  *item3;
@property (strong, nonatomic) NSString  *item4;
@property (strong, nonatomic) NSString  *item5;
@property (strong, nonatomic) NSString  *item6;
@property (strong, nonatomic) NSString  *item7;
@property (strong, nonatomic) NSString  *item8;
@property (strong, nonatomic) NSString  *item9;
@property (strong, nonatomic) NSString  *item10;
@property (strong, nonatomic) NSString  *item11;
@property (strong, nonatomic) NSString  *item12;
@property (strong, nonatomic) NSString  *item13;
@property (strong, nonatomic) NSString  *item14;
@property (strong, nonatomic) NSString  *item15;
@property (strong, nonatomic) NSString  *item16;
@property (strong, nonatomic) NSString  *item17;
@property (strong, nonatomic) NSString  *item18;
@property (strong, nonatomic) NSString  *item19;
@property (strong, nonatomic) NSString  *item20;
@property (strong, nonatomic) NSString  *item21;
@property (strong, nonatomic) NSString  *item22;
@property (strong, nonatomic) NSString  *item23;
@property (strong, nonatomic) NSString  *item24;
@property (strong, nonatomic) NSString  *item25;
@property (strong, nonatomic) NSString  *item26;
@property (strong, nonatomic) NSString  *item27;
@property (strong, nonatomic) NSString  *item28;
@property (strong, nonatomic) NSString  *item29;
@property (strong, nonatomic) NSString  *item30;
@property (strong, nonatomic) NSString  *item31;
@property (strong, nonatomic) NSString  *item32;
@property (strong, nonatomic) NSString  *item33;
@property (strong, nonatomic) NSString  *item34;
@property (strong, nonatomic) NSString  *item35;
@property (strong, nonatomic) NSString  *item36;
@property (strong, nonatomic) NSString  *item37;
@property (strong, nonatomic) NSString  *item38;
@property (strong, nonatomic) NSString  *item39;
@property (strong, nonatomic) NSString  *item40;
@property (strong, nonatomic) NSString  *item41;
@property (strong, nonatomic) NSString  *item42;
@property (strong, nonatomic) NSString  *item43;
@property (strong, nonatomic) NSString  *item44;
@property (strong, nonatomic) NSString  *item45;
@property (strong, nonatomic) NSString  *item46;
@property (strong, nonatomic) NSString  *item47;
@property (strong, nonatomic) NSString  *item48;
@property (strong, nonatomic) NSString  *item49;
@property (strong, nonatomic) NSString  *item50;



@end



@interface WSRequestDataCacheObject : NSObject

@property (assign) int                  ID;
@property (nonatomic, copy) NSString *emp_Id;
@property (nonatomic, copy) NSString *biz_date;
@property (nonatomic, copy) NSString *data_md5;
@property (nonatomic, copy) NSString *data;
@property (nonatomic, copy) NSString *reserve0;
@property (nonatomic, copy) NSString *reserve1;
@property (nonatomic, copy) NSString *reserve2;
@property (nonatomic, copy) NSString *reserve3;
@property (nonatomic, copy) NSString *reserve4;
@property (nonatomic, copy) NSString *reserve5;
@property (nonatomic, copy) NSString *reserve6;
@property (nonatomic, copy) NSString *reserve7;
@property (nonatomic, copy) NSString *reserve8;
@property (nonatomic, copy) NSString *reserve9;

@end




typedef NSString*  VisitActionStatus;



@interface WSVisitStoreActionObject : NSObject

@property (nonatomic, assign)  int ID;
@property (nonatomic, assign) int parent_action_id;
@property (nonatomic, copy) NSString *store_id;
@property (nonatomic, copy) NSString *newstore_id;
@property (nonatomic, copy) NSString *func_code;
@property (nonatomic, copy) NSString *biz_date;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *emp_id;
@property (nonatomic, copy) NSString *dict_id;
@property (nonatomic, copy) NSString *is_required;
@property (nonatomic, copy) NSString *title;
/**
 * module_fc是为了区分不同模块下门店门店拜访状态。
 * module包含：TB层、门店列表层两个层级。
 * TB层的module_fc传下去主要为了区分不同模块（同九宫格）下的门店拜访（方便从门店向上回溯遍历本模块fc树）。
 * 而门店列表层向下传递module_fc是为了让同模块（同九宫格）下计划内、计划外、新门店拜访状态相同而构造。
 *
 */
@property (nonatomic, copy) NSString *module_fc;

@property (nonatomic, copy) NSString *nouploadInfo;///<未上报信息:特殊处理，数据查询的时候添加module_fc 配置为1

///来源于哪个模块（拜访/助销）
@property (nonatomic, copy) NSString *fromModuleName;

@end



@interface WSVisitPeoplePlanObject : NSObject

@property (assign) int                  ID;
@property (strong, nonatomic) NSString* docdate;
@property (strong, nonatomic) NSString* empid;
@property (strong, nonatomic) NSString* subempid;
@property (strong, nonatomic) NSString* subempname;
@property (strong, nonatomic) NSString* suborgid;
@property (strong, nonatomic) NSString* suborgname;

@end


@interface WSVisitStorePlanObject : NSObject

@property (assign) int                  ID;
@property (strong, nonatomic) NSString* storeids;
@property (strong, nonatomic) NSString* date;
@property (strong, nonatomic) NSString* empid;
@property (strong, nonatomic) NSString* storeid;
@property (strong, nonatomic) NSString* storestate;
@property (strong, nonatomic) NSString* storestateurl;


@end



@interface WSDownloadFileObject : NSObject

@property (assign) int                  ID;
@property (nonatomic,strong)  NSString  *file_id;
@property (nonatomic,strong)  NSString  *file_name;
@property (nonatomic,strong)  NSString  *file_url;
@property (nonatomic,strong)  NSNumber  *file_length;
@property (nonatomic,strong)  NSNumber  *file_download_size;
@property (nonatomic,strong)  NSString  *file_type;
@property (nonatomic,strong)  NSString  *file_save_path;
@property (nonatomic,strong)  NSString  *file_download_status;
@property (nonatomic,strong)  NSDate    *file_download_begin_time;
@property (nonatomic,strong)  NSDate    *file_download_end_time;
@property (nonatomic,strong)  NSDate    *file_expire_time;
@property (strong, nonatomic) NSString* empid;
@property (strong, nonatomic) NSString  *biz_date;
@property (strong, nonatomic) NSString  *acvt_id;

@end

@interface WSBaseStoreObject : NSObject

/*
storeacvtdis:visitplan 此节点信息 查找要显示在计划内的 门店
 有 //? 注释的 字段是之前塞班字段
 */

@property (assign) int ID;
@property (nonatomic, strong) NSString *store_id; // 门店Id
@property (nonatomic, strong) NSString *empid; //用户Id
@property (nonatomic, strong) NSString *name; //门店名称
@property (nonatomic, strong) NSString *code; //门店编码
@property (nonatomic, strong) NSString *styp; //门店类型
@property (nonatomic, strong) NSString *addr; //门店地址
@property (nonatomic, strong) NSString *lon; //门店经度
@property (nonatomic, strong) NSString *lat; //门店纬度
@property (nonatomic, strong) NSString *seq; //未知
@property (nonatomic, strong) NSString *search_objid; //门店数据来自哪个节点
@property (nonatomic, strong) NSString *search_code; //实时请求时候的关键字
@property (nonatomic, strong) NSString *lvlcode; //门店等级编码
@property (nonatomic, strong) NSString *dist_rule_id; //分销规则id
@property (nonatomic, strong) NSString *is_plan; //是否计划内
@property (nonatomic, strong) NSString *sv;
@property (nonatomic, strong) NSString *visit_status; //拜访状态
@property (nonatomic, strong) NSString *biz_date;// 日期
@property (nonatomic, strong) NSString *addstore_json_data;//新增门店相关数据，（可能不用）
@property (nonatomic, strong) NSString *store_other_col; //指定门店相关的字段信息(名称,id)等
@property (nonatomic, strong) NSString *pid; // 父店id
@property (nonatomic, strong) NSString *acvt_genid; // 本地新增门店gen_id
@property (nonatomic, strong) NSString *detail_info;// 门店详细信息(点击cell右侧按钮更新)
@property (nonatomic, strong) NSString *beacon_mac; // 门店相关的beancon 地址（若多个 逗号分开）
@property (nonatomic, strong) NSString *beacon_uuid;// 门店相关的beancon uuid (若多个，都好分开)

@property (nonatomic, strong) NSString *storeImg; // 门店icon
@property (nonatomic, strong) NSString *attri; // 门店属性icon

@property (nonatomic,strong) NSString *linkman;
@property (nonatomic,strong) NSString *phone;
@property (nonatomic,strong) NSString *storesfilter;
@property (nonatomic,strong) NSString *state;

@property (nonatomic,strong) NSString *last_man;
@property (nonatomic,strong) NSString *last_date;
@property (nonatomic,strong) NSString *last_num_q;
@property (nonatomic,strong) NSString *distances;
@property (nonatomic,strong) NSString *row_number;
@property (nonatomic,strong) NSString *item_name;
@property (nonatomic,strong) NSString *department_id;

// MSTD-7051 将要进行搜索的内容转为拼音，用于拼音搜索
@property (nonatomic, copy) NSString *pinyin;
@property (nonatomic, copy) NSString *follow; //是否关注

@property (nonatomic, copy) NSString *cityid; 

@property (nonatomic, copy) NSString *ctyp; // YIHAIKERRY-4192 门店渠道
@property (nonatomic, copy) NSString *qrcode; //是否关注
@property (nonatomic, copy) NSString *custCode;
@property (nonatomic, copy) NSString *orgid;//YIHAIKERRY-5136 益海嘉里-传统渠道 分公司id

@end


@interface WSBaseStoreVisitPlanObject : NSObject
@property (assign) int                  ID;
@property (nonatomic, strong) NSString *emp_id;
@property (nonatomic, strong) NSString *store_id;
@property (nonatomic, strong) NSString *biz_date;

@end


@interface WSBaseStoreOtherDataObject : NSObject
@property (assign) int                  ID;
@property (nonatomic, strong) NSString *emp_id;
@property (nonatomic, strong) NSString *store_id;
@property (nonatomic, strong) NSString *biz_date;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *item1;
@property (nonatomic, strong) NSString *item2;
@property (nonatomic, strong) NSString *item3;
@property (nonatomic, strong) NSString *item4;
@property (nonatomic, strong) NSString *item5;
@property (nonatomic, strong) NSString *item6;
@property (nonatomic, strong) NSString *item7;
@property (nonatomic, strong) NSString *item8;
@property (nonatomic, strong) NSString *item9;
@property (nonatomic, strong) NSString *item10;
@property (nonatomic, strong) NSString *item11;
@property (nonatomic, strong) NSString *item12;
@property (nonatomic, strong) NSString *item13;
@property (nonatomic, strong) NSString *item14;
@property (nonatomic, strong) NSString *item15;
@property (nonatomic, strong) NSString *item16;
@property (nonatomic, strong) NSString *item17;
@property (nonatomic, strong) NSString *item18;
@property (nonatomic, strong) NSString *item19;
@property (nonatomic, strong) NSString *item20;

@end

@interface WSBaseMsgObject : NSObject
@property (assign) int              ID;
@property(nonatomic,copy) NSString *_id;
@property(nonatomic,copy) NSString *title;         // 信息标题
@property(nonatomic,copy) NSString *cont;          // 信息详情内容
@property(nonatomic,copy) NSString *pubdate;       // 发布时间 ?
@property(nonatomic,copy) NSString *isread;        // 是否已读
@property(nonatomic,copy) NSString *pid;           // 父节点ID
@property(nonatomic,copy) NSString *url;           // 图片url
@property(nonatomic,copy) NSString *video_url;     // 视频url
@property(nonatomic,copy) NSString *video_path;
@property(nonatomic,copy) NSString *sound_url;     // 声音url
@property(nonatomic,copy) NSString *sound_path;    // 声音路径??
@property(nonatomic,copy) NSString *updatetime;    // 更新时间 ?
@property(nonatomic,copy) NSString *fileurl;       // 附件url
@property(nonatomic,copy) NSString *filename;      // 附件名字
@property(nonatomic,copy) NSString *organization;  // 组织
@property(nonatomic,copy) NSString *publisher;     // 信息发布者
@property(nonatomic,copy) NSString *visit_address; // html页面
@property(nonatomic,copy) NSString *headrail;
@property(nonatomic,copy) NSString *lastreplycount; // 上次消息的回复条数
@property(nonatomic,copy) NSString *pinyin;         // 标题转出来的拼音
@property(nonatomic,copy) NSString *typcode;
@property(nonatomic,copy) NSString *store_id;
@property(nonatomic,copy) NSString *seq;



@end

@interface WSBaseMsgTypeObject : NSObject
@property (assign) int              ID;
@property(nonatomic,copy) NSString *name;          // 信息分类信息
@property(nonatomic,copy) NSString *cod;           // 分类标识
@property(nonatomic,copy) NSString *msg_amount;    // 数量?
@property(nonatomic,copy) NSString *msg_sequence;  // 信息顺序
@property(nonatomic,copy) NSString *type;          // 类型  ?
@property(nonatomic,copy) NSString *icon_url;        
@property(nonatomic,copy) NSString *sort;//分类


@end


@interface WSBaseStoreAcvtObject : NSObject

@property (assign)int ID;
@property (nonatomic,copy)NSString *sid;
@property (nonatomic,copy)NSString *acvtid;
@property (nonatomic,copy)NSString *uploadcount;
@property (nonatomic,copy)NSString *hasuploadedcount;
@property (nonatomic,copy)NSString *server_node;

@end

@interface WSBaseStoreAcvtDisObject : NSObject<I_W_OptionDataItem>
@property (assign)int ID;
@property (nonatomic,copy)NSString *sid; // 门店id
@property (nonatomic,copy)NSString *acvtid; // 调查问卷id
@property (nonatomic,copy)NSString *acvtqstid; // 问题id
@property (nonatomic,copy)NSString *acvt_qst_answer;// 问题答案
@property (nonatomic,copy)NSString *gen_id;// 新增问卷的唯一标识
@property (nonatomic,copy)NSString *assetid; //
@property (nonatomic,copy)NSString *opt_value; //
@property (nonatomic,copy)NSString *is_search; //
@property (nonatomic,copy)NSString *newstoreid; // 新增门店的id
@property (nonatomic,copy)NSString *server_node; //
@property (nonatomic,copy)NSString *emp_id; // 用户id
@property (nonatomic,copy)NSString *gettime;
@property (nonatomic,assign) NSInteger queryCount; // 查询结果总数，用于 sql 查询总数

@end


@interface WSBaseStoreProdDisObject : NSObject
@property (assign) int                  ID;
@property (strong, nonatomic) NSString  *store_id;
@property (strong, nonatomic) NSString  *prod_id;
@property (strong, nonatomic) NSString  *dist;
@property (strong, nonatomic) NSString  *pri;
@property (strong, nonatomic) NSString  *inv;
@property (strong, nonatomic) NSString  *disp;
@property (strong, nonatomic) NSString  *sdisp;
@property (strong, nonatomic) NSString  *cmpt;
@property (strong, nonatomic) NSString  *oos;
@property (strong, nonatomic) NSString  *mtd;
@property (strong, nonatomic) NSString  *ord;
@property (strong, nonatomic) NSString  *gofa;
@property (strong, nonatomic) NSString  *aging;
@property (strong, nonatomic) NSString  *otherdicts;
@property (strong, nonatomic) NSString  *item1;
@property (strong, nonatomic) NSString  *item2;
@property (strong, nonatomic) NSString  *item3;
@property (strong, nonatomic) NSString  *item4;
@property (strong, nonatomic) NSString  *item5;
@property (strong, nonatomic) NSString  *item6;
@property (strong, nonatomic) NSString  *item7;
@property (strong, nonatomic) NSString  *item8;
@property (strong, nonatomic) NSString  *item9;
@property (strong, nonatomic) NSString  *item10;
@property (strong, nonatomic) NSString  *item11;
@property (strong, nonatomic) NSString  *item12;
@property (strong, nonatomic) NSString  *item13;
@property (strong, nonatomic) NSString  *item14;
@property (strong, nonatomic) NSString  *item15;
@property (strong, nonatomic) NSString  *item16;
@property (strong, nonatomic) NSString  *item17;
@property (strong, nonatomic) NSString  *item18;
@property (strong, nonatomic) NSString  *item19;
@property (strong, nonatomic) NSString  *item20;
@property (strong, nonatomic) NSString  *item21;
@property (strong, nonatomic) NSString  *item22;
@property (strong, nonatomic) NSString  *item23;
@property (strong, nonatomic) NSString  *item24;
@property (strong, nonatomic) NSString  *item25;
@property (strong, nonatomic) NSString  *item26;
@property (strong, nonatomic) NSString  *item27;
@property (strong, nonatomic) NSString  *item28;
@property (strong, nonatomic) NSString  *item29;
@property (strong, nonatomic) NSString  *item30;
@property (strong, nonatomic) NSString  *item31;
@property (strong, nonatomic) NSString  *item32;
@property (strong, nonatomic) NSString  *item33;
@property (strong, nonatomic) NSString  *item34;
@property (strong, nonatomic) NSString  *item35;
@property (strong, nonatomic) NSString  *item36;
@property (strong, nonatomic) NSString  *item37;
@property (strong, nonatomic) NSString  *item38;
@property (strong, nonatomic) NSString  *item39;
@property (strong, nonatomic) NSString  *item40;
@property (strong, nonatomic) NSString  *item41;
@property (strong, nonatomic) NSString  *item42;
@property (strong, nonatomic) NSString  *item43;
@property (strong, nonatomic) NSString  *item44;
@property (strong, nonatomic) NSString  *item45;
@property (strong, nonatomic) NSString  *item46;
@property (strong, nonatomic) NSString  *item47;
@property (strong, nonatomic) NSString  *item48;
@property (strong, nonatomic) NSString  *item49;
@property (strong, nonatomic) NSString  *item50;
@property (strong, nonatomic) NSString *dt;
@property (strong, nonatomic) NSString *dn;
@property (strong, nonatomic) NSString *funccode;
@property (strong, nonatomic) NSString *genid;
@property (strong, nonatomic) NSString *server_node;


@end



@interface WSBaseStoreDictDisObject : NSObject
@property (assign) int                  ID;
@property (strong, nonatomic) NSString *emp_id;
@property (strong, nonatomic) NSString *store_id;
@property (strong, nonatomic) NSString *func_code;
@property (strong, nonatomic) NSString *dict_id;
@property (strong, nonatomic) NSString *col1;
@property (strong, nonatomic) NSString *col2;
@property (strong, nonatomic) NSString *col3;
@property (strong, nonatomic) NSString *col4;
@property (strong, nonatomic) NSString *col5;
@property (strong, nonatomic) NSString *col6;
@property (strong, nonatomic) NSString *col7;
@property (strong, nonatomic) NSString *col8;
@property (strong, nonatomic) NSString *col9;
@property (strong, nonatomic) NSString *col10;
@property (strong, nonatomic) NSString *assetid;
@property (strong, nonatomic) NSString *server_node;
@property (strong, nonatomic) NSString *col11;
@property (strong, nonatomic) NSString *col12;
@property (strong, nonatomic) NSString *col13;
@property (strong, nonatomic) NSString *col14;
@property (strong, nonatomic) NSString *col15;
@property (strong, nonatomic) NSString *col16;
@property (strong, nonatomic) NSString *col17;
@property (strong, nonatomic) NSString *col18;
@property (strong, nonatomic) NSString *col19;
@property (strong, nonatomic) NSString *col20;
@property (strong, nonatomic) NSString *col21;
@property (strong, nonatomic) NSString *col22;
@property (strong, nonatomic) NSString *col23;
@property (strong, nonatomic) NSString *col24;
@property (strong, nonatomic) NSString *col25;
@property (strong, nonatomic) NSString *col26;
@property (strong, nonatomic) NSString *col27;
@property (strong, nonatomic) NSString *col28;
@property (strong, nonatomic) NSString *col29;
@property (strong, nonatomic) NSString *col30;
@property (strong, nonatomic) NSString *col31;
@property (strong, nonatomic) NSString *col32;
@property (strong, nonatomic) NSString *col33;
@property (strong, nonatomic) NSString *col34;
@property (strong, nonatomic) NSString *col35;
@property (strong, nonatomic) NSString *col36;
@property (strong, nonatomic) NSString *col37;
@property (strong, nonatomic) NSString *col38;
@property (strong, nonatomic) NSString *col39;
@property (strong, nonatomic) NSString *col40;

@end


@interface  WSVisitStoreStatusObject : NSObject
@property (assign) int                  ID;
@property (strong, nonatomic) NSString *emp_id;
@property (strong, nonatomic) NSString *store_id;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *biz_date;
@property (strong, nonatomic) NSString *func_code;
@property (strong, nonatomic) NSString *is_plan;
@property (strong, nonatomic) NSString *from_module;

@end

@interface  WSBaseAcvtObject : NSObject
@property (assign) int                  ID;
@property (strong, nonatomic) NSString *acvtname;
@property (strong, nonatomic) NSString *acvtobj;
@property (strong, nonatomic) NSString *typ;
@property (strong, nonatomic) NSString *s;
@property (strong,nonatomic) NSString *seq;
@property (strong,nonatomic) NSString *isblock;
@property (strong,nonatomic) NSString *originalacvtid;
@property (strong,nonatomic) NSString *isreq;

@property (strong,nonatomic) NSString *ispreview;
@property (strong,nonatomic) NSString *ftext;
@property (strong,nonatomic) NSString *acvtcode;
@property (strong,nonatomic) NSString *organization;
@property (strong,nonatomic) NSString *publisher;
@end




@interface WSBaseInStoreProdObject : NSObject
@property (assign) int                  ID;
@property (strong, nonatomic) NSString  *store_id;
@property (strong, nonatomic) NSString  *prod_id;
@property (strong, nonatomic) NSString  *dist;
@property (strong, nonatomic) NSString  *pri;
@property (strong, nonatomic) NSString  *inv;
@property (strong, nonatomic) NSString  *disp;
@property (strong, nonatomic) NSString  *sdisp;
@property (strong, nonatomic) NSString  *cmpt;
@property (strong, nonatomic) NSString  *oos;
@property (strong, nonatomic) NSString  *mtd;
@property (strong, nonatomic) NSString  *ord;
@property (strong, nonatomic) NSString  *gofa;
@property (strong, nonatomic) NSString  *aging;
@property (strong, nonatomic) NSString  *otherdicts;
@property (strong, nonatomic) NSString  *item1;
@property (strong, nonatomic) NSString  *item2;
@property (strong, nonatomic) NSString  *item3;
@property (strong, nonatomic) NSString  *item4;
@property (strong, nonatomic) NSString  *item5;
@property (strong, nonatomic) NSString  *item6;
@property (strong, nonatomic) NSString  *item7;
@property (strong, nonatomic) NSString  *item8;
@property (strong, nonatomic) NSString  *item9;
@property (strong, nonatomic) NSString  *item10;
@property (strong, nonatomic) NSString  *item11;
@property (strong, nonatomic) NSString  *item12;
@property (strong, nonatomic) NSString  *item13;
@property (strong, nonatomic) NSString  *item14;
@property (strong, nonatomic) NSString  *item15;
@property (strong, nonatomic) NSString  *item16;
@property (strong, nonatomic) NSString  *item17;
@property (strong, nonatomic) NSString  *item18;
@property (strong, nonatomic) NSString  *item19;
@property (strong, nonatomic) NSString  *item20;
@property (strong, nonatomic) NSString  *item21;
@property (strong, nonatomic) NSString  *item22;
@property (strong, nonatomic) NSString  *item23;
@property (strong, nonatomic) NSString  *item24;
@property (strong, nonatomic) NSString  *item25;
@property (strong, nonatomic) NSString  *item26;
@property (strong, nonatomic) NSString  *item27;
@property (strong, nonatomic) NSString  *item28;
@property (strong, nonatomic) NSString  *item29;
@property (strong, nonatomic) NSString  *item30;
@property (strong, nonatomic) NSString  *item31;
@property (strong, nonatomic) NSString  *item32;
@property (strong, nonatomic) NSString  *item33;
@property (strong, nonatomic) NSString  *item34;
@property (strong, nonatomic) NSString  *item35;
@property (strong, nonatomic) NSString  *item36;
@property (strong, nonatomic) NSString  *item37;
@property (strong, nonatomic) NSString  *item38;
@property (strong, nonatomic) NSString  *item39;
@property (strong, nonatomic) NSString  *item40;
@property (strong, nonatomic) NSString  *item41;
@property (strong, nonatomic) NSString  *item42;
@property (strong, nonatomic) NSString  *item43;
@property (strong, nonatomic) NSString  *item44;
@property (strong, nonatomic) NSString  *item45;
@property (strong, nonatomic) NSString  *item46;
@property (strong, nonatomic) NSString  *item47;
@property (strong, nonatomic) NSString  *item48;
@property (strong, nonatomic) NSString  *item49;
@property (strong, nonatomic) NSString  *item50;
@property (strong, nonatomic) NSString *dt;
@property (strong, nonatomic) NSString *dn;
@property (strong, nonatomic) NSString *server_node;

@end


@interface WSVisitStoreAcvtDataObject : NSObject
@property (assign)int ID;
@property (nonatomic,copy)NSString *sid; // 门店id
@property (nonatomic,copy)NSString *acvtid; // 调查问卷id
@property (nonatomic,copy)NSString *acvtqstid; // 问题id
@property (nonatomic,copy)NSString *acvt_qst_answer;// 问题答案
@property (nonatomic,copy)NSString *gen_id;// 新增问卷的唯一标识
@property (nonatomic,copy)NSString *assetid; //
@property (nonatomic,copy)NSString *opt_value; //问题答案对应的值
@property (nonatomic,copy)NSString *emp_id; // 用户id
@property (nonatomic,copy)NSString *biz_date; // 业务日期
@property (nonatomic,copy)NSString *newstoreid; // 二级门店 id
@property (nonatomic,copy)NSString *mclicktime; // mobileClickTime
@property (nonatomic,copy)NSString *server_node;//节点

@end

@interface  WSBaseFunsObject : NSObject

@property (strong, nonatomic) NSString *Id;
@property (strong, nonatomic) NSString *parentid;
@property (strong, nonatomic) NSString *userid;
@property (strong, nonatomic) NSString *fc;
@property (strong, nonatomic) NSString *fv;
@property (strong,nonatomic) NSString *name;
@property (strong,nonatomic) NSString *required;
@property (strong,nonatomic) NSString *typ;
@property (strong,nonatomic) NSString *opt;

@property (strong,nonatomic) NSString *ds;
@property (strong,nonatomic) NSString *filter;
@property (strong,nonatomic) NSString *wfcol;
@property (strong,nonatomic) NSString *param;
@property (strong,nonatomic) NSString *other;
@property (strong,nonatomic) NSString *datetyp;
@property (strong,nonatomic) NSString *styp;
@property (strong,nonatomic) NSString *isacvtlist;
@property (strong,nonatomic) NSString *readonly;
@property (strong,nonatomic) NSString *lockcol;

@property (strong,nonatomic) NSString *sort;
@property (strong,nonatomic) NSString *levelcode;
@property (strong,nonatomic) NSString *submenu;
@property (strong,nonatomic) NSString *unredo;
@property (strong,nonatomic) NSString *storeinfo;
@property (strong,nonatomic) NSString *defaultinfo;
@property (strong,nonatomic) NSString *redis;
@property (strong,nonatomic) NSString *sqlw;
@property (strong,nonatomic) NSString *datasource;
@property (strong,nonatomic) NSString *maxrow;

@property (strong,nonatomic) NSString *buttonname;
@property (strong,nonatomic) NSString *sql;
@property (strong,nonatomic) NSString *tabparam;
@property (strong,nonatomic) NSString *value;
@property (strong,nonatomic) NSString *fcharnum;
@property (strong,nonatomic) NSString *icon;
@property (strong,nonatomic) NSString *nullvalue;
@property (strong,nonatomic) NSString *subcode;
@property (strong,nonatomic) NSString *android;
@property (strong,nonatomic) NSString *script;
@property (strong,nonatomic) NSString *hiddenempty;
@property (strong,nonatomic) NSString *menutype;

@end

@interface  WSBaseSmsDataObject : NSObject

@property (nonatomic , copy) NSString *Id;
@property (nonatomic , copy) NSString *emp_id;
@property (nonatomic , copy) NSString *biz_date;
@property (nonatomic , copy) NSString *send_num;
@property (nonatomic , copy) NSString *receiver_num;
@property (nonatomic , copy) NSString *content;
@property (nonatomic , copy) NSString *result_time;
@property (nonatomic , copy) NSString *result_code;
@property (nonatomic , copy) NSString *genId;
@property (nonatomic , copy) NSString *memo;
@property (nonatomic , assign) int isSelect;

@end

@interface  WSUserBehaviorStatisticsObject : NSObject

@property (strong,nonatomic) NSString *userAccount;
@property (strong,nonatomic) NSString *empName;
@property (strong,nonatomic) NSString *bizdate;
@property (strong,nonatomic) NSString *parentFc;
@property (strong,nonatomic) NSString *parentFuncName;
@property (strong,nonatomic) NSString *fc ;
@property (strong,nonatomic) NSString *funcName;
@property (strong,nonatomic) NSString *storeId;
@property (strong,nonatomic) NSString *storeCode;
@property (strong,nonatomic) NSString *storeName;
@property (strong,nonatomic) NSString *sceneId ;
@property (strong,nonatomic) NSString *eventId;
@property (strong,nonatomic) NSString *startTime;
@property (strong,nonatomic) NSString *endTime;
@property (strong,nonatomic) NSString *eventValue;
@property (strong,nonatomic) NSString *genId;



@end

@interface  WSBaseStoreDistruleObject : NSObject

@property (assign) int             ID;
@property (nonatomic,copy)NSString *sid;
@property (nonatomic,copy)NSString *drid;
@property (nonatomic,copy)NSString *server_node;

@end


@interface  WSBdLocationDataObject : NSObject

@property (assign) int             ID;
@property (nonatomic , assign) NSInteger emp_id;
@property (nonatomic , copy) NSString *loc_biz_date;
@property (nonatomic , copy) NSString *lon;
@property (nonatomic , copy) NSString *lat;
@property (nonatomic , copy) NSString *loc_time;
@property (nonatomic , copy) NSString *loc_addr;
@property (nonatomic , copy) NSString *loc_date_time;
@property (nonatomic , copy) NSString *loc_city;
@property (nonatomic , copy) NSString *item2;
@property (nonatomic , copy) NSString *item3;

@end

@interface  WSFuncsMenuNoticeObject : NSObject

@property (nonatomic , copy) NSString *sid;
@property (nonatomic , copy) NSString *fc;
@property (nonatomic , copy) NSString *totalNum;
@property (nonatomic , copy) NSString *noticeNumFc;

@end

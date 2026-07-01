//
//  StoreBean.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSStoreBean.h"
#import "WSAcvtBean.h"
#import "WSPromBean.h"
#import "WSStoreBean_prod.h"
#import "WSAppData.h"
#import "WSStoreAcvtDisArray.h"
#import "WSStoreAcvtDisBean.h"
#import "I_W_Cell.h"
#import "WSEnvrionment.h"
//#import "ConfigFileController.h"
#import "WSHosBean.h"
#import "WSPointInfo.h"
 //TODO:对上层依赖，需要重构
#import "PayDisPlayBeanArray.h"
#import "WSBaseStoreDistruleDBService.h"

@interface WSStoreBean ()
//是否WSAppData调用
@property (nonatomic ,assign)BOOL isInitForWSAppData;
//prodArray是否初始化过
@property (nonatomic ,assign)BOOL isInitProdArrayData;

@property (nonatomic ,assign)BOOL isSetDrid;

@end

@implementation WSStoreBean


@synthesize empId          = _empId;
@synthesize Id          = _Id;
@synthesize sid         = _sid;
@synthesize n           = _n;
@synthesize name        = _name;
@synthesize shortName   = _shortName;
@synthesize plan        = _plan;
@synthesize code        = _code;
@synthesize pid         = _pid;
@synthesize cellid      = _cellid;
@synthesize procTypId   = _procTypId;
@synthesize typ         = _typ;
@synthesize addr        = _addr;
@synthesize phone       = _phone;
@synthesize styp        = _styp;
@synthesize linkman     = _linkman;
@synthesize linktel     = _linktel;
@synthesize sv          = _sv;
@synthesize srid        = _srid;
@synthesize orgId        = _orgId;

@synthesize miniumalDuration = _miniumalDuration;
@synthesize  storeprodArray = _storeprod;
@synthesize  promsArray     = _promsArray;
@synthesize  acvtsArray     = _acvtsArray;
@synthesize  acvtDisArray   = _acvtDisArray;
@synthesize  comptArray     = _comptArray;
@synthesize  hosArray      = _hosArray;

@synthesize  isEnter = _isEnter;
@synthesize  isLeave = _isLeave;
/**FIXME 以下是以前的，待处理*/
@synthesize  seq = _seq;
@synthesize  cpyCode = _cpyCode;
@synthesize  py = _py;
@synthesize  custIdf = _custIdf;
@synthesize  tel = _tel;
@synthesize  locCode = _locCode;
@synthesize  icrat = _icrat;
@synthesize  update_md5id = _update_md5id;


@synthesize  saleProdArray = _saleProdArray;
@synthesize  shiptoArray = _shiptoArray;        //送货地址
@synthesize  equArray = _equArray;              //设备信息
@synthesize  salepromArray = _salepromsArray;   //促销活动
@synthesize  rebateArray = _rebateArray;        //返利活动
@synthesize  prodArray = _prodArray;            //产品信息  销售产品
@synthesize  invProdArray = _invProdArray;      //库存价格采集产品列表
@synthesize  cmdArray = _cmdArray;              //指令集
@synthesize longitude = _longitude;
@synthesize latitude = _latitude;
//@synthesize cl = _cl;
@synthesize inArray = _inArray;
@synthesize payDisplayBeanArray = _payDisplayBeanArray;
@synthesize iStoreIdentify = _iStoreIdentify;
@synthesize last_num_q = _last_num_q;
@synthesize access_status;
@synthesize canClick = _canClick;

//inplanstore or outplanstore data
- (id)copyWithZone:(NSZone *)zone {
    
    WSStoreBean *copy = [[[self class] allocWithZone:zone] init];
    copy.empId = [self.empId copy];
    copy.Id = [self.Id copy];
    copy.sid = [self.sid copy];
    copy.n = [self.n copy];
    copy.name = [self.name copy];
    copy.shortName = [self.shortName copy];
    copy.plan = self.plan;
    copy.code = [self.code copy];
    copy.acvt_genId = [self.acvt_genId copy];
    copy.pid = [self.pid copy];
    copy.cellid = [self.cellid copy];
    copy.procTypId = [self.procTypId copy];
    copy.typ = [self.typ copy];
    copy.addr = [self.addr copy];
    copy.styp = [self.styp copy];
    copy.linkman = [self.linkman copy];
    copy.linktel = [self.linktel copy];
    copy.phone = [self.phone copy];
    copy.sv = [self.sv copy];
    copy.storeprodArray = [self.storeprodArray mutableCopy];
    copy.promsArray = [self.promsArray mutableCopy];
    copy.acvtsArray = [self.acvtsArray mutableCopy];
    copy.acvtDisArray = [self.acvtDisArray mutableCopy];
    copy.comptArray = [self.comptArray mutableCopy];
    copy.hosArray = [self.hosArray mutableCopy];
    copy.isEnter = self.isEnter;
    copy.isLeave = self.isLeave;
    copy.seq = [self.seq copy];
    copy.cpyCode = [self.cpyCode copy];
    copy.py = [self.py copy];
    copy.custIdf = [self.custIdf copy];
    copy.tel = [self.tel copy];
    copy.locCode = [self.locCode copy];
    copy.icrat = [self.icrat copy];
    copy.longitude = self.longitude;
    copy.latitude = self.latitude;
    copy.srid = self.srid;
    copy.orgId =self.orgId;
    copy.bfnum = self.bfnum;
    copy.sfnum = self.sfnum;
    copy.bPlanned = self.bPlanned;
    copy.storeAccessMode = self.storeAccessMode;
    copy.miniumalDuration = self.miniumalDuration ;
    copy.drId = [self.drId copy];
    copy.last_man = [self.last_man copy];
    copy.last_date = [self.last_date copy];
    copy.last_num_q = [self.last_num_q copy];
    copy.last_transaction = [self.last_transaction copy];
    copy.distance = [self.distance copy];
    copy.f_distance=self.f_distance;
    copy.row_number = [self.row_number copy];
    copy.local_ImageID =[self.local_ImageID copy];
    copy.item_name = [self.item_name copy];
    copy.departmentId = [self.departmentId copy];
    copy.state = [self.state copy];
    copy.attri = [self.attri copy];
    copy.storeImg = [self.storeImg copy];
    copy.mapPicDis = [self.mapPicDis copy];
    copy.dotDisplay = [self.dotDisplay copy];
    copy.actionState = [self.actionState copy];
    copy.visitcontent = [self.visitcontent copy];
    copy.store_month_visit_time = [self.store_month_visit_time copy];
    copy.isRouteStore = [self.isRouteStore copy];
    copy.follow = [self.follow copy];
    copy.canClick = [self.canClick copy];
    copy.ctyp = [self.ctyp copy];
    copy.qrcode = [self.qrcode copy];
    copy.custCode = [self.custCode copy];
    
    copy.optName = [self.optName copy];
    copy.monthVisitNumber = [self.monthVisitNumber copy];
    copy.monthHelpVisitNumber = [self.monthHelpVisitNumber copy];
    return copy;
}

- (NSUInteger) getProdSpecIndexWithContent:(NSString*)content
{
    
    if (!content || [content length] < 1) {
        return NSNotFound;
    }
    
    NSArray* ps = [WSAppData getObjectbyKey:PRODSPEC];
    if (ps) {
        return [ps indexOfObject:content];
    }
    
    return NSNotFound;
}


/**
 *返回分销产品列表（含回显值）
 */
-(NSArray*)productProdsWithNewDats:(NSArray*)aProds Dis:(NSArray*)aDisArray
{
    // 品牌组的id（drid）存在 先用组id过滤
    NSUInteger sidIndex = [self getProdSpecIndexWithContent:@"drid"];
    if (sidIndex == NSNotFound) {
        sidIndex = [self getProdSpecIndexWithContent:@"sid"];
    }
    NSUInteger pidIndex = [self getProdSpecIndexWithContent:@"pid"];
    NSMutableArray* prods = [[NSMutableArray alloc]init];
    if(sidIndex != NSNotFound)
    {
        //先通过店ID过滤回显数组，然后再生成WSStoreBean_prod；
        NSArray* firstProdArray = (NSArray*)[aProds firstObject];
        NSString *sidString = [firstProdArray objectAtIndex:sidIndex];
        NSMutableArray *filterDisArray = [[NSMutableArray alloc] init];
        
        [aDisArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSArray *prodDisInfo = (NSArray *)obj;
            NSString *sidStringTemp = [prodDisInfo objectAtIndex:sidIndex];
            if ([sidStringTemp isEqualToString:sidString]) {
                [filterDisArray addObject:prodDisInfo];
            }
        }];
        
        __weak __typeof(self) weakSelf = self;
        [aProds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSArray* l_prodArray = (NSArray*)obj;
            NSString *pid = [l_prodArray objectAtIndex:pidIndex];
            __strong __typeof(weakSelf) sself = weakSelf;
            __block NSArray *displayArray = nil;
            [filterDisArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSArray *prodInfo = (NSArray *)obj;
                NSString *pidStr = [prodInfo objectAtIndex:pidIndex];
                if([pidStr isEqualToString:pid]){
                    displayArray = prodInfo;
                    *stop = YES;
                }
            }];
            
            WSStoreBean_prod* sb_p = [[WSStoreBean_prod alloc] initWithSid:sself.Id
                                                                       Pid:pid
                                                                     Prods:l_prodArray
                                                                       Dis:displayArray];
            [prods addObject:sb_p];
            
        }];
    }
    return prods;
}

/**
 *返回分销产品列表（含回显值）
 */

//-(NSArray*)productProdsWithNewDats:(NSArray*)aProds Dis:(NSArray*)aDisArray
//{
//    // 品牌组的id（drid）存在 先用组id过滤
//    NSUInteger sidIndex = [self getProdSpecIndexWithContent:@"drid"];
//    if (sidIndex == NSNotFound) {
//        sidIndex = [self getProdSpecIndexWithContent:@"sid"];
//    }
//    NSUInteger pidIndex = [self getProdSpecIndexWithContent:@"pid"];
//    NSMutableArray* prods = [[NSMutableArray alloc]init];
//    
//    if(sidIndex != NSNotFound)
//    {
//        //先通过店ID过滤回显数组，然后再生成WSStoreBean_prod；
//        /*
//        NSArray* firstProdArray = (NSArray*)[aProds firstObject];
//        NSString *sidString = [firstProdArray objectAtIndex:sidIndex];
//         */
//        NSMutableArray *filterDisArray = [[NSMutableArray alloc] init];
//        /*用storeId来过滤回显数据*/
//        [aDisArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            NSArray *prodDisInfo = (NSArray *)obj;
//            NSString *sidStringTemp = [prodDisInfo objectAtIndex:sidIndex];
//            if ([sidStringTemp isEqualToString:self.Id]) {
//                [filterDisArray addObject:prodDisInfo];
//            }
//        }];
//        
//        __weak __typeof(self) weakSelf = self;
//        [aProds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            NSArray* l_prodArray = (NSArray*)obj;
//            NSString *pid = [l_prodArray objectAtIndex:pidIndex];
//            __strong __typeof(weakSelf) sself = weakSelf;
//            
//            
//            /*针对不同funcode的表格  有相同产品回显的修改*/
//            __block NSMutableArray *displayArrays = [NSMutableArray array];;
//            [filterDisArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                NSArray *prodInfo = (NSArray *)obj;
//                NSString *pidStr = [prodInfo objectAtIndex:pidIndex];
//                if([pidStr isEqualToString:pid]){
//                    [displayArrays addObject: prodInfo];
//                }
//            }];
//            if ([displayArrays count] > 0) {
//                for (NSInteger i = 0; i < [displayArrays count]; i++) {
//                    NSArray *displayArray = displayArrays[i];
//                    WSStoreBean_prod* sb_p = [[WSStoreBean_prod alloc] initWithSid:sself.Id
//                                                                               Pid:pid
//                                                                             Prods:l_prodArray
//                                                                               Dis:displayArray];
//                    [prods addObject:sb_p];
//                }
//            }else {
//                WSStoreBean_prod* sb_p = [[WSStoreBean_prod alloc] initWithSid:sself.Id
//                                                                           Pid:pid
//                                                                         Prods:l_prodArray
//                                                                           Dis:nil];
//                 [prods addObject:sb_p];
//            }
//           
//            
//        }];
//    }
//    return prods;
//}
//add 过滤各店的产品 by yanguoshuai at 2012－03－23

-(NSArray *)getStoreProd:(NSArray *)_prod
{
    __block NSMutableArray *tmpArray=[[NSMutableArray alloc]init];
   
    if (self.drId && self.drId.length >0) {
        [_prod enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
          NSArray *sidArray = (NSArray *)obj;
          NSString *proddrId = [sidArray objectAtIndex:0];
          if ([self.drId isEqualToString:proddrId]) {
            [tmpArray addObject:sidArray];
           }
        }];
    }else if (self.Id && self.Id.length >0){
        [_prod enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSArray *sidArray = (NSArray *)obj;
            NSString *proddrId = [sidArray objectAtIndex:0];
            if ([self.Id isEqualToString:proddrId]) {
                [tmpArray addObject:sidArray];
            }
        }];
    }
    //根据产品的drid或者sid 找对应门店
    if (tmpArray.count < 1) {
        
        NSInteger drIdIndex = [self getProdSpecIndexWithContent:@"drid"];
        if (drIdIndex != NSNotFound && self.drId) {
            [_prod enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSArray *sidArray = (NSArray *)obj;
                NSString *proddrId = [sidArray objectAtIndex:drIdIndex];
                if ([self.drId isEqualToString:proddrId]) {
                    [tmpArray addObject:sidArray];
                }
            }];
            
        } else {
            NSUInteger sidIndex = [self getProdSpecIndexWithContent:@"sid"];
            if(sidIndex!=NSNotFound){
                [_prod enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSArray *sidArray = (NSArray *)obj;
                    NSString *prodSid = [sidArray objectAtIndex:sidIndex];
                    if ([self.Id isEqualToString:prodSid]) {
                        [tmpArray addObject:sidArray];
                    }
                }];
            }
        }
    }


    
    return tmpArray;
}


-(void)addAcvtDis:(NSDictionary *)objectDic
{
    if(self.acvtDisArray == nil)
        _acvtDisArray = [[NSMutableArray alloc]init];
    
    WSStoreAcvtDisArray* l_sada = nil;
    if ([objectDic objectForKey:STOREACVTDIS]) {
        l_sada = [[WSStoreAcvtDisArray  alloc] initWithObject:objectDic];
    }else{
        l_sada = [WSAppData getObjectbyKey:STOREACVTDIS];
    }

    for(WSStoreAcvtDisBean* f_sad in l_sada.storeAcvtDisArray)
    {
        if([f_sad.m_p count]>0)
        {
            NSString* i_storeId = [f_sad.m_p objectAtIndex:0];
            if([i_storeId isEqualToString:self.sid])
            {
                [self.acvtDisArray addObject:f_sad];
            }
        }
    }
}

-(void)addAcvts:(NSDictionary*)aDic
{
    //acvts
    NSArray *l_acvtArray ;
    if(self.plan)
        l_acvtArray = [aDic objectForKey:Store_acvts];
    else
        l_acvtArray = [aDic objectForKey:@"acvt"];

    
    if(self.acvtsArray == nil)
        _acvtsArray = [[NSMutableArray alloc]initWithCapacity:[l_acvtArray count]];
    for(NSDictionary* l_dic in l_acvtArray)
    {
        NSString* l_sid = [NSString stringWithValue:[l_dic objectForKey:@"sid"]];
        
        NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithDictionary:l_dic];
        
        NSArray *allKeys = [newDic allKeys];
        for (NSString *key in allKeys) {
            if ([[newDic objectForKey:key] isKindOfClass:[NSNull class]]) {
                [newDic removeObjectForKey:key];
            }
        }
        
        // 辉瑞医院 院外拜访-计划内 单独处理 sid 和 pid 比较
        if ( self.noteName != nil && [self.noteName isEqualToString:@"inempplan"]) {
            BOOL hasExit = NO;
            if ([self.pid isEqualToString:l_sid]) {
                for (NSDictionary *subDic in _acvtsArray) {
                    if ([subDic isEqualToDictionary:newDic]) {
                        hasExit = YES;
                    }
                }
                if (!hasExit) {
                    [_acvtsArray addObject:newDic];
                }
            }
        } else if ([self.Id isEqualToString:l_sid]) {
            BOOL hasExit = NO;
            for (NSDictionary *subDic in _acvtsArray) {
                if ([subDic isEqualToDictionary:newDic]) {
                    hasExit = YES;
                }
            }
            if (!hasExit) {
                [_acvtsArray addObject:newDic];
            }
        }
        
        
    }
}

- (void)addHos:(NSDictionary*)aDic {
    NSArray *l_hosArray ;
    
    l_hosArray = [aDic objectForKey:Store_hos];
    
    
    if ([l_hosArray isKindOfClass:[NSArray class]]) {
        if(self.hosArray == nil) {
            _hosArray = [[NSMutableArray alloc] initWithCapacity:[l_hosArray count]];
        }
        
        for (NSDictionary *l_dic in l_hosArray) {
            NSString *l_sid = [NSString stringWithValue:[l_dic objectForKey:@"sid"]];
            
            if ([self.Id isEqualToString:l_sid]) {
                WSHosBean *hosBean = [[WSHosBean alloc] initHosWithObject:l_dic isPlan:self.plan];
                [_hosArray addObject:hosBean];
            }
            
            //        // 辉瑞医院 计划内 单独处理 sid 和 pid 比较
            //        if ( projectName != nil && [projectName isEqualToString:@"pfizer"] && self.plan) {
            //            BOOL hasExit = NO;
            //            if ([self.pid isEqualToString:l_sid]) {
            //                for (NSDictionary *subDic in _acvtsArray) {
            //                    if ([subDic isEqualToDictionary:l_dic]) {
            //                        hasExit = YES;
            //                    }
            //                }
            //                if (!hasExit) {
            //                    [_acvtsArray addObject:l_dic];
            //                }
            //            }
            //        } else if ([self.Id isEqualToString:l_sid]) {
            //            [_acvtsArray addObject:l_dic];
            //        }
        }
    }
    
}

-(void)addProms:(NSDictionary*)aDic
{
//    //proms
//    NSArray *l_promArray = [aDic objectForKey:Store_proms];
//    if(_promsArray == nil)
//        _promsArray = [[NSMutableArray alloc]initWithCapacity:[l_promArray count]];
}

- (void)addPayDisplay:(NSDictionary *)aDic {
    NSArray *l_payDisplayArray ;
    
    l_payDisplayArray = [aDic objectForKey:Store_payDisplay];
    if (!l_payDisplayArray)
        return;
    
//    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[l_payDisplayArray count]];
    
    
    //TODO:对上层依赖，需要重构
     PayDisPlayBeanArray *bean = [[PayDisPlayBeanArray alloc] initWithObject:l_payDisplayArray];
     if (bean) {
         _payDisplayBeanArray = bean;
     }

    
    //
//    for (NSDictionary *l_dic in l_hosArray) {
//        NSString *l_sid = [NSString stringWithValue:[l_dic objectForKey:@"sid"]];
//        
//        if ([self.Id isEqualToString:l_sid]) {
//            HosBean *hosBean = [[[HosBean alloc] initHosWithObject:l_dic isPlan:self.plan] autorelease];
//            [_hosArray addObject:hosBean];
//        }
}
#pragma mark - initObject



- (instancetype)initStoreWithObject:(id)object IsPlan:(BOOL)isPlan
{
    return [self initStoreWithObject:object IsPlan:isPlan noteName:nil storeAccessMode:WSStoreAccessModeNormal];
}

- (instancetype)initStoreWithObject:(id) object IsPlan:(BOOL)isPlan storeAccessMode:(WSStoreAccessMode)accessMode
{
     return [self initStoreWithObject:object IsPlan:isPlan noteName:nil storeAccessMode:accessMode];
}

- (instancetype)initStoreWithObject:(id)object IsPlan:(BOOL)isPlan noteName:(NSString *)aNoteName
{
    return [self initStoreWithObject:object IsPlan:isPlan noteName:aNoteName storeAccessMode:WSStoreAccessModeNormal];
}

- (instancetype)initstoreWithBaseStoreObject:(WSBaseStoreObject *)baseStoreObject isPlan:(BOOL)isPlan {
    if (baseStoreObject == nil) {
        return nil;
    }
    if ([super init]) {
        self.storeAccessMode = WSStoreAccessModeNormal;
        self.noteName = baseStoreObject.search_objid;
        self.plan = isPlan;
        self.cellid = @"";
        self.code = baseStoreObject.code;
        self.acvt_genId = baseStoreObject.acvt_genid;
        self.empId = baseStoreObject.empid;
        self.drId = baseStoreObject.dist_rule_id;
        self.Id = baseStoreObject.store_id;
        if (![baseStoreObject.empid isEqualToString:[WSAppData getObjectbyKey:APPDATA_EMPID]]) {
            self.srid = baseStoreObject.empid;// 存入数据库的时候如果srid存在 则赋给表格empId字段,若不存在则用empId自己的值
            self.storeAccessMode = WSStoreAccessModeSubEmp;
        }
        self.pid = baseStoreObject.pid;
        self.name = baseStoreObject.name;
        self.styp = baseStoreObject.styp;
        self.addr = baseStoreObject.addr;
//        self.cl = @"";
        self.inArray = [NSMutableArray array];
        self.orgId = @"";
        self.seq = [NSNumber numberWithInteger:[baseStoreObject.seq integerValue]];
        self.sv = baseStoreObject.sv;
        self.bfnum = @"";
        self.sfnum = @"";
        self.beaconUUId = baseStoreObject.beacon_uuid;
        self.latitude = [baseStoreObject.lat doubleValue];
        self.longitude = [baseStoreObject.lon doubleValue];
        self.isInitForWSAppData = YES;
        self.detail_info = baseStoreObject.detail_info;
        self.miniumalDuration = @"";
        self.actionState = baseStoreObject.visit_status;
        self.storeImg = baseStoreObject.storeImg;
        self.attri = baseStoreObject.attri;
        self.last_date = baseStoreObject.last_date;
        self.last_num_q = baseStoreObject.last_num_q;
        self.follow =  baseStoreObject.follow;
        self.ctyp = baseStoreObject.ctyp;
        self.qrcode = baseStoreObject.qrcode;
        self.custCode = baseStoreObject.custCode;
    }
    return self;
    
}

- (instancetype)initStoreForWSAppDataWithObject:(id)object IsPlan:(BOOL)isPlan noteName:(NSString *)aNoteName
{
    if (nil == object) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.noteName = aNoteName;
        self.plan = isPlan;
        if ([object isKindOfClass:[NSDictionary class]]){
            NSDictionary *storeDectionary = (NSDictionary *)object;
            self.cellid = [NSString stringWithValue:[storeDectionary objectForKey:Store_cellid]];
            self.code = [NSString stringWithValue:[storeDectionary objectForKey:Store_cod]];
            self.acvt_genId = [NSString stringWithValue:[storeDectionary objectForKey:Store_genid]];
            self.empId = [NSString stringWithValue:[storeDectionary objectForKey:Store_empId]];
            self.drId = [NSString stringWithValue:[storeDectionary objectForKey:Store_drId]];
            self.Id = [NSString stringWithValue:[storeDectionary objectForKey:Store_id]];
            self.srid = [NSString stringWithValue:[storeDectionary objectForKey:Store_srid]];
            self.pid = [NSString stringWithValue:[storeDectionary objectForKey:Store_pid]];
            self.name = [NSString stringWithValue:[storeDectionary objectForKey:Store_name]];
            self.styp = [NSString stringWithValue:[storeDectionary objectForKey:Store_styp]];
            self.addr = [NSString stringWithValue:[storeDectionary objectForKey:Store_addr]];
//            self.cl = [NSString stringWithValue:[storeDectionary objectForKey:Store_cl]];
            self.inArray = [storeDectionary objectForKey:Store_in];
            self.orgId = [NSString stringWithValue:[storeDectionary objectForKey:SUBEMPSTORE_ORGID]];
            self.seq =[[NSNumber alloc] initWithInteger:[[storeDectionary objectForKey:@"seq"] integerValue]];
            //add by wangdongyan 03-08
            self.sv = [NSString stringWithValue:[storeDectionary objectForKey:Store_sv]];
            
            self.bfnum = [NSString stringWithValue:[storeDectionary objectForKey:Store_bfnum]];
            self.sfnum = [NSString stringWithValue:[storeDectionary objectForKey:Store_sfnum]];
            
            id tmp = [storeDectionary objectForKey:Store_beacon_uuid];
            if (tmp) {
                self.beaconUUId = [NSString stringWithValue:tmp];
            }
            
            self.latitude = [[NSString stringWithValue:[storeDectionary objectForKey: Store_lat]] doubleValue];
            self.longitude = [[NSString stringWithValue:[storeDectionary objectForKey: Store_lon]] doubleValue];
            self.storeAccessMode = WSStoreAccessModeNormal;
            self.isInitForWSAppData = YES;
            
            self.detail_info =[NSString stringWithValue:[storeDectionary objectForKey:Store_detail_info]];
            
             self.miniumalDuration = [NSString stringWithValue:[storeDectionary objectForKey:Store_miniumalDuration]];
            [self reloadStoreData:storeDectionary];
            
            self.storesFilter = [NSString stringWithValue:[storeDectionary objectForKey:Store_filter]];
            _item_name = [NSString stringWithValue: storeDectionary[Store_item_name]];
            _departmentId = [NSString stringWithValue:storeDectionary[Store_departmentId]];
            self.follow = [NSString stringWithValue:storeDectionary[Store_follow]];
            self.ctyp = [NSString stringWithValue:storeDectionary[Store_ctyp]];
            self.qrcode = [NSString stringWithValue:storeDectionary[Store_qrcode]];
            self.custCode = [NSString stringWithValue:storeDectionary[Store_custCode]];
            self.is_plan = [NSString stringWithValue:[storeDectionary objectForKey:@"is_plan"]];
            self.routeName = [NSString stringWithValue:[storeDectionary objectForKey:@"routeName"]];
            self.fromModuleName = [NSString stringWithValue:[storeDectionary objectForKey:@"fromModuleName"]];
        }
    }
    
    return self;

}

- (instancetype)initStoreWithObject:(id) object IsPlan:(BOOL)isPlan noteName:(NSString *)aNoteName storeAccessMode:(WSStoreAccessMode)accessMode
{
    if (nil == object) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.noteName = aNoteName;
        self.plan = isPlan;
        if ([object isKindOfClass:[NSDictionary class]]){
            NSDictionary *storeDectionary = (NSDictionary *)object;
            self.cellid = [NSString stringWithValue:[storeDectionary objectForKey:Store_cellid]];
            self.code = [NSString stringWithValue:[storeDectionary objectForKey:Store_cod]];
            self.acvt_genId = [NSString stringWithValue:[storeDectionary objectForKey:Store_genid]];
            self.empId = [NSString stringWithValue:[storeDectionary objectForKey:Store_empId]];
            self.drId = [NSString stringWithValue:[storeDectionary objectForKey:Store_drId]];
            self.Id = [NSString stringWithValue:[storeDectionary objectForKey:Store_id]];
            self.pid = [NSString stringWithValue:[storeDectionary objectForKey:Store_pid]];
            self.name = [NSString stringWithValue:[storeDectionary objectForKey:Store_name]];
            self.styp = [NSString stringWithValue:[storeDectionary objectForKey:Store_styp]];
            self.addr = [NSString stringWithValue:[storeDectionary objectForKey:Store_addr]];
//            self.cl = [NSString stringWithValue:[storeDectionary objectForKey:Store_cl]];
            self.inArray = [storeDectionary objectForKey:Store_in];
            self.orgId = [NSString stringWithValue:[storeDectionary objectForKey:@"orgId"]];
            // 按照 android 的方式获取电话
            self.phone = [NSString stringWithValue:[storeDectionary objectForKey:Store_phone]];
            
            //add by wangdongyan 03-08
            self.sv = [NSString stringWithValue:[storeDectionary objectForKey:Store_sv]];
            self.seq =[[NSNumber alloc] initWithInteger:[[storeDectionary objectForKey:@"seq"] integerValue]];
            self.bfnum = [NSString stringWithValue:[storeDectionary objectForKey:Store_bfnum]];
            self.sfnum = [NSString stringWithValue:[storeDectionary objectForKey:Store_sfnum]];
            self.srid = [NSString stringWithValue:[storeDectionary objectForKey:Store_srid]];
            
            id tmp = [storeDectionary objectForKey:Store_beacon_uuid];
            if (tmp) {
                self.beaconUUId = [NSString stringWithValue:tmp];
            }

            self.latitude = [[NSString stringWithValue:[storeDectionary objectForKey: Store_lat]] doubleValue];
            self.longitude = [[NSString stringWithValue:[storeDectionary objectForKey: Store_lon]] doubleValue];
            self.storeAccessMode = accessMode;
            self.isInitForWSAppData = NO;
            
            self.detail_info =[NSString stringWithValue:[storeDectionary objectForKey:Store_detail_info]];
            [self reloadStoreData:storeDectionary];
            
            self.miniumalDuration = [NSString stringWithValue:[storeDectionary objectForKey:Store_miniumalDuration]];
            self.storesFilter = [NSString stringWithValue:[storeDectionary objectForKey:Store_filter]];
            self.last_man = [NSString stringWithValue:storeDectionary[Store_last_man]];
            self.last_date = [NSString stringWithValue:storeDectionary[Store_last_date]];
            self.last_num_q = [NSString stringWithValue:storeDectionary[Store_last_num_q]];
            self.last_transaction = [NSString stringWithValue:storeDectionary[Store_last_transaction]];
            self.distance = [NSString stringWithValue:storeDectionary[Store_distance]];
            self.row_number = [NSString stringWithValue:storeDectionary[Store_row_number]];
            self.follow = [NSString stringWithValue:storeDectionary[Store_follow]];
            self.qrcode = [NSString stringWithValue:storeDectionary[Store_qrcode]];
            self.custCode = [NSString stringWithValue:storeDectionary[Store_custCode]];
            self.ctyp = [NSString stringWithValue:storeDectionary[Store_ctyp]];
            self.is_plan = [NSString stringWithValue:[storeDectionary objectForKey:@"is_plan"]];
            self.routeName = [NSString stringWithValue:[storeDectionary objectForKey:@"routeName"]];
        }
    }
    
    return self;
    
}

- (instancetype)initStoreWithObjectForSer:(id)object{
    if (nil == object) {
        return nil;
    }
    
    self = [super init];
    if (self) {

        if ([object isKindOfClass:[NSDictionary class]]){
            NSDictionary *storeDectionary = (NSDictionary *)object;
            self.cellid = [NSString stringWithValue:[storeDectionary objectForKey:Store_cellid]];
            self.code = [NSString stringWithValue:[storeDectionary objectForKey:Store_cod]];
            self.acvt_genId = [NSString stringWithValue:[storeDectionary objectForKey:Store_genid]];
            self.empId = [NSString stringWithValue:[storeDectionary objectForKey:Store_empId]];
            self.drId = [NSString stringWithValue:[storeDectionary objectForKey:Store_drId]];
            self.Id = [NSString stringWithValue:[storeDectionary objectForKey:Store_id]];
            self.pid = [NSString stringWithValue:[storeDectionary objectForKey:Store_pid]];
            self.name = [NSString stringWithValue:[storeDectionary objectForKey:Store_name]];
            self.styp = [NSString stringWithValue:[storeDectionary objectForKey:Store_styp]];
            self.addr = [NSString stringWithValue:[storeDectionary objectForKey:Store_addr]];
//            self.cl = [NSString stringWithValue:[storeDectionary objectForKey:Store_cl]];
            self.inArray = [storeDectionary objectForKey:Store_in];
            self.orgId = [NSString stringWithValue:[storeDectionary objectForKey:@"orgId"]];
            
            //add by wangdongyan 03-08
            self.sv = [NSString stringWithValue:[storeDectionary objectForKey:Store_sv]];
            self.seq =[[NSNumber alloc] initWithInteger:[[storeDectionary objectForKey:@"seq"] integerValue]];
            self.bfnum = [NSString stringWithValue:[storeDectionary objectForKey:Store_bfnum]];
            self.sfnum = [NSString stringWithValue:[storeDectionary objectForKey:Store_sfnum]];
            self.srid = [NSString stringWithValue:[storeDectionary objectForKey:Store_srid]];
            
            id tmp = [storeDectionary objectForKey:Store_beacon_uuid];
            if (tmp) {
                self.beaconUUId = [NSString stringWithValue:tmp];
            }
            
            self.latitude = [[NSString stringWithValue:[storeDectionary objectForKey: Store_lat]] doubleValue];
            self.longitude = [[NSString stringWithValue:[storeDectionary objectForKey: Store_lon]] doubleValue];
            self.detail_info =[NSString stringWithValue:[storeDectionary objectForKey:Store_detail_info]];
            self.isInitForWSAppData = NO;
            
            self.miniumalDuration = [NSString stringWithValue:[storeDectionary objectForKey:Store_miniumalDuration]];
            
            self.storesFilter = [NSString stringWithValue:[storeDectionary objectForKey:Store_filter]];

            self.last_man = [NSString stringWithValue:storeDectionary[Store_last_man]];
            self.last_date = [NSString stringWithValue:storeDectionary[Store_last_date]];
            self.last_num_q = [NSString stringWithValue:storeDectionary[Store_last_num_q]];
            self.last_transaction = [NSString stringWithValue:storeDectionary[Store_last_transaction]];
            self.distance = [NSString stringWithValue:storeDectionary[Store_distance]];
            self.row_number = [NSString stringWithValue:storeDectionary[Store_row_number]];
            self.follow = [NSString stringWithValue:storeDectionary[Store_follow]];
            self.qrcode = [NSString stringWithValue:storeDectionary[Store_qrcode]];
            self.custCode = [NSString stringWithValue:storeDectionary[Store_custCode]];
            self.ctyp = [NSString stringWithValue:storeDectionary[Store_ctyp]];
            self.is_plan = [NSString stringWithValue:storeDectionary[@"is_plan"]];
            self.routeName = [NSString stringWithValue:storeDectionary[@"routeName"]];

        }
    }
    
    return self;

}
- (instancetype)initStoreWithId:(NSString *)aStoreId andName:(NSString *)aName andPlan:(BOOL)aIsPlan
{
    self = [super init];
    if (self) {
        _Id = [aStoreId copy];
        _sid = [aStoreId copy];
        _name = [aName copy];
        _plan = aIsPlan;
        self.storeAccessMode = WSStoreAccessModeNormal;
    }
    return self;
}
#pragma mark - setStoreData

- (WSStoreBean*)initNeighborStoreWithDic:(NSDictionary*)dic
{
    self.Id = [dic objectForKey:@"store_id"];
    self.latitude = [[dic objectForKey:Store_lat] doubleValue];
    self.name = [dic objectForKey:@"store_name"];
    self.code = [dic objectForKey:@"store_code"];
    self.acvt_genId = [dic objectForKey:@"acvt_genId"];
    self.longitude = [[dic objectForKey:@"lon"] doubleValue];
    
    return self;
}

/**
 用数据库model 填充storemodel
 */
- (void)setStoreWith:(WSBaseStoreObject *)storeObject {
    _Id = storeObject.store_id;
    _name = storeObject.name;
    _styp =storeObject.styp;
    _empId = storeObject.empid;
    _code = storeObject.code;
    _acvt_genId = storeObject.acvt_genid;
    _addr  = storeObject.addr;
    _longitude = [storeObject.lon doubleValue];
    _latitude = [storeObject.lat doubleValue];
    _drId = storeObject.dist_rule_id;
    _plan = [storeObject.is_plan isEqualToString:@"1"] ? YES : NO;
    
    
}

#pragma mark - calc method

-(NSDictionary *)calcAllAcvts:(NSString*)acvtId
{
    if (!acvtId) {
        return nil;
    }
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    for(WSStoreAcvtDisBean* f_sad in self.acvtDisArray)
    {
         NSString* i_acvtId = [f_sad.m_p objectAtIndex:ACVTDIS_ACVTID];
        if([i_acvtId isEqualToString:acvtId])
        {
            NSString * gen_id = [f_sad.gen_id copy];
            if (gen_id && [gen_id length] > 0) {
                NSMutableArray *qstArray = [dic objectForKey:f_sad.gen_id];
                if (!qstArray && f_sad.gen_id) {
                    qstArray = [NSMutableArray array];
                    [dic setObject:qstArray forKey:f_sad.gen_id];
                }
                 [qstArray addObject:f_sad];
            }

        }
    }
    
    return dic;
}

- (void)reSetStore:(id)object Key:(NSString *)key
{
    if ([object isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary* dic = (NSDictionary*)object;
        NSArray* infoArray = [dic objectForKey:key];
        id dicObject = [infoArray firstObject];
        if ([dicObject isKindOfClass:[NSDictionary class]]) {
            [self clearStoreData];
            self.isInitProdArrayData = NO;
            [self reloadStoreData:dicObject];
        }
    }
}

- (void)reloadStoreData:(NSDictionary*)dicObject
{
    if (!dicObject) {
        return;
    }
    self.Id = [NSString stringWithValue:self.Id];
    
    if (self.Id && [self.Id length] > 0) {
        self.sid = self.Id;
    }
    
    NSString *drId = [NSString stringWithValue:[dicObject objectForKey:Store_drId]];
    if ([drId length] > 0) {
        self.drId = drId;
    }
    
    if ([dicObject objectForKey: Store_lat]  ) {
        self.latitude = [[NSString stringWithValue:[dicObject objectForKey: Store_lat]] doubleValue];
    }
    if ([dicObject objectForKey: Store_lon]) {
        self.longitude = [[NSString stringWithValue:[dicObject objectForKey: Store_lon]] doubleValue];
    }
    NSString *sType = [NSString stringWithValue:[dicObject objectForKey:Store_styp]];
    if (sType && [sType length] > 0) {
        self.styp = sType;
    }
    
    NSString *code = [NSString stringWithValue:[dicObject objectForKey:Store_cod]];
    if ([code length] > 0) {
        self.code = code;
    }
    NSString *name = [NSString stringWithValue:[dicObject objectForKey:Store_name]];
    if ([name length] > 0) {
        self.name = name;
    }
    NSString *acvt_genId = [NSString stringWithValue:[dicObject objectForKey:Store_genid]];
    if ([acvt_genId length] > 0) {
        self.acvt_genId = acvt_genId;
    }
    self.is_plan = [NSString stringWithValue:[dicObject objectForKey:@"is_plan"]];

    NSString *empId = [NSString stringWithValue:[dicObject objectForKey:Store_empId]];
    if ([empId length] > 0) {
        NSString *currentEmpId = [WSAppData getObjectbyKey:APPDATA_EMPID];
        if (![self.empId isEqualToString:empId]) {
            LogError(@"这里可能不是错误，但是后台经常下发错误，所以当做错误报出。empId is %@, currentEmpId is %@", self.empId, currentEmpId);
        }
        self.empId = empId;
    }
    
    switch (self.storeAccessMode) {
        case WSStoreAccessModeSubEmp:
        {
           NSString* subEmpId = [NSString stringWithValue:[dicObject objectForKey:Store_empId]];
            if (subEmpId && [subEmpId length]  > 0) {
                self.srid = subEmpId;
            }
            /*
            [self addSubEmpInPlanStoreAcvt:dicObject];
            // 计划内外的随访门店生成prodArray 及 产品数据回显逻辑一样
            [self dealWithSubEmpStoreProds:dicObject];
             */
            
        }
            break;
        default:
        {
            [self addHos:dicObject];
            /*
            [self addAcvtDis:dicObject];
            [self addAcvts:dicObject];
            
        
            [self addPayDisplay:dicObject];
    
            if(!self.isInitForWSAppData){
                if(self.plan){
                    [self dealWithinPlanStoreProds];
                }else{
                    [self dealWithOutPlanStoreProds:dicObject];
                }
            }else{
                //经过沟通，不确定登陆串里是否会在以下节点【prods，storeproddis】下发包含计划外的的数据，特此做兼容，如果填充过此数据则不再。
                
                if(dicObject && self.plan==NO){
                    [self dealWithOutPlanStoreProds:dicObject];
                }
                if(!self.plan){
                    if (![WSAppData hasObject:@"prods"]) {
                        NSArray* ispArray =[dicObject objectForKey:@"prods"];
                        if(ispArray != nil)
                        {
                            NSMutableArray* array = [[NSMutableArray alloc]init];
                            [ispArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                NSDictionary* element = (NSDictionary*)obj;
                                NSString* p = [element objectForKey:@"p"];
                                NSArray* pArray = [p componentsSeparatedByString:@","];
                                [array addObject:pArray];
                            }];
                            
                            [WSAppData putObject:array forKey:OUTSTOREPROD];
                        }
                    }
                    if (![WSAppData hasObject:STOREPRODDIS]) {
                        //回显
                        NSArray* spdArray = [dicObject objectForKey:STOREPRODDIS];
                        if(spdArray != nil)
                        {
                            NSMutableArray* array = [[NSMutableArray alloc]init];
                            [spdArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                NSDictionary* element = (NSDictionary*)obj;
                                NSString* p = [element objectForKey:@"p"];
                                NSArray* pArray = [p componentsSeparatedByString:@","];
                                [array addObject:pArray];
                            }];
                            [WSAppData putObject:array forKey:STOREPRODDIS];
                        }
                    }
                }
            }
            */
        }
            break;
    }
}

- (void)clearStoreData
{
    
    if (!_acvtsArray) {
        _acvtsArray = [[NSMutableArray alloc]init];
    }else{
        [self.acvtsArray removeAllObjects];
    }
    
    if (!_promsArray) {
        _promsArray = [[NSMutableArray alloc]init];
    }else{
        [self.promsArray removeAllObjects];
    }
    
    if (!_comptArray) {
        _comptArray = [[NSMutableArray alloc]init];
    }else{
        [self.comptArray removeAllObjects];
    }
    
    if (!_hosArray) {
        _hosArray = [[NSMutableArray alloc]init];
    }else{
        [self.hosArray removeAllObjects];
    }
    
    if (!_prodArray) {
        _prodArray = [[NSMutableArray alloc]init];
    }else{
        [_prodArray removeAllObjects];
    }
    
    if (!_acvtDisArray) {
        _acvtDisArray = [[NSMutableArray alloc]init];
    }else{
        [self.acvtDisArray removeAllObjects];
    }
    
}

-(void)addSubEmpInPlanStoreAcvt:(NSDictionary*)aDic
{
    //acvts
    NSArray *l_acvtArray = [aDic objectForKey:Store_acvt];

    if(self.acvtsArray == nil)
        _acvtsArray = [[NSMutableArray alloc]initWithCapacity:[l_acvtArray count]];
    for(NSDictionary* l_dic in l_acvtArray)
    {
        NSString* l_sid = [NSString stringWithValue:[l_dic objectForKey:@"sid"]];
        
        NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithDictionary:l_dic];
        
        NSArray *allKeys = [newDic allKeys];
        for (NSString *key in allKeys) {
            if ([[newDic objectForKey:key] isKindOfClass:[NSNull class]]) {
                [newDic removeObjectForKey:key];
            }
        }
        
        if ([self.Id isEqualToString:l_sid]) {
            BOOL hasExit = NO;
            for (NSDictionary *subDic in _acvtsArray) {
                if ([subDic isEqualToDictionary:newDic]) {
                    hasExit = YES;
                }
            }
            if (!hasExit) {
                [_acvtsArray addObject:newDic];
            }
        }
    }
}

- (void)addAcvtArrayFromStores:(NSArray *)acvtArray
{
    if(_acvtsArray == nil)
        _acvtsArray = [[NSMutableArray alloc]initWithCapacity:[acvtArray count]];
    [_acvtsArray addObjectsFromArray:acvtArray];
}

- (void)modifyStoreInfo:(NSDictionary *)storeInfo{
    
    
    if ([storeInfo objectForKey:@"storeId"]) {
         self.Id = [storeInfo objectForKey:@"storeId"];
    }

    if ([storeInfo objectForKey:@"name"]) {
        self.name = [storeInfo objectForKey:@"name"];
    }
    if ([storeInfo objectForKey:@"code"]) {
        self.code = [storeInfo objectForKey:@"code"];
    }
    if ([storeInfo objectForKey:@"acvt_genId"]) {
        self.acvt_genId = [storeInfo objectForKey:@"acvt_genId"];
    }
    //日后再进行补充
    NSString *latitude = [NSString stringWithValue:[storeInfo objectForKey:Store_lat]];
    if ([latitude length] > 0) {
        self.latitude = [latitude doubleValue];
    }
    
    NSString *longitude = [NSString stringWithValue:[storeInfo objectForKey:@"lon"]];
    if ([longitude length] > 0) {
        self.longitude = [longitude doubleValue];
    }
    
    if ([storeInfo objectForKey:Store_img]) {
        self.storeImg = [storeInfo objectForKey:Store_img];
    }
    
}

#pragma mark - I_W_OptionDataItem

- (NSString *)getDataItemID
{
    return self.Id;
}

- (NSString *)getDataItemName
{
    return self.name;
}

#pragma mark -I_W_CELL

-(NSString *)getTtitle{
    
    return self.name;
}

-(NSInteger)getAccessStatus{


    return access_status;
}

-(NSString *)getCode{
    
    return self.code;
    
}

#pragma mark - I_W_Cell
-(NSString *)getName{

    return self.name;
}


- (NSString *)getPid{
    return self.pid;
}

- (NSString *)getId{
    
    return self.Id;
}

- (NSString *)getLevelCode{
    
    return self.level_code;
}
- (NSString *)getSub_Level_Code{
    return nil;
}
- (BOOL)getIsExpland{
    
    return self.isExpland;
}
- (BOOL)getOptioned{
    
    return self.isOption;
}
- (NSArray *)getSonBean{
    
    return self.sonBean;
}

- (void)setIsExpland:(BOOL)isExpland{
    _isExpland = isExpland;
}

- (void)setLevel_code:(NSString *)level_code{
    _level_code = level_code;
}

- (void)setSonBean:(NSMutableArray *)sonBean{
    
    _sonBean = sonBean;
}

- (void)setOptioned:(BOOL)isOptioned{
    
    _isOption = isOptioned;
}

- (NSString *)getStyp{
    return self.styp;
  
}

- (BOOL)getIsAllExpand {
    return self.isAllExpand;
}

- (void)setIsAllExpand:(BOOL)isAllExpand {
    _isAllExpand = isAllExpand;
}


- (NSString *)srid {
    if (self.isRestSrid) {
        return _srid;
    }
    NSString *currentEmpId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    if (![self.empId isEqualToString:currentEmpId]) {
        _srid = self.empId;
        self.isRestSrid = YES;
    }
    return _srid;
}

- (NSString *)drId {
    
    if (self.isSetDrid) {
        return _drId;
    }
    
    WSBaseStoreDistruleDBService *disruleService = [[WSBaseStoreDistruleDBService alloc] init];
    NSArray *drIdArray = [disruleService queryDrIdByStoreId:self.Id];
    if ([drIdArray count] > 0) {
        _drId = [drIdArray componentsJoinedByString:@","];
    }
    
    self.isSetDrid = YES;
    
    return _drId;
}

- (NSString *)getDisplayNameAndCode {
    NSString *storeName = nil;
    if (![self.Id isEqualToString:@"-1"] && self.name) {
        storeName = self.name;
        if (storeName) {
            storeName = [NSString stringWithFormat:@"%@",self.name];
        }
        NSString *storeCode = self.code;
        if (storeCode && [storeCode isKindOfClass:[NSString class]] && [storeCode length] > 0) {
            if (storeName && [storeName isKindOfClass:[NSString class]] && [storeName rangeOfString:storeCode].length >0) {
                storeName = self.name;
            }else{
                storeName = [NSString stringWithFormat:@"%@-%@",self.code,self.name];
                
            }
        }
    }
    return storeName;
}
@end

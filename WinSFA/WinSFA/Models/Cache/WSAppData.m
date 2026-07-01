//
//  AppData.m
//  WinchannelMobile_iphone
//
//  Created by Chen Angus on 11-7-2.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <sys/sysctl.h>
#include <mach/mach.h>
#include <mach/mach_time.h>
#import "WSAppData.h"
#import "WinSFA.h"
#import "WSFuncsBeanArray.h"
#import "WSInPlanStoreBean.h"
#import "WSOutPlanStoreBean.h"
#import "WSProdBeanArray.h"
#import "WSProdBeanArray.h"
#import "WinSFA.h"
#import "WSCurrentTime.h"
#import "WSProdBeanArray.h"
#import "WSPromBean.h"
#import "WSPromBeanArray.h"
#import "WSSugBean.h"
#import "WSSugBeanArray.h"
#import "WSDistStore.h"
#import "WSEmpAcvtDis.h"
#import "WSEmpAcvtDisArray.h"
#import "WSSubempstoreBeanArray.h"
#import "WSEmpinforefreshBeanArray.h"
#import "WSStoreInfoBeanArray.h"
#import "WSStoreAcvtDisArray.h"
#import "FileManager.h"
#import "WSServerIPList.h"
#import "WSAcvtShowBean.h"
#import "WSAcvtShowBeanArray.h"
#import "WSEmpInfoBeanArray.h"
#import "WSGeographicInfo.h"
#import "WSTableItemsArray.h"
#import "WSScheduleBrandArray.h"
#import "WSLocationArray.h"
#import "WSBrandLevelArray.h"
#import "WSSubmicsBeanArray.h"
#import "WSStoreDataSource.h"
#import "WSAcvtListFlagArray.h"
#import "WSCustomEnterStoreTimeObject.h"
#import "WSStoredDictDisArray.h"
#import "WSTestTools.h"
#import "WSDutyBeanArray.h"
#import "WSOthersAttendanceArray.h"
#import "WSStoreBeans.h"
#import "WSVisitPlanArray.h"
#import "WSStoreAcvtArray.h"
#import "WSProductValidateBeanArray.h"
#import "WSVisitedMenuArray.h"
#import "PayDisPlayBeanArray.h"
#import "WSBaseEmployeeBeanArray.h"
#import "WSEditableAcvtQstBeanArray.h"
#import "WSOrgBeanArray.h"
#import "WSEnvrionment.h"
#import "WSContactsBookTools.h"

static WSAppData *sharedDataManager = nil;
//======================================================================================================================================================

@interface WSAppData ()

@property (nonatomic, strong, readwrite) NSMutableDictionary *datas;

@end
//======================================================================================================================================================

@implementation WSAppData
@synthesize datas = _datas;

+ (WSAppData *)sharedManager {
    
    @synchronized(self) {
        if (nil == sharedDataManager) {
            sharedDataManager = [[self alloc] init];
            sharedDataManager.datas = [[NSMutableDictionary alloc] init];
        }
    }
    return sharedDataManager;
}

+ (id)allocWithZone:(NSZone *)zone {
    
    @synchronized(self) {
        if (nil == sharedDataManager) {
            sharedDataManager = [super allocWithZone:zone];
            return sharedDataManager;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    
    return self;
}

+ (void)recordObject:(id)aObject {
    
     [FileManager setUserDefaults:aObject forKey:APPDATA_LOCALOBJECTKEY];
}

+ (void)putData:(id)object {
    
    [WSAppData removeAll];                                  //移除所有数据
    [[WSTestTools getInstance] keepTimeWithKey:@"putData"];
    
    //字典项回显
    WSStoredDictDisArray* storedDictDisArray = [[WSStoredDictDisArray alloc]initWithObject:object];
    if (storedDictDisArray) {
        [sharedDataManager.datas setObject:storedDictDisArray forKey:STOREDICTDIS];
    }

    NSDictionary *dic = (NSDictionary *)object;
    if ([dic objectForKey:APPDATA_TASKINFO]) {
        
        id taskInfo = [dic objectForKey:APPDATA_TASKINFO];
        if ([taskInfo isKindOfClass:[NSArray class]]) {
            
            NSArray *taskInfoArray = (NSArray *)taskInfo;
            id info = [taskInfoArray firstObject];
            if ([info isKindOfClass:[NSDictionary class]]) {
                NSString *taskId = [info objectForKey:@"taskId"];
                [sharedDataManager.datas setObject:(taskId.length > 0 ? taskId : @"") forKey:APPDATA_TASKINFO];
            }
        }
    }
    
    if ([dic objectForKey:APPDATA_MAIL_LIST]) {
        [[WSContactsBookTools sharedManager] saveContactsBookWithDictionary:@{APPDATA_MAIL_LIST : [dic objectForKey:APPDATA_MAIL_LIST]}];
    }
    
    if ([dic objectForKey:APPDATA_CUS_MAIL_LIST]) {
        [[WSContactsBookTools sharedManager] saveStoreContactsBookWithDictionary:@{APPDATA_CUS_MAIL_LIST : [dic objectForKey:APPDATA_CUS_MAIL_LIST]}];
    }
    
    NSArray *extraReminderArray = [dic objectForKey:APPDATA_EXTRA_REMINDER_NODE_NAME];
    if (extraReminderArray && extraReminderArray.count > 0) {
        
        NSDictionary *element = [extraReminderArray firstObject];
        NSString *nodeName = [element objectForKey:APPDATA_EXTRA_REMINDER_NODE_NAME_KEY];
        if (nodeName && nodeName.length > 0) {
            [sharedDataManager.datas setObject:nodeName forKey:APPDATA_EXTRA_REMINDER_NODE_NAME];
        }
    }
    
    if ([dic objectForKey:APPDATA_BIZDATE]) {
        
        [sharedDataManager.datas setObject:[[dic objectForKey:APPDATA_BIZDATE] copy] forKey:APPDATA_BIZDATE];
        LogInfo(@"BIZDATE = %@", [dic objectForKey:APPDATA_BIZDATE]);
    }
    
    if ([dic objectForKey:APPDATA_EMPID]) {
        
        NSString *empId = [dic objectForKey:APPDATA_EMPID];
        if ([empId isKindOfClass:[NSNumber class]]) {
            empId = [(NSNumber *)empId stringValue];
        }
        [sharedDataManager.datas setObject:[empId copy] forKey:APPDATA_EMPID];
        [FileManager setUserDefaults:[empId copy] forKey:APPDATA_EMPID];
    }

    //获取强制退出时间
    NSNumber *exitTime = [object objectForKey:FORCEEXITTIME];
    if (exitTime != nil && [exitTime isKindOfClass:[NSNumber class]]) {
        
        if ([exitTime isKindOfClass:[NSNumber class]]) {
            [[self sharedManager].datas setObject:[exitTime stringValue] forKey:FORCEEXITTIME];
        }
    }
    
    //获取prodspec
    NSArray* prodspecArray = [object objectForKey:PRODSPEC];
    if (prodspecArray != nil) {
        
        NSDictionary* element = [prodspecArray objectAtIndex:0];
        NSString* s = [element objectForKey:@"s"];
        NSArray* sp = [s componentsSeparatedByString:@","];
        [sharedDataManager.datas setObject:sp forKey:PRODSPEC];
    }
    
    //获取prodspecdis
    // 用于区别产品展示页中（更多）在不同的产品展示页中的回显（列：产品分销，销售数据上报，订单库存上报）
    NSArray *prodspecdisArray = [object objectForKey:PRODSPECDIS];
    if (prodspecdisArray != nil) {
        
        id prodsData = [prodspecdisArray objectAtIndex:0];
        if ([prodsData isKindOfClass:[NSDictionary class]]) {
            NSString *prodspecdisString = [(NSDictionary *)prodsData objectForKey:@"s"];
            NSArray *specdisArray = [prodspecdisString componentsSeparatedByString:@","];
            [sharedDataManager.datas setObject:specdisArray forKey:PRODSPECDIS];
        }
    }
    
    //geo version
    NSArray *versionArray = [object objectForKey:GEOVERSION];
    if (versionArray != nil) {
        
        NSDictionary *dic = [versionArray objectAtIndex:0];
        NSString *version = [NSString stringWithValue:[dic objectForKey:GEOVERSIONVERSIONID]];
        if (version) {
            [sharedDataManager.datas setObject:version forKey:GEOVERSION];
        }
    }
    
    NSArray *receiverArray = [object objectForKey:SUBEMPTASK];
    if (receiverArray != nil) {
        
        [[self sharedManager].datas setObject:receiverArray forKey:SUBEMPTASK];
    }
    
    NSArray *remindArray = [object objectForKey:TASKREMIND];
    if (remindArray != nil) {
        
        [[self sharedManager].datas setObject:remindArray forKey:TASKREMIND];
    }
    
    WSOrgBeanArray *orgBeanArray = [[WSOrgBeanArray alloc] initWithObject:object];
    if (orgBeanArray  != nil) {
        
        [sharedDataManager.datas setObject:orgBeanArray forKey:ORG_RELATION];
    }
    
    //empInfo
    WSEmpInfoBeanArray *empInfoArray = [[WSEmpInfoBeanArray alloc] initWithObject:object];
    if (empInfoArray) {
        
        [sharedDataManager.datas setObject:empInfoArray forKey:EMPINFO];
    }
    
    //tb 节点
    WSTableItemsArray *tableItemsArray = [[WSTableItemsArray alloc] initWithObject:object];
    if (tableItemsArray) {
        
        [sharedDataManager.datas setObject:tableItemsArray forKey:TB];
    }
    
    //citynames 节点
    WSLocationArray *loactionArray = [[WSLocationArray alloc] initWithObject:object andNode:nil];
    if (loactionArray) {
        
        [sharedDataManager.datas setObject:loactionArray forKey:CITYNAMES];
    }
    
    //PointCityNames 节点
    WSLocationArray *pointcitys = [[WSLocationArray alloc] initWithObject:object andNode:GEOPOINTCITYNAMES];
    if (pointcitys != nil) {
        
        [sharedDataManager.datas setObject:pointcitys forKey:GEOPOINTCITYNAMES];
    }
    
    
    WSAcvtShowBeanArray *acvtShowBeans = [[WSAcvtShowBeanArray alloc] initWithObject:object];
    if (acvtShowBeans != nil) {
        
        [sharedDataManager.datas setObject:acvtShowBeans forKey:ACVTSHOW];
    }
    
    NSArray *serverRequireNode = [object objectForKey:SERVERREQUIRE];
    if (serverRequireNode) {
        
        [[self sharedManager].datas setObject:[serverRequireNode JSONString] forKey:SERVERREQUIRE];
    }
    
    // mobileHomePage 节点
    NSArray * mobileHomePage = [object objectForKey:MOBILEHOMEPAGE];
    if (mobileHomePage && mobileHomePage.count > 0) {
        
        NSDictionary *dic = [mobileHomePage objectAtIndex:0];
        NSString *tmpStr = [dic objectForKey:MOBILEHOMEPAGE];
        NSDictionary *contentDic = nil;
        if ([tmpStr rangeOfString:MobileHomePageReadingTimeKey].length > 0) {
            contentDic = [tmpStr objectFromJSONString];
        }
        else {
            if (!tmpStr) {
                tmpStr = @"";
            }
            contentDic = [[NSDictionary alloc] initWithObjectsAndKeys:tmpStr, MobileHomePageFcKey, @"-1", MobileHomePageReadingTimeKey, nil];
        }
        
        if (contentDic) {
            [[self sharedManager].datas  setObject:contentDic forKey:MOBILEHOMEPAGE];
        }
    }
    
    //mobilePicture 节点
    NSArray *mobilePicture = [object objectForKey:MOBILEPICTURE];
    if (mobilePicture) {
        
        [[self sharedManager].datas setObject:mobilePicture forKey:MOBILEPICTURE];
    }
    
    //新加ServerIP 节点
    WSServerIPList *serverIP=[[WSServerIPList alloc]initWithObject:object];
    if (serverIP) {
        
        [sharedDataManager.datas setObject:serverIP forKey:SERVERURL];
    }
    
    //优先取funcs2 在initWithObject方法中处理
    WSFuncsBeanArray *funcsArray = [[WSFuncsBeanArray alloc] initWithObject:object];
    if(funcsArray != nil) {

        [sharedDataManager.datas setObject:funcsArray forKey:FUNCS];
    }
    
    [[WSTestTools getInstance] keepTimeWithKey:@"planstore"];
    WSInPlanStoreBean *inplanstore = [[WSInPlanStoreBean alloc]initWithObjectForWSAppData:object];
    if (inplanstore) {
        
        [sharedDataManager.datas setObject:inplanstore forKey:INPLANSTORE];
    }
    
    WSOutPlanStoreBean *outplanstore = [[WSOutPlanStoreBean alloc]initWithObjectForWSAppData:object];
    if (outplanstore) {
        
        [sharedDataManager.datas setObject:outplanstore forKey:OUTPLANSTORE];
    }
    
    WSVisitPlanArray *visitPlanArray = [[WSVisitPlanArray alloc] initWithObject:object];
    if (visitPlanArray) {
        
        [sharedDataManager.datas setObject:visitPlanArray forKey:STOREACVTDIS_VISITPLAN];
    }
    

    [[WSTestTools getInstance] printAndEndTimeIntervalforKey:@"planstore"];
    WSStoreDataSource* newstore = [[WSStoreDataSource alloc] initWithDicArray:[object objectForKey:NEWSTORE] withNoteName:NEWSTORE];
    if (newstore) {
        
        [sharedDataManager.datas setObject:newstore forKey:NEWSTORE];
    }
    
    WSBaseEmployeeBeanArray *baseEmployeeBeanArray =[[WSBaseEmployeeBeanArray alloc]initWithObject:object];
    if (baseEmployeeBeanArray) {
        
        [sharedDataManager.datas setObject:baseEmployeeBeanArray forKey:@"store_emp"];
    }

    NSMutableArray *tmpArray = [NSMutableArray array];
    NSArray *afterAddArray = [object objectForKey:BASE_DATA_ENTRY];
    for (NSDictionary *dic in afterAddArray) {
        
        WSCustomEnterStoreTimeObject *customTimeObj = [[WSCustomEnterStoreTimeObject alloc] initWithDic:dic];
        if (customTimeObj) {
            [tmpArray addObject:customTimeObj];
        }
    }

    if ([tmpArray count] > 0) {
        [sharedDataManager.datas setObject:tmpArray forKey:BASE_DATA_ENTRY];
    }
    
    WSGeographicInfo *geoinfo = [[WSGeographicInfo alloc] initWithObject:object];
    if (geoinfo) {
        
        [sharedDataManager.datas setObject:geoinfo forKey:GEOINFO];
    }

    WSBrandLevelArray *brandarray = [[WSBrandLevelArray alloc] initWithObject:object];
    if (brandarray != nil) {
        
        [sharedDataManager.datas setObject:brandarray forKey:GEOPOINTINFO];
    }

    WSInPlanStoreBean *inempolan = [[WSInPlanStoreBean alloc] initWithObject:object noteName:INEMPPLAN];
    if (inempolan) {
        
        [sharedDataManager.datas setObject:inempolan forKey:INEMPPLAN];
    }
    
    WSOutPlanStoreBean *outempolan = [[WSOutPlanStoreBean alloc] initWithObject:object noteName:OUTEMPPLAN];
    if (outempolan) {
        
        [sharedDataManager.datas setObject:outempolan forKey:OUTEMPPLAN];
    }

    NSArray *busiAcvtArray = [object objectForKey:@"busiAcvt"];
    if (busiAcvtArray) {
        
        [sharedDataManager.datas setObject:busiAcvtArray forKey:@"busiAcvt"];
    }

    NSArray *spbaInfoArray = [object objectForKey:@"spbaInfo"];
    if (spbaInfoArray) {
        
         [sharedDataManager.datas setObject:spbaInfoArray forKey:@"spbaInfo"];
    }
    
    NSArray *loginTipArray = [object objectForKey:LOGIN_TIP];
    if (loginTipArray) {
        
        [sharedDataManager.datas setObject:loginTipArray forKey:LOGIN_TIP];
    }
    
    WSScheduleBrandArray *brands = [[WSScheduleBrandArray alloc] initWithObject:object];
    if (brands != nil) {
        
        [sharedDataManager.datas setObject:brands forKey:SCHEDULEBRAND_NODE];
    }
    
    WSStoreBeans  *store_real_in_the_future = [[WSStoreBeans alloc] initWithObjectForWSAppData:object andParseKey:STORES];
    if (store_real_in_the_future) {
        
        [sharedDataManager.datas setObject:store_real_in_the_future forKey:STORES];
    }

    NSArray *payDisPlayArray = [object objectForKey:@"pay"];
    PayDisPlayBeanArray *payDisPlays = [[PayDisPlayBeanArray alloc]initWithObject:payDisPlayArray];
    if (payDisPlayArray != nil) {
        [sharedDataManager.datas setObject:payDisPlays forKey:@"pay"];
    }

    WSDistStore *distStore = [[WSDistStore alloc]initWithObject:object];
    if (distStore) {
        [sharedDataManager.datas setObject:distStore forKey:DISTSTORE];
    }

    WSProdBeanArray* prods = [[WSProdBeanArray alloc]initWithObject:object];
    if (prods) {
        [sharedDataManager.datas setObject:prods forKey:PRODS];
    }
    
    WSPromBeanArray* proms = [[WSPromBeanArray alloc]initWithObject:object];
    if (proms) {
        [sharedDataManager.datas setObject:proms forKey:PROMS];
    }
    
    WSSugBeanArray* sugs = [[WSSugBeanArray alloc]initWithObject:object];
    if (sugs) {
        [sharedDataManager.datas setObject:sugs forKey:SUG];
    }

    WSEmpAcvtDisArray* l_empAcvtDisArray = [[WSEmpAcvtDisArray alloc]initWithObject:object];
    if (l_empAcvtDisArray) {
        [sharedDataManager.datas setObject:l_empAcvtDisArray forKey:EMPACVTDIS];
    }
   
    NSArray * allKey = [dic allKeys];
    for (NSString * objId in allKey) {
        
        if ([objId hasPrefix:SUBEMPSTORES]) {
            WSSubempstoreBeanArray *subBeans1=[[WSSubempstoreBeanArray alloc]initWithObject:object noteName:objId];
            if (subBeans1) {
                [sharedDataManager.datas setObject:subBeans1 forKey:objId];
            }
        }
    }
    
    WSSubempstoreBeanArray *parentempstore =[[WSSubempstoreBeanArray alloc]initWithObject:object noteName:@"parentempstore"];
    if (parentempstore) {
        [sharedDataManager.datas setObject:parentempstore forKey:@"parentempstore"];
    }

    //6200服务器内的信息查询内的业绩查询的数据的存储
    WSEmpinforefreshBeanArray *empinforefreshBeans=[[WSEmpinforefreshBeanArray alloc]initWithObject:object];
    if (empinforefreshBeans) {
        
        [sharedDataManager.datas setObject:empinforefreshBeans forKey:EMPINFOREFRESHS];
    }
    
    //6200服务器的路线管理
    WSStoreInfoBeanArray *storeinfoBeans=[[WSStoreInfoBeanArray alloc]initWithObject:object];
    if (storeinfoBeans) {
        
        [sharedDataManager.datas setObject:storeinfoBeans forKey:STOREINFOS];
    }
    
    if ([dic objectForKey:APPDATA_EMPNAME]) {
        
        [sharedDataManager.datas setObject:[[dic objectForKey:APPDATA_EMPNAME] copy] forKey:APPDATA_EMPNAME];
    }
    
    if ([dic objectForKey:APPDATA_TIMEMS]) {
        
        [sharedDataManager.datas setObject:[[dic objectForKey:APPDATA_TIMEMS] copy] forKey:APPDATA_TIMEMS];
        LogInfo(@"APPDATA_TIMEMS = %@", [dic objectForKey:APPDATA_TIMEMS]);
    }
    
    id maxCallNumObj = [dic objectForKey:APPDATA_MAXCALLNUM];
    if ([maxCallNumObj isKindOfClass:[NSArray class]]) {
        
        NSArray *maxCallNumArray = (NSArray *)maxCallNumObj;
        if ([maxCallNumArray count] > 0) {
            
            NSDictionary *maxCallNumDic = [maxCallNumArray objectAtIndex:0];
            NSString *maxCallNumString = [NSString stringWithValue:[maxCallNumDic objectForKey:APPDATA_MAXCALLNUM]];
            if (maxCallNumString && [maxCallNumString integerValue] > 0) {
                [sharedDataManager.datas setObject:[maxCallNumString copy] forKey:APPDATA_MAXCALLNUM];
            }
        }
    }
    
    //自动上传时间间隔
    id autoUploadObj = [dic objectForKey:MOBILE_AUTO_UPLOAD];
    NSString *mobileAutoUpload;
    if (autoUploadObj && [autoUploadObj isKindOfClass:[NSArray class]]) {
        
        NSArray *autoUploadArray = (NSArray *)autoUploadObj;
        if ([autoUploadArray isKindOfClass:[NSArray class]]) {
            
            if ([autoUploadArray count] > 0) {
                NSDictionary *autoUploadDic = [autoUploadArray objectAtIndex:0];
                NSString *obj = [NSString stringWithValue:[autoUploadDic objectForKey:MOBILE_AUTO_UPLOAD]];
                if (obj) {
                    mobileAutoUpload = obj;
                }
            }
        }
    }
    if (!mobileAutoUpload || [mobileAutoUpload length] == 0) {
        mobileAutoUpload = @"30"; //默认自动上传间隔时间30分钟
    }
    [sharedDataManager.datas setObject:mobileAutoUpload forKey:MOBILE_AUTO_UPLOAD];
    
    //未上传数据处理方案标记
    BOOL hasValue = NO;
    id checkUploadObj = [dic objectForKey:CHECK_UPLOADED_DATA];
    if (checkUploadObj && [checkUploadObj isKindOfClass:[NSArray class]] ) {
        
        NSArray *autoUploadArray = (NSArray *)checkUploadObj;
        if ([autoUploadArray isKindOfClass:[NSArray class]]) {
            
            if ([autoUploadArray count] > 0) {
                
                NSDictionary *autoUploadDic = [autoUploadArray objectAtIndex:0];
                NSString *obj = [NSString stringWithValue:[autoUploadDic objectForKey:CHECK_UPLOADED_DATA]];
                if (obj) {
                    [sharedDataManager.datas setObject:[obj copy] forKey:CHECK_UPLOADED_DATA];
                    hasValue = YES;
                }
            }
        }
    }
    if (hasValue == NO) {
        [sharedDataManager.datas setObject:@"1" forKey:CHECK_UPLOADED_DATA];
    }
    
    //登录数据版本
    if ([dic objectForKey:CACHE_DATA_VERSION_NODE]) {
        
        [sharedDataManager.datas setObject:[[dic objectForKey:CACHE_DATA_VERSION_NODE] copy] forKey:CACHE_DATA_VERSION_NODE];
    }
    [sharedDataManager.datas setObject:[WSCurrentTime getTimeMillisString] forKey:APPDATA_LOGINTIME];
    
    //消息是否显示“回复”按钮
    if ([dic objectForKey:APPDATA_NOREPLY]) {
        [sharedDataManager.datas setObject:[[NSString stringWithValue:[dic objectForKey:APPDATA_NOREPLY]] copy] forKey:APPDATA_NOREPLY];
    }
    
    [sharedDataManager.datas setObject:[WSCurrentTime getTimeMillisString] forKey:APPDATA_LOGINTIME];
    
    if ([object isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *dic = (NSDictionary *)object;
        if ([dic objectForKey:EMPNAME]) {
            [sharedDataManager.datas setObject:[[dic objectForKey:EMPNAME] copy] forKey:EMPNAME];
        }
    }
    
    WSSubmicsBeanArray *submicsArray=[[WSSubmicsBeanArray alloc] initWithObject:object];
    if (submicsArray) {
        [sharedDataManager.datas setObject:submicsArray forKey:SUBMICS];
    }
    
    // 密码提示到期
    if ([dic objectForKey:PSW_VALID_DAY_MSG]) {
        [sharedDataManager.datas setObject:[[NSString stringWithValue:[dic objectForKey:PSW_VALID_DAY_MSG]] copy] forKey:PSW_VALID_DAY_MSG];
    }
    //地理位置权限弹框
    if ([dic objectForKey:VISITPRIVACYPOLOCY]){
        NSArray * polocyArray = [dic objectForKey:VISITPRIVACYPOLOCY];
        NSDictionary * polocyDic = polocyArray.firstObject;
        NSString * empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
        NSString * visitPrivacyPolicyFlag = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@",VISITPRIVACYFLAG,ISNULL(empId)]];

        if(polocyDic&&!visitPrivacyPolicyFlag.boolValue){
            NSString * emp_id = [polocyDic objectForKey:@"empId"];
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithValue:[polocyDic objectForKey:@"flag"]] forKey:[NSString stringWithFormat:@"%@_%@",VISITPRIVACYFLAG,ISNULL(emp_id)]];
            [sharedDataManager.datas setObject:[[NSString stringWithValue:[polocyDic objectForKey:@"message"]] copy] forKey:VISITPRIVACYMESSAGE];
            if([polocyDic.allKeys containsObject:@"pVersion"]){
                [sharedDataManager.datas setObject:[NSString stringWithValue:[polocyDic objectForKey:@"pVersion"]]  forKey:VISITPRIVACYVERRSION];
            }
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
      
    }
    
    // 新的用于生成下载本app的二维码的url
    // 如果新节点不存在，则检查ver节点下是否有updateUrl用作生成二维码。
    NSString *saasUrl = [WSEnvrionment getSaasUrl];
    if (!saasUrl || [saasUrl length] == 0) {
        
        NSString *qrUrl = [dic objectForKey:APPDATA_QR_URL];
        if (qrUrl && [qrUrl isKindOfClass:[NSString class]] && ![qrUrl isEqualToString:@""] && ![qrUrl isEqualToString:@"null"]) {
            
            [sharedDataManager.datas setObject:[NSString stringWithValue:qrUrl] forKey:APPDATA_QR_URL];
            [[NSUserDefaults standardUserDefaults] setValue:qrUrl forKey:APPDATA_QR_URL];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else {
            
            if ([dic objectForKey:@"ver"]) {
                NSDictionary *version = [dic objectForKey:@"ver"];
                if ([version objectForKey:APPDATA_UPDATEURL]) {
                    NSString *updateUrl = [version objectForKey:APPDATA_UPDATEURL];
                    [sharedDataManager.datas setObject:[NSString stringNotNilWithValue:updateUrl] forKey:APPDATA_UPDATEURL];
                    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringNotNilWithValue:updateUrl] forKey:APPDATA_QR_URL];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
        }
    }
    // acvt action显示
    WSAcvtListFlagArray *listFlagArray=[[WSAcvtListFlagArray alloc] initWithObject:object];
    if ([dic objectForKey:MENUACVTLISTFLAG]) {
        [sharedDataManager.datas setObject:listFlagArray forKey:MENUACVTLISTFLAG];
    }
    
    // acvt 产品列表回显显示
    WSAcvtListFlagArray *listFlagArrayEcho=[[WSAcvtListFlagArray alloc] initWithObjectEcho:object];
    if ([dic objectForKey:MENUACVTLISTFLAGECHO]) {
        [sharedDataManager.datas setObject:listFlagArrayEcho forKey:MENUACVTLISTFLAGECHO];
    }

    //考勤历史记录数据 节点
    WSDutyBeanArray *dutyArray = [[WSDutyBeanArray alloc] initWithObject:object];
    if (dutyArray) {
        [sharedDataManager.datas setObject:dutyArray forKey:DUTY_ATTENDANCEDETAIL];
    }
    
    //sanofi考勤设置记录 节点
    WSOthersAttendanceArray *oaArray = [[WSOthersAttendanceArray alloc] initWithObject:object];
    if (oaArray) {
        [sharedDataManager.datas setObject:oaArray forKey:DUTY_OTHERSATTENDANCE];
    }
    
    //箭牌，用于两个菜单之间的逻辑校验
    WSProductValidateBeanArray *prodValidateArray = [[WSProductValidateBeanArray alloc] initWithObject:object];
    if (prodValidateArray) {
        [sharedDataManager.datas setObject:prodValidateArray forKey:PRODUCT_VALIDATE];
    }
    
    //箭牌，用来标识一个门店下的某个菜单已上传过数据
    WSVisitedMenuArray *visitedMenuArray = [[WSVisitedMenuArray alloc] initWithObject:object];
    if (visitedMenuArray) {
        [sharedDataManager.datas setObject:visitedMenuArray forKey:VISITED_MENU];
    }
    
    WSEditableAcvtQstBeanArray *editableQstArray = [[WSEditableAcvtQstBeanArray alloc] initWithObject:object];
    if (editableQstArray) {
        [sharedDataManager.datas setObject:editableQstArray forKey:EDITABLE_ACVTQST];
    }
    
    NSString *loginRedircteFc = (NSString *)[object objectForKey:APPDATA_LOGIN_REDIRECT_FC];
    NSArray *loginRedircteFcArray = [loginRedircteFc componentsSeparatedByString:@","];
    if ([loginRedircteFcArray count] > 0) {
        [sharedDataManager.datas setObject:loginRedircteFcArray forKey:APPDATA_LOGIN_REDIRECT_FC];
    }
    
    if ([dic objectForKey:REDIS_DATA]) {
        
        NSString *redisData = [dic objectForKey:REDIS_DATA];
        if (redisData && [redisData isKindOfClass:[NSDictionary class]]) {
            NSDictionary *redisDic = (NSDictionary *)redisData;
            redisData = [redisDic objectForKey:REDIS_DATA];
        }
        [sharedDataManager.datas setObject:[NSString stringWithValue:redisData] forKey:REDIS_DATA];
    }
    
    if ([dic objectForKey:APPDATA_SIGNKEY]) {
        
        NSString *signKey = [dic objectForKey:APPDATA_SIGNKEY];
        [sharedDataManager.datas setObject:signKey forKey:APPDATA_SIGNKEY];
    }
    //轻覆盖
    if ([dic objectForKey:APPDATA_SIGNKEY]) {
        
    }
}

+ (void)putObject:(id)object forKey:(NSString*)key {
    
    [sharedDataManager.datas setObject:object forKey:key];
}

+ (id)getUnplannedData:(id)key {
    
    return [sharedDataManager.datas objectForKey:key];
}

+ (id)getObjectbyKey:(const NSString *)key {
    
    if ([key isEqualToString:APPDATA_BIZDATE]) {

        NSString *isOfflineLanding = [[NSUserDefaults standardUserDefaults] objectForKey:IS_OFFLINE_LANDING];
        if ([isOfflineLanding isEqualToString:@"1"]) {
            return [WSCurrentTime getDateString];
        }
    }
    else if ([key isEqualToString:APPDATA_EMPID]){
        
        NSString * empid = [[self sharedManager].datas objectForKey:key];
        if (!empid) {
            empid = @"";
        }
        return empid;
    }
    
    return [[self sharedManager].datas objectForKey:key];
}

+ (BOOL)hasObject:(const NSString *)key {
    
    BOOL result;
    result= ([[self sharedManager].datas objectForKey:key] != nil);
    return result;
}

+ (BOOL)removeAll {
    
    NSString *cacheEmpid = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]] ;
    [[self sharedManager].datas removeAllObjects];
    [WSAppData putObject:cacheEmpid forKey:APPDATA_EMPID];
    return YES;
}

+ (id)getLocalObject {
    
    return [FileManager getUserDefaults:APPDATA_LOCALOBJECTKEY];
}

+ (time_t)uptime {
    
    struct timeval boottime;
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    size_t size = sizeof(boottime);
    time_t now;
    time_t uptime = -1;
    
    (void)time(&now);
    
    if (sysctl(mib, 2, &boottime, &size, NULL, 0) != -1 && boottime.tv_sec != 0) {
        uptime = now - boottime.tv_sec;
    }
    return uptime;
}

+ (BOOL)getIsShowLoginRedirectWithFcCode:(NSString *)fcCode {
    
    if (!fcCode || fcCode.length <= 0) {
        return NO;
    }
    
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    id loginRedirectCache = [FileManager getUserDefaults:APPDATA_LOGIN_REDIRECT_FC_CACHE];
    if (loginRedirectCache) {
        
        NSDictionary *dictionary = (NSDictionary *)loginRedirectCache;
        NSArray *array = (NSArray *)[dictionary objectForKey:empId];
        if ([array containsObject:fcCode]) {
            return YES;
        }
    }
    return NO;
}

+ (void)setIsShowLoginRedirectWithFcCode:(NSString *)fcCode {
    
    if (!fcCode || fcCode.length <= 0) {
        return;
    }
    
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    id loginRedirectCache = [FileManager getUserDefaults:APPDATA_LOGIN_REDIRECT_FC_CACHE];
    if (loginRedirectCache) {
        
        NSDictionary *dictionary = (NSDictionary *)loginRedirectCache;
        NSArray *array = (NSArray *)[dictionary objectForKey:empId];
        if ([array containsObject:fcCode]) {
            return;
        }
        
        NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:array];
        [newArray addObject:fcCode];
        NSMutableDictionary *newDictionary = [[NSMutableDictionary alloc] initWithDictionary:loginRedirectCache];
        [newDictionary setObject:newArray forKey:empId];
        [FileManager setUserDefaults:newDictionary forKey:APPDATA_LOGIN_REDIRECT_FC_CACHE];
    }
    else {
        
        NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:1];
        [newArray addObject:fcCode];
        NSMutableDictionary *newDictionary = [[NSMutableDictionary alloc] initWithCapacity:1];
        [newDictionary setObject:newArray forKey:empId];
        [FileManager setUserDefaults:newDictionary forKey:APPDATA_LOGIN_REDIRECT_FC_CACHE];
    }
}

+ (NSString *)compareCurrentStrTime:(NSString*)compareStr withMonth:(int)month andDays:(int)days {
    
    NSDateFormatter *inputFormatter = [NSDateFormatter standardDateFormatter];
    [inputFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate* inputDate = [inputFormatter dateFromString:compareStr];

    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:month];
    [comps setDay:days];
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *mDate = [calender dateByAddingComponents:comps toDate:inputDate options:0];
    NSString *dateString = [inputFormatter stringFromDate:mDate];
    return dateString;
}

+ (void)removeIsShowLoginRedirect {
    
    [FileManager removeDefaultsByKey:APPDATA_LOGIN_REDIRECT_FC_CACHE];
}

@end
//======================================================================================================================================================

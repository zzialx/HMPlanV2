//
//  WSStoreHttpService.h
//  WinSFA
//
//  Created by yang on 17/3/8.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSBaseHttpService.h"
#define kIsSearchAbleAuto         @"auto"
#define kIsSearchAbleRemote         @"remote"

@interface WSStoreHttpService : WSBaseHttpService
@property (nonatomic, strong) NSString    *jsEmpID;   //js跳转提供的empID
@property (nonatomic , copy) NSString * bizDate;      // 业务日期  MN-286
@property (nonatomic , strong) WSFuncsBean * currentFunc;
@property (nonatomic , copy) NSString *currentCity;
@property (nonatomic , copy) NSString *searchString;  // 查询的关键字
@property (assign) CLLocationCoordinate2D               location; // 定位数据
@property (nonatomic, strong) NSString *subMenuFuncsCode;
@property (nonatomic, assign) BOOL isUploadLocationInfo;
@property (nonatomic, strong) NSString *cityCode;
@property (nonatomic, strong) NSDictionary *searchConditionDic;
@property (nonatomic, assign) float distance;
@property (nonatomic, strong) NSString *filterString;// 筛选的的关键字

@property (nonatomic, strong) NSString *orgId;//分公司id
@property (nonatomic , copy) NSString *currentOrg;//当前分公司
@property (nonatomic , copy) NSString *downLoadStoreListType;//门店下载类型

//YIHAIKERRY-2888
@property (nonatomic, assign) double maxLat;    //最大纬度
@property (nonatomic, assign) double minLat;    //最小纬度
@property (nonatomic, assign) double maxLon;    //最大经度
@property (nonatomic, assign) double minLon;    //最小经度

- (void)getOutplanStoreDataWithCompletionBlock:(WSBaseHttpServiceBlock)completionBlock;
- (void)getCustomerQueryStoreListDataWithCompletionBlock:(WSBaseHttpServiceBlock)completionBlock;

@end

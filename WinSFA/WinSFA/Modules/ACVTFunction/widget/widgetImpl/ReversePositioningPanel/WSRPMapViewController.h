//
//  WSRPMapViewController.h
//  WinSFA
//
//  Created by mac on 17/4/20.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "BaseViewController.h"
#import "WSStoreHttpService.h"

typedef NS_ENUM(unsigned int, WSRPViewCType) {
    WSRPViewCTypeLocation   = 0,//cell展示地理位置页面
    WSRPViewCTypeStore      = 1, //cell展示门店页面
};
@class AMapPOI;
/**
    可以根据地址搜索并指定某个地理位置
 */
@interface WSRPMapViewController : BaseViewController

@property (nonatomic , copy) NSString *range;  //收索范围
@property (nonatomic , copy) NSString *condition;  //收索条件
@property (nonatomic , copy) NSString *maxItem;  //最大显示多少条数据
@property (nonatomic , copy) NSString *searchPlaceholder;  //收索框占位符
@property (nonatomic , copy) NSString *downByMap;  //离线门店
@property (nonatomic , strong) WSStoreHttpService * storeHttpService;  // 门店请求工具
@property (nonatomic, strong) WSSubempstoreBean *subempStore;
@property (nonatomic, strong) NSString *subMenuFuncsCode;
@property (nonatomic , strong) NSMutableArray * storeTableArray;
///经纬度
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

//页面的展示的type
@property (nonatomic, assign) WSRPViewCType ViewCType;






@property (nonatomic , copy) void (^confirmButtomClick)(AMapPOI * poi,NSString * provinceCityDistricy); // 回传的信息
@end

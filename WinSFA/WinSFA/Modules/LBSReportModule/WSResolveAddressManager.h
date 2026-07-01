//
//  WSResolveAddressManager.h
//  WinSFA
//
//  Created by mac on 17/3/20.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
/**
    高德解析地址的管理类
 */

typedef void(^getFormattedAddress)(AMapReGeocode * regeocode ,NSError * error);
typedef void(^getGeocodes)(NSArray * array ,NSError * error);
typedef void(^getPois)(NSArray * array ,NSError * error);

@interface WSResolveAddressManager : NSObject

@property (nonatomic , copy) getFormattedAddress getAddressBlock;  // 回调地址信息
@property (nonatomic , copy) getGeocodes  getGeocodesBlock;     // 地理编码结果 AMapGeocode 数组
@property (nonatomic , copy) getPois  getPoisBlock ;        // 请求的周围数据集合


+(instancetype)shareInstance;

/**
    根据经纬度解析地址

 @param coordinate2D 经纬度
 */
-(void)startGetFormattedAddressWith:(CLLocationCoordinate2D)coordinate2D withBlock:(getFormattedAddress)getAddressBlock;

/**
    根据地址获取地址对应的地理信息
 
 @param address 要收索的地址信息
 */
-(void)startGetReGeocodeSearchWith:(NSString *)address withBlock:(getGeocodes)getGeocodesBlock;

/**
    POI 周边查询接口
 */
-(void)startGetAroundSearchWith:(AMapPOIAroundSearchRequest *)request withBlock:(getPois)getPoisBlock;;
/**
  根据条件查询
 */

-(void)startAMapPOIKeywordsSearchWith:(AMapPOIKeywordsSearchRequest *)request withBlock:(getPois)getPoisBlock;

@end

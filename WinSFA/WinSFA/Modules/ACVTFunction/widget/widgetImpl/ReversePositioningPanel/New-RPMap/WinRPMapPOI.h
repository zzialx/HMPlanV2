//
//  WinRPMapPOI.h
//  WinSFA
//
//  Created by yuanji on 2019/7/10.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
//=================================================================================================================================

NS_ASSUME_NONNULL_BEGIN

#pragma mark - RP地图poi
@interface WinRPMapPOI : NSObject

@property (nonatomic, copy) NSString *name;                 //名称
@property (nonatomic, copy) NSString *address;              //地址
@property (nonatomic, copy) NSString *distance;             //距离
@property (nonatomic, copy) NSString *provinceCityDistricy; //省市区信息
@property (nonatomic, strong) NSDictionary *areaCodeDic;    //地区代码
@property (nonatomic, strong) CLLocation *currentLocation;  //当前定位信息
@property (nonatomic, strong) CLLocation *wgs84Location;    //wgs84定位信息

@end

NS_ASSUME_NONNULL_END
//=================================================================================================================================


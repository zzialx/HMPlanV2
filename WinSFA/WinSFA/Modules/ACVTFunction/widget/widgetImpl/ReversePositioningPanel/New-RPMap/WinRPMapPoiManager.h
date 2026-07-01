//
//  WinRPMapPoiManager.h
//  WinSFA
//
//  Created by yuanji on 2019/7/10.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol WinRPMapPoiManagerDelegate;
@class AMapReGeocode;

extern NSString *const WinMapPoiSearchCountMrak;    //地图poi搜索数量标示
extern NSString *const WinMapPoiSearchRadiusMrak;   //地图poi搜索半径标示
extern NSString *const WinMapPoiSearchKeywordsMrak; //地图poi搜索关键字标示

NS_ASSUME_NONNULL_BEGIN
//=================================================================================================================================

#pragma mark - RP地图poi管理器
@interface WinRPMapPoiManager : NSObject

@property (nonatomic, weak) id <WinRPMapPoiManagerDelegate> delegate; //RP地图poi管理器代理指针

- (void)queryGaoDeReGoecodeSearchWithLocation:(CLLocation *)location;                                           //查询逆地址编码方法(针对高德)
- (void)queryGaoDePoiAroundSearchWithLocation:(CLLocation *)location auxiliaryInfo:(NSDictionary *)infoDic;     //查询poi方法(针对高德-周边查询)
- (void)queryGaoDePoiKeywordsSearchWithLocation:(CLLocation *)location auxiliaryInfo:(NSDictionary *)infoDic;   //查询poi方法(针对高德-关键字查询)

- (void)queryAppleReGoecodeSearchWithLocation:(CLLocation *)location;                                           //查询逆地址编码方法(针对苹果)
- (void)queryApplePoiAroundSearchWithLocation:(CLLocation *)location auxiliaryInfo:(NSDictionary *)infoDic;     //查询poi方法(针对苹果-周边查询)
- (void)queryApplePoiKeywordsSearchWithLocation:(CLLocation *)location auxiliaryInfo:(NSDictionary *)infoDic;   //查询poi方法(针对苹果-关键字查询)

@end
//=================================================================================================================================

#pragma mark -RP地图poi管理器代理协议
@protocol WinRPMapPoiManagerDelegate <NSObject>

@optional //可选
- (void)queryGaoDeReGoecodeSearchSuccess:(WinRPMapPoiManager *)manager successData:(AMapReGeocode *)regeocode;  //逆地址编码成功方法(针对高德)
- (void)queryGaoDeReGoecodeSearchFailed:(WinRPMapPoiManager *)manager failedData:(NSError *)error;              //逆地址编码失败方法(针对高德)

- (void)queryGaoDePoiAroundSearchSuccess:(WinRPMapPoiManager *)manager successData:(NSArray *)poiArray;         //poi成功方法(针对高德-周边查询)
- (void)queryGaoDePoiAroundSearchFailed:(WinRPMapPoiManager *)manager failedData:(NSError *)error;              //poi失败方法(针对高德-周边查询)

- (void)queryGaoDePoiKeywordsSearchSuccess:(WinRPMapPoiManager *)manager successData:(NSArray *)poiArray;       //poi成功方法(针对高德-关键字查询)
- (void)queryGaoDePoiKeywordsSearchFailed:(WinRPMapPoiManager *)manager failedData:(NSError *)error;            //poi失败方法(针对高德-关键字查询)

- (void)queryAppleReGoecodeSearchSuccess:(WinRPMapPoiManager *)manager successData:(CLPlacemark *)placemark;    //逆地址编码成功方法(针对苹果)
- (void)queryAppleReGoecodeSearchFailed:(WinRPMapPoiManager *)manager failedData:(NSError *)error;              //逆地址编码失败方法(针对苹果)

- (void)queryApplePoiAroundSearchSuccess:(WinRPMapPoiManager *)manager successData:(NSArray *)poiArray;         //poi成功方法(针对苹果-周边查询)
- (void)queryApplePoiAroundSearchFailed:(WinRPMapPoiManager *)manager failedData:(NSError *)error;              //poi失败方法(针对苹果-周边查询)

- (void)queryApplePoiKeywordsSearchSuccess:(WinRPMapPoiManager *)manager successData:(NSArray *)poiArray;       //poi成功方法(针对苹果-关键字查询)
- (void)queryApplePoiKeywordsSearchFailed:(WinRPMapPoiManager *)manager failedData:(NSError *)error;            //poi失败方法(针对苹果-关键字查询)

@end

NS_ASSUME_NONNULL_END
//=================================================================================================================================


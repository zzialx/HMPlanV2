//
//  WinRPMapPoiManager.m
//  WinSFA
//
//  Created by yuanji on 2019/7/10.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import "WinRPMapPoiManager.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

NSString *const WinMapPoiSearchCountMrak = @"mapPoiSearchCount";        //定义 地图poi搜索数量标示
NSString *const WinMapPoiSearchRadiusMrak = @"mapPoiSearchRadius";      //定义 地图poi搜索半径标示
NSString *const WinMapPoiSearchKeywordsMrak = @"mapPoiSearchKeywords";  //定义 地图poi搜索关键字标示
//=================================================================================================================================

#pragma mark - RP地图poi管理器 延展(内部)
@interface WinRPMapPoiManager ()

@property (nonatomic, strong) AMapSearchAPI *mapSearch; //搜索器(针对高德地图)

@end
//=================================================================================================================================

#pragma mark - RP地图poi管理器 延展(实现AMapSearchDelegate代理协议)
@interface WinRPMapPoiManager (mapSearchDelegate) <AMapSearchDelegate>

@end
//=================================================================================================================================

#pragma mark - RP地图poi管理器
@implementation WinRPMapPoiManager

#pragma mark - 重写init方法
- (instancetype)init {
    
    self = [super init];
    if (self) {
        _mapSearch = [[AMapSearchAPI alloc] init];
        _mapSearch.delegate = self;
    }
    return self;
}

#pragma mark - 重写dealloc方法
- (void)dealloc {
    
    _mapSearch.delegate = nil;
}

#pragma mark - 查询逆地址编码方法(针对高德)
- (void)queryGaoDeReGoecodeSearchWithLocation:(CLLocation *)location {
    
    AMapReGeocodeSearchRequest *request = [[AMapReGeocodeSearchRequest alloc] init];
    request.requireExtension = YES;
    request.location = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    [self.mapSearch AMapReGoecodeSearch:request];
}

#pragma mark - 查询poi方法(针对高德-周边查询)
- (void)queryGaoDePoiAroundSearchWithLocation:(CLLocation *)location auxiliaryInfo:(NSDictionary *)infoDic {
    
    NSString *keywords = [infoDic objectForKey:WinMapPoiSearchKeywordsMrak];
    NSInteger offset = [[infoDic objectForKey:WinMapPoiSearchCountMrak] integerValue];
    NSInteger radius = [[infoDic objectForKey:WinMapPoiSearchRadiusMrak] integerValue];
    
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.sortrule = 0;
    request.keywords = (keywords.length > 0) ? keywords : @"";
    request.offset = (offset > 0) ? offset : 10;
    request.radius = (radius > 0) ? radius : 3000;
    request.requireExtension = YES;
    request.location = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    [self.mapSearch AMapPOIAroundSearch:request];
}

#pragma mark - 查询poi方法(针对高德-关键字查询)
- (void)queryGaoDePoiKeywordsSearchWithLocation:(CLLocation *)location auxiliaryInfo:(NSDictionary *)infoDic {
    
    NSString *keywords = [infoDic objectForKey:WinMapPoiSearchKeywordsMrak];
    
    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
    request.keywords = (keywords.length > 0) ? keywords : @"";
    request.requireExtension = YES;
    [self.mapSearch AMapPOIKeywordsSearch:request];
}

#pragma mark - 查询逆地址编码方法(针对苹果)
- (void)queryAppleReGoecodeSearchWithLocation:(CLLocation *)location {
    
    __weak WinRPMapPoiManager *weakSelf = self;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *array, NSError *error) {
        if (error) {
            if ([weakSelf.delegate respondsToSelector:@selector(queryAppleReGoecodeSearchFailed:failedData:)]) {
                [weakSelf.delegate queryAppleReGoecodeSearchFailed:self failedData:error];
            }
            return;
        }
        
        CLPlacemark *placemark = [array firstObject];
        if ([weakSelf.delegate respondsToSelector:@selector(queryAppleReGoecodeSearchSuccess:successData:)]) {
            [weakSelf.delegate queryAppleReGoecodeSearchSuccess:weakSelf successData:placemark];
        }
    }];
}

#pragma mark - 查询poi方法(针对苹果-周边查询)
- (void)queryApplePoiAroundSearchWithLocation:(CLLocation *)location auxiliaryInfo:(NSDictionary *)infoDic {
    
    NSString *keywords = [infoDic objectForKey:WinMapPoiSearchKeywordsMrak];
    NSInteger radius = [[infoDic objectForKey:WinMapPoiSearchRadiusMrak] integerValue];
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.region = MKCoordinateRegionMakeWithDistance(location.coordinate, radius, radius);
    request.naturalLanguageQuery = keywords;
    MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    
    __weak WinRPMapPoiManager *weakSelf = self;
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (error) {
            if ([weakSelf.delegate respondsToSelector:@selector(queryApplePoiAroundSearchFailed:failedData:)]) {
                [weakSelf.delegate queryApplePoiAroundSearchFailed:self failedData:error];
            }
            return;
        }
        
        if ([weakSelf.delegate respondsToSelector:@selector(queryApplePoiAroundSearchSuccess:successData:)]) {
            [weakSelf.delegate queryApplePoiAroundSearchSuccess:weakSelf successData:response.mapItems];
        }
    }];
}

#pragma mark - 查询poi方法(针对苹果-关键字查询)
- (void)queryApplePoiKeywordsSearchWithLocation:(CLLocation *)location auxiliaryInfo:(NSDictionary *)infoDic {
    
    NSString *keywords = [infoDic objectForKey:WinMapPoiSearchKeywordsMrak];
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = keywords;
    MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    
    __weak WinRPMapPoiManager *weakSelf = self;
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (error) {
            if ([weakSelf.delegate respondsToSelector:@selector(queryApplePoiKeywordsSearchFailed:failedData:)]) {
                [weakSelf.delegate queryApplePoiKeywordsSearchFailed:self failedData:error];
            }
            return;
        }
        
        if ([weakSelf.delegate respondsToSelector:@selector(queryApplePoiKeywordsSearchSuccess:successData:)]) {
            [weakSelf.delegate queryApplePoiKeywordsSearchSuccess:weakSelf successData:response.mapItems];
        }
    }];
}

@end
//=================================================================================================================================

#pragma mark - RP地图poi管理器 延展(实现AMapSearchDelegate代理协议)
@implementation WinRPMapPoiManager (mapSearchDelegate)

#pragma mark - 实现onReGeocodeSearchDone:response:代理方法
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
    
    if ([self.delegate respondsToSelector:@selector(queryGaoDeReGoecodeSearchSuccess:successData:)]) {
        [self.delegate queryGaoDeReGoecodeSearchSuccess:self successData:response.regeocode];
    }
}

#pragma mark - 实现onPOISearchDone:response:代理方法
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response {
    
    if ([request isKindOfClass:[AMapPOIAroundSearchRequest class]]) {
        if ([self.delegate respondsToSelector:@selector(queryGaoDePoiAroundSearchSuccess:successData:)]) {
            [self.delegate queryGaoDePoiAroundSearchSuccess:self successData:response.pois];
        }
        return;
    }
    
    if ([request isKindOfClass:[AMapPOIKeywordsSearchRequest class]]) {
        if ([self.delegate respondsToSelector:@selector(queryGaoDePoiKeywordsSearchSuccess:successData:)]) {
            [self.delegate queryGaoDePoiKeywordsSearchSuccess:self successData:response.pois];
        }
        return;
    }
}

#pragma mark - 实现AMapSearchRequest:didFailWithError:代理方法
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    
    if ([request isKindOfClass:[AMapReGeocodeSearchRequest class]]) {
        if ([self.delegate respondsToSelector:@selector(queryGaoDeReGoecodeSearchFailed:failedData:)]) {
            [self.delegate queryGaoDeReGoecodeSearchFailed:self failedData:error];
        }
        return;
    }
    
    if ([request isKindOfClass:[AMapPOIAroundSearchRequest class]]) {
        if ([self.delegate respondsToSelector:@selector(queryGaoDePoiAroundSearchFailed:failedData:)]) {
            [self.delegate queryGaoDePoiAroundSearchFailed:self failedData:error];
        }
        return;
    }
    
    if ([request isKindOfClass:[AMapPOIKeywordsSearchRequest class]]) {
        if ([self.delegate respondsToSelector:@selector(queryGaoDePoiKeywordsSearchFailed:failedData:)]) {
            [self.delegate queryGaoDePoiKeywordsSearchFailed:self failedData:error];
        }
        return;
    }
}

@end
//=================================================================================================================================


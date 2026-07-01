//
//  WinBaiduMap.m
//  WinSFA
//
//  Created by yuanji on 2020/5/26.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import "WinBaiduMap.h"
#import "Masonry.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "WinBaiduCurrentPointAnnotation.h"
#import "WinBaiduCurrentPointAnnotationView.h"
#import "WinBaiduStorePointAnnotation.h"
#import "WinBaiduStorePointAnnotationView.h"

static NSString *baiduCurrentPointAnnotationViewIdentifier = @"win.baiduCurrentPointAnnotationViewIdentifier";  //百度当前点视图标识
static NSString *baiduStorePointAnnotationViewIdentifier = @"win.baiduStorePointAnnotationViewIdentifier";      //百度门店点视图标识
//================================================================================================================================================================================================

#pragma mark - 百度地图 延展(内部)
@interface WinBaiduMap ()

@property (nonatomic, strong) BMKMapView *mapView;                                      //地图视图
@property (nonatomic, strong) WinBaiduCurrentPointAnnotation *currentPointAnnotation;   //当前点注释
@property (nonatomic, strong) WinBaiduStorePointAnnotation *storePointAnnotation;       //门店点注释

@end
//================================================================================================================================================================================================

#pragma mark - 百度地图 延展(工具)
@interface WinBaiduMap (Tools)

- (void)createSubView; //创造子视图方法
- (void)addConstraints;//添加约束方法

@end
//================================================================================================================================================================================================

#pragma mark - 百度地图 延展(实现BMKMapViewDelegate代理协议)
@interface WinBaiduMap (bmkMapViewDelegate) <BMKMapViewDelegate>

@end
//================================================================================================================================================================================================

#pragma mark - 百度地图
@implementation WinBaiduMap

#pragma mark - 获取mapView方法
- (BMKMapView *)mapView {
    
    if (!_mapView) {
        
        _mapView = [[BMKMapView alloc] init];
        [_mapView setZoomLevel:17];
        _mapView.delegate = self;
    }
    return _mapView;
}

#pragma mark - 重写initWithFrame:方法
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self createSubView];
        [self addConstraints];
    }
    return self;
}

#pragma mark - 重写dealloc方法
- (void)dealloc {
    
    _mapView.delegate = nil;
    _mapView = nil;
}

#pragma mark - 重写addCurrentPointAnnotationWithCoordinate:添加当前点位置方法
- (void)addCurrentPointAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate {
    
    [self.mapView removeAnnotation:self.currentPointAnnotation];
    self.currentPointAnnotation = nil;
    
    self.currentPointAnnotation = [[WinBaiduCurrentPointAnnotation alloc] init];
    self.currentPointAnnotation.coordinate = coordinate;
    self.currentPointAnnotation.title = NSLocalizedString(@"map_current", nil);
    self.currentPointAnnotation.subtitle = [NSString stringWithFormat:@"%.8f, %.8f", coordinate.latitude, coordinate.longitude];
    
    [self.mapView addAnnotation:self.currentPointAnnotation];
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.mapView showAnnotations:@[self.currentPointAnnotation] animated:NO];
    });
}

#pragma mark - 添加门店点位置方法
- (void)addStoreAnotationWithCoordinate:(CLLocationCoordinate2D)coordinate withStoreBean:(WSStoreBean *)aStore {
    
    [self.mapView removeAnnotation:self.storePointAnnotation];
    self.storePointAnnotation = nil;
    
    self.storePointAnnotation = [[WinBaiduStorePointAnnotation alloc] init];
    self.storePointAnnotation.coordinate = coordinate;
    self.storePointAnnotation.title = aStore.name;
    if (aStore.addr.length > 0) {
        self.storePointAnnotation.subtitle = [NSString stringWithFormat:@"%@", aStore.addr];
    }
    else {
        self.storePointAnnotation.subtitle = [NSString stringWithFormat:@"%.8f, %.8f", coordinate.latitude, coordinate.longitude];
    }
    
    [self.mapView addAnnotation:self.storePointAnnotation];
}

@end
//================================================================================================================================================================================================

#pragma mark - 百度地图 延展(工具)
@implementation WinBaiduMap (Tools)

#pragma mark - 创造子视图方法
- (void)createSubView {
    
    [self addSubview:self.mapView];
}

#pragma mark - 添加约束方法
- (void)addConstraints {
    
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f));
    }];
}

@end
//================================================================================================================================================================================================

#pragma mark - 百度地图 延展(实现BMKMapViewDelegate代理协议)
@implementation WinBaiduMap (bmkMapViewDelegate)

#pragma mark - 实现mapView:viewForAnnotation:协议
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[WinBaiduCurrentPointAnnotation class]]) {
        
        WinBaiduCurrentPointAnnotationView *annotationView = (WinBaiduCurrentPointAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:baiduCurrentPointAnnotationViewIdentifier];
        if (!annotationView) {
            
            annotationView = [[WinBaiduCurrentPointAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:baiduCurrentPointAnnotationViewIdentifier];
            annotationView.centerOffset = CGPointMake(0, 0);
            annotationView.calloutOffset = CGPointMake(0, 0);
            annotationView.enabled3D = NO;
            annotationView.enabled = YES;
            annotationView.selected = YES;
            annotationView.canShowCallout = YES;
            annotationView.leftCalloutAccessoryView = nil;
            annotationView.rightCalloutAccessoryView = nil;
            annotationView.pinColor = BMKPinAnnotationColorRed;
            annotationView.animatesDrop = NO;
            annotationView.draggable = NO;
        }
        return annotationView;
    }
    
    if ([annotation isKindOfClass:[WinBaiduStorePointAnnotation class]]) {
        
        WinBaiduStorePointAnnotationView *annotationView = (WinBaiduStorePointAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:baiduStorePointAnnotationViewIdentifier];
        if (!annotationView) {
            
            annotationView = [[WinBaiduStorePointAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:baiduStorePointAnnotationViewIdentifier];
            annotationView.centerOffset = CGPointMake(0, 0);
            annotationView.calloutOffset = CGPointMake(0, 0);
            annotationView.enabled3D = NO;
            annotationView.enabled = YES;
            annotationView.selected = YES;
            annotationView.canShowCallout = YES;
            annotationView.leftCalloutAccessoryView = nil;
            annotationView.rightCalloutAccessoryView = nil;
            annotationView.animatesDrop = NO;
            annotationView.draggable = NO;
            annotationView.image = [UIImage imageForName:@"map_start"];
        }
        return annotationView;
    }
    
    return nil;
}

@end
//================================================================================================================================================================================================

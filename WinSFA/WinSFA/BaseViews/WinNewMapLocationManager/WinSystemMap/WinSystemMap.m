//
//  WinSystemMap.m
//  WinSFA
//
//  Created by yuanji on 2023/3/30.
//  Copyright © 2023 WinChannel. All rights reserved.
//

#import "WinSystemMap.h"
#import "Masonry.h"
#import "WinSystemCurrentPointAnnotation.h"
#import "WinSystemCurrentPointAnnotationView.h"
#import "WinSystemStorePointAnnotation.h"
#import "WinSystemStorePointAnnotationView.h"

static NSString *systemCurrentPointAnnotationViewIdentifier = @"win.systemCurrentPointAnnotationViewIdentifier";//系统当前点视图标识
static NSString *systemStorePointAnnotationViewIdentifier = @"win.systemStorePointAnnotationViewIdentifier";    //系统门店点视图标识
//================================================================================================================================================================================================

#pragma mark - 系统地图 延展(内部)
@interface WinSystemMap ()

@property (nonatomic, strong) MKMapView *mapView;                                       //地图视图
@property (nonatomic, strong) WinSystemCurrentPointAnnotation *currentPointAnnotation;  //当前点注释
@property (nonatomic, strong) WinSystemStorePointAnnotation *storePointAnnotation;      //门店点注释

@end
//================================================================================================================================================================================================

#pragma mark - 系统地图 延展(工具)
@interface WinSystemMap (Tools)

- (void)createSubView; //创造子视图方法
- (void)addConstraints;//添加约束方法

@end
//================================================================================================================================================================================================

#pragma mark - 系统地图 延展(实现MKMapViewDelegate代理协议)
@interface WinSystemMap (mkMapViewDelegate) <MKMapViewDelegate>

@end
//================================================================================================================================================================================================

#pragma mark - 系统地图
@implementation WinSystemMap

#pragma mark - 获取mapView方法
- (MKMapView *)mapView {
    
    if (!_mapView) {
        
        _mapView = [[MKMapView alloc] init];
        _mapView.showsUserLocation = NO;
        _mapView.rotateEnabled = NO;
        _mapView.pitchEnabled = NO;
        _mapView.showsBuildings = NO;
        _mapView.mapType = MKMapTypeStandard;
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
    
    self.currentPointAnnotation = [[WinSystemCurrentPointAnnotation alloc] init];
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
    
    self.storePointAnnotation = [[WinSystemStorePointAnnotation alloc] init];
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

#pragma mark - 系统地图 延展(工具)
@implementation WinSystemMap (Tools)

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

#pragma mark - 系统地图 延展(实现MKMapViewDelegate代理协议)
@implementation WinSystemMap (mkMapViewDelegate)

#pragma mark - 实现mapView:viewForAnnotation:协议
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[WinSystemCurrentPointAnnotation class]]) {
        
        WinSystemCurrentPointAnnotationView *annotationView = (WinSystemCurrentPointAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:systemCurrentPointAnnotationViewIdentifier];
        if (!annotationView) {
            
            annotationView = [[WinSystemCurrentPointAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:systemCurrentPointAnnotationViewIdentifier];
            annotationView.canShowCallout = YES;
            annotationView.centerOffset = CGPointMake(0, 0);
            annotationView.calloutOffset = CGPointMake(0, 0);
            annotationView.enabled = YES;
            annotationView.leftCalloutAccessoryView = nil;
            annotationView.rightCalloutAccessoryView = nil;
            annotationView.draggable = NO;
            annotationView.pinTintColor = [UIColor redColor];
        }
        return annotationView;
    }
    
    if ([annotation isKindOfClass:[WinSystemStorePointAnnotation class]]) {
        
        WinSystemStorePointAnnotationView *annotationView = (WinSystemStorePointAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:systemStorePointAnnotationViewIdentifier];
        if (!annotationView) {
            
            annotationView = [[WinSystemStorePointAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:systemStorePointAnnotationViewIdentifier];
            annotationView.canShowCallout = YES;
            annotationView.centerOffset = CGPointMake(0, 0);
            annotationView.calloutOffset = CGPointMake(0, 0);
            annotationView.enabled = YES;
            annotationView.leftCalloutAccessoryView = nil;
            annotationView.rightCalloutAccessoryView = nil;
            annotationView.draggable = NO;
            annotationView.image = [UIImage imageForName:@"map_start"];
        }
        return annotationView;
    }
    
    return nil;
}

@end
//================================================================================================================================================================================================

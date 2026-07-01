//
//  WinNewMapView.m
//  WinSFA
//
//  Created by yuanji on 2020/5/26.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import "WinNewMapView.h"
#import "WinMapBase.h"
#import "WinMapCreator.h"
#import "WSEnvrionment.h"
//================================================================================================================================================================================================

#pragma mark - 地图视图 延展(内部)
@interface WinNewMapView ()

@property (nonatomic, strong) WinMapBase *mapView;      //地图视图
@property (nonatomic, strong) UIView *bottomView;       //底部视图
@property (nonatomic, strong) UIButton *refreshButton;  //刷新按键
@property (nonatomic, strong) UILabel *locationLabel;   //位置标签

- (void)refreshButtonClick:(id)sender; //刷新按键响应方法

@end
//================================================================================================================================================================================================

#pragma mark - 地图视图 延展(工具)
@interface WinNewMapView (Tools)

- (void)createSubView; //创造子视图方法
- (void)addConstraints;//添加约束方法

@end
//================================================================================================================================================================================================

#pragma mark - 地图视图
@implementation WinNewMapView

#pragma mark - 获取mapView方法
- (WinMapBase *)mapView {
    
    if (!_mapView) {
        
        if ([WSEnvrionment getUseBaiduMap]) {
            _mapView = [WinMapCreator mapCreatorWithMapType:WinMapCreatorTypeBaidu];
        }
        else {
            _mapView = [WinMapCreator mapCreatorWithMapType:WinMapCreatorTypeOther];
        }
    }
    return _mapView;
}

#pragma mark - 获取bottomView方法
- (UIView *)bottomView {
    
    if (!_bottomView) {
        
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor colorWithRed:220.0/255 green:220.0/255 blue:220.0/255 alpha:0.6f];
    }
    return _bottomView;
}

#pragma mark - 获取refreshButton方法
- (UIButton *)refreshButton {
    
    if (!_refreshButton) {
        
        _refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _refreshButton.backgroundColor = [UIColor clearColor];
        [_refreshButton addTarget:self action:@selector(refreshButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_refreshButton setImage:[UIImage imageForName:@"refreshLocation"] forState:UIControlStateNormal];
        [_refreshButton setImage:[UIImage imageForName:@"refreshLocation_pressed"] forState:UIControlStateHighlighted];
    }
    return _refreshButton;
}

#pragma mark - 获取locationLabel方法
- (UILabel *)locationLabel {
    
    if (!_locationLabel) {
        
        _locationLabel = [[UILabel alloc] init];
        _locationLabel.backgroundColor = [UIColor clearColor];
        _locationLabel.textAlignment = NSTextAlignmentLeft;
        _locationLabel.numberOfLines = 0;
        _locationLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _locationLabel.font = [UIFont systemFontOfSize:12.0f];
    }
    return _locationLabel;
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

#pragma mark - 自定义初始化方法
- (id)initWithFrame:(CGRect)mapViewRect storeCoordinate:(CLLocationCoordinate2D)coordinate storeId:(NSString *)storeId
          storeName:(NSString *)storeName isCenterForStoreLocation:(BOOL)isCenterForStore isShowAddress:(BOOL)isShowAddress
       locationType:(NSString *)locationType isDropFullScreen:(BOOL)isDropFullScreen {
    
    self = [super initWithFrame:mapViewRect];
    if (self) {
        
        [self createSubView];
        [self addConstraints];
    }
    return self;
}

#pragma mark - 设置地址方法
- (void)setAddress:(NSString *)address {
    
    self.locationLabel.text = address;
}

#pragma mark - 添加当前点注释方法
- (void)addCurrentPointAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate {
    
    [self.mapView addCurrentPointAnnotationWithCoordinate:coordinate];
}

#pragma mark - 添加门店方法
- (void)addStoreAnotationWithCoordinate:(CLLocationCoordinate2D)coordinate withStoreBean:(WSStoreBean *)aStore {
    
    [self.mapView addStoreAnotationWithCoordinate:coordinate withStoreBean:aStore];
}

#pragma mark - 刷新按键响应方法
- (void)refreshButtonClick:(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapViewRefreshButtonClick:)]) {
        [self.delegate mapViewRefreshButtonClick:self];
    }
}

@end
//================================================================================================================================================================================================

#pragma mark - 地图视图 延展(工具)
@implementation WinNewMapView (Tools)

#pragma mark - 创造子视图方法
- (void)createSubView {
    
    [self addSubview:self.mapView];
    [self addSubview:self.bottomView];
    [self addSubview:self.refreshButton];
    [self addSubview:self.locationLabel];
}

#pragma mark - 添加约束方法
- (void)addConstraints {
    
    __weak __typeof(&*self)weakSelf = self;
    
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(weakSelf).with.insets(UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f));
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.bottom.equalTo(weakSelf).insets(UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f));
        make.height.mas_equalTo(40);
    }];
    
    [self.refreshButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(weakSelf.bottomView);
        make.left.equalTo(weakSelf).mas_offset(0.0f);
        make.height.equalTo(weakSelf.bottomView);
        make.width.mas_equalTo(40);
    }];
    
    [self.locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(weakSelf.bottomView);
        make.left.equalTo(weakSelf.refreshButton.mas_right).mas_offset(0.0f);
        make.right.equalTo(weakSelf).mas_offset(-10.0f);
        make.height.equalTo(weakSelf.bottomView);
    }];
}

@end
//================================================================================================================================================================================================

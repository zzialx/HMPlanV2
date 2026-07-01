//
//  WSPljygonModel.h
//  WinSFA
//
//  Created by mac on 2018/3/2.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

//#import <MapKit/MapKit.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface WSPljygonModel : BMKPolygon
@property (nonatomic , strong) UIColor *fillColor;
@property (nonatomic , strong) UIColor *strokeColor;
@property (nonatomic , assign) CGFloat lineWidth;

@end

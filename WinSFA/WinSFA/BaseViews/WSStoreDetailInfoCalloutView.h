//
//  WSStoreDetailInfoCalloutView.h
//  WinSFA
//
//  Created by mac on 2017/10/24.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface WSStoreDetailInfoCalloutView : BMKAnnotationView
@property (nonatomic,strong) WSStoreAnnotation *calloutAnnotaion;

@end

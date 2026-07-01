//
//  WSCalloutAnnotationView.h
//  WinSFA
//
//  Created by heju on 16/5/12.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "WSStoreAnnotation.h"

@interface WSCalloutAnnotationView : BMKAnnotationView

@property (nonatomic,strong) WSStoreAnnotation *calloutAnnotaion;


@end

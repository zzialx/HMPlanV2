//
//  WSStoreAnnotationWithNameView.h
//  WinSFA
//
//  Created by HZH on 2017/9/28.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "WSStoreAnnotation.h"

@interface WSStoreAnnotationWithNameView : BMKAnnotationView

@property (nonatomic , strong) WSStoreAnnotation * storeAnnotation;

@end

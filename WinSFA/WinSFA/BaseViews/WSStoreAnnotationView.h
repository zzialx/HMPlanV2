//
//  WSStoreAnnotationView.h
//  WinSFA
//
//  Created by heju on 16/8/28.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "WSStoreAnnotation.h"

@interface WSStoreAnnotationView : BMKAnnotationView

@property (nonatomic , strong) WSStoreAnnotation * storeAnnotation;

-(void)setAnnotatinViewImage:(UIImage *)image;

@end

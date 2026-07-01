//
//  WSBaseAnnotation.h
//  WinSFA
//
//  Created by heju on 14/12/16.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoordinateTransform/CoordinateTransform.h>
#import <MapKit/MapKit.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface WSBaseAnnotation : NSObject<BMKAnnotation>

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

@property (nonatomic, readwrite) CLLocationCoordinate2D wgs84Coordinate;

@property (nonatomic,copy,readonly) NSString * title;

@property (nonatomic,copy,readonly) NSString * subtitle;

-(id)initWithWgs84:(CLLocationCoordinate2D)wgs84Coordinate title:(NSString *)title;

@end

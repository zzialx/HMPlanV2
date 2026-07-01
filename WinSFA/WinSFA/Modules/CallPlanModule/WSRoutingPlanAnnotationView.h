//
//  WSRoutingPlanAnnotationView.h
//  WinSFA
//
//  Created by zhiqing on 16/8/25.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface WSRoutingPlanAnnotationView : BMKAnnotationView
@property(nonatomic,strong)UILabel * label;
@end

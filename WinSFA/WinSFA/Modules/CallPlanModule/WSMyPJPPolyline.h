//
//  WSMyPJPPolyline.h
//  WinSFA
//
//  Created by zhiqing on 16/8/25.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>

typedef NS_ENUM(NSInteger, UIRoutingPlanLineType) {
    
    UIRoutingPlanLineTypeActuallyStd,       //标准实际路线
    UIRoutingPlanLineTypeInplanStd,         //标准计划路线
    UIRoutingPlanLineTypeActuallyUNC,       //联合利华实际路线
    UIRoutingPlanLineTypeInplanUNC,         //联合利华计划路线
    
    UIRoutingPlanLineTypeNewStandardPlan,   //新的标准计划
    UIRoutingPlanLineTypeNewInPlan,         //新的内计划
    UIRoutingPlanLineTypeNewActuallyPlan    //新的实际计划
};

@interface WSMyPJPPolyline : BMKPolyline

@property (nonatomic, assign) UIRoutingPlanLineType type;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) BOOL isSelected;

@end

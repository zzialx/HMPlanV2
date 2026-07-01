//
//  MKMapView+Addtions.m
//  WinSFA
//
//  Created by heju on 14/12/16.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "MKMapView+Addtions.h"
#import "WSBaseAnnotation.h"

@implementation MKMapView(Additions)

-(void)zoomToFitMapAnnotations
{
    NSMutableArray *validAnnotations = [NSMutableArray array];

    for(WSBaseAnnotation *annotation in self.annotations){
        if (CLLocationCoordinate2DIsValid(annotation.coordinate)) {
            [validAnnotations addObject:annotation];
        }else {
            LogError(@"坐标不合法：title:%@, latitude:%f, longitude:%f", annotation.title, annotation.coordinate.latitude, annotation.coordinate.longitude);
        }
    }
    
    if([validAnnotations count] == 0)
        return;
    if([validAnnotations count] == 1){
        
        MKCoordinateRegion region;
        WSBaseAnnotation *annotation = [validAnnotations objectAtIndex:0];
        region.span = MKCoordinateSpanMake(0.003, 0.003);
        region.center =  annotation.coordinate;
        
        [self setRegion:region animated:NO];
        
        return;

    }
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(WSBaseAnnotation* annotation in validAnnotations)
    {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.2; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.2; // Add a little extra space on the sides
    
    if (CLLocationCoordinate2DIsValid(region.center)) {
        region = [self regionThatFits:region];
        //YIHAIKERRY-4810
        if(region.center.latitude > -90 && region.center.latitude < 90 && region.center.latitude != 0 && region.center.longitude >-180  && region.center.longitude < 180  && region.center.longitude != 0) {
            [self setRegion:region animated:NO];
        } else {
            LogInfo(@"经纬度异常: latitude = %lf  longitude = %lf",region.center.latitude,region.center.longitude);
        }
    }
    
}


@end

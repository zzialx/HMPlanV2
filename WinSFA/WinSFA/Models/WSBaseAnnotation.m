//
//  WSBaseAnnotation.m
//  WinSFA
//
//  Created by heju on 14/12/16.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSBaseAnnotation.h"

@implementation WSBaseAnnotation
-(id)initWithWgs84:(CLLocationCoordinate2D)wgs84Coordinate title:(NSString *)title
{
    self = [super init];
    if(self != nil)
    {
        //CLLocationCoordinate2D gcj02Coordinate = [CoordinateTransform transCoordinate:wgs84Coordinate from:@"wgs84" to:@"gcj02"];
        //CLLocationCoordinate2D actualStoreCoordinate = [WSLocationManager getActualCoordinateWithWgs84:wgs84Coordinate];
        //_coordinate = actualStoreCoordinate;
        //_wgs84Coordinate = wgs84Coordinate;
        //_title = [title copy];
    }
    return self;
}
-(NSString *)subtitle{
    return [NSString stringWithFormat:@"%.12f,%.12f",self.wgs84Coordinate.latitude,self.wgs84Coordinate.longitude];
}
-(NSString *)description{
    return [NSString stringWithFormat:@"%@-->{coordinate:{latitude=%12f,longitude=%12f},title:%@,subtitle:%@",
            [self className],
            self.coordinate.latitude,
            self.coordinate.longitude,
            self.title,
            self.subtitle];
}


@end

//
//  WSNeighborPin.h
//  WinSFA
//
//  Created by Nemo on 14-3-21.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface WSNeighborPin : NSObject<MKAnnotation>


@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;

- (id)initWithCoordinate2D:(CLLocationCoordinate2D)dinate
                    tittle:(NSString*)title
                    subtitle:(NSString*)subtitle;

@end

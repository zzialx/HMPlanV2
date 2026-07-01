//
//  CoordinateTransform.h
//  CoordinateTransform
//
//  Created by sam wang on 14/11/24.
//  Copyright (c) 2014年 Appfanr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CoordinateTransform : NSObject

+(CLLocationCoordinate2D)transCoordinate:(CLLocationCoordinate2D)coordinate
                                    from:(NSString *)fromCode
                                      to:(NSString *)toCode;

@end

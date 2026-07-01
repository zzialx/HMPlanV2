//
//  WCBasicAnnotation.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 5/10/13.
//
//

#import "WSBasicAnnotation.h"

@implementation WSBasicAnnotation

@synthesize coordinate = _coordinate;
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize pinAnnotationColor = _pinAnnotationColor;
@synthesize annotationType = _annotationType;

- (id)init
{
    self = [super init];
    return self;
}


- (void)setTitle:(NSString *)aTitle
{
    if (aTitle != _title && [aTitle isKindOfClass:[NSString class]]) {
        _title = [aTitle copy];
    }
}

- (void)setSubtitle:(NSString *)aSubtitle
{
    if (aSubtitle != _subtitle && [aSubtitle isKindOfClass:[NSString class]]) {
        _subtitle = [aSubtitle copy];
    }
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    _coordinate = CLLocationCoordinate2DMake(newCoordinate.latitude, newCoordinate.longitude);
}

@end

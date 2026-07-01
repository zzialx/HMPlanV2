//
//  WCBasicAnnotation.h
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 5/10/13.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

enum {
    WCMKAnnotationPinType = 0,
    WCMKAnnotationCallOutType,
    WCMKUserLocationType
};
typedef NSUInteger WCMKAnnotationType;


@interface WSBasicAnnotation : NSObject<MKAnnotation>

@property (nonatomic, assign)MKPinAnnotationColor pinAnnotationColor;
@property (nonatomic, assign)WCMKAnnotationType annotationType;

- (id)init;
- (void)setTitle:(NSString *)aTitle; //Store name
- (void)setSubtitle:(NSString *)aSubtitle; // Store address
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate; // Store GPS
@end

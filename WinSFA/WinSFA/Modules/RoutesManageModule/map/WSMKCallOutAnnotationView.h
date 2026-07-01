//
//  WCMKCallOutAnnotationView.h
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 5/10/13.
//
//

#import <MapKit/MapKit.h>

@interface WSMKCallOutAnnotationView : MKAnnotationView

@property (nonatomic, strong) UIView *iContentView;

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;

@end

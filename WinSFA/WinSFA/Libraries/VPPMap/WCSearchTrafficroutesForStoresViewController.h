//
//  WCSearchTrafficroutesForStoresViewController.h
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 5/7/13.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MKAnnotation.h>
#import "WSFuncsBean.h"

@interface WCSearchTrafficroutesForStoresViewController : UIViewController
@property (retain, nonatomic) IBOutlet UILabel *iSearchTypeLabel;
@property (retain, nonatomic) IBOutlet UILabel *iStartPositionTitlelabel;
@property (retain, nonatomic) IBOutlet UILabel *iEndPositionTitleLabel;
- (IBAction)clickForSearchRoutes:(id)sender;

- (void)setWithFunction:(WSFuncsBean *)aBean andAllAnnotations:(NSArray *)aAnnotations andTapAnnotation:(id<MKAnnotation>)aMapAnnotaion andCurrentLocation:(id<MKAnnotation>)aCurrentLocation;

@end

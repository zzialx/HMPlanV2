//
//  LBSViewController.h
//  TestLBS
//
//  Created by winchannel on 12-2-9.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import "WSFuncsBean.h"
#import "WCBaseViewController.h"
#import "WSLocationManager.h"
#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed : 0.20392f green : 0.19607f blue : 0.61176f alpha : 1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[[UIBarButtonItem alloc] initWithTitle : TITLE style : UIBarButtonItemStylePlain target : self action : SELECTOR] autorelease]

@interface WSLBSViewController : WCBaseViewController <CLLocationManagerDelegate, UIAlertViewDelegate>{
    NSMutableString     *log;
    IBOutlet UITextView *textView;
    CLLocationManager   *locManager;
}
@property (strong, nonatomic) NSMutableString           *log;
@property (strong, nonatomic) CLLocationManager         *locManager;
@property (strong, nonatomic) WSFuncsBean                 *m_currentFuncs;
@property (strong, nonatomic) IBOutlet UITextField      *m_TextField;
@property (assign, nonatomic) CLLocationCoordinate2D    m_location;
@property (strong, nonatomic) CLLocation                *currentLocation;
@property (nonatomic, assign) BOOL iGpsReady; // GPS is 

- (id)initWithFuncs:(WSFuncsBean *)funcs;
- (IBAction)upLoadGPS;

@end

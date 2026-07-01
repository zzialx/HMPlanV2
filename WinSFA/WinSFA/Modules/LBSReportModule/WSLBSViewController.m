//
//  LBSViewController.m
//  TestLBS
//
//  Created by winchannel on 12-2-9.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSLBSViewController.h"
#import "WSRequestHelper.h"
#define UPLOADGPS           @"uploadGPS"

@implementation WSLBSViewController
@synthesize log;
@synthesize locManager;
@synthesize m_currentFuncs = _m_currentFuncs;
@synthesize m_TextField = _m_TextField;
@synthesize m_location = _m_location;
@synthesize iGpsReady = _iGpsReady;


-(void)uploadFinished:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UPLOADGPS 
                                                  object:nil];
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0) {
         NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }else{
        NSString *tmpString = NSLocalizedString(@"upload_success",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        //更新完成后对userdefault重新处理
    }
    
}

-(IBAction)upLoadGPS
{
    if (!self.iGpsReady) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(uploadFinished:)
                                                 name:UPLOADGPS 
                                               object:nil];
    
//    WSRequestHelper* l_upload = [WSRequestHelper shareInstance];
//    
//    LogInfo(@"UPLOAD PASSIVE LOCATION");
//    [l_upload uploadBackGroundGPSWithLocation:self.currentLocation NotifyName:UPLOADGPS];
//    
//    NSString *tmpString = NSLocalizedString(@"update_data_tip",nil);
//    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:self action:nil];

}
- (void) doLog: (NSString *) formatstring, ...
{
	va_list arglist;
	if (!formatstring) return;
	va_start(arglist, formatstring);
	NSString *outstring = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
	va_end(arglist);
	[self.log appendString:outstring];
	[self.log appendString:@"\n"];
	textView.text = self.log;
}

-(void)dealFuncsAttribute
{
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithFuncs:(WSFuncsBean*)funcs;
{
    if(funcs == nil)
        return nil;
    self.m_currentFuncs = funcs;
    return [self initWithNibName:@"WSLBSViewController" bundle:nil];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.log = [NSMutableString string];
    NSString *tmpString = NSLocalizedString(@"开始定位:",nil);
	[self doLog:tmpString];
	
	self.locManager = [[CLLocationManager alloc] init];
	if (![CLLocationManager locationServicesEnabled])
	{
        NSString *tmpString = NSLocalizedString(@"定位功能没有打开",nil);
        NSString *cancelString = NSLocalizedString(@"cancel_label",nil);
        NSString *OpenString = NSLocalizedString(@"打开",nil);
        
        BlockAlertView *alertView = [BlockAlertView alertWithTitle:tmpString message:nil];
        [alertView setCancelButtonWithTitle:cancelString block:^{
            NSString *NOPositionString = NSLocalizedString(@"NOPosition:%@",nil);
            [self doLog:@"%@\n", NOPositionString];
        }];
        [alertView addButtonWithTitle:OpenString block:^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]];
            
        	self.locManager.delegate = self;
            self.locManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.locManager.distanceFilter = 5.0f; // in meters
            [self startLocation];
        }];
        [alertView show];
        return;
	}
	
	self.locManager.delegate = self;
	self.locManager.desiredAccuracy = kCLLocationAccuracyBest;
    
	self.locManager.distanceFilter = 5.0f; // in meters
	[self startLocation];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LBSManagerDidUpdatedLocationFinishedNotification object:nil];
}
#pragma locationdelegate
-(void)startLocation
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocationFinished:) name:LBSManagerDidUpdatedLocationFinishedNotification object:nil];
    [[WSLocationManager getInstance] startUpdatingLocationWithActive:NO];
}

- (void)updateLocationFinished:(NSNotification *)sender
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LBSManagerDidUpdatedLocationFinishedNotification object:nil];
    
    NSDictionary *userInfo = [sender userInfo];
    
    NSError *error = [userInfo objectForKey:LBSManagerDidUpdatedLocationFinishedErrorKey];
    CLLocation *location = [userInfo objectForKey:LBSManagerDidUpdatedLocationFinishedLocationKey];
    
    if (error)
    {
        self.iGpsReady = NO;
    }else{
        self.iGpsReady = YES;
    }
    
    self.currentLocation = location;
    self.m_location = location.coordinate;
}

#pragma alert
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            NSString *NOPositionString = NSLocalizedString(@"NOPosition:%@",nil);
        [self doLog:@"%@\n", NOPositionString];
        }
            break;
        case 1:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]];  
            
        	self.locManager.delegate = self;
            self.locManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.locManager.distanceFilter = 5.0f; // in meters
            [self startLocation];
        }
            break;
        default:
            break;
    }
}
@end

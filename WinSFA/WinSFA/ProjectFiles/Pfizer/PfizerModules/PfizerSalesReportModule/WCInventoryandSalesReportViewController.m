//
//  WCInventoryandSalesReportViewController.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 7/8/13.
//
//

#import "WCInventoryandSalesReportViewController.h"
#import "WCSubInventoryandSalesReportViewController.h"

@interface WCInventoryandSalesReportViewController ()

@end

@implementation WCInventoryandSalesReportViewController
@synthesize currentFuncs = _currentFuncs;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithFuncs:(WSFuncsBean *)funcs
{
    self = [super init];
    if (self) {
        self.currentFuncs = funcs;
        self.title = funcs.name;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
#endif
    
    WSFuncsBean *fb = nil;
    if ([self.currentFuncs.funcsArray count] > 0) {
        fb = [self.currentFuncs.funcsArray objectAtIndex:0];
    }
    
    WCSubInventoryandSalesReportViewController *vc = [[WCSubInventoryandSalesReportViewController alloc] initWithFuncs:fb];
    vc.ownParentViewController = self;
    [self addChildViewController:vc];
    vc.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    vc.view.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:vc.view];
}


//[super loadView];
//UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 372+44)];
//self.mainView = view;
//[view release];
//[self.view addSubview:self.mainView];
//
//FuncsBean* fb = nil;
//if([self.currentFuncs.funcsArray count]>0)
//fb = [self.currentFuncs.funcsArray objectAtIndex:0];
//
//SubAgentViewController* vc = [[[SubAgentViewController alloc]initWithFuncs:fb] autorelease];
//
//
//vc.view.frame = [[ConfigFileController sharedInstanceMethod] getCGRectFromString:@"PartOfViewFrame"];
////    vc.view.frame = CGRectMake(0, 0, 320, 480);
//vc.ownParentViewController = self;
//[self.mainView addSubview:vc.view];
//self.swpvc = vc;





- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

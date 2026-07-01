//
//  WSPfizerSpecialAcvtViewController.m
//  Pfizer
//
//  Created by yang on 13-11-11.
//  Copyright (c) 2013年 Winchannel. All rights reserved.
//

#import "WSPfizerSpecialAcvtViewController.h"
#import "WSPfizerAcvtListViewController.h"
#import "WSAppData.h"
#import "WSAcvtViewController.h"
#import "WSBaseAcvtDBService.h"

@interface WSPfizerSpecialAcvtViewController ()

@property (nonatomic, strong)WSPfizerAcvtListViewController *m_acvtListViewController;

@end

@implementation WSPfizerSpecialAcvtViewController

@synthesize m_acvtListViewController = _m_acvtListViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor whiteColor];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
#endif
    
    WSFuncsBean *funbean = self.currentFuncs;
    if (funbean == nil && funbean.filter == nil)
        return;
    
    
    WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];
    NSArray *l_acvtFilters = [baseAcvtDBService queryAcvtsWithStoreId:self.currentStore.Id filter:funbean.filter];
    
    if([l_acvtFilters count] == 1 && (funbean.isAcvtList != nil && [funbean.isAcvtList isEqualToString:@"1"]))
    {
        [self.m_AcvtViewController removeFromParentViewController];
        self.m_AcvtViewController = nil;
        
        WSAcvtBean* i_CurrentAcvtBean = [l_acvtFilters objectAtIndex:0];
        WSAcvtViewController* i_AcvtViewController = [[WSAcvtViewController alloc]initWithAcvt:i_CurrentAcvtBean Funcs:funbean Store:nil];
        self.m_AcvtViewController = i_AcvtViewController;
        [self addChildViewController:self.m_AcvtViewController];
        i_AcvtViewController.m_ParentViewController = self.ownParentViewController;
        //        self.m_AcvtViewController = i_AcvtViewController;
        [self.view addSubview:self.m_AcvtViewController.view];
    }else if( [l_acvtFilters count] >= 1){
        [self.m_acvtListViewController removeFromParentViewController];
        self.m_acvtListViewController = nil;
        WSPfizerAcvtListViewController *acvtList = [[WSPfizerAcvtListViewController alloc] initWithFuncs:funbean];
        [acvtList setShowActionTip:YES];
        self.m_acvtListViewController = acvtList;
        acvtList.m_ParentViewController = self.ownParentViewController;
        acvtList = nil;
        [self addChildViewController:self.m_acvtListViewController];
        [self.view addSubview:self.m_acvtListViewController.view];
        self.m_acvtListViewController.view.frame = CGRectMake(self.m_acvtListViewController.view.frame.origin.x, self.m_acvtListViewController.view.frame.origin.y - 20, self.m_acvtListViewController.view.frame.size.width, self.m_acvtListViewController.view.frame.size.height);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

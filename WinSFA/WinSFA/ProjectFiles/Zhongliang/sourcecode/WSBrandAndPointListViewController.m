//
//  WSBrandAndPointListViewController.m
//  Zhongliang
//
//  Created by xiaotang.wang on 9/6/13.
//  Copyright (c) 2013 Winchannel. All rights reserved.
//

#import "WSBrandAndPointListViewController.h"
#import "WSAcvtBean.h"
#import "WSPointInfo.h"
#import "WSSpecialAuditViewController.h"
#define kRowHeight 44

@interface WSBrandAndPointListViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)NSArray *iEntityArray;
@property (nonatomic, strong)WSFuncsBean *iCurrentFuncs;
@property (nonatomic, strong)UITableView *iTableView;

@end

@implementation WSBrandAndPointListViewController
@synthesize iEntityArray = _iEntityArray;
@synthesize iCurrentFuncs = _iCurrentFuncs;
@synthesize iTableView = _iTableView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (id)initWithFuns:(WSFuncsBean *)aFuncsBean withArray:(NSArray *)aArray
{
    if (aFuncsBean == nil || aArray == nil) {
        return nil;
    }
    
    self = [super init];
    if (self != nil) {
        _iCurrentFuncs = aFuncsBean;
        _iEntityArray = aArray;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor redColor];
    
    self.view.backgroundColor = [UIColor whiteColor];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
#endif

    
    CGRect rect = [[UIScreen mainScreen] applicationFrame];
    NSLog(@"%@", NSStringFromCGRect(rect));
    UITableView *tb;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] <7.0) {
        tb = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height) style:UITableViewStyleGrouped];
    } else {
        CGFloat tableHeight;
        if ([self.iEntityArray count]*kRowHeight < rect.size.height) {
            tableHeight = [self.iEntityArray count]*kRowHeight;
        } else {
            tableHeight = rect.size.height;
        }
        tb = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width,[self.iEntityArray count]*kRowHeight) style:UITableViewStylePlain];
    }
    
    tb.backgroundColor = [UIColor clearColor];
    tb.backgroundView = nil;
    tb.dataSource = self;
    tb.delegate = self;
    _iTableView = tb;
    [self.view addSubview:tb];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] <7.0) {
        self.iTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    } else {
        CGFloat tableHeight;
        if ([self.iEntityArray count]*kRowHeight < self.view.frame.size.height) {
            tableHeight = [self.iEntityArray count]*kRowHeight;
        } else {
            tableHeight = self.view.frame.size.height;
        }
        self.iTableView.frame  = CGRectMake(0, 0,self.view.frame.size.width,tableHeight);
    }
    
    
    NSLog(@"%@", NSStringFromCGRect(self.view.frame));
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





#pragma mark - UITableView delegate and datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.iEntityArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kTbIdentify = @"wspointinfolist";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTbIdentify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTbIdentify];
    }
    
    WSPointInfo *info = [self.iEntityArray objectAtIndex:indexPath.row];
    if (info != nil) {
        cell.textLabel.text = info.iPointName;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *vc = nil;
    WSPointInfo *info = [self.iEntityArray objectAtIndex:indexPath.row];
    if (info.iPointInfoArray != nil) {
        vc = [[WSBrandAndPointListViewController alloc] initWithFuns:self.iCurrentFuncs withArray:info.iPointInfoArray];
        vc.title = info.iPointName;
    }else{
        vc = [[WSSpecialAuditViewController alloc] initWithFuncs:self.iCurrentFuncs withPointInfo:info];
    }
    [self.navigationController pushViewController:vc animated:YES];
}






@end

//
//  InfoProdViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-14.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSInfoProdViewController.h"
#import "WSDictBeanArray.h"
#import "WSBaseDictsDBService.h"
#import "WSDictBrand.h"
#import "WSProdListViewController.h"
//#import "ConfigFileController.h"
#import "WCOptionalSource.h"
#import "WSPlistHelper.h"

@implementation WSInfoProdViewController
@synthesize currentFuncs = _currentFuncs;
@synthesize dictBrandsArray = _dictBrandsArray;


-(void)dealWithds{
    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
    NSArray* dictBeanArray = [service queryProdsBrandByFilter:self.currentFuncs.filter];
    self.dictBrandsArray = [dictBeanArray mutableCopy];
}


-(id)initWithFuncs:(WSFuncsBean*)funcs
{
    if(funcs==nil)
        return nil;
    
    self = [super init];
    if(self != nil)
    {
        self.currentFuncs = funcs;
        [self dealWithds];
        return self;
    }
    return nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - View lifecycle


- (void)loadView
{
    [super loadView];
    UITableView* tv = nil;
    CGRect tableRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    if (IOS7_OR_LATER) {
        tv = [[UITableView alloc]initWithFrame:tableRect style:UITableViewStylePlain];
    }else {
        tv = [[UITableView alloc]initWithFrame:tableRect style:UITableViewStyleGrouped];
    }
    tv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tv.backgroundColor = [UIColor whiteColor];
    tv.backgroundView = nil;
    tv.delegate = self;
    tv.dataSource = self;
    tv.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:tv];
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self navBarClearLeftBarButtonItems];
    [self addBackBarButtonItem];
}

- (void)navBarClearLeftBarButtonItems {
    [self getNavigationItem].leftBarButtonItems = nil;
}

- (void)addBackBarButtonItem {
    NSMutableArray *barButtonItems = [NSMutableArray arrayWithArray:[self getNavigationItem].leftBarButtonItems] ;
    
    if ([self navigationController].viewControllers.count <= 1) {
    } else{
        UIBarButtonItem *backBBI = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
        [barButtonItems addObject:backBBI];
        
        [self getNavigationItem].leftBarButtonItems = barButtonItems;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  [self.dictBrandsArray count];
     
}

//绘制Cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             SimpleTableIdentifier];
    if (cell == nil) {  
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier: SimpleTableIdentifier];
    }
    
    WSDictBrand* db = [self.dictBrandsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = db.dictBean.name;
     
    return cell;
}

//选中Cell响应事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    
    WSDictBrand* db = [self.dictBrandsArray objectAtIndex:indexPath.row];
    //NSLog(@"sub count is %d",[db.subDictBrandsArray count]);
    WSProdListViewController* lvc ;
    if(db.subDictBrandsArray != nil&& [db.subDictBrandsArray count]> 0)
    {
        lvc = [[WSProdListViewController alloc]initWithArray:db.subDictBrandsArray];
        [[WCOptionalSource sharedInstance] setViewControllerParam:lvc byKey:self.currentFuncs.fv];
    }
    else
    {
        //NSLog(@"---%d",[db.prodArray count]);
        lvc = [[WSProdListViewController alloc]initWithArray:db.prodArray];
        [[WCOptionalSource sharedInstance] setViewControllerParam:lvc byKey:self.currentFuncs.fv];
    }
    
    lvc.ownParenetViewController = self.ownParentViewController;
    
    LogInfo(@"Going to class WSProdListViewController");
    
    self.ownParentViewController.hidesBottomBarWhenPushed = YES;
    [self.ownParentViewController.navigationController pushViewController:lvc animated:YES];
//    self.hidesBottomBarWhenPushed = NO;
}


@end

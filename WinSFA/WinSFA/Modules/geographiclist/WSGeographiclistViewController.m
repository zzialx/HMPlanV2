//
//  WCGeographiclistViewController.m
//  WinSFA
//
//  Created by xiaotang.wang on 7/22/13.
//  Copyright (c) 2013 WinChannel. All rights reserved.
//

#import "WSGeographiclistViewController.h"
#import "WSBaseGeographicInfo.h"
#import "WSFetchOutplanStoreByGeographicViewController.h"

@interface WSGeographiclistViewController ()<UITableViewDataSource, UITableViewDelegate>



@end

@implementation WSGeographiclistViewController

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
    self = [super initWithFuncs:funcs];
    if (self) {
        // Do something
    }
    return self;
}

- (id)initWithFuncs:(WSFuncsBean *)funcs andGeographicinfos:(NSArray *)aInfos
{
    self = [super initWithFuncs:funcs];
    if (self != nil) {
        _iGeographicInfos = aInfos;
    }
    return self;
}


- (void)loadView
{
    [super loadView];
    
    UITableView *tv = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStyleGrouped];
    tv.backgroundColor = [UIColor whiteColor];
    tv.backgroundView = nil;
    tv.delegate = self;
    tv.dataSource = self;
    tv.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:tv];
    
    self.ownParentViewController.navigationItem.rightBarButtonItem = nil;
}

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

#pragma mark - UITableView delegate and datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.iGeographicInfos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tvidentify = @"geoidentify";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tvidentify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tvidentify];
    }
    
    WSBaseGeographicInfo *info = [self.iGeographicInfos objectAtIndex:indexPath.row];
    cell.textLabel.text = info.iName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WSBaseGeographicInfo *info = [self.iGeographicInfos objectAtIndex:indexPath.row];
    if (info.iGeographicInfos != nil && [info.iGeographicInfos count] > 0) {
        WSGeographiclistViewController *cv = [[WSGeographiclistViewController alloc] initWithFuncs:self.currentFuncs andGeographicinfos:info.iGeographicInfos];
        cv.ownParentViewController = self.ownParentViewController;
        [self.ownParentViewController.navigationController pushViewController:cv animated:YES];
    }else{
        WSFetchOutplanStoreByGeographicViewController *cv = [[WSFetchOutplanStoreByGeographicViewController alloc] initWithFuncs:self.currentFuncs andBaseGeographicInfo:info];
        cv.ownParentViewController = self;
        [self.ownParentViewController.navigationController pushViewController:cv animated:YES];
    }
}







@end

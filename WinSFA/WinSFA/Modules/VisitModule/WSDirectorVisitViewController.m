//
//  DirectorVisitViewController.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 9/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSDirectorVisitViewController.h"
#import "WSFuncsBean.h"
#import "WSFuncsBean_menu.h"
//TODO:对上层依赖，需要重构
//#import "StoreExpansionViewController.h"
#import "WSStoreSearchFromNetViewController.h"
#import "WCOptionalSource.h"


@interface WSDirectorVisitViewController() <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)UITableView *iCategoryTableView;

@property (nonatomic, strong)NSMutableArray* iNameArray;
@property (nonatomic, strong)NSMutableArray* iFilterArray;
@property (nonatomic, strong)WSFuncsBean* iCurrentFuncs;
@end

@implementation WSDirectorVisitViewController

@synthesize iCategoryTableView = _iCategoryTableView;
@synthesize iNameArray = _iNameArray;
@synthesize iFilterArray = _iFilterArray;
@synthesize iCurrentFuncs = _iCurrentFuncs;
@synthesize specialMenuFilterAccess = _specialMenuFilterAccess;


#pragma mark - init & dealloc

- (id)init
{
    self = [super init];
    if (self) {
        // Do something
        return self;
    }
    return nil;
}


- (id)initWithFuncs:(WSFuncsBean *)aFuncs
{
    if (!aFuncs) 
        return nil;
    
    self = [super init];
    if (self) 
    {
        self.iCurrentFuncs = aFuncs;
        self.title = aFuncs.name;
        [[WCOptionalSource sharedInstance] setViewControllerParam:self byKey:self.iCurrentFuncs.fv];
        return self;
    }
    return nil;
}

- (NSMutableArray*)iNameArray
{
    if (!_iNameArray) 
    {
        _iNameArray = [[NSMutableArray alloc] init];
    }
    return _iNameArray;
}

- (NSMutableArray*)iFilterArray
{
    if (!_iFilterArray) 
    {
        _iFilterArray = [[NSMutableArray alloc] init ];
    }
    return _iFilterArray;
}


#pragma mark - view life cycle

- (void)loadView
{
    // Create a view for the main view
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.autoresizesSubviews = YES;
    self.view = view;
    
    // Create table view
    CGRect frame = CGRectMake(0, 0, 320, 460);
    UITableView *tv = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    self.iCategoryTableView = tv;
    self.iCategoryTableView.delegate = self;
    self.iCategoryTableView.dataSource = self;
    self.iCategoryTableView.backgroundColor = [UIColor whiteColor];
    self.iCategoryTableView.backgroundView = nil;
    [self.view addSubview:tv];

}

- (void)viewDidLoad
{
    // Init data
    WSFuncsBean *categoryFunc = [self.iCurrentFuncs.funcsArray objectAtIndex:0];
    NSArray *menuArray = categoryFunc.menuArray;
    for (WSFuncsBean_menu *item in menuArray) 
    {
        [self.iNameArray addObject:item.name];
        NSLog(@"name = %@ filter = %@", item.name, item.filter);
        [self.iFilterArray addObject:item.filter];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.iCurrentFuncs = nil;
    self.iCategoryTableView = nil;
    self.iNameArray = nil;
    self.iFilterArray = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableView dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.iNameArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tvIdentifier = @"com.winchannel.directorvisit";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tvIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tvIdentifier];
    }
    
    NSString *name = [self.iNameArray objectAtIndex:indexPath.row];
    cell.textLabel.text = name;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *name = [self.iNameArray objectAtIndex: indexPath.row];
    NSString *filter = [self.iFilterArray objectAtIndex: indexPath.row];
    
    NSString *isplanlist = nil;
    WSFuncsBean *categoryFunc = [self.iCurrentFuncs.funcsArray objectAtIndex:0];
    NSArray *menuArray = categoryFunc.menuArray;
    for (WSFuncsBean_menu *item in menuArray) {
        if ([item.filter isEqualToString:[self.iFilterArray objectAtIndex:indexPath.row]]) 
        {
            isplanlist = item.isplanlist;
        }
    }
    
    NSString *specialFilterClass = [self.specialMenuFilterAccess objectForKey:filter];
    if (specialFilterClass)
    {
        NSLog(@"Going to init class: %@", specialFilterClass);
        UIViewController *vc = [[NSClassFromString(specialFilterClass) alloc] initWithName:name];
        vc.title = name;
        [self.navigationController pushViewController:vc animated:YES];
    }
//    if ([filter isEqualToString:@"CallPlan"])
//    {
//        NSLog(@"Going to init class: %@", [PropertyManager getPropertybyKey:@"TAB_CallPlan"]);
//        UIViewController *vc = [[NSClassFromString([PropertyManager getPropertybyKey:@"TAB_CallPlan"]) alloc] initWithName:name];
//        vc.title = name;
//        [self.navigationController pushViewController:vc animated:YES];
//        [vc release];
//    }
    else {
//        if (!isplanlist || [isplanlist isEqualToString:@"0"]) {
            WSStoreSearchFromNetViewController *searchvc = [[WSStoreSearchFromNetViewController alloc] initWithFuncs:[self.iCurrentFuncs.funcsArray objectAtIndex:0] andFilter:filter];
            searchvc.title = name;
            [self.navigationController pushViewController:searchvc animated:YES];
//        }else {
//            StoreExpansionViewController *sevc = [[StoreExpansionViewController alloc] initWithFuncs:[self.iCurrentFuncs.funcsArray objectAtIndex:0] currentFilter:filter];
//            sevc.title = name;
//            [self.navigationController pushViewController:sevc animated:YES];
//            [sevc release];
//        }
    }
}


@end

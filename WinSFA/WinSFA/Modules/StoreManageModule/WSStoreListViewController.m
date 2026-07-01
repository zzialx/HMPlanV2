//
//  StoreListViewController.m
//  WinChannelFrameWork
//
//  Created by Jiepeng Zheng on 12-8-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSStoreListViewController.h"
#import "WSOutPlanStoreBean.h"
#import "WSInPlanStoreBean.h"
//TODO:对上层依赖，需要重构
//#import "MyModifyStoreInfoViewController.h"
#import "WSAppData.h"
#import "WSStoreBean.h"

@interface WSStoreListViewController ()

- (void)initArrayData;

@end

@implementation WSStoreListViewController

@synthesize filter = _filter;
@synthesize storeBeanArray = _storeBeanArray;
@synthesize ownParentViewController = _ownParentViewController;
@synthesize searchBar = _searchBar;
@synthesize searchDC = _searchDC;
@synthesize searchResultArray = _searchResultArray;
@synthesize tv = _tv;

#pragma mark - init & dealloc
- (id)initWithFilter:(NSString *)aFilter
{
    if (aFilter == nil)
    {
        return nil;
    }
    self = [super init];
    if (self)
    {
        self.filter = aFilter;
        [self initArrayData];
        return self;
    }
    return nil;
}


#pragma mark - view controller
- (void)loadView
{
    [super loadView];
    _tv = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 415) style:UITableViewStyleGrouped];
    _tv.backgroundView = nil;
    _tv.backgroundColor = [UIColor clearColor];
    _tv.delegate = self;
    _tv.dataSource = self;
    [self.view addSubview:_tv];
    
    self.searchBar = [[WSSearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44) isResetTextField:NO isResetBackgroundColor:YES];
    _tv.tableHeaderView = self.searchBar;
    
    self.searchDC = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar.searchBar contentsController:self];
    self.searchDC.searchResultsDataSource = self;
    self.searchDC.searchResultsDelegate = self;
    self.searchBar.searchBar.placeholder = NSLocalizedString(@"query_label", nil);
}

#pragma mark - delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _tv)
    {
        return [_storeBeanArray count];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[cd] %@",self.searchBar.searchBar.text];
    self.searchResultArray = [self.storeBeanArray filteredArrayUsingPredicate:predicate];
    
    return [_searchResultArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WSStoreListViewController";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:CellIdentifier];
    }
    
    WSStoreBean *storeBean;
    if (tableView == _tv)
    {
        storeBean = [_storeBeanArray objectAtIndex:[indexPath row]];
    }
    else
    {
        storeBean = [_searchResultArray objectAtIndex:[indexPath row]];
    }
    cell.textLabel.text = storeBean.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    WSStoreBean *storeBean;
//    if (tableView == _tv)
//    {
//        storeBean = [_storeBeanArray objectAtIndex:[indexPath row]];
//    }
//    else
//    {
//        storeBean = [_searchResultArray objectAtIndex:[indexPath row]];
//    }
    
    //TODO:对上层依赖，需要重构
//    MyModifyStoreInfoViewController *vc = [[MyModifyStoreInfoViewController alloc] initWithStoreInfo:storeBean filter:_filter];
//    
//    vc.title = @"档案修改";
//    [_ownParentViewController.navigationController pushViewController:vc animated:YES];
//    [vc release];
}

#pragma mark - private API
- (void)initArrayData
{
    if (_storeBeanArray == nil)
    {
        _storeBeanArray = [[NSMutableArray alloc] init];
    }
    [_storeBeanArray removeAllObjects];
    WSOutPlanStoreBean *outPlanStoreArray = [WSAppData getObjectbyKey:OUTPLANSTORE];
    for (WSStoreBean *item in outPlanStoreArray.storesArray)
    {
        if (![item.name respondsToSelector:@selector(isEqualToString:)])
            continue;
        if (item.styp) 
        {
            if ([item.styp respondsToSelector:@selector(isEqualToString:)] && [item.styp isEqualToString:_filter])
            {
                [_storeBeanArray addObject:item];
            }
        }
    }
    WSInPlanStoreBean *inPlanStoreArray = [WSAppData getObjectbyKey:INPLANSTORE];
    for (WSStoreBean *item in inPlanStoreArray.storesArray)
    {
        if (![item.name respondsToSelector:@selector(isEqualToString:)])
            continue;
        if (item.styp) {
            if ([item.styp respondsToSelector:@selector(isEqualToString:)] && [item.styp isEqualToString:_filter])
            {
                [_storeBeanArray addObject:item];
            }
        }
    }
}

@end

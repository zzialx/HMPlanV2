//
//  WSStoreContactsBookViewController.m
//  WinSFA
//
//  Created by yuanji on 2018/5/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSStoreContactsBookViewController.h"
#import "WSContactsBookHeaderView.h"
#import "WSEmptyView.h"
#import "WSContactsBookSearchView.h"
#import "WSContactsBookNameTableViewCell.h"
#import "WSContactsBookDetailsViewController.h"
#import "WSContactsBookTools.h"
#import "WSContactsBookGlobalDefinitions.h"
//===================================================================================================================================================================

#pragma mark - 门店通讯录视图管理器 延展(内部)
@interface WSStoreContactsBookViewController ()

@property (nonatomic, strong) WSContactsBookHeaderView *headerView;         //头视图
@property (nonatomic, strong) UITableView *tableView;                       //表视图
@property (nonatomic, strong) WSEmptyView *dataEmptyView;                   //数据空视图
@property (nonatomic, strong) WSContactsBookSearchView *searchView;         //搜索视图
@property (nonatomic, strong) NSMutableArray *nameIndexArray;               //姓名索引下标数组
@property (nonatomic, strong) NSMutableDictionary *nameSectionDictionary;   //姓名分组字典
@property (nonatomic, strong) NSMutableArray *contactsArray;                //联系人数组

@end
//===================================================================================================================================================================

#pragma mark - 门店通讯录视图管理器 延展(工具)
@interface WSStoreContactsBookViewController (Tools)

#pragma mark - 普通初始化方法
- (void)commonInit;

#pragma mark - 布局门店通讯录视图方法
- (void)layoutStoreContactsBookView;

@end
//===================================================================================================================================================================

#pragma mark - 门店通讯录视图管理器 延展(实现UITableViewDelegate代理协议, 实现UITableViewDataSource数据源协议)
@interface WSStoreContactsBookViewController (tableViewDelegateAndDataSource) <UITableViewDelegate, UITableViewDataSource>

@end
//===================================================================================================================================================================

#pragma mark - 门店通讯录视图管理器 延展(实现WSContactsBookHeaderViewDelegate代理协议)
@interface WSStoreContactsBookViewController (contactsBookHeaderViewDelegate) <WSContactsBookHeaderViewDelegate>

@end
//===================================================================================================================================================================

#pragma mark - 门店通讯录视图管理器 延展(实现WSContactsBookSearchViewDelegate代理协议)
@interface WSStoreContactsBookViewController (contactsBookSearchViewDelegate) <WSContactsBookSearchViewDelegate>

@end
//===================================================================================================================================================================

#pragma mark - 门店通讯录视图管理器
@implementation WSStoreContactsBookViewController

#pragma mark - 获取headerView方法
- (WSContactsBookHeaderView *)headerView
{
    if(_headerView == nil)
    {
        _headerView = [[WSContactsBookHeaderView alloc] initWithFrame:CGRectZero];
        _headerView.backgroundColor = [UIColor clearColor];
        _headerView.delegate = self;
    }
    return _headerView;
}

#pragma mark - 获取tableView方法
- (UITableView *)tableView
{
    if(_tableView == nil)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

#pragma mark - 获取dataEmptyView方法
- (WSEmptyView *)dataEmptyView
{
    if(_dataEmptyView == nil)
    {
        _dataEmptyView = [[WSEmptyView alloc] initWithFrame:self.view.bounds andFuncsBean:self.currentFuncs];
        _dataEmptyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _dataEmptyView.backgroundColor = [UIColor whiteColor];
        _dataEmptyView.hidden = YES;
    }
    return _dataEmptyView;
}

#pragma mark - 获取searchView方法
- (WSContactsBookSearchView *)searchView
{
    if(_searchView == nil)
    {
        _searchView = [[WSContactsBookSearchView alloc] initWithFrame:CGRectZero];
        _searchView.backgroundColor = [UIColor colorWithRed:155.0f / 255.0f green:155.0f / 255.0f blue:155.0f / 255.0f alpha:0.5f];
        _searchView.hidden = YES;
        _searchView.delegate = self;
    }
    return _searchView;
}

#pragma mark - 重写viewDidLoad方法
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self commonInit];
}

#pragma mark - 重写viewWillLayoutSubviews方法
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self layoutStoreContactsBookView];
}

#pragma mark - 重写iewWillDisappear:方法
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.headerView cloaseSearchBar];
}

@end
//===================================================================================================================================================================

#pragma mark - 门店通讯录视图管理器 延展(工具)
@implementation WSStoreContactsBookViewController (Tools)

#pragma mark - 普通初始化方法
- (void)commonInit
{
    self.view.backgroundColor = [[WSContactsBookTools sharedManager] getContactsBookBgColor];
    
    self.nameIndexArray = [[NSMutableArray alloc] initWithArray:[WSContactsBookTools sharedManager].storeNameIndexArray];
    self.nameSectionDictionary = [[NSMutableDictionary alloc] initWithDictionary:[WSContactsBookTools sharedManager].storeNameSectionDictionary];
    self.contactsArray = [[NSMutableArray alloc] initWithCapacity:self.nameSectionDictionary.allValues.count];
    for (int i = 0; i < self.nameSectionDictionary.allValues.count; ++i)
        [self.contactsArray addObjectsFromArray:[self.nameSectionDictionary.allValues objectAtIndex:i]];
    
    [self.view addSubview:self.headerView];
    [self.headerView updateWithIsShowOrganize:NO isShowStoreButton:NO];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.dataEmptyView];
    [self.view addSubview:self.searchView];
    
    if(self.nameIndexArray.count <= 0)
        self.dataEmptyView.hidden = NO;
    else
        [self.tableView reloadData];
}

#pragma mark - 布局门店通讯录视图方法
- (void)layoutStoreContactsBookView
{
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    CGFloat w = CGRectGetWidth(self.view.frame);
    CGFloat h = [self.headerView getHeightWithisShowOrganize:NO isShowStoreButton:NO maxWidth:CGRectGetWidth(self.view.frame)];
    self.headerView.frame = CGRectMake(x, y, w, h);
    
    x = 0.0f;
    y = CGRectGetMaxY(self.headerView.frame);
    w = CGRectGetWidth(self.view.frame);
    h = CGRectGetHeight(self.view.frame) - y;
    self.tableView.frame = CGRectMake(x, y, w, h);
    
    x = 0.0f;
    y = kContactsBookSearchHeight_standard;
    w = CGRectGetWidth(self.view.frame);
    h = CGRectGetHeight(self.view.frame) - y;
    self.searchView.frame = CGRectMake(x, y, w, h);
}

@end
//===================================================================================================================================================================

#pragma mark - 门店通讯录视图管理器 延展(实现UITableViewDelegate代理协议, 实现UITableViewDataSource数据源协议)
@implementation WSStoreContactsBookViewController (tableViewDelegateAndDataSource)

#pragma mark - 实现tableView:heightForHeaderInSection:协议
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kContactsBookElementHeaderHeight_standard;
}

#pragma mark - 实现tableView:titleForHeaderInSection:协议
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.nameIndexArray[section];
}

#pragma mark - 实现tableView:willDisplayHeaderView:协议
-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.contentView.backgroundColor = [[WSContactsBookTools sharedManager] getContactsBookBgColor];
    header.textLabel.textColor = [[WSContactsBookTools sharedManager] getContactsBookGroupingTitleColor];
}

#pragma mark - 实现numberOfSectionsInTableView协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.nameIndexArray.count;
}

#pragma mark - 实现tableView:numberOfRowsInSection:协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *str = [self.nameIndexArray objectAtIndex:section];
    return ((NSMutableArray *)[self.nameSectionDictionary objectForKey:str]).count;
}

#pragma mark - 实现tableView:heightForRowAtIndexPath:协议
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [WSContactsBookNameTableViewCell getCellHeight];
}

#pragma mark - 实现tableView:cellForRowAtIndexPath:协议
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *contactsBookNameTableViewCell = @"contactsBookNameTableViewCellIdentifier";
    WSContactsBookNameTableViewCell *nameCell = [tableView dequeueReusableCellWithIdentifier:contactsBookNameTableViewCell];
    
    if(nameCell == nil)
    {
        nameCell = [[WSContactsBookNameTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contactsBookNameTableViewCell];
        [nameCell setAccessoryType:UITableViewCellAccessoryNone];
        [nameCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [nameCell setBackgroundColor:[[WSContactsBookTools sharedManager] getContactsBookElementBgColor]];
    }
    
    NSString *str = [self.nameIndexArray objectAtIndex:indexPath.section];
    NSArray *array = [self.nameSectionDictionary objectForKey:str];
    WSContactsStandardInfo *data = [array objectAtIndex:indexPath.row];
    [nameCell setCellWithData:data isHiddenLine:(indexPath.row < array.count - 1) ? NO : YES];
    
    return nameCell;
}

#pragma mark - 实现tableView:didSelectRowAtIndexPath:协议
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *str = [self.nameIndexArray objectAtIndex:indexPath.section];
    NSArray *array = [self.nameSectionDictionary objectForKey:str];
    WSContactsStandardInfo *data = [array objectAtIndex:indexPath.row];
    
    WSContactsBookDetailsViewController *vc = [[WSContactsBookDetailsViewController alloc] init];
    vc.title = NSLocalizedString(@"details", nil);
    vc.detailsType = WSContactsBookDetailsTypeStore;
    vc.infoData = data;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 实现sectionIndexTitlesForTableView:协议
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.nameIndexArray;
}

@end
//===================================================================================================================================================================

#pragma mark - 门店通讯录视图管理器 延展(实现WSContactsBookHeaderViewDelegate代理协议)
@implementation WSStoreContactsBookViewController (contactsBookHeaderViewDelegate)

#pragma mark - 开始搜索方法
- (void)beginSearch
{
    self.searchView.hidden = NO;
}

#pragma mark - 结束搜索方法
- (void)endSearch
{
    self.searchView.hidden = YES;
    self.searchView.resultMutableArray = [NSMutableArray array];
}

#pragma mark - 搜索结果方法
- (void)searchResult:(NSString *)result
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS %@", result];
    NSMutableArray *resultArray = [[NSMutableArray alloc] initWithArray:[self.contactsArray filteredArrayUsingPredicate:predicate]];
    
    NSMutableArray *newResultArray = [NSMutableArray array];
    NSMutableArray *idArray = [NSMutableArray array];
    for(WSContactsStandardInfo *info in resultArray)
    {
        if([idArray containsObject:info.contactsId])
            continue;
        
        [idArray addObject:info.contactsId];
        [newResultArray addObject:info];
    }
    self.searchView.resultMutableArray = newResultArray;
}

@end
//===================================================================================================================================================================

#pragma mark - 门店通讯录视图管理器 延展(实现WSContactsBookSearchViewDelegate代理协议)
@implementation WSStoreContactsBookViewController (contactsBookSearchViewDelegate)

#pragma mark - 结果选择代理协议
- (void)resultsSelect:(id)results
{
    WSContactsStandardInfo *data = (WSContactsStandardInfo *)results;
    WSContactsBookDetailsViewController *vc = [[WSContactsBookDetailsViewController alloc] init];
    vc.title = NSLocalizedString(@"details", nil);
    vc.detailsType = WSContactsBookDetailsTypeStore;
    vc.infoData = data;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 滚动视图拖动代理协议
- (void)scrollViewStartDragging
{
    [self.headerView cloaseSearchBar];
}

@end
//===================================================================================================================================================================

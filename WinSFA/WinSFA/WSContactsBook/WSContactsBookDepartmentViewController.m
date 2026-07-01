//
//  WSContactsBookDepartmentViewController.m
//  WinSFA
//
//  Created by yuanji on 2018/5/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSContactsBookDepartmentViewController.h"
#import "WSContactsBookGlobalDefinitions.h"
#import "WSContactsBookTools.h"
#import "WSContactsBookDepartmentScrollView.h"
#import "WSContactsBookNameTableViewCell.h"
#import "WSContactsBookDepartmentTableViewCell.h"
#import "WSContactsBookHeaderView.h"
#import "WSContactsBookDetailsViewController.h"
#import "WSContactsBookSearchView.h"
//===================================================================================================================================================================

#pragma mark - 通讯录部门视图管理器 延展(内部)
@interface WSContactsBookDepartmentViewController ()

@property (nonatomic, strong) WSContactsBookHeaderView *headerView;             //头视图
@property (nonatomic, strong) WSContactsBookDepartmentScrollView *scrollView;   //滚动视图
@property (nonatomic, strong) UITableView *tableView;                           //表视图
@property (nonatomic, strong) WSContactsBookSearchView *searchView;             //搜索视图
@property (nonatomic, strong) NSMutableArray *contactsBookArray;                //通讯录数组
@property (nonatomic, strong) NSMutableArray *resultArray;                      //结果数组
@property (nonatomic, strong) NSMutableArray *contactsArray;                    //联系人数组
@property (nonatomic, strong) NSMutableArray *parentIdArray;                    //父级id数组

@end
//===================================================================================================================================================================

#pragma mark - 通讯录部门管理器 延展(工具)
@interface WSContactsBookDepartmentViewController (Tools)

#pragma mark - 普通初始化方法
- (void)commonInit;

#pragma mark - 布局通讯录部门视图方法
- (void)layoutContactsBookDepartment;

#pragma mark - 查询结果方法 parentId:父级id
- (void)queryResult:(NSString *)parentId;

@end
//===================================================================================================================================================================

#pragma mark - 通讯录部门视图管理器 延展(实现WSContactsBookHeaderViewDelegate代理协议)
@interface WSContactsBookDepartmentViewController (contactsBookHeaderViewDelegate) <WSContactsBookHeaderViewDelegate>

@end
//===================================================================================================================================================================

#pragma mark - 通讯录部门视图管理器 延展(实现UITableViewDelegate代理协议, 实现UITableViewDataSource数据源协议)
@interface WSContactsBookDepartmentViewController (tableViewDelegateAndDataSource) <UITableViewDelegate, UITableViewDataSource>

@end
//===================================================================================================================================================================

#pragma mark - 通讯录部门视图管理器 延展(实现WSContactsBookSearchViewDelegate代理协议)
@interface WSContactsBookDepartmentViewController (contactsBookSearchViewDelegate) <WSContactsBookSearchViewDelegate>

@end
//===================================================================================================================================================================

#pragma mark - 通讯录部门视图管理器 延展(实现WSContactsBookDepartmentScrollViewDelegate代理协议)
@interface WSContactsBookDepartmentViewController (contactsBookDepartmentScrollViewDelegate) <WSContactsBookDepartmentScrollViewDelegate>

@end
//===================================================================================================================================================================

#pragma mark - 通讯录部门视图管理器
@implementation WSContactsBookDepartmentViewController

#pragma mark - 获取resultArray方法
- (NSMutableArray *)resultArray
{
    if(_resultArray == nil)
        _resultArray = [NSMutableArray array];
    return _resultArray;
}

#pragma mark - 获取parentIdArray方法
- (NSMutableArray *)parentIdArray
{
    if(_parentIdArray == nil)
        _parentIdArray = [NSMutableArray array];
    return _parentIdArray;
}

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

#pragma mark - 获取scrollView方法
- (WSContactsBookDepartmentScrollView *)scrollView
{
    if(_scrollView == nil)
    {
        _scrollView = [[WSContactsBookDepartmentScrollView alloc] initWithFrame:CGRectZero];
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [[WSContactsBookTools sharedManager] getContactsBookElementBgColor];
    }
    return _scrollView;
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
    [self layoutContactsBookDepartment];
}

#pragma mark - 重写iewWillDisappear:方法
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.headerView cloaseSearchBar];
}

@end
//===================================================================================================================================================================

#pragma mark - 通讯录部门管理器 延展(工具)
@implementation WSContactsBookDepartmentViewController (Tools)

#pragma mark - 普通初始化方法
- (void)commonInit
{
    self.view.backgroundColor = [[WSContactsBookTools sharedManager] getContactsBookBgColor];
    
    [self.view addSubview:self.headerView];
    [self.headerView updateWithIsShowOrganize:NO isShowStoreButton:NO];
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.searchView];
    
    NSMutableDictionary *nameSectionDictionary = [WSContactsBookTools sharedManager].nameSectionDictionary;
    self.contactsArray = [[NSMutableArray alloc] initWithCapacity:nameSectionDictionary.allValues.count];
    for (int i = 0; i < nameSectionDictionary.allValues.count; ++i)
        [self.contactsArray addObjectsFromArray:[nameSectionDictionary.allValues objectAtIndex:i]];
    
    self.contactsBookArray = [[NSMutableArray alloc] initWithArray:[WSContactsBookTools sharedManager].allInfoArray];
    [self queryResult:@""];
    [self.tableView reloadData];
    self.scrollView.tags = [[NSMutableArray alloc] initWithObjects:NSLocalizedString(@"contacts_book", nil), nil];
    [self.scrollView reloadTagSubviews];
}

#pragma mark - 布局通讯录部门视图方法
- (void)layoutContactsBookDepartment
{
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    CGFloat w = CGRectGetWidth(self.view.frame);
    CGFloat h = [self.headerView getHeightWithisShowOrganize:NO isShowStoreButton:NO maxWidth:CGRectGetWidth(self.view.frame)];
    self.headerView.frame = CGRectMake(x, y, w, h);
    
    x = 0.0f;
    y = CGRectGetMaxY(self.headerView.frame) + kContactsBookSpace_standard;
    w = CGRectGetWidth(self.view.frame);
    h = kContactsBookDepartmentHeadHeight;
    self.scrollView.frame = CGRectMake(x, y, w, h);
    
    x = 0.0f;
    y = CGRectGetMaxY(self.scrollView.frame) + kContactsBookSpace_standard;
    w = CGRectGetWidth(self.view.frame);
    h = CGRectGetHeight(self.view.frame) - y;
    self.tableView.frame = CGRectMake(x, y, w, h);
    
    x = 0.0f;
    y = kContactsBookSearchHeight_standard;
    w = CGRectGetWidth(self.view.frame);
    h = CGRectGetHeight(self.view.frame) - y;
    self.searchView.frame = CGRectMake(x, y, w, h);
}

#pragma mark - 查询结果方法 parentId:父级id
- (void)queryResult:(NSString *)parentId
{
    NSPredicate *predicate = nil;
    if(parentId.length > 0)
        predicate = [NSPredicate predicateWithFormat:@"parentId == %@", parentId];
    else
        predicate = [NSPredicate predicateWithFormat:@"parentId == %@ || parentId == %@", @"", nil];
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] initWithArray:[self.contactsBookArray filteredArrayUsingPredicate:predicate]];
    [self.resultArray removeAllObjects];
    self.resultArray = [[NSMutableArray alloc] initWithArray:resultArray];
}

@end
//===================================================================================================================================================================

#pragma mark - 通讯录部门管理器 延展(实现WSContactsBookHeaderViewDelegate代理协议)
@implementation WSContactsBookDepartmentViewController (contactsBookHeaderViewDelegate)

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

#pragma mark - 通讯录部门视图管理器 延展(实现UITableViewDelegate代理协议, 实现UITableViewDataSource数据源协议)
@implementation WSContactsBookDepartmentViewController (tableViewDelegateAndDataSource)

#pragma mark - 实现tableView:numberOfRowsInSection:协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.resultArray.count;
}

#pragma mark - 实现tableView:heightForRowAtIndexPath:协议
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WSContactsStandardInfo *info = [self.resultArray objectAtIndex:indexPath.row];
    
    if([info.leafNode isEqualToString:@"1"])
        return [WSContactsBookNameTableViewCell getCellHeight];
    
    return [WSContactsBookDepartmentTableViewCell getCellHeight];
}

#pragma mark - 实现tableView:cellForRowAtIndexPath:协议
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WSContactsStandardInfo *info = [self.resultArray objectAtIndex:indexPath.row];
    
    if([info.leafNode isEqualToString:@"1"])
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
        
        [nameCell setCellWithData:info isHiddenLine:(indexPath.row < self.resultArray.count - 1) ? NO : YES];
        return nameCell;
    }
    
    static NSString *contactsBookDepartmentTableViewCell = @"contactsBookDepartmentTableViewCellIdentifier";
    WSContactsBookDepartmentTableViewCell *departmentCell = [tableView dequeueReusableCellWithIdentifier:contactsBookDepartmentTableViewCell];
    if(departmentCell == nil)
    {
        departmentCell = [[WSContactsBookDepartmentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contactsBookDepartmentTableViewCell];
        [departmentCell setAccessoryType:UITableViewCellAccessoryNone];
        [departmentCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [departmentCell setBackgroundColor:[[WSContactsBookTools sharedManager] getContactsBookElementBgColor]];
    }
    
    [departmentCell setCellWithData:info isHiddenLine:(indexPath.row < self.resultArray.count - 1) ? NO : YES];
    return departmentCell;
}

#pragma mark - 实现tableView:didSelectRowAtIndexPath:协议
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WSContactsStandardInfo *info = [self.resultArray objectAtIndex:indexPath.row];
    if([info.leafNode isEqualToString:@"1"])
    {
        WSContactsBookDetailsViewController *vc = [[WSContactsBookDetailsViewController alloc] init];
        vc.title = NSLocalizedString(@"details", nil);
        vc.infoData = info;
        vc.optData = self.currentFuncs.opt;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    [self queryResult:info.contactsId];
    [self.tableView reloadData];
    [self.scrollView addTag:info.name];
    [self.parentIdArray addObject:info.contactsId];
}

@end
//===================================================================================================================================================================

#pragma mark - 通讯录部门管理器 延展(实现WSContactsBookHeaderViewDelegate代理协议)
@implementation WSContactsBookDepartmentViewController (contactsBookSearchViewDelegate)

#pragma mark - 结果选择代理协议
- (void)resultsSelect:(id)results
{
    WSContactsStandardInfo *data = (WSContactsStandardInfo *)results;
    WSContactsBookDetailsViewController *vc = [[WSContactsBookDetailsViewController alloc] init];
    vc.title = NSLocalizedString(@"details", nil);
    vc.infoData = data;
    vc.optData = self.currentFuncs.opt;
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

#pragma mark - 通讯录部门视图管理器 延展(实现WSContactsBookDepartmentScrollViewDelegate代理协议)
@implementation WSContactsBookDepartmentViewController (contactsBookDepartmentScrollViewDelegate)

#pragma mark - 点击事件方法 departmentScrollView:通讯录部门滚动视图 index:索引
- (void)departmentScrollView:(WSContactsBookDepartmentScrollView *)departmentScrollView tappedAtIndex:(NSInteger)index
{
    NSMutableArray *tagsArray = departmentScrollView.tags;
    if((tagsArray.count <= 0) || (index < 0) || (index >= tagsArray.count))
        return;
    
    if(index == 0)
    {
        if(tagsArray.count > 1)
        {
            [self queryResult:@""];
            [self.tableView reloadData];
            
            [self.parentIdArray removeAllObjects];
            
            self.scrollView.tags = [[NSMutableArray alloc] initWithObjects:NSLocalizedString(@"contacts_book", nil), nil];
            [self.scrollView reloadTagSubviews];
        }
        return;
    }
    
    if(index == (tagsArray.count - 1))
        return;
    
    NSMutableArray *newTagsArray = [NSMutableArray arrayWithArray:tagsArray];
    NSInteger startIndex = (index + 1);
    NSInteger endIndex = newTagsArray.count - startIndex;
    [newTagsArray removeObjectsInRange:NSMakeRange(startIndex, endIndex)];
    self.scrollView.tags = newTagsArray;
    [self.scrollView reloadTagSubviews];
    
    NSInteger parentIdIndex = index - 1;
    if(parentIdIndex < self.parentIdArray.count)
    {
        NSString *parentId = [self.parentIdArray objectAtIndex:parentIdIndex];
        [self queryResult:parentId];
        [self.tableView reloadData];
        
        NSMutableArray *newparentIdArray = [NSMutableArray arrayWithArray:self.parentIdArray];
        NSInteger startIndex = (parentIdIndex + 1);
        NSInteger endIndex = newparentIdArray.count - startIndex;
        [newparentIdArray removeObjectsInRange:NSMakeRange(startIndex, endIndex)];
        self.parentIdArray = newparentIdArray;
    }
}

@end
//===================================================================================================================================================================

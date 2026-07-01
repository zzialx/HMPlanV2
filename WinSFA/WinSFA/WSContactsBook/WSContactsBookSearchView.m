//
//  WSContactsBookSearchView.m
//  WinSFA
//
//  Created by yuanji on 2018/5/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSContactsBookSearchView.h"
#import "WSContactsBookNameTableViewCell.h"
#import "WSContactsBookTools.h"
//===================================================================================================================================================================

#pragma mark - 通讯录搜索视图 延展(内部)
@interface WSContactsBookSearchView ()

@property (nonatomic, strong) UITableView *rootTableView; //表视图

@end
//===================================================================================================================================================================

#pragma mark - 通讯录搜索视图 延展(实现UITableViewDelegate代理协议, 实现UITableViewDataSource数据源协议)
@interface WSContactsBookSearchView (tableViewDelegateAndDataSource) <UITableViewDelegate, UITableViewDataSource>

@end
//===================================================================================================================================================================

#pragma mark - 通讯录搜索视图
@implementation WSContactsBookSearchView

#pragma mark - 获取rootTableView方法
- (UITableView *)rootTableView
{
    if (_rootTableView == nil)
    {
        _rootTableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _rootTableView.backgroundColor = [[WSContactsBookTools sharedManager] getContactsBookElementBgColor];
        _rootTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _rootTableView.delegate = self;
        _rootTableView.dataSource = self;
    }
    return _rootTableView;
}

#pragma mark - 重写initWithFrame:方法
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
        [self addSubview:self.rootTableView];
    
    return self;
}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.rootTableView.frame = self.bounds;
}

#pragma mark - 设置resultMutableArray:方法
- (void)setResultMutableArray:(NSMutableArray *)resultMutableArray
{
    _resultMutableArray = resultMutableArray;
    [self.rootTableView reloadData];
}

@end
//===================================================================================================================================================================

#pragma mark - 通讯录搜索视图 延展(实现UITableViewDelegate代理协议, 实现UITableViewDataSource数据源协议)
@implementation WSContactsBookSearchView (tableViewDelegateAndDataSource)

#pragma mark - 实现tableView:numberOfRowsInSection:协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.resultMutableArray.count;
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
    
    WSContactsStandardInfo *data = [self.resultMutableArray objectAtIndex:indexPath.row];
    [nameCell setCellWithData:data isHiddenLine:(indexPath.row < self.resultMutableArray.count - 1) ? NO : YES];
    
    return nameCell;
}

#pragma mark - 实现tableView:didSelectRowAtIndexPath:协议
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(resultsSelect:)])
        [self.delegate resultsSelect:[self.resultMutableArray objectAtIndex:indexPath.row]];
}

#pragma mark - 实现scrollViewWillBeginDragging:协议
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(self.resultMutableArray.count > 0)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewStartDragging)])
            [self.delegate scrollViewStartDragging];
    }
}

@end
//===================================================================================================================================================================


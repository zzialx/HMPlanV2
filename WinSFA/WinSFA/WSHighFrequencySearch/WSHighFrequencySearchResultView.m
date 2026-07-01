//
//  WSHighFrequencySearchResultView.m
//  WinSFA
//
//  Created by yuanji on 2018/11/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSHighFrequencySearchResultView.h"
#import "WSHighFrequencySearchResultCell.h"
//=====================================================================================================================================

#pragma mark - 高频搜索结果视图
@interface WSHighFrequencySearchResultView ()

@property (nonatomic, strong) UITableView *tableView;   //表视图
@property (nonatomic, strong) NSMutableArray *dataArray;//数据数组

- (void)deleteButtonClick:(id)sender; //删除按键响应方法

@end
//=====================================================================================================================================

#pragma mark - 高频搜索结果视图 延展(工具)
@interface WSHighFrequencySearchResultView (Tools)

#pragma mark - 布局高频搜索结果视图方法
- (void)layoutHighFrequencySearchResultView;

@end
//=====================================================================================================================================

#pragma mark - 高频搜索结果视图 延展(实现UITableViewDelegate代理协议, 实现UITableViewDataSource数据源协议)
@interface WSHighFrequencySearchResultView (tableViewDelegateAndDataSource) <UITableViewDelegate, UITableViewDataSource>

@end
//=====================================================================================================================================

#pragma mark - 高频搜索结果视图
@implementation WSHighFrequencySearchResultView

#pragma mark - 获取tableView方法
- (UITableView *)tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.backgroundColor = [UIColor colorForKey:@"HighFrequencySearchBgColor"];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

#pragma mark - 获取dataArray方法
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

#pragma mark - 重写initWithFrame:方法
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _elementHeight = MAIN_CELL_HEIGHT;
        [self addSubview:self.tableView];
    }
    return self;
}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutHighFrequencySearchResultView];
}

#pragma mark - 更新视图方法 dataArray:数据数组
- (void)updateViewWithDataArray:(NSArray *)dataArray {
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:dataArray];
    [self.tableView reloadData];
}

#pragma mark - 获取元素个数方法
- (NSInteger)getSearchElementCount {
    return self.dataArray.count;
}

#pragma mark - 删除按键响应方法
- (void)deleteButtonClick:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(deleteClickAtText:)]) {
        
        UIButton *button = (UIButton *)sender;
        NSString *title = [self.dataArray objectAtIndex:button.tag];
        
        [self.dataArray removeObject:title];
        [self.tableView reloadData];
        
        [self.delegate deleteClickAtText:title];
    }
}

@end
//=====================================================================================================================================

#pragma mark - 高频搜索结果视图 延展(工具)
@implementation WSHighFrequencySearchResultView (Tools)

#pragma mark - 布局高频搜索结果视图方法
- (void)layoutHighFrequencySearchResultView {
    
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    CGFloat w = CGRectGetWidth(self.frame);
    CGFloat h = CGRectGetHeight(self.frame);
    self.tableView.frame = CGRectMake(x, y, w, h);
}

@end
//=====================================================================================================================================

#pragma mark - 高频搜索结果视图 延展(实现UITableViewDelegate代理协议, 实现UITableViewDataSource数据源协议)
@implementation WSHighFrequencySearchResultView (tableViewDelegateAndDataSource)

#pragma mark - 实现tableView:numberOfRowsInSection:协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

#pragma mark - 实现tableView:heightForRowAtIndexPath:协议
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.elementHeight;
}

#pragma mark - 实现tableView:cellForRowAtIndexPath:协议
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *highFrequencySearchResultIdentifier = @"highFrequencySearchResultIdentifier";
    WSHighFrequencySearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:highFrequencySearchResultIdentifier];
    if(!cell) {
        cell = [[WSHighFrequencySearchResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:highFrequencySearchResultIdentifier];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell.deleteButton addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    cell.deleteButton.tag = indexPath.row;
    NSString *title = [self.dataArray objectAtIndex:indexPath.row];
    [cell setCellWithText:title];

    return cell;
}

#pragma mark - 实现tableView:didSelectRowAtIndexPath:协议
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.delegate respondsToSelector:@selector(selectClickAtText:)]) {
        NSString *title = [self.dataArray objectAtIndex:indexPath.row];
        [self.delegate selectClickAtText:title];
    }
}

@end
//=====================================================================================================================================

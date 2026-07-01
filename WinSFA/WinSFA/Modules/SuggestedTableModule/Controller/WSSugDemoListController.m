//
//  WSSugDemoListController.m
//  WinSFA
//
//  Created by huzepei on 16/9/9.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSugDemoListController.h"
#import "PureLayout.h"
#import "WSSuggestWholesale.h"
#import "WSSuggestListTable.h"

@interface WSSugDemoListController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *contentView;

@end

@implementation WSSugDemoListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *label = [UILabel new];
    label.text = @"建议单";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:18];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label];
    [label autoSetDimension:ALDimensionHeight toSize:40];
    [label autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeBottom];
    
    [self.contentView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"WSSugDemoListController"];
    
    self.contentView.tableFooterView = [[UIView alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

// 分隔线到头
-(void)viewDidLayoutSubviews
{
    if ([self.contentView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.contentView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    if ([self.contentView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.contentView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

#pragma mark - uitableView delegate datasource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"WSSugDemoListController" forIndexPath:indexPath];
    
    
    if ([_stype isEqualToString:@"02"]) { //批发
        WSSuggestWholesale *pro = _dmeoListArray[indexPath.row];
        cell.textLabel.text = pro.name;
    }else{
        WSSuggestHome *pro = _dmeoListArray[indexPath.row];
        cell.textLabel.text = pro.name;
    }
    
    
    cell.textLabel.textColor = [UIColor grayColor];
    
    
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dmeoListArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //更新数据库
    if ([_stype isEqualToString:@"02"]) {
        
        WSSuggestWholesale *sw = _dmeoListArray[indexPath.row];
        [[WSSuggestListTable sharedTable] deleteSuggestWithNames:@[@"ID"] ArgumentsValue:@[sw.ID]];
        
    }else{
        
        WSSuggestHome *sw = _dmeoListArray[indexPath.row];
        [[WSSuggestListTable sharedTable] deleteSuggestWithNames:@[@"ID"] ArgumentsValue:@[sw.ID]];
    }
    
    
    [_dmeoListArray removeObjectAtIndex:indexPath.row];
    
     [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    //block  回传通知SuggestTable
    if (_delegateSuc) {
        _delegateSuc();
    }
    
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    id objectToMove = [_dmeoListArray objectAtIndex:sourceIndexPath.row];
    [_dmeoListArray removeObjectAtIndex:sourceIndexPath.row];
    [_dmeoListArray insertObject:objectToMove atIndex:destinationIndexPath.row];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //点击将模板添加到界面上
    
    
    if ([_stype isEqualToString:@"02"]) {
        
        WSSuggestWholesale *sw = _dmeoListArray[indexPath.row];
        if (_sugClick) {
            
            _sugClick(sw);
            
        };
    }else{
        
        WSSuggestHome *sh = _dmeoListArray[indexPath.row];
        if (_sugHomeClick) {
            _sugHomeClick(sh);
        };
    }
   
}

#pragma mark - getter setter
-(void)setStype:(NSString *)stype
{
    _stype = stype;
}

-(UITableView *)contentView
{
    if (!_contentView) {
        _contentView = [[UITableView alloc] init];
        _contentView.delegate  = self;
        _contentView.allowsSelectionDuringEditing = YES;
        _contentView.dataSource = self;
        [_contentView setEditing:YES];
        _contentView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_contentView];
        [_contentView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(40, 1, 1, 1)];
    }
    return _contentView;
}
@end

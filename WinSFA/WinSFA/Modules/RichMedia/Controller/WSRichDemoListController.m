//
//  WSRichDemoListController.m
//  WinSFA
//
//  Created by huzepei on 16/8/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSRichDemoListController.h"
#import "PureLayout.h"
#import "WSRichItemModel.h"
#import "WSSearchTableViewCell.h"
#define WSColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]


@interface WSRichDemoListController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property (nonatomic,strong) UITableView *contentView;

@end

@implementation WSRichDemoListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *label = [UILabel new];
    label.text = @"您的演示列表";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:18];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label];
    [label autoSetDimension:ALDimensionHeight toSize:40];
    [label autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeBottom];
    
//    [self.contentView registerClass:[WSSearchTableViewCell class] forCellReuseIdentifier:@"WSRichDemoListController"];
    
    self.contentView.tableFooterView = [[UIView alloc] init];
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    [saveBtn addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveBtn];
    [saveBtn autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5.0];
    [saveBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10.0];
    [saveBtn autoSetDimension:ALDimensionWidth toSize:40.0];
    [saveBtn autoSetDimension:ALDimensionHeight toSize:30.0];
    
}
-(void)save
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入模板名称"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"cancel_label"
                                          otherButtonTitles:@"confirm",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;

    [alert show];
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

#pragma mark - uialertdelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
     NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
     if (buttonIndex == alertView.firstOtherButtonIndex) { //点击确定
        
        UITextField *nameField = [alertView textFieldAtIndex:0];
         
         if ([nameField.text isEqualToString:@""]) {
             NSString *title = NSLocalizedString(@"未填写名称", nil);
             [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
             
             return;
         }
         
         if (_dmeoListArray.count == 0) {
             NSString *title = NSLocalizedString(@"演示列表为空", nil);
             [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
             
             return;
         }
         
         [dict setObject:_dmeoListArray forKey:nameField.text];
         
         if (_saveSuc) {
             _saveSuc(dict);
         }
         
    }
}

#pragma mark - uitableView delegate datasource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WSSearchTableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"WSRichDemoListController" ];
    if (cell == nil) {
        cell = [[WSSearchTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WSRichDemoListController"  withStyle:WSSearchTableViewCellStyleNone];
    }
    WSRichItemModel *tm = (WSRichItemModel *)_dmeoListArray[indexPath.row];
    cell.model = tm;
    
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dmeoListArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
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
    WSRichItemModel *tm = (WSRichItemModel *)_dmeoListArray[indexPath.row];
    
    [_dmeoListArray removeObjectAtIndex:indexPath.row];
    
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    //删除之后也要通知MainVC,更新Item数量.
    if (_deleteSuc) {
        _deleteSuc(_dmeoListArray,tm);
    }
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    id objectToMove = [_dmeoListArray objectAtIndex:sourceIndexPath.row];
    [_dmeoListArray removeObjectAtIndex:sourceIndexPath.row];
    [_dmeoListArray insertObject:objectToMove atIndex:destinationIndexPath.row];
    
}
#pragma mark - getter setter
-(UITableView *)contentView
{
    if (!_contentView) {
        _contentView = [[UITableView alloc] init];
        _contentView.delegate  = self;
        _contentView.dataSource = self;
        [_contentView setEditing:YES];
        _contentView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_contentView];
        [_contentView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(40, 1, 1, 1)];
    }
    return _contentView;
}
@end

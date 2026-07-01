//
//  WSTemplateController.m
//  WinSFA
//
//  Created by huzepei on 16/8/16.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSTemplateController.h"
#import "PureLayout.h"
#import "WSTemplateCell.h"
#import "WSTemplateClickController.h"
#import "WSRichMediaTemplateTable.h"
#import "WSRichMediaTemplate.h"
#import "WSRichItemModel.h"
#import "WSRichMediaTemplate.h"

#define POPVIEWWIDTH 450
#define POPVIEWHEIGHT 370

@interface WSTemplateController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UIView *contentView;

@property (nonatomic,strong) UITableView *tableView;

@end

@implementation WSTemplateController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    UIButton *titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    titleBtn.userInteractionEnabled = NO;
    [titleBtn setTitle:@"已保存的模板" forState:UIControlStateNormal];
    [titleBtn.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
    [titleBtn setBackgroundImage:[UIImage imageForName:@"suggestTitle_bg"] forState:UIControlStateNormal];
    [titleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.contentView addSubview:titleBtn];
    
    [titleBtn autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [titleBtn autoSetDimension:ALDimensionHeight toSize:40];
    
    _tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.contentView addSubview:_tableView];
    [_tableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:titleBtn];
    [_tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([WSTemplateCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([WSTemplateCell class])];
    
    _templateArr = [[[WSRichMediaTemplateTable sharedTable] queryTableForTemplate] mutableCopy];
    
}

#pragma mark - setter getter
-(UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.layer.cornerRadius = 10.0;
        _contentView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_contentView];
        [_contentView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(10, 30, 10, 30)];
    }
    return _contentView;
}

-(void)setTemplateArr:(NSMutableArray *)templateArr
{
    _templateArr = [[[WSRichMediaTemplateTable sharedTable] queryTableForTemplate] mutableCopy];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - delegate datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _templateArr.count;
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dict =  _templateArr[indexPath.row];
    
    BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:@"是否要删除模板？"];
    [alert setCancelButtonWithTitle:@"cancel_label" block:nil];
    [alert setDestructiveButtonWithTitle:@"confirm" block:^{
        
        NSString *pid;
        NSString *key = dict.allKeys[0];
        NSString *pidStr = [NSString stringWithFormat:@"SELECT spe.ID FROM spe_richMedia_template AS spe WHERE spe.name = '%@' AND spe.type = 'template';",key];
        NSMutableArray *pidArray = [[WSRichMediaTemplateTable sharedTable] queryDatasBySql:pidStr columnArr:@[@"ID"]];
        
        if (pidArray.count > 0) {
            pid = pidArray[0];
        }
        
        //删除模板
        [[WSRichMediaTemplateTable sharedTable] deleteWithNames:@[@"name",@"type"] ArgumentsValue:@[key,@"template"]];
        
        //删除模板下的演示列表数组
        [[WSRichMediaTemplateTable sharedTable] deleteWithNames:@[@"pid"] ArgumentsValue:@[pid]];
        
        //移除数据源- 更新数据动画
        [_templateArr removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    
    [alert show];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WSTemplateCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WSTemplateCell class]) forIndexPath:indexPath];
    
    cell.cellIndexPath = indexPath;
    
    NSMutableDictionary *dict =  _templateArr[indexPath.row];
    
    NSString *key = dict.allKeys[0];
    
    cell.title = key;
    
    __weak typeof(self) weakSelf = self;
    
    cell.clickPlusBtn = ^(NSIndexPath *indexPath){
        
        WSTemplateCell *cell2 = (WSTemplateCell *)[weakSelf.tableView cellForRowAtIndexPath:indexPath];
        
        CGRect rc = [cell2 convertRect:cell2.templateBtn.frame toView:self.view];
        
        __block UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageForName:@"richMedia_add.png"] forState:UIControlStateNormal];
        
        btn.frame = CGRectMake(rc.origin.x, rc.origin.y, 30, 30);
        
        [self.contentView addSubview:btn];
        
        [UIView animateWithDuration:0.5 animations:^{
            
            CGPoint point = CGPointMake(self.view.width - 50, -30);
            btn.center = point;
            
        } completion:^(BOOL finished) {
            
            [btn removeFromSuperview];
        }];
        
        if (_listArr) {
            NSMutableArray *arr = [NSMutableArray array];
            NSMutableDictionary *dict =  _templateArr[indexPath.row];
            NSString *key = dict.allKeys[0];
            NSMutableArray *array = [dict objectForKey:key];
            for (WSRichMediaDemoList *demoList in array) {
                [arr addObject:demoList.itemModel];
            }
            _listArr(arr);
        }
    };
    
    
    if (indexPath.row % 2 == 1 ) {
        cell.backgroundColor = [UIColor colorWithRed:254/255.0 green:243/255.0 blue:240/255.0 alpha:1.0];
    }else{
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    WSTemplateClickController *template = [[WSTemplateClickController alloc] init];
    
    NSMutableDictionary *dict =  _templateArr[indexPath.row];
    
    NSString *key = dict.allKeys[0];
    
    NSArray *array = [dict objectForKey:key];
    
    NSMutableArray *dataArray = [NSMutableArray array];
    
    for (WSRichMediaDemoList *rdl in array) {
        [dataArray addObject:rdl.itemModel];
    }
    
    template.dataArray = dataArray;
    
    template.name = key;
    
    template.changeTitle = ^(NSString *str){ //更新数据库
        
        [[WSRichMediaTemplateTable sharedTable] updateWithNames:@[@"name"] values:@[str] whereName:@[@"name",@"type"] whereValue:@[key,@"template"]];
        
        _templateArr = [[[WSRichMediaTemplateTable sharedTable] queryTableForTemplate] mutableCopy];
        
        [self.tableView reloadData];
    };
    
    template.view.backgroundColor = [UIColor redColor];
    
    template.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:template animated:YES completion:nil];
    
    if ([[[UIDevice currentDevice]systemVersion] floatValue] >= 8.0) {
        template.preferredContentSize = CGSizeMake(POPVIEWWIDTH,POPVIEWHEIGHT);
    }else{
        template.view.superview.center = CGPointMake(550 , 1024 / 2);
        template.view.superview.size = CGSizeMake(POPVIEWWIDTH,POPVIEWHEIGHT);
    }
}
@end

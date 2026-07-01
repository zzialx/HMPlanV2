//
//  WSANAcvtTableView.m
//  WinSFA
//
//  Created by zhangmin on 2018/12/13.
//  Copyright © 2018年 WinChannel. All rights reserved.
//cell是一个问卷acvtview

#import "WSANAcvtTableView.h"
#import "WSANTableView.h"
#import "WSStoreInfoTableViewCell.h"
#import "WSAcvtGridTableViewCell.h"
#import "WSAcvtGridTableViewHeaderView.h"
#import "WSCustomGestrueScrollView.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSAcvtListDataItem.h"

#import "WSANAcvtTableViewCell.h"

#define cellTopMargin       6.0

@interface WSANAcvtTableView () <UITableViewDataSource,UITableViewDelegate,WSANAcvtTableViewCellDelegate>
{
    NSUInteger tableViewContentHeight;

}

@end
@implementation WSANAcvtTableView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.usereditable = YES;
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        [self.tableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        [self addSubview:self.tableView];

        tableViewContentHeight = 0;
        
    }
    return self;
}
-(void)setAcvtVCArray:(NSMutableArray *)acvtVCArray {
    _acvtVCArray = acvtVCArray;
    
    [self.tableView reloadData];

}


#pragma mark - table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.acvtVCArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

     WSANAcvtTableViewCell *cell = [[WSANAcvtTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.containerView.frame = CGRectMake(cellTopMargin, cellTopMargin, SCREEN_WIDTH-cellTopMargin *2, _cellHight - cellTopMargin *2);
    WCBaseViewController *contentController = self.acvtVCArray[indexPath.row];
    contentController.view.frame = CGRectMake(0, self.mainIsDelete ? 0 : 32, SCREEN_WIDTH - cellTopMargin *2, _cellHight - (self.mainIsDelete ? 0 : 32) - cellTopMargin *2);
    [cell.containerView addSubview:contentController.view];
    cell.tag = indexPath.row;
    cell.delegate = self;
    cell.deleteButton.hidden = self.mainIsDelete;
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
     return _cellHight;
}

#pragma  mark -

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];

    [self.tableView setFrame:self.bounds];
  
}


//加号，添加问卷
- (void)addVCViewToSelfWithViewController:(WCBaseViewController *)contentController {
    
    [self.acvtVCArray  addObject:contentController];
    [self.tableView reloadData];
}

//移除全部
- (void)removeAll {
    [self.acvtVCArray removeAllObjects];
    [self.tableView reloadData];
}
//移除某一个
- (void)removeIndex:(NSInteger )index {
    // 先删除数据源
    if (index >= 0 && index < self.acvtVCArray.count) {
        [self.acvtVCArray removeObjectAtIndex:index];
        [self.tableView reloadData];
    }
 
}

#pragma mark - WSANAcvtTableViewCellDelegate
- (void)anAcvtTableViewCellDidDeleteButton:(WSANAcvtTableViewCell *)tableViewCell index:(NSInteger)index
{
    [self removeIndex:index];
}

@end


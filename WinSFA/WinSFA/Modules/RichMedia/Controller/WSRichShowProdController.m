//
//  WSRichShowProdController.m
//  WinSFA
//
//  Created by zhiqing on 16/8/28.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSRichShowProdController.h"
#import "PureLayout.h"
#import "WSRichShowProdCell.h"
#import "WSRichModel.h"
#import "WSRichItemModel.h"
#import "WSBaseDictsTable.h"
@interface WSRichShowProdController ()<UITableViewDelegate,UITableViewDataSource,WSRichShowProdCellDelegate>
{
    UITableView * _tableView;
    
    NSArray * _filterItemArray;
}
@end

@implementation WSRichShowProdController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _filterItemArray = [self getFilterItemsWiht:self.filterName];
    
    
    _tableView = [[UITableView alloc]init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    [_tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  _filterItemArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * reuserID = @"UITableViewCellReuserID";
    WSRichShowProdCell * cell = [tableView dequeueReusableCellWithIdentifier:reuserID];
    if (cell == nil) {
        cell = [[WSRichShowProdCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserID withStyle:@"prod"];
    }
    WSRichModel * model = _filterItemArray[indexPath.row];
    NSString *sql = [NSString stringWithFormat:@"select * from spe_richMedia where fenleiId = '%@'",model._id];
    NSArray * fenleiArray = [[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSRichItemModel"];
    if (fenleiArray.count  >0) {
        WSRichItemModel * fenleiModel =  fenleiArray[0];
        UIImage * image  = [self getImageWith:fenleiModel.img_add wihtType:@"sort-0.png"];
        if (!image) {
            image = [UIImage imageNamed:@"sort-0"];
        }
         cell.typeImageView.image = image;
    }
    
    cell.delegate = self;
    cell.richItemArray = [self getAllItemWith:self.filterName withFilterName:model._id];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return _tableView.height / 3.0;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WSRichModel * model = _filterItemArray[indexPath.row];
    NSString *sql = [NSString stringWithFormat:@"select * from spe_richMedia where fenleiId = '%@'",model._id];
    NSArray * fenleiArray = [[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSRichItemModel"];
    if (fenleiArray.count  >0) {
        WSRichItemModel * fenleiModel =  fenleiArray[0];
        [self itemClickCallH5WithItemModel:fenleiModel];
    }

}
-(void)reloadData{
    [super reloadData];

     _filterItemArray = [self getFilterItemsWiht:self.filterName];
    [_tableView reloadData];
}

#pragma mark - WSRichShowProdCellDelegate
-(void)popWebViewWith:(WSRichItemModel *)richModel{

    [self itemClickCallH5WithItemModel:richModel];

}
@end

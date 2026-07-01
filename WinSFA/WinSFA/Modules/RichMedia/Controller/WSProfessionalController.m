//
//  WSProfessionalController.m
//  WinSFA
//
//  Created by zhiqing on 16/8/29.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSProfessionalController.h"
#import "PureLayout.h"
#import "WSRichMediaTableTemplate.h"
#import "WSRichModel.h"
#import "WSBaseDictsTable.h"
#import "WSRichShowProdCell.h"
@interface WSProfessionalController ()<WSRichMediaTableTemplateDelegate,UITableViewDelegate,UITableViewDataSource,WSRichShowProdCellDelegate>
@property(nonatomic,strong) NSArray * filterItemArray;
@property(nonatomic,strong) WSRichMediaTableTemplate * currentView;
@property(nonatomic,strong) UITableView * tableview;

@end


@implementation WSProfessionalController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.filterItemArray = [self getFilterItemsWiht:self.filterName];
    self.tableview = [[UITableView alloc]init];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
     self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview: self.tableview];
    [ self.tableview autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];

//    for (int i = 0; i < self.filterItemArray.count; i++) {
//        WSRichModel *model = self.filterItemArray[i];
//        model.filterItems  =[self getAllItemWith:self.filterName withFilterName:model._id].mutableCopy;
//        WSRichMediaTableTemplate * view = [[WSRichMediaTableTemplate alloc]initWithFrame:CGRectMake(i * self.view.width/self.filterItemArray.count, 0, self.view.width/self.filterItemArray.count, self.view.height)];
//        view.richModel = model;
//        view.delegate  = self;
//        [self.view addSubview:view];
//    }
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  _filterItemArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * reuserID = @"UITableViewCellReuserID";
    WSRichShowProdCell * cell = [tableView dequeueReusableCellWithIdentifier:reuserID];
    if (cell == nil) {
        cell = [[WSRichShowProdCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserID withStyle:@"profession"];
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
        cell.filterImageView.image = image;
    }
    
    cell.delegate = self;
    cell.richItemArray = [self getAllItemWith:self.filterName withFilterName:model._id];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return _tableview.height / 3.0;
    
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
    WSRichModel *model = self.currentView.richModel;
    model.filterItems = [self getAllItemWith:self.filterName withFilterName:self.currentView.richModel._id].mutableCopy;
    self.currentView.richModel = model;
}

#pragma mark - WSRichMediaTableTemplateDelegate
-(void)popWebViewWith:(WSRichMediaTableTemplate *)view  andRichModel:(WSRichItemModel *)richModel{
    self.currentView = view;
    [self itemClickCallH5WithItemModel:richModel];
    
}

#pragma mark - WSRichShowProdCellDelegate
-(void)popWebViewWith:(WSRichItemModel *)richModel{
    
    [self itemClickCallH5WithItemModel:richModel];
    
}
@end

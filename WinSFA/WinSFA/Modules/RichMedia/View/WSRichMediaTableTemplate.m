//
//  WSRichMediaTableTemplate.m
//  WinSFA
//
//  Created by zhiqing on 16/8/29.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSRichMediaTableTemplate.h"
#import "PureLayout.h"
#import "WSRichMediaTableTemplateCell.h"
#import "WSRichItemModel.h"


@interface WSRichMediaTableTemplate ()<UITableViewDelegate,UITableViewDataSource>
{
    UIButton * headButton;
    UITableView * _tableView;
    UIImage * image;
}


@end

@implementation WSRichMediaTableTemplate

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupSubViews];
    }
    return self;
}

-(void)setupSubViews{

    headButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height * 0.3)];
    [headButton setImage:[UIImage imageNamed:@"sort-0"] forState:UIControlStateNormal];
    [self addSubview:headButton];


    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.height * 0.3, self.width, self.height * 0.7 - 64)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:_tableView];

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.richModel.filterItems.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * reuserID = @"UITableViewCellReuserID";
    WSRichMediaTableTemplateCell  *cell = [tableView dequeueReusableCellWithIdentifier:reuserID];
    if (cell == nil) {
        cell = [[WSRichMediaTableTemplateCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserID];
    }
    WSRichItemModel * model = self.richModel.filterItems[indexPath.row];
    cell.model = model;
       return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    return tableView.height * 0.5; // 默认高度
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if ([self.delegate respondsToSelector:@selector(popWebViewWith:andRichModel:)]) {
        [self.delegate popWebViewWith:self andRichModel:self.richModel.filterItems[indexPath.row]];
    }
}

-(void)setRichModel:(WSRichModel *)richModel{
    _richModel = richModel;
    [_tableView reloadData];

}

@end

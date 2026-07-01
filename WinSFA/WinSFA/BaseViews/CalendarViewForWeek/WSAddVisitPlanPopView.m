//
//  WSAddVisitPlanPopView.m
//  WinSFA
//
//  Created by zhiqing on 16/7/27.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSAddVisitPlanPopView.h"
#import "WSMyCustomerTitleView.h"
#import "WSSelectListNewTableviewCell.h"
#import "PureLayout.h"
#define k_View_Space 15
@interface WSAddVisitPlanPopView ()<UITableViewDelegate,UITableViewDataSource>

{
    UIView * _titleView;
    WSMyCustomerTitleView * _searchView;
    UITableView * _tableview;
    UIView * _footerView;
    
}

@end

@implementation WSAddVisitPlanPopView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

-(void)setupViews{
    _titleView  = [[UIView alloc]init];
    _titleView.backgroundColor = CELL_DETAIL_TEXTCOLOR;
    [self addSubview:_titleView];
    UILabel * titleLabel = [[UILabel alloc]init];
    titleLabel.text = NSLocalizedString(@"添加联系人", nil);
    UIButton * offButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [offButton setTitle:@"关闭" forState:UIControlStateNormal];
    [offButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [offButton addTarget:self action:@selector(removeSelf) forControlEvents:UIControlEventTouchUpInside];
    [_titleView addSubview:titleLabel];
    [_titleView addSubview:offButton];
    [titleLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [titleLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [titleLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    
    [offButton autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:k_View_Space];
    [offButton autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [offButton autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [offButton autoSetDimension:ALDimensionWidth toSize:3 *k_View_Space];
    
    [_titleView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [_titleView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [_titleView autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [_titleView autoSetDimension:ALDimensionHeight toSize:40];
    
    _searchView = [[WSMyCustomerTitleView alloc]initWithFrame:CGRectZero style:WSMyCustomerTitleViewStyleAddNewVisit withItems:nil];
    _searchView.backgroundColor = [UIColor grayColor];
    [self addSubview:_searchView];
    [_searchView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_titleView];
    [_searchView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [_searchView autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [_searchView autoSetDimension:ALDimensionHeight toSize:60];
    
    _tableview = [[UITableView alloc]init];
    _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableview.dataSource = self;
    _tableview.delegate = self;
    [self addSubview:_tableview];
    
    [_tableview autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_searchView];
    [_tableview autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [_tableview autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [_tableview autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:80];
    
    
    _footerView = [[UIView alloc]init];
    _footerView.backgroundColor = CELL_DETAIL_TEXTCOLOR;
    UIButton * cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"button_bj"] forState:UIControlStateNormal];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
    [cancelButton setTitle:@"cancel_label" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(removeSelf) forControlEvents:UIControlEventTouchUpInside];
    UIButton * determineButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [determineButton setBackgroundImage:[UIImage imageNamed:@"button_bj"] forState:UIControlStateNormal];
    [determineButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
    [determineButton setTitle:@"confirm" forState:UIControlStateNormal];
    [determineButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [determineButton addTarget:self action:@selector(saveVisitPlan) forControlEvents:UIControlEventTouchUpInside];

    [_footerView addSubview:cancelButton];
    [_footerView addSubview:determineButton];
    [cancelButton autoAlignAxis:ALAxisVertical toSameAxisOfView:_footerView withOffset:-59];
    [cancelButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [cancelButton autoSetDimensionsToSize:CGSizeMake(108, 38)];
    
    [determineButton autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:cancelButton withOffset:15];
    [determineButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [determineButton autoSetDimensionsToSize:CGSizeMake(108, 38)];
    
    
    [self addSubview:_footerView];
    
    [_footerView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_tableview withOffset:k_View_Space];
    [_footerView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [_footerView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [_footerView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:k_View_Space];
    
}

-(NSMutableArray *)dataSource{
    if (_dataSource == nil) {
        _dataSource = [[NSMutableArray alloc]init];
    }
    return _dataSource;
}

-(NSMutableArray *)selectArray{
    if (_dataSource == nil) {
        _dataSource = [[NSMutableArray alloc]init];
    }
    return _dataSource;
}
#pragma mark - UITableViewDelegate,UITableViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _dataSource.count;

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * reueserId = @"CellForAddVisitPlan";
    WSSelectListNewTableviewCell * cell = [tableView dequeueReusableCellWithIdentifier:reueserId];
    if (cell == nil) {
        cell = [[WSSelectListNewTableviewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reueserId withFuncStyle:WSSelectListNewTableviewCellStyleStoreVisitList isStoreInfo:nil cellWidth:tableView.width];
    }
    cell.store = _dataSource[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(void)saveVisitPlan{
    // 保存数据
    
}

-(void)removeSelf{
    [self removeFromSuperview];
}
@end

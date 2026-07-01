//
//  WSMyJPJCollectionViewCell.m
//  WinSFA
//
//  Created by zhiqing on 16/8/15.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSMyJPJCollectionViewCell.h"
#import "PureLayout.h"
#import "WSMyJPJTableViewCell.h"
#import "WSMyJPJCollectionModel.h"
#import "WSPopStoreDetailMessageView.h"
#define WSMyJPJCollectionView_TEXT_SIZE [UIFont systemFontOfSize:15]
@interface WSMyJPJCollectionViewCell ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView * tableview;
    UILabel * weekLable ;
    UILabel * dayLable ;
    UILabel * lable ;
    UIView  * view;
}
@end


@implementation WSMyJPJCollectionViewCell
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        tableview = [[UITableView alloc]init];
        [self.contentView addSubview:tableview];
        [tableview autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [tableview autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [tableview autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [tableview autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:120];
        tableview.sectionHeaderHeight = 64;
        tableview.dataSource = self ;
        tableview.delegate = self;
        tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [self addCollectionViewBorder];
    }
    return self;
}


- (void)addCollectionViewBorder {
    CGFloat borderWidth = 1;
    UIView *rightBorder = [[UIView alloc] init];
    rightBorder.frame = CGRectMake(self.width - borderWidth, 0, borderWidth, self.height);
    rightBorder.backgroundColor =  DETAIL_SEPERATE_LINE_COLOR;
    [self.contentView addSubview:rightBorder];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static  NSString * reuserID = @"tableViewReuserID";
    WSMyJPJTableViewCell * cell = [tableview dequeueReusableCellWithIdentifier:reuserID];
    if (cell == nil) {
        cell = [[WSMyJPJTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserID withStyle:@"noPlanOrder"];
    }
    cell.storeDict = _model.visitPlanStoreArray[indexPath.row];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _model.visitPlanStoreArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self popStoreDetailMessage:_model.visitPlanStoreArray[indexPath.row]];

}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    view = [[UIView alloc]init];
    weekLable = [[UILabel alloc]init];
    weekLable.font = WSMyJPJCollectionView_TEXT_SIZE;
    weekLable.textColor = MAIN_TEXT_COLOR;
    dayLable = [[UILabel alloc]init];
    dayLable.font = [UIFont systemFontOfSize:13];
    dayLable.textColor = DETAIL_TEXT_COLOR;
    lable = [[UILabel alloc]init];
    lable.textColor = DETAIL_TEXT_COLOR;
    lable.font = [UIFont systemFontOfSize:13];

    [view addSubview:weekLable];
    [view addSubview:dayLable];
    [view addSubview:lable];
    
    weekLable.text = _model.week;
    dayLable.text = [self getDateStringWith:_model.day];
    NSInteger actureNum = 0 ,allNum = 0;
    allNum = _model.visitPlanStoreArray.count;
    for (NSDictionary  *dict in _model.visitPlanStoreArray) {
        NSString  *visitString = dict[@"memo4"];
        if (visitString.length) {
            actureNum ++;
        }
    }
    lable.text = [NSString stringWithFormat:@"%ld/%ld",(long)actureNum,(long)allNum];

    lable.textAlignment = NSTextAlignmentCenter;
    [weekLable autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10];
    [weekLable autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [weekLable autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:view withMultiplier:0.5];
    [weekLable autoSetDimension:ALDimensionHeight toSize:20];
    
    [dayLable autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [dayLable autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:weekLable withOffset:5];
    [dayLable autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:view withMultiplier:0.7];
//    [dayLable autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:view withMultiplier:0.25];
    [dayLable autoSetDimension:ALDimensionHeight toSize:18];
    
    [lable autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
    [lable autoAlignAxis:ALAxisHorizontal toSameAxisOfView:weekLable];
    [lable autoMatchDimension:ALDimensionWidth toDimension:ALDimensionHeight ofView:view withMultiplier:0.8];
    [lable autoSetDimension:ALDimensionHeight toSize:18];

//    lable.layer.cornerRadius = 25;
//    lable.layer.borderWidth = 1;
//    lable.layer.borderColor = [UIColor blackColor].CGColor;
//    lable.clipsToBounds = YES;
//    lable.backgroundColor = [UIColor colorForKey:@"AcvtPopViewNavigationBarBackgroundColor"];

    UIColor *titleBgColor = [UIColor colorForKey:@"GridHeaderBackgroundColor"];
    if (!titleBgColor) {
        titleBgColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    }
    view.backgroundColor = titleBgColor;
    
    return view;

}

-(void)setModel:(WSMyJPJCollectionModel *)model{
    _model = model;
    [tableview reloadData];
}

-(NSString *)getDateStringWith:(NSDate *)date{
    NSDateFormatter *formatDate = [NSDateFormatter standardDateFormatter];
    [formatDate setDateFormat:@"yyyy-MM-dd"];
   return  [formatDate stringFromDate:date];
}
-(void)popStoreDetailMessage:(NSDictionary *)store{
    
    WSAppDelegate *delegate = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
    UIView *rootView = delegate.window.rootViewController.view;
    
    WSPopStoreDetailMessageView * popView = [[WSPopStoreDetailMessageView alloc]init];
    popView.dateString = [self getDateStringWith:_model.day];
    popView.store = store;
    popView.delegate = (id<WSSelectListNewTableviewCellDelegate>)self.viewController;
    [rootView addSubview:popView];
    [popView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];

}


@end

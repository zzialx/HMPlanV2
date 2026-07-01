//
//  WSNewRouteTableViewCell.m
//  WinSFA
//
//  Created by zzialx on 2022/10/27.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import "WSNewRouteTableViewCell.h"
#import "WSStoreTools.h"
#import "WSLargePointBtn.h"

static CGFloat const kStoreRouteViewCellT      = 14.0;

static CGFloat const kStoreRouteViewCellX      = 14.0;

static CGFloat const kStoreRouteViewBtn_H      = 18.0;

@interface WSNewRouteTableViewCell ()

/// 背景图
@property(nonatomic,strong)UIView * bgView;

/// 路线日期
@property (nonatomic, strong) UILabel *routeDateLab;

/// 路线查询按钮
@property (nonatomic, strong) WSLargePointBtn *routeSearchBtn;

/// 路线编辑按钮
@property (nonatomic, strong) WSLargePointBtn *routeEditBtn;

/// 路线总数
@property (nonatomic, strong) UILabel *routeCountLab;

/// 审批状态
@property (nonatomic, strong) UILabel *approveLab;

/// 路线执行率
@property (nonatomic, strong) UILabel *routeExcutionPersent;

@end
@implementation WSNewRouteTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = HColorFromHex(0xEFF0F1);
        [self.contentView addSubview:self.bgView];
        [self.bgView addSubview:self.routeDateLab];
//        [self.bgView addSubview:self.routeSearchBtn];
        [self.bgView addSubview:self.routeEditBtn];
        [self.bgView addSubview:self.routeCountLab];
        [self.bgView addSubview:self.approveLab];
        [self.bgView addSubview:self.routeExcutionPersent];
        [self p_addMasonry];
    }
    return self;
}
#pragma mark - # Data 
- (void)setRouteModel:(WSNewRouteModel *)routeModel{
    _routeModel = routeModel;
    if(_routeModel==nil)return;
    self.routeDateLab.text = [NSString stringWithFormat:@"计划拜访日期：%@",ISNULL(_routeModel.docDate)];
    self.routeCountLab.text = [NSString stringWithFormat:@"门店总数：%@",ISNULL(_routeModel.storeNum)];
    if([_routeModel.zxState isEqualToString:@"未执行"]){
        self.routeExcutionPersent.text = [NSString stringWithFormat:@"%@",ISNULL(_routeModel.zxState)];
    }else{
        self.routeExcutionPersent.text = [NSString stringWithFormat:@"%@ %@",ISNULL(_routeModel.zxState),ISNULL(_routeModel.bfRate)];
    }
    self.approveLab.text = [NSString stringWithFormat:@"%@",ISNULL(routeModel.approveState)];
    self.approveLab.textColor = [WSStoreTools getApproveLabColorWithState:ISNULL(_routeModel.approveState)];
}
#pragma mark - # Event Response
- (void)routeSearchBtnTouchUpInside:(WSLargePointBtn *)sender {
//    if(self.clicikAction){
//        self.clicikAction(self.routeModel.docDate, RouteViewBtnType_Search);
//    }
}

- (void)routeEditBtnTouchUpInside:(WSLargePointBtn *)sender {
//    if(self.clicikAction){
//        self.clicikAction(self.routeModel.docDate, RouteViewBtnType_Edit);
//    }
}

#pragma mark - # Private Methods
- (void)p_addMasonry {
    //背景图
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).with.insets(UIEdgeInsetsMake(14.0, 12.0, 0, 12.0));
    }];
    // 路线编辑按钮
    [self.routeEditBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgView.top).offset(kStoreRouteViewCellT);
        make.height.mas_equalTo(kStoreRouteViewBtn_H);
        make.width.mas_equalTo(kStoreRouteViewBtn_H);
        make.right.equalTo(self.bgView.right).offset(-kStoreRouteViewCellX);
    }];
//    // 路线查询按钮
//    [self.routeSearchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(self.routeEditBtn);
//        make.height.mas_equalTo(kStoreRouteViewBtn_H);
//        make.width.mas_equalTo(kStoreRouteViewBtn_H);
//        make.right.equalTo(self.routeEditBtn.mas_left).offset(-kStoreRouteViewCellX);
//    }];
    // 路线日期
    [self.routeDateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.routeEditBtn);
        make.height.mas_equalTo(kStoreRouteViewBtn_H);
        make.left.equalTo(self.bgView.mas_left).offset(kStoreRouteViewCellT);
        make.right.equalTo(self.routeEditBtn.mas_left).offset(-kStoreRouteViewCellX);
    }];
   
    // 路线总数
    [self.routeCountLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kStoreRouteViewBtn_H);
        make.left.equalTo(self.bgView.mas_left).offset(kStoreRouteViewCellT);
        make.right.equalTo(self.routeExcutionPersent.mas_left).offset(-kStoreRouteViewCellX);
        make.top.equalTo(self.routeEditBtn.mas_bottom).offset(kStoreRouteViewCellX);
    }];
    // 审批状态
    [self.approveLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView.mas_left).offset(kStoreRouteViewCellT);
        make.top.equalTo(self.routeCountLab.mas_bottom).offset(kStoreRouteViewCellX);
        make.height.mas_equalTo(kStoreRouteViewBtn_H);
        make.width.mas_equalTo(kStoreRouteViewCellX * 10);
        make.bottom.equalTo(self.bgView.mas_bottom).offset(-kStoreRouteViewCellT);
    }];
    // 路线执行率
    [self.routeExcutionPersent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.approveLab);
        make.height.mas_equalTo(kStoreRouteViewBtn_H);
        make.width.mas_equalTo(kStoreRouteViewCellX * 8);
        make.right.equalTo(self.bgView.right).offset(-kStoreRouteViewCellX);
    }];
}

#pragma mark - # Getter
- (UILabel *)routeDateLab {
    if (!_routeDateLab) {
        _routeDateLab = [[UILabel alloc] init];
        _routeDateLab.font = [UIFont systemFontOfSize:14.0];
        _routeDateLab.textColor = HColorFromHex(0x333333);
    }
    return _routeDateLab;
}

- (WSLargePointBtn *)routeSearchBtn {
    if (!_routeSearchBtn) {
        _routeSearchBtn = [[WSLargePointBtn alloc] init];
        [_routeSearchBtn addTarget:self action:@selector(routeSearchBtnTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [_routeSearchBtn setBackgroundImage:[UIImage imageNamed:@"route_search"] forState:UIControlStateNormal];

    }
    return _routeSearchBtn;
}

- (WSLargePointBtn *)routeEditBtn {
    if (!_routeEditBtn) {
        _routeEditBtn = [[WSLargePointBtn alloc] init];
        [_routeEditBtn addTarget:self action:@selector(routeEditBtnTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [_routeEditBtn setBackgroundImage:[UIImage imageNamed:@"route_edit"] forState:UIControlStateNormal];

    }
    return _routeEditBtn;
}

- (UILabel *)routeCountLab {
    if (!_routeCountLab) {
        _routeCountLab = [[UILabel alloc] init];
        _routeCountLab.font = [UIFont systemFontOfSize:14.0];
        _routeCountLab.textColor = HColorFromHex(0x7F7F7F);
    }
    return _routeCountLab;
}

- (UILabel *)routeExcutionPersent {
    if (!_routeExcutionPersent) {
        _routeExcutionPersent = [[UILabel alloc] init];
        _routeExcutionPersent.font = [UIFont systemFontOfSize:12.0];
        _routeExcutionPersent.textColor = HColorFromHex(0x28A707);
        _routeExcutionPersent.textAlignment = NSTextAlignmentRight;
    }
    return _routeExcutionPersent;
}
- (UILabel *)approveLab{
    if(!_approveLab){
        _approveLab = [[UILabel alloc]init];
        _approveLab.font = [UIFont systemFontOfSize:16.0];
        _approveLab.textColor = HColorFromHex(0xEFF0F1);
    }
    return _approveLab;
}

- (UIView*)bgView{
    if(!_bgView){
        _bgView = [[UIView alloc]initWithFrame:CGRectZero];
        _bgView.backgroundColor = HColorFromHex(0xFFFFFF);
        _bgView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.12].CGColor;
        _bgView.layer.shadowOffset = CGSizeMake(0,0);
        _bgView.layer.shadowRadius = 8;
        _bgView.layer.shadowOpacity = 1;
    }
    return _bgView;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

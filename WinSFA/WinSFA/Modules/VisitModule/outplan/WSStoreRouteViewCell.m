//
//  WSStoreRouteViewCell.m
//  WinSFA
//
//  Created by 董宏 on 2019/12/9.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import "WSStoreRouteViewCell.h"
#import "WSStoreRouteDataModel.h"
#import "WSRouteSetHeadView.h"
#import "WSStoreTools.h"
//==========================================================================================================================================

#pragma mark - 门店路线单元格 延展(内部)
@interface WSStoreRouteViewCell ()

@property (nonatomic, strong) UIView *bgView;                   //背景视图
@property (nonatomic, strong) WSRouteSetHeadView *nameHeadView; //名称头视图
@property (nonatomic, strong) UILabel *rtotalLabel;             //客户总数标签
@property (nonatomic, strong) UILabel *estTimeLabel;            //预计总在途时间标签
@property (nonatomic, strong) UILabel *inTimeLabel;             //总在店时间标签
@property (nonatomic, strong) UILabel *effDateLabel;            //执行日期标签
@property (nonatomic, strong) UILabel *effPlanDateLabel;        //计划执行日期标签
@property (nonatomic, strong) UIButton *planBtn;                //今日路线按键
@property (nonatomic, strong) UILabel *approveLab;              //申请状态标签
@property (nonatomic, strong) UILabel *stateLabel;              //计划状态标签
@property (nonatomic, strong) WSStoreRouteDataInfoModel *model; //数据模型

@end
//==========================================================================================================================================

#pragma mark - 门店路线单元格
@implementation WSStoreRouteViewCell

#pragma mark - 重写initWithStyle:reuseIdentifier:方法
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setBackgroundColor:[UIColor whiteColor]];
        [self addControls];
    }
    return self;
}

#pragma mark - 获取bgView方法
- (UIView *)bgView {
    
    if (!_bgView) {
        
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgView.backgroundColor = UIColor.whiteColor;
        _bgView.layer.shadowColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.12f].CGColor;
        _bgView.layer.shadowOffset = CGSizeMake(0, 0);
        _bgView.layer.shadowRadius = 8.0f;
        _bgView.layer.shadowOpacity = 1.0f;
    }
    return _bgView;
}

#pragma mark - 获取nameHeadView方法
- (WSRouteSetHeadView *)nameHeadView {
    
    if (!_nameHeadView) {
        
        _nameHeadView = [[WSRouteSetHeadView alloc] init];
        
        __weak typeof(self) weakSelf = self;
        _nameHeadView.routeHeadClickAction = ^(WinRouteCellHeaderClickType clickType) {
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            if (clickType == WinRouteCellHeaderClickTypeRevoke) {
                
                if (strongSelf.revokeActionBlock) {
                    strongSelf.revokeActionBlock(strongSelf.model.routeId);
                }
            }
            else if (clickType == WinRouteCellHeaderClickTypeDelete) {
                
                if (strongSelf.delegateActionBlock) {
                    strongSelf.delegateActionBlock(strongSelf.model.routeId);
                }
            }
            else if (clickType == WinRouteCellHeaderClickTypeEdit) {
                
                if (strongSelf.editActionBlock) {
                    strongSelf.editActionBlock(strongSelf.model.routeId);
                }
            }
            else if (clickType == WinRouteCellHeaderClickTypeExecute) {
                
                if (strongSelf.executeActionBlock) {
                    strongSelf.executeActionBlock(strongSelf.model.routeId);
                }
            }
        };
    }
    return _nameHeadView;
}

#pragma mark - 获取rtotalLabel方法
- (UILabel *)rtotalLabel {
    
    if (!_rtotalLabel) {
        
        _rtotalLabel = [[UILabel alloc] init];
        _rtotalLabel.backgroundColor = [UIColor clearColor];
        _rtotalLabel.font = [UIFont systemFontOfSize:15.0f];
        _rtotalLabel.textColor = [UIColor colorWithHexString:@"7F7F7F"];
    }
    return _rtotalLabel;
}

#pragma mark - 获取estTimeLabel方法
- (UILabel *)estTimeLabel {
    
    if (!_estTimeLabel) {
        
        _estTimeLabel = [[UILabel alloc] init];
        _estTimeLabel.backgroundColor = [UIColor clearColor];
        _estTimeLabel.font = [UIFont systemFontOfSize:15.0f];
        _estTimeLabel.textColor = [UIColor colorWithHexString:@"7F7F7F"];
    }
    return _estTimeLabel;
}

#pragma mark - 获取inTimeLabel方法
- (UILabel *)inTimeLabel {
    
    if (!_inTimeLabel) {
        
        _inTimeLabel = [[UILabel alloc] init];
        _inTimeLabel.backgroundColor = [UIColor clearColor];
        _inTimeLabel.font = [UIFont systemFontOfSize:15.0f];
        _inTimeLabel.textColor = [UIColor colorWithHexString:@"7F7F7F"];
    }
    return _inTimeLabel;
}

#pragma mark - 获取effDateLabel方法
- (UILabel *)effDateLabel {
    
    if (!_effDateLabel) {
        
        _effDateLabel = [[UILabel alloc] init];
        _effDateLabel.backgroundColor = [UIColor clearColor];
        _effDateLabel.font = [UIFont systemFontOfSize:15.0f];
        _effDateLabel.textColor = [UIColor colorWithHexString:@"7F7F7F"];
    }
    return _effDateLabel;
}

#pragma mark - 获取effPlanDateLabel方法
- (UILabel *)effPlanDateLabel {
    
    if (!_effPlanDateLabel) {
        
        _effPlanDateLabel = [[UILabel alloc] init];
        _effPlanDateLabel.backgroundColor = [UIColor clearColor];
        _effPlanDateLabel.font = [UIFont systemFontOfSize:15.0f];
        _effPlanDateLabel.textColor = [UIColor colorWithHexString:@"7F7F7F"];
    }
    return _effPlanDateLabel;
}

#pragma mark - 获取planBtn方法
- (UIButton *)planBtn {
    
    if (!_planBtn) {
        
        _planBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_planBtn setTitle:NSLocalizedString(@"route_todayRoute", nil) forState:UIControlStateNormal];
        [_planBtn setTintColor:[UIColor colorWithHexString:@"EB7C24"]];
        _planBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        _planBtn.layer.cornerRadius = 4.0;
        _planBtn.layer.borderColor = [UIColor colorWithHexString:@"EB7C24"].CGColor;
        _planBtn.layer.borderWidth = 1.0f;
        _planBtn.userInteractionEnabled = NO;
    }
    return _planBtn;
}

#pragma mark - 获取approveLab方法
- (UILabel *)approveLab {
    
    if (!_approveLab) {
        
        _approveLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _approveLab.backgroundColor = [UIColor clearColor];
        _approveLab.font = [UIFont systemFontOfSize:15.0];
    }
    return _approveLab;
}

#pragma mark - 获取stateLabel方法
- (UILabel *)stateLabel {
    
    if (!_stateLabel) {
        
        _stateLabel = [[UILabel alloc] init];
        _stateLabel.backgroundColor = [UIColor clearColor];
        _stateLabel.font = [UIFont systemFontOfSize:15.0f];
        _stateLabel.textColor = HColorFromHex(0xEB7C24);
        _stateLabel.textAlignment = NSTextAlignmentRight;
    }
    return _stateLabel;
}

#pragma mark - 添加控件方法
- (void)addControls {
        
    [self.contentView addSubview:self.bgView];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
                
        make.top.equalTo(self.contentView.mas_top).offset(10.0);
        make.left.equalTo(self.contentView.mas_left).offset(10.0);
        make.right.equalTo(self.contentView.mas_right).offset(-10.0);
        make.bottom.equalTo(self.contentView.mas_bottom);
    }];
    
    [self.bgView addSubview:self.nameHeadView];
    [self.bgView addSubview:self.rtotalLabel];
    [self.bgView addSubview:self.estTimeLabel];
    [self.bgView addSubview:self.inTimeLabel];
    [self.bgView addSubview:self.effDateLabel];
    [self.bgView addSubview:self.effPlanDateLabel];
    [self.bgView addSubview:self.planBtn];
    [self.bgView addSubview:self.approveLab];
    [self.bgView addSubview:self.stateLabel];
    
    [self.nameHeadView mas_makeConstraints:^(MASConstraintMaker *make) {
                
        make.top.equalTo(self.bgView.mas_top).offset(0.0);
        make.left.equalTo(self.bgView.mas_left).offset(0.0);
        make.right.equalTo(self.bgView.mas_right).offset(0.0);
    }];
    
    [self.rtotalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                
        make.top.equalTo(self.nameHeadView.mas_bottom).offset(10.0);
        make.left.equalTo(self.bgView.mas_left).offset(10.0);
        make.right.equalTo(self.bgView.mas_right).offset(-10.0);
    }];
    
    [self.estTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                
        make.top.equalTo(self.rtotalLabel.mas_bottom).offset(10.0);
        make.left.equalTo(self.bgView.mas_left).offset(10.0);
        make.right.equalTo(self.bgView.mas_right).offset(-10.0);
    }];
    
    [self.inTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                
        make.top.equalTo(self.estTimeLabel.mas_bottom).offset(10.0);
        make.left.equalTo(self.bgView.mas_left).offset(10.0);
        make.right.equalTo(self.bgView.mas_right).offset(-10.0);
    }];
    
    [self.effDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                
        make.top.equalTo(self.inTimeLabel.mas_bottom).offset(10.0);
        make.left.equalTo(self.bgView.mas_left).offset(10.0);
        make.right.equalTo(self.bgView.mas_right).offset(-10.0);
    }];
    
    [self.effPlanDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                
        make.top.equalTo(self.effDateLabel.mas_bottom).offset(10.0);
        make.left.equalTo(self.bgView.mas_left).offset(10.0);
        make.right.equalTo(self.planBtn.mas_left).offset(-10.0);
    }];
    
    [self.planBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                
        make.top.equalTo(self.effPlanDateLabel.mas_top);
        make.right.equalTo(self.bgView.mas_right).offset(-10.0);
        make.width.mas_equalTo(70.0f);
        make.height.mas_equalTo(20.0f);
    }];
    
    [self.approveLab mas_makeConstraints:^(MASConstraintMaker *make) {
                
        make.top.equalTo(self.effPlanDateLabel.mas_bottom).offset(10.0);
        make.left.equalTo(self.bgView.mas_left).offset(10.0);
        make.right.equalTo(self.stateLabel.mas_left).offset(-10.0);
    }];
    
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                
        make.top.equalTo(self.approveLab.mas_top);
        make.right.equalTo(self.bgView.mas_right).offset(-10.0);
        make.bottom.equalTo(self.bgView.mas_bottom).offset(-10.0);
    }];
}

#pragma mark - 设置信息方法
- (void)setupInfoWithModel:(WSStoreRouteDataInfoModel *)model routeId:(NSString *)routeId isLast:(BOOL)isLast {

    self.model = model;
    
    [self.nameHeadView setupTitleWithText:model.routeName model:model];
    
    self.rtotalLabel.text = [NSString stringWithFormat:@"%@:%ld", NSLocalizedString(@"route_customerNumber", nil), model.rtotal];
    
    if (model.rexecNum > 0) {
        self.estTimeLabel.text = [NSString stringWithFormat:@"%@:%ld%@",
                                  NSLocalizedString(@"route_transitTime", nil), model.estTime, NSLocalizedString(@"route_minute", nil)];
    }
    else {
        self.estTimeLabel.text = [NSString stringWithFormat:@"%@:%ld%@",
                                  NSLocalizedString(@"route_expectedTransitTime", nil), model.estTime, NSLocalizedString(@"route_minute", nil)];
    }
    
    if (model.rexecNum > 0) {
        self.inTimeLabel.text = [NSString stringWithFormat:@"%@:%ld%@",
                                 NSLocalizedString(@"route_inStoreTime", nil), model.inTime, NSLocalizedString(@"route_minute", nil)];
        [self.inTimeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.estTimeLabel.mas_bottom).offset(10.0);
        }];
    }
    else {
        self.inTimeLabel.text = @"";
        [self.inTimeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.estTimeLabel.mas_bottom);
        }];
    }
    
    if (model.effDate) {
        self.effDateLabel.text = [NSString stringWithFormat:@"%@:%@", NSLocalizedString(@"route_executionDate", nil), model.effDate];
    }
    else {
        self.effDateLabel.text = [NSString stringWithFormat:@"%@:%@",
                                  NSLocalizedString(@"route_executionDate", nil), NSLocalizedString(@"route_notSet", nil)];
    }
    
    if (model.effPlanDate) {
        self.effPlanDateLabel.text = [NSString stringWithFormat:@"%@:%@", NSLocalizedString(@"route_planExecutionDate", nil), model.effPlanDate];
    }
    else {
        self.effPlanDateLabel.text = [NSString stringWithFormat:@"%@:%@",
                                      NSLocalizedString(@"route_planExecutionDate", nil), NSLocalizedString(@"route_notSet", nil)];
    }
    
    self.planBtn.hidden = (model.isToday ? NO : YES);
    
    self.approveLab.text = ISNULL(model.approveState);
    self.approveLab.textColor = [WSStoreTools getApproveLabColorWithState:model.approveState];
    
    if (model.rexecNum > 0 || [routeId isEqualToString:model.routeId]) {
        NSString *str = NSLocalizedString(@"route_executed", nil);
        if ([routeId isEqualToString:model.routeId]) {
            str = NSLocalizedString(@"route_progress", nil);
        }
        self.stateLabel.text = [NSString stringWithFormat:@"%@（%ld%@）>", str, model.rexecNum * 100 / (model.rtotal > 0  ? model.rtotal : 1), @"%"];
    }
    else {
        self.stateLabel.text = NSLocalizedString(@"route_unplanned", nil);
    }
    
    if (isLast) {
        
        [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-10.0);
        }];
        
    } else {
        
        [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView.mas_bottom).offset(0.0);
        }];
    }
}

@end
//==========================================================================================================================================

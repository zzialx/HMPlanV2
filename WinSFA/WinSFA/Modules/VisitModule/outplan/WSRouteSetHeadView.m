//
//  WSRouteSetHeadView.m
//  zhuanzhuan
//
//  Created by zziax on 2022/10/24.
//  Copyright © 2022年 ZZUIHelper. All rights reserved.
//

#import "WSRouteSetHeadView.h"
//==========================================================================================================================================

#pragma mark - 路线设定头视图(单元格内头图) 延展(内部)
@interface WSRouteSetHeadView ()

@property (nonatomic, strong) UIView *infoBgView;   //信息背景视图
@property (nonatomic, strong) UILabel *titleLabel;  //标题标签
@property (nonatomic, strong) UIButton *revokeBtn;  //撤销按键
@property (nonatomic, strong) UIButton *deleteBtn;  //删除按键
@property (nonatomic, strong) UIButton *editBtn;    //编辑按键
@property (nonatomic, strong) UIButton *executeBtn; //执行按键

@end
//==========================================================================================================================================

#pragma mark - 路线设定头视图(单元格内头图)
@implementation WSRouteSetHeadView

#pragma mark - 获取infoBgView方法
- (UIView *)infoBgView {
    
    if (!_infoBgView) {
        
        _infoBgView = [[UIView alloc] init];
        _infoBgView.backgroundColor = [UIColor colorWithRed:249.0 / 255.0f green:249.0 / 255.0f blue:249.0 / 255.0f alpha:1.0f];
    }
    
    return _infoBgView;
}

#pragma mark - 获取titleLabel方法
- (UILabel *)titleLabel {
    
    if (!_titleLabel) {
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:15.0f];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.text = NSLocalizedString(@"route_routeTitle", nil);
    }
    
    return _titleLabel;
}

#pragma mark - 获取revokeBtn方法
- (UIButton *)revokeBtn {
    
    if (!_revokeBtn) {
        
        _revokeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _revokeBtn.backgroundColor = [UIColor clearColor];
        [_revokeBtn setBackgroundImage:[UIImage imageNamed:@"route_revoke"] forState:UIControlStateNormal];
        [_revokeBtn addTarget:self action:@selector(revokeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _revokeBtn;
}

#pragma mark - 获取deleteBtn方法
- (UIButton *)deleteBtn {
    
    if (!_deleteBtn) {
        
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBtn.backgroundColor = [UIColor clearColor];
        [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"route_delete"] forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(deleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _deleteBtn;
}

#pragma mark - 获取editBtn方法
- (UIButton *)editBtn {
    
    if (!_editBtn) {
        
        _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _editBtn.backgroundColor = [UIColor clearColor];
        [_editBtn setBackgroundImage:[UIImage imageNamed:@"route_edit"] forState:UIControlStateNormal];
        [_editBtn addTarget:self action:@selector(editBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editBtn;
}

#pragma mark - 获取executeBtn方法
- (UIButton *)executeBtn {
    
    if (!_executeBtn) {
        
        _executeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _executeBtn.backgroundColor = [UIColor clearColor];
        [_executeBtn setBackgroundImage:[UIImage imageNamed:@"route_set"] forState:UIControlStateNormal];
        [_executeBtn addTarget:self action:@selector(executeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _executeBtn;
}

#pragma mark - 重写initWithFrame:方法
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addControls];
    }
    return self;
}

#pragma mark - 添加控件方法
- (void)addControls {
    
    [self addSubview:self.infoBgView];
    [self.infoBgView addSubview:self.titleLabel];
    [self.infoBgView addSubview:self.revokeBtn];
    [self.infoBgView addSubview:self.deleteBtn];
    [self.infoBgView addSubview:self.editBtn];
    [self.infoBgView addSubview:self.executeBtn];
    
    [self.infoBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.mas_top);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(self.mas_bottom);
        make.height.mas_equalTo(44.0f);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.mas_left).offset(10.0f);
        make.centerY.equalTo(self.mas_centerY);
        make.width.mas_lessThanOrEqualTo(180.0f);
    }];
    
    [self.revokeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(self.infoBgView.mas_right).offset(-130.0f);
        make.centerY.equalTo(self.mas_centerY);
        make.width.mas_equalTo(25.0f);
        make.height.mas_equalTo(25.0f);
    }];
    
    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(self.infoBgView.mas_right).offset(-90.0f);
        make.centerY.equalTo(self.mas_centerY);
        make.width.mas_equalTo(25.0f);
        make.height.mas_equalTo(25.0f);
    }];
    
    [self.editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(self.infoBgView.mas_right).offset(-50.0f);
        make.centerY.equalTo(self.mas_centerY);
        make.width.mas_equalTo(25.0f);
        make.height.mas_equalTo(25.0f);
    }];
    
    [self.executeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(self.infoBgView.mas_right).offset(-10.0f);
        make.centerY.equalTo(self.mas_centerY);
        make.width.mas_equalTo(25.0f);
        make.height.mas_equalTo(25.0f);
    }];
}

#pragma mark - 撤销按键响应方法
- (void)revokeBtnClick:(id)sender {
    
    if (self.routeHeadClickAction) {
        self.routeHeadClickAction(WinRouteCellHeaderClickTypeRevoke);
    }
}

#pragma mark - 删除按键响应方法
- (void)deleteBtnClick:(id)sender {
    
    if (self.routeHeadClickAction) {
        self.routeHeadClickAction(WinRouteCellHeaderClickTypeDelete);
    }
}

#pragma mark - 编辑按键响应方法
- (void)editBtnClick:(id)sender {
    
    if (self.routeHeadClickAction) {
        self.routeHeadClickAction(WinRouteCellHeaderClickTypeEdit);
    }
}

#pragma mark - 执行按键响应方法
- (void)executeBtnClick:(id)sender {
    
    if (self.routeHeadClickAction) {
        self.routeHeadClickAction(WinRouteCellHeaderClickTypeExecute);
    }
}

#pragma mark - 设置方法
- (void)setupTitleWithText:(NSString *)text model:(WSStoreRouteDataInfoModel *)model {
    
    CGFloat offX = -10.0f;
    
    self.titleLabel.text = ((text.length == 0) ? NSLocalizedString(@"route_routeTitle", nil) : text);
    
    self.executeBtn.hidden = ([model.approveState isEqualToString:@"审批中"] ? YES : NO);
    offX = ([model.approveState isEqualToString:@"审批中"] ? -10.0f : -50.0f);
    
    [self.editBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.infoBgView.mas_right).offset(offX);
    }];
    offX = (offX == -10 ? -50.0f : -90.0f);
    
    self.deleteBtn.hidden = (model.isHidenDel == 1 ? YES : NO);
    if (model.isHidenDel == 1) {
        offX = offX;
    }
    else {
        
        [self.deleteBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.infoBgView.mas_right).offset(offX);
        }];
        offX = (offX == -50 ? -90.0f : -130.0f);
    }
    
    self.revokeBtn.hidden = ([model.approveState isEqualToString:@"审批中"] ? NO : YES);
    [self.revokeBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.infoBgView.mas_right).offset(offX);
    }];
}

@end
//==========================================================================================================================================

//
//  WSStoreRouteViewHeaderView.m
//  WinSFA
//
//  Created by 董宏 on 2019/12/9.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import "WSStoreRouteViewHeaderView.h"
#import "WSStoreRouteDataModel.h"
//==========================================================================================================================================

#pragma mark - 门店线路头部视图 延展(内部)
@interface WSStoreRouteViewHeaderView ()

@property (nonatomic, strong) UIView *infoBgView;       //信息背景视图
@property (nonatomic, strong) UILabel *allLabel;        //路线总标签
@property (nonatomic, strong) UILabel *runLabel;        //已执行路线标签
@property (nonatomic, strong) UILabel *unRunLabel;      //未执行路线标签
@property (nonatomic, strong) UIButton *searchBtn;      //搜索按键
@property (nonatomic, strong) UIView *interactiveBgView;//交互背景视图
@property (nonatomic, strong) UIButton *addBtn;         //新增按键
@property (nonatomic, strong) UIButton *modifyBtn;      //修改按键

@end
//==========================================================================================================================================

#pragma mark - 门店线路头部视图
@implementation WSStoreRouteViewHeaderView

#pragma mark - 获取infoBgView方法
- (UIView *)infoBgView {
    
    if (!_infoBgView) {
        
        _infoBgView = [[UIView alloc] init];
        _infoBgView.backgroundColor = [UIColor colorWithRed:240.0 / 255.0f green:252.0 / 255.0f blue:245.0 / 255.0f alpha:1.0f];
    }
    return _infoBgView;
}

#pragma mark - 获取allLabel方法
- (UILabel *)allLabel {
    
    if (!_allLabel) {
        
        _allLabel = [[UILabel alloc] init];
        _allLabel.backgroundColor = [UIColor clearColor];
        _allLabel.font = [UIFont systemFontOfSize:15.0f];
        _allLabel.textColor = [UIColor blackColor];
        _allLabel.text = NSLocalizedString(@"route_routeAll", nil);
    }
    return _allLabel;
}

#pragma mark - 获取runLabel方法
- (UILabel *)runLabel {
    
    if (!_runLabel) {
        
        _runLabel = [[UILabel alloc] init];
        _runLabel.backgroundColor = [UIColor clearColor];
        _runLabel.font = [UIFont systemFontOfSize:13.0f];
        _runLabel.textColor = [UIColor colorWithRed:40.0 / 255.0f green:167.0 / 255.0f blue:7.0 / 255.0f alpha:1.0f];
        _runLabel.text = NSLocalizedString(@"route_routeRun", nil);
    }
    return _runLabel;
}

#pragma mark - 获取unRunLabel方法
- (UILabel *)unRunLabel {
    
    if (!_unRunLabel) {
        
        _unRunLabel = [[UILabel alloc] init];
        _unRunLabel.backgroundColor = [UIColor clearColor];
        _unRunLabel.font = [UIFont systemFontOfSize:13.0f];
        _unRunLabel.textColor = [UIColor colorWithRed:40.0 / 255.0f green:167.0 / 255.0f blue:7.0 / 255.0f alpha:1.0f];
        _unRunLabel.text = NSLocalizedString(@"route_routeUnRun", nil);
    }
    return _unRunLabel;
}

#pragma mark - 重写searchBtn方法
- (UIButton *)searchBtn {
    
    if (!_searchBtn) {
        
        _searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _searchBtn.backgroundColor = [UIColor clearColor];
        [_searchBtn setBackgroundImage:[UIImage imageNamed:@"route_search"] forState:UIControlStateNormal];
        [_searchBtn addTarget:self action:@selector(searchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _searchBtn;
}

#pragma mark - 获取interactiveBgView方法
- (UIView *)interactiveBgView {
    
    if (!_interactiveBgView) {
        
        _interactiveBgView = [[UIView alloc] init];
        _interactiveBgView.backgroundColor = [UIColor colorWithRed:239.0 / 255.0f green:239.0 / 255.0f blue:239.0 / 255.0f alpha:1.0f];
    }
    return _interactiveBgView;
}

#pragma mark - 重写addBtn方法
- (UIButton *)addBtn {
    
    if (!_addBtn) {
        
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addBtn.backgroundColor = [UIColor colorWithRed:50.0 / 255.0f green:234.0 / 255.0f blue:2.0 / 255.0f alpha:1.0f];
        _addBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [_addBtn setTitle:NSLocalizedString(@"route_addRoute", nil) forState:UIControlStateNormal];
        [_addBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_addBtn setContentEdgeInsets:UIEdgeInsetsMake(5, 10, 5, 10)];
        [_addBtn addTarget:self action:@selector(addBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addBtn;
}

#pragma mark - 重写modifyBtn方法
- (UIButton *)modifyBtn {
    
    if (!_modifyBtn) {
        
        _modifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _modifyBtn.backgroundColor = [UIColor colorWithRed:50.0 / 255.0f green:234.0 / 255.0f blue:2.0 / 255.0f alpha:1.0f];
        _modifyBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [_modifyBtn setTitle:NSLocalizedString(@"route_batchModify", nil) forState:UIControlStateNormal];
        [_modifyBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_modifyBtn setContentEdgeInsets:UIEdgeInsetsMake(5, 10, 5, 10)];
        [_modifyBtn addTarget:self action:@selector(modifyBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _modifyBtn;
}

#pragma mark - 重写initWithFrame方法
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
            
        [self addControls];
    }
    return self;
}

#pragma mark - 添加控件方法
- (void)addControls {
    
    [self addSubview:self.infoBgView];
    [self addSubview:self.interactiveBgView];
    
    [self.infoBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.mas_top);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.height.mas_equalTo(44.0f);
    }];
    
    [self.interactiveBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.infoBgView.mas_bottom);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(self.mas_bottom);
        make.height.mas_equalTo(44.0f);
    }];
    
    [self.infoBgView addSubview:self.allLabel];
    [self.infoBgView addSubview:self.runLabel];
    [self.infoBgView addSubview:self.unRunLabel];
    [self.infoBgView addSubview:self.searchBtn];
    
    [self.allLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.infoBgView.mas_left).offset(10.0f);
        make.top.equalTo(self.infoBgView.mas_top);
        make.height.equalTo(self.infoBgView.mas_height);
    }];
    
    [self.runLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(self.unRunLabel.mas_left).offset(-10.0f);
        make.top.equalTo(self.infoBgView.mas_top);
        make.height.equalTo(self.infoBgView.mas_height);
    }];
    
    [self.unRunLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(self.searchBtn.mas_left).offset(-15.0f);
        make.top.equalTo(self.infoBgView.mas_top);
        make.height.equalTo(self.infoBgView.mas_height);
    }];
    
    [self.searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(self.infoBgView.mas_right).offset(-10.0f);
        make.centerY.equalTo(self.infoBgView.mas_centerY);
        make.width.mas_equalTo(25.0f);
        make.height.mas_equalTo(25.0f);
    }];
    
    [self.interactiveBgView addSubview:self.addBtn];
    [self.interactiveBgView addSubview:self.modifyBtn];
    
    [self.addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(self.modifyBtn.mas_left).offset(-10.0f);
        make.centerY.equalTo(self.interactiveBgView.mas_centerY);
    }];
    
    [self.modifyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(self.interactiveBgView.mas_right).offset(-10.0f);
        make.centerY.equalTo(self.interactiveBgView.mas_centerY);
    }];
}

#pragma mark - 设置信息方法
- (void)setInfoWithData:(WSStoreRouteDataModel *)dataModel {

    self.allLabel.text = [NSString stringWithFormat:@"%@:%ld", NSLocalizedString(@"route_routeAll", nil), dataModel.total];
    self.runLabel.text = [NSString stringWithFormat:@"%@:%ld", NSLocalizedString(@"route_routeRun", nil), dataModel.execNum];
    self.unRunLabel.text = [NSString stringWithFormat:@"%@:%ld", NSLocalizedString(@"route_routeUnRun", nil), dataModel.unExecNum];
}

#pragma mark - 搜索按键响应方法
- (void)searchBtnClick:(id)sender {
    
    if (self.storeRouteHeaderClick) {
        self.storeRouteHeaderClick(WinStoreRouteHeaderClickTypeSearch);
    }
}

#pragma mark - 添加按键响应方法
- (void)addBtnClick:(id)sender {
    
    if (self.storeRouteHeaderClick) {
        self.storeRouteHeaderClick(WinStoreRouteHeaderClickTypeAdd);
    }
}

#pragma mark - 修改按键响应方法
- (void)modifyBtnClick:(id)sender {
    
    if (self.storeRouteHeaderClick) {
        self.storeRouteHeaderClick(WinStoreRouteHeaderClickTypeModify);
    }
}

@end
//==========================================================================================================================================


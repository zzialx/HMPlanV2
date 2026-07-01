//
//  WSHelpSalesAlertView.m
//  WinSFA
//
//  Created by zzialx on 2025/5/7.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#import "WSHelpSalesAlertView.h"

static BOOL isHelpSalesViewAdded = NO;


@interface WSHelpSalesAlertView ()

@property (nonatomic,strong)WSHelpSalesViewConfig * allConfig ;

@property (nonatomic,strong)UIView * backGroundView;

@property (nonatomic,strong)UIView * contentBackGroundView;

@property (nonatomic,strong)UIButton * visitBtn;///拜访按钮

@property (nonatomic,strong)UIButton * helpSalesBtn;///助销

@property (nonatomic,strong)UIButton * confirmBtn;///确认

@property (nonatomic,copy)WSHelpSalesAlertViewCallBack callBack;

@property (nonatomic,copy)WSHelpSalesTipsCallBack tipsCallBack;

@end

@implementation WSHelpSalesAlertView

- (instancetype)initWithConfig:(WSHelpSalesViewConfig *)config{
    
    if (self = [super init]) {
    
        _allConfig = config ;
        [self creatUI];
        [self updateSubViewSelectState];
    }
    return self ;
}
- (void)creatUI{
    
    [self backGroundView];
    [self contentBackGroundView];
    [self visitBtn];
    [self helpSalesBtn];
    [self confirmBtn];
    [self addTapGesture];
}
- (void)addTapGesture{
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGesture.numberOfTapsRequired = 1;
    [self.backGroundView addGestureRecognizer:tapGesture];
}
- (void)handleTap:(UITapGestureRecognizer *)gesture {
    
    [WSHelpSalesAlertView hiddenEmptyView:self];
    
    [WSHelpSalesAlertView release:self];

}
- (void)updateSubViewSelectState{
    if (self.allConfig.defaultConfig&&[self.allConfig.defaultConfig isEqualToString:@"助销"]) {
        self.helpSalesBtn.selected = YES;
        self.visitBtn.selected = NO;
    }if (self.allConfig.defaultConfig&&[self.allConfig.defaultConfig isEqualToString:@"拜访"]) {
        self.visitBtn.selected = YES;
        self.helpSalesBtn.selected = NO;
    }
}
#pragma mark - # Public Method
- (void)showView{
    
    self.backgroundColor = self.allConfig.bgColor;
    [UIView animateWithDuration:0.3 animations:^{
    }] ;
    
}
- (void)visitAction:(UIButton*)sender{
    
    if (!self.allConfig.isCanSelectVisitModule) {
        LogError(@"不能拜访,当前门店正在助销");
        if (self.tipsCallBack) {
            self.tipsCallBack(WSHelpSalesTipsType_HelpSales);
        }
        return;
    }
    sender.selected = !sender.selected;
    self.helpSalesBtn.selected = NO;
}
- (void)helpSalesAction:(UIButton*)sender{
    if (!self.allConfig.isCanSelectHelpSalesModule) {
        LogError(@"不能助销，当前门店正在拜访");
        if (self.tipsCallBack) {
            self.tipsCallBack(WSHelpSalesTipsType_Visit);
        }
        return;
    }
    sender.selected = !sender.selected;
    self.visitBtn.selected = NO;
}
- (void)confirmAction:(UIButton*)sender{
    
    [WSHelpSalesAlertView hiddenEmptyView:self];
    
    if (self.visitBtn.selected) {
        if (self.callBack) {
            self.callBack(WSHelpSalesAlertButtonType_Visit);
        }
    }else if (self.helpSalesBtn.selected){
        if (self.callBack) {
            self.callBack(WSHelpSalesAlertButtonType_HelpSales);
        }
    }else{
        [SVProgressHUD showHudMsg:@"请点击选项"];
    }
    
    [WSHelpSalesAlertView release:self];
}
#pragma mark - # Load lazy
- (UIView*)backGroundView{
    if (!_backGroundView) {
        _backGroundView = [[UIView alloc]init];
        [self addSubview:_backGroundView];
        [_backGroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f));
        }];
        _backGroundView.backgroundColor = UIColor.blackColor;
        _backGroundView.alpha = 0.5;

    }
    return _backGroundView;
}
- (UIView*)contentBackGroundView{
    if (!_contentBackGroundView) {
        _contentBackGroundView = [[UIView alloc]init];
        [self addSubview:_contentBackGroundView];
        [_contentBackGroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.centerY.equalTo(self.mas_centerY);
            make.width.equalTo(self).multipliedBy(0.8);
            make.height.mas_equalTo(kContentBG_H);
        }];
        _contentBackGroundView.backgroundColor = UIColor.whiteColor;
        _contentBackGroundView.layer.cornerRadius = 5.0;
        _contentBackGroundView.clipsToBounds = YES;
    }
    return _contentBackGroundView;
}
- (UIButton*)visitBtn{
    if (!_visitBtn) {
        _visitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentBackGroundView addSubview:_visitBtn];
        [_visitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentBackGroundView.mas_top).offset(kPadLR);
            make.left.equalTo(self.contentBackGroundView.mas_left).offset(kPadLR);
            make.right.equalTo(self.contentBackGroundView.mas_right).offset(-kPadLR);
            make.height.mas_equalTo(kVisit_H);
        }];
        [_visitBtn setBackgroundImage:[UIImage imageNamed:@"ic_visit_unselect"] forState:UIControlStateNormal];
        [_visitBtn setBackgroundImage:[UIImage imageNamed:@"ic_visit_unselect"] forState:UIControlStateHighlighted];
        [_visitBtn setBackgroundImage:[UIImage imageNamed:@"ic_visit_select"] forState:UIControlStateSelected];
        [_visitBtn addTarget:self action:@selector(visitAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _visitBtn;
}
- (UIButton*)helpSalesBtn{
    if (!_helpSalesBtn) {
        _helpSalesBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentBackGroundView addSubview:_helpSalesBtn];
        [_helpSalesBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.visitBtn.mas_bottom).offset(kPadLR);
            make.left.equalTo(self.contentBackGroundView.mas_left).offset(kPadLR);
            make.right.equalTo(self.contentBackGroundView.mas_right).offset(-kPadLR);
            make.height.mas_equalTo(kVisit_H);
        }];
        [_helpSalesBtn setBackgroundImage:[UIImage imageNamed:@"ic_help_unselect"] forState:UIControlStateNormal];
        [_helpSalesBtn setBackgroundImage:[UIImage imageNamed:@"ic_help_unselect"] forState:UIControlStateHighlighted];
        [_helpSalesBtn setBackgroundImage:[UIImage imageNamed:@"ic_help_select"] forState:UIControlStateSelected];
        [_helpSalesBtn addTarget:self action:@selector(helpSalesAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _helpSalesBtn;
}

- (UIButton*)confirmBtn{
    if (!_confirmBtn) {
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentBackGroundView addSubview:_confirmBtn];
        [_confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentBackGroundView.mas_bottom).offset(-kPadLR);
            make.left.equalTo(self.contentBackGroundView.mas_left).offset(kPadLR);
            make.right.equalTo(self.contentBackGroundView.mas_right).offset(-kPadLR);
            make.height.mas_equalTo(kConfirmBTN_H);
        }];
        [_confirmBtn setBackgroundImage:[UIImage imageNamed:@"ic_confirm"] forState:UIControlStateNormal];
        [_confirmBtn addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmBtn;
}
#pragma mark - # 类方法
#pragma mark - # 显示弹框
+ (WSHelpSalesAlertView *)showHelpSalesViewInView:(UIView *)superview
                            config:(WSHelpSalesViewConfig *(^)(void))config
                                 callback:(WSHelpSalesAlertViewCallBack)callback tipsCallBack:(WSHelpSalesTipsCallBack)tipsBack{
    if (isHelpSalesViewAdded) {
        return nil;
    }
    WSHelpSalesViewConfig * emptyConfig = config();
    WSHelpSalesAlertView * helpSalesView = [[WSHelpSalesAlertView alloc]initWithConfig:emptyConfig];
    helpSalesView.callBack  = callback;
    helpSalesView.tipsCallBack = tipsBack;
    [superview addSubview:helpSalesView] ;
    
    [helpSalesView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(superview).with.insets(UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f));
    }];
    
    [helpSalesView showView];
    isHelpSalesViewAdded = YES;
    return helpSalesView ;
}
+ (void)hiddenEmptyView:(WSHelpSalesAlertView *)emptyView{
    
    [UIView animateWithDuration:.3 animations:^{
        emptyView.alpha = 0.2 ;
    } completion:^(BOOL finished) {
        [emptyView removeFromSuperview];
    }] ;
}

+ (void)release:(WSHelpSalesAlertView *)emptyView{
    emptyView = nil;
    isHelpSalesViewAdded = NO;
}

@end

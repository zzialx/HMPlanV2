//
//  WinStockOutPopupView.m
//  WinSFA
//
//  Created by zzialx on 2025/7/30.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#import "WinStockOutPopupView.h"
#import "WSInventoruHeader.h"
#import "WinStockOutTableViewCell.h"
#import "WSInventoryModel.h"


@interface WinStockOutPopupView ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) WinStockOutPopupConfig *config;

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *titleLine;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIView * dividerView;


@end

static  NSString * const kWinStockOutTableViewCellCellIdentifier  = @"WinStockOutTableViewCell";

static WinStockOutPopupView *_sharedPopupView = nil;


@implementation WinStockOutPopupView

+ (void)showStockOutPopupViewWithConfig:(WinStockOutPopupConfig *)config {
    [self dismiss];
    
    _sharedPopupView = [[WinStockOutPopupView alloc] initWithConfig:config];
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (!keyWindow) {
        keyWindow = [UIApplication sharedApplication].windows.firstObject;
    }
    
    [keyWindow addSubview:_sharedPopupView];
    [_sharedPopupView showAnimation];
}

+ (void)dismiss {
    if (_sharedPopupView) {
        [_sharedPopupView dismissAnimation];
    }
}

#pragma mark - 初始化

- (instancetype)initWithConfig:(WinStockOutPopupConfig *)config {
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:screenBounds];
    if (self) {
        self.config = config;
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - UI 设置

- (void)setupUI {
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    self.containerView = [[UIView alloc] init];
    self.containerView.backgroundColor = [UIColor whiteColor];
    self.containerView.layer.cornerRadius = 12;
    self.containerView.layer.masksToBounds = YES;
    [self addSubview:self.containerView];
    
    self.titleLine = [[UIView alloc]init];
    self.titleLine.backgroundColor = WIN_RGBCOLOR(49,234,0);
    [self addSubview:self.titleLine];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = self.config.title;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.containerView addSubview:self.titleLabel];
    
    [self setupHeaderView];
    
    [self.containerView addSubview:self.tableView];
        
    self.dividerView = [[UIView alloc]init];
    self.dividerView.backgroundColor = LINE_COLOR;
    [self.containerView addSubview:self.dividerView];
    
    [self setupButtons];
    
   
}

- (void)setupHeaderView {
    self.headerView = [[UIView alloc] init];
    self.headerView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    [self.containerView addSubview:self.headerView];
        
    UILabel *productNameHeaderLabel = [[UILabel alloc] init];
    productNameHeaderLabel.text = @"缺货SKU";
    productNameHeaderLabel.font = HEADER_TITLE_FONT;
    productNameHeaderLabel.textColor = HEADER_TITLE_COLOR;
    productNameHeaderLabel.textAlignment = NSTextAlignmentLeft;
    [self.headerView addSubview:productNameHeaderLabel];
    
    UILabel *stockOutDaysHeaderLabel = [[UILabel alloc] init];
    stockOutDaysHeaderLabel.text = @"连续缺货天数";
    stockOutDaysHeaderLabel.font = HEADER_TITLE_FONT;
    stockOutDaysHeaderLabel.textColor = HEADER_TITLE_COLOR;
    stockOutDaysHeaderLabel.textAlignment = NSTextAlignmentCenter;
    [self.headerView addSubview:stockOutDaysHeaderLabel];

    UIView * line = [[UIView alloc]init];
    line.backgroundColor = WIN_RGBCOLOR(49,234,0);
    [self.headerView addSubview:line];

    [stockOutDaysHeaderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.headerView.mas_right).offset(-PAD_P_LR);
        make.centerY.equalTo(self.headerView);
        make.width.mas_equalTo(STOCK_OUT_DNM_W);
    }];
    
    [productNameHeaderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerView.mas_left).offset(PAD_P_LR);
        make.centerY.equalTo(self.headerView);
        make.right.equalTo(stockOutDaysHeaderLabel.mas_left).offset(-PAD_P_LR);
    }];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.headerView);
        make.height.mas_equalTo(1);
        make.bottom.equalTo(self.headerView.mas_bottom).offset(-1);
    }];
}

- (void)setupButtons {
    
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.confirmButton setTitle:self.config.confirmButtonTitle forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.confirmButton setBackgroundColor:WIN_RGBCOLOR(49,234,0)];
    self.confirmButton.titleLabel.font = [UIFont systemFontOfSize:16];
    self.confirmButton.layer.cornerRadius = 5;
    self.confirmButton.clipsToBounds = YES;
    [self.confirmButton addTarget:self action:@selector(confirmButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.confirmButton];
}

- (void)setupConstraints {
    
    CGFloat width = 0.9 * WIN_SCREEN_WIDTH;
    CGFloat fixedHeight = 255.0f;
    NSInteger count = self.config.otoTableData.count >4?4:self.config.otoTableData.count;
    CGFloat height = count * 50 + fixedHeight;

    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
    }];
    
    [self.titleLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerView).offset(PAD_P_LR);
        make.top.equalTo(self.containerView).offset(PAD_P_TL);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(5);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleLine.mas_centerY);
        make.left.equalTo(self.titleLine.mas_right).offset(PAD_P_LR);
        make.right.equalTo(self.containerView).offset(-PAD_P_LR);
    }];

    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(PAD_P_TL);
        make.left.right.equalTo(self.containerView);
        make.height.mas_equalTo(50);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView.mas_bottom);
        make.left.right.equalTo(self.containerView);
    }];
        
    [self.dividerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tableView.mas_bottom).offset(0);
        make.height.mas_equalTo(0.5);
        make.left.right.equalTo(self.containerView);
    }];
    
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.dividerView.mas_bottom).offset(BTN_PAD_TL);
        make.bottom.equalTo(self.containerView).offset(-BTN_PAD_TL);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(120);
        make.centerX.equalTo(self.containerView.mas_centerX);
    }];
}

#pragma mark - 动画

- (void)showAnimation {
    self.alpha = 0;
    self.containerView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
        self.containerView.transform = CGAffineTransformIdentity;
    }];
}

- (void)dismissAnimation {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
        self.containerView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        _sharedPopupView = nil;
    }];
}

#pragma mark - 按钮事件

- (void)confirmButtonTapped {
    if (self.config.confirmAction) {
        self.config.confirmAction();
    }
    [WinStockOutPopupView dismiss];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.config.otoTableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WinStockOutTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kWinStockOutTableViewCellCellIdentifier forIndexPath:indexPath];
    WSStockOutModel *item = self.config.otoTableData[indexPath.row];
    [cell configureWithItem:item];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableView*)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = [UIColor lightGrayColor];
        _tableView.scrollEnabled = YES;
        _tableView.showsVerticalScrollIndicator = YES;
        _tableView.backgroundColor = [UIColor whiteColor];
        [_tableView registerClass:[WinStockOutTableViewCell class] forCellReuseIdentifier:kWinStockOutTableViewCellCellIdentifier];
    }
    return _tableView;
}


@end

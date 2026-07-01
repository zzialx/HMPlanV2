//
//  WinInventoryPopupView.m
//

#import "WinInventoryPopupView.h"
#import <Masonry/Masonry.h>
#import "WSInventoryModel.h"
#import "WSInventoryTableViewCell.h"
#import "WSInventoruHeader.h"

@interface WinInventoryPopupView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UILabel *subtotalLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIView * dividerView;
@property (nonatomic, strong) UIView * dividerView1;

@property (nonatomic, strong) WinInventoryPopupConfig *config;

@end

static  NSString * const kInventoryPopupViewCellIdentifier  = @"WSInventoryTableViewCell";

static WinInventoryPopupView *_sharedPopupView = nil;

@implementation WinInventoryPopupView

#pragma mark - 类方法

+ (void)showWithConfig:(WinInventoryPopupConfig *)config {
    [self dismiss];
    
    _sharedPopupView = [[WinInventoryPopupView alloc] initWithConfig:config];
    
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

- (instancetype)initWithConfig:(WinInventoryPopupConfig *)config {
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
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = self.config.title;
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.containerView addSubview:self.titleLabel];
    
    self.subtitleLabel = [[UILabel alloc] init];
    self.subtitleLabel.text = self.config.subtitle;
    self.subtitleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.subtitleLabel.textColor = [UIColor blackColor];
    self.subtitleLabel.textAlignment = NSTextAlignmentLeft;
    [self.containerView addSubview:self.subtitleLabel];
    
    [self setupHeaderView];
    
    [self.containerView addSubview:self.tableView];
    
    [self setupFooterView];
    
    self.dividerView1 = [[UIView alloc]init];
    self.dividerView1.backgroundColor = LINE_COLOR;
    [self.containerView addSubview:self.dividerView1];
    
    [self setupButtons];
    
    self.dividerView = [[UIView alloc]init];
    self.dividerView.backgroundColor = LINE_COLOR;
    [self.containerView addSubview:self.dividerView];
}

- (void)setupHeaderView {
    self.headerView = [[UIView alloc] init];
    self.headerView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    [self.containerView addSubview:self.headerView];
    
    UILabel *storeCodeHeaderLabel = [[UILabel alloc] init];
    storeCodeHeaderLabel.text = @"店内码";
    storeCodeHeaderLabel.font = HEADER_TITLE_FONT;
    storeCodeHeaderLabel.textColor = HEADER_TITLE_COLOR;
    storeCodeHeaderLabel.textAlignment = NSTextAlignmentLeft;
    [self.headerView addSubview:storeCodeHeaderLabel];
    
    UILabel *productNameHeaderLabel = [[UILabel alloc] init];
    productNameHeaderLabel.text = @"产品名称";
    productNameHeaderLabel.font = HEADER_TITLE_FONT;
    productNameHeaderLabel.textColor = HEADER_TITLE_COLOR;
    productNameHeaderLabel.textAlignment = NSTextAlignmentLeft;
    [self.headerView addSubview:productNameHeaderLabel];
    
    UILabel *quantityHeaderLabel = [[UILabel alloc] init];
    quantityHeaderLabel.text = @"本次建议数量";
    quantityHeaderLabel.font = HEADER_TITLE_FONT;
    quantityHeaderLabel.textColor = HEADER_TITLE_COLOR;
    quantityHeaderLabel.textAlignment = NSTextAlignmentRight;
    [self.headerView addSubview:quantityHeaderLabel];
    
    UIView * line = [[UIView alloc]init];
    line.backgroundColor = WIN_RGBCOLOR(49,234,0);
    [self.headerView addSubview:line];
    

    [storeCodeHeaderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerView).offset(PAD_P_LR);
        make.centerY.equalTo(self.headerView);
        make.width.mas_equalTo(DNM_W);
    }];
    
    [productNameHeaderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(storeCodeHeaderLabel.mas_right).offset(PAD_P_LR);
        make.centerY.equalTo(self.headerView);
    }];
    
    [quantityHeaderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.headerView).offset(-PAD_P_LR);
        make.centerY.equalTo(self.headerView);
        make.width.mas_equalTo(BCJYSL_W);
        make.left.equalTo(productNameHeaderLabel.mas_right).offset(PAD_P_LR);
    }];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.headerView);
        make.height.mas_equalTo(1);
        make.bottom.equalTo(self.headerView.mas_bottom).offset(-1);
    }];
}

- (void)setupFooterView {
    self.footerView = [[UIView alloc] init];
    self.footerView.backgroundColor = WIN_RGBCOLOR(246.0, 247.0, 251.0);
    [self.containerView addSubview:self.footerView];
    
    // 分割线
    UIView *separatorLine = [[UIView alloc] init];
    separatorLine.backgroundColor = LINE_COLOR;
    [self.footerView addSubview:separatorLine];
    
    UILabel *subtotalTitleLabel = [[UILabel alloc] init];
    subtotalTitleLabel.text = @"小计";
    subtotalTitleLabel.font = [UIFont systemFontOfSize:16];
    subtotalTitleLabel.textColor = [UIColor blackColor];
    [self.footerView addSubview:subtotalTitleLabel];
    
    self.subtotalLabel = [[UILabel alloc] init];
    self.subtotalLabel.text = self.config.subtotalText;
    self.subtotalLabel.font = [UIFont systemFontOfSize:16];
    self.subtotalLabel.textAlignment = NSTextAlignmentCenter;
    self.subtotalLabel.textColor = [UIColor blackColor];
    [self.footerView addSubview:self.subtotalLabel];
    
    [separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.footerView);
        make.height.mas_equalTo(0.5);
    }];
    
    [subtotalTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.footerView).offset(PAD_P_LR);
        make.centerY.equalTo(self.footerView);
    }];
    
    [self.subtotalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.footerView).offset(-PAD_P_LR);
        make.centerY.equalTo(self.footerView);
        make.width.mas_equalTo(BCJYSL_CONTENT_W);
    }];
}

- (void)setupButtons {
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelButton setTitle:self.config.cancelButtonTitle forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.cancelButton];
    
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.confirmButton setTitle:self.config.confirmButtonTitle forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.confirmButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.confirmButton addTarget:self action:@selector(confirmButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.confirmButton];
}

- (void)setupConstraints {
    
    CGFloat width = 0.9 * WIN_SCREEN_WIDTH;
    CGFloat fixedHeight = 255.0f;
    NSInteger count = self.config.tableData.count >4?4:self.config.tableData.count;
    CGFloat height = count * 50 + fixedHeight;

    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView).offset(PAD_P_TL);
        make.left.equalTo(self.containerView).offset(PAD_P_LR);
        make.right.equalTo(self.containerView).offset(-PAD_P_LR);
    }];
    
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(PAD_P_LR);
        make.left.equalTo(self.containerView).offset(PAD_P_LR);
        make.right.equalTo(self.containerView).offset(-PAD_P_LR);
    }];
    
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subtitleLabel.mas_bottom).offset(PAD_P_TL);
        make.left.right.equalTo(self.containerView);
        make.height.mas_equalTo(50);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView.mas_bottom);
        make.left.right.equalTo(self.containerView);
    }];
    
    [self.footerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tableView.mas_bottom);
        make.left.right.equalTo(self.containerView);
        make.height.mas_equalTo(50);
    }];
    [self.dividerView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.footerView.mas_bottom).offset(0);
        make.height.mas_equalTo(0.5);
        make.left.right.equalTo(self.containerView);
    }];
    
    [self.dividerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.footerView.mas_bottom).offset(0);
        make.width.mas_equalTo(0.5);
        make.centerX.equalTo(self.containerView.mas_centerX);
        make.bottom.equalTo(self.containerView).offset(-0);
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.footerView.mas_bottom).offset(BTN_PAD_TL);
        make.left.equalTo(self.containerView.mas_left).offset(BTN_PAD_LR);
        make.right.equalTo(self.dividerView.mas_left).offset(-BTN_PAD_LR);
        make.bottom.equalTo(self.containerView).offset(-BTN_PAD_TL);
        make.height.mas_equalTo(30);
    }];
    
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.footerView.mas_bottom).offset(BTN_PAD_TL);
        make.bottom.equalTo(self.containerView).offset(-BTN_PAD_TL);
        make.height.mas_equalTo(30);
        make.left.equalTo(self.dividerView.mas_right).offset(BTN_PAD_LR);
        make.right.equalTo(self.containerView.mas_right).offset(-BTN_PAD_LR);
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

- (void)cancelButtonTapped {
    if (self.config.cancelAction) {
        self.config.cancelAction();
    }
    [WinInventoryPopupView dismiss];
}

- (void)confirmButtonTapped {
    if (self.config.confirmAction) {
        self.config.confirmAction();
    }
//    [WinInventoryPopupView dismiss];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.config.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WSInventoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kInventoryPopupViewCellIdentifier forIndexPath:indexPath];
    WSInventoryModel *item = self.config.tableData[indexPath.row];
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
        [_tableView registerClass:[WSInventoryTableViewCell class] forCellReuseIdentifier:kInventoryPopupViewCellIdentifier];
    }
    return _tableView;
}


@end



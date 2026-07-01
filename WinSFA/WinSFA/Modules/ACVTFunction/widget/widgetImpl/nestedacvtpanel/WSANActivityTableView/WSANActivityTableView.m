
//
//  WSANActivityTableView.m
//  WinSFA
//
//  Created by zzialx on 2025/5/9.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#import "WSANActivityTableView.h"
#import "WSANActivityTableViewCell.h"
#import "WSANActivityHeadView.h"
#import "UIButton+JKImagePosition.h"
#import "WSANActivityHeader.h"


static NSString * kCellReuseIdentifierId  = @"kCellReuseIdentifierId";

static NSString * kHeaderReuseIdentifierId  = @"kHeaderReuseIdentifierId";

@interface WSANActivityTableView ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)UITableView * tableView;

@property(nonatomic,strong)UIStackView  * footView;

@property(nonatomic,strong)UIButton * addNewAcvtButon;
///数据源
@property(nonatomic,strong)NSMutableArray * dataArray;

@property(nonatomic,copy)addNewActivityBlock addNewActivityBlock;

@property(nonatomic,copy)deleteActivityBlock deleteActivityBlock;

@property(nonatomic,copy)expandActivityHandler expandActivityHandler;


@end

@implementation WSANActivityTableView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = RGBCOLOR(239.0, 240.0, 241.0);
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

- (void)setupUI{
    
    [self tableView];
    
    [self footView];
        
    [self.footView addArrangedSubview:self.addNewAcvtButon];
    
}
- (void)setupConstraints{
    
    [self.addNewAcvtButon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kActivityAddBtnHeight);
        make.centerY.equalTo(self.footView.mas_centerY);
    }];
    
    [self.footView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(0);
        make.right.equalTo(self.mas_right).offset(0);
        make.height.mas_equalTo(kActivityFootererHeight);
        make.bottom.equalTo(self.mas_bottom).offset(-kActivityFootererSpace);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(self.footView.mas_top).offset(-kActivityTableSpace);
        
    }];
    
}
#pragma makr - # TableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return kActivityHeaderHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WSANActivityModel * model = self.dataArray[indexPath.section];
    if (model.isExpand) {
        return model.cellHeight;
    }
    return 0.001;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WSANActivityModel * model = self.dataArray[indexPath.section];
    CGFloat cellHeight = model.cellHeight;
    if (!model.isExpand) {
        cellHeight = kTableCellPad *2;
    }
    WSANActivityTableViewCell * cell = [[WSANActivityTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellReuseIdentifierId];
    cell.containerView.frame = CGRectMake(kTableCellPad, kTableCellPad, self.width-kTableCellPad *2, cellHeight - kTableCellPad *2);
    WCBaseViewController *contentController = model.controller;
    contentController.isNotShowStoreNameLabel = YES;
    contentController.view.frame = CGRectMake(0, 0, self.width - kTableCellPad *2, cellHeight - kTableCellPad *2);
    [cell.containerView addSubview:contentController.view];
    return cell;
}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    WSANActivityHeadView * headerView = [[WSANActivityHeadView alloc]initWithFrame:CGRectMake(0, 0, self.width, kActivityHeaderHeight)];
    WSANActivityModel * model = self.dataArray[section];
    headerView.headModel = model;
    @weakify_self;
    [headerView expandActivityBlock:^(BOOL isSelect) {
        @strongify_self;
        [self p_expandAcvityAction:isSelect inSection:section];
    }];
    [headerView deleteActivityItemBlock:^(void) {
        @strongify_self;
        [self p_deleteAcvityInSection:section];
    }];
    return headerView;
}
#pragma mark - # Response Event
- (void)addAcvtAction:(UIButton*)sender{
    LogInfo(@"新增活动问卷");
    if (self.addNewActivityBlock) {
        self.addNewActivityBlock();
    }
}
#pragma mark - # Private Method
- (void)p_deleteAcvityInSection:(NSInteger)section{
    
    @weakify_self;
    BlockAlertView * alterView = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"确定要删除吗？", nil)];
    
    [alterView setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:nil];
    
    [alterView addButtonWithTitle:NSLocalizedString(@"confirm_label", nil) block:^{
        LogInfo(@"确认删除活动");
        @strongify_self;
        NSIndexPath * deleteIndexPath = [NSIndexPath indexPathForRow:0 inSection:section];
        if (self.deleteActivityBlock) {
            self.deleteActivityBlock(deleteIndexPath);
        }
    }];
    [alterView show];
    
}
- (void)p_expandAcvityAction:(BOOL)isExpand inSection:(NSInteger)section{
    
    if (section>self.dataArray.count) {
        LogError(@"嵌套问卷删除活动数组越界");
        return;
    }
    NSIndexPath * deleteIndexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    if (self.expandActivityHandler) {
        self.expandActivityHandler(deleteIndexPath, isExpand);
    }
}
#pragma mark - # Public Method
- (void)setAcvtVCArray:(NSMutableArray *)acvtVCArray{
    
    _acvtVCArray = acvtVCArray;
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:_acvtVCArray];
    [self.tableView reloadData];
}
#pragma mark - # 添加活动
- (void)addNewANActivityBlock:(addNewActivityBlock)block{
    self.addNewActivityBlock = block;
}
#pragma mark - # 删除活动
- (void)deleteActivityBlock:(deleteActivityBlock)block{
    self.deleteActivityBlock = block;
}
#pragma mark - # 活动展开或者闭合回调
- (void)expandActivityHandler:(expandActivityHandler)block{
    self.expandActivityHandler = block;
}

#pragma mark - # Load Lazy
- (UITableView*)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        [self addSubview:_tableView];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[WSANActivityTableViewCell class] forCellReuseIdentifier:kCellReuseIdentifierId];
        [_tableView registerClass:[WSANActivityHeadView class] forHeaderFooterViewReuseIdentifier:kHeaderReuseIdentifierId];
        _tableView.showsHorizontalScrollIndicator = NO;

    }
    return _tableView;
}
- (UIStackView*)footView{
    if (!_footView) {
        _footView = [[UIStackView alloc] init];
        [self addSubview:_footView];
        _footView.axis = UILayoutConstraintAxisHorizontal;
        _footView.alignment = UIStackViewAlignmentCenter;
        _footView.distribution = UIStackViewDistributionFillEqually;
        _footView.spacing = 20;
        _footView.translatesAutoresizingMaskIntoConstraints = NO;
        if (@available(iOS 14.0, *)) {
            _footView.backgroundColor = UIColor.whiteColor;
        } else {
            UIView *backgroundView = [[UIView alloc] init];
            backgroundView.backgroundColor = [UIColor whiteColor];
            [_footView insertSubview:backgroundView atIndex:0];
            // 设置约束
            [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(_footView);
            }];
            
        }
        [self addSubview:_footView];
    }
    return _footView;
}
- (UIButton*)addNewAcvtButon{
    if(!_addNewAcvtButon){
        _addNewAcvtButon = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addNewAcvtButon setImage:[UIImage imageNamed:@"ic_add_acvt"] forState:UIControlStateNormal];
        [_addNewAcvtButon setTitle:@"添加" forState:UIControlStateNormal];
        [_addNewAcvtButon setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_addNewAcvtButon jk_setImagePosition:LXMImagePositionLeft spacing:5];
        [_addNewAcvtButon addTarget:self action:@selector(addAcvtAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addNewAcvtButon;
}
- (NSMutableArray*)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:100];
    }
    return _dataArray;
}
@end

//
//  WSFuncTipAlertView.m
//  TestDemo
//
//  Created by xq的电脑 on 2023/12/3.
//

#import "WSFuncTipAlertView.h"
#import "WSFuncTipsTableViewCell.h"
#import "WSFuncTipsModel.h"
#import "WSFuncTipsViewModel.h"
//===================================================================================================================

#pragma mark - 菜单提醒视图 延展(内部)
@interface WSFuncTipAlertView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIControl *alphaCoverView;    //透明遮罩图层
@property (nonatomic, strong) UIView *elementBgView;        //元素底图
@property (nonatomic, strong) UILabel *label;               //标签视图
@property (nonatomic, strong) UITableView *tableView;       //表示图
@property (nonatomic, strong) UIButton *confirmButton;      //确认按键

@property (nonatomic, strong) NSString *title;              //标题
@property (nonatomic, strong) NSArray *alertList;           //提醒数组

@end
//===================================================================================================================

#pragma mark - 菜单提醒视图
@implementation WSFuncTipAlertView

#pragma mark - 获取alphaCoverView方法
- (UIControl *)alphaCoverView {
    
    if (!_alphaCoverView) {
        
        _alphaCoverView = [[UIControl alloc] init];
        _alphaCoverView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.6f];
    }
    return _alphaCoverView;
}

#pragma mark - 获取elementBgView方法
- (UIView *)elementBgView {
    
    if (!_elementBgView) {
        
        _elementBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _elementBgView.backgroundColor = [UIColor whiteColor];
        _elementBgView.layer.cornerRadius = 10.0f;
        _elementBgView.layer.masksToBounds = YES;
    }
    return _elementBgView;
}

#pragma mark - 获取label方法
- (UILabel *)label {
    
    if (!_label) {
        
        _label = [[UILabel alloc] init];
        _label.backgroundColor = [UIColor clearColor];
        _label.font = [UIFont boldSystemFontOfSize:17.0f];
        _label.textColor = [UIColor blackColor];
        _label.textAlignment = NSTextAlignmentCenter;
    }
    return _label;
}

#pragma mark - 获取tableView方法
- (UITableView *)tableView {
    
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedSectionFooterHeight = 0.0f;
        _tableView.estimatedSectionHeaderHeight = 0.0f;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
    }
    return _tableView;
}

#pragma mark - 获取confirmButton方法
- (UIButton *)confirmButton {
    
    if (!_confirmButton) {
        
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.backgroundColor = [UIColor whiteColor];
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:kAlertViewButtonTextColor forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(confirmButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

#pragma mark - 创建菜单提醒视图方法
+ (instancetype)creatFuncTipAlertViewWithList:(NSArray *)list title:(NSString *)title {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    WSFuncTipAlertView *funcTipAlertView = [[WSFuncTipAlertView alloc] initWithFrame:rect];
    
    funcTipAlertView.title = title;
    funcTipAlertView.alertList = list;
    
    [funcTipAlertView setupUI];
    [funcTipAlertView setupContent];
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [window addSubview:funcTipAlertView];
    
    return funcTipAlertView;
}

#pragma mark - 关闭菜单提醒视图方法
- (void)closeFuncTipAlertView {

    [self removeFromSuperview];
}

#pragma mark - 设置UI方法
- (void)setupUI {
    
    [self addSubview:self.alphaCoverView];
    [self addSubview:self.elementBgView];
    [self.elementBgView addSubview:self.label];
    [self.elementBgView addSubview:self.tableView];
    [self.elementBgView addSubview:self.confirmButton];
    
    [self.alphaCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
    }];
    
    [self.elementBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY);
        make.left.equalTo(self).offset(40.0f);
        make.right.equalTo(self).offset(-40.0f);
        make.height.mas_equalTo(320.0f);
    }];
    
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.elementBgView.mas_top).offset(10.0f);
        make.left.equalTo(self.elementBgView.mas_left).offset(10.0f);
        make.right.equalTo(self.elementBgView.mas_right).offset(-10.0f);
        make.height.mas_equalTo(20.0f);
    }];
    
    CGFloat tableViewHeight = ((self.alertList.count > 5) ? 5 * 44.0f : self.alertList.count * 44.0f);
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            
        make.top.equalTo(self.label.mas_bottom).offset(20.0f);
        make.left.equalTo(self.elementBgView.mas_left).offset(10.0f);
        make.right.equalTo(self.elementBgView.mas_right).offset(-10.0f);
        make.height.mas_equalTo(tableViewHeight);
    }];
    
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            
        make.left.equalTo(self.elementBgView.mas_left).offset(10.0f);
        make.right.equalTo(self.elementBgView.mas_right).offset(-10.0f);
        make.height.mas_equalTo(20.0f);
        make.bottom.equalTo(self.elementBgView.mas_bottom).offset(-10.0f);
    }];
}

#pragma mark - 设置内容方法
- (void)setupContent {
    
    self.label.text = self.title;
    [self.tableView reloadData];
}

#pragma mark - 确认按键响应方法
- (void)confirmButtonClick:(id)sender {
    
    if (self.completeBlock) {
        self.completeBlock(self);
    }
}

#pragma mark - 实现tableView:numberOfRowsInSection:协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.alertList.count;
}

#pragma mark - 实现tableView:heightForRowAtIndexPath:协议
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 44.0f;
}

#pragma mark - 实现tableView:cellForRowAtIndexPath:协议
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *funcTipsTableViewCelldentifier = @"funcTipsTableViewCelldentifier";
    WSFuncTipsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:funcTipsTableViewCelldentifier];
    if (!cell) {
        
        cell = [[WSFuncTipsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:funcTipsTableViewCelldentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    WSFuncTipsModel *model = self.alertList[indexPath.row];
    cell.funcNameLab.text = [NSString stringWithFormat:@"%@:", model.name];
    cell.passLab.text = (model.passNum.length == 0 ? @"" : model.passNum);
    cell.refuseLab.text = (model.refuseNum.length == 0 ? @"" : model.refuseNum);
    
    return cell;
}

@end
//===================================================================================================================

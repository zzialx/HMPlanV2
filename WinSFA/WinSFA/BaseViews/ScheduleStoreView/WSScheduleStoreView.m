//
//  WSScheduleStoreView.m
//  WinSFA
//
//  Created by zzialx on 2022/10/20.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import "WSScheduleStoreView.h"
#import "WSScheduleStoreTableViewCell.h"
#import "WSScheduleHeadView.h"
#import "WSAttanceInfoView.h"
#import <Masonry.h>
#import "WSAttanceViewModel.h"
#import "NSDate+Formatter.h"

#define PADING              0.0f
#define PADING_LEFT         10.0f
#define CELL_HEIGHT         40.0f
#define SMALLLTITLE_W       170.0f
#define SMALLLTITLE_H       40.0f
#define PAD_BOTTOM           5.0f
#define ATTANCE_H            70.0f
#define KTABLEVIEWCELLID     @"WSScheduleStoreTableViewCell"
#define KTABLEVIEWCHEADID    @"WSScheduleStoreTableVHead"
#define KHeadClassName       @"WSScheduleHeadView"

@interface WSScheduleStoreView ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UIView * bgView;
@property(nonatomic,strong)UIView * contentBGView;
@property(nonatomic,strong)UILabel * titleLab;
@property(nonatomic,strong)UIView * smallTitleBgView;
@property(nonatomic,strong)UILabel * smallTilteLab;
@property(nonatomic,strong)UIButton * attanceBtn;
@property(nonatomic,strong)WSAttanceInfoView * attanceView;
@property(nonatomic,strong)UITableView * tableView;

@end

@implementation WSScheduleStoreView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if ([super initWithFrame:frame]) {
        self.backgroundColor= UIColor.whiteColor;
        [self p_creatSubviewUI];
    }
    return self;
}

- (void)setAttenanceModel:(WSAttenanceModel *)attenanceModel {
    
    if (self.selectDate) {
        
        NSString *role = [WSAttanceViewModel getLoginUserRole];
        if ([role isEqualToString:@"SR"]||[role isEqualToString:@"销售代表"]) {
            
            if ([NSDate validateWithSelectDateStr:self.selectDate]) {
                self.attanceBtn.backgroundColor = [UIColor colorWithHexString:@"#31EA00"];
                self.attanceBtn.userInteractionEnabled = YES;
            }
            else {
                self.attanceBtn.backgroundColor = [UIColor colorWithHexString:@"#C0C0C0"];
                self.attanceBtn.userInteractionEnabled = NO;
            }
            
//            NSString *currentDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
//            NSString *attenanceDate = self.selectDate;
//            NSInteger day_difference = [WSCurrentTime differencewithDate:currentDate withDate:attenanceDate];
//            if(day_difference > 7 || day_difference < -60){
//                LogInfo(@"SR角色7天以内，60天以后隐藏考勤设置按钮");
//                [self.attanceBtn setHidden:YES];
//            }
        }
    }
    
    _attenanceModel = attenanceModel;
    if (!_attenanceModel) {
        
        [self.attanceView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0.0);
        }];
    }
    else {
        
        [self.attanceView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(ATTANCE_H);
        }];
    }
    [self.attanceView setAttenanceModel:_attenanceModel];
}

- (void)setSchedduleTaskList:(NSArray *)schedduleTaskList{
    _schedduleTaskList = schedduleTaskList;
    if(_schedduleTaskList.count==0){
    
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0.0);
        }];
        return;
    }
    [self.tableView reloadData];
}
#pragma mark - # BTN ACTION
- (void)clickAttanceAction:(UIButton*)sender{
    if(self.clickAttanceAction){
        self.clickAttanceAction();
    }
}
- (void)setAttenanceRuleBlock:(clickAttanceAction)block{
    self.clickAttanceAction = block;
}
#pragma mark - # Private Method Craet UI

- (void)p_creatSubviewUI{
    [self bgView];
    [self titleLab];
    [self contentBGView];
    [self smallTitleBgView];
    [self smallTilteLab];
    [self attanceBtn];
    [self attanceView];
    [self tableView];
}
#pragma mark - # TableViewDelegate
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    WSScheduleStoreTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:KTABLEVIEWCELLID forIndexPath:indexPath];
    if(cell==nil){
        cell = [[WSScheduleStoreTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:KTABLEVIEWCELLID];
    }
    [cell setStoreModel:self.schedduleTaskList[indexPath.row]];
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.schedduleTaskList.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CELL_HEIGHT;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    WSScheduleHeadView *headerView = (WSScheduleHeadView*)[[[NSBundle mainBundle] loadNibNamed:@"WSScheduleHeadView" owner:self options:nil]lastObject];
    headerView.backgroundColor = HColorFromHex(0xF5F5F5);
    return headerView;
}

#pragma mark - # Load Lazy UI
- (UIView*)bgView{
    if(!_bgView){
        _bgView = [[UIView alloc]initWithFrame:CGRectZero];
        [self addSubview:_bgView];
        _bgView.backgroundColor = [UIColor colorWithRed:239/255.0 green:240/255.0 blue:241/255.0 alpha:1.00];
        @weakify_self;
        [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            @strongify_self;
            make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(PADING, PADING, PADING, PADING));
        }];
    }
    return _bgView;
}
- (UILabel*)titleLab{
    if(!_titleLab){
        _titleLab = [[UILabel alloc]initWithFrame:CGRectZero];
        [_bgView addSubview:_titleLab];
        @weakify_self;
        [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            @strongify_self;
            make.left.right.equalTo(self.bgView).offset(PADING_LEFT);
            make.height.mas_equalTo(CELL_HEIGHT);
            make.top.equalTo(self.bgView.mas_top).offset(PADING);
        }];
        _titleLab.font = FONT(14.0);
        _titleLab.textColor = HColorFromHex(0x7F7F7F);
        _titleLab.text = @"拜访计划/实际拜访";
        _titleLab.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLab;
}
- (UIView*)contentBGView{
    if(!_contentBGView){
        _contentBGView = [[UIView alloc]initWithFrame:CGRectZero];
        [_bgView addSubview:_contentBGView];
        @weakify_self;
        [_contentBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify_self;
            make.top.equalTo(self.titleLab.mas_bottom).offset(PADING);
            make.left.equalTo(self.bgView.mas_left).offset(PADING_LEFT);
            make.right.equalTo(self.bgView.mas_right).offset(-PADING_LEFT);
            make.bottom.equalTo(self.bgView.mas_bottom).offset(-PAD_BOTTOM);
        }];
        _contentBGView.alpha = 1;
        _contentBGView.backgroundColor = HColorFromHex(0xFFFFFF);
        _contentBGView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.12].CGColor;
        _contentBGView.layer.shadowOffset = CGSizeMake(0,0);
        _contentBGView.layer.shadowRadius = 8;
        _contentBGView.layer.shadowOpacity = 1;
    }
    return _contentBGView;
}
- (UIView*)smallTitleBgView{
    if(!_smallTitleBgView){
        _smallTitleBgView = [[UIView alloc]initWithFrame:CGRectZero];
        [self.contentBGView addSubview:_smallTitleBgView];
        @weakify_self;
        [_smallTitleBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify_self;
            make.top.equalTo(self.contentBGView.mas_top).offset(0);
            make.left.equalTo(self.contentBGView.mas_left).offset(0);
            make.right.equalTo(self.contentBGView.mas_right).offset(0);
            make.height.mas_equalTo(SMALLLTITLE_H);
        }];
        _smallTitleBgView.backgroundColor = HColorFromHex(0xF9F9F9);
    }
    return _smallTitleBgView;
}
- (UILabel*)smallTilteLab{
    if(!_smallTilteLab){
        _smallTilteLab = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.smallTitleBgView addSubview:_smallTilteLab];
        @weakify_self;
        [_smallTilteLab mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify_self;
            make.top.equalTo(self.smallTitleBgView.mas_top).offset(PADING);
            make.left.equalTo(self.smallTitleBgView.mas_left).offset(PADING_LEFT);
            make.width.mas_equalTo(SMALLLTITLE_W);
            make.height.mas_equalTo(SMALLLTITLE_H);
        }];
        _smallTilteLab.alpha = 1;
        NSString * smallTitle = @"日程安排";
        NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:smallTitle];
        [attributed addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16.0] range:NSMakeRange(0, smallTitle.length)];
        [attributed addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.00] range:NSMakeRange(0, smallTitle.length)];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 13.0;
       [attributed addAttribute:NSParagraphStyleAttributeName
                                 value:paragraphStyle
                                 range:NSMakeRange(0, [smallTitle length])];
        _smallTilteLab.attributedText = attributed;
        _smallTilteLab.textAlignment = NSTextAlignmentLeft;
    }
    return _smallTilteLab;
}
- (UIButton*)attanceBtn{
    if(!_attanceBtn){
        _attanceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.smallTitleBgView addSubview:_attanceBtn];
        @weakify_self;
        [_attanceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify_self;
            make.top.equalTo(self.smallTitleBgView.mas_top).offset(8);
            make.right.equalTo(self.smallTitleBgView.mas_right).offset(-PADING_LEFT);
            make.width.mas_equalTo(50.0);
            make.height.mas_equalTo(24.0);
        }];
        [_attanceBtn setBackgroundColor:MAIN_TINT_COLOR];
        [_attanceBtn addTarget:self action:@selector(clickAttanceAction:) forControlEvents:UIControlEventTouchUpInside];
        [_attanceBtn setTitle:@"设置" forState:UIControlStateNormal];
        [_attanceBtn setTitleColor:HColorFromHex(0x000000) forState:UIControlStateNormal];
        _attanceBtn.titleLabel.font = FONT(11.0);
    }
    return _attanceBtn;
}
- (WSAttanceInfoView*)attanceView{
    if(!_attanceView){
        _attanceView = (WSAttanceInfoView*)[[[NSBundle mainBundle]loadNibNamed:@"WSAttanceInfoView" owner:self options:nil] lastObject];
        [self.contentBGView addSubview:_attanceView];
        @weakify_self;
        [_attanceView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify_self;
            make.top.equalTo(self.smallTitleBgView.mas_bottom).offset(PADING_LEFT);
            make.left.equalTo(self.contentBGView).offset(PADING);
            make.right.equalTo(self.contentBGView).offset(-PADING);
            make.height.mas_equalTo(ATTANCE_H);
        }];
    }
    return _attanceView;
}
- (UITableView*)tableView{
    if(!_tableView){
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_contentBGView addSubview:_tableView];
        @weakify_self;
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            @strongify_self;
            make.left.right.equalTo(self.contentBGView).offset(PADING);
            make.top.equalTo(self.attanceView.mas_bottom).offset(PADING);
            make.bottom.equalTo(self.contentBGView.mas_bottom).offset(PADING);
        }];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = CELL_HEIGHT;
        _tableView.tableFooterView= [[UIView alloc]init];
        [_tableView registerNib:[UINib nibWithNibName:@"WSScheduleStoreTableViewCell" bundle:nil] forCellReuseIdentifier:KTABLEVIEWCELLID];
        [_tableView registerNib:[UINib nibWithNibName:@"WSScheduleHeadView" bundle:nil] forHeaderFooterViewReuseIdentifier:KTABLEVIEWCHEADID];
        _tableView.showsHorizontalScrollIndicator = NO;
    }
    return _tableView;
}


@end

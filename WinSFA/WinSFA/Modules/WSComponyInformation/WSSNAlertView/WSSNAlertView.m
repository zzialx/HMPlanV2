//
//  WSSNAlertView.m
//  WinSFA
//
//  Created by admin on 2023/2/14.
//  Copyright © 2023 WinChannel. All rights reserved.
//

#import "WSSNAlertView.h"
#import "WSSNInfoTableViewCell.h"
#import "Masonry/Masonry.h"
#import "WSMsgsBean_msg.h"
#define SCREEN_WIDTH ([[UIScreen mainScreen]bounds].size.width)
#define FRAME_WIDTH [[UIScreen mainScreen] applicationFrame].size.width

#define SCREEN_HEIGHT ([[UIScreen mainScreen]bounds].size.height)
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f \
alpha:(a)]

#define kPadding    12.0f

#define kInfoLabH   20.0f

#define kLineH      0.5f

#define kBtnH       35.0f

#define kBtnW       60.0f

static NSString * const kIdentifier = @"CellID";

@interface WSSNAlertView ()<UITableViewDelegate,UITableViewDataSource>

/// 背景框
@property(nonatomic,strong)UIView * backGroundView;
/// 确认按钮
@property(nonatomic,strong)UIButton * confimBtn;
/// 取消按钮
@property(nonatomic,strong)UIButton * cancleBtn;
/// 产品信息展示
@property(nonatomic,strong)UITableView * tableView;
/// 序列号分割线
@property(nonatomic,strong)UIView * line1;
/// 底部按钮分割线
@property(nonatomic,strong)UIView * line2;
/// 内容背景
@property (nonatomic,strong)UIView *bgContentView ;
/// 主标题
@property (nonatomic,strong)UILabel *defaultTitleLabel ;
/// 副标题
@property (nonatomic,strong)UILabel *defaultSubTitleLabel ;

@property (nonatomic,strong)WSSNShowViewPart *emptyItem ;

@property (nonatomic,strong)WSSNShowViewConfig *emptyConfig ;

@property (nonatomic,strong)WSSNAlertViewCallback callback ;

@property (nonatomic,strong)UIImageView *defaultImageView ;

@end

@implementation WSSNAlertView

- (instancetype)initWithConfig:(WSSNShowViewConfig *)config
{
    if (self = [super init]) {
        
        _emptyConfig = config ;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight ;
        self.backgroundColor = config.bgColor;
        [self creatUI];
    }
    return self ;
}
#pragma mark - # Private Method
#pragma mark - # Event Response Action
- (void)confirmAction:(UIButton*)sender{
    [WSSNAlertView hiddenEmptyView:self];
    NSArray * msgIdsArray =  [self.emptyItem.infoArray valueForKeyPath:@"@distinctUnionOfObjects.Id"];
    NSMutableArray * msgIdsList= [NSMutableArray arrayWithArray:msgIdsArray];
    // 使用NSArray的sortedArrayUsingComparator方法对数组元素进行降序排序
    NSArray *sortedMsgIdsNumbers = [msgIdsList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj2 compare:obj1];
    }];
    if (self.callback) {
        self.callback(self, sender,[sortedMsgIdsNumbers componentsJoinedByString:@","]) ;
    }
}
- (void)cancleAction:(UIButton*)sender{
    [WSSNAlertView hiddenEmptyView:self];
    if (self.callback) {
        self.callback(self, nil,nil);
    }
}
#pragma mark - # Public Method
- (void)showView{
    self.defaultTitleLabel.text = self.emptyItem.title;
    self.defaultSubTitleLabel.text = self.emptyItem.subtitle;
    [self.tableView reloadData];
    self.backgroundColor = UIColor.clearColor;
    [UIView animateWithDuration:0.3 animations:^{
    }] ;
    
}
#pragma mark - # UI
- (void)creatUI{
    [self backGroundView];
    [self bgContentView];
    [self defaultTitleLabel];
    [self line1];
    [self defaultSubTitleLabel];
    [self line2];
    [self confimBtn];
    [self tableView];
}
#pragma mark - # UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.emptyItem.infoArray.count>=3?3:self.emptyItem.infoArray.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WSSNInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifier forIndexPath:indexPath];
    if(cell==nil){
        cell = [[WSSNInfoTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    WSMsgsBean_msg * msgModel  = (WSMsgsBean_msg*)self.emptyItem.infoArray[indexPath.row];
    cell.model = msgModel;
    if(indexPath.row==2){
        cell.infoNameLab.text = @"";
        cell.infoContentLab.text = @"......";
    }
    return cell;
}
#pragma mark - # lozy load
#pragma mark - getter

- (UIView *)backGroundView{
    if (nil == _backGroundView) {
        _backGroundView = [[UIView alloc]init];
        [self addSubview:_backGroundView];
        [_backGroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).insets(UIEdgeInsetsMake(0,0,0,0));
        }];
        _backGroundView.backgroundColor = RGBACOLOR(60,60,60,0.8);
        
    }
    return _backGroundView ;
}

- (UIView *)bgContentView{
    if (nil == _bgContentView) {
        _bgContentView = [[UIView alloc]init];
        [self.backGroundView addSubview:_bgContentView];
        [_bgContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.backGroundView.mas_centerY);
            make.left.equalTo(self.backGroundView.mas_left).offset(kPadding*2);
            make.right.equalTo(self.backGroundView.mas_right).offset(-kPadding*2);
            make.height.mas_equalTo(240.0f);
        }];
        _bgContentView.backgroundColor = UIColor.whiteColor;
        _bgContentView.alpha = 1.0;
        _bgContentView.layer.cornerRadius = kPadding;
        _bgContentView.layer.masksToBounds = YES;
    }
    return _bgContentView ;
}
- (UILabel *)defaultTitleLabel{
    if (nil == _defaultTitleLabel) {
        _defaultTitleLabel = [[UILabel alloc] init];
        [_bgContentView addSubview:_defaultTitleLabel];
        [_defaultTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bgContentView).offset(kPadding);
            make.left.equalTo(self.bgContentView).offset(kPadding);
            make.right.equalTo(self.bgContentView).offset(-kPadding);
            make.height.mas_equalTo(kInfoLabH);
        }];
        _defaultTitleLabel.textColor = self.emptyConfig.titleColor ;
        _defaultTitleLabel.font = self.emptyConfig.tittleFont ;
        _defaultTitleLabel.numberOfLines = 1 ;
        _defaultTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _defaultTitleLabel ;
}
- (UILabel *)defaultSubTitleLabel{
    if (nil == _defaultSubTitleLabel) {
        _defaultSubTitleLabel =  [[UILabel alloc] init];
        [_bgContentView addSubview:_defaultSubTitleLabel];
        [_defaultSubTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.defaultTitleLabel.mas_bottom).offset(kPadding);
            make.left.equalTo(self.bgContentView).offset(kPadding);
            make.right.equalTo(self.bgContentView).offset(-kPadding);
            make.height.mas_equalTo(0.0f);
        }];
        _defaultSubTitleLabel.textColor = self.emptyConfig.subTitleColor ;
        _defaultSubTitleLabel.font = self.emptyConfig.subtitleFont ;
        _defaultSubTitleLabel.numberOfLines = 0 ;
        _defaultSubTitleLabel.textAlignment = NSTextAlignmentLeft ;
    }
    return _defaultSubTitleLabel ;
}
- (UIButton*)confimBtn{
    if(_confimBtn==nil){
        _confimBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.bgContentView addSubview:_confimBtn];
        [_confimBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.bgContentView.mas_bottom).offset(-kPadding);
            make.centerX.equalTo(self.bgContentView.mas_centerX);
            make.width.mas_equalTo(kBtnW*2);
            make.height.mas_equalTo(kBtnH);
        }];
        [_confimBtn setTitle:@"查看详情" forState:UIControlStateNormal];
        [_confimBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
        [_confimBtn setTitleColor:self.emptyConfig.buttonColor  forState:UIControlStateNormal];
        _confimBtn.layer.cornerRadius = 5.0;
        _confimBtn.layer.masksToBounds = YES;
        _confimBtn.layer.borderColor = UIColor.lightGrayColor.CGColor;
        _confimBtn.layer.borderWidth = 0.5;
        [_confimBtn addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
        _confimBtn.tag = 9999;
    }
    return _confimBtn;
}
- (UIButton*)cancleBtn{
    if(_cancleBtn==nil){
        _cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.bgContentView addSubview:_cancleBtn];
        [_cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.bgContentView.mas_bottom).offset(-kPadding);
            make.right.equalTo(self.bgContentView).offset(-(SCREEN_WIDTH/4 - kBtnW/2));
            make.width.mas_equalTo(kBtnW);
            make.height.mas_equalTo(kBtnH);
        }];
        [_cancleBtn setTitle:NSLocalizedString(@"cancel_label", nil) forState:UIControlStateNormal];
        [_cancleBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
        [_cancleBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        _cancleBtn.layer.cornerRadius = 5.0;
        _cancleBtn.layer.masksToBounds = YES;
        _cancleBtn.layer.borderColor = UIColor.lightGrayColor.CGColor;
        _cancleBtn.layer.borderWidth = 0.5;
        [_cancleBtn addTarget:self action:@selector(cancleAction:) forControlEvents:UIControlEventTouchUpInside];
        _cancleBtn.tag = 1000;
    }
    return _cancleBtn;
}
- (UITableView*)tableView{
    if(_tableView==nil){
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        [self.bgContentView addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.defaultSubTitleLabel.mas_bottom).offset(kPadding);
            make.left.equalTo(self.bgContentView).offset(kPadding);
            make.right.equalTo(self.bgContentView).offset(-kPadding);
            make.bottom.equalTo(self.confimBtn.mas_top).offset(-kPadding);
        }];
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = kInfoLabH * 2;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerNib:[UINib nibWithNibName:@"WSSNInfoTableViewCell" bundle:nil] forCellReuseIdentifier:kIdentifier];
    }
    return _tableView;
}
- (UIView*)line1{
    if(!_line1){
        _line1 = [[UIView alloc]initWithFrame:CGRectZero];
        [self.bgContentView addSubview:_line1];
        _line1.backgroundColor = RGBACOLOR(49.0, 234.0,0.0, 1);
        [_line1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.defaultSubTitleLabel.mas_bottom).offset(0.0f);
            make.left.equalTo(self.bgContentView).offset(kLineH);
            make.right.equalTo(self.bgContentView).offset(-kLineH);
            make.height.mas_equalTo(kLineH);
        }];
    }
    return _line1;
}
- (UIView*)line2{
    if(!_line2){
        _line2 = [[UIView alloc]initWithFrame:CGRectZero];
        [self.bgContentView addSubview:_line2];
        _line2.backgroundColor = UIColor.lightGrayColor;
        [_line2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.confimBtn.mas_top).offset(-11.5f);
            make.left.equalTo(self.bgContentView).offset(kLineH);
            make.right.equalTo(self.bgContentView).offset(-kLineH);
            make.height.mas_equalTo(0.0f);
        }];
    }
    return _line2;
}
#pragma mark - # 类方法

+ (WSSNAlertView *)showEmptyInView:(UIView *)superview
                              part:(WSSNShowViewPart *(^)(void))part
{
    return [self showEmptyInView:superview part:part config:nil];
}

+ (WSSNAlertView *)showEmptyInView:(UIView *)superview
                              part:(WSSNShowViewPart *(^)(void))part
                            config:(WSSNShowViewConfig *(^)(void))config
{
    return [self showEmptyInView:superview part:part config:config callback:nil];
}

+ (WSSNAlertView *)showEmptyInView:(UIView *)superview
                   part:(WSSNShowViewPart *(^)(void))part
                 config:(WSSNShowViewConfig *(^)(void))config
               callback:(WSSNAlertViewCallback)callback
{
    
    WSSNShowViewConfig *emptyConfig = [self changeConfigWithConfig:config] ;
    WSSNShowViewPart   *emptyItem = part() ;
    
    NSAssert(emptyItem.buttonArray.count<3, @"you can't set more than two button") ;
    
    WSSNAlertView *emptyView = [[WSSNAlertView alloc]initWithConfig:emptyConfig];
    emptyView.emptyItem =emptyItem ;
    emptyView.callback = callback ;
    
    UIEdgeInsets edge = emptyConfig.easyViewEdgeInsets ;

    [emptyView setFrame:CGRectMake(edge.left, edge.top, SCREEN_WIDTH,SCREEN_HEIGHT )] ;
    
    [superview addSubview:emptyView] ;
    
    [emptyView showView];
    
    return emptyView ;
}


+ (void)hiddenEmptyView:(WSSNAlertView *)emptyView
{
    [UIView animateWithDuration:.3 animations:^{
        emptyView.alpha = 0.2 ;
    } completion:^(BOOL finished) {
        [emptyView removeFromSuperview];
    }] ;
}
+ (void)hiddenEmptyInView:(UIView *)superView
{
    
    NSAssert([NSThread isMainThread], @"needs to be accessed on the main thread.");
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
        });
    }
    
    NSEnumerator *subviewsEnum = [superView.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:self]) {
            WSSNAlertView *emptyView = (WSSNAlertView *)subview ;
            [self hiddenEmptyView:emptyView];
        }
    }
}

+ (WSSNShowViewConfig *)changeConfigWithConfig:(WSSNShowViewConfig *(^)(void))config
{
    WSSNShowViewConfig *tempConfig = config ? config() : nil ;
    if (!tempConfig) {
        tempConfig = [WSSNShowViewConfig shared] ;
    }

    WSSNShowViewGlobalConfig *globalConfig = [WSSNShowViewGlobalConfig shared];

    if (!tempConfig.bgColor) {
        tempConfig.bgColor = globalConfig.bgColor  ;
    }
    if (!tempConfig.tittleFont) {
        tempConfig.tittleFont =globalConfig.tittleFont;
    }
    if (!tempConfig.titleColor) {
        tempConfig.titleColor =  globalConfig.titleColor ;
    }
    if (!tempConfig.subtitleFont) {
        tempConfig.subtitleFont = globalConfig.subtitleFont;
    }
    if (!tempConfig.subTitleColor) {
        tempConfig.subTitleColor = globalConfig.subTitleColor ;
    }
    if (!tempConfig.buttonFont) {
        tempConfig.buttonFont =  globalConfig.buttonFont ;
    }
    if (!tempConfig.buttonColor) {
        tempConfig.buttonColor = globalConfig.buttonColor;
    }
    if (!tempConfig.buttonBgColor) {
        tempConfig.buttonBgColor = globalConfig.buttonBgColor;
    }

    if (tempConfig.buttonEdgeInsets.top==0 && tempConfig.buttonEdgeInsets.left==0
    && tempConfig.buttonEdgeInsets.bottom==0 && tempConfig.buttonEdgeInsets.right==0 ) {
        tempConfig.buttonEdgeInsets = globalConfig.buttonEdgeInsets ;
    }
    return tempConfig ;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

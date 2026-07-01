//
//  WSGenerateSuggestController.m
//  WinSFA
//
//  Created by huzepei on 16/7/6.
//  Copyright © 2016年 WinChannel. All rights reserved.
//


#import "WSGenerateSuggestController.h"
#import "WSPopUpProductViewController.h"
#import "WSProductDetails.h"
#import "PureLayout.h"
#import "UIView+Shake.h"
#import "WSSuggest.h"
#import "WSSuggestWholesale.h"
#import "WSSuggestListTable.h"
#import "WSCateModel.h"
#import "WSBaseDictsTable.h"

#define VIEWBROADCOLOR  [[UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:0.5] CGColor]
#define POPVIEWWIDTH 450
#define POPVIEWHEIGHT 450

#define CustomViewHeight 300
#define CustomViewMaginTop 50

#define k_UISCREN_Width ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? : 1024)
#define k_UISCREN_Height ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? : 768)

@interface WSGenerateSuggestController ()
{
    BOOL _isOwnExist;
    BOOL _isOtherExist;
}
@property (nonatomic,strong) WSSuggestPro *currentOwnSP_wholesale;
@property (nonatomic,strong) WSSuggestPro *currentOwnSp_terminal;
@property (nonatomic,strong) WSSuggestPro *currentOtherSP_wholesale;
@property (nonatomic,strong) WSSuggestPro *currentOtherSp_terminal;

@property (nonatomic,strong) WSSuggestPro *leftModel;
@property (nonatomic,strong) WSSuggestPro *rightModel;


@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *rightView;

@property (weak, nonatomic) IBOutlet UIView *leftTopView;
@property (weak, nonatomic) IBOutlet UIView *leftBottomView;
@property (weak, nonatomic) IBOutlet UIView *rightTopVIew;
@property (weak, nonatomic) IBOutlet UIView *rightBottomView;



@property (nonatomic,strong) WSProductDetails *proDetailView;

@property (weak, nonatomic) IBOutlet UILabel *monthSumProfits;

@property (weak, nonatomic) IBOutlet UILabel *monthOtherSumProfits;

@property (weak, nonatomic) IBOutlet UILabel *monthMoreProfits;

@property (weak, nonatomic) IBOutlet UILabel *yearMoreProfits;

//当前的品类,需要将品类锁定.
@property (nonatomic,strong) WSCateModel *currentModel;

- (IBAction)backClick:(id)sender;
- (IBAction)saveSuggest:(id)sender;

//poper建议单
@property (nonatomic,strong)WSPopUpProductViewController *pop;
@property (nonatomic,strong)WSPopUpProductViewController *pop2;

@property (weak, nonatomic) IBOutlet UITextField *sugNameLabel;

/**
 *   此数据是在本界面保存的数据模型
 */
@property (nonatomic,strong) WSSuggestWholesale *suggestWholesale;


@property (nonatomic,strong) WSSuggest *suggest;

/**
 *  缓存产品标题与产品属性
 */
@property (nonatomic,strong) NSString *productTitle;
@property (nonatomic,strong) NSString *proAttribute;

@property (nonatomic,strong) NSString *productOtherTitle;
@property (nonatomic,strong) NSString *proOtherAttribute;

//当前选中的品类(需求:本品或者竞品选择完品类之后,品类就会锁定)
@property (nonatomic,strong) WSCateModel *currentCateModel;

@end

@implementation WSGenerateSuggestController


#pragma mark - view cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _leftView.layer.borderColor = VIEWBROADCOLOR;
    _leftView.layer.borderWidth = 1.0;
    _rightView.layer.borderColor = VIEWBROADCOLOR;
    _rightView.layer.borderWidth = 1.0;
    
    [self loadCustomView];
    
    if (_suggestWho) {
        [self updateViewWithSuggestWho];
    }
     _sugNameLabel.text = [NSString stringWithFormat:@"%@",_suggestName];
}

/**
 *  根据不同的业务加载不同的页面
 */
-(void)loadCustomView
{
    //加载本品
    [self addProject];
    
//    //加载竞品
    [self addOtherProject];
    
}

-(void)setSuggestName:(NSString *)suggestName
{
    _suggestName = suggestName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)reloadSubViews
{
    if (_currentOwnSP_wholesale) {
        [self.leftTopView addSubview:self.proDetailView];
        [self.proDetailView autoPinEdgesToSuperviewEdges];
    }
}

#pragma mark - functional logic
- (void)addProject {
    
    WSPopUpProductViewController *pop = [[WSPopUpProductViewController alloc] init];
    
    if ([self isHasCateModel] && _currentCateModel) {
        pop.curOutCateModel = _currentCateModel;
    }
    
    pop.proType = 0;
    
    if (_currentOwnSP_wholesale || _currentOwnSp_terminal) {
        pop.showProdTitle = NO;
    }else{
        pop.showProdTitle = YES;
    }
    
    //设置大小
    [self addChildViewController:pop];
    
    pop.view.frame = CGRectMake(0, CustomViewMaginTop, _leftView.width, _leftView.height - 100);
    
    [_leftView addSubview:pop.view];
    
    pop.sp = ^(WSSuggestPro *currentSp,WSCateModel *currentCate){
        
        if (currentSp.name == nil) {
            currentSp.name = _productTitle;
        }else{
            _productTitle = currentSp.name;
        }
        
        if (currentSp.memo4 == nil) {
            currentSp.memo4 = _proAttribute;
        }else{
            _proAttribute = currentSp.memo4;
        }
        
        if (currentCate) {
            _currentCateModel = currentCate;
        }
        
        _leftModel = currentSp;
        
        [self refreshOwnSumLabel:currentSp];
        
    };
    
    pop.currentCate = ^(WSCateModel *currentCate){
        
        _currentCateModel = currentCate;
        //刷新品类的互斥
        [self refreshCateModelPop2];
    };
    
    self.pop = pop;
    
}
/**
 *  刷新品类的互斥
 */
-(void)refreshCateModelPop2
{

    _pop2.curOutCateModel = _currentCateModel;
    
}

-(void)refreshCateModelPop
{

    _pop.curOutCateModel = _currentCateModel;
    
}

- (void)addOtherProject {
    
    WSPopUpProductViewController *pop = [[WSPopUpProductViewController alloc] init];
    
    if ([self isHasCateModel] && _currentCateModel) {
        pop.curOutCateModel = _currentCateModel;
    }
    
    pop.proType = 1;
    
    pop.modalPresentationStyle = UIModalPresentationFormSheet;
    
    if (_currentOtherSp_terminal || _currentOtherSP_wholesale) {
        pop.showProdTitle = NO;
    }else{
        pop.showProdTitle = YES;
    }
    
    [self addChildViewController:pop];
    
    pop.view.frame = CGRectMake(0, CustomViewMaginTop, _leftView.width, _leftView.height - 100);
    
    [_rightView addSubview:pop.view];
    
    pop.sp = ^(WSSuggestPro *currentSp,WSCateModel *currentCate){
        
        if (currentSp.name == nil) {
            currentSp.name = _productOtherTitle;
        }else{
            _productOtherTitle = currentSp.name;
        }
        
        if (currentSp.memo4 == nil) {
            currentSp.memo4 = _proOtherAttribute;
        }else{
            _proOtherAttribute = currentSp.memo4;
        }
        
        if (currentCate) {
            _currentCateModel = currentCate;
        }
        
        _rightModel = currentSp;
        
        [self refreshOtherSumLabel:currentSp];
        
    };
    pop.currentCate = ^(WSCateModel *currentCate){
        
        _currentCateModel = currentCate;
        //刷新品类的互斥
        [self refreshCateModelPop];
    };
    
    self.pop2 = pop;
}

-(void)refreshOwnSumLabel:(WSSuggestPro *)sugPro
{
    _isOwnExist = YES;

    CGFloat sum = [sugPro.month_sales floatValue] * [sugPro.boxProfits floatValue];
    _monthSumProfits.text = [NSString stringWithFormat:@"%0.2f 元",sum];
    
    [self refreshMoreSumLabel];
}
-(void)refreshOtherSumLabel:(WSSuggestPro *)sugPro
{
    _isOtherExist = YES;
    
    CGFloat sum = [sugPro.month_sales floatValue] * [sugPro.boxProfits floatValue];
    _monthOtherSumProfits.text = [NSString stringWithFormat:@"%0.2f 元",sum];

    [self refreshMoreSumLabel];
}
-(void)refreshMoreSumLabel
{
    if (_isOwnExist && _isOtherExist) {
        
        CGFloat monthMore = [_monthSumProfits.text floatValue] - [_monthOtherSumProfits.text floatValue];
        _monthMoreProfits.text = [NSString stringWithFormat:@"%0.2f 元",monthMore];
        
        CGFloat yearMore = monthMore * 12;
        _yearMoreProfits.text = [NSString stringWithFormat:@"%0.2f 元",yearMore];
    }
}

-(void)setSuggestWho:(WSSuggestWholesale *)suggestWho
{
    _suggestWho = suggestWho;
}

-(void)updateViewWithSuggestWho
{
    //建议单名称
    _suggestName = _suggestWho.name;
    
    NSLog(@"%@",_suggestWho.sugModel.ownSp_terminal);
    
    if (_suggestWho.sugModel.ownSP_wholesale) {
        _leftModel = _suggestWho.sugModel.ownSP_wholesale;
    }
    
    if (_suggestWho.sugModel.otherSP_wholesale){
        _rightModel = _suggestWho.sugModel.otherSP_wholesale;
    }
    
    [self containerViewClick];
}

/**
 *  点击内容视图,弹出POP
 */
-(void)containerViewClick
{
    //刷新本品视图
    _pop.proType = 0;
    
    if (_suggestWho.sugModel.ownSP_wholesale) {
        _pop.sww = _suggestWho.sugModel.ownSP_wholesale;
    }
    
    //刷新竞品视图
    _pop2.proType = 1;
    
    if (_suggestWho.sugModel.otherSP_wholesale) {
        _pop2.sww = _suggestWho.sugModel.otherSP_wholesale;
    }
    
    
    if (_suggestWho.sugModel.ownSP_wholesale) {
        
        NSString *cateStr = [NSString stringWithFormat:@"SELECT dicts._id,dicts.name,dicts.typ FROM  base_dicts AS dicts WHERE dicts._id = '%@';",_suggestWho.sugModel.ownSP_wholesale.memo1];
        WSCateModel *cate = (WSCateModel *)[[WSBaseDictsTable sharedTable] queryAndReturnSingleInfoBySql:cateStr andClassName:@"WSCateModel"];
        _pop2.curOutCateModel = cate;
    }
    
    if (_suggestWho.sugModel.otherSP_wholesale) {
        NSString *cateStr = [NSString stringWithFormat:@"SELECT dicts._id,dicts.name,dicts.typ FROM  base_dicts AS dicts WHERE dicts._id = '%@';",_suggestWho.sugModel.otherSP_wholesale.memo1];
        
        WSCateModel *cate = (WSCateModel *)[[WSBaseDictsTable sharedTable] queryAndReturnSingleInfoBySql:cateStr andClassName:@"WSCateModel"];
        _pop.curOutCateModel = cate;
    }
    
    //计算收益
    [self refreshOwnSumLabel:_suggestWho.sugModel.ownSP_wholesale];
    [self refreshOtherSumLabel:_suggestWho.sugModel.otherSP_wholesale];
    
}
#pragma mark - event

- (IBAction)backClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveSuggest:(id)sender {
    
    if (!(_leftModel || _rightModel)) {
        NSString *title = NSLocalizedString(@"未填写任何内容", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
        
    }
    
    //点击确定的时候,拼接模型.
    WSSuggestWhoModel *swm = [[WSSuggestWhoModel alloc] init];
    swm.ownSP_wholesale = _leftModel;
    swm.otherSP_wholesale = _rightModel;
    swm.proFits = _monthSumProfits.text;
    swm.compFits = _monthOtherSumProfits.text;
    swm.moreMonthFits = _monthMoreProfits.text;
    swm.moreYearFits = _yearMoreProfits.text;
    
    _suggestWholesale = [[WSSuggestWholesale alloc] init];
    //归档
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:swm];
    _suggestWholesale.item = data;
    _suggestWholesale.dType = @"02";
    _suggestWholesale.sugModel = swm;
    
    if (_suggestWho) {
        _suggestWholesale.ID = _suggestWho.ID;
    }
    
    //建议单名称
    if ([_sugNameLabel.text isEqualToString:@""]) {
        [_sugNameLabel shakeView];
        return;
    }
    
    _suggestWholesale.name = _sugNameLabel.text;

    BlockAlertView *alert = [BlockAlertView alertWithTitle:@"提醒" message:@"是否保存为模板"];
    
    [alert setDestructiveButtonWithTitle:@"confirm" block:^{
        
        //这里只负责模板数据的对比(去重)
        [self updateTableWithType:@"02" model:_suggestWholesale];
        
        [self dismissViewControllerAnimated:YES completion:^{
            
            if (_sug) {
                _sug(_suggestWholesale);
            }
        }];
        
    }];
    
    [alert setCancelButtonWithTitle:@"cancel_label" block:^{
        
        [self dismissViewControllerAnimated:YES completion:^{
            if (_sug) {
                _sug(_suggestWholesale);
            }
        }];
        
    }];
    
    [alert show];
}

//更新数据库(重复的去重,不重复添加)
-(void)updateTableWithType:(NSString *)type model:(WSSuggestWholesale *)who
{
    //模板数据
    NSMutableArray * localTempArray = [[[WSSuggestListTable sharedTable] queryTableForSuggestListType:type className:@"WSSuggestWholesale"] mutableCopy];
    
    BOOL isTempReplace = NO;
    for (int i = 0; i < localTempArray.count; i++) {
        
        WSSuggestWholesale *arrItem = localTempArray[i];
        
        if ([who.name isEqualToString:arrItem.name]) {
            
            [localTempArray replaceObjectAtIndex:i withObject:who];
            // 如果用家的和批发的数据有重复！就会把用家和批发的数据更新成一种。---更新条件加上type
            [[WSSuggestListTable sharedTable] updateWithNames:@[@"item"] values:@[who.item] whereName:@[@"name",@"sid",@"type"] whereValue:@[who.name,@"0",type]];
            
            isTempReplace = YES;
        }
    }
    
    if (!isTempReplace) {
        [localTempArray addObject:who];
        [[WSSuggestListTable sharedTable] insertTableWithType:type model:who sid:@"0" withbiz_date:self.prepareDate];
    }
    
}
//检测是否有品类
-(BOOL)isHasCateModel
{
    if (_leftModel || _rightModel) {
        
        return YES;
        
    }else{
        
        return NO;
    }
}

#pragma mark - setter,getter
-(WSProductDetails *)proDetailView
{
    _proDetailView  = [WSProductDetails productDetailView];
    return _proDetailView;
}

@end

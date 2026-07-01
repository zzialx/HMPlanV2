//
//  WSGenerateSuggestForHomeViewController.m
//  WinSFA
//
//  Created by HZH on 16/9/7.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSGenerateSuggestForHomeViewController.h"
//#import "WSPopUpProductViewController.h"
#import "WSProductDetails.h"
#import "PureLayout.h"
#import "WSSuggestWholesale.h"
#import "UIView+Shake.h"
#import "WSSuggest.h"
#import "WSSuggestTableInstance.h"
#import "WSPopUpProductForHomeViewController.h"
#import "WSSuggestListTable.h"
#import "WSSuggestHome.h"
#import "WSCateModel.h"
#import "WSBaseDictsTable.h"


#define CustomViewHeight 390
#define CustomViewMaginTop 65


#import "WSHomeProDetails.h"

@interface WSGenerateSuggestForHomeViewController ()<UITextFieldDelegate>
{
    BOOL _isOwnExist;
    BOOL _isOtherExist;
    
    double  _ownCosts;
    double  _otherCosts;
}

@property (nonatomic,strong) WSSuggestHomePro *ownSP_top;

@property (nonatomic,strong) WSSuggestHomePro *otherSP_top;



@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *rightView;

@property (weak, nonatomic) IBOutlet UIView *leftTopView;

@property (weak, nonatomic) IBOutlet UIView *rightTopVIew;


@property (nonatomic,strong) WSProductDetails *proDetailView;
@property (weak, nonatomic) IBOutlet UILabel *objectCosts;
@property (weak, nonatomic) IBOutlet UILabel *objectOtherCosts;

@property (weak, nonatomic) IBOutlet UIButton *leftBottomBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightBottomBtn;
@property (weak, nonatomic) IBOutlet UILabel *dishOrFormulaStaticLabel;

@property (weak, nonatomic) IBOutlet UILabel *unitNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *dishClickedCntOrFormulaUsedCntTF;
@property (weak, nonatomic) IBOutlet UILabel *monthSaveCosts;
@property (weak, nonatomic) IBOutlet UILabel *yearSaveCosts;
- (IBAction)backClick:(id)sender;
- (IBAction)saveSuggest:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *suggestNameLabel;


@property (nonatomic,strong) WSHomeProDetails *benPd;
@property (nonatomic,strong) WSHomeProDetails *jingPd;

@property (nonatomic,strong) WSSuggest *suggest;

//本页面保存的数据模型
@property (nonatomic,strong) WSSuggestHome *suggestHome;

/**
 *  缓存产品标题与产品属性
 */
@property (nonatomic,strong) NSString *productTitle;
@property (nonatomic,strong) NSString *proAttribute;

@property (nonatomic,strong) NSString *productOtherTitle;
@property (nonatomic,strong) NSString *proOtherAttribute;

//当前选中的品类(需求:本品或者竞品选择完品类之后,品类就会锁定)
@property (nonatomic,strong) WSCateModel *currentCateModel;

@property (nonatomic,strong)WSPopUpProductForHomeViewController *pop;
@property (nonatomic,strong)WSPopUpProductForHomeViewController *pop2;

@end

@implementation WSGenerateSuggestForHomeViewController


#pragma mark - view cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dishClickedCntOrFormulaUsedCntTF.delegate = self;
    
    [_dishClickedCntOrFormulaUsedCntTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    _leftView.layer.borderColor = VIEWBROADCOLOR;
    _leftView.layer.borderWidth = 1.0;
    _rightView.layer.borderColor = VIEWBROADCOLOR;
    _rightView.layer.borderWidth = 1.0;
    
    if ([_sStyle isEqualToString:HSuggestTableForHomeModelStyleDish]) { //菜市应用
        [_leftBottomBtn setTitle:@"每菜成本 (元) :" forState:UIControlStateNormal];
        [_rightBottomBtn setTitle:@"每菜成本 (元) :" forState:UIControlStateNormal];
        _dishOrFormulaStaticLabel.text = @"每日菜式点击率";
        _unitNameLabel.text = @"次";

    }else if ([_sStyle isEqualToString:HSuggestTableForHomeModelStyleFormula]) {
        [_leftBottomBtn setTitle:@"配方成本 (元/KG) :" forState:UIControlStateNormal];
        [_rightBottomBtn setTitle:@"配方成本 (元/KG) :" forState:UIControlStateNormal];
        _dishOrFormulaStaticLabel.text = @"每日配方用量";
        _unitNameLabel.text = @"KG";

    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWillBeHidden:)
     
                                                 name:UIKeyboardWillHideNotification object:nil];

    [self loadCustomView];
    
    if (_suhome) {
        [self updateViewWithSuggestHome];
        
    }
    
    _suggestNameLabel.text = [NSString stringWithFormat:@"%@",_sTableName];
    
    //键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}
/**
 *  根据不同的业务加载不同的页面
 */
-(void)loadCustomView
{
    //加载本品
    [self addProject];
    
    //加载竞品
    [self addOtherProject];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - functional logic

/**
 *  点击内容视图,弹出POP
 */
-(void)containerViewClick
{
    
    //刷新本品视图
    _pop.sStyle = _sStyle;
    _pop.productOwnerType = @"01";
    _pop.shp = _ownSP_top;
    
    //刷新竞品视图
    _pop2.sStyle = _sStyle;
    _pop2.productOwnerType = @"02";
    _pop2.shp = _otherSP_top;
    
    if (_ownSP_top) {
        NSString *cateStr = [NSString stringWithFormat:@"SELECT dicts._id,dicts.name,dicts.typ FROM  base_dicts AS dicts WHERE dicts._id = '%@';",_ownSP_top.memo1];
        WSCateModel *cate = (WSCateModel *)[[WSBaseDictsTable sharedTable] queryAndReturnSingleInfoBySql:cateStr andClassName:@"WSCateModel"];
        _pop2.curOutCateModel = cate;
    }
    
    if (_otherSP_top) {
        NSString *cateStr = [NSString stringWithFormat:@"SELECT dicts._id,dicts.name,dicts.typ FROM  base_dicts AS dicts WHERE dicts._id = '%@';",_ownSP_top.memo1];
        WSCateModel *cate = (WSCateModel *)[[WSBaseDictsTable sharedTable] queryAndReturnSingleInfoBySql:cateStr andClassName:@"WSCateModel"];
        _pop.curOutCateModel = cate;
    }
    
    if ([_sStyle isEqualToString:@"01"]) {  //  菜式
        
        [self refreshOwnSumLabel:_ownSP_top];
        [self refreshOtherSumLabel:_otherSP_top];
        
    }else{//配方
        
        [self refreshOwnPeiLabel:_ownSP_top];
        [self refreshRecipesPeiLabel:_otherSP_top];
        
    }
}
/**
 *  点击内容更新
 */
-(void)updateViewWithSuggestHome
{
    //建议单名称
    _sTableName = _suhome.name;
    
    //创造模型
    if (_suhome.sugHomeModel.clickRate) {
        _dishClickedCntOrFormulaUsedCntTF.text = _suhome.sugHomeModel.clickRate;
    }
    
    if (_suhome.sugHomeModel.ownSP_top) {
        
        _ownSP_top = _suhome.sugHomeModel.ownSP_top;
    }
    if (_suhome.sugHomeModel.otherSP_top) {
        
        _otherSP_top = _suhome.sugHomeModel.otherSP_top;
    }
    [self containerViewClick];
}

/**
 *  添加本品
 */
- (void)addProject {
    
    WSPopUpProductForHomeViewController *pop = [[WSPopUpProductForHomeViewController alloc] init];
    
    if ([self isHasCateModel] && _currentCateModel) {
        pop.curOutCateModel = _currentCateModel;
    }
    
    pop.sStyle = _sStyle;
    pop.productOwnerType = @"01";

    //设置大小
    [self addChildViewController:pop];
    
    pop.view.frame = CGRectMake(0, CustomViewMaginTop, _leftView.width, CustomViewHeight);
    
    [_leftView addSubview:pop.view];

    //回显
    pop.sp = ^(WSSuggestHomePro *currentSp, WSCateModel *currentCate){
        
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
        _ownSP_top = currentSp;
        
        [self updateProWith:currentSp local:_ownSP_top view:self.leftTopView type:0];
        
    };
    
    pop.currentCate = ^(WSCateModel *currentCate){
        
        _currentCateModel = currentCate;
        //刷新品类的互斥
        [self refreshCateModelPop2];
    };
    
    _pop = pop;
}

/**
 *  刷新品类的互斥
 */
-(void)refreshCateModelPop2
{
    if (![_sStyle isEqualToString:@"02"]) {
        _pop2.curOutCateModel = _currentCateModel;
    }
}

-(void)refreshCateModelPop
{
    if (![_sStyle isEqualToString:@"02"]) {
        _pop.curOutCateModel = _currentCateModel;
    }
    
}

/**
 *  添加竞品
 */
- (void)addOtherProject {

    WSPopUpProductForHomeViewController *pop = [[WSPopUpProductForHomeViewController alloc] init];
    
    if (_currentCateModel && [self isHasCateModel]) {
        pop.curOutCateModel = _currentCateModel;
    }
    
    pop.sStyle = _sStyle;
    pop.productOwnerType = @"02";
    
    [self addChildViewController:pop];
    
    pop.view.frame = CGRectMake(0, CustomViewMaginTop, _rightView.width, CustomViewHeight);
    
    [_rightView addSubview:pop.view];
    
    pop.sp = ^(WSSuggestHomePro *currentSp, WSCateModel *currentCate){
        
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
        
        _otherSP_top = currentSp;
        [self updateProWith:currentSp local:_otherSP_top view:self.rightTopVIew type:1];
    };
    
    pop.currentCate = ^(WSCateModel *currentCate){
        
        _currentCateModel = currentCate;
        //刷新品类的互斥
        [self refreshCateModelPop];
    };
    
    _pop2 = pop;
}

/**
 *  根据不同的条件（本品01,竞品02,菜式01,用家02,生成相同的模型对象）
 */
-(void)updateProWith:(WSSuggestHomePro *)currentSp local:(WSSuggestHomePro *)localSp view:(UIView *)localView  type:(int)type
{
    if (type == 0) { //本品
        
        if ([_sStyle isEqualToString:@"02"]) { //配方
            
            [self generateNewFormulaPro:currentSp];
            localSp  = currentSp;
            self.benPd.formulaSp = localSp;
            
            [self refreshOwnPeiLabel:localSp];
            
        }else{
            
            [self generateNewPro:currentSp];
            localSp  = currentSp;
            self.benPd.sp = localSp;
            
            //更新本品的每菜成本.
            [self refreshOwnSumLabel:localSp];
        }
    
    }else{ //竞品
        
        if ([_sStyle isEqualToString:@"02"]) { //配方  -- 新需求只有自制配方.
            
            [self generateNewOwnFormulaPro:currentSp];
            localSp  = currentSp;
            self.jingPd.recipesSp = localSp;
            
            //更新自制配方
            [self refreshRecipesPeiLabel:localSp];
            
        }else{//菜式
        
            [self generateNewPro:currentSp];
            localSp  = currentSp;
            self.jingPd.sp = localSp;
            
            //更新竞品的每菜成本
            [self refreshOtherSumLabel:localSp];
            
        }
    }
}

//计算生成新的产品模型
-(void)generateNewPro:(WSSuggestHomePro *)pro
{
    //规格--不处理kg,如果是kg的话,叫后台处理一下,前端默认是g.
    int spec = [pro.memo2 intValue] * [pro.memo3 intValue];
    //单位成本
    double homeCostInt = [pro.priceBox doubleValue] / spec ;
    NSString *homeCostStr = [NSString stringWithFormat:@"%f",homeCostInt];
    if ([homeCostStr containsString:@"."]) {
        NSRange range = [homeCostStr rangeOfString:@"."];
        homeCostStr = [homeCostStr substringToIndex:range.length + range.location + 2];
    }else{
        homeCostStr = [NSString stringWithFormat:@"%.2f",homeCostInt];
    }
    //每菜成本
    double homeFoodCost = homeCostInt * [pro.dosage doubleValue];
    
    NSString *homeFoodStr = [NSString stringWithFormat:@"%f",homeFoodCost];
    if ([homeFoodStr containsString:@"."]) {
        NSRange range = [homeFoodStr rangeOfString:@"."];
        homeFoodStr = [homeFoodStr substringToIndex:range.length + range.location + 2];
    }else{
        homeFoodStr = [NSString stringWithFormat:@"%.2f",homeFoodCost];
    }
    pro.homeCost = homeCostStr;
    pro.homeFoodCost = homeFoodStr;
    
}

//计算生成新的产品模型-- 配方
-(void)generateNewFormulaPro:(WSSuggestHomePro *)pro
{
    //规格
    int spec = [pro.memo2 intValue] * [pro.memo3 intValue];
    
    //单位成本
    double homeCostInt = [pro.priceBox doubleValue] / spec;
    NSString *homeCostStr = [NSString stringWithFormat:@"%f",homeCostInt];
    if ([homeCostStr containsString:@"."]) {
        NSRange range = [homeCostStr rangeOfString:@"."];
        homeCostStr = [homeCostStr substringToIndex:range.length + range.location + 2];
    }else{
        homeCostStr = [NSString stringWithFormat:@"%.2f",homeCostInt];
    }
    
    //配方成本
    double FormulaCost = homeCostInt * [pro.formulaDosage doubleValue];
    NSString *formulaCostStr = [NSString stringWithFormat:@"%f",FormulaCost];
    if ([formulaCostStr containsString:@"."]) {
        NSRange range = [formulaCostStr rangeOfString:@"."];
        formulaCostStr = [formulaCostStr substringToIndex:range.length + range.location + 2];
    }else{
        formulaCostStr = [NSString stringWithFormat:@"%.2f",FormulaCost];
    }
    pro.homeCost = homeCostStr;
    pro.formulaCost = formulaCostStr;
    
}

//计算生成新的产品模型-- 自制配方
-(void)generateNewOwnFormulaPro:(WSSuggestHomePro *)pro
{
    CGFloat sumCost = [pro.renliCost doubleValue] + [pro.yuanliaoCost doubleValue] + [pro.makeCost doubleValue];
    
    NSString *sumCostStr = [NSString stringWithFormat:@"%.2f",sumCost];
    
    CGFloat peiCost = [sumCostStr doubleValue] / [pro.makeEveryTime doubleValue];
    
    NSString *peiCostStr = [NSString stringWithFormat:@"%.2f",peiCost];
    
    pro.sumCost = sumCostStr;
    pro.peiCost = peiCostStr;
    
}

// 刷新本品的配方成本
-(void)refreshOwnPeiLabel:(WSSuggestHomePro *)ownPro
{
    _isOwnExist = YES;
    
    _ownCosts = [ownPro.formulaCost doubleValue];
    _objectCosts.text = [NSString stringWithFormat:@"%.2f",_ownCosts];
    
    [self refreshMoreSumLabel];
}


// 刷新竞品的配方成本
-(void)refreshOtherPeiSumLabel:(WSSuggestHomePro *)ownPro
{
    _isOtherExist = YES;
    
    _otherCosts = [ownPro.formulaCost doubleValue];
    _objectOtherCosts.text = [NSString stringWithFormat:@"%.2f",_otherCosts];
    
    [self refreshMoreSumLabel];
}

// 刷新竞品的    ****自制配方*****
- (void)refreshRecipesPeiLabel:(WSSuggestHomePro *)ownPro
{
    _isOtherExist = YES;
    
    //自制配方的总成本相加.
    _otherCosts = [ownPro.peiCost doubleValue];
    
    _objectOtherCosts.text = [NSString stringWithFormat:@"%.2f",_otherCosts];
    
    [self refreshMoreSumLabel];
    
}
// 刷新本品的每菜成本
-(void)refreshOwnSumLabel:(WSSuggestHomePro *)ownPro
{
    _isOwnExist = YES;
    
    _ownCosts = [ownPro.homeFoodCost doubleValue];
    _objectCosts.text = [NSString stringWithFormat:@"%.2f",_ownCosts];
    
    [self refreshMoreSumLabel];
}

// 刷新竞品的每菜成本
-(void)refreshOtherSumLabel:(WSSuggestHomePro *)ownPro
{
    _isOtherExist = YES;

    _otherCosts = [ownPro.homeFoodCost doubleValue];
    _objectOtherCosts.text = [NSString stringWithFormat:@"%.2f",_otherCosts];
    
    [self refreshMoreSumLabel];
}

//更新每月每年的数据
-(void)refreshMoreSumLabel
{
    NSLog(@"_otherCosts %f  _ownCosts  %f   ",_otherCosts,_ownCosts);
    //本品和竞品都有值的时候在计算.
    if (_otherCosts && _ownCosts) {
        
        int dish;
        if (_dishClickedCntOrFormulaUsedCntTF.text) {
            dish = [_dishClickedCntOrFormulaUsedCntTF.text intValue];
            if (dish == 0 ) {
                dish = 1;
            }
        }else{
            dish = 1;
        }
        
        //每月剩下的费用
        double monthMore = (_otherCosts - _ownCosts) * dish * 30;
        _monthSaveCosts.text = [NSString stringWithFormat:@"%0.2f 元",monthMore];
        
        double yearMore = monthMore * 12;
        _yearSaveCosts.text = [NSString stringWithFormat:@"%0.2f 元",yearMore];
    }
}

//检测是否有品类
-(BOOL)isHasCateModel
{
    if (_ownSP_top || _otherSP_top) {
        
        return YES;
        
    }else{
        
        return NO;
    }
}

#pragma textDelegate
// 输入过程中,检测数字
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return [self validateNumber:string];
}

- (BOOL)validateNumber:(NSString*)number {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}

- (void) textFieldDidChange:(UITextField *) TextField{
    
    if (TextField == _dishClickedCntOrFormulaUsedCntTF) {
        
        
        [self refreshMoreSumLabel];
    }
}
//检测数字
- (BOOL)checkNum:(NSString *)str
{
    NSString *regex = @"^[0-9]+(\\.[0-9]+)?$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:str];
    if (!isMatch) {
        return NO;
    }
    return YES;
}

#pragma mark - event
-(void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    //检测_dish是否有值.
    if (_dishClickedCntOrFormulaUsedCntTF.text) {
        if (![self checkNum:_dishClickedCntOrFormulaUsedCntTF.text]) {
            [_dishClickedCntOrFormulaUsedCntTF shakeView];
        }
    }
}

- (IBAction)backClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveSuggest:(id)sender {
    
    if (!(_ownSP_top || _otherSP_top)) {
        NSString *title = NSLocalizedString(@"未填写任何内容", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
        
    }
    
    //点击确定的时候,拼接模型
    WSSuggestHomeModel *sh = [[WSSuggestHomeModel alloc] init];
    sh.ownSP_top = _ownSP_top;
    sh.otherSP_top = _otherSP_top;
    
    sh.sStype = _sStyle;
    
    sh.ownFoodCost = _objectCosts.text;
    sh.otherFoodCost = _objectOtherCosts.text;
    sh.clickRate = _dishClickedCntOrFormulaUsedCntTF.text;
    sh.monthMore = _monthSaveCosts.text;
    sh.yearMore = _yearSaveCosts.text;
    
    _suggestHome = [[WSSuggestHome alloc] init];
    //归档
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:sh];
    
    if (_suhome) {
        _suggestHome.ID = _suhome.ID;
    }
    
    _suggestHome.item = data;
    _suggestHome.dType = @"01";
   
    _suggestHome.sugHomeModel = sh;

    //建议单名称
    if ([_suggestNameLabel.text isEqualToString:@""]) {
        [_suggestNameLabel shakeView];
        return;
    }
     _suggestHome.name = _suggestNameLabel.text;
    
    BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:@"是否保存为模板"];
    
    [alert setDestructiveButtonWithTitle:@"confirm" block:^{
        
        //这里只负责模板数据的对比(去重)
        [self updateTableWithType:@"01" homeModel:_suggestHome];
        
        [self dismissViewControllerAnimated:YES completion:^{
            
            if (_sug) {
                _sug(_suggestHome);
            }
            
        }];
        
    }];
    
    [alert setCancelButtonWithTitle:@"cancel_label" block:^{
        
        [self dismissViewControllerAnimated:YES completion:^{
            
            if (_sug) {
                _sug(_suggestHome);
            }
            
        }];
    }];
    [alert show];
    
}

//更新数据库(重复的去重,不重复添加)
-(void)updateTableWithType:(NSString *)type homeModel:(WSSuggestHome *)home
{
    //模板数据
    NSMutableArray * localTempArray = [[[WSSuggestListTable sharedTable] queryTableForSuggestListType:type className:@"WSSuggestHome"] mutableCopy];
        
        BOOL isTempReplace = NO;
        for (int i = 0; i < localTempArray.count; i++) {
            
            WSSuggestHome *arrItem = localTempArray[i];
            
            if ([home.name isEqualToString:arrItem.name]) {
                
                [localTempArray replaceObjectAtIndex:i withObject:home];
                
                [[WSSuggestListTable sharedTable] updateWithNames:@[@"item"] values:@[home.item] whereName:@[@"name",@"sid",@"type"] whereValue:@[home.name,@"0",type]];
                
                isTempReplace = YES;
            }
        }
        if (!isTempReplace) {
            [localTempArray addObject:home];
            [[WSSuggestListTable sharedTable] insertTableWithType:type homeModel:home sid:@"0" withbiz_date:self.prepareDate];
        }
}

#pragma mark - 通知
-(UIViewController *)viewController
{
    for (UIView *next = [self.view superview]; next; next = next.superview)
    {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    if ([_dishClickedCntOrFormulaUsedCntTF isFirstResponder]) {
        
        [self keyboardOffsetWithView:_dishClickedCntOrFormulaUsedCntTF :notification];
    }
}

///键盘消失事件
- (void) keyboardWillHide:(NSNotification *)notify {
    double duration = [[notify.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    UIViewController *viewController = [self viewController];
    UIView *view = viewController.view;
    [UIView animateWithDuration:duration animations:^{
        view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    }];
}
/**
 *  键盘偏移量的计算
 */
-(void)keyboardOffsetWithView:(UIView *)firstResponderView :(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    CGFloat kbHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    UIView *view = self.view;
    
//    CGRect rc = [firstResponderView convertRect:firstResponderView.frame toView:view];
    
    CGFloat offset = (firstResponderView.origin.y + firstResponderView.size.height + 20) - (view.size.height - kbHeight);
    
    if(offset > 0) {
        [UIView animateWithDuration:animationDuration animations:^{
            view.frame = CGRectMake(0.0f, -offset, view.width, view.height);
        }];
    }
}


#pragma mark - setter,getter
-(WSProductDetails *)proDetailView
{
    _proDetailView  = [WSProductDetails productDetailView];
    return _proDetailView;
}

-(void)setSuhome:(WSSuggestHome *)suhome
{
    _suhome = suhome;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
@end

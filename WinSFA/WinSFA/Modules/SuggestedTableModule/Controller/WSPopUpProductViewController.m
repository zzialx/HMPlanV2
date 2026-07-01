//
//  WSPopUpProductViewController.m
//  WinSFA
//
//  Created by huzepei on 16/7/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "PureLayout.h"
#import "WSPopUpProductViewController.h"
#import "UIView+Shake.h"
#import "WSSuggestProduct.h"
#import "YYModel.h"
#import "WSSuggestDataFactory.h"
#import "WSBrandModel.h"
#import "WSCateModel.h"
#import "WSSuggestWholesale.h"
#import "WSSugFilterModel.h"
#import "WSBaseDictsTable.h"
#import "UIView+ViewController.h"

#define TopMargindIstance 65

@interface WSPopUpProductViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    BOOL  _isChooseProduct;
}
//产品
@property (weak, nonatomic) IBOutlet UITextField *product_input;
//每箱利润
@property (weak, nonatomic) IBOutlet UITextField *profits_input;
//每月销量
@property (weak, nonatomic) IBOutlet UITextField *sales_input;

@property (nonatomic,strong) NSMutableArray *resultArr;
@property (weak, nonatomic) IBOutlet UIView *productView;
@property (nonatomic,strong) UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *middleView;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *producTitleHeight;
@property (weak, nonatomic) IBOutlet UIView *salesView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *salesViewHeight;

//品类
@property (weak, nonatomic) IBOutlet UITextField *cate_input;
//品牌
@property (weak, nonatomic) IBOutlet UITextField *brand_input;
// 顶部的距离
@property (nonatomic,strong) NSLayoutConstraint * tableViewMarginTop;

//数据源 -> 时间紧迫,先这么写了
@property (nonatomic,strong) NSArray *brandOwnArray;
@property (nonatomic,strong) NSArray *brandOtherArray;
//公用的
@property (nonatomic,strong) NSArray *cateArray;

//产品数组
@property (nonatomic,strong) NSArray *proArray;

//当前选中的model(品牌和品类)
@property (nonatomic,strong) WSCateModel *currentCateModel;
@property (nonatomic,strong) WSBrandModel *currentBrandModel;
@property (nonatomic,strong) WSSuggestPro *currentSP;

//有效品牌与品类对应数组.
@property (nonatomic,strong) NSMutableArray *avProArray;
@property (nonatomic,strong) NSMutableArray *avcompArray;

//有效的本品数组
@property (nonatomic,strong) NSMutableArray *avpArray;
//有效的竞品数组
@property (nonatomic,strong) NSMutableArray *avcArray;

@property (weak, nonatomic) IBOutlet UILabel *proAttribute;


@end

@implementation WSPopUpProductViewController

#pragma mark - view cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadDatas];
    
    [self setUpViews];
    
    [self creatTableView];
    
    //键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
}
-(void)loadDatas
{
    _avpArray = [NSMutableArray array];
    _avcArray = [NSMutableArray array];

    //获取本品的品牌数组
    _brandOwnArray = [WSSuggestDataFactory suggestBrandForType:@"prod"];
    
    //获取竞品的品牌数组
    _brandOtherArray = [WSSuggestDataFactory suggestBrandForType:@"comp"];
    
    //获取品类数组
    _cateArray = [WSSuggestDataFactory suggestCategory];
    
    //获取所有数据(1:本品)
    NSArray * proArray = [WSSuggestDataFactory suggestAVProType:@"1" className:@"WSSuggestPro"];
    
    //获取所有数据(2:竟品)
    NSArray * compArray = [WSSuggestDataFactory suggestAVProType:@"2" className:@"WSSuggestPro"];
    
    //获取有效数据
    _avProArray = [self filterAvData:proArray brandArray:_brandOwnArray pros:_avpArray];
    _avcompArray = [self filterAvData:compArray brandArray:_brandOtherArray pros:_avcArray];
    
}

-(void)setUpViews
{
    //后期添加的搜索按钮
    _brand_input.rightView = [self generateRightViewWithTag:3001];
    _brand_input.delegate = self;
    [_brand_input addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _brand_input.rightViewMode = UITextFieldViewModeAlways;
    
    _cate_input.rightView = [self generateRightViewWithTag:3002];
    _cate_input.delegate = self;
    [_cate_input addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _cate_input.rightViewMode = UITextFieldViewModeAlways;
    
    if (_curOutCateModel) {
        _cate_input.text = _curOutCateModel.name;
        [_cate_input setUserInteractionEnabled:NO];
        [_cate_input setBackground:[UIImage imageForName:@"inputNoEdit.png"]];
    }
    
    
    _product_input.rightView = [self generateRightViewWithTag:3003];
    _product_input.delegate = self;
    [_product_input addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _product_input.rightViewMode = UITextFieldViewModeAlways;
    
    [self.profits_input addTarget:self action:@selector(textFieldDidChange2:) forControlEvents:UIControlEventEditingChanged];
    [self.sales_input addTarget:self action:@selector(textFieldDidChange2:) forControlEvents:UIControlEventEditingChanged];
    
}

-(UIView *)generateRightViewWithTag:(int)tag
{
    UIView *rightVeiw = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBtn setImage:[UIImage imageForName:@"suggest_search.png"] forState:UIControlStateNormal];
    
    searchBtn.tag  = tag;
    searchBtn.center = rightVeiw.center;
    searchBtn.bounds = CGRectMake(0,0,searchBtn.currentImage.size.width + 20,searchBtn.currentImage.size.height + 20);
    [searchBtn addTarget:self action:@selector(searchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [rightVeiw addSubview:searchBtn];
    return rightVeiw;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)creatTableView
{
    self.tableView  = [[UITableView alloc] init];
    self.tableView.hidden = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.tableView];
    
    [self.tableView autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:_brand_input];
    
    _tableViewMarginTop = [self.tableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_brand_input];
    
    [self.tableView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:_brand_input];
//    [self.tableView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view];
    [self.tableView autoSetDimension:ALDimensionHeight toSize:300];
    
}
/**
 *  解决系统分割线不能设置到顶部-避免自定义分割线
 */
-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
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
    
    if ([_profits_input isFirstResponder]) {
        
        [self keyboardOffsetWithView:_profits_input :notification];
    }
    
    if ([_sales_input isFirstResponder]) {
        
        [self keyboardOffsetWithView:_sales_input :notification];
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
    
    UIViewController *viewController = [self viewController];
    UIView *view = viewController.view;
    
    CGRect rc = [firstResponderView convertRect:firstResponderView.frame toView:view];
    CGFloat offset = (rc.origin.y + rc.size.height + 20) - (view.size.height - kbHeight);
    
    if(offset > 0) {
        [UIView animateWithDuration:animationDuration animations:^{
            view.frame = CGRectMake(0.0f, -offset, view.width, view.height);
        }];
    }
}

#pragma mark - enevt
- (void)confirmBtnClick{

    _currentSP.boxProfits = _profits_input.text;
    _currentSP.month_sales = _sales_input.text;

    if (_sp) {
        _sp(_currentSP,_currentCateModel);
    }
    
}
- (void)searchBtnClick:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    
    self.tableView.hidden  = !self.tableView.hidden;
    
    //当tableView是隐藏的时候,如果输入框内为空,消除当前的对象
    if (self.tableView.hidden == YES) {
        if ([_brand_input.text isEqualToString:@""]) {
            _currentBrandModel = nil;
        }
        
        if ([_cate_input.text isEqualToString:@""]) {
            _currentCateModel = nil;
            _product_input.text = @"";
        }
        
        if ([_product_input.text isEqualToString:@""]) {
            _currentSP = nil;
        }
    }

    
    if (btn.tag == 3001) {  //品牌
        
        _tableViewMarginTop.constant = 0 * TopMargindIstance;
        self.brand_input.text = @"";
        
        if (_proType == 0) {
            
            [self showBrandArr:_avProArray];
            
        }else
        {
            
            [self showBrandArr:_avcompArray];
        }
        
    }else if (btn.tag == 3002){  //品类
        
        _tableViewMarginTop.constant = 1 * TopMargindIstance;
        self.cate_input.text = @"";
        
        //加载有效品类
        if (_proType == 0) {
            
            [self showCateArr:_avProArray];

        }else{//加载有效竞品品牌的数组
            
            [self showCateArr:_avcompArray];
            
        }
        
        self.resultArr = self.dataArr;
        
    }else if (btn.tag == 3003){  //产品
        
        _tableViewMarginTop.constant = 2 * TopMargindIstance;
        self.product_input.text = @"";
        
        
        if (_proType == 0) {
            
            [self showProArr:_avpArray];
            
        }else{
            
            [self showProArr:_avcArray];
        }
        
        self.resultArr = self.dataArr;

    }
    
    [self.tableView reloadData];
    
}

// 本品和竞品的显示逻辑.(品类)

-(void)showCateArr:(NSMutableArray *)pros
{
    if (_currentBrandModel) {  //如果有品牌,加载的是联动品类
        
        //加载有效本品品牌的数组
        NSMutableArray *temp = [NSMutableArray array];
        for (WSSugAvProModel * sugPro in pros) {
            
            if ([_currentBrandModel._id isEqualToString:sugPro.brand._id]) {
                temp = [sugPro.avCate mutableCopy];
            }
            
        }
        self.dataArr = temp;
        
    }else{ //否则加载的非联动的有效品类
        
        NSMutableArray *temp = [NSMutableArray array];
        for (WSSugAvProModel * sugPro in pros) {
            
            [temp addObjectsFromArray:sugPro.avCate];
            
        }
        self.dataArr = temp;
    }
    
}

// 本品和竞品的显示逻辑.(品牌)
-(void)showBrandArr:(NSMutableArray *)pros
{
    
    //加载有效本品品牌的数组
    NSMutableArray *temp = [NSMutableArray array];
    for (WSSugAvProModel * sugPro in pros) {
        
        [temp addObject:sugPro.brand];
        
    }
    self.dataArr = temp;
    
    //如果当前已经有了品类,那么只查询当前品类下面的品牌
    
    if (_curOutCateModel || _currentCateModel) {
        
        
        if (_curOutCateModel) {
            //根据当前的品类,查找
            NSMutableArray *temp = [NSMutableArray array];
            for (WSSugAvProModel * sugPro in pros) {
                
                for (WSCateModel *cateModel in sugPro.avCate) {
                    
                    if ([_curOutCateModel._id isEqualToString:cateModel._id]) {
                        [temp addObject:sugPro.brand];
                    }
                    
                }
                
                self.dataArr = temp;
                
            }
            
        }else{
            
            NSMutableArray *temp = [NSMutableArray array];
            for (WSSugAvProModel * sugPro in pros) {
                
                for (WSCateModel *cateModel in sugPro.avCate) {
                    
                    if ([_currentCateModel._id isEqualToString:cateModel._id]) {
                        [temp addObject:sugPro.brand];
                    }
                    
                }
            }
            
            self.dataArr = temp;
        }


        //根据当前的品类,查找
//        NSMutableArray *temp = [NSMutableArray array];
//        for (WSSugAvProModel * sugPro in pros) {
//            
//            for (WSCateModel *cateModel in sugPro.avCate) {
//                
//                if ([_currentCateModel._id isEqualToString:cateModel._id]) {
//                    [temp addObject:sugPro.brand];
//                }
//                
//            }
//        }
//        self.dataArr = temp;
    }
    self.resultArr = self.dataArr;

}

// 本品和竞品的显示逻辑.(产品)
-(void)showProArr:(NSMutableArray *)pros
{
    //temp数组显示品牌
    NSMutableArray *temp = [NSMutableArray array];
    
    if (!_currentCateModel && !_currentBrandModel && !_curOutCateModel) {  //如果两个都没有值
        
        //显示本品的有效数组
        self.dataArr = pros;
        
    }else if(_currentBrandModel && !(_currentCateModel || _curOutCateModel)){ //只有品牌有值,品类没有值
        
        //从有效数组中,查找出有品牌的值.
        for (WSSuggestPro * sp in pros) {
            
            if ([sp.brand isEqualToString:_currentBrandModel._id]) {
                [temp addObject:sp];
            }
        }
        
        self.dataArr = [temp mutableCopy];
        
    }else if (!_currentBrandModel && (_currentCateModel || _curOutCateModel)){  //品牌没有值,品类有值
        
        if (_curOutCateModel) {
            
            //从有效数组中,查找出有品类的值.
            for (WSSuggestPro * sp in pros) {
                
                if ([sp.memo1 isEqualToString:_curOutCateModel._id]) {
                    [temp addObject:sp];
                }
            }
            
            self.dataArr = [temp mutableCopy];
            
        }else{
            
            //从有效数组中,查找出有品类的值.
            for (WSSuggestPro * sp in pros) {
                
                if ([sp.memo1 isEqualToString:_currentCateModel._id]) {
                    [temp addObject:sp];
                }
            }
            self.dataArr = [temp mutableCopy];
        }
        
//        //从有效数组中,查找出有品类的值.
//        for (WSSuggestPro * sp in pros) {
//            
//            if ([sp.memo1 isEqualToString:_currentCateModel._id]) {
//                [temp addObject:sp];
//            }
//        }
//        self.dataArr = [temp mutableCopy];
        
        
    }else{ //都有值
        
        //加载品牌和品类过滤后的数组,根据品牌ID和品类ID来过滤
        
        if (_curOutCateModel) {
            
            _proArray = [WSSuggestDataFactory suggestProForBrand:_currentBrandModel._id cate:_curOutCateModel._id className:@"WSSuggestPro"];
            
        }else{
            
            //加载品牌和品类过滤后的数组,根据品牌ID和品类ID来过滤
            _proArray = [WSSuggestDataFactory suggestProForBrand:_currentBrandModel._id cate:_currentCateModel._id className:@"WSSuggestPro"];
        }
        
//        _proArray = [WSSuggestDataFactory suggestProForBrand:_currentBrandModel._id cate:_currentCateModel._id className:@"WSSuggestPro"];
        self.dataArr = [_proArray mutableCopy];
        self.resultArr = self.dataArr;
    }
    
}


#pragma mark - tableViewDelagate detaSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"SuggestProduct";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.selectionStyle =UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.numberOfLines = 0;
    }
    
    //判断
    if (_tableViewMarginTop.constant == 0 * TopMargindIstance) { //品牌
        
        WSBrandModel *brandModel = self.dataArr[indexPath.row];
        cell.textLabel.text = brandModel.name;
        
    }else if (_tableViewMarginTop.constant == 1 * TopMargindIstance){ //品类
        
        WSCateModel *cateModel = self.dataArr[indexPath.row];
        cell.textLabel.text = cateModel.name;
        
    }else{ //产品
        
        WSSuggestPro *pro = self.dataArr[indexPath.row];
        cell.textLabel.text = pro.name;
    }
    
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //判断
    CGSize size;
    if (_tableViewMarginTop.constant == 0 * TopMargindIstance) { //品牌
        
        WSBrandModel *brandModel = self.dataArr[indexPath.row];
        size = [brandModel.name ws_sizeWithFont:[UIFont systemFontOfSize:16.0] constrainedToWidth:250.0 lineBreakMode:NSLineBreakByWordWrapping];
        
    }else if (_tableViewMarginTop.constant == 1 * TopMargindIstance){ //品类
        
        WSCateModel *cateModel = self.dataArr[indexPath.row];
        size = [cateModel.name ws_sizeWithFont:[UIFont systemFontOfSize:16.0] constrainedToWidth:250.0 lineBreakMode:NSLineBreakByWordWrapping];
        
    }else{ //产品
        WSSuggestPro *pro = self.dataArr[indexPath.row];
        size = [pro.name ws_sizeWithFont:[UIFont systemFontOfSize:16.0] constrainedToWidth:250.0 lineBreakMode:NSLineBreakByWordWrapping];
        
        
    }
    return size.height + 20;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_tableViewMarginTop.constant == 0 * TopMargindIstance) { //品牌
        
        _currentBrandModel = self.dataArr[indexPath.row];
        [self.brand_input setText:_currentBrandModel.name];
        [self.brand_input resignFirstResponder];
        
        
        if (_curOutCateModel) {
            
            _product_input.text  = @"";
            
            _proArray = [WSSuggestDataFactory suggestProForBrand:_currentBrandModel._id cate:_curOutCateModel._id className:@"WSSuggestPro"];
            
        }else if(_currentCateModel){
          
          _product_input.text  = @"";
          _proArray = [WSSuggestDataFactory suggestProForBrand:_currentBrandModel._id cate:_currentCateModel._id className:@"WSSuggestPro"];

        }else{
            _cate_input.text = @"";
            _product_input.text  = @"";
            
            [_cate_input setUserInteractionEnabled:YES];
            [_cate_input setBackground:[UIImage imageForName:@"input.png"]];
        }
        
        
    }else if (_tableViewMarginTop.constant == 1 * TopMargindIstance){ //品类
        
        _product_input.text  = @"";
        
        _currentCateModel = self.dataArr[indexPath.row];
        [self.cate_input setText:_currentCateModel.name];
        [self.cate_input resignFirstResponder];
        
        _proArray = [WSSuggestDataFactory suggestProForBrand:_currentBrandModel._id cate:_currentCateModel._id className:@"WSSuggestPro"];
        
        if (_currentCate) {
            _currentCate(_currentCateModel);
        }

    }else{ //产品
        
        _currentSP = self.dataArr[indexPath.row];
        _isChooseProduct = YES;
        [self.product_input setText:_currentSP.name];
        [self.product_input resignFirstResponder];
        
        //选择完产品之后,自动更新到品牌和品类
        if (_proType == 0) {
            
            for (WSSugAvProModel * sugPro in _avProArray) {
                
                if ([_currentSP.brand isEqualToString:sugPro.brand._id]) {
                    _brand_input.text = sugPro.brand.name;
                    _currentBrandModel = sugPro.brand;
                }
                
                for (WSCateModel *cate in sugPro.avCate) {
                    
                    if ([_currentSP.memo1 isEqualToString:cate._id]) {
                        _cate_input.text = cate.name;
                        _currentCateModel = cate;
                    }
                }
            }
            
            
        }else{
            
            for (WSSugAvProModel * sugPro in _avcompArray) {
                
                if ([_currentSP.brand isEqualToString:sugPro.brand._id]) {
                    _brand_input.text = sugPro.brand.name;
                    _currentBrandModel = sugPro.brand;
                }
                
                for (WSCateModel *cate in sugPro.avCate) {
                    
                    if ([_currentSP.memo1 isEqualToString:cate._id]) {
                        _cate_input.text = cate.name;
                        _currentCateModel = cate;
                    }
                }
            }
            
        }
        
        //更新产品属性
        if (![_currentSP.memo4 isEqualToString:@""]) {
            _proAttribute.text = _currentSP.memo4;
        }else{
            _proAttribute.text = @"empty_instruction_sheet_label";
        }
        
        if (_currentCate) {
            _currentCate(_currentCateModel);
        }
        
    }
    self.tableView.hidden = YES;
}

#pragma mark - UITextFieldDelegate

// 输入过程中,检测数字
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL a;
    if (textField == _profits_input || textField == _sales_input) {
        a = [self validateNumber:string];
    }else{
        a = YES;
    }
    return a;
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == nil) {
        
        self.tableView.hidden = YES;
        
    }
    
    if (textField == _brand_input) {
        
        self.tableView.hidden = NO;
        
        _tableViewMarginTop.constant = 0 * TopMargindIstance;
        
        if (_proType == 0) {
            
            [self showBrandArr:_avProArray];
            
        }else{
            
            [self showBrandArr:_avcompArray];
        }
        self.resultArr = self.dataArr;
        [self.tableView reloadData];

        
    }else if (textField == _cate_input){
        
        self.tableView.hidden = NO;
        
        _tableViewMarginTop.constant = 1 * TopMargindIstance;
        
        if (_proType == 0) {
            
            [self showCateArr:_avProArray];
            
        }else{
            
            [self showCateArr:_avcompArray];
        }
        self.resultArr = self.dataArr;
        [self.tableView reloadData];

        
    }else if (textField == _product_input){
        
        self.tableView.hidden = NO;
        
        _tableViewMarginTop.constant = 2 * TopMargindIstance;
        
        if (_proType == 0) {
            
            [self showProArr:_avpArray];
            
        }else{
            
            [self showProArr:_avcArray];
        }
        self.resultArr = self.dataArr;
        [self.tableView reloadData];
    }
    
    
    return YES;
}

- (void) textFieldDidChange2:(UITextField *) TextField{
    
    [self confirmBtnClick];
    
}


- (void) textFieldDidChange:(UITextField *) TextField{
    
    if (TextField == nil) {
        
        self.tableView.hidden = YES;
        
    }else{
        
        if (TextField == _brand_input) {
            
            _tableViewMarginTop.constant = 0 * TopMargindIstance;
            
            
        }else if (TextField == _cate_input){
            
            _tableViewMarginTop.constant = 1 * TopMargindIstance;
            
            
        }else if (TextField == _product_input){
            
            _tableViewMarginTop.constant = 2 * TopMargindIstance;
          
        }
        
        self.tableView.hidden = NO;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains %@",TextField.text];
        
        self.dataArr = [[self.resultArr filteredArrayUsingPredicate:predicate] mutableCopy];
        
        if ([TextField.text isEqualToString:@""]) {
            self.dataArr = self.resultArr;
        }
        
        [self.tableView reloadData];
    }
}

-(BOOL)textFieldShouldClear:(UITextField *)textField{
    
    [self.tableView reloadData];
    
    return YES;
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    
//    if (textField == _brand_input) {
//        
//        if (!_currentBrandModel) {
//            textField.text = @"";
//        }
//        
//        
//    }else if (textField == _cate_input){
//        
//        if (!_currentCateModel) {
//            textField.text = @"";
//        }
//        
//        
//    }else if (textField == _product_input){
//        
//        if (!_currentSP) {
//            textField.text = @"";
//        }
//        
//    }
//    self.tableView.hidden = YES;
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    self.tableView.hidden = YES;
    return YES;
}

#pragma mark - Functional logic
/**
 *  过滤有效数据
 */
-(NSMutableArray *)filterAvData:(NSArray *)proArray brandArray:(NSArray *)brandArr pros:(NSMutableArray *)pros
{
    NSMutableArray *sugFilterArr = [NSMutableArray array];
    NSMutableArray *sugAvModelArr = [NSMutableArray array];
    
    for (int i = 0; i < proArray.count; i++) {
        
        WSSuggestPro * curPro = proArray[i];

        WSCateModel *curCate = [WSCateModel new];
        WSBrandModel *curBrand = [WSBrandModel new];
        
        BOOL isAvBrand = NO;
        BOOL isAvCate = NO;
        
        for (WSCateModel *cate in _cateArray) {
            
            if ([curPro.memo1 isEqualToString:cate._id]) { //能找到数据
                curCate = cate;
                isAvCate = YES;
            }
        }
        
        for (WSBrandModel *brand in brandArr) {
            
            if ([curPro.brand isEqualToString:brand._id]) { //能找到数据
                curBrand = brand;
                isAvBrand = YES;
            }
        }
        
        // 如果找到了品牌和品类
        if (isAvCate == YES && isAvBrand == YES) {
            
            WSSugFilterModel *sugFilter = [[WSSugFilterModel alloc] init];
            sugFilter.cate = curCate;
            sugFilter.brand = curBrand;
            
            //有效的产品数组
            [pros addObject:curPro];
            
            [sugFilterArr addObject:sugFilter];
           
        }
    }
   //有效品牌数组
    NSMutableArray *avBrandArr = [sugFilterArr valueForKeyPath:@"@distinctUnionOfObjects.brand"];
    
    for (WSBrandModel *brand in avBrandArr) {
        
        WSSugAvProModel *avPro = [WSSugAvProModel new];
        avPro.brand = brand;
        
        NSMutableArray *avCateArr = [NSMutableArray array];
        for (WSSugFilterModel *sugFilter in sugFilterArr) {
            
            if ([brand._id isEqualToString:sugFilter.brand._id]) {
                [avCateArr addObject:sugFilter.cate];
                
            }
        }
        avPro.avCate = [[avCateArr valueForKeyPath:@"@distinctUnionOfObjects.self"] copy];
        
        [sugAvModelArr addObject:avPro];
    }
    return sugAvModelArr;
}

/**
 *  检测空值
 */
-(BOOL)checkValue
{
    if ([_product_input.text isEqual:@""] && _productView.hidden == NO) {
        [_product_input shakeView];
        return NO;
        
    }else if ([_profits_input.text isEqual:@""] || ![self checkNum:_profits_input.text])
    {
         [_profits_input shakeView];
        return NO;
    }else if([_sales_input.text isEqual:@""] || ![self checkNum:_sales_input.text]){
        [_sales_input shakeView];
        return NO;
    }
    return YES;
}
/**
 *  检测数字,小数
 */
- (BOOL)checkNum:(NSString *)str
{
    NSString *regex = @"^[0-9]+([.]{0,1}[0-9]+){0,1}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:str];
    if (!isMatch) {
        return NO;
    }
    return YES;
}

#pragma mark - setter,getter
-(void)setCurOutCateModel:(WSCateModel *)curOutCateModel
{
    _curOutCateModel = curOutCateModel;
    
    if (_curOutCateModel) {
        _cate_input.text = _curOutCateModel.name;
        [_cate_input setUserInteractionEnabled:NO];
        [_cate_input setBackground:[UIImage imageForName:@"inputNoEdit.png"]];
    }
}

-(void)setSww:(WSSuggestPro *)sww
{
    _sww = sww;
    
    //赋值,品牌,品类和产品为不可修改
    [_cate_input setUserInteractionEnabled:NO];
    [_cate_input setBackground:[UIImage imageForName:@"inputNoEdit.png"]];
    [_brand_input setUserInteractionEnabled:NO];
    [_brand_input setBackground:[UIImage imageForName:@"inputNoEdit.png"]];
    [_product_input setUserInteractionEnabled:NO];
    [_product_input setBackground:[UIImage imageForName:@"inputNoEdit.png"]];
    
    //view赋值
    NSString *brandStr = [NSString stringWithFormat:@"SELECT dicts.name FROM  base_dicts AS dicts WHERE dicts._id = '%@';",_sww.brand];
    NSMutableArray *brandArr = [[WSBaseDictsTable sharedTable] queryDatasBySql:brandStr columnArr:@[@"name"]];
    NSString *cateStr = [NSString stringWithFormat:@"SELECT dicts.name FROM  base_dicts AS dicts WHERE dicts._id = '%@';",_sww.memo1];
    NSMutableArray *cateArr = [[WSBaseDictsTable sharedTable] queryDatasBySql:cateStr columnArr:@[@"name"]];

    [_cate_input setText:cateArr[0]];
    [_brand_input setText:brandArr[0]];
    [_product_input setText:_sww.name];
    [_profits_input setText:_sww.boxProfits];
    [_sales_input setText:_sww.month_sales];
    
    //更新memo4
    if (![_sww.memo4 isEqualToString:@""]) {
        _proAttribute.text = _sww.memo4;
    }else{
        _proAttribute.text = @"empty_instruction_sheet_label";
    }
    
    //模型赋值给当前current
    _currentSP = _sww;
}

-(void)setShowProdTitle:(BOOL)showProdTitle
{
    _showProdTitle = showProdTitle;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

@end

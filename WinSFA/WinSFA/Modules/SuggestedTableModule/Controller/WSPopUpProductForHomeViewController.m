//
//  WSPopUpProductForHomeViewController.m
//  WinSFA
//
//  Created by HZH on 16/9/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSPopUpProductForHomeViewController.h"
#import "WSSuggestTableInstance.h"

#import "YYModel.h"
#import "PureLayout.h"
#import "WSSuggestDataFactory.h"
#import "WSBrandModel.h"
#import "WSCateModel.h"
#import "WSSuggestHome.h"
#import "UIView+Shake.h"
#import "WSBaseDictsTable.h"
#import "WSSugFilterModel.h"
#import "WSHomeProDetails.h"
#import "WSHTextField.h"

#define TopMargindIstance SEARCHBARPADDING

#define HPOPVIEWWIDTH 450
#define HPOPVIEWHEIGHT 270

#define SEARCHBARHEIGHT 30
#define SEARCHBARPADDING  60

@interface WSPopUpProductForHomeViewController () <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    UISegmentedControl *_styleSC;
    NSMutableArray *_textFieldMArray;
    NSMutableArray *_staticLabelMArray;
    // 配方类型 [01:对比产品配方  02:自制配方]
    NSString *_sFormulaStyle;
    BOOL  _isChooseProduct;
    BOOL isFirst; // 是不是第一次加载配方应用的子视图
}
@property (nonatomic, assign) CGSize viewSize;

//数据源
@property (nonatomic,strong) NSMutableArray *resultArr;
@property (nonatomic,strong) NSMutableArray *dataArr;

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIButton *cancelBtn;

// 顶部的距离
@property (nonatomic,strong) NSLayoutConstraint * tableViewMarginTop;

//数据源 -> 时间紧迫,先这么写了
@property (nonatomic,strong) NSArray *brandOwnArray;
@property (nonatomic,strong) NSArray *brandOtherArray;

//公用的
@property (nonatomic,strong) NSArray *cateArray;

//品类
@property (strong, nonatomic)  UITextField *cate_input;
//品牌
@property (strong, nonatomic)  UITextField *brand_input;
//产品
@property (strong, nonatomic)  UITextField *product_input;

//每箱价格
@property (strong, nonatomic)  UITextField *price_input;

//每菜用量（配方中为配方用量）
@property (strong, nonatomic)  UITextField *dosage_input;

@property (strong, nonatomic) WSHomeProDetails *pd;

//产品数组
@property (nonatomic,strong) NSArray *proArray;

@property (nonatomic,strong)UIView *bgView;

//当前选中的model(品牌和品类)
@property (nonatomic,strong) WSCateModel *currentCateModel;
@property (nonatomic,strong) WSBrandModel *currentBrandModel;
@property (nonatomic,strong) WSSuggestHomePro *currentSP;

//有效品牌与品类对应数组.
@property (nonatomic,strong) NSMutableArray *avProArray;
@property (nonatomic,strong) NSMutableArray *avcompArray;

//有效的本品数组
@property (nonatomic,strong) NSMutableArray *avpArray;
//有效的竞品数组
@property (nonatomic,strong) NSMutableArray *avcArray;

@end

@implementation WSPopUpProductForHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadDatas];
    
    _sFormulaStyle = HSuggestTableForHomeFormulaProductCompare;
    _viewSize = CGSizeMake(0, 0);
    
    if ([_sStyle isEqualToString:HSuggestTableForHomeModelStyleDish]) {
        
        _viewSize = CGSizeMake(HPOPVIEWWIDTH, HPOPVIEWHEIGHT);
        
    }else if ([_sStyle isEqualToString:HSuggestTableForHomeModelStyleFormula]) {
        if ([_productOwnerType isEqualToString:@"01"]) {
            _viewSize = CGSizeMake(HPOPVIEWWIDTH, HPOPVIEWHEIGHT);
        }else if ([_productOwnerType isEqualToString:@"02"]) {
            _viewSize = CGSizeMake(HPOPVIEWWIDTH, HPOPVIEWHEIGHT + 50);
        }
    }
    
    [self buildUIWithType:_sStyle];
    [self creatTableView];
    
    [self loadResultView];
    

    //键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

-(void)loadDatas
{
    _avpArray = [NSMutableArray array];
    _avcArray = [NSMutableArray array];
    
    //获取本品的品牌数据
    _brandOwnArray = [WSSuggestDataFactory suggestBrandForType:@"prod"];
    
    //获取竞品的品牌数组
    _brandOtherArray = [WSSuggestDataFactory suggestBrandForType:@"comp"];
    
    //获取品类数组
    _cateArray = [WSSuggestDataFactory suggestCategory];
    
    //获取所有数据(1:本品)
    NSArray * proArray = [WSSuggestDataFactory suggestAVProType:@"1" className:@"WSSuggestHomePro"];
    
    //获取所有数据(2:竟品)
    NSArray * compArray = [WSSuggestDataFactory suggestAVProType:@"2" className:@"WSSuggestHomePro"];
    
    //获取有效数据
    _avProArray = [self filterAvData:proArray brandArray:_brandOwnArray pros:_avpArray];
    _avcompArray = [self filterAvData:compArray brandArray:_brandOtherArray pros:_avcArray];
    
}

- (void)buildUIWithType:(NSString *)type
{
    
    if ([type isEqualToString:HSuggestTableForHomeModelStyleDish]) {
        
        [self buildPartIViewWithFrame:CGRectMake(0, 0, _viewSize.width, _viewSize.height)];
        
        
    }else if ([type isEqualToString:HSuggestTableForHomeModelStyleFormula]){
        
        if ([_productOwnerType isEqualToString:@"01"]) {
            
            [self buildPartIViewWithFrame:CGRectMake(0, 0, _viewSize.width, _viewSize.height)];
            
        }else if ([_productOwnerType isEqualToString:@"02"]){
            
            [self buildPartIViewWithFrame:CGRectMake(0, 0, _viewSize.width, _viewSize.height)];
            
            _styleSC =[[UISegmentedControl alloc] init];
            [_styleSC insertSegmentWithTitle:@"对比产品" atIndex:0 animated:NO];
            [_styleSC insertSegmentWithTitle:@"自制配方" atIndex:1 animated:NO];
            
             [_styleSC addTarget:self action:@selector(styleSegmentControlValueChanged:) forControlEvents:UIControlEventValueChanged];
            
            _styleSC.selectedSegmentIndex = 1;
            
            [self styleSegmentControlValueChanged:_styleSC];

        }
    }
    
}

- (void)buildPartIViewWithFrame:(CGRect)frame
{
    _bgView = [[UIView alloc] initWithFrame:frame];
    
    NSArray *labelTextDataArray01 = [[NSArray alloc] initWithObjects:@"* 选择市场品牌:", @"* 选择品类:", @"* 选择产品:", @"* 每箱价格(元):", @"* 每菜用量:", nil];
    NSArray *labelTextDataArray02 = [[NSArray alloc] initWithObjects:@"* 选择市场品牌:", @"* 选择品类:", @"* 选择产品:", @"* 每箱价格(元):", @"* 配方用量(g/KG):", nil];
    
    _staticLabelMArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 5; i ++) {
        UILabel *staticLabel01 = [[UILabel alloc] initWithFrame:CGRectMake(20, SEARCHBARPADDING * i, (frame.size.width - 40)/3, SEARCHBARHEIGHT)];
        staticLabel01.backgroundColor = [UIColor clearColor];
        staticLabel01.textColor = [UIColor blackColor];
        staticLabel01.font = [UIFont systemFontOfSize:16.0];
        staticLabel01.text = @"* 选择市场品牌:";
        
        [_staticLabelMArray addObject:staticLabel01];
        [_bgView addSubview:staticLabel01];
    }
    
    _textFieldMArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 5; i ++) {
        
        UITextField *mTextField01 = [[UITextField alloc] initWithFrame:CGRectMake((frame.size.width - 40)/3 + 20, SEARCHBARPADDING * i, (frame.size.width - 40)/3 * 2, SEARCHBARHEIGHT)];
        
        UIView *blankView = [[UIView alloc] initWithFrame:CGRectMake(mTextField01.frame.origin.x,mTextField01.frame.origin.y, 8.0, mTextField01.frame.size.height)];
        mTextField01.leftView = blankView;
        mTextField01.leftViewMode =UITextFieldViewModeAlways;  // 这里是用来设置leftView的实现时机的
        
        mTextField01.placeholder = @"please_fill_in";
        mTextField01.background = [UIImage imageNamed:@"input"];
        mTextField01.tintColor = UIColorFromRGBWithAlpha(POP_MAIN_THEME_COLOR, 1);

        
        [_textFieldMArray addObject:mTextField01];
        [_bgView addSubview:mTextField01];
    }
    
    self.brand_input = _textFieldMArray[0];
    self.cate_input = _textFieldMArray[1];
    self.product_input = _textFieldMArray[2];
    
    self.price_input = _textFieldMArray[3];
    self.price_input.delegate = self;
    self.dosage_input = _textFieldMArray[4];
    self.dosage_input.delegate = self;
    
    
    [self.price_input addTarget:self action:@selector(textFieldDidChange2:) forControlEvents:UIControlEventEditingChanged];
    [self.dosage_input addTarget:self action:@selector(textFieldDidChange2:) forControlEvents:UIControlEventEditingChanged];
    [self.brand_input addTarget:self action:@selector(textFieldDidChange2:) forControlEvents:UIControlEventEditingChanged];
    [self.cate_input addTarget:self action:@selector(textFieldDidChange2:) forControlEvents:UIControlEventEditingChanged];
    [self.product_input addTarget:self action:@selector(textFieldDidChange2:) forControlEvents:UIControlEventEditingChanged];
    
    
    self.price_input.keyboardType = UIKeyboardTypeNumberPad;
    self.dosage_input.keyboardType = UIKeyboardTypeNumberPad;
    

    if (_curOutCateModel) {
        _cate_input.text = _curOutCateModel.name;
        [_cate_input setUserInteractionEnabled:NO];
        [_cate_input setBackground:[UIImage imageForName:@"inputNoEdit.png"]];
    }
   
    [self buildViewDetails];
    
    if ([_sStyle isEqualToString:@"01"]) {
        
        for (int i = 0; i < 5; i ++) {
            UILabel *label = (UILabel *)[_staticLabelMArray objectAtIndex:i];
            
            label.text = [labelTextDataArray01 objectAtIndex:i];
        }
        
    }else if ([_sStyle isEqualToString:@"02"]) {
        
        for (int i = 0; i < 5; i ++) {
            UILabel *label = (UILabel *)[_staticLabelMArray objectAtIndex:i];
            
            label.text = [labelTextDataArray02 objectAtIndex:i];
        }
    }
    
    [self.view addSubview:_bgView];
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
    
    if ([_price_input isFirstResponder]) {
        
        [self keyboardOffsetWithView:_price_input :notification];
    }
    
    if ([_dosage_input isFirstResponder]) {
        
        [self keyboardOffsetWithView:_dosage_input :notification];
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
    CGFloat offset = (rc.origin.y + rc.size.height + 20) - (view.size.height - kbHeight) - 180;
    
    if(offset > 0) {
        [UIView animateWithDuration:animationDuration animations:^{
            view.frame = CGRectMake(0.0f, -offset, view.width, view.height);
        }];
    }
}



/**
 *  加载结果View,区分本品和竞品 - 区别配方 - 配方区别
 */
-(void)loadResultView
{
    CGFloat y = CGRectGetMaxY(self.dosage_input.frame) + 15;
    
    if ([_sStyle isEqualToString:@"01"]) {  //菜市应用
        
        _pd = [WSHomeProDetails homeProductDetailView];
        _pd.frame = CGRectMake(0, y, self.view.size.width, 300);
        _pd.type = @"1";
        [self.view insertSubview:_pd belowSubview:_bgView];
        
    }else{ //配方应用
        
        _pd = [WSHomeProDetails homeProductDetailView];
        _pd.frame = CGRectMake(0, y, self.view.size.width, 300);
        if (isFirst) {
            _pd.type = @"3";

        }else{
            _pd.type = @"2";

        }
        
        [self.view insertSubview:_pd belowSubview:_bgView];
    }
}


-(void)buildViewDetails
{
    //后期添加的搜索按钮
    for (int i = 0; i < 3; i ++) {
        
        UITextField *textField = [_textFieldMArray objectAtIndex:i];
        textField.delegate = self;
        textField.rightView = [self generateRightViewWithTag:4001 + i];
        [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        textField.rightViewMode = UITextFieldViewModeAlways;
    }
}

-(UIView *)generateRightViewWithTag:(int)tag
{
    UIView *rightVeiw = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBtn setImage:[UIImage imageForName:@"suggest_search.png"] forState:UIControlStateNormal];
    
    searchBtn.tag  = tag;
    searchBtn.center = rightVeiw.center;
    searchBtn.bounds = CGRectMake(0,0,searchBtn.currentImage.size.width,searchBtn.currentImage.size.height);
    [searchBtn addTarget:self action:@selector(searchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [rightVeiw addSubview:searchBtn];
    return rightVeiw;
}

-(void)creatTableView
{
    self.tableView  = [[UITableView alloc] init];
    self.tableView.hidden = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.tableView];
    
    
    [self.tableView autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:[_textFieldMArray objectAtIndex:0]];
    
    _tableViewMarginTop = [self.tableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:[_textFieldMArray objectAtIndex:0]];
    
    [self.tableView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:[_textFieldMArray objectAtIndex:0]];
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

- (void)searchBtnClick:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    
    NSInteger index = btn.tag - 4001;
    
    self.tableView.hidden   = !self.tableView.hidden;
    
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
    
    if (index == 0) {
        
        _tableViewMarginTop.constant = 0 * TopMargindIstance;
        self.brand_input.text = @"";
        
        if ([_productOwnerType isEqualToString:@"01"]) {
            
            [self showBrandArr:_avProArray];
            
            self.resultArr = self.dataArr;
            
        }else{
            
            [self showBrandArr:_avcompArray];
            self.resultArr = self.dataArr;
            
        }
        
    }else if (index == 1){
        
        _tableViewMarginTop.constant = 1 * TopMargindIstance;
        self.cate_input.text = @"";
        
        if ([_productOwnerType isEqualToString:@"01"]) {
            
            [self showCateArr:_avProArray];
            
        }else{
            
            [self showCateArr:_avcompArray];

        }
        self.resultArr = self.dataArr;
        
    }else if (index == 2){
        
        _tableViewMarginTop.constant = 2 * TopMargindIstance;
        self.product_input.text = @"";
        
        
        if ([_productOwnerType isEqualToString:@"01"]) {
            
            [self showProArr:_avpArray];
            
        }else{
            
            [self showProArr:_avcArray];
        }
        
        self.resultArr = self.dataArr;

    }
    
    self.dataArr            = self.resultArr;
    [self.tableView reloadData];
    
}

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

// 显示品牌数组(本品)
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
    }
}

// 本品和竞品的显示逻辑.
-(void)showProArr:(NSMutableArray *)pros
{
    //temp数组显示品牌
    NSMutableArray *temp = [NSMutableArray array];
    
    if (!_currentCateModel && !_currentBrandModel && !_curOutCateModel) {  //如果两个都没有值
        
        //显示本品的有效数组
        self.dataArr = pros;
        
    }else if(_currentBrandModel && !(_currentCateModel || _curOutCateModel)){ //只有品牌有值,品类没有值
        
        //从有效数组中,查找出有品牌的值.
        for (WSSuggestHomePro * sp in pros) {
            
            if ([sp.brand isEqualToString:_currentBrandModel._id]) {
                [temp addObject:sp];
            }
        }
        
        self.dataArr = [temp mutableCopy];
        
    }else if (!_currentBrandModel && (_currentCateModel || _curOutCateModel)){  //品牌没有值,品类有值
        
        if (_curOutCateModel) {
            
            //从有效数组中,查找出有品类的值.
            for (WSSuggestHomePro * sp in pros) {
                
                if ([sp.memo1 isEqualToString:_curOutCateModel._id]) {
                    [temp addObject:sp];
                }
            }
            
            self.dataArr = [temp mutableCopy];
            
        }else{
            
            //从有效数组中,查找出有品类的值.
            for (WSSuggestHomePro * sp in pros) {
                
                if ([sp.memo1 isEqualToString:_currentCateModel._id]) {
                    [temp addObject:sp];
                }
            }
            self.dataArr = [temp mutableCopy];
        }
    }else{  //都有值
        
        //加载品牌和品类过滤后的数组,根据品牌ID和品类ID来过滤
        _proArray = [WSSuggestDataFactory suggestProForBrand:_currentBrandModel._id cate:_currentCateModel._id className:@"WSSuggestHomePro"];
        
        
        if (_curOutCateModel) {
            
            _proArray = [WSSuggestDataFactory suggestProForBrand:_currentBrandModel._id cate:_curOutCateModel._id className:@"WSSuggestHomePro"];
            
        }else{
            
            //加载品牌和品类过滤后的数组,根据品牌ID和品类ID来过滤
            _proArray = [WSSuggestDataFactory suggestProForBrand:_currentBrandModel._id cate:_currentCateModel._id className:@"WSSuggestHomePro"];
        }
        
        self.dataArr = [_proArray mutableCopy];
    }
    
}

#pragma mark - tableViewDelagate detaSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"SuggestHomeProcuct";
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
        
        WSSuggestHomePro *pro = self.dataArr[indexPath.row];
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
    
    CGSize size;
    if (_tableViewMarginTop.constant == 0 * TopMargindIstance) { //品牌
        
        WSBrandModel *brandModel = self.dataArr[indexPath.row];
        size = [brandModel.name ws_sizeWithFont:[UIFont systemFontOfSize:16.0] constrainedToWidth:250.0 lineBreakMode:NSLineBreakByWordWrapping];
        
    }else if (_tableViewMarginTop.constant == 1 * TopMargindIstance){ //品类
        
        WSCateModel *cateModel = self.dataArr[indexPath.row];
        size = [cateModel.name ws_sizeWithFont:[UIFont systemFontOfSize:16.0] constrainedToWidth:250.0 lineBreakMode:NSLineBreakByWordWrapping];
        
    }else{ //产品
        WSSuggestHomePro *pro = self.dataArr[indexPath.row];
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
            
            [self clearAllWithoutCate];
            
            _proArray = [WSSuggestDataFactory suggestProForBrand:_currentBrandModel._id cate:_curOutCateModel._id className:@"WSSuggestHomePro"];
            
        }else if(_currentCateModel){
            
            [self clearAllWithoutCate];
            
        }else{
            _cate_input.text = @"";
            _product_input.text  = @"";
            
            [_cate_input setUserInteractionEnabled:YES];
            [_cate_input setBackground:[UIImage imageForName:@"input.png"]];
        }
        
    }else if (_tableViewMarginTop.constant == 1 * TopMargindIstance){ //品类
        
        _currentCateModel = self.dataArr[indexPath.row];
        [self.cate_input setText:_currentCateModel.name];
        [self.cate_input resignFirstResponder];
        _product_input.text = @"";
        
        
        if (_currentCate) {
            _currentCate(_currentCateModel);
        }
        
        
    }else{ //产品
        
        _currentSP = self.dataArr[indexPath.row];
        _isChooseProduct = YES;
        [self.product_input setText:_currentSP.name];
        [self.product_input resignFirstResponder];
        
        //选择完产品之后,自动更新到品牌和品类
        if ([_productOwnerType isEqualToString:@"01"]) {
            
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
        [self confirmBtnClicked];
        
        if (_currentCate) {
            _currentCate(_currentCateModel);
        }
        
    }
    self.tableView.hidden = YES;

}

- (void)styleSegmentControlValueChanged:(id)sender
{
    
    NSArray *labelTextDataArray02 = [[NSArray alloc] initWithObjects:@"* 选择市场品牌:", @"* 选择品类:", @"* 选择产品:", @"* 每箱价格(元):", @"* 配方用量(g/KG):", nil];
    NSArray *labelTextDataArray03 = [[NSArray alloc] initWithObjects:@"* 配方名:", @"* 人力成本(元):", @"* 原料成本(元):", @"* 制作成本(元):", @"* 每次自制量(KG):", nil];
    
    UISegmentedControl *sc = (UISegmentedControl *)sender;
    NSInteger selectedIndex = sc.selectedSegmentIndex;
    
    
    if (selectedIndex == 0) {
        _sFormulaStyle = HSuggestTableForHomeFormulaProductCompare;
    }else if (selectedIndex == 1){
        _sFormulaStyle = HSuggestTableForHomeFormulaProductSelfMake;
    }
    
    if ([_sFormulaStyle isEqualToString:@"01"]) {  //对比产品
        
        _brand_input.text = @"";
        _product_input.text  = @"";
        _price_input.text = @"";
        _dosage_input.text = @"";
        
        if (_curOutCateModel) {
            _cate_input.text = _curOutCateModel.name;
            _cate_input.userInteractionEnabled = NO;
            [_cate_input setBackground:[UIImage imageForName:@"inputNoEdit.png"]];
        }
        
        for (int i = 0; i < 5; i ++) {
            UILabel *label = (UILabel *)[_staticLabelMArray objectAtIndex:i];
            
            label.text = [labelTextDataArray02 objectAtIndex:i];
        }
        
        for (int i = 0; i < 3; i ++) {
            UITextField *textField = [_textFieldMArray objectAtIndex:i];
            textField.rightView.hidden = NO;
            
        }
        self.cate_input.keyboardType = UIKeyboardTypeDefault;
        self.product_input.keyboardType = UIKeyboardTypeDefault;
        
        
    }else { //自制配方
        
        [self clearAll];
        
        for (int i = 0; i < 5; i ++) {
            
            UILabel *label = (UILabel *)[_staticLabelMArray objectAtIndex:i];
            
            label.text = [labelTextDataArray03 objectAtIndex:i];
            isFirst = YES;
        }
        
        for (int i = 0; i < 3; i ++) {
            
            UITextField *textField = [_textFieldMArray objectAtIndex:i];
            
            textField.rightView.hidden = YES;
        }
        
        self.cate_input.keyboardType = UIKeyboardTypeNumberPad;
        self.product_input.keyboardType = UIKeyboardTypeNumberPad;
        
    }
}


- (void)clearAll
{
    _cate_input.text = @"";
    _brand_input.text = @"";
    _product_input.text  = @"";
    _price_input.text = @"";
    _dosage_input.text = @"";
}

-(void)clearAllWithoutCate
{
    _product_input.text  = @"";
    _price_input.text = @"";
    _dosage_input.text = @"";
}



#pragma mark - UITextFieldDelegate

// 输入过程中,检测数字
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    BOOL a;
    if (textField == _price_input || textField == _dosage_input) {
        a = [self validateNumber:string];
    }else{
        a = YES;
    }
    
    if ([_sFormulaStyle isEqualToString:@"02"]){
        if (textField == _cate_input || textField == _product_input) {
            a = [self validateNumber:string];
        }
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

        if ([_sFormulaStyle isEqualToString:@"01"]) {
            
            if (textField == nil) {
                
                self.tableView.hidden = YES;
                
            }
            if (textField == _brand_input) {
                
                self.tableView.hidden = NO;
                
                _tableViewMarginTop.constant = 0 * TopMargindIstance;
                
                if ([_productOwnerType isEqualToString:@"01"]) {
                    
                    [self showBrandArr:_avProArray];
                    
                }else{
                    
                    [self showBrandArr:_avcompArray];
                }
                self.resultArr = self.dataArr;
                [self.tableView reloadData];
                
                
            }else if (textField == _cate_input){
                
                self.tableView.hidden = NO;
                
                _tableViewMarginTop.constant = 1 * TopMargindIstance;
                
                if ([_productOwnerType isEqualToString:@"01"]) {
                    
                    [self showCateArr:_avProArray];
                    
                }else{
                    
                    [self showCateArr:_avcompArray];
                }
                self.resultArr = self.dataArr;
                [self.tableView reloadData];
                
                
            }else if (textField == _product_input){
                
                self.tableView.hidden = NO;
                
                _tableViewMarginTop.constant = 2 * TopMargindIstance;
                
                if ([_productOwnerType isEqualToString:@"01"]) {
                    
                    [self showProArr:_avpArray];
                    
                }else{
                    
                    [self showProArr:_avcArray];
                }
                self.resultArr = self.dataArr;
                [self.tableView reloadData];
            }
            
        }
    return YES;
}

/**
 *  每次最后两个框编辑都刷新数据
 */
- (void) textFieldDidChange2:(UITextField *) TextField{
    
    [self confirmBtnClicked];
}

- (void) textFieldDidChange:(UITextField *) TextField{
    
    if (TextField == nil || [_sFormulaStyle isEqualToString:@"02"]) {
        
        self.tableView.hidden = YES;
        
    }else{
        
        for (int i = 0; i < 3; i ++) {
            UITextField *textFieldTemp = [_textFieldMArray objectAtIndex:i];
            if (TextField == textFieldTemp) {
                
                _tableViewMarginTop.constant = i * TopMargindIstance;
                
            }
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
    
    if ([_sFormulaStyle isEqualToString:@"01"]){
     
        if (textField == _brand_input) {
            
            if (!_currentBrandModel) {
                textField.text = @"";
            }
            
            
        }else if (textField == _cate_input){
            
            if (!_currentCateModel) {
                textField.text = @"";
            }
            
            
        }else if (textField == _product_input){
            
            if (!_currentSP) {
                textField.text = @"";
            }
            
        }
        
    }
    
    self.tableView.hidden = YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    self.tableView.hidden = YES;
    return YES;
}

#pragma mark - Functional logic

/**
 *  更新配方状态
 */

-(void)updateStatusStyle
{

    if (_shp.isFormulaStyle == YES) {  //当初选择的是自制配方
        
        _currentSP = _shp;
        _styleSC.selectedSegmentIndex = 1;
        [self styleSegmentControlValueChanged:_styleSC];
        
        [_brand_input setText:_shp.name];
        [_cate_input setText:_shp.renliCost];
        [_product_input setText:_shp.yuanliaoCost];
        [_price_input setText:_shp.makeCost];
        [_dosage_input setText:_shp.makeEveryTime];
        
        _pd.recipesSp = _shp;
        
        
    }else{
        
        
        //赋值,品牌,品类和产品为不可修改
        [_cate_input setUserInteractionEnabled:NO];
        [_cate_input setBackground:[UIImage imageForName:@"inputNoEdit.png"]];
        [_brand_input setUserInteractionEnabled:NO];
        [_brand_input setBackground:[UIImage imageForName:@"inputNoEdit.png"]];
        [_product_input setUserInteractionEnabled:NO];
        [_product_input setBackground:[UIImage imageForName:@"inputNoEdit.png"]];
        
        //view赋值
        NSString *brandStr = [NSString stringWithFormat:@"SELECT dicts.name FROM  base_dicts AS dicts WHERE dicts._id = '%@';",_shp.brand];
        NSMutableArray *brandArr = [[WSBaseDictsTable sharedTable] queryDatasBySql:brandStr columnArr:@[@"name"]];
        NSString *cateStr = [NSString stringWithFormat:@"SELECT dicts.name FROM  base_dicts AS dicts WHERE dicts._id = '%@';",_shp.memo1];
        NSMutableArray *cateArr = [[WSBaseDictsTable sharedTable] queryDatasBySql:cateStr columnArr:@[@"name"]];
        if (cateArr.count > 0) {
            [_cate_input setText:cateArr[0]];

        }
        if (brandArr.count > 0) {
            [_brand_input setText:brandArr[0]];
        }
        [_product_input setText:_shp.name];
        [_price_input setText:_shp.priceBox];
        
        
        if ([_sStyle isEqualToString:@"01"]) { //菜式
            [_dosage_input setText:_shp.dosage];
            
            _pd.sp = _shp;
            
        }else{
            [_dosage_input setText:_shp.formulaDosage];
            
            _pd.formulaSp = _shp;
        }
        
        //模型赋值给当前current
        _currentSP = _shp;
    }
}

/**
 *  过滤有效数据
 */
-(NSMutableArray *)filterAvData:(NSArray *)proArray brandArray:(NSArray *)brandArr pros:(NSMutableArray *)pros
{
    NSMutableArray *sugFilterArr = [NSMutableArray array];
    NSMutableArray *sugAvModelArr = [NSMutableArray array];
    
    for (int i = 0; i < proArray.count; i++) {
        
        WSSuggestHomePro * curPro = proArray[i];
        
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


-(void)setShp:(WSSuggestHomePro *)shp
{
    _shp = shp;
    
    if (_shp) {
        
        if (_shp) {
            _styleSC.userInteractionEnabled = NO;
        }
        
        [self updateStatusStyle];
    }    
}

-(void)setCurOutCateModel:(WSCateModel *)curOutCateModel
{
    _curOutCateModel = curOutCateModel;
    
    if (_curOutCateModel && _shp.isFormulaStyle == NO) {
        _cate_input.text = _curOutCateModel.name;
        [_cate_input setUserInteractionEnabled:NO];
        [_cate_input setBackground:[UIImage imageForName:@"inputNoEdit.png"]];
    }
}

/**
 *  检测空值
 */
-(BOOL)checkValue
{
    if ([_product_input.text isEqualToString:@""] && _product_input.hidden == NO) {
        [_product_input shakeView];
        return NO;
        
    }else if ([_dosage_input.text isEqual:@""] || ![self checkNum:_dosage_input.text])
    {
        [_dosage_input shakeView];
        return NO;
    }else if([_price_input.text isEqual:@""] || ![self checkNum:_price_input.text]){
        [_price_input shakeView];
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

- (void)cancelBtnClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)confirmBtnClicked
{
    if ([_sStyle isEqualToString:@"01"]) {  //菜市应用
        
        _currentSP.priceBox = self.price_input.text;
        
        _currentSP.dosage = self.dosage_input.text;
        
        //先拿到_currentSp,计算出新的模型,在回调
        [self generateNewPro:_currentSP];
        
        _pd.sp = _currentSP;
        
        if (_sp) {
            _sp(_currentSP,_currentCateModel);
        }
        
        }else if ([_sStyle isEqualToString:@"02"]){  //配方应用
            
            if ([_productOwnerType isEqualToString:@"02"] && [_sFormulaStyle isEqualToString:@"02"]) { //竞品 自制配方
                
                _currentSP = [WSSuggestHomePro new];
                
                _currentSP.name = _brand_input.text;
                _currentSP.renliCost = _cate_input.text;
                _currentSP.yuanliaoCost = _product_input.text;
                _currentSP.makeCost = _price_input.text;
                _currentSP.makeEveryTime = _dosage_input.text;
                _currentSP.isFormulaStyle = YES;
                
                //自制配方
                [self generateNewOwnFormulaPro:_currentSP];
                 _pd.recipesSp = _currentSP;
                
                if (_sp) {
                    _sp(_currentSP,_currentCateModel);
                }
                
            }else{
                
                _currentSP.priceBox = self.price_input.text;
                _currentSP.formulaDosage = self.dosage_input.text;
                
                //配方
                [self generateNewFormulaPro:_currentSP];
                _pd.formulaSp = _currentSP;

                
                if (_sp) {
                    _sp(_currentSP,_currentCateModel);
                }
            }
    }
}

#pragma mark - 计算

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
@end

//
//  MoreProductViewController.m
//  WinChannelIPhone
//
//  Created by winchannel on 11-10-3.
//  Copyright 2011年 Winchannel. All rights reserved.
//

#import "MoreProductViewController.h"
#import "WSAppData.h"
#import "WSProdBean.h"
#import "WSProdGrideViewController.h"
//#import "ConfigFileController.h"
#import "WSScheduleBrandArray.h"
#import "WidgetConstant.h"
#import "WSInterAction.h"
#import "WSEnvrionment.h"
#import "WSProductCell.h"
#import "WSGroupHeaderView.h"
#import "WSBaseDictsDBService.h"


#define RECEIVEMORE             @"receiveMoreProducts"

#define WSMOREPORUCETS          @"moreproduct"

#define kTagbase                100

@interface MoreProductViewController()<UISearchBarDelegate,WSGroupHeaderViewDelegate>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSArray *iSourceProductsArray;
@property (nonatomic, strong)NSMutableDictionary *iBranProducts;
@property (nonatomic, strong)NSMutableArray *iSelectedProducts;
@property (nonatomic, strong) NSString *searchBarText;

//分组样式的模型数组.
@property (nonatomic,strong) NSArray *prodBeanGroup;
@property (nonatomic,assign) BOOL isGroup;

@end

#pragma mark - MoreProductViewController延展(工具)
@interface MoreProductViewController (Tools)

- (NSMutableArray *)getSearchProdBeanGroupFromDictionary:(NSDictionary *)dictionary;            //从字典中搜索产品分组方法 dictionary:数据字典
- (NSMutableArray *)getProdBeanGroupModel:(NSMutableArray *)prodArray isSearch:(BOOL)isSearch;  //设置产品分组方法 prodArray:产品数组 isSearch:是否搜索状态

@end

@implementation MoreProductViewController
@synthesize iSelectedProducts = _iSelectedProducts;
@synthesize iBranProducts = _iBranProducts;
@synthesize iSourceProductsArray = _iSourceProductsArray;

- (instancetype)init
{
    return [self initWithProductArray:nil title:nil];
}

- (instancetype)initWithProductArray:(NSArray *)productArray title:(NSString *)titleName
{
    self = [super init];
    if (self) {
        _iSourceProductsArray = productArray;
        _titleName = titleName;
        self.title = titleName;
    }
    return self;
}

- (NSMutableArray *)iSelectedProducts
{
    if (_iSelectedProducts == nil) {
        _iSelectedProducts = [[NSMutableArray alloc] initWithCapacity:8];
    }
    return _iSelectedProducts;
}
#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *isBrandMore =  [[NSUserDefaults standardUserDefaults] objectForKey:IS_BRAND_MORE];
    if ([isBrandMore isEqualToString:@"0"]) {
        _isGroup = NO;
    }else{
        _isGroup = YES;
    }
    
    
    if ([self.executeParam.execute_class_param isKindOfClass:[NSArray class]]) {
        _iSourceProductsArray = (NSArray *)self.executeParam.execute_class_param;
    }
    
    if (_isGroup) {
        NSArray *brandArray = [_iSourceProductsArray valueForKeyPath:@"@distinctUnionOfObjects.brand"];
        if (!brandArray || [brandArray count] == 0 || ([brandArray count] == 1 && [[brandArray firstObject] length] == 0)) {
            _isGroup = NO;
        }
    }
    
    //backBtn added by Miller
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(MAIN_BUTTON_WH, 0, MAIN_BUTTON_WH, 44)];
    
    [backBtn setBackgroundColor:[UIColor clearColor]];
    
    [backBtn setImage:[UIImage scaledImageForName:@"icon_back" ofType:@"png"] forState:UIControlStateNormal];
    
//    [backBtn setImage:[UIImage imageForName:@"icon_back_press.png"] forState:UIControlStateHighlighted];
    
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *homeButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem=homeButtonItem;
    
    if ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue]>=7) {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -5;
        self.navigationItem.leftBarButtonItems = @[negativeSpacer, homeButtonItem];
    }else{
        self.navigationItem.leftBarButtonItem = homeButtonItem;
    }
    
    UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"add_label", nil) style:UIBarButtonItemStylePlain target:self action:@selector(addBarButtonItemClicked:)];
    
    self.navigationItem.rightBarButtonItem = addBarButtonItem;
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@",_titleName];
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _tableView.dataSource = self;
    _tableView.delegate = self;

    [self.view addSubview:_tableView];
    
    self.iBranProducts = [[NSMutableDictionary alloc] initWithCapacity:8];
    
    if ([[self.iBranProducts allKeys] count] == 0 /*&& [self.iSourceProductsArray count] > 0*/ ) {
        [self.iBranProducts setObjectSafe:self.iSourceProductsArray forKey:WSMOREPORUCETS];
    }
    
    self.tableView.tableHeaderView = [self getTableHeaderView];// headerView;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
    
    if ([self.tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    
#endif
    // 暴力去掉多余的cell分割线.
    self.tableView.tableFooterView=[[UIView alloc]init];
    
}

- (void)addBarButtonItemClicked:(id)sender
{
    NSLog(@"addBarButtonItemClicked");
    [self postReceiveMoreNotificationAndSendSelectedProducts];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)postReceiveMoreNotificationAndSendSelectedProducts
{
    [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVEMORE object:self.iSelectedProducts];
    
    if (self.wcBaseViewdelegate && [self.wcBaseViewdelegate respondsToSelector:@selector(callBackWhenFinishTask:)]) {
        self.executeParam.execute_result = self.iSelectedProducts;
        [self.wcBaseViewdelegate callBackWhenFinishTask:self.executeParam];
    }
}

- (void)addKeyboardNotificationObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardNotificationObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"keyboardWillShown" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"keyboardWillHidden" object:nil];
}

#pragma mark - keyboard show and hiden
-(void) keyboardWillShown:(NSNotification *) aNotification
{
    NSString *infoName = [aNotification name];
    NSDictionary* info = [aNotification userInfo];
    //kbSize即为键盘尺寸 (有width, height)
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;//得到键盘的高度
    
    if ([infoName isEqualToString:UIKeyboardWillShowNotification]) {
        [_tableView setFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height - kbSize.height)];
    }
}

-(void)keyboardWillHidden:(NSNotification *) notif
{
    NSString *name = [notif name];
    if ([name isEqualToString:UIKeyboardWillHideNotification]) {
        [_tableView setFrame:self.view.bounds];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     self.filterIBranProducts = [NSMutableDictionary dictionaryWithDictionary:self.iBranProducts];
//    [self.stateDictionary removeAllObjects];
    [self.tableView reloadData];
    [self addKeyboardNotificationObserver];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self removeKeyboardNotificationObserver];
}

-(void)viewDidLayoutSubviews{
    if(INTERFACE_IS_PAD){
        CGRect rect=CGRectMake(0.0, 0.0, self.view.bounds.size.width, 44.0);
        rect.size.width/=2;
        self.ownSearchBar.frame=rect;
        self.ownSearchBar.centerX=self.view.bounds.size.width/2;
    }
}

#pragma mark - table 

- (UIView *)getTableHeaderView {
    WSSearchBar *searchBar = [[WSSearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 44.0) isResetTextField:NO isResetBackgroundColor:NO isTop:NO isNotAutoresizingFlexible:YES];
    self.ownSearchBar = searchBar;
    self.ownSearchBar.searchBar.delegate = self;
    self.ownSearchBar.backViewColor = [UIColor whiteColor];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    if (INTERFACE_IS_PHONE){
        [headerView setBackgroundColor:MAIN_SEARCH_BG_COLOR];
    }
    [headerView addSubview:self.ownSearchBar];

    self.ownSearchBar.searchBar.placeholder = NSLocalizedString(@"query_more_sku_hint_label", nil) ;
    return headerView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_isGroup) {
        return self.prodBeanGroup.count;
    }else{
        // Return the number of sections.
        return [[self.filterIBranProducts allKeys] count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (_isGroup) {
        return @"";
        
    }else{
        NSArray *keys = [self.filterIBranProducts allKeys];
        NSString *brandid = [keys objectAtIndex:section];
        if ([brandid isEqualToString:WSMOREPORUCETS]) {
            NSArray *array = [self.filterIBranProducts objectForKey:brandid];
            if ([array count] > 0) {
                return NSLocalizedString(@"more_product_label",nil);
            }else{
                return NSLocalizedString(@"no_more_product",nil);
            }
        }else{
            WSScheduleBrandArray *brandarray = [WSAppData getObjectbyKey:SCHEDULEBRAND_NODE];
            NSString *brandname = [brandarray getBrandNameByBrandId:brandid];
            return (brandname != nil) ? brandname : @"";
        }
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 44;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
   
    
    if (_isGroup) {
        WSGroupHeaderView *headerView = [WSGroupHeaderView groupHeaderViewWithTableView:tableView];
        headerView.delegate = self;
        WSProdBeanArray *prodBeanArray = self.prodBeanGroup[section];
        headerView.prodBeanArray = prodBeanArray;
        headerView.tag = section + kTagbase;
        
        return headerView;
    }else{
        
        if (!IOS7_OR_LATER) {
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 44)];
            view.backgroundColor = [UIColor colorWithHexString:@"#fafafa"];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.width - 10, 44)];
            [view addSubview:label];
            label.textAlignment = NSTextAlignmentLeft;
            label.textColor = [UIColor blackColor];
            label.font = [UIFont systemFontOfSize:18];
            label.backgroundColor = [UIColor clearColor];
            
            label.text = [self tableView:tableView titleForHeaderInSection:section];
            
            
            UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, 43, tableView.width, 1)];
            line2.backgroundColor = [UIColor lightGrayColor];
            [view addSubview:line2];
            
            return view;
        }
        
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isGroup) {
        WSProdBeanArray *model = self.prodBeanGroup[section];
        return model.isExpend ? model.prodArray.count : 0;
    }else{
        NSArray *keys = [self.filterIBranProducts allKeys];
        NSString *brandid = [keys objectAtIndex:section];
        NSArray *products = [self.filterIBranProducts objectForKey:brandid];
        return [products count];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"productcell";
    
    WSProductCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[WSProductCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    WSProdBean *prodbean;
    if (_isGroup) {
        prodbean = [self.prodBeanGroup[indexPath.section] prodArray][indexPath.row];
    }else{
        NSArray *keys = [self.filterIBranProducts allKeys];
        NSString * brandid = [keys objectAtIndex:indexPath.section];
        NSArray *products = [self.filterIBranProducts objectForKey:brandid];
        if (products.count > indexPath.row) {
            prodbean = [products objectAtIndex:indexPath.row];
        }
        
    }
    
    NSString *content = nil;
    
    BOOL isCode = NO;
    id inner_param = self.executeParam.inner_param;
    if ([inner_param isKindOfClass:[WSFuncsBean_opt class]]) {
        WSFuncsBean_opt *opt = (WSFuncsBean_opt *)inner_param;
        if ([opt.isCode isEqualToString:@"1"]) {
            isCode = YES;
        }
    }
    
    if (isCode) {
        content = [NSString stringWithFormat:@"%@-%@", prodbean.name, prodbean.cod];
    }else {
        content = [NSString stringWithFormat:@"%@", prodbean.name];
    }
    BOOL isSelect = [self.iSelectedProducts containsObject:prodbean];
    
    [cell setContent:content isSelect:isSelect];
    
    return cell;
}

// tableView自适应高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WSProdBean *prodbean;
    if (_isGroup) {
        
        prodbean = [self.prodBeanGroup[indexPath.section] prodArray][indexPath.row];
        
    }else{
        
        NSArray *keys = [self.filterIBranProducts allKeys];
        NSString *brandid = [keys objectAtIndex:indexPath.section];
        NSArray *products = [self.filterIBranProducts objectForKey:brandid];
        if (products.count > indexPath.row) {
            prodbean = [products objectAtIndex:indexPath.row];
        }

    }
    
    NSString *content = [NSString stringWithFormat:@"%@-%@", prodbean.name, prodbean.cod];
    
    return [WSProductCell heightForRowWithContent:content tableWidth:tableView.width isNeedSelect:YES];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WSProdBean *prodbean;
    if (_isGroup) {
        
        prodbean = [self.prodBeanGroup[indexPath.section] prodArray][indexPath.row];
        
    }else{
        
        NSArray *keys = [self.filterIBranProducts allKeys];
        NSString *brandid = [keys objectAtIndex:indexPath.section];
        NSArray *products = [self.filterIBranProducts objectForKey:brandid];
        if (products.count >0) {
            prodbean = [products objectAtIndex:indexPath.row];
        }
        
    }
    
    WSProductCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.isCellSelected) {
        [self.iSelectedProducts removeObject:prodbean];
    }else{
        [self.iSelectedProducts addObject:prodbean];
    }
    
    NSArray *indexpaths = [NSArray arrayWithObject:indexPath];
    [tableView reloadRowsAtIndexPaths:indexpaths withRowAnimation:UITableViewRowAnimationNone];
    
    //计算个数
    if (_isGroup) {
        WSProdBeanArray *proArr = self.prodBeanGroup[indexPath.section];
        
        int num = 0;
        for (WSProdBean *selectPro in self.iSelectedProducts) {
            
            for (WSProdBean *pb in proArr.prodArray) {
                if ([selectPro.Id isEqualToString:pb.Id]) {
                    num++;
                }
            }
            
        }
        proArr.selectNum = num;
        
        //刷新组
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:indexPath.section];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
        
        UIButton *allButton = [self getGroupHeaderButtonWithTag:indexPath.section + kTagbase];
        if (allButton) {
            if (proArr.prodArray.count == proArr.selectNum) {
                [allButton setSelected:YES];
            } else if (proArr.selectNum == 0) {
                [allButton setSelected:NO];
            } else {
                [allButton setSelected:NO];
            }
        }
    }
}


- (UIButton *)getGroupHeaderButtonWithTag:(NSInteger)tag {
    UIView *headerView =  [self.view viewWithTag:tag];
    if (![headerView isKindOfClass:[WSGroupHeaderView class]]) {
        return nil;
    }
    WSGroupHeaderView *groupHeaderView = (WSGroupHeaderView *)headerView;
    
    return groupHeaderView.allSelectedBtn;
}

-(void)WSGroupHeaderViewDidClickAllSelectedBtn:(WSGroupHeaderView *)headerView
{
    WSProdBeanArray *pbarr = self.prodBeanGroup[headerView.tag - kTagbase];
    NSArray *prodbeanArr = [self.prodBeanGroup[headerView.tag - kTagbase] prodArray];
    
    if (pbarr.isSelected == NO) { //没有选中
        pbarr.selected = YES;
        [self.iSelectedProducts addObjectsFromArray:prodbeanArr];
        
        self.iSelectedProducts = [[self.iSelectedProducts valueForKeyPath:@"@distinctUnionOfObjects.self"] mutableCopy];
        
        pbarr.selectNum = prodbeanArr.count;
        
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:headerView.tag - kTagbase];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
        
        
    }else{
        
        pbarr.selected = NO;
        [self.iSelectedProducts removeObjectsInArray:prodbeanArr];
        
        pbarr.selectNum = 0;
        
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:headerView.tag - kTagbase];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
        
    }
}


#pragma mark - WSGroupHeaderViewDelegate
- (void)WSGroupHeaderViewDidClickBtn:(WSGroupHeaderView *)headerView
{
    if (IOS7_OR_LATER) {
        [UIView performWithoutAnimation:^{
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:headerView.tag - kTagbase];
            [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
        }];
    }else {
        [UIView setAnimationsEnabled:NO];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:headerView.tag - kTagbase];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
        [UIView setAnimationsEnabled:YES];
    }
    
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    if (IOS7_OR_LATER){
        for(id cc in [[[searchBar subviews] objectAtIndex:0] subviews]){
            if([cc isKindOfClass:[UIButton class]])
            {
                UIButton *btn = (UIButton *)cc;
                NSString *CancelString = NSLocalizedString(@"cancel_label",nil);
                [btn setTitle:CancelString  forState:UIControlStateNormal];
                if(INTERFACE_IS_PAD){
                    [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                    [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
                }
                //[btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
                break;
            }
        }
    }else{
        for(id cc in [searchBar subviews]){
            if([cc isKindOfClass:[UIButton class]]){
                UIButton *btn = (UIButton *)cc;
                NSString *CancelString = NSLocalizedString(@"cancel_label",nil);
                [btn setTitle:CancelString  forState:UIControlStateNormal];
                if(INTERFACE_IS_PAD){
                    [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                    [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
                }
                break;
            }
        }
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text=@"";
    
    self.searchBarText = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.filterIBranProducts = [NSMutableDictionary dictionaryWithDictionary:self.iBranProducts];
    self.prodBeanGroup = [self getProdBeanGroupModel:nil isSearch:NO];
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSDictionary *searchDict = [NSMutableDictionary dictionaryWithDictionary:[self searchUnitbyString:searchBar.text]];
    self.filterIBranProducts = [searchDict mutableCopy];
    
    //self.prodBeanGroup = [self getSearchProdBeanGroupModel:searchDict];
    self.searchBarText = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.prodBeanGroup = [self getSearchProdBeanGroupFromDictionary:searchDict];//2017-10-12-yuanji-修改逻辑
    
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    NSDictionary *searchDict = [NSMutableDictionary dictionaryWithDictionary:[self searchUnitbyString:searchBar.text]];
    self.filterIBranProducts = [searchDict mutableCopy];
    
    //self.prodBeanGroup = [self getSearchProdBeanGroupModel:searchDict];
    self.searchBarText = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.prodBeanGroup = [self getSearchProdBeanGroupFromDictionary:searchDict]; //2017-10-12-yuanji-修改逻辑
    
    [self.tableView reloadData];
    
}

- (NSDictionary *)searchUnitbyString:(NSString *)search{
    
    if (search == nil) {
         return self.iBranProducts;
    }
    
    //去除字符串两边的空格
    search = [search stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //只有空格 不作为
    if ([search isEqualToString:@""]) {
        return self.iBranProducts;
    }
    
    NSArray *searchArray = [search componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (searchArray != nil) {
        NSMutableString *format = [NSMutableString stringWithCapacity:4];
        int i = 0;
        NSMutableArray *formatArray = [[NSMutableArray alloc] initWithCapacity:4];
        for (NSString *item in searchArray) {
            if (![item isEqualToString:@""]) {
                if (i == 0) {
                    [format appendString:@"(SELF.name contains[cd] %@)"];
                    [formatArray addObject:item];
                }else{
                    [format appendString:@" AND (SELF.name contains[cd] %@)"];
                    [formatArray addObject:item];
                }
                [format appendString:@" OR (SELF.cod contains[cd] %@)"];
                [formatArray addObject:item];

                [format appendString:@" OR (SELF.pinyin like[cd] %@)"];
                NSString *pinyin = [NSString stringWithFormat:@"*%@*", item];
                [formatArray addObject:pinyin];
                i++;
            }
            
        }
        
        if ([formatArray count] > 0) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:format argumentArray:formatArray];
            
            NSMutableDictionary * reslutDictionary = [NSMutableDictionary dictionaryWithCapacity:1];
            NSArray *keys = [self.iBranProducts allKeys];
            for (NSString *keyString in keys) {
                NSArray * tempArray = [self.iBranProducts objectForKey:keyString];
                NSArray *proArray = [tempArray filteredArrayUsingPredicate:predicate];
                if ([proArray count] > 0) {
                    [reslutDictionary setObject:proArray forKey:keyString];
                }
            }
            return reslutDictionary;
        }
    }
    return nil;
}

- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}




#pragma mark - getter setter
-(NSArray *)prodBeanGroup
{
    if (!_prodBeanGroup) {
        _prodBeanGroup = [self getProdBeanGroupModel:nil isSearch:NO];
    }
    return _prodBeanGroup;
}


/**
 *  @return 获取搜索时的分组模型
 */
//-(NSMutableArray *)getSearchProdBeanGroupModel:(NSDictionary *)dict
//{
//    NSMutableArray *tempArr = [NSMutableArray array];
//    NSArray *keys = [self.iBranProducts allKeys];
//    for (NSString *keyString in keys) {
//        WSProdBeanArray *pba = [WSProdBeanArray new];
//        NSArray * proArray = [dict objectForKey:keyString];
//        pba.prodArray = [proArray mutableCopy];
//        pba.name = NSLocalizedString(@"搜索结果",nil);
//        pba.expend = YES;
//        int num = 0;
//        for (WSProdBean * prod in proArray) {
//            for (WSProdBean *select in self.iSelectedProducts) {
//                if ([select.cod isEqualToString:prod.cod]) {
//                    num ++ ;
//                    break;
//                }
//            }
//        }
//        pba.selectNum = num;
//        [tempArr addObject:pba];
//    }
//
//    return tempArr;
//}

/**
 *  @return 获取分组模型
 */
//-(NSMutableArray *)getProdBeanGroupModel
//{
//    // 1.对proBean进行排序.
//    NSArray *sortArr = [_iSourceProductsArray sortedArrayUsingComparator:^NSComparisonResult(WSProdBean *obj1, WSProdBean *obj2) {
//        NSComparisonResult result = [obj1.brand compare:obj2.brand];
//        return result;
//    }];
//    //2. 根据Brand进行分组
//    NSMutableArray *newGroupArr = [NSMutableArray array];
//    int n = 0;
//    int location = 1; //游标，记录从哪里开始
//    for (int i = 0; i < sortArr.count - 1; i++) {
//        WSProdBean *first = sortArr[i];
//        WSProdBean *two = sortArr[i + 1];
//        if (![first.brand isEqualToString:two.brand]) {
//            NSRange range  = NSMakeRange(n, location);
//            NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
//            NSArray *tempArr = [sortArr objectsAtIndexes:set];
//            [newGroupArr addObject:tempArr];
//            n = i + 1;
//            location = 1;
//        }else{
//            location += 1;
//            if (i == sortArr.count - 2) {
//                NSRange range  = NSMakeRange(n, location);
//                NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
//                NSArray *tempArr = [sortArr objectsAtIndexes:set];
//                [newGroupArr addObject:tempArr];
//            }
//        }
//    }
//
//    if(sortArr[sortArr.count -1])
//    {
//        WSProdBean *last = sortArr[sortArr.count - 1];
//        if (sortArr.count >=2) {
//            WSProdBean *two = sortArr[sortArr.count - 2];
//            if (![last.brand isEqualToString:two.brand] ) {
//                NSRange range  = NSMakeRange(sortArr.count - 1, 1);
//                NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
//                NSArray *tempArr = [sortArr objectsAtIndexes:set];
//                [newGroupArr addObject:tempArr];
//            }
//        }else if (sortArr.count == 1){
//             [newGroupArr addObject:sortArr];
//        }
//
//    }
//    NSMutableArray *tempArr = [NSMutableArray array];
//
//    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
//
//    for (NSArray *arr in newGroupArr) {
//        WSProdBeanArray *pba = [WSProdBeanArray new];
//        pba.prodArray = [arr mutableCopy];
//        int selectNum = 0;
//        for (WSProdBean *ob in arr) {
//
//            WSDictBean* dictBean = [service queryDictWithID:ob.brand];
//
//            if (dictBean) {
//                pba.name = dictBean.name;
//                pba.expend = NO;
//            }
//            for (WSProdBean *select in self.iSelectedProducts) {
//                if ([ob.cod isEqualToString:select.cod]) {
//                    selectNum ++ ;
//                    break;
//                }
//            }
//        }
//        pba.selectNum = selectNum;
//
//        if ([pba.name length] > 0) {
//            [tempArr addObject:pba];
//        }
//
//    }
//    return tempArr;
//}
@end

#pragma mark - MoreProductViewController延展(工具)
@implementation MoreProductViewController (Tools)

#pragma mark - 从字典中搜索产品分组方法 dictionary:数据字典
- (NSMutableArray *)getSearchProdBeanGroupFromDictionary:(NSDictionary *)dictionary
{
    NSArray *keys = [dictionary allKeys];
    NSMutableArray *prodArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSString *keyStr in keys)
    {
        NSArray *array = (NSArray *)[dictionary objectForKey:keyStr];
        [prodArray addObjectsFromArray:array];
    }
    
    return [self getProdBeanGroupModel:prodArray isSearch:YES];
}

#pragma mark - 设置产品分组方法 prodArray:产品数组 isSearch:是否搜索状态
- (NSMutableArray *)getProdBeanGroupModel:(NSMutableArray *)prodArray isSearch:(BOOL)isSearch
{
    // 1.对proBean进行排序.
    NSArray *sortArr = nil;
    if(isSearch)
    {
        sortArr = [prodArray sortedArrayUsingComparator:^NSComparisonResult(WSProdBean *obj1, WSProdBean *obj2) {
            NSComparisonResult result = [obj1.brand compare:obj2.brand];
            return result;
        }];
    }
    else
    {
        sortArr = [_iSourceProductsArray sortedArrayUsingComparator:^NSComparisonResult(WSProdBean *obj1, WSProdBean *obj2) {
            NSComparisonResult result = [obj1.brand compare:obj2.brand];
            return result;
        }];
    }
    if(!sortArr || sortArr.count <= 0)
        return [NSMutableArray arrayWithCapacity:0];
    
    //2. 根据Brand进行分组
    NSMutableArray *newGroupArr = [NSMutableArray array];
    int n = 0;
    int location = 1; //游标，记录从哪里开始
    for (NSInteger i = 0; i < sortArr.count - 1; i++)
    {
        WSProdBean *first = sortArr[i];
        WSProdBean *two = sortArr[i + 1];
        if (![first.brand isEqualToString:two.brand]) {
            NSRange range  = NSMakeRange(n, location);
            NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
            NSArray *tempArr = [sortArr objectsAtIndexes:set];
            [newGroupArr addObject:tempArr];
            n = i + 1;
            location = 1;
        }else{
            location += 1;
            if (i == sortArr.count - 2) {
                NSRange range  = NSMakeRange(n, location);
                NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
                NSArray *tempArr = [sortArr objectsAtIndexes:set];
                [newGroupArr addObject:tempArr];
            }
        }
    }
    
    if(sortArr[sortArr.count -1])
    {
        WSProdBean *last = sortArr[sortArr.count - 1];
        if (sortArr.count >=2) {
            WSProdBean *two = sortArr[sortArr.count - 2];
            if (![last.brand isEqualToString:two.brand] ) {
                NSRange range  = NSMakeRange(sortArr.count - 1, 1);
                NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
                NSArray *tempArr = [sortArr objectsAtIndexes:set];
                [newGroupArr addObject:tempArr];
            }
        }else if (sortArr.count == 1){
            [newGroupArr addObject:sortArr];
        }
    }
    
    NSMutableArray *tempArr = [NSMutableArray array];
    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
    
    for (NSArray *arr in newGroupArr) {
        WSProdBeanArray *pba = [WSProdBeanArray new];
        pba.prodArray = [arr mutableCopy];
        int selectNum = 0;
        for (WSProdBean *ob in arr) {
            
            WSDictBean* dictBean = [service queryDictWithID:ob.brand];
            
            if (dictBean) {
                pba.name = dictBean.name;
                pba.expend = NO;
            }
            for (WSProdBean *select in self.iSelectedProducts) {
                if ([ob.cod isEqualToString:select.cod]) {
                    selectNum ++ ;
                    break;
                }
            }
        }
        pba.selectNum = selectNum;
        
        if ([pba.name length] > 0)
        {
            if(isSearch && self.searchBarText.length > 0)
                pba.expend = YES;
            
            [tempArr addObject:pba];
        }
        
    }
    
    return [self configKeyWithTempArr:tempArr];
}
#pragma mark -

#pragma 将数组排序
- (NSMutableArray *)configKeyWithTempArr:(NSMutableArray *)tempArr
{
    [tempArr sortUsingComparator:^NSComparisonResult(WSProdBeanArray *obj, WSProdBeanArray *twoObj) {
        NSString *name = [self firstCharactor:obj.name];
        NSString *twoName = [self firstCharactor:twoObj.name];;
        return [name compare:twoName];
    }];
    return tempArr;
   
 }

#pragma mark -

#pragma 获取字符串的首字符

- (NSString *)firstCharactor:(NSString *)aString
{
    NSMutableString *str = [NSMutableString stringWithString:aString];
    const char *cStringFromstr = [str UTF8String];
    //判断是不是汉字，如果是汉字则转为拼音
    if (strlen(cStringFromstr)==3) {
        CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    }
    NSString *newString = [str capitalizedString];
    
    if(newString.length > 1) {
      
        return [newString substringToIndex:1];
    }
    return newString;
}

@end

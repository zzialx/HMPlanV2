//
//  WSSearchStoreViewController.m
//  WinSFA
//
//  Created by heju on 16/8/27.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSearchStoreViewController.h"

#import "WSCurrentTime.h"

#define K_HEAD_LABEL_LEFT_SPACE 15

#define K_HEAD_LABEL_TOP_SPACE 10

#define K_HEAD_LABEL_HEGITH 25



#define K_HEAD_BUTTON_LEFT_SPACE 16

#define K_HEAD_BUTTON_TOP_MARGIN 12

#define K_HEAD_BUTTONS_SPACE 16

#define K_HEAD_BUTTONS_MARGIN 20

#define K_HEAD_BUTTON_WIDTH (SCREEN_WIDTH - K_HEAD_BUTTON_LEFT_SPACE * 5) / 4

#define K_HEAD_BUTTON_HEIGHT 30

#define K_BUTTON_ROWS 2

#define K_BUTTON_COLUMN 4

#define K_TABLE_HEADVIEW_HEIGHT 150

#define K_LAST_DATES_COUNT 8

#define K_BASE_TAG  100

#define K_TABLE_HEAD_BG_COLOR [UIColor colorWithRed:237.0/255.0 green:243.0/255.0 blue:241.0/255.0 alpha:1.0]


#define K_SEARCH_BAR_BG_COLOR  [UIColor colorWithRed:234.0/255 green:234.0/255 blue:235.0/255 alpha:1.0]

#define K_SPERATE_LINE_BG_COLOR [UIColor colorWithRed:201.0/255 green:201.0/255 blue:201.0/255 alpha:1.0]

@interface WSSearchStoreViewController () {
    UISearchBar *nbar;
    UIView *leftView;
    UIImageView *markImageView;
}
@property (nonatomic,strong) NSString *selectedCityName;
@property (nonatomic,strong) NSString *searchContent;
@property (nonatomic,strong) UISearchBar *ownSearchBar;
@property (nonatomic,strong) UIButton *locationBtn;

@property (nonatomic,strong) UITableView *dateTableView;
@property (nonatomic,strong) NSMutableArray *dateStrs;
@property (nonatomic,strong) NSMutableArray *years;
@property (nonatomic , strong) UIView *headerView;

@end

@implementation WSSearchStoreViewController


- (instancetype)initWithCityName:(NSString *)selectedCityName searchContent:(NSString *)content{
    if (self = [super init]) {
        _selectedCityName = selectedCityName;
        _searchContent = content;
        [self initData];
    }
    return self;
}

- (void)initData {
    
    if (_dateStrs == nil) {
        _dateStrs = [[NSMutableArray alloc] init];
    }
    
    if (_years == nil) {
        _years = [[NSMutableArray alloc]  init];
    }
    
    NSDateFormatter *dateFormatter = [NSDateFormatter standardDateFormatter];
    [dateFormatter setDateFormat:@"yyyy MM-dd"];
    
    for (NSInteger i = 0; i < K_LAST_DATES_COUNT; i++) {
        NSTimeInterval daySeconds = (i+1) *24 * 60 * 60;
        NSDate *dayDate = [[NSDate alloc] initWithTimeIntervalSinceNow:-daySeconds];
        NSString *dateStr = [dateFormatter stringFromDate:dayDate];
        NSArray *dateArray = [dateStr componentsSeparatedByString:@" "];
        [self.years addObject:[dateArray firstObject]];
        [self.dateStrs addObject:[dateArray lastObject]];
    }
}

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                   target:self
                                      
                                                                                   action:@selector(cancel)];
    
    self.navigationItem.leftBarButtonItem = flexibleSpace;
    [self.navigationItem.leftBarButtonItem setWidth:12.0f];
    [self loadSearchView];
    if ([self.searchContent length] == 0) {
        [self.ownSearchBar becomeFirstResponder];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _dateTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.headerView.bottom, self.view.bounds.size.width, self.view.bounds.size.height - K_SEARCHBAR_HEIGHT - 64) style:UITableViewStylePlain];
    self.dateTableView.delegate = self;
    self.dateTableView.dataSource = self;
    self.dateTableView.tableHeaderView = [self tableHeadView];
    self.dateTableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.dateTableView];
}

- (void)loadSearchView {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
    self.headerView = headerView;
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    headerView.backgroundColor = K_SEARCH_BAR_BG_COLOR;
    if ([[UIDevice currentDevice] systemVersionNotLowerThan:@"7.0"])
    {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        CGFloat leftView_origin_x = INTERFACE_IS_PHONE ? 0 :175;
        leftView = [[UIView alloc] initWithFrame:CGRectMake(leftView_origin_x, 0, LeftBarWidth, 44)];
        self.locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _locationBtn.frame = CGRectMake(0, 0, LeftBarWidth, 44);
        _locationBtn.showsTouchWhenHighlighted = YES;
        _locationBtn.titleLabel.font = [UIFont systemFontOfSize:UI_Font -2];
        NSString *title = self.selectedCityName;
        [_locationBtn setTitle:title forState:UIControlStateNormal];
        [_locationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_locationBtn setTitleColor:[UIColor colorWithRed:201.0/255.0 green:201.0/255.0 blue:206.0/255.0 alpha:1.0] forState:UIControlStateHighlighted];
        [_locationBtn addTarget:self action:@selector(locationBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [leftView addSubview:_locationBtn];
        
//        markImageView = [[UIImageView alloc] initWithImage:[UIImage imageForName:@"carat-open.png"]];
        markImageView.frame = CGRectMake(0, 0, LeftBarWidth, 44);
        markImageView.contentMode = UIViewContentModeRight;
        [leftView addSubview:markImageView];
        [headerView addSubview:leftView];
#else
        
        nbar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, LeftBarWidth, 44)];
        for (UIView *view in nbar.subviews) {
            if ([view isKindOfClass:[UITextField class]]) {
                [view removeFromSuperview];
            }
        }
        self.locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _locationBtn.frame = CGRectMake(0, 0, LeftBarWidth, 44);
        _locationBtn.showsTouchWhenHighlighted = YES;
        _locationBtn.titleLabel.font = [UIFont systemFontOfSize:UI_Font - 2];
        NSString *title = self.selectedCityName;
        [_locationBtn.titleLabel adjustsFontSizeToFitWidth];
        [_locationBtn setTitle:title forState:UIControlStateNormal];
        [_locationBtn addTarget:self action:@selector(locationBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [nbar addSubview:_locationBtn];
        
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageForName:@"carat-open.png"]];
        imageView.frame = CGRectMake(0, 0, LeftBarWidth, 44);
        imageView.contentMode = UIViewContentModeRight;
        [nbar addSubview:imageView];
        [headerView addSubview:nbar];
#endif
        
    }
    else
    {
        nbar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, LeftBarWidth, 44)];
        nbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        for (UIView *view in nbar.subviews) {
            if ([view isKindOfClass:[UITextField class]]) {
                [view removeFromSuperview];
            }
        }
        self.locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _locationBtn.frame = CGRectMake(0, 0, LeftBarWidth, 44);
        _locationBtn.showsTouchWhenHighlighted = YES;
        _locationBtn.titleLabel.font = [UIFont systemFontOfSize:UI_Font - 1];
        NSString *title = self.selectedCityName;
        [_locationBtn.titleLabel adjustsFontSizeToFitWidth];
        [_locationBtn setTitle:title forState:UIControlStateNormal];
        [_locationBtn addTarget:self action:@selector(locationBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [nbar addSubview:_locationBtn];
        
        markImageView = [[UIImageView alloc] initWithImage:[UIImage imageForName:@"carat-open.png"]];
        markImageView.frame = CGRectMake(0, 0, LeftBarWidth, 44);
        markImageView.contentMode = UIViewContentModeRight;
        [nbar addSubview:markImageView];
        [headerView addSubview:nbar];
    }
    
    
    float xoffset =   LeftBarWidth  ;
    float width = self.view.bounds.size.width - xoffset;
    self.ownSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(xoffset, 0.0, width, 44.0)];
    self.ownSearchBar.delegate = self;
    
    // 20160926 Changed by HZH.
    self.ownSearchBar.placeholder = @"关键词之间用空格分隔";
    if ([self.searchContent length] > 0) {
        self.ownSearchBar.text = self.searchContent;
    }
    self.ownSearchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIView* view;
    if(IOS7_OR_LATER){
        self.ownSearchBar.barTintColor=[UIColor clearColor];
        view = [self.ownSearchBar.subviews objectAtIndex:0];
    }else{
        view = self.ownSearchBar;
    }
    
    for (UIView *subview in view.subviews){
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]){
            if (@available(iOS 13.0, *)) {
                                       subview.hidden = YES;
                                   } else {
                                       [subview removeFromSuperview];
                                   }
        }
        // 删除searchBar输入框的背景
        if ([subview isKindOfClass:[UITextField class]]) {
            UITextField* searchField = (UITextField*)subview;
            [searchField setBackground:nil];
            searchField.layer.borderColor=[[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
            searchField.layer.borderWidth=1;
            searchField.layer.cornerRadius=5;
        }
    }
    if(INTERFACE_IS_PAD){
        CGRect rect = self.ownSearchBar.frame;
        rect.size.width /= 2;
        //self.ownSearchBar.frame = rect;
        self.ownSearchBar.centerX = width/2;
        CGRect leftRect = leftView.frame;
        leftRect.origin.x = CGRectGetMinX(self.ownSearchBar.frame) - leftRect.size.width;
        leftView.frame = leftRect;
    }
    
    [headerView  addSubview:self.ownSearchBar];
    [self.view addSubview:headerView];
}


- (UIView *)tableHeadView {

    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, K_TABLE_HEADVIEW_HEIGHT)];
    headView.backgroundColor = K_TABLE_HEAD_BG_COLOR;
    
    UIView *topSperateLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
    topSperateLine.backgroundColor = K_SPERATE_LINE_BG_COLOR;
    [headView addSubview:topSperateLine];
    
    UIView *bottomSperateLine = [[UIView alloc] initWithFrame:CGRectMake(0,  K_TABLE_HEADVIEW_HEIGHT - 1, self.view.bounds.size.width,1)];
    bottomSperateLine.backgroundColor = K_SPERATE_LINE_BG_COLOR;
    [headView addSubview:bottomSperateLine];
    
    CGFloat y = 0;
    NSString *text =NSLocalizedString(@"last_visit_notify", nil)  ;
    CGSize lastSearchLabelSize = [text ws_sizeWithFont:[UIFont systemFontOfSize:UI_Font - 2] constrainedToWidth:headView.width lineBreakMode:NSLineBreakByCharWrapping];
    UILabel *lastSearchLabel = [[UILabel alloc] initWithFrame:CGRectMake(K_HEAD_LABEL_LEFT_SPACE, K_HEAD_LABEL_TOP_SPACE,headView.width, lastSearchLabelSize.height)];
    lastSearchLabel.backgroundColor = [UIColor clearColor];
    lastSearchLabel.font = [UIFont systemFontOfSize:UI_Font - 2];
    lastSearchLabel.textAlignment = NSTextAlignmentLeft;
    lastSearchLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [lastSearchLabel setNumberOfLines:0];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
    NSRange range = NSMakeRange(0, 0);
    if ([text rangeOfString:@"("].location != NSNotFound) {
         range = [text rangeOfString:@"("];
    }

    [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(range.location, [text length] - range.location)];
    UIFont *font = [UIFont systemFontOfSize:UI_Font - 3];
    [attributedText addAttribute:NSFontAttributeName value:font range:NSMakeRange(range.location, [text length] - range.location)];

    
    lastSearchLabel.attributedText = attributedText;
    
    [headView addSubview:lastSearchLabel];
    y += K_HEAD_LABEL_HEGITH + K_HEAD_LABEL_TOP_SPACE;
    
    
    for (NSInteger i = 0; i < K_BUTTON_COLUMN * K_BUTTON_ROWS; i++) {
        CGFloat button_x = K_HEAD_BUTTON_LEFT_SPACE  + (K_HEAD_BUTTON_WIDTH + K_HEAD_BUTTONS_SPACE)*(i%K_BUTTON_COLUMN);
        CGFloat button_y = y + K_HEAD_BUTTON_TOP_MARGIN + (K_HEAD_BUTTON_HEIGHT + K_HEAD_BUTTONS_MARGIN)*(i/K_BUTTON_COLUMN);
        CGRect rect = CGRectMake(button_x,button_y, K_HEAD_BUTTON_WIDTH, K_HEAD_BUTTON_HEIGHT);
        NSString *dateStr = self.dateStrs[i];
        UIButton *button = [self createButtonWith:rect title:dateStr];
        button.tag = i + K_BASE_TAG;
        [headView addSubview:button];
    }
    return headView;
}


- (UIButton *)createButtonWith:(CGRect)rect title:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(dateButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = rect;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:DETAIL_TEXT_COLOR forState:UIControlStateNormal];
    button.backgroundColor = [UIColor clearColor];
    button.layer.borderColor = [DETAIL_TEXT_COLOR CGColor];
    button.layer.borderWidth = 1.0f;
    button.layer.cornerRadius = 2.0f;
    [button.titleLabel setFont:[UIFont systemFontOfSize:UI_Font - 2]];
    return button;
}

- (void)dateButtonClick:(UIButton *)button {
    NSInteger index = button.tag - K_BASE_TAG;
    NSString *dateStr = self.dateStrs[index];
    NSString *yearStr = self.years[index];
    NSString *resultDateStr = [NSString stringWithFormat:@"%@-%@",yearStr,dateStr];
    if ([self.ownSearchBar.text isEqualToString:@" "]) {
        self.ownSearchBar.text = resultDateStr;
    }else {
        self.ownSearchBar.text =  [self.ownSearchBar.text stringByAppendingFormat:@" %@",resultDateStr];
    }
}

- (void)cancel {
    [self.ownSearchBar resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)locationBtnClick:(UIButton *)button {
}


#pragma mark UISearchBarDelegate Methods 

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(viewController:didSelectContent:)]) {
            [self.delegate viewController:self didSelectContent:searchBar.text];
        }
    }];
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    
    [searchBar setShowsCancelButton:YES animated:YES];
//    searchBar.text = @" ";  因这个初始化空格 影响了搜索功能 所以去掉 MENGNIU-140 修改
    /*
     searchBar.layer.anchorPoint = CGPointMake(320, searchBar.layer.anchorPoint.y);
     */
    for(UIView *cc in [searchBar subviews])
    {
        for (UIView *views in [cc subviews]) {
            if([views isKindOfClass:[UIButton class]])
            {
                UIButton *btn = (UIButton *)views;
                NSString *CancelString = NSLocalizedString(@"cancel_label",nil);
                [btn setTitle:CancelString  forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
                [btn.titleLabel setFont:[UIFont systemFontOfSize:UI_Font - 2]];
                break;
            }
        }
        
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}


#pragma UITableViewDelegate/UITabelViewDataSource Method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIndentifier = @"CellIndentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIndentifier];
    }
    return cell;
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  WSNewLocationSelectViewController.m
//  WinSFA
//
//  Created by heju on 16/8/24.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSNewLocationSelectViewController.h"



#define K_TABLE_HEADVIEW_HEIGHT 150
#define K_LEFT_SPACE 15.0f

#define K_LABEL_WITHD (SCREEN_WIDTH - (3 * K_LEFT_SPACE))
#define k_Label_HEIGHT 20

#define K_BUTTON_WIDTH  80
#define K_BUTTON_HEIGHT 30


@interface WSNewLocationSelectViewController (){
    
}
@property (nonatomic, strong) NSArray *dicts;
@property (nonatomic, copy) NSString *locationCityName;
@property (nonatomic, strong) WSLocationArray *locationArray;
@property (nonatomic, assign) NSInteger locationSelectIndex;
@property (nonatomic, strong) UITableView *locationTableView;
@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) NSMutableArray *sectionIndexTitles;
@property (nonatomic, strong) UIView *visitedCitysView;
@property (nonatomic, strong) WSDictBean *selectedDictBean;
@property (nonatomic, strong) WSDictBean *currentDictBean;
@property (nonatomic,strong) UIButton *visitedLocationCityButton;
@property (nonatomic,strong) NSMutableArray *sectionTitles;
@property (nonatomic,strong) NSArray *filters;
@property (nonatomic,strong) UIView *searchBarBgView;

@end

@implementation WSNewLocationSelectViewController

- (id)initWithCurrentLocationItem:(WSDictBean *)currentItem selectedItem:(WSDictBean *)selectedItem dicts:(NSArray *)dicts{
    
    self.currentDictBean = currentItem;
    
    return  [self initWithCurrentLocation:currentItem.name selectedItem:selectedItem dicts:dicts];
    
}

- (id)initWithCurrentLocation:(NSString *)cityName selectedItem:(WSDictBean *)selectedItem dicts:(NSArray *)dicts  {
    self = [super init];
    if (self) {
        self.dicts = dicts;
        self.filters = dicts;
        self.locationCityName = cityName;
//        if (selectedItem == nil) {
//            self.selectedDictBean = [[dicts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.name == %@",cityName]] firstObject];
//        } else {
        self.selectedDictBean = selectedItem;
//        }
        [self initData];
        
    }
    return self;
}

- (void)initData {

    if (_sectionIndexTitles == nil) {
        _sectionIndexTitles = [[NSMutableArray alloc] init];
    }
    if(_sectionTitles==nil){
        _sectionTitles=[[NSMutableArray alloc] init];
    }
    
    if ([self.dicts count]> 0) {
        NSMutableArray * array =[[NSMutableArray alloc] initWithArray:  [self.dicts valueForKeyPath:@"@distinctUnionOfObjects.fl"]];
        //排序
        NSArray *resultArray = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            
            return [obj1 compare:obj2 options:NSLiteralSearch];
        }];
        
        [self.sectionIndexTitles addObjectsFromArray:resultArray];
        
    }
    else
    {
        for(char c = 'A'; c <= 'Z'; c++ )
        {
            /*没有城市拼音首字母为I的*/
            if (c !='I') {
                [_sectionIndexTitles addObject:[NSString stringWithFormat:@"%c",c]];
            }
        }
    }
        if (_sections == nil) {
            _sections = [[NSMutableArray alloc] init];
        }
    
    [self reloadDataSource];
}

- (void)reloadDataSource {
    [self.sections removeAllObjects];

    NSArray * tempArray= [self.filters valueForKeyPath:@"@distinctUnionOfObjects.fl"];
    if ([tempArray count] > 0) {
        //排序
        NSArray *resultArray = [tempArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2 options:NSLiteralSearch];
        }];
        [self.sectionTitles removeAllObjects];
        [self.sectionTitles addObjectsFromArray:resultArray];
        
        for (NSInteger i = 0; i < [self.sectionTitles count]; i++) {
            NSString *sectionTitle = self.sectionTitles[i];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.fl == %@",sectionTitle];
            NSArray *rowDatas = [self.filters filteredArrayUsingPredicate:predicate];
            [self.sections addObject:rowDatas];
        }
    } else {
        [self filterCities];
    }
}

- (void)filterCities {
    NSString *parentId = nil;
    NSPredicate *predicateParent = [NSPredicate predicateWithFormat:@"self._p == nil"];
    NSArray *tempArray = [self.filters filteredArrayUsingPredicate:predicateParent];
    if ([tempArray count] == 1) {
        WSDictBean *parentDictBean = tempArray[0];
        parentId =  parentDictBean.Id;
    } else if ([tempArray count] == 0) {
        // MSTD-5591 要求只过滤levelCode 为2的节点， SFA-13083 获取不到父节点的时候取第一个作为父节点
        if ([self.filters count] == 1) {
            WSDictBean *dictBean = self.filters[0];
            parentId = dictBean.p;
        }
    }
    //    SFA-17146 donghong
    if ([parentId length] > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self._p == %@", parentId];
        NSArray *tempArray = [self.filters filteredArrayUsingPredicate:predicate];
        if ([tempArray count] > 0) {
            [self.sections addObject:tempArray];
        }
        else {
            [self.sections addObject:self.filters];
        }
    }
    if (self.sections.count < 1) {
        [self.sections addObject:self.filters];
        
    }

}

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    // YIHAIKERRY-3452 zhaodanyang
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(MAIN_BUTTON_WH, 0, MAIN_BUTTON_WH, 44)];
    
    [backButton setBackgroundColor:[UIColor clearColor]];
    
    [backButton setImage:[UIImage scaledImageForName:@"icon_back" ofType:@"png"] forState:UIControlStateNormal];
    
    [backButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    [self loadSearchBar];
    
    _locationTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.searchBarBgView.bottom, self.view.bounds.size.width, self.view.bounds.size.height - K_SEARCHBAR_HEIGHT - 64) style:UITableViewStylePlain];
    
    NSLog(@"self.view--%@",self.view);
    self.locationTableView.delegate = self;
    self.locationTableView.dataSource = self;
    self.locationTableView.tableHeaderView = [self tableHeadView];
    [self.view addSubview:self.locationTableView];
}
- (void)loadSearchBar {
    self.searchBarBgView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0, self.view.bounds.size.width, K_SEARCHBAR_HEIGHT)];
    
    self.searchBarBgView.backgroundColor = K_SEARCHBAR_BG_COLOR;
    [self.searchBarBgView addSubview:self.ownSearchBar];
    [self.view addSubview:self.searchBarBgView];
    
    WSSearchBar *searchBar = [[WSSearchBar alloc] initWithFrame:CGRectMake(0.0, 0, self.view.bounds.size.width, K_SEARCHBAR_HEIGHT)];
    self.ownSearchBar = searchBar;
    self.ownSearchBar.searchBar.delegate = self;
    self.ownSearchBar.searchBar.placeholder = NSLocalizedString(@"city_name_hint",nil);
    [self.searchBarBgView addSubview:self.ownSearchBar];
}

- (UIView *)tableHeadView {
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, K_TABLE_HEADVIEW_HEIGHT/2)];
    headView.backgroundColor = K_SEARCHBAR_BG_COLOR;

    CGFloat y = 5.0f;
    UILabel *locationCityLabel = [[UILabel alloc] initWithFrame:CGRectMake(K_LEFT_SPACE, y, K_LABEL_WITHD, k_Label_HEIGHT)];
    locationCityLabel.backgroundColor = [UIColor clearColor];
    locationCityLabel.font = [UIFont systemFontOfSize:UI_Font - 2];
    locationCityLabel.textAlignment = NSTextAlignmentLeft;
    locationCityLabel.text = NSLocalizedString(@"positioned_city", nil);
    [headView addSubview:locationCityLabel];
    y += k_Label_HEIGHT;
    y += 10;

    UIButton *locationCityButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [locationCityButton setFrame:CGRectMake(K_LEFT_SPACE, y, K_BUTTON_WIDTH, K_BUTTON_HEIGHT)];
    locationCityButton.backgroundColor = [UIColor whiteColor];
    locationCityButton.layer.borderWidth = 1.0f;
    locationCityButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    locationCityButton.layer.cornerRadius = 2.0f;
    [locationCityButton setTitle:self.locationCityName forState:UIControlStateNormal];
    [locationCityButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [locationCityButton.titleLabel setFont:[UIFont systemFontOfSize:UI_Font - 1]];
    [locationCityButton addTarget:self action:@selector(locationCityButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:locationCityButton];
    
    if(self.selectedDictBean.name.length > 0 )
    {
    headView.frame = CGRectMake(0, 0, self.view.bounds.size.width, K_TABLE_HEADVIEW_HEIGHT);
    y += K_BUTTON_HEIGHT;
    y += 15;
    
    UILabel *visitedLocationCityLabel = [[UILabel alloc] initWithFrame:CGRectMake(K_LEFT_SPACE, y, K_LABEL_WITHD, k_Label_HEIGHT)];
    visitedLocationCityLabel.backgroundColor = [UIColor clearColor];
    visitedLocationCityLabel.font = [UIFont systemFontOfSize:UI_Font - 1];
    visitedLocationCityLabel.textAlignment = NSTextAlignmentLeft;
    visitedLocationCityLabel.text = NSLocalizedString(@"last_visited_city", nil);
    [headView addSubview:visitedLocationCityLabel];
    y += k_Label_HEIGHT;
    y += 10;



    _visitedLocationCityButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _visitedLocationCityButton.backgroundColor = [UIColor whiteColor];
    [_visitedLocationCityButton setFrame:CGRectMake(K_LEFT_SPACE, y, K_BUTTON_WIDTH, K_BUTTON_HEIGHT)];
    _visitedLocationCityButton.layer.borderWidth = 1.0f;
    _visitedLocationCityButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    _visitedLocationCityButton.layer.cornerRadius = 2.0f;
    [_visitedLocationCityButton addTarget:self action:@selector(visitedCityButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_visitedLocationCityButton setTitle:self.selectedDictBean.name forState:UIControlStateNormal];
    [_visitedLocationCityButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_visitedLocationCityButton.titleLabel setFont:[UIFont systemFontOfSize:UI_Font-1]];
    [headView addSubview:self.visitedLocationCityButton];
    }
    return headView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)cancel {
//    [self visitedCityButtonClick:nil];
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)locationCityButtonClick:(UIButton *)button {
    if ([self.selectDelegate respondsToSelector:@selector(viewController:didselectedItem:)]) {
        
        // SFA-5507 解决定位城市名与本地城市列表名称不匹配的问题（例如：北京与北京市）
        WSDictBean *locationDict = nil;
        if (self.locationCityName.length > 0) {
            for (WSDictBean *dictBean in self.dicts) {
                
                if (dictBean.name.length == self.locationCityName.length) {
                    if ([dictBean.name isEqualToString:self.locationCityName]) {
                        locationDict = dictBean;
                    }
                }else if (dictBean.name.length > self.locationCityName.length && dictBean.name.length - self.locationCityName.length == 1){
                    if ([dictBean.name rangeOfString:self.locationCityName].length > 0) {
                        locationDict = dictBean;
                    }
                }else if (dictBean.name.length < self.locationCityName.length && self.locationCityName.length - dictBean.name.length == 1){
                    if ([self.locationCityName rangeOfString:dictBean.name].length > 0) {
                        locationDict = dictBean;
                    }
                }else{
                    
                }
                
            }
        }

        if (locationDict ==  nil && self.currentDictBean.name != nil) {
            locationDict = self.currentDictBean;
        }
        
        // WSDictBean *locationDict = [[self.dicts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.name == %@",self.locationCityName]] firstObject];
//        SFA-18632
//        【IOS】走访-走访终端-左上角点击别的城市，切换不回北京市
        [self.selectDelegate viewController:self didselectedItem:locationDict];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)visitedCityButtonClick:(UIButton *)button {
    if ([self.selectDelegate respondsToSelector:@selector(viewController:didselectedItem:)]) {
        [self.selectDelegate viewController:self didselectedItem:self.selectedDictBean];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.sections count]) {
        return [self.sections count];
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.sections count]) {
        return [self.sections[section] count];
    } else {
        return [self.sections count];
    }
}
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if ([self.sectionIndexTitles count]) {
        return self.sectionIndexTitles;
    } else {
        return nil;
    }
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.sectionIndexTitles indexOfObject:title];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.sectionTitles count]) {
        return self.sectionTitles[section];
    } else {
        return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identify = @"WSLocationSelectViewControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identify];
    }
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = [(WSDictBean *)(self.sections[indexPath.section][indexPath.row]) name];
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WSDictBean *dictBean = self.sections[indexPath.section][indexPath.row];
    if ([self.selectDelegate respondsToSelector:@selector(viewController:didselectedItem:)]) {
        [self.selectDelegate viewController:self didselectedItem:dictBean];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    
    for(UIView *view in [searchBar subviews])
    {
        for (UIView *views in [view subviews]) {
            if([views isKindOfClass:[UIButton class]])
            {
                UIButton *btn = (UIButton *)views;
                NSString *CancelString = NSLocalizedString(@"cancel_label",nil);
                [btn setTitle:CancelString  forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
                break;
            }
        }
        
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text=@"";
    
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.filters = self.dicts;
    [self reloadDataSource];
    [self.locationTableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.filters = [NSMutableArray arrayWithArray:[self searchUnitbyString:searchBar.text]];
    [self reloadDataSource];
    [self.locationTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    self.filters = [NSMutableArray arrayWithArray:[self searchUnitbyString:searchBar.text]];
    [self reloadDataSource];
    [self.locationTableView reloadData];
    
}

- (NSArray *)searchUnitbyString:(NSString *)search{
    
    if (search == nil || [search isEqualToString:@""]) {
        return self.dicts;
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
                i++;
            }
            
        }
        if ([formatArray count] > 0) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:format argumentArray:formatArray];
            NSMutableArray *tempArray = [(NSMutableArray *)[self.dicts filteredArrayUsingPredicate:predicate] mutableCopy];
            //SFA-7037
            NSPredicate *predicateParent = [NSPredicate predicateWithFormat:@"self._p == nil and self._fl == nil"];
            NSArray *tempArray2 = [self.dicts filteredArrayUsingPredicate:predicateParent];
            if (tempArray && tempArray2.count == 1 ) {
                [tempArray addObjectsFromArray:tempArray2];
            }
            return (NSArray *)tempArray;
        }
    }
    return nil;
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

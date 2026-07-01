//
//  WSPersonnelListTreeView.m
//  WinSFA
//
//  Created by winchannel on 15/7/29.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSPersonnelListTreeView.h"
#import "WSSubempstoreBean.h"

static NSString * const kPersonnelReuseCell = @"PersonnelCell";

@interface WSPersonnelListTreeView () <UISearchBarDelegate>

@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) NSMutableArray *selectedDataItem;
@property (nonatomic, strong) NSArray *displayArray;
@property (nonatomic, strong) NSArray *resultArray; // 数据平级结构，用于查找设置等
@property (nonatomic, strong) NSArray *resultTreeArray; // resultArray 对应的树形结构数组
@property (nonatomic, strong) WSFuncsBean *currentFuncBean;
@property (nonatomic, strong) WSSearchBar *searchBar;
@property (nonatomic, assign) WSPersonnelListStyle listStyle;

@end

@implementation WSPersonnelListTreeView

#pragma mark - Init
- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame withFuncsBean:nil listStyle:WSPersonnelListStyleDefault];
}

- (id)initWithFrame:(CGRect)frame withFuncsBean:(WSFuncsBean *)currentFuncsBean {
    return [self initWithFrame:frame withFuncsBean:currentFuncsBean listStyle:WSPersonnelListStyleDefault];
}

- (instancetype)initWithFrame:(CGRect)frame listStyle:(WSPersonnelListStyle)listStyle {
    return [self initWithFrame:frame withFuncsBean:nil listStyle:listStyle];
}


- (id)initWithFrame:(CGRect)frame withFuncsBean:(WSFuncsBean *)currentFuncsBean listStyle:(WSPersonnelListStyle)listStyle {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.currentFuncBean = currentFuncsBean;
        
        self.listStyle = listStyle;
        
        self.displayArray = [[NSArray alloc]init];
        
        self.selectedDataItem = [[NSMutableArray alloc]init];
        
        self.listTableView  = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        
        self.listTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        self.listTableView.dataSource = self;
        
        self.listTableView.delegate = self;
        
        self.listTableView.bounces = NO;
        
        self.listTableView.tableFooterView = [[UIView alloc] init];
        
        [self addSubview:self.listTableView];
        
        if (self.listStyle & WSPersonnelListStyleSearchable) {
            [self setupSearchBar];
        }
        
    }
    return self;
}

- (void)setupSearchBar {
    WSSearchBar *searchBar = [[WSSearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bounds.size.width, K_SEARCHBAR_HEIGHT) isResetTextField:NO isResetBackgroundColor:YES isTop:NO isNotAutoresizingFlexible:YES];
    self.searchBar = searchBar;
    self.searchBar.searchBar.delegate = self;
    self.searchBar.backViewColor = [UIColor whiteColor];

    self.listTableView.tableHeaderView = searchBar;
    
}

#pragma mark - Public Method
- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = [[NSArray alloc] initWithArray:dataArray copyItems:YES];
    [self resetTree];
    [self reloadDataForDisplayArray];
}

- (void)setSelectArray:(NSArray *)selectArray {
    for (NSString *selectItemID in selectArray) {
        for (NSObject<I_W_Cell> *subempStoreBean in self.resultArray) {
            if ([selectItemID isEqualToString:[subempStoreBean getId]]) {
                [subempStoreBean setOptioned:YES];
                
                [self setParentBeanExpand:subempStoreBean];
                
                break;
            }
        }
        
    }
    [self reloadDataForDisplayArray];
}

- (WSPersonnelListStyle)getListStyle {
    return self.listStyle;
}


//初始化将要显示的cell的数据
- (void)reloadDataForDisplayArray {
    [self setDisplayArrayWithDataArray];
 
    if (INTERFACE_IS_PAD) {
        CGRect listTableViewRect = self.listTableView.frame;
        
        // 2018-05-21-LX-SFA-20190
        CGFloat temHeight = self.displayArray.count * MAIN_CELL_HEIGHT;
        if (self.displayArray.count * MAIN_CELL_HEIGHT > listTableViewRect.size.height) {
            temHeight = listTableViewRect.size.height;
        }
        
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.displayArray.count * MAIN_CELL_HEIGHT);
        
        self.listTableView.frame = CGRectMake(listTableViewRect.origin.x, listTableViewRect.origin.y, listTableViewRect.size.width, temHeight);
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(resetFramePersonnelListTreeView:)]) {
            [self.delegate resetFramePersonnelListTreeView:self];
        }
    }
    
    [self.listTableView reloadData];
}

- (void)selectWithDataArray:(NSArray *)dataArray isOption:(BOOL)isOption {
    for (NSObject<I_W_Cell> *subempStoreBean in dataArray) {
        [subempStoreBean setOptioned:isOption];
        if (isOption) {
            [subempStoreBean setIsExpland:YES];
            [subempStoreBean setIsAllExpand:YES];
        }
        NSArray *sonArray = [subempStoreBean getSonBean];
        if (sonArray) {
            [self selectWithDataArray:sonArray isOption:isOption];
        }
    }
}

- (void)selectAll:(BOOL)isSelect {
    [self selectWithDataArray:self.resultTreeArray isOption:isSelect];
    [self displayAll];
    [self.listTableView reloadData];
    
    [self selectArrayChanged];
}

- (void)setTreeListReadOnly:(BOOL)sourceTreelistReadOnly{
    if (_sourceTreelistReadOnly != sourceTreelistReadOnly) {
        _sourceTreelistReadOnly = sourceTreelistReadOnly;
    }
}

- (void)resetSearchBar:(BOOL)isClearText {
    if (isClearText) {
        self.searchBar.searchBar.text = @"";
    }
    [self.searchBar.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar.searchBar resignFirstResponder];
}

#pragma mark - UITableDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.displayArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WSPersonnelListTreeCell *levelcell = [tableView dequeueReusableCellWithIdentifier:kPersonnelReuseCell];
    if (!levelcell) {
        levelcell = [[[WSPersonnelListTreeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPersonnelReuseCell] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPersonnelReuseCell listStyle:self.listStyle];
        levelcell.delegate = self;
        levelcell.selectionStyle = UITableViewCellAccessoryNone;
    }

    NSObject<I_W_Cell> *bean = [self.displayArray objectAtIndex:indexPath.row];
    [levelcell assignedWithWSSubempStoreBean:bean withIsReadOnly:_sourceTreelistReadOnly];
    return levelcell;
}

//设置单元高度
- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return MAIN_CELL_HEIGHT;
}


//选中单元格所产生事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(personnelListTreeView:withSubempStoreBean:)]) {
    
        NSObject<I_W_Cell> *object = [self.displayArray objectAtIndex:indexPath.row];
        
        if ([object isKindOfClass:[WSSubempstoreBean class]]) {
            
            WSSubempstoreBean *subempStoreBean = (WSSubempstoreBean *)object;
            //层级锁定
            if (self.currentFuncBean.lockLevel && [[object getSub_Level_Code] isEqualToString:@"3"]) {
                
            }
            else{
                [self.delegate personnelListTreeView:self withSubempStoreBean:subempStoreBean];
            }
            
        }
    }
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self resetSearchBar:YES];
    
    [self resetTree];
    [self reloadDataForDisplayArray];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self resetSearchBar:NO];
    
    [self filterArrayWithSearchText:searchBar.text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self filterArrayWithSearchText:searchBar.text];
}


#pragma mark - Private Method

- (void)resetTree {
    self.resultArray = [[NSArray alloc] initWithArray:self.dataArray copyItems:YES];
    self.resultTreeArray = [self parseData:self.resultArray];
}

- (NSArray *)parseData:(NSArray *)subempstoreArray  {
    NSMutableArray *dataArray = [NSMutableArray array];
    
    NSInteger subLevelCode = [kRootSubLevel integerValue];
    
    for (NSObject<I_W_Cell> *cell in subempstoreArray) {
        if (![cell getPid]) {
            if ([cell isKindOfClass:[WSSubempstoreBean class]]) {
                WSSubempstoreBean *empStoreBean = (WSSubempstoreBean *)cell;
                [empStoreBean setSub_level_code:kRootSubLevel];
            }
            
            [dataArray addObject:cell];
            [self parseSonData:subempstoreArray cell:cell pid:[cell getId] subLevelCode:subLevelCode + 1];
        }
    }
    
    return [dataArray copy];
}

- (void)parseSonData:(NSArray *)subempstoreArray
                cell:(NSObject<I_W_Cell> *)cell
                 pid:(NSString *)pid
        subLevelCode:(NSInteger)subLevelCode {
    
    NSMutableArray *sonArray = nil;
    
    for (NSObject<I_W_Cell> *subCell in subempstoreArray) {
        if ([[subCell getPid] isEqualToString:pid]) {
            if ([subCell isKindOfClass:[WSSubempstoreBean class]]) {
                WSSubempstoreBean *empStoreBean = (WSSubempstoreBean *)subCell;
                [empStoreBean setSub_level_code:[NSString stringWithFormat:@"%ld", subLevelCode]];
            }
            
            if (!sonArray) {
                sonArray = [[NSMutableArray alloc] init];
                [cell setSonBean:sonArray];
            }
            [sonArray addObject:subCell];
            
            [self parseSonData:subempstoreArray cell:subCell pid:[subCell getId] subLevelCode:subLevelCode + 1];
        }
    }
}


- (void)filterArrayWithSearchText:(NSString *)searchText {
//    self.resultArray = [[NSArray alloc] initWithArray:self.dataArray copyItems:YES];
    [self resetTree];
    // 搜索即设置展开还是收起
    if (searchText.length > 0) {
        [self filterArray:self.resultTreeArray searchText:searchText];
    }
    [self reloadDataForDisplayArray];
}

- (void)setParentBeanExpand:(NSObject <I_W_Cell> *)bean {
    if (![[bean getSub_Level_Code] isEqualToString:kRootSubLevel]) {
        BOOL isExpand = [bean getIsExpland];
        if (!isExpand) {
            [bean setIsExpland:YES];
            NSObject<I_W_Cell> *parentBean = [self getParentBeanWithPid:[bean getPid]];
            if (parentBean) {
                [self setParentBeanExpand:parentBean];
            }
        }
    }
}

- (NSObject<I_W_Cell> *)getParentBeanWithPid:(NSString *)pid {
    for (NSObject<I_W_Cell> *parentBean in self.resultArray) {
        if ([[parentBean getId] isEqualToString:pid]) {
            return parentBean;
        }
    }
    return nil;
}

- (void)filterArray:(NSArray *)dataArray searchText:(NSString *)searchText {
    for (NSObject<I_W_Cell> *bean in dataArray) {
        NSString *beanName = [bean getName];
        if ([beanName containsString:searchText]) {
            [self setParentBeanExpand:bean];
        }
        NSArray *sonArray = [bean getSonBean];
        if (sonArray) {
            [self filterArray:sonArray searchText:searchText];
        }
    }
}



- (void)setDisplayArrayWithDataArray {
    if ([self.resultTreeArray count] == 0) {
        self.displayArray = self.resultTreeArray;
        return;
    }
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (NSObject<I_W_Cell> *subempStoreBean in self.resultTreeArray) {
        if ([[subempStoreBean getSub_Level_Code] isEqualToString:kRootSubLevel]) {
            [tempArray addObject:subempStoreBean];
            
            NSArray *sonArray = [subempStoreBean getSonBean];
            if (sonArray) {
                BOOL isSonExpand = [subempStoreBean getIsAllExpand];
                [self setDisplayArray:tempArray withSonArray:sonArray isSonExpand:isSonExpand];
            }
        }
    }
    self.displayArray = [tempArray copy];
}


- (void)setDisplayArray:(NSMutableArray *)displayArray withSonArray:(NSArray *)sonArray isSonExpand:(BOOL)isSonExpand {
    if ([sonArray count] == 0) {
        return;
    }
    
    for (NSObject<I_W_Cell> *subempStoreBean in sonArray) {
        BOOL isExpand = [subempStoreBean getIsExpland];
        if (isSonExpand || isExpand) {
            [displayArray addObject:subempStoreBean];
        }
        NSArray *sonArray = [subempStoreBean getSonBean];
        if (sonArray) {
            BOOL isGrandSonExpand = [subempStoreBean getIsAllExpand];;
            [self setDisplayArray:displayArray withSonArray:sonArray isSonExpand:isGrandSonExpand];
        }
    }
}

- (void)displayAll {
    if ([self.resultTreeArray count] == 0) {
        return;
    }
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    for (NSObject<I_W_Cell> *subempStoreBean in self.resultTreeArray) {
        if ([[subempStoreBean getSub_Level_Code] isEqualToString:kRootSubLevel]) {
            [tempArray addObject:subempStoreBean];
            
            NSArray *sonArray = [subempStoreBean getSonBean];
            if (sonArray) {
                [self setDisplayArray:tempArray withSonArray:sonArray isSonExpand:YES];
            }
        }
    }
    self.displayArray = [tempArray copy];
}

- (void)pushController:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(personnelListTreeView:withSubempStoreBean:)]) {
        NSObject<I_W_Cell> *dataItem = [self.displayArray objectAtIndex:sender.tag];
        [self.delegate personnelListTreeView:self withSubempStoreBean:dataItem];
    }
}

// 设置子节点收起
- (void)setDataItemFold:(NSObject <I_W_Cell> *)dataItem {
    NSArray *sonArray = [dataItem getSonBean];
    if ([sonArray count] == 0) {
        return;
    }
    
    for (NSObject<I_W_Cell> *subempStoreBean in sonArray) {
        if ([subempStoreBean getIsExpland]) {
            [subempStoreBean setIsExpland:NO];
            [subempStoreBean setIsAllExpand:NO];
            
            [self setDataItemFold:subempStoreBean];
        }
    }
}


// 设置选中项
- (void)setOptionedSelectItemID:(NSString *)selectItemID {
    for (NSObject<I_W_Cell> *subempStoreBean in self.resultArray) {
        if ([selectItemID isEqualToString:[subempStoreBean getId]]) {
            [subempStoreBean setOptioned:YES];
            [self setParentBeanExpand:subempStoreBean];
            break;
        }
    }
}
- (void)setSelectItemID:(NSString *)selectItemID dataArray:(NSArray *)dataArray isOptioned:(BOOL)isOptioned {
    for (NSObject<I_W_Cell> *subempStoreBean in dataArray) {
        if ([selectItemID isEqualToString:[subempStoreBean getId]]) {
            [subempStoreBean setOptioned:isOptioned];
            
            if (![subempStoreBean getIsExpland]) {
                [subempStoreBean setIsExpland:isOptioned];
            }
            [self setParentSelectionBean:subempStoreBean isOptioned:isOptioned];
            NSArray *sonArray = [subempStoreBean getSonBean];
            if (sonArray) {
                [self setSelectItemID:selectItemID dataArray:sonArray isOptioned:isOptioned];
            }
        }
    }
}

- (void)setParentSelectionBean:(NSObject<I_W_Cell> *)bean isOptioned:(BOOL)isOptioned {
    if (([self getListStyle] & WSPersonnelListStyleParentOption) == 0) {
        return;
    }
    
    NSObject<I_W_Cell> *parentBean = [self getParentBeanWithPid:[bean getPid]];;
    if (!parentBean) {
        return;
    }
    if (!isOptioned) {
        if ([parentBean getOptioned]) {
            [parentBean setOptioned:NO];
            [self setParentSelectionBean:parentBean isOptioned:NO];
        }
    } else {
        if (![parentBean getOptioned]) {
            BOOL isAllSubSelected = YES;
            
            NSArray *sonArray = [parentBean getSonBean];
            for (NSObject<I_W_Cell> *subBean in sonArray ) {
                if (![subBean getOptioned]) {
                    isAllSubSelected = NO;
                    break;
                }
            }
            if (isAllSubSelected) {
                [parentBean setOptioned:YES];
                [self setParentSelectionBean:parentBean isOptioned:YES];
            }
        }
    }
    
}

- (NSArray *)getSelectedIdArray {
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (NSObject<I_W_Cell> *bean in self.resultArray) {
        if ([bean getOptioned]) {
            [tempArray addObject:[bean getId]];
        }
    }
    return tempArray;
}

#pragma mark - WSPersonnelListTreeCell

- (void)listTreeCell:(WSPersonnelListTreeCell *)listTreeCell reloadDataItem:(NSObject <I_W_Cell> *)dataItem {
    [self resetSearchBar:NO];
    //SFA-21030 赵丹阳
    BOOL isExpand = ![dataItem getIsAllExpand];
    [dataItem setIsAllExpand:isExpand];
    if (!isExpand) {
        [self setDataItemFold:dataItem];
    }
    [self reloadDataForDisplayArray];
}

- (void)listTreeCell:(WSPersonnelListTreeCell *)listTreeCell didClickItem:(NSObject<I_W_Cell> *)dataItem {
    [self resetSearchBar:NO];
    
    BOOL isOptioned = [dataItem getOptioned];
    [dataItem setOptioned:isOptioned];
    
    // 当前取消勾选，取消其父的勾选
    if (!isOptioned) {
        [self setParentSelectionBean:dataItem isOptioned:isOptioned];
    }
    NSArray *sonArray = [dataItem getSonBean];
    if (sonArray) {
        if (isOptioned) {
            [dataItem setIsAllExpand:YES];
        }
        [self selectWithDataArray:sonArray isOption:isOptioned];
    }
    [self reloadDataForDisplayArray];
    
    [self selectArrayChanged];
}

- (void)selectArrayChanged {
    if (self.delegate && [self.delegate respondsToSelector:@selector(setSelectedArray:)]) {
        NSArray *selectedArray = [self getSelectedIdArray];
        [self.delegate setSelectedArray:selectedArray];
    }
}

@end

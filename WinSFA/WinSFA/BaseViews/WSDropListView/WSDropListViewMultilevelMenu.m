//
//  WSDropListViewCountryAdministrationList.m
//  WinSFA
//
//  Created by sunhf on 2018/1/11.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSDropListViewMultilevelMenu.h"
#import "WSDropListView.h"
#import "WSMultilevelMenuCell.h"
#import "GlobalUtil.h"

static NSString *identify = @"multilevelMenuCell";

@implementation WSDropListViewMultilevelMenu
- (id)initWithFrame:(CGRect)frame withLevelNumber:(NSInteger)levelNumber withAllData:(NSMutableArray *)allDataArray withBackShowLevelData:(NSMutableArray *)backShowLevelDataArray
{
    self = [super initWithFrame:frame];
    if (self) {
        self.levelNumber = levelNumber;
        self.allDataArray = allDataArray;
        self.backShowLevelDataArray = backShowLevelDataArray;
        service = [[WSBaseDictsDBService alloc] init];
        [self createSubViews];
    }
    return self;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //不同tableview 取不同的数据  根绝在数组里的位置一一对应取 第一次进来的时候 currentLevelDataArray不存在 取得是当前级的数据,当点击子集的时候,刷新的应该是下一层级的数据
    WSDictBean *dict;
    CGSize cellSize;
    if (currentNeedRefreshLevelDataArray)
    {
        dict = currentNeedRefreshLevelDataArray[indexPath.row];
    }
    if (tableView.tag-500+1 <= self.allDataArray.count)
    {
        NSMutableArray *dataArray = self.allDataArray[tableView.tag-500];
        dict = dataArray[indexPath.row];
    }
    cellSize = [GlobalUtil sizeOfContent:dict.name labelFont:[UIFont systemFontOfSize:UI_Font] isFixWidth:YES fixValue:self.width/_levelNumber];
    if (cellSize.height > MAIN_CELL_HEIGHT)
    {
        return cellSize.height;
    }
    else
    {
        return MAIN_CELL_HEIGHT;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //不同tableview 取不同的数据  根绝在数组里的位置一一对应取 第一次进来的时候 currentLevelDataArray不存在 取得是当前级的数据,当点击子集的时候,刷新的应该是下一层级的数据
    if (currentNeedRefreshLevelDataArray)
    {
        return currentNeedRefreshLevelDataArray.count;
    }
    if (tableView.tag-500+1 <= self.allDataArray.count)
    {
        NSMutableArray *dataArray = self.allDataArray[tableView.tag-500];
        return dataArray.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WSMultilevelMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil)
    {
        cell = [[WSMultilevelMenuCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identify];
    }
    
    WSDictBean *dataItem;
    WSDictBean *selectDataItem;
    if (currentNeedRefreshLevelDataArray)
    {
        dataItem = currentNeedRefreshLevelDataArray[indexPath.row];
    }
    else
    {
        NSMutableArray *dataArray = self.allDataArray[tableView.tag-500];
        //如果有回显,要自动滚动到各自列表相应的位置
        if (self.backShowLevelDataArray.count)
        {
            for (UITableView *tab in self.allTableViewArray) {
                NSMutableArray *dataArray = self.allDataArray[tab.tag-500];
                selectDataItem = self.backShowLevelDataArray[tab.tag-500];
                NSInteger index;
                for (WSDictBean *dict in dataArray) {
                    if ([dict.Id isEqualToString:selectDataItem.Id ]) {
                        index = [dataArray indexOfObject:dict];
                        dict.isSelected = YES;
                    }
                    else
                    {
                        dict.isSelected = NO;
                    }
                }
                NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
                [tab scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
        }
        dataItem = dataArray[indexPath.row];
    }
    
    if (tableView.tag-500 == 0)
    {
        cell.isHiddenSeparatorLine = YES;
        cell.isFirstTableView = YES;
        if (indexPath.row == 0 && !self.backShowLevelDataArray.count)
        {
            dataItem.isSelected = YES;
        }
    }
    cell.dictBean = dataItem;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //点击的tableview只有一个cell能被选中
    NSMutableArray *dataArray = self.allDataArray[tableView.tag-500];
    for (WSDictBean *dict in dataArray)
    {
        dict.isSelected = NO;
    }
    
    WSDictBean *dataItem = dataArray[indexPath.row];
    dataItem.isSelected = YES;
    [tableView reloadData];
    
    //判断点击的当前层级对应的下一层级是否有对应的数组装数据,有的话删除数组中的旧的数据,加入当前父级对应的子集数据,没有就初始化一个对应层级的数组,放对应层级的数据,统一由allDataArray管理 根据tableView.tag-500 的值取对应层级的数据
    NSMutableArray *nextLevelDataArray;
    if (tableView.tag-500+1 < self.allDataArray.count)
    {
        nextLevelDataArray = self.allDataArray[tableView.tag-500+1];
    }
    else
    {
        nextLevelDataArray = [NSMutableArray array];
        if((tableView.tag-500+1) < self.levelNumber /*最后一个层级不需要再加下一层级的数据进来*/)
        {
            [self.allDataArray addObject: nextLevelDataArray];
        }
    }
    
    //根据当前层级的数据,取得对应子集的数据
    NSMutableArray *currentLevelDataArray = self.allDataArray[tableView.tag-500];
    WSDictBean *dictBean = currentLevelDataArray[indexPath.row];
    if ([service queryDictsWithParentId:dictBean.Id filter:dictBean.typ].count)
    {
        //当点击的时候需要做当前点击层级的所有下级联动数据清理和刷新
        int needRemoveObjPrefixNumber =  (int)(tableView.tag-500+1);
        for (int i = needRemoveObjPrefixNumber; i < self.allDataArray.count; i++) {
            NSMutableArray *dataArray = self.allDataArray[i];
            [dataArray removeAllObjects];
            UITableView *currentRefreshTableView = self.allTableViewArray[i];
            [currentRefreshTableView reloadData];
        }
        [self.backShowLevelDataArray removeAllObjects];
        //重新获得当前点击层级的下一层级对应的数据
        [nextLevelDataArray addObjectsFromArray:[service queryDictsWithParentId:dictBean.Id filter:dictBean.typ]];
    }
    
    //点击的是最后一个层级就把数据传出去,做相应的处理
    if ((tableView.tag-500+1) == self.levelNumber)
    {
        //dictBean 就是当前点击的数据model 传出去
        if ([self.delegate respondsToSelector:@selector(wsDropListViewMultilevelMenuCellDidClickWithParam:)]) {
            [self.delegate wsDropListViewMultilevelMenuCellDidClickWithParam:dictBean];
        }
    }
    else
    {
        //点击的不是最后一个层级就刷新点击层级的下一级数据
        currentNeedRefreshLevelDataArray = nextLevelDataArray;
        UITableView *currentRefreshTableView = self.allTableViewArray[tableView.tag-500+1];
        [currentRefreshTableView reloadData];
        currentNeedRefreshLevelDataArray = nil;
    }
}

//回显滚动就把回显数据清楚,不然会一直滚动到需要显示回显的那个位置
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.backShowLevelDataArray removeAllObjects];
}

#pragma mark - Private
- (void)createSubViews
{
    [self.allTableViewArray removeAllObjects];
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 1)];
    topLineView.backgroundColor = [UIColor grayColor];
    [self addSubview:topLineView];
    for (int i = 0; i < self.levelNumber; i ++) {
        //        UITableView *menuTab = [[UITableView alloc] initWithFrame:CGRectMake(i > 0 ? (self.width*0.3 + (i-1)*(self.width*0.7/self.levelNumber)) : 0, topLineView.bottom, i > 0 ? (self.width*0.7/self.levelNumber) : self.width*0.3, self.height-topLineView.height) style:UITableViewStylePlain];
        UITableView *menuTab = [[UITableView alloc] initWithFrame:CGRectMake(i*(self.width/self.levelNumber), topLineView.bottom, self.width/self.levelNumber, self.height-topLineView.height) style:UITableViewStylePlain];
        menuTab.delegate = self;
        menuTab.dataSource = self;
        menuTab.tag = 500+i;
        menuTab.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (i == 0)
        {
            menuTab.backgroundColor = RGB_COLOR(MultilevelMenu_BackGroundView_Color);
        }
        else
        {
            menuTab.backgroundColor = [UIColor whiteColor];
        }
        
        [self addSubview: menuTab];
        [self.allTableViewArray addObject: menuTab];
    }
}

- (NSMutableArray *)allTableViewArray
{
    if (!_allTableViewArray) {
        _allTableViewArray = [NSMutableArray array];
    }
    return _allTableViewArray;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

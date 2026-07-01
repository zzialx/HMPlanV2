//
//  WSMultiSelectDropListPanel.m
//  WinSFA
//
//  Created by yang on 15-3-19.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSMultiSelectDropListPanel.h"
#import "WSDropListView.h"
#import "I_W_DisplayValue.h"
#import "I_W_BuildInfo.h"
#import "I_W_DataSource.h"
#import "WSArrayValueChangeChecker.h"
#import "WSStoreBean.h"
#import "WSDataSourceFromDSStore.h"


@implementation WSMultiSelectDropListPanel

/*
- (void) initRedisplayForLinkDepend
{
    //依赖父节点必须为空，只调用此方法一次
    if (self.parentMulSelectListView) {
        return;
    }
    
    [self initSubListSourceAndRedisplay];
}

- (void)initSubListSourceAndRedisplay{
    
    NSArray *originDataSource = [self getDataSource];
    NSMutableArray *dataSource = [NSMutableArray array];
    if (originDataSource && [originDataSource count] > 0) {
        [dataSource addObjectsFromArray:originDataSource];
    }
    //递归初始化子节点数据源
    if (self.subMulSelectListView) {
        [self.subMulSelectListView initSubListSourceAndRedisplay];
    }
    self.dropListView.dataSourceArray = dataSource;
    //区分手动操作和回显操作
    WSMultiSelectDropListPanel *subMulListTmp = self.subMulSelectListView;
    
    self.subMulSelectListView = nil;
    
    self.subMulSelectListView = subMulListTmp;
    //根据WSMultiSelectDropListPanel父级与子级关联之后回显的数据
    NSArray *selectItemIDArray = (NSArray *)[xdisplayValue getDisplayValueFor:xbuildInfo];
    if (selectItemIDArray) {
        [self.subMulSelectListView updateListSourceWithSelectAction];
        [self.dropListView setUpSelectionByItemIDArray:selectItemIDArray];
        
    }
    
    _originalValue = selectItemIDArray;
}
 */

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.oldRect = frame;
    if (self) {
        
        self.xvalueChangeChecker = [[WSArrayValueChangeChecker alloc] init];
        
        return self;
    }
    
    return nil;
}

- (void)buildDisplayContent
{
    [super buildDisplayContent];
    
    self.dropListView.selectMode = WSDropListViewSelectModeMultipleChoice;
    
    // 如果数据源仅有一项（不包括没有默认选项时添加的@""）且为必填则直接选中该选项
    if ([[xbuildInfo getISRequire] isEqualToString:@"1"] && [xdataSource.dataSourceArray count] == 1) {
        [self.dropListView setUpSelectionByItemIDArray:@[[[xdataSource.dataSourceArray firstObject] getDataItemID]]];
    }
   
   // SFA-17308 按钮模式不需要该功能
   if (![[xbuildInfo getDisplayMode] isEqualToString:QST_DISPLAYMODE_LABEL]) {
    // 如果多选框得话在下拉框下面增加一个列表
    CGFloat tableViewHeight = MAIN_CELL_HEIGHT * (self.dropListView.selectedItemArray.count);
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(self.bounds.origin.x, CGRectGetMaxY(self.dropListView.frame) , self.bounds.size.width, tableViewHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsSelection = NO;
//        self.tableView.userInteractionEnabled = NO;
//        if (self.dropListView.selectedItemArray.count > 0) {
//            [self addTableListView];
//        }
        [self addSubview:self.tableView ];
        self.height = self.size.height + self.tableView.height ;
        [self.tableView  reloadData];
   }
    //回显值
    NSArray *selectItemIDArray = (NSArray *)[xdisplayValue getDisplayValueFor:xbuildInfo];
    [self.dropListView setUpSelectionByItemIDArray:selectItemIDArray];
    _originalValue = selectItemIDArray;
   [self.superview setNeedsLayout];
}

-(void)addTableListView{
    
    UILabel * lable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.tableView.width - 20, 20)];
    UIView * headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.dropListView.frame.size.width - 20, 21)];
    headView.backgroundColor = [UIColor colorWithRed:208/255.0 green:208/255.0 blue:208/255.0 alpha:1];
    headView.layer.cornerRadius = 5;
    [headView addSubview:lable];
    lable.text = @"selected";
    lable.font = [UIFont systemFontOfSize:INTERFACE_IS_PHONE ? 12 : 16];
    [self.tableView setTableHeaderView:headView];

}

//- (NSObject *)getDisplayValuePresentation {
//
//    NSString *result = nil;
//    
//    if (_originalValue && [_originalValue isKindOfClass:[NSArray class]] && [(NSArray *)_originalValue count] > 0) {
//        
//        NSMutableArray *array = [NSMutableArray array];
//        
//        for (NSString *dataID in (NSArray *)_originalValue) {
//            for (NSObject<I_W_OptionDataItem> *item in xdataSource.dataSourceArray) {
//                if ([[item getDataItemID] isEqualToString:dataID]) {
//                    [array addObject:[item getDataItemName]];
//                    break;
//                }
//            }
//        }
//        
//        if ([array count] > 0) {
//            result = [array componentsJoinedByString:@","];
//        }
//        
//    }
//    
//    return result;
//}

#pragma mark - I_W_ValueChangeObject

- (NSObject *)getCurrentValue
{
        
    NSMutableArray *selectIDArray = nil;
    if ([self.dropListView.selectedItemArray count] > 0) {
        selectIDArray = [NSMutableArray array];
        for (NSObject<I_W_OptionDataItem> *dataItem in self.dropListView.selectedItemArray) {
            [selectIDArray addObject:[dataItem getDataItemID]];
        }
    }
    
    return selectIDArray;
}

//- (NSArray *)getDataSource{
//    // 根据父控件的选择的数据 去刷新子控件的数据
//    if (![xbuildInfo getDataSource] || (self.parentMulSelectListView && !self.parentMulSelectListView.dropListView.selectedItemArray)) {
//        return nil;  // 如果父级控没有数据 那么子级控件(数据源为空)数据不显示
//    }
//    
//    if ([xdataSource isKindOfClass:[WSDataSourceFromDSStore class]]) {
//        WSDataSourceFromDSStore *mulDataSource = (WSDataSourceFromDSStore *)xdataSource;
//        mulDataSource.parentSelectIdArray = self.parentMulSelectListView.dropListView.selectedItemArray;
//    }
//    
//    return (NSArray *)[xdataSource getDataSourceFor:xbuildInfo];
//}

- (NSArray *)getDataSource{
    
    NSString *parentSelectedIDs = [self.parentWidget getSelectedItemID];
    
    if (self.parentWidget && !parentSelectedIDs) {
        return nil;
    }
    
    if ([parentSelectedIDs length] > 0) {
        [xdataSource setParentSelectedItemID:parentSelectedIDs];
    }
    
    if ([xdataSource isKindOfClass:[WSDataSourceFromDSStore class]]) {
        WSDataSourceFromDSStore *mulDataSource = (WSDataSourceFromDSStore *)xdataSource;
        mulDataSource.parentSelectIdArray = [self.parentWidget getSelectedItemArray];
    }
    
    return (NSArray *)[xdataSource getDataSourceFor:xbuildInfo];
    
}

- (void)cleanSelection
{
    [super cleanSelection];
    [self refreshTableView];
}

- (void)refreshTableView
{
    // 根据tableView的高度调整Panel的高度
    if (self.tableView) {
        self.tableView.height = MAIN_CELL_HEIGHT *  (self.dropListView.selectedItemArray.count);
        if (self.dropListView.selectedItemArray.count == 0) {
            self.tableView.hidden = YES;
            [self.tableView setTableHeaderView:nil];
        }else{
            self.tableView.hidden = NO;
            //            [self addTableListView];
            [self.tableView reloadData];
        }
        self.height = CGRectGetMaxY(self.tableView.frame);
        CGRect rect = CGRectMake(self.origin.x, self.origin.y, self.width, self.height);
        [self.xbuildInfo setLayOutInfo:rect];
        [self.superview layoutSubviews];
    }
}


/**
 *  更新下拉列表数据源
 */
//- (void) updateListSourceWithSelectAction
//{
//    NSArray *nameList = [[NSArray alloc]init];
//    nameList = [self getDataSource];
//    self.dropListView.dataSourceArray = nameList;
//    [self.dropListView flushTable];
//    NSArray *selectItemIDArray = (NSArray *)[xdisplayValue getDisplayValueFor:xbuildInfo];
//    
//    [self.dropListView setUpSelectionByItemIDArray:selectItemIDArray];
//    
//}
#pragma mark - WSDropListViewDelegate
- (void)dropListViewDidChangeSelect:(WSDropListView *)dropListView{
    [super dropListViewDidChangeSelect:dropListView];
    [self refreshTableView];
   [self.superview setNeedsLayout];
}


- (void)reloadCurrentWidgetWithValue:(NSObject *)value {
   if (value) {
      NSArray *selectItemIds = nil;
      if ([value isKindOfClass:[NSString class]]) {
         selectItemIds = [(NSString *)value componentsSeparatedByString:@","];
      } else if ([value isKindOfClass:[NSArray class]]) {
         selectItemIds = (NSArray *)value;
      } else {
         LogError(@"参数错误");
         return;
      }
      // SFA-23057 self.dropListView.dataSourceArray 中会存取 WSDictBean 和 WSBaseOptionDataItem 两种类型数据
      // WSBaseOptionDataItem 没有 ID  所以不能使用 .iD 过滤
//      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.Id in %@",selectItemIds];
//      NSArray *redisArrray = [self.dropListView.dataSourceArray filteredArrayUsingPredicate:predicate];
      NSMutableArray *redisArrray = [NSMutableArray array];
      for (NSObject <I_W_OptionDataItem> *item in self.dropListView.dataSourceArray) {
         for (NSString *selectItem in selectItemIds) {
            if ([selectItem isEqualToString:[item getDataItemID]]) {
               [redisArrray addObject:item];
            }
         }
      }
      
      self.dropListView.selectedItemArray = [NSMutableArray arrayWithArray: redisArrray];
      
//      self.tableView.height = MAIN_CELL_HEIGHT  *  (self.dropListView.selectedItemArray.count);
//      [self.tableView  reloadData];
//      self.height = CGRectGetMaxY(self.tableView.frame);
   }else {
      /*to do something*/
   }

}


#pragma mark - tableViewDelegate tableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dropListView.selectedItemArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * reuserID = @"tableViewCellID";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:reuserID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserID];
    }
    NSObject <I_W_OptionDataItem> *option = self.dropListView.selectedItemArray[indexPath.row];
    if ([option conformsToProtocol:@protocol(I_W_OptionDataItem)]) {
        cell.textLabel.text = [option getDataItemName];
    }
    // MN-2305
    cell.backgroundColor = MAIN_CELL_DISABLE_COLOR;
    cell.textLabel.textColor = DETAIL_TEXT_COLOR;
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icn_check_disable"]];
    cell.textLabel.font = [UIFont systemFontOfSize:UI_Font];
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    cell.textLabel.numberOfLines = 0;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return MAIN_CELL_HEIGHT;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.dropListView.selectedItemArray removeObjectAtIndex:indexPath.row];
//        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
      
       if ([self.dropListView isKindOfClass:[WSDropListView class]]) {
          [(WSDropListView *)self.dropListView updateButtonTitle];
       }
        [self dropListViewDidChangeSelect:self.dropListView];
    }
}
@end

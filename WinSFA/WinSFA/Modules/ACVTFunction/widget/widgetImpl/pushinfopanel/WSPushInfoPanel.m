//
//  WSPushInfoPanel.m
//  WinSFA
//
//  Created by xiajl on 15/3/31.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSPushInfoPanel.h"
#import "WidgetConstant.h"
#import "WSTableItemsArray.h"
#import "WSPIGride.h"
#import "I_W_BuildInfo.h"
#import "WSPITableView.h"
#import "WSStoreInfoBeanArray.h"
#import "I_W_DataSource.h"
#import "WSFuncsBeanArray.h"

#define DATAGRID_CELL_HEIGHT_DEFAULT    (INTERFACE_IS_PHONE ? 40.0f : 55.0f)

@interface WSPushInfoPanel()<WSPITableViewDataSource>

//pushinfo信息表头和表格内容信息数据
@property (nonatomic, strong) NSArray *headDataOfPITableView;

// TB节点包含的表格配置信息
@property (nonatomic, strong) WSTableItem *tableItem;

@property (nonatomic, strong) WSPITableView *tableView;
@end

@implementation WSPushInfoPanel

-(void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    [super loadBuildInfo:buildInfo];
    
    WSTableItemsArray *tbArray = [WSAppData getObjectbyKey:TB];
    NSArray *itemsArray = [tbArray getTableItemWithMc:[buildInfo getMenuCode]];
    
    if ([itemsArray count] > 0) {
        self.tableItem = [itemsArray objectAtIndex:0];
    }else {
        self.tableItem = [self getTableItemWithMc:[buildInfo getMenuCode]];
    }
    [self initHeadData];
    
}

-(void)buildDisplayContent{
    
    [super buildDisplayContent];
    
    CGFloat mContentHeight = [[xdataSource.dataSourceArray firstObject] count] * DATAGRID_CELL_HEIGHT_DEFAULT + ([[xdataSource.dataSourceArray firstObject] count]) * 1. + 60.;
    
    if (!self.tableView) {
        self.tableView = [[WSPITableView alloc] initWithFrame:CGRectZero];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.datasource = self;
        [self addSubview:self.tableView];
    }
    
    if (mContentHeight > 300) {
        mContentHeight = 300 ;
    }
    
    [self.tableView setFrame:CGRectInset(CGRectMake(0,0, CGRectGetWidth(self.frame) - 10.f, mContentHeight), 10.0f, 10.0f)];
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, CGRectGetWidth(self.frame), mContentHeight + SPACEHEIGTH)];
    [self.tableView reloadData];
}
- (void)loadDataSource:(NSObject<I_W_DataSource> *)datasource
{
    [super loadDataSource:datasource];
    [datasource getDataSourceFor:xbuildInfo];

}

- (void) setParentView:(UIView *)scrollview
{
//    if (scrollview && self.mWSPIGride) {
//        [self.mWSPIGride setParent:scrollview];
//        [self.mWSPIGride showViewWithFrame:CGRectMake(0, TITLE_AND_OPTION_SAPCE_HEIGHT , CGRectGetWidth(self.bounds), self.mWSPIGride.mContentHeight)];
//        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, CGRectGetWidth(self.frame), self.mWSPIGride.mContentHeight+SPACEHEIGTH)];
//    }
}

#pragma mark - private

- (void) initHeadData
{
    //    初始化表头数据
     NSMutableArray *headArray = [[NSMutableArray alloc] init];
    if (self.tableItem.paramArray && [self.tableItem.paramArray count] > 0) {
        for (WSFuncsBean_Param *param in self.tableItem.paramArray) {
            [headArray addObject:[NSString stringNotNilWithValue:param.name]];
        }
    }
      self.headDataOfPITableView = headArray;
    
}

- (CGFloat) getUIKitWidthWithColumn : (NSUInteger) column
{
    CGFloat width = [SHORT_COLUMN_WIDTH floatValue];
    if (self.tableItem.paramArray
        && [self.tableItem.paramArray count] > 0
        && column < [self.tableItem.paramArray count]) {
        WSFuncsBean_Param *param = [self.tableItem.paramArray objectAtIndex:column];
        if ([param.tpy isEqualToString:COL_TYPL]) {
            
            width = [param.charNum integerValue] * UINIT_WIDTH_OTHER;
        }else{
            
            width = [param.charNum integerValue] * UINIT_WIDTH_OTHER + UINIT_SPACE_WIDTH * 2;
        }
        
    }
    return width;
}

- (WSTableItem *)getTableItemWithMc:(NSString *)mc
{
    WSFuncsBeanArray *funcsBeanArray = [WSAppData getObjectbyKey:FUNCS];
    WSFuncsBean *funcsBean = [funcsBeanArray getHideFuncsBeanWithFC:mc];
    WSTableItem *tableItem = nil;
    if (funcsBean) {
        tableItem = [[WSTableItem alloc] initWithFuncsBean:funcsBean];
    }
    
    return tableItem;
}


#pragma mark -  WSPITableViewDataSource

- (NSArray *)arrayDataForTopHeaderInTableView:(WSPITableView *)tableView {
    return [self.headDataOfPITableView copy];
}

- (NSArray *)arrayDataForContentInTableView:(WSPITableView *)tableView InSection:(NSUInteger)section {
    if(xdataSource.dataSourceArray.count>section)
       return [xdataSource.dataSourceArray objectAtIndex:section];
    else
        return nil;
}


- (NSUInteger)numberOfSectionsInPITableView:(WSPITableView *)tableView {
    
    return [xdataSource.dataSourceArray count];
}

- (CGFloat)tableView:(WSPITableView *)tableView contentTableCellWidth:(NSUInteger)column {
    
    return  [self getUIKitWidthWithColumn:column];
}

- (CGFloat)topHeaderHeightInTableView:(WSPITableView *)tableView
{
    
    return DATAGRID_CELL_HEIGHT_DEFAULT ;
}

- (CGFloat)tableView:(WSPITableView *)tableView cellHeightInRow:(NSUInteger)row InSection:(NSUInteger)section {
    
    return DATAGRID_CELL_HEIGHT_DEFAULT;
}

- (UIColor *)tableView:(WSPITableView *)tableView bgColorInSection:(NSUInteger)section InRow:(NSUInteger)row InColumn:(NSUInteger)column {
    
    return [UIColor clearColor];
}

- (UIColor *)tableView:(WSPITableView *)tableView headerBgColorInColumn:(NSUInteger)column {
    
    return [UIColor clearColor];
}

- (void)setParent:(UIScrollView *) parent
{
    
    self.tableView.parentScrollView = parent;
}

@end

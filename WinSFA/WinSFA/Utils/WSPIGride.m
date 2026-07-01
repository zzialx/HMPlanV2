  //
//  WSPIGride.m
//  WinSFA
//
//  Created by xiajl on 14-7-23.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSPIGride.h"
#import "WSPITableView.h"
#import "WSStoreInfoBeanArray.h"
#import "WSTableItem.h"
#define DATAGRID_CELL_HEIGHT_DEFAULT    (INTERFACE_IS_PHONE ? 40.0f : 55.0f)


@interface WSPIGride () <WSPITableViewDataSource>
{
    WSPITableView *tableView;

}
//pushinfo信息表头和表格内容信息数据
@property (nonatomic, strong) NSMutableArray *headDataOfPITableView;
@property (nonatomic, strong) NSMutableArray *rightTableDataOfPITableView;

@property (nonatomic, strong) WSTableItem *tableItem;

@end

@implementation WSPIGride

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (void)setDataSurceWithDictionary:(WSTableItem *)tableItem andStoreInfoType:(NSString*)aSInfoType andStoreInfoId:(NSString*)aStoreId
{
    self.tableItem = tableItem;
    [self initHeadData];
    [self initStoreInfoDatasSourcesWithType:aSInfoType andID:aStoreId];
    
}

- (void)showViewWithFrame:(CGRect)frame
{
    
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setFrame:frame];
    

    tableView = [[WSPITableView alloc] initWithFrame:CGRectInset(CGRectMake(0,0, self.frame.size.width - 10.f, self.frame.size.height), 10.0f, 10.0f)];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.datasource = self;
    [self addSubview:tableView];
    [tableView reloadData];
    
}

- (void)initStoreInfoDatasSourcesWithType:(NSString *)aType andID:(NSString *)storeId  {
    
    if (!self.tableItem) {
        return;
    }
    
    NSString *dsValue = self.tableItem.ds;
    WSStoreInfoBeanArray *storeInfoBeans = [WSAppData getObjectbyKey:dsValue];
    
    self.rightTableDataOfPITableView = [NSMutableArray arrayWithCapacity:1];
    
    NSMutableArray *rowArray = [NSMutableArray arrayWithCapacity:10];
    for (WSStoreInfoBean *storeInBean in storeInfoBeans.storeinfoArray) {
        if (storeInBean.typ
            && storeInBean.storeId
            && [storeInBean.typ isEqualToString:aType]
            && [storeInBean.storeId isEqualToString:storeId]) {
            
            NSMutableArray *columnArray = [NSMutableArray arrayWithCapacity:[self.tableItem.paramArray count]];
            //按表格配置顺序 显示列
            for (WSFuncsBean_Param *param in self.tableItem.paramArray) {
                if ([param.col isEqualToString:STOREINFO_COL1]) {
                    
                    [columnArray addObject:[NSString stringNotNilWithValue:storeInBean.col1]];
                }else if ([param.col isEqualToString:STOREINFO_COL2]){
                    
                    [columnArray addObject:[NSString stringNotNilWithValue:storeInBean.col2]];
                }else if ([param.col isEqualToString:STOREINFO_COL3]){
                    
                    [columnArray addObject:[NSString stringNotNilWithValue:storeInBean.col3]];
                }else if ([param.col isEqualToString:STOREINFO_COL4]){
                    
                    [columnArray addObject:[NSString stringNotNilWithValue:storeInBean.col4]];
                }else if ([param.col isEqualToString:STOREINFO_COL5]){
                    
                    [columnArray addObject:[NSString stringNotNilWithValue:storeInBean.col5]];
                }
            }
            if([columnArray count] > 0){
                [rowArray addObject:columnArray];
            }

        }
    }
////    测试数据
//     NSMutableArray *columnArray = [NSMutableArray arrayWithCapacity:3];
//    [columnArray addObject:[NSString stringNotNilWithValue:@"1111"]];
//    [columnArray addObject:[NSString stringNotNilWithValue:@"2222"]];
//    [columnArray addObject:[NSString stringNotNilWithValue:@"3333"]];
//    [columnArray addObject:[NSString stringNotNilWithValue:@"4444"]];
//    [columnArray addObject:[NSString stringNotNilWithValue:@"5555"]];
//    
//    for (int i =0 ; i < 100; i++) {
//        [rowArray addObject:columnArray];
//    }
//

    
    if ([rowArray count] > 0) {
        
        self.isAlllowShow = YES;
    }else{
        
        self.isAlllowShow = NO;
    }
    
    [self.rightTableDataOfPITableView addObject:rowArray];
    
    self.mContentHeight = [rowArray count] * DATAGRID_CELL_HEIGHT_DEFAULT + ([rowArray count]) * 1. + 60;

}

- (void) initHeadData
{
    //    初始化表头数据
    if (self.tableItem.paramArray && [self.tableItem.paramArray count] > 0) {
        self.headDataOfPITableView = [NSMutableArray arrayWithCapacity:[self.tableItem.paramArray count]];
        for (WSFuncsBean_Param *param in self.tableItem.paramArray) {
            [self.headDataOfPITableView addObject:[NSString stringNotNilWithValue:param.name]];
        }
    }
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

#pragma mark -  WSPITableViewDataSource

- (NSArray *)arrayDataForTopHeaderInTableView:(WSPITableView *)tableView {
    return [self.headDataOfPITableView copy];
}

- (NSArray *)arrayDataForContentInTableView:(WSPITableView *)tableView InSection:(NSUInteger)section {
    
    return [self.rightTableDataOfPITableView objectAtIndex:section];
}


- (NSUInteger)numberOfSectionsInPITableView:(WSPITableView *)tableView {
    
    return [self.rightTableDataOfPITableView count];
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
    
    tableView.parentScrollView = parent;
}
@end

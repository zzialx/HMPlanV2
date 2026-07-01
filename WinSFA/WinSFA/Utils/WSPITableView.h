//
//  WSPITableView.h
//  WinSFA
//
//  Created by xiajl on 14-7-23.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SortColumnType) {
    SortColumnTypeInteger,
    SortColumnTypeFloat,
    SortColumnTypeDate,
};

@protocol WSPITableViewDataSource;

@interface WSPITableView : UIView


@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) CGFloat topHeaderHeight;

@property (nonatomic, assign) CGFloat normalSeperatorLineWidth;
@property (nonatomic, strong) UIColor *normalSeperatorLineColor;


@property (nonatomic, weak) id<WSPITableViewDataSource> datasource;

@property (nonatomic, strong) UIScrollView *parentScrollView;


- (void)reloadData;

@end

@protocol WSPITableViewDataSource <NSObject>

@required
- (NSArray *)arrayDataForTopHeaderInTableView:(WSPITableView *)tableView;
- (NSArray *)arrayDataForContentInTableView:(WSPITableView *)tableView InSection:(NSUInteger)section;

@optional
- (NSUInteger)numberOfSectionsInPITableView:(WSPITableView *)tableView;
- (CGFloat)tableView:(WSPITableView *)tableView contentTableCellWidth:(NSUInteger)column;
- (CGFloat)tableView:(WSPITableView *)tableView cellHeightInRow:(NSUInteger)row InSection:(NSUInteger)section;
- (CGFloat)topHeaderHeightInTableView:(WSPITableView *)tableView;
- (UIColor *)tableView:(WSPITableView *)tableView bgColorInSection:(NSUInteger)section InRow:(NSUInteger)row InColumn:(NSUInteger)column;
- (UIColor *)tableView:(WSPITableView *)tableView headerBgColorInColumn:(NSUInteger)column;

@end

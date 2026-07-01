//
//  WSPITableView.m
//  WinSFA
//
//  Created by xiajl on 14-7-23.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSPITableView.h"
#import "WSPITableViewBGScrollView.h"
#import "UIView+WSPITableView.h"

#define DATAGRID_TITLE_FONTSIZE  (INTERFACE_IS_PHONE ? 15.0 : 17.0)

#define AddHeightTo(v, h) { CGRect f = v.frame; f.size.height += h; v.frame = f; }

//typedef NS_ENUM(NSUInteger, TableColumnSortType) {
//    TableColumnSortTypeAsc,
//    TableColumnSortTypeDesc,
//    TableColumnSortTypeNone
//};

@interface WSPITableView () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

- (void)reset;
- (void)adjustView;
- (void)setUpTopHeaderScrollView;
- (void)accessColumnPointCollection;
- (void)buildSectionFoledStatus:(NSInteger)section;

- (CGFloat)accessContentTableViewCellWidth:(NSUInteger)column;
- (UITableViewCell *)contentTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@implementation WSPITableView{
    WSPITableViewBGScrollView *topHeaderScrollView;
    WSPITableViewBGScrollView *contentScrollView;
    UITableView *contentTableView;
    
    NSMutableDictionary *sectionFoldedStatus;
    NSArray *columnPointCollection;
    
    NSMutableArray *contentDataArray;
    
    NSMutableDictionary *columnTapViewDict;
    
    NSMutableDictionary *columnSortedTapFlags;
    
    BOOL responseToNumberSections;
    BOOL responseContentTableCellWidth;
    BOOL responseNumberofContentColumns;
    BOOL responseCellHeight;
    BOOL responseTopHeaderHeight;
    BOOL responseBgColorForColumn;
    BOOL responseHeaderBgColorForColumn;
    
    BOOL isAnim;
}

@synthesize cellWidth, cellHeight, topHeaderHeight, normalSeperatorLineWidth;
@synthesize normalSeperatorLineColor;

//@synthesize leftHeaderEnable;

@synthesize datasource;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        cellWidth = 150.;
        cellHeight = 30.;
        topHeaderHeight = 60.;
        normalSeperatorLineWidth = 1.;
        normalSeperatorLineColor = [UIColor colorWithWhite:223.0f/255.0f alpha:1.0];
        
        
        topHeaderScrollView = [[WSPITableViewBGScrollView alloc] initWithFrame:CGRectZero];
        topHeaderScrollView.backgroundColor = [UIColor clearColor];
        topHeaderScrollView.parent = self;
        topHeaderScrollView.delegate = self;
        topHeaderScrollView.showsHorizontalScrollIndicator = NO;
        topHeaderScrollView.showsVerticalScrollIndicator = NO;
        topHeaderScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:topHeaderScrollView];
        
        contentScrollView = [[WSPITableViewBGScrollView alloc] initWithFrame:CGRectZero];
        contentScrollView.backgroundColor = [UIColor clearColor];
        contentScrollView.parent = self;
        contentScrollView.delegate = self;
        contentScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:contentScrollView];
        
        contentTableView = [[UITableView alloc] initWithFrame:contentScrollView.bounds];
        contentTableView.dataSource = self;
        contentTableView.delegate = self;
        contentTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        contentTableView.backgroundColor = [UIColor clearColor];
        [contentScrollView addSubview:contentTableView];

        
    }
    return self;
}


- (void)layoutSubviews {
    
    [super layoutSubviews];
    CGFloat superWidth = self.bounds.size.width;
    CGFloat superHeight = self.bounds.size.height;
    
    
    topHeaderScrollView.frame = CGRectMake(0, 0, superWidth, [self accessTopHeaderHeight]);
    contentScrollView.frame = CGRectMake(0, [self accessTopHeaderHeight] + normalSeperatorLineWidth, superWidth, superHeight - [self accessTopHeaderHeight] - normalSeperatorLineWidth);
    
    [self adjustView];
}

- (void)reloadData {
    [self reset];
    [contentTableView reloadData];
}

- (void)dealloc {
    topHeaderScrollView = nil;
    contentScrollView = nil;
    contentTableView = nil;
    columnPointCollection = nil;
}

#pragma mark - property

- (void)setDatasource:(id<WSPITableViewDataSource>)datasource_ {
    if (datasource != datasource_) {
        datasource = datasource_;
        
        responseToNumberSections = [datasource_ respondsToSelector:@selector(numberOfSectionsInTableView:)];
        responseContentTableCellWidth = [datasource_ respondsToSelector:@selector(tableView:contentTableCellWidth:)];
        responseNumberofContentColumns = [datasource_ respondsToSelector:@selector(arrayDataForTopHeaderInTableView:)];
        responseCellHeight = [datasource_ respondsToSelector:@selector(tableView:cellHeightInRow:InSection:)];
        responseTopHeaderHeight = [datasource_ respondsToSelector:@selector(topHeaderHeightInTableView:)];
        responseBgColorForColumn = [datasource_ respondsToSelector:@selector(tableView:bgColorInSection:InRow:InColumn:)];
        responseHeaderBgColorForColumn = [datasource_ respondsToSelector:@selector(tableView:headerBgColorInColumn:)];
        
        [self reset];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self cellHeightInIndexPath:indexPath];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSUInteger rows = 0;
    if (![self foldedInSection:section]) {
        rows = [self rowsInSection:section];
    }
    
    return rows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self numberOfSections];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self contentTableView:tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    

    UIScrollView *target = nil;
    
    if (scrollView == contentScrollView) {
        target = topHeaderScrollView;
    }else if (scrollView == topHeaderScrollView) {
        target = contentScrollView;
    }
    target.contentOffset = scrollView.contentOffset;
//    需要继续完善
//    if (self.parentScrollView
//        && self.parentScrollView.contentSize.height > self.parentScrollView.frame.size.height
//        && (self.frame.origin.y + self.frame.size.height) >= self.parentScrollView.frame.size.height) {
//        
//        CGFloat height1 = contentTableView.contentSize.height - contentScrollView.contentSize.height;
//        CGFloat height2 = self.parentScrollView.contentSize.height - self.parentScrollView.frame.size.height;
//        CGFloat y = scrollView.contentOffset.y * (height2 > height1 ? height1 * 1.5  : height2) / height1 ;
//        self.parentScrollView.contentOffset = CGPointMake(0, y);
//        
//    }
}

-(void)setParentScrollView:(UIScrollView *)parentScrollView
{
    _parentScrollView = parentScrollView;
}

#pragma mark - private method

- (void)reset {
    
    columnTapViewDict = [NSMutableDictionary dictionary];
    columnSortedTapFlags = [NSMutableDictionary dictionary];
    
    [self accessDataSourceData];
    
    [self accessColumnPointCollection];
    [self buildSectionFoledStatus:-1];
    [self setUpTopHeaderScrollView];
    [contentScrollView reDraw];
}

- (void)adjustView {
    
    CGFloat width = 0.0f;
    NSUInteger count = [datasource arrayDataForTopHeaderInTableView:self].count;
    for (int i = 1; i <= count + 1; i++) {
        if (i == count + 1) {
            width += normalSeperatorLineWidth;
        }else {
            width += normalSeperatorLineWidth + [self accessContentTableViewCellWidth:i - 1];
        }
    }
    
    topHeaderScrollView.contentSize = CGSizeMake(width, [self accessTopHeaderHeight]);

    contentScrollView.contentSize = CGSizeMake(width, self.bounds.size.height - [self accessTopHeaderHeight] - normalSeperatorLineWidth);
    
    contentTableView.frame = CGRectMake(0.0f, 0.0f, width, self.bounds.size.height - [self accessTopHeaderHeight] - normalSeperatorLineWidth);
    
    [topHeaderScrollView addTopLineWithWidth:normalSeperatorLineWidth bgColor:normalSeperatorLineColor drawWidth:width];
    
    [contentScrollView addBottomLineWithWidth:normalSeperatorLineWidth bgColor:normalSeperatorLineColor drawWidth:width];
}

- (void)buildSectionFoledStatus:(NSInteger)section {
    if (sectionFoldedStatus == nil) sectionFoldedStatus = [NSMutableDictionary dictionary];
    
    NSUInteger sections = [self numberOfSections];
    for (int i = 0; i < sections; i++) {
        if (section == -1) {
            [sectionFoldedStatus setObject:[NSNumber numberWithBool:NO] forKey:[self sectionToString:i]];
        }else if (i == section) {
            if ([self foldedInSection:section]) {
                [sectionFoldedStatus setObject:[NSNumber numberWithBool:NO] forKey:[self sectionToString:section]];
            }else {
                [sectionFoldedStatus setObject:[NSNumber numberWithBool:YES] forKey:[self sectionToString:section]];
            }
            break;
        }
    }
}

- (void)setUpTopHeaderScrollView {
    
    NSUInteger count = [datasource arrayDataForTopHeaderInTableView:self].count;
    for (int i = 0; i < count; i++) {
        
        CGFloat topHeaderW = [self accessContentTableViewCellWidth:i];
        CGFloat topHeaderH = [self accessTopHeaderHeight];
        
        CGFloat widthP = [[columnPointCollection objectAtIndex:i] floatValue];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, topHeaderW, topHeaderH)];
        view.clipsToBounds = YES;
        view.center = CGPointMake(widthP, topHeaderH / 2.0f);
        view.tag = i;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.text = [[datasource arrayDataForTopHeaderInTableView:self] objectAtIndex:i];
        label.font = [UIFont systemFontOfSize:DATAGRID_TITLE_FONTSIZE];
        [label sizeToFit];
        label.center = CGPointMake(topHeaderW / 2.0f, topHeaderH / 2.0f);
        
        UIColor *color = [self headerBgColorColumn:i];
        view.backgroundColor = color;
        label.backgroundColor = color;
        
        [view addSubview:label];
        
        [topHeaderScrollView addSubview:view];
       
    }
    
    [topHeaderScrollView reDraw];
  
    
}

- (void)accessColumnPointCollection {
    NSUInteger columns = responseNumberofContentColumns ? [datasource arrayDataForTopHeaderInTableView:self].count : 0;
    if (columns == 0) @throw [NSException exceptionWithName:@"emptycolumns" reason:@"number of content columns must more than 0" userInfo:nil];
    NSMutableArray *tmpAry = [NSMutableArray array];
    CGFloat widthColumn = 0.0f;
    CGFloat widthP = 0.0f;
    for (int i = 0; i < columns; i++) {
        CGFloat columnWidth = [self accessContentTableViewCellWidth:i];
        widthColumn += (normalSeperatorLineWidth + columnWidth);
        widthP = widthColumn - columnWidth / 2.0f;
        [tmpAry addObject:[NSNumber numberWithFloat:widthP]];
    }
    columnPointCollection = [tmpAry copy];
}

- (CGFloat)accessContentTableViewCellWidth:(NSUInteger)column {
    return responseContentTableCellWidth ? [datasource tableView:self contentTableCellWidth:column] : cellWidth;
}

- (UITableViewCell *)contentTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger count = [datasource arrayDataForTopHeaderInTableView:self].count;
    static NSString *cellID = @"contentTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell addTopLineWithWidth:normalSeperatorLineWidth bgColor:normalSeperatorLineColor];
        
    }
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSMutableArray *ary = [[contentDataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    for (int i = 0; i < count; i++) {
        
        CGFloat cellW = [self accessContentTableViewCellWidth:i];
        CGFloat cellH = [self cellHeightInIndexPath:indexPath];
        
        CGFloat width = [[columnPointCollection objectAtIndex:i] floatValue];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cellW, cellH)];
        view.center = CGPointMake(width, cellH / 2.0f);
        view.clipsToBounds = YES;
        
        UILabel *label = [[UILabel alloc] initWithFrame:view.frame];
        if (i < [ary count]) {
               label.text = [NSString stringWithFormat:@"%@", [ary objectAtIndex:i]];
        }else{
             label.text = @"";
        }
     
        label.font = [UIFont systemFontOfSize:DATAGRID_TITLE_FONTSIZE];
        [label sizeToFit];
        label.center = CGPointMake(cellW / 2.0f, cellH / 2.0f);
        label.textAlignment = NSTextAlignmentCenter;
        
        UIColor *color = [self bgColorInSection:indexPath.section InRow:indexPath.row InColumn:i];
        
        view.backgroundColor = color;
        label.backgroundColor = color;
        
        [view addSubview:label];
        
        [cell.contentView addSubview:view];
    }
    
    AddHeightTo(cell, normalSeperatorLineWidth);
    
    return cell;
}

#pragma mark - GestureRecognizer



#pragma mark - other method

- (NSUInteger)rowsInSection:(NSUInteger)section {
    if(contentDataArray.count>section)
       return [[contentDataArray objectAtIndex:section] count];
    else
        return 0;
}

- (NSUInteger)numberOfSections {
    NSUInteger sections = responseToNumberSections ? [datasource numberOfSectionsInPITableView:self] : 1;
    return sections < 1 ? 1 : sections;
}

- (NSString *)sectionToString:(NSUInteger)section {
    return [NSString stringWithFormat:@"%lu", (unsigned long)section];
}

- (BOOL)foldedInSection:(NSUInteger)section {
    return [[sectionFoldedStatus objectForKey:[self sectionToString:section]] boolValue];
}

- (CGFloat)cellHeightInIndexPath:(NSIndexPath *)indexPath {
    return responseCellHeight ? [datasource tableView:self cellHeightInRow:indexPath.row InSection:indexPath.section] : cellHeight;
}

- (CGFloat)accessTopHeaderHeight {
    return responseTopHeaderHeight ? [datasource topHeaderHeightInTableView:self] : topHeaderHeight;
}

- (UIColor *)bgColorInSection:(NSUInteger)section InRow:(NSUInteger)row InColumn:(NSUInteger)column {
    return responseBgColorForColumn ? [datasource tableView:self bgColorInSection:section InRow:row InColumn:column] : [UIColor clearColor];
}

- (UIColor *)headerBgColorColumn:(NSUInteger)column {
    return responseHeaderBgColorForColumn ? [datasource tableView:self headerBgColorInColumn:column] : [UIColor clearColor];
}

- (void)accessDataSourceData {
    contentDataArray = [NSMutableArray array];
    
    NSUInteger sections = [datasource numberOfSectionsInPITableView:self];
    for (int i = 0; i < sections; i++) {
        [contentDataArray addObject:[datasource arrayDataForContentInTableView:self InSection:i]];
    }
}

- (NSIndexPath *)accessUIViewVirtualTag:(UIView *)view {
    for (NSString *key in [columnTapViewDict allKeys]) {
        UIView *vi = [columnTapViewDict objectForKey:key];
        if (vi == view) {
            NSArray *sep = [key componentsSeparatedByString:@"_"];
            NSUInteger section = [[sep objectAtIndex:0] integerValue];
            NSUInteger row = [[sep objectAtIndex:1] integerValue];
            return [NSIndexPath indexPathForRow:row inSection:section];
        }
    }
    return nil;
}


@end

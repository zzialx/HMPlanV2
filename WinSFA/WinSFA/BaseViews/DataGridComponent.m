//
//  DataGridComponent.m
//
//  Created by lee jory on 09-10-22.
//  Copyright 2009 Netgen. All rights reserved.
//

#import "DataGridComponent.h"
#import <QuartzCore/QuartzCore.h>
#import "WSSelectListView.h"
#import "WSDropListView.h"
#import "WSCheckBox.h"
#import "WSAcvtDataGridComponentDataSource.h"
#import "WCURLUILabel.h"
#import "WSDatePickerLabel.h"
#import "WSGridImageHeaderView.h"
#import "NSString+Additions.h"
#import "WSBaseProductDBService.h"
#import "WSAcvtDataGridComponentService.h"
#import "WSAcvtDataGridViewPanel.h"
#import "HYPageView.h"
#import "UIView+Additions.h"
#import "WSGridWidget.h"
#import "WSGridCheckBoxAll.h"

#define HeaderTextFont              [UIFont fontWithName:@"STHeitiSC-Light" size:DATAGRID_TITLE_FONTSIZE]
#define kGridHeaderTitleFont        ([UIFont fontForKey:@"BasePannelTitle"] ? [UIFont fontForKey:@"BasePannelTitle"] : HeaderTextFont)
#define CellTextFont                [UIFont fontWithName:@"Helvetica-Light" size:DATAGRID_TITLE_FONTSIZE]
#define kLeftTitleFont              ([UIFont fontForKey:@"GridLeftTitleFont"] ?:CellTextFont)
#define Grid_View_Height_Y_Offset   15.0f
#define EXTRA_WIDTH                 38.0f
#define SEPARATELINE_HEIGHT         15.0f
//===============================================================================================================================================================================

@implementation DataGridComponentDataSource
@synthesize titles,data,columnWidth, rowHeight;

- (void)reloadDataSourceWith:(NSArray *)prods changeSerieLinkHeadViewTitleWith:(NSString *)brandSerieName {
    
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)isShowThumbnail {
    
    if ([self.currentTableItem.showThumbnail isEqualToString:@"1"]) {
        return YES;
    }
    return NO;
}

- (NSInteger)getCellRowCount {
    
    NSInteger rowCnt = 1;
    if (self.rightTableShowType == WSDataGridComponentRightTableColumnMaxShowType) {
        
        int hiddenParamCnt = 0;
        for (WSFuncsBean_Param *param in self.currentTableItem.paramArray) {
        
            if (![param.gone isEqualToString:@"0"] && param.gone.length > 0) {
                hiddenParamCnt += 1;
            }
        }
        
        int showParamArrayCnt = (int)[self.currentTableItem.paramArray count] - hiddenParamCnt;
        if (self.currentTableItem.paramArray && self.rightTableShowColOrRowMaxValue) {
            
            int tempCnt = showParamArrayCnt/self.rightTableShowColOrRowMaxValue;
            if (tempCnt > 0) {
                
                if (showParamArrayCnt%self.rightTableShowColOrRowMaxValue > 0) {
                    tempCnt += 1;
                }
            }
            else {
                tempCnt = 1;
            }
            rowCnt = tempCnt;
        }
    }
    
    return rowCnt;
}

- (CGFloat)resetCellHeightWithOriginHeight:(CGFloat)height {
    
    if (self.rightTableShowType == WSDataGridComponentRightTableColumnMaxShowType) {
        height *= [self getCellRowCount];
    }
    else if (self.rightTableShowType == WSDataGridComponentRightTableRowMaxShowType) {
        height *= self.rightTableShowColOrRowMaxValue;
    }
    return height;
}

@end
//===============================================================================================================================================================================

@interface DataGridComponent () <UITextFieldDelegate> {
    
    CGRect selfFrameBeforeRedraw;
    CGRect leftFrameBeforeRedraw;
    CGRect scrollFrameBeforeRedraw;
    CGRect rightFrameBeforeRedraw;
    CGRect bLineFrameBeforeRedraw;
    CGFloat originY;
    BOOL isStartAnim;
    BOOL notResetSelfFrame;
}

@property (nonatomic, strong) UIView *rightTableViewHeadView;
@property (nonatomic, strong) UIView *leftTableViewHeadView;
@property (nonatomic, strong) UIView *m_buttomLine;
@property (nonatomic, strong) UIScrollView *m_rightScrollView;
@property (nonatomic, strong) NSMutableDictionary *moreThanOneRowCellHeightDic;
@property (nonatomic, strong) UIScrollView *leftSteadyHeadView;
@property (nonatomic, strong) UIScrollView *rightSteadyHeadView;
@property (nonatomic, assign) BOOL isHideTableHeader;
@property (nonatomic, strong) NSMutableArray *xRowArray;
@property (nonatomic, strong) NSMutableArray *colNameArray;
@property (nonatomic, strong) NSMutableArray *textFieldArray;

@end
//===============================================================================================================================================================================

@implementation DataGridComponent
@synthesize dataSource;
@synthesize contentWidth = _contentWidth;
@synthesize headerHeight;

- (id)initWithFrame:(CGRect)aRect data:(DataGridComponentDataSource*)aDataSource funcs:(WSFuncsBean *)funcs isAllProducts:(BOOL)isAllProducts {
    
    return [self initWithFrame:aRect data:aDataSource funcs:funcs isAllProducts:isAllProducts isDrawSerieLink:NO];
}

- (id)initWithFrame:(CGRect)aRect data:(DataGridComponentDataSource*)aDataSource {
    
    return [self initWithFrame:aRect data:aDataSource funcs:nil isAllProducts:NO isDrawSerieLink:NO];
}

- (id)initWithFrame:(CGRect)aRect data:(DataGridComponentDataSource*)aDataSource funcs:(WSFuncsBean *)funcs {
    
    return [self initWithFrame:aRect data:aDataSource funcs:funcs isAllProducts:NO isDrawSerieLink:NO];
}

- (id)initWithFrame:(CGRect)aRect data:(DataGridComponentDataSource *)aDataSource funcs:(WSFuncsBean *)funcs isAllProducts:(BOOL)isAllProducts isDrawSerieLink:(BOOL)isDrawSerieLink {
    
    self = [super initWithFrame:aRect];
    if (self != nil) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeValue) name:WSAcvtDataGridComponentDataSource_NOTIFY_ISVALUECHANGE object:nil];
        
        self.xRowArray = [NSMutableArray array];
        self.paramArray = [NSMutableArray array];
        self.colNameArray = [NSMutableArray array];
        self.checkBoxArray = [NSMutableArray arrayWithCapacity:5];
        self.widthesArray = [NSMutableArray arrayWithCapacity:5];
        self.currentFuncs = funcs;
        self.dataSource = aDataSource;
        _extraHeight = 0;
        
        BOOL morePro = NO;
        if ([aDataSource isKindOfClass:[WSAcvtDataGridComponentDataSource class]]) {
            WSAcvtDataGridComponentDataSource *acvtDataSource = (WSAcvtDataGridComponentDataSource *)dataSource;
            morePro = acvtDataSource.moreProductArray.count > 0;
        }
        
        NSString *needSelect = aDataSource.currentTableItem.opt.needSelect;
        if (needSelect != nil && needSelect.length > 0 && [needSelect isKindOfClass:[NSString class]]) {
            
            if ([needSelect isEqualToString:@"1"]) {
                self.brandSerieType = WSBrandType;
            }
            else if ([needSelect isEqualToString:@"2"]) {
                self.brandSerieType = WSAllType;
            }
            
            self.showSerieLinkHeadView = NO;
            if ((![needSelect isEqualToString:@"1"] || [aDataSource isKindOfClass:[WSAcvtDataGridComponentDataSource class]]) || isDrawSerieLink) {
                self.showSerieLinkHeadView = YES;
            }
        }
        
        if ((aDataSource.data && [aDataSource.data count] > 0) || self.showSerieLinkHeadView || morePro || [aDataSource.titles count] > 0) {

            self.clipsToBounds = YES;
            self.backgroundColor = [UIColor whiteColor];
            
            cellOriginHeight = DATAGRID_CELL_HEIGHT_DEFAULT;
            headerHeight = MAIN_CELL_HEIGHT;
            if (aDataSource.rowHeight > 0) {
                cellOriginHeight = aDataSource.rowHeight;
                headerHeight = aDataSource.rowHeight;
            }
            
            NSString *testText = @"测试";
            if (self.dataSource && [self.dataSource.titles count] > 0) {
                testText = [NSString stringWithFormat:@"%@" ,[self.dataSource.titles firstObject]];
            }
            CGSize textSize = [testText ws_sizeWithFont:kGridHeaderTitleFont constrainedToWidth:CGFLOAT_MAX lineBreakMode:NSLineBreakByCharWrapping];
            if (textSize.height * 2 > headerHeight) {
                headerHeight = textSize.height * 2;
            }
            _contentHeight = headerHeight + ([dataSource.data count] - 1) * cellOriginHeight + 10;
            
            for (int i = 1; i < [dataSource.columnWidth count]; i++) {
                
                NSString *strinWidth = [dataSource.columnWidth objectAtIndex:i];
                NSArray *widthArray = [self transformedWidthStirng:strinWidth];
                WSTableItem *tableItem = dataSource.currentTableItem;
                NSString *gone = [[tableItem.paramArray objectAtIndex:i - 1] gone];
                if ([gone isEqualToString:@"0"] || gone.length == 0 ) {
                    _contentWidth += [((NSNumber *)[widthArray firstObject]) floatValue] + UINIT_SPACE_WIDTH * 2;
                }
            }
            
            [self resetLeftCellWidthByFrame:aRect];

            if (self.showSerieLinkHeadView) {
                [self loadSerieLinkHeadViewWithFrame:aRect dataSource:aDataSource];
            }
       
            if ((self.currentFuncs.opt.needSelect && [self.currentFuncs.opt.needSelect length] > 0) ||
                [self.currentFuncs.opt.deleteButton isEqualToString:@"1"]) {
                leftCellWidth += 50;
            }
            
            [self initUITabWith:aRect isAllProducts:isAllProducts];
            [self resetColumWidth];
            [self initUITabSteadyHeadViewWith:aRect];
            [self saveAllViewsNormalFrames];
        }
        else {
            
            if (needSelect == nil || (needSelect && [needSelect isEqualToString:@""])) {
                [self addNoDataLabelWithFrame:CGRectMake(0, 0, self.bounds.size.width, 40)];
            }
        }
    }
    
    self.frame  = CGRectMake(self.frame.origin.x, self.frame.origin.y,self.size.width  , self.size.height);
    [self setCellHeightToDic];

    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    [self saveAllViewsNormalFrames];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSMutableDictionary *)cellHeightDic {
    
    if (!_cellHeightDic) {
        _cellHeightDic = [NSMutableDictionary dictionary];
    }
    return _cellHeightDic;
}

- (NSMutableDictionary *)moreThanOneRowCellHeightDic {
    
    if (!_moreThanOneRowCellHeightDic) {
        _moreThanOneRowCellHeightDic = [NSMutableDictionary dictionary];
    }
    return _moreThanOneRowCellHeightDic;
}

- (NSMutableArray *)textFieldArray {
    
    if (!_textFieldArray) {
        _textFieldArray = [NSMutableArray array];
    }
    return _textFieldArray;
}

- (UIButton *)createExpandButton {
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.bounds) - 39.) / 2., CGRectGetHeight(self.bounds) - 21., 39., 21.)];
    [button setImage:[UIImage imageForName:@"btn_listdown"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageForName:@"btn_listdown"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(expendView) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)addNoDataLabelWithFrame:(CGRect)frame {
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.contentMode = UIViewContentModeCenter;
    label.layer.masksToBounds = YES;
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:UI_Font];
    label.textColor = DETAIL_TEXT_COLOR;
    NSString *nodata = NSLocalizedString(@"acvt_type_empty_label", nil);
    label.text = nodata;
    [self addSubview:label];
}

- (void)resetColumWidth {
    
    BOOL isResetWidth = NO;
    if (dataSource.data.count < 1) {
        return;
    }
    
    UIView *view = [[dataSource.data objectAtIndex:0] firstObject];
    if ([view isKindOfClass:[UILabel class]] && self.isAllowEdit) {
        isResetWidth = YES;
    }
    else if ([view isKindOfClass:[WSGridImageHeaderView class]] && [self.dataSource.currentTableItem.opt.deleteButton isEqualToString:@"1"]) {
        isResetWidth = YES;
    }
    
    if (isResetWidth) {
        
        CGFloat xoffset = 50;
        CGFloat width = leftCellWidth - MAIN_CELL_PADDING * 2 - xoffset;
        [dataSource.columnWidth replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%f", width]];
    }
}

- (void)resetLeftCellWidthByFrame:(CGRect)aRect {
    
    leftCellWidth = [[dataSource.columnWidth objectAtIndex:0] floatValue] + 2*MAIN_CELL_PADDING;

    CGFloat contentOffset = (aRect.size.width - leftCellWidth) - _contentWidth;
    if (contentOffset >= 0) {

        CGFloat firstColumnTilteInitWidth = [[dataSource.columnWidth objectAtIndex:0] floatValue];
        if (leftCellWidth < firstColumnTilteInitWidth) {
            
            contentOffset = (aRect.size.width - firstColumnTilteInitWidth) - _contentWidth;
            if (contentOffset >= 0) {
                leftCellWidth = firstColumnTilteInitWidth;
            }
        }
    }
}

- (void)loadSerieLinkHeadViewWithFrame:(CGRect)aRect dataSource:(DataGridComponentDataSource *)dataSouce {
    
    CGRect serieFrame = CGRectMake(0, 0, aRect.size.width, 44);
    _serieLinkHeadView = [[WSSerieLinkHeadView alloc] initWithFrame:serieFrame];
    self.serieLinkHeadView.delegate = self;
    
    [self addSubview:self.serieLinkHeadView];
}

- (void)setCellHeightToDic {
    
    CGFloat tableHeight = 0;
    if (self.showSerieLinkHeadView) {
        tableHeight = self.serieLinkHeadView.height;
    }
    else {
        tableHeight = [self.dataSource resetCellHeightWithOriginHeight:MAIN_CELL_HEIGHT];
    }
    
    if ([dataSource.data count] == 0 && self.dataSource.needSelect) {
        tableHeight += MAIN_CELL_HEIGHT;
    }

    for (int row = 0; row < self.dataSource.data.count; row ++) {
        CGFloat cellHeight = [self setHeightForRowAtIndexPath:row];
        tableHeight += cellHeight;
    }

    CGRect frame = self.frame;
    self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, tableHeight);
}

- (CGFloat)setHeightForRowAtIndexPath:(NSInteger)row {
    
    NSMutableArray *rowViews = [self.dataSource.data objectAtIndex:row];
    NSString *prodName = [(UILabel *)[rowViews firstObject] text];
    NSString *prodLabelWidth = [dataSource.columnWidth firstObject];
    
    CGFloat width = [prodLabelWidth floatValue];
    CGFloat leftWidth = leftCellWidth - MAIN_CELL_PADDING * 2;
    width = width > leftWidth ? width : leftWidth;
    
    CGSize prodNameSize = [prodName ws_sizeWithFont:kLeftTitleFont constrainedToWidth:width lineBreakMode:NSLineBreakByCharWrapping];
    CGFloat cellHeight = cellOriginHeight;
    [self.moreThanOneRowCellHeightDic setObject:[NSNumber numberWithFloat:cellHeight] forKey:[NSNumber numberWithInteger:row]];
    
    cellHeight = [self.dataSource resetCellHeightWithOriginHeight:cellHeight];
    if (prodNameSize.height >= (cellHeight-Grid_View_Height_Y_Offset*2)) {
        cellHeight = prodNameSize.height + Grid_View_Height_Y_Offset*2;
    }
    
    [self.cellHeightDic setObject:[NSNumber numberWithFloat:cellHeight] forKey:[NSNumber numberWithInteger:row]];
    return cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return dataSource.data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat cellHeight = [self getCellHeightWithIndexPath:indexPath];
    if (cellHeight == 0) {
        
        [self setHeightForRowAtIndexPath:indexPath.row];
        cellHeight = [self getCellHeightWithIndexPath:indexPath];
    }
    return cellHeight;
}

- (CGFloat)getCellHeightWithIndexPath:(NSIndexPath *)indexPath {
    
    return [[self.cellHeightDic objectForKey:[NSNumber numberWithInteger:indexPath.row]] floatValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"dataGridComponent";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [cell.contentView removeAllSubviews];
    
    NSArray *rowData = [dataSource.data objectAtIndex:indexPath.row];
    WSTableItem *tableItem = dataSource.currentTableItem;
    float columnOffset = 0.0;
    float columnOffsetY = 0.0;
    UIView *view = [rowData firstObject];
    
    CGFloat realCellHeigh = [[self.moreThanOneRowCellHeightDic objectForKey:[NSNumber numberWithInteger:indexPath.row]] floatValue];
    CGFloat leftCellHeight = [[self.cellHeightDic objectForKey:[NSNumber numberWithInteger:indexPath.row]] floatValue];
    if (realCellHeigh == 0 || leftCellHeight == 0) {
        
        [self setHeightForRowAtIndexPath:indexPath.row];
        realCellHeigh = [[self.moreThanOneRowCellHeightDic objectForKey:[NSNumber numberWithInteger:indexPath.row]] floatValue];
        leftCellHeight = [self getCellHeightWithIndexPath:indexPath];
    }
    NSInteger rowCount = [self.dataSource getCellRowCount];
    if (leftCellHeight > realCellHeigh * rowCount) {
        realCellHeigh = leftCellHeight / rowCount;
    }
    
    if (tableView == self.rightTableView) {
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        int notHideColIndex = 1;
        for (int column = 1; column < rowData.count; column++) {
            
            WSFuncsBean_Param *param = [tableItem.paramArray objectAtIndex:column - 1];
            if (![param.gone isEqualToString:@"0"] && param.gone.length > 0) {
                continue;
            }
           
            WSGridWidget *gridWidget = [rowData objectAtIndex:column];
            UIView *view = nil;
            if ([gridWidget isKindOfClass:[WSGridWidget class]]) {
                view = [gridWidget getView];
            }
            else {
                view = (UIView *)gridWidget;
            }
            view.userInteractionEnabled = YES;
            if ([self.dataSource.currentTableItem.opt.jumpToInput isEqualToString:@"1"] && ![param.ispopup isEqualToString:@"N"]) {
                view.userInteractionEnabled = NO;
            }
            
            NSNumber *widthNumber = nil;
            if (column - 1 < [self.widthesArray count]) {
                widthNumber = (NSNumber *)[self.widthesArray objectAtIndex: column - 1];
            }
            float columnWidth  = [widthNumber floatValue];
            [view setFrame:CGRectMake(columnOffset + UINIT_SPACE_WIDTH, columnOffsetY, columnWidth - UINIT_SPACE_WIDTH * 2, realCellHeigh)];
            [cell.contentView addSubview:view];
            
            if ([view isKindOfClass:[UITextField class]]) {
                
                UITextField *textfield = (UITextField*)view;
                textfield.font = [UIFont fontForKey:@"WorkFlowSectionHeaderViewTitle"] ? [UIFont fontForKey:@"WorkFlowSectionHeaderViewTitle"] : CellTextFont;
                textfield.textAlignment = NSTextAlignmentCenter;
                textfield.backgroundColor = [UIColor clearColor];
                textfield.frame = CGRectMake(UINIT_SPACE_WIDTH, 0, columnWidth - UINIT_SPACE_WIDTH * 2, 30);
                textfield.centerX = columnOffset + columnWidth / 2;
                
                if (column == rowData.count - 1 && [rowData count] > 2) {
                    if (tableView.width - textfield.left - columnWidth > 10) {
                        columnWidth = tableView.width - textfield.left - 10;
                    }
                }

                textfield.centerY = realCellHeigh / 2 + columnOffsetY;
                
                if (self.isUnredo) {
                    textfield.enabled = NO;
                }
            }
            else if ([view isKindOfClass:[WSSelectListView class]]) {
                
                WSSelectListView *selectView = (WSSelectListView *)view;
                selectView.parentViewController = self.parentViewController;
                selectView.frame = CGRectMake(UINIT_SPACE_WIDTH, 0, columnWidth - UINIT_SPACE_WIDTH * 2, 40);
                selectView.centerX = columnOffset + columnWidth / 2;
                selectView.centerY = realCellHeigh / 2 + columnOffsetY;
                [selectView reloadData];
                
                if (self.isUnredo) {
                    selectView.userInteractionEnabled = NO;
                }
            }
            else if ([view isKindOfClass:[WSDropListView class]]) {
                
                WSDropListView *selectView = (WSDropListView *)view;
                [selectView setFont:CellTextFont];
                selectView.frame = CGRectMake(UINIT_SPACE_WIDTH, 0, columnWidth - UINIT_SPACE_WIDTH * 2, 40);
                selectView.centerX = columnOffset+columnWidth/2;
                selectView.centerY = realCellHeigh / 2 + columnOffsetY;
                [selectView flushTable];
                
                if (self.isUnredo) {
                    selectView.userInteractionEnabled = NO;
                }
            }
            else if ([view isKindOfClass:[UIButton class]]) {
                
                if (self.isUnredo && view != self.expandGridViewButton) {
                    view.userInteractionEnabled = NO;
                }
            }
            else if ([view isKindOfClass:[WSDatePickerLabel class]]) {
                
                CGRect viewFrame = view.frame;
                CGFloat viewTopMargin = 2.0;
                view.frame = CGRectMake(viewFrame.origin.x,  viewTopMargin , viewFrame.size.width, viewFrame.size.height - 2 * viewTopMargin);
                
                for (UIView *subView in view.subviews) {
                    
                    if ([subView isKindOfClass:[UIImageView class]]) {
                        CGSize subViewSize = subView.frame.size;
                        CGFloat sub_y_offset = -2.0f;
                        subView.frame = CGRectMake((viewFrame.size.width - subViewSize.width)/2, sub_y_offset + (viewFrame.size.height - subViewSize.height) / 2, subViewSize.width, subViewSize.height);
                        break;
                    }
                }
            }
            
            if ([self.xRowArray containsObject:[NSNumber numberWithInteger:indexPath.row]]) {
                
                NSString *colName = _colNameArray[[self.xRowArray indexOfObject:[NSNumber numberWithInteger:indexPath.row]]];
                NSString *params = _paramArray[[self.xRowArray indexOfObject:[NSNumber numberWithInteger:indexPath.row]]];
                NSArray *colorArray = [params componentsSeparatedByString:@"[#]"];
                NSArray *colNameArray = [colName componentsSeparatedByString:@","];
                WSFuncsBean_Param *param = tableItem.paramArray[column - 1];
                
                if ([colName rangeOfString:param.col].location != NSNotFound) {
            
                    NSInteger index = [colNameArray indexOfObject:param.col];
                    NSString *colorStr = colorArray[index];
                    colorStr = [NSString stringWithFormat:@"#%@",[colorStr substringFromIndex:colorStr.length-6]];
                    view.backgroundColor = RGB_COLOR(colorStr);
                }
            }

            UIView *line = [self getLine:CGRectMake(columnOffset, columnOffsetY + ((realCellHeigh - SEPARATELINE_HEIGHT ) / 2), MAIN_CELL_SEPERATOR_HEIGHT, SEPARATELINE_HEIGHT)];
            [cell.contentView addSubview:line];

            CGPoint newOffset = [self getNewColumnOffsetWithOldOffset:CGPointMake(columnOffset, columnOffsetY) andColumnWidth:columnWidth andColumnHeight:realCellHeigh andIndex:notHideColIndex];
            columnOffset = newOffset.x;
            columnOffsetY = newOffset.y;

            if (column == [rowData count] - 1) {

            }
            else {
                
                UIColor *headerBorderColor = [UIColor colorForKey:@"GridHeaderBorderColor"];
                if (!headerBorderColor) {
                    headerBorderColor = [UIColor colorWithRed:220.0 / 255.0 green:220.0 / 255.0 blue:220.0 / 255.0 alpha:1.0];
                }
                
                if (columnOffset == 0 && columnOffsetY > 0) {
                    
                    UIImageView *rightTableViewDashLineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, columnOffsetY-1, cell.width, 1)];
                    [rightTableViewDashLineView setImage:[UIImage imageNamed:@"imaginary-line"]];
                    [cell.contentView addSubview:rightTableViewDashLineView];
                    rightTableViewDashLineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                    WSAcvtDataGridComponentDataSource *acvtDataSource = [self getAcvtDataSource];
                    
                    if ([[acvtDataSource.currentQst getDisplayMode] isEqualToString:@"iconBtn"]) {
                        rightTableViewDashLineView.hidden = YES;
                    }
                }
            }
            
            notHideColIndex++;
        }
    }
    else {
        
        if (self.isAllowEdit) {
            
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            if (!cell.multipleSelectionBackgroundView) {
                
                cell.multipleSelectionBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
                if (indexPath.row % 2 != 0) {
                    cell.multipleSelectionBackgroundView.backgroundColor = HColorFromHex(0xfafafa);
                }
                else {
                    cell.multipleSelectionBackgroundView.backgroundColor = [UIColor whiteColor];
                }
            }
        }
        else {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        float columnWidth = 0.;
        NSString *strinWidth = [dataSource.columnWidth firstObject];
        NSArray *widthArray = [self transformedWidthStirng:strinWidth];
        for (NSNumber *number in widthArray) {
            columnWidth += [number floatValue];
        }
        
        [view setFrame:CGRectMake(columnOffset, 0 , columnWidth , leftCellHeight)];
        [cell.contentView addSubview:view];
        
        if ([view isKindOfClass:[UILabel class]]) {
            
            UILabel *label = (UILabel *)view;
            if ([label isKindOfClass:[WCURLUILabel class]]) {
                
                WCURLUILabel *tempLabel = (WCURLUILabel *)label;
                tempLabel.container = self;
                tempLabel.longPressTag = indexPath.row;
            }
            
            CGFloat width = leftCellWidth - MAIN_CELL_PADDING * 2;
            label.frame = CGRectMake(MAIN_CELL_PADDING, 0, width, leftCellHeight);
            label.font = kLeftTitleFont;
            label.textAlignment = NSTextAlignmentLeft;
            label.numberOfLines  = 0;
            label.lineBreakMode = NSLineBreakByCharWrapping;
            UIColor *gridLeftTitleColor = [UIColor colorForKey:@"GridLeftTitleColor"];
            gridLeftTitleColor = gridLeftTitleColor ? : GRID_MAIN_TEXT_COLOR;
            UIColor *gridLeftTitleReadonlyColor = [UIColor colorForKey:@"GridLeftTitleReadonlyColor"];
            gridLeftTitleReadonlyColor = gridLeftTitleReadonlyColor ? : GRID_MAIN_TEXT_DISABLE_COLOR;
            
            NSString *textContent = label.text;
            BOOL isResetTitleColor = NO;
            NSRange range = [textContent rangeOfString:@"*" options:NSBackwardsSearch];
            if (textContent && range.location != NSNotFound && range.location == ([textContent length] - 1)) {
                
                if ([self.dataSource isKindOfClass:[WSAcvtDataGridComponentDataSource class]]) {
                    
                    WSAcvtDataGridComponentDataSource *acvtDataGridComponentDataSource = (WSAcvtDataGridComponentDataSource *)self.dataSource;
                    id <I_W_OptionDataItem> data = acvtDataGridComponentDataSource.dataSource[indexPath.row];
                    if ([data respondsToSelector:@selector(isDataItemRequired)]) {
                        
                        BOOL isRequired = [data isDataItemRequired];
                        if (isRequired) {
                            
                            NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:textContent];
                            [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(range.location, 1)];
                            [string addAttribute:NSForegroundColorAttributeName value:gridLeftTitleColor range:NSMakeRange(0, range.location)];
                            label.attributedText = string;
                        
                            isResetTitleColor = YES;
                        }
                    }
                }
            }
            
            if ([self.dataSource isKindOfClass:[WSAcvtDataGridComponentDataSource class]]) {
                
                WSAcvtDataGridComponentDataSource *acvtDataGridComponentDataSource = (WSAcvtDataGridComponentDataSource *)self.dataSource;
                if ([acvtDataGridComponentDataSource.currentQst.getLuaScript rangeOfString:@"setItemTitleColor"].location != NSNotFound) {
                    isResetTitleColor = YES;
                }
            }
        
            if (!isResetTitleColor){
                if ([self.superview isKindOfClass:[WSAcvtDataGridViewPanel class]]) {
                    
                    WSAcvtDataGridViewPanel *acvtDataGridViewPanel = (WSAcvtDataGridViewPanel *)self.superview;
                    if ([[acvtDataGridViewPanel getReadonly] boolValue]) {
                        label.textColor = gridLeftTitleReadonlyColor;
                    }
                    else {
                        label.textColor = gridLeftTitleColor;
                    }
                }
                else {
                    label.textColor = gridLeftTitleColor;
                }
            }
        }
        else if([view isKindOfClass:[WSGridImageHeaderView class]]) {
            
            WSGridImageHeaderView *headerView = (WSGridImageHeaderView *)view;
            CGFloat width = leftCellWidth - MAIN_CELL_PADDING * 2;

            headerView.textLabel.font = CellTextFont;
            headerView.frame = CGRectMake(MAIN_CELL_PADDING, 0, width, leftCellHeight);
            headerView.textLabel.textAlignment = NSTextAlignmentLeft;
            headerView.textLabel.numberOfLines  = 0;
            headerView.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
        }
    }

    if (indexPath.row % 2 != 0) {
        cell.contentView.backgroundColor = HColorFromHex(0xfafafa);
    }
    else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }

    if (tableView == self.rightTableView) {
        [self getTextFieldArrayMethodFromTableView:tableView andTableViewCell:cell];
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (tableView == self.rightTableView) {
        return self.rightTableViewHeadView;
    }
    else {
        return self.leftTableViewHeadView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (_isHideTableHeader) {
        return 0.0;
    }
    else {
        return [self.dataSource resetCellHeightWithOriginHeight:headerHeight];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.leftTableView && self.isSelecting && self.isAllowEdit) {
        
        [self.mutableSelectionSet addObject:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
    }
    else {
        
        if ([self.dataSource.currentTableItem.opt.jumpToInput isEqualToString:@"1"]) {
            if ([self.delegate respondsToSelector:@selector(dataGridComponent:pushIndexPath:)]) {
                [self.delegate dataGridComponent:self pushIndexPath:indexPath];
            }
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (tableView == self.leftTableView && self.isSelecting && self.isAllowEdit) {
        [self.mutableSelectionSet removeObject:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (scrollView == self.m_rightScrollView) {
        [self setSuperScrollViewEnableDragging:scrollView isEnable:YES];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if (scrollView == self.m_rightScrollView) {
        [self setSuperScrollViewEnableDragging:scrollView isEnable:NO];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView == self.rightTableView) {
        
        CGFloat offsetY = self.rightTableView.contentOffset.y;
        CGPoint timeOffsetY = self.leftTableView.contentOffset;
        timeOffsetY.y = offsetY;
        self.leftTableView.contentOffset=timeOffsetY;
        if (offsetY == 0) {
            self.leftTableView.contentOffset=CGPointZero;
        }
    }
    else if (scrollView == self.leftTableView) {
        
        CGFloat offsetY = self.leftTableView.contentOffset.y;
        CGPoint timeOffsetY = self.rightTableView.contentOffset;
        timeOffsetY.y = offsetY;
        self.rightTableView.contentOffset = timeOffsetY;
        if (offsetY == 0) {
            self.rightTableView.contentOffset=CGPointZero;
        }
    }
    else if (scrollView == self.m_rightScrollView) {
        
        CGFloat offsetX = self.m_rightScrollView.contentOffset.x;
        CGPoint timeOffsetX = self.rightSteadyHeadView.contentOffset;
        timeOffsetX.x = offsetX;
        self.rightSteadyHeadView.contentOffset = timeOffsetX;
        if (offsetX == 0) {
            self.rightSteadyHeadView.contentOffset=CGPointZero;
        }
    }
}

- (void)setSuperScrollViewEnableDragging:(UIScrollView *)scrollView isEnable:(BOOL)isEnable {
    
    BOOL isSuccess = YES;
    UIView *tempScrollView = scrollView;
    while (isSuccess) {
        
        if ([tempScrollView.superview isKindOfClass:[HYPageView class]]) {
            
            HYPageView * superScrollView = (HYPageView *)tempScrollView.superview;
            [superScrollView setScrollViewScrollEnabled:isEnable];
            isSuccess = NO;
        }
        else {
            
            tempScrollView = tempScrollView.superview;
            if (!tempScrollView) {
                isSuccess = NO;
            }
        }
    }
}

- (UIView *)getLine:(CGRect)rect {
    
    UIView *vLine = [[UIView alloc] initWithFrame:rect];
    UIColor *gridSeparteLineColor = [UIColor colorForKey:@"GridSeparteLineColor"];
    if (!gridSeparteLineColor) {
        gridSeparteLineColor = [UIColor colorWithRed:0.0 / 255.0 green:0.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
    }
    vLine.backgroundColor = gridSeparteLineColor;
    
    return vLine;
}

- (BOOL)isValueChange {
    
    if (_isValueChange) {
        return _isValueChange;
    }
    
    for (NSArray *rowData in self.dataSource.data) {
        for (WSGridWidget *gridWidget in rowData) {
            
            UIView *view = nil;
            if ([gridWidget isKindOfClass:[WSGridWidget class]]) {
                view = [gridWidget getView];
            }
            else {
                view = (UIView *)gridWidget;
            }
            
            if ([view respondsToSelector:@selector(isValueChange)]) {
                if ([view performSelector:@selector(isValueChange)]) {
                    _isValueChange = YES;
                    return _isValueChange;
                }
            }
        }
    }
    
    return NO;
}

- (void)reDrawGridViewWithHeight:(CGFloat) newHeight {
    
    [self changeViewsFrameWithHeight:newHeight];
    [self saveAllViewsNormalFrames];
}

- (void)changeViewsFrameWithHeight:(CGFloat) newHeight {
    
    CGRect frame = self.frame;
    frame.size.height = newHeight;
    self.frame = frame;

    CGFloat tableHeight = newHeight;
    if (self.dataSource.needSelect) {
        tableHeight -= self.serieLinkHeadView.height;
    }
    
    CGRect leftFrame = self.leftTableView.frame;
    leftFrame.size.height = tableHeight;
    self.leftTableView.frame = leftFrame;
    
    CGRect rightScrollView = self.m_rightScrollView.frame;
    rightScrollView.size.height = tableHeight;
    self.m_rightScrollView.frame = rightScrollView;
    
    CGRect rightFrame = self.rightTableView.frame;
    rightFrame.size.height = tableHeight;
    self.rightTableView.frame = rightFrame;
    
    CGRect bLineFrame = self.m_buttomLine.frame;
    bLineFrame.origin.y = newHeight - 1;
    self.m_buttomLine.frame = bLineFrame;
}

- (void)setFrame:(CGRect)frame {
    
    [super setFrame:frame];
    
    if (!notResetSelfFrame) {
        
        CGRect frameTemp = selfFrameBeforeRedraw;
        frameTemp.origin.y = self.frame.origin.y;
        selfFrameBeforeRedraw =  frameTemp;
    }
}

- (void)saveAllViewsNormalFrames {
    
    selfFrameBeforeRedraw = self.frame;
    leftFrameBeforeRedraw = self.leftTableView.frame;
    scrollFrameBeforeRedraw = self.m_rightScrollView.frame;
    rightFrameBeforeRedraw = self.rightTableView.frame;
    bLineFrameBeforeRedraw = self.m_buttomLine.frame;
    originY = self.frame.origin.y;
}

- (void)redrawGridViewWithHeightForLayout:(CGFloat) newHeight {
    
    [self changeViewsFrameWithHeight:newHeight];
    
    if (self.expandGridViewButton) {
        
        [self.expandGridViewButton setImage:[UIImage imageForName:@"btn_listdown"] forState:UIControlStateNormal];
        [self.expandGridViewButton setImage:[UIImage imageForName:@"btn_listdown"] forState:UIControlStateHighlighted];
        CGRect frame = self.expandGridViewButton.frame;
        frame.origin.y = CGRectGetHeight(self.bounds) - 21.;
        self.expandGridViewButton.frame = frame;
    }
    
    [self.superview layoutSubviews];
}

- (void)redrawGridViewWithHeightForKeyboardShow:(CGFloat) newHeight {
    
    notResetSelfFrame = YES;
    [self changeViewsFrameWithHeight:newHeight];
    notResetSelfFrame = NO;
}

- (void)redrawGridViewWithHeightForKeyboardHide {
    
    self.frame = selfFrameBeforeRedraw;
    
    self.leftTableView.frame = leftFrameBeforeRedraw;
    self.m_rightScrollView.frame = scrollFrameBeforeRedraw;
    self.rightTableView.frame = rightFrameBeforeRedraw;
    self.m_buttomLine.frame = bLineFrameBeforeRedraw;
    
    [self.superview layoutSubviews];
}

- (void)reDrawGridViewWithY:(CGFloat)y {
    
    notResetSelfFrame = YES;
    
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
    notResetSelfFrame = NO;
}

- (void)setBackgroundColorWithRowId:(NSString *)rowId col:(NSString *)colName value:(NSString *)params {
    
    [self.paramArray addObject:params];
    [self.colNameArray addObject:colName];
    
    if ([self.dataSource isKindOfClass:[WSAcvtDataGridComponentDataSource class]]) {
        
        WSAcvtDataGridComponentDataSource *acvtDataGridComponentDataSource = (WSAcvtDataGridComponentDataSource *)self.dataSource;
        for (int i = 0; i < acvtDataGridComponentDataSource.dataSource.count; i++) {
            
            id<I_W_OptionDataItem> bean = acvtDataGridComponentDataSource.dataSource[i];
            if ([rowId isEqualToString:[bean getDataItemID]]) {
                [self.xRowArray addObject:[NSNumber numberWithInt:i]];
            }
        }
    }
}

- (void)changeValue {
    
    self.isValueChange = YES;
}

- (void)setIsAllowedExtend:(BOOL)isAllowedExtend {
    
    _isAllowedExtend = isAllowedExtend;
    
    if (_isAllowedExtend) {
        
        BOOL isAcvtGrid = NO;
        if ([self.dataSource isKindOfClass:[WSAcvtDataGridComponentDataSource class]]) {
            isAcvtGrid = YES;
        }
        
        if (!self.expandGridViewButton && (self.dataSource && ([self.dataSource.data count] > 0 && !isAcvtGrid))) {
            self.expandGridViewButton = [self createExpandButton];
            [self addSubview:self.expandGridViewButton];
        }
    }
}

- (void)expendView {
    
    if (!self.isAllowedExtend) {
        return;
    }
    
    if (isStartAnim) {
        return;
    }
    
    isStartAnim = YES;
    if (self.isExtendedView) {
        
        self.isExtendedView = NO;
        [UIView animateWithDuration: 0.2 animations:^{
            [self redrawGridViewWithHeightForLayout:[self getHeaderHeight]];
        }
                         completion:^(BOOL finished) {
            
            isStartAnim = NO;
            [self refreshSuperView];
        }];
    }
    else {
        
        self.isExtendedView = YES;
        [self refreshSuperView];
        
        [UIView animateWithDuration: 0.2 animations:^{
            [self redrawGridViewWithHeightForKeyboardHide];
        }
                         completion:^(BOOL finished) {
                         
            isStartAnim = NO;
            if (self.expandGridViewButton) {
            
                [self.expandGridViewButton setImage:[UIImage imageForName:@"btn_listup"] forState:UIControlStateNormal];
                [self.expandGridViewButton setImage:[UIImage imageForName:@"btn_listup"] forState:UIControlStateHighlighted];
                CGRect frame = self.expandGridViewButton.frame;
                frame.origin.y = CGRectGetHeight(self.bounds) - 21.;
                self.expandGridViewButton.frame = frame;
            }
        }];
    }
}

- (void)refreshSuperView {
    
    UIView *superView = self.superview;
    if (superView) {
        [superView.superview setNeedsLayout];
    }
}

- (CGFloat)attachedViewsHeight {

    return 36.f;
}

- (CGFloat)getOffset {
    
    if (!CGRectIsEmpty(selfFrameBeforeRedraw)) {
        return CGRectGetHeight(selfFrameBeforeRedraw) - headerHeight;
    }
    return 0.f;
}

- (CGFloat)getHeaderHeight {
    
    CGFloat brandViewHeight = 0.0;
    if (dataSource.needSelect) {
        brandViewHeight = 44.0;
    }
    CGFloat originHeaderHeight = [self.dataSource resetCellHeightWithOriginHeight:headerHeight];
    if (_isHideTableHeader) {
        originHeaderHeight = 0.0;
    }
    return originHeaderHeight + brandViewHeight;
}

- (void)serieLinkHeadView:(WSSerieLinkHeadView *)serieLinkHeadView superViewWillDisplay:(BOOL)dispaly {
    
    if (dispaly) {
        
        [self endEditing:YES];
        
        NSString *brandFilter = self.dataSource.currentTableItem.filter;
        CGRect rect = [[UIScreen mainScreen] bounds];
        if (self.popupView == nil) {
            
            NSString *dataSourceMd5 = nil;
            NSString *storeId = nil;
            NSArray *prods = nil;
            
            if ([self.dataSource isKindOfClass:[WSAcvtDataGridComponentDataSource class]]) {

                WSAcvtDataGridComponentDataSource *acvtDataGridComponentDataSource = (WSAcvtDataGridComponentDataSource *)self.dataSource;
                prods = acvtDataGridComponentDataSource.dataSource;
                dataSourceMd5 = [acvtDataGridComponentDataSource getGridMd5];
                storeId = [[acvtDataGridComponentDataSource currentStore] Id];
                NSString *drId = [[acvtDataGridComponentDataSource currentStore] drId];
                if ([drId length] > 0) {
                    storeId = drId;
                }
            }
            
            if (self.brandSerieType == WSAllType) {
                _popupView = [[WSGridLinkPopupView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height) brandFilter:brandFilter md5:dataSourceMd5 prods:prods
                                                                 params:self.dataSource.currentTableItem.paramArray appendprop:self.currentFuncs.opt.appendprop];
            }
            else if (self.brandSerieType == WSBrandType) {
                _popupView = [[WSGridLinkPopupView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height) storeId:storeId params:self.dataSource.currentTableItem.paramArray
                                                            brandFilter:brandFilter md5:dataSourceMd5 brandSerieType:self.brandSerieType prods:prods appendprop:self.currentFuncs.opt.appendprop];
            }
        
            self.popupView.delegate = self;
            [self.window addSubview:self.popupView];
        }
        else if (self.popupView) {
            
            self.popupView.hidden = NO;
        }
        
        [self addProdsToGridViewAndShow];
    }
}

- (void)addProdToCache {
    
    WSAcvtDataGridComponentDataSource *acvtDataGridComponentDataSource = (WSAcvtDataGridComponentDataSource *)self.dataSource;
    NSMutableArray *prodsArray = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < [acvtDataGridComponentDataSource.dataSource count]; i++) {
        
        NSDictionary *proDictionary = [WSAcvtDataGridComponentService getProdDictionaryWithDataSource:acvtDataGridComponentDataSource atIndex:i];
        if (proDictionary) {
            [prodsArray addObject:proDictionary];
        }
    }
    
    for (NSDictionary *prodDic in prodsArray) {
        for (WSFuncsBean_Param *param in acvtDataGridComponentDataSource.currentTableItem.paramArray) {
            
            if ([[prodDic objectForKey:param.col] length] > 0) {
                NSString *cacheKey = [NSString stringWithFormat:@"%@_%@",[prodDic objectForKey:@"PROD_ID"], param.col];
                
                [acvtDataGridComponentDataSource.prod_cacheDataMDictionary setObject:[NSString stringNotNilWithValue:[prodDic objectForKey:param.col]] forKey:cacheKey];
                if ([acvtDataGridComponentDataSource.prod_cacheDataDictKeysArray indexOfObject:cacheKey] == NSNotFound) {
                    [acvtDataGridComponentDataSource.prod_cacheDataDictKeysArray addObject:cacheKey];
                }
            }
        }
    }
}

- (void)addProdsToGridViewAndShow {
    
    [self.dataSource.addedEditingProds removeAllObjects];
    
    WSAcvtDataGridComponentDataSource *acvtDataGridComponentDataSource = (WSAcvtDataGridComponentDataSource *)self.dataSource;
    [acvtDataGridComponentDataSource.addedEditingProds removeAllObjects];
    
    [self addProdToCache];
    
    WSBaseProductDBService *baseProductDBSerice = [[WSBaseProductDBService alloc] init];
    NSMutableArray *prodIdsMArray = [[NSMutableArray alloc] init];
    
    if ([acvtDataGridComponentDataSource isKindOfClass:[WSAcvtDataGridComponentDataSource class]] && acvtDataGridComponentDataSource.prod_cacheDataDictKeysArray.count > 0) {
        
        for (NSString *keyStr in acvtDataGridComponentDataSource.prod_cacheDataDictKeysArray) {
            NSArray *keyStrSegmentsArray = [keyStr componentsSeparatedByString:@"_"];
            [prodIdsMArray addObject:[keyStrSegmentsArray firstObject]];
        }
    }
    
    NSArray *editedProdsInCache = [baseProductDBSerice queryProductByIds:prodIdsMArray appendprop:self.currentFuncs.opt.appendprop];
    acvtDataGridComponentDataSource.addedEditingProds = [NSMutableArray arrayWithArray:editedProdsInCache];
    
    NSMutableArray *tempDataSource = [[NSMutableArray alloc] init];
    for (WSProdBean *prodBean in self.dataSource.addedEditingProds) {
        
        BOOL isHasProd = NO;
        for (WSProdBean *tempProdBean in tempDataSource) {
            if ([[prodBean Id] isEqualToString:[tempProdBean Id]]) {
                isHasProd = YES;
                break;
            }
        }
        
        if (!isHasProd) {
            [tempDataSource addObject:prodBean];
        }
    }
    self.dataSource.addedEditingProds = tempDataSource;
    
    [self.popupView redisplayWith:self.dataSource.addedEditingProds];
}

- (void)gridLinkPopupView:(WSGridLinkPopupView *)popupView didSelecteBrandRowAtIndex:(NSInteger)brandIndex serieIndex:(NSInteger)serieIndex prods:(NSArray *)prods andBrandSerieName:(NSString *)brandSerieName {
    
    if (popupView && self.dataSource) {
        
        self.popupView.hidden = YES;
        [self.dataSource reloadDataSourceWith:prods changeSerieLinkHeadViewTitleWith:brandSerieName];
    }
}

- (void)gridLinkPopupView:(WSGridLinkPopupView *)popupView didSelectedAllEditedProds:(BOOL)show andBrandSerieName:(NSString *)brandSerieName {
    
    self.popupView.hidden = YES;
    NSMutableArray *prodArray = [NSMutableArray array];
    if ([self.dataSource.addedEditingProds count] > 0 || [popupView.uploadedEditedProds count] > 0) {
        
        if ([self.dataSource.addedEditingProds count] > 0) {
            [prodArray addObjectsFromArray:self.dataSource.addedEditingProds];
        }
        else {
            [prodArray addObjectsFromArray:popupView.uploadedEditedProds];
        }
    }
    [self.dataSource reloadDataSourceWith:prodArray changeSerieLinkHeadViewTitleWith:brandSerieName];
}

- (void)gridLinkPopupViewBackToAllSelectedProdsView {
    
    if (self.popupView) {
        
        [self addProdsToGridViewAndShow];
        [self.popupView setSelectedBrandIndex:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.popupView.selectedBrandIndex inSection:0];
        [self.popupView scrollToRowSelectIndexPath:indexPath];
    }
}

- (BOOL)isShowOrHideSelection {
    
    if (!self.isSelecting) {
        
        self.isSelecting = YES;
        [self allowsMultipleSelection:YES];
        [self resetTableFrameByIsSelection:self.isSelecting];
   
        return YES;
    }
    else {
        
        if ([self.mutableSelectionSet count] == 0) {
            
            self.isSelecting = NO;
            [self allowsMultipleSelection:NO];
            [self resetTableFrameByIsSelection:self.isSelecting];

            return YES;
        }
    }
    
    return NO;
}

- (void)resetTableFrameByIsSelection:(BOOL)isSelection {
    
    CGFloat offset;
    if (self.isSelecting) {
        offset = EXTRA_WIDTH;
    }
    else {
        offset = -EXTRA_WIDTH;
    }
    
    CGRect leftFrame = self.leftTableView.frame;
    leftFrame.size.width += offset;
    [self.leftTableView setFrame:leftFrame];
    
    CGRect rightScrollFrame = self.m_rightScrollView.frame;
    rightScrollFrame.origin.x += offset;
    [self.m_rightScrollView setFrame:rightScrollFrame];
    
    CGRect leftSteadyFrame = self.leftSteadyHeadView.frame;
    leftSteadyFrame.size.width += offset;
    [self.leftSteadyHeadView setFrame:leftSteadyFrame];
    
    CGRect rightSteadyFrame = self.rightSteadyHeadView.frame;
    rightSteadyFrame.origin.x += offset;
    [self.rightSteadyHeadView setFrame:rightSteadyFrame];
}

- (void)seletedItems:(NSIndexSet *)selectedItems {
    
}

- (void)setHideTableHeader:(BOOL)isHide {
    
    _isHideTableHeader = isHide;
    
    self.leftTableViewHeadView.hidden = isHide;
    self.rightTableViewHeadView.hidden = isHide;
    self.leftSteadyHeadView.hidden = isHide;
    self.rightSteadyHeadView.hidden = isHide;
    
    [self resetTableHeaderViewFrame];
    
    [self.leftTableView reloadData];
    [self.rightTableView reloadData];
}

- (void)resetTableHeaderViewFrame {
    
    CGFloat tabHeaderHeight = [self.dataSource resetCellHeightWithOriginHeight:headerHeight];
    if (!_isHideTableHeader) {
        
        if (tabHeaderHeight > _steadyTableHeadView.frame.size.height) {
            tabHeaderHeight = -[self.dataSource resetCellHeightWithOriginHeight:headerHeight];
        }
        else{
            tabHeaderHeight = 0.0;
        }
    }
    
    [self reDrawGridViewWithHeight:(self.height - tabHeaderHeight)];
    
    CGRect steadyTableHeadViewFrame = _steadyTableHeadView.frame;
    steadyTableHeadViewFrame.size.height = steadyTableHeadViewFrame.size.height - tabHeaderHeight;
    _steadyTableHeadView.frame = steadyTableHeadViewFrame;
    
    CGRect steadyTableHeadBgViewFrame = _steadyTableHeadView.superview.frame;
    steadyTableHeadBgViewFrame.size.height = steadyTableHeadBgViewFrame.size.height - tabHeaderHeight;
    _steadyTableHeadView.superview.frame = steadyTableHeadBgViewFrame;
}

- (void)longPressDeletePods:(NSInteger)index {
    
    if (index >= 0) {
        
        if (!self.mutableSelectionSet) {
            self.mutableSelectionSet = [NSMutableSet setWithCapacity:1];
        }
        
        [self.mutableSelectionSet removeAllObjects];
        [self.mutableSelectionSet addObject:[NSString stringWithFormat:@"%ld", (long)index]];
        
        if ([self.delegate respondsToSelector:@selector(longPressDeleteCallback)]) {
            [((WSWidget *)self.delegate) longPressDeleteCallback];
        }
    }
}

- (UIColor *)getTableHeaderColor {
    
    UIColor *titleBgColor = [UIColor colorForKey:@"GridHeaderBackgroundColor"];
    if (!titleBgColor) {
        titleBgColor = [UIColor colorWithRed:(255.0 / 255.0) green:(255.0 / 255.0) blue:(255.0 / 255.0) alpha:1.0f];
    }
    return titleBgColor;
}

- (UIColor *)getTableHeaderBorderColor {
    
    UIColor *headerBorderColor = [UIColor colorForKey:@"GridHeaderBorderColor"];
    if (!headerBorderColor) {
        headerBorderColor = DETAIL_SEPERATE_LINE_COLOR;
    }
    return headerBorderColor;
}

- (NSArray *)transformedWidthStirng:(NSString *)widthString {
    
    NSMutableArray *widthArray = [NSMutableArray arrayWithCapacity:2];
    NSArray *widthItems = [widthString componentsSeparatedByString:@"_"];
    for (NSString *widthTemp in widthItems) {
        [widthArray addObject:[NSNumber numberWithFloat:[widthTemp floatValue]]];
    }
    return widthArray;
}

- (CGPoint)getNewColumnOffsetWithOldOffset:(CGPoint)offset andColumnWidth:(float)columnWidth andColumnHeight:(float)columnHeight andIndex:(int)index {
    
    float columnOffsetX = offset.x;
    float columnOffsetY = offset.y;
    if (self.dataSource.rightTableShowType == WSDataGridComponentRightTableColumnMaxShowType) {
        if (self.dataSource.rightTableShowColOrRowMaxValue) {
            
            int rowCnt = index / self.dataSource.rightTableShowColOrRowMaxValue;
            columnOffsetY = rowCnt * columnHeight;
            if (index % self.dataSource.rightTableShowColOrRowMaxValue == 0) {
                columnOffsetX = 0.0;
            }
            else {
                columnOffsetX += columnWidth;
            }
        }
    }
    else if (self.dataSource.rightTableShowType != WSDataGridComponentRightTableRowMaxShowType || self.dataSource.rightTableShowType != WSDataGridComponentRightTableAutoresizingMaskShowType) {
        columnOffsetX += columnWidth;
    }
    
    return CGPointMake(columnOffsetX, columnOffsetY);
}

- (CGFloat)resetCellWidthWithOriginWidth:(CGFloat)width {
    
    if (self.dataSource.rightTableShowType == WSDataGridComponentRightTableColumnMaxShowType) {
        
        NSArray *rowData = [dataSource.data firstObject];
        float cellWidth = 0.0f;
        if (self.dataSource.rightTableShowColOrRowMaxValue) {
            
            for (int column = 1; column < self.dataSource.rightTableShowColOrRowMaxValue + 1; column++) {
                
                NSNumber *widthNumber = nil;
                if (column - 1 < [self.widthesArray count]) {
                    widthNumber = (NSNumber *)[self.widthesArray objectAtIndex:column - 1];
                }
                float columnWidth = [widthNumber floatValue];
                cellWidth += columnWidth;
            }
            
            NSInteger contrastA = (rowData.count - 1 - self.dataSource.rightTableShowColOrRowMaxValue);
            NSInteger secRowDataCnt = contrastA > self.dataSource.rightTableShowColOrRowMaxValue ? self.dataSource.rightTableShowColOrRowMaxValue : contrastA;
            float secRowCellWidth = 0.0f;
            for (int column = self.dataSource.rightTableShowColOrRowMaxValue + 1; column < self.dataSource.rightTableShowColOrRowMaxValue + secRowDataCnt; column++) {
                
                NSNumber *widthNumber = nil;
                if (column - 1 < [self.widthesArray count]) {
                    widthNumber = (NSNumber *)[self.widthesArray objectAtIndex: column - 1];
                }
                float columnWidth = [widthNumber floatValue];
                secRowCellWidth += columnWidth;
            }
            width = cellWidth > secRowCellWidth ? cellWidth : secRowCellWidth;
        }
        width = width  < self.frame.size.width - leftCellWidth ? self.frame.size.width - leftCellWidth : width;
    }
    
    return width;
}

- (void)allowsMultipleSelection:(BOOL) isAllow {
    
    self.userInteractionEnabled = NO;
    self.isAllowEdit = isAllow;
    if (self.isSelecting && self.isAllowEdit) {
        
        if (!self.mutableSelectionSet) {
            self.mutableSelectionSet = [NSMutableSet setWithCapacity:1];
        }
        
        [self.mutableSelectionSet removeAllObjects];
        [self.leftTableView setEditing:YES];
        
        NSArray *cells = [self.leftTableView visibleCells];
        for (UITableViewCell *cell in cells) {
            
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            if (!cell.multipleSelectionBackgroundView) {
                cell.multipleSelectionBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
                cell.multipleSelectionBackgroundView.backgroundColor = [UIColor whiteColor];
            }
        }
    }
    else {
        
        [self.leftTableView setEditing:NO];
        for (NSArray *rowData in dataSource.data) {
            
            UIView *view = [rowData firstObject];
            if ([view isKindOfClass:[WCURLUILabel class]]) {
                WCURLUILabel *label = (WCURLUILabel *)view;
                label.userInteractionEnabled = YES;
            }
        }
        
        NSArray *cells = [self.leftTableView visibleCells];
        for (UITableViewCell *cell in cells) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    
    self.userInteractionEnabled = YES;
}

- (void)initUITabWith:(CGRect)aRect isAllProducts:(BOOL)isAllProducts {
    
    float contentWidth_ = _contentWidth  < aRect.size.width - leftCellWidth ? aRect.size.width - leftCellWidth : _contentWidth;
    UIColor *titleBgColor = [self getTableHeaderColor];
    UIColor *headerBorderColor = [self getTableHeaderBorderColor];
    float columnOffset = 0;
    float columnOffsetY = 0;
    int notHideColIndex = 1;
    WSTableItem *tableItem = dataSource.currentTableItem;
    
    UIView *rightTableViewHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, contentWidth_, headerHeight)];
    [rightTableViewHeadView setBackgroundColor: titleBgColor];
    rightTableViewHeadView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.rightTableViewHeadView=rightTableViewHeadView;
    
    UIView *rightTableViewHeadViewTopLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentWidth_, 1)];
    rightTableViewHeadViewTopLine.backgroundColor = headerBorderColor;
    rightTableViewHeadViewTopLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [rightTableViewHeadView addSubview:rightTableViewHeadViewTopLine];

    UIView *rightTableViewHeadViewButtomLine = [[UIView alloc] initWithFrame:CGRectMake(0, headerHeight - 1, contentWidth_, 1)];
    rightTableViewHeadViewButtomLine.backgroundColor = headerBorderColor;
    rightTableViewHeadViewButtomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [rightTableViewHeadView addSubview:rightTableViewHeadViewButtomLine];
    
    for (int column = 1; column < [dataSource.titles count]; column++) {
        
        NSString *strinWidth = [dataSource.columnWidth objectAtIndex:column];
        NSArray *widthArray = [self transformedWidthStirng:strinWidth];
        float columnWidth = [((NSNumber *)[widthArray firstObject]) floatValue] + UINIT_SPACE_WIDTH * 2;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(columnOffset, columnOffsetY, columnWidth, headerHeight)];
        label.font = kGridHeaderTitleFont;
        label.text = [dataSource.titles objectAtIndex:column];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorForKey:@"GridHeaderTitleColor"];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 2;
        
        WSFuncsBean_Param *param = [tableItem.paramArray objectAtIndex:column - 1];
        if (param.align.length > 0) {
            
            if ([param.align isEqualToString:@"L"]) {
                label.textAlignment = NSTextAlignmentLeft;
            }
            else if ([param.align isEqualToString:@"R"]) {
                label.textAlignment = NSTextAlignmentRight;
            }
            else if ([param.align isEqualToString:@"C"]) {
                label.textAlignment = NSTextAlignmentCenter;
            }
            else {
                label.textAlignment = NSTextAlignmentCenter;
            }
        }
        
        if ([param.gone isEqualToString:@"0"] || param.gone.length == 0) {
            
            [rightTableViewHeadView addSubview:label];
            if ([widthArray count] > 1) {
                
                NSArray *rowUIdata = [self.dataSource.data firstObject];
                if (column < [rowUIdata count]) {
                    
                    UIView *view = [rowUIdata objectAtIndex:column];
                    if ([view isKindOfClass:[WSGridCheckBoxAll class]]) {
                        
                        WSCheckBox *mWSCheckBox = (WSCheckBox *)[((WSGridCheckBoxAll *)view) getView];
                        if (mWSCheckBox) {
                            
                            float secondUIViewWidth = [((NSNumber *)[widthArray objectAtIndex:1]) floatValue];
                            columnWidth = [((NSNumber *)[widthArray firstObject]) floatValue] + secondUIViewWidth;
                            CGRect frame = label.frame ;
                            frame.origin.x = columnOffset + secondUIViewWidth;
                            frame.size.width = [((NSNumber *)[widthArray firstObject]) floatValue];
                            label.frame = frame;
                            
                            WSGridCheckBoxAll *tempCheckBox = [[WSGridCheckBoxAll alloc] initWithParam:param rowIndex:0 columnIndex:column - 1] ;
                            tempCheckBox.widgetKey = param.col;
                            tempCheckBox.groupName = @"CA";
                            tempCheckBox.isHeader = YES;
                            UIView *checxBox = [tempCheckBox getView];
                            checxBox.frame = CGRectMake(columnOffset, 0, secondUIViewWidth, cellOriginHeight);
                            [rightTableViewHeadView addSubview:checxBox];
                            [self.checkBoxArray addObject:tempCheckBox];
                        }
                    }
                }
            }
            
            CGPoint newOffset = [self getNewColumnOffsetWithOldOffset:CGPointMake(columnOffset, columnOffsetY) andColumnWidth:columnWidth andColumnHeight:headerHeight andIndex:notHideColIndex];
            columnOffset = newOffset.x;
            columnOffsetY = newOffset.y;
            if (columnOffset == 0 && columnOffsetY > 0) {
                
                UIImageView* rightTableViewDashLineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, columnOffsetY - 1, contentWidth_, 1)];
                [rightTableViewDashLineView setImage:[UIImage imageForName:@"imaginary-line"]];
                [rightTableViewHeadView addSubview:rightTableViewDashLineView];
                rightTableViewDashLineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                
                WSAcvtDataGridComponentDataSource *acvtDataSource = [self getAcvtDataSource];
                if ([[acvtDataSource.currentQst getDisplayMode] isEqualToString:@"iconBtn"]) {
                    rightTableViewDashLineView.hidden = YES;
                }
            }
            notHideColIndex++;
        }
        
        [self.widthesArray addObject:[NSNumber numberWithFloat:columnWidth]];
    }
    
    contentWidth_ = [self resetCellWidthWithOriginWidth:contentWidth_];
    CGFloat rightScrollViewOriginY = self.showSerieLinkHeadView ? 44.0f : 0;
    
    UIScrollView *rightScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(leftCellWidth, rightScrollViewOriginY, self.frame.size.width-leftCellWidth, self.height)];
    rightScrollView.backgroundColor = [UIColor grayColor];
    rightScrollView.bounces = NO;
    rightScrollView.contentSize = CGSizeMake(contentWidth_, 0);
    rightScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    rightScrollView.showsHorizontalScrollIndicator = NO;
    rightScrollView.delegate = self;
    rightScrollView.delaysContentTouches = NO;
    [self addSubview:rightScrollView];
    self.m_rightScrollView = rightScrollView;
    
    UITableView *rightTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, contentWidth_, self.height) style:UITableViewStylePlain];
    rightTableView.delegate = self;
    rightTableView.dataSource = self;
    rightTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    rightTableView.bounces = NO;
    if ([rightTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [rightTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([rightTableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [rightTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    rightTableView.backgroundColor = [UIColor whiteColor];
    rightTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    rightTableView.showsVerticalScrollIndicator = NO;
    rightTableView.showsHorizontalScrollIndicator = NO;
    rightTableView.bounces = NO;
    self.rightTableView = rightTableView;
    [self.m_rightScrollView addSubview:rightTableView];
    
    UIView *leftTableViewHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, leftCellWidth, [self.dataSource resetCellHeightWithOriginHeight:headerHeight])];
    [leftTableViewHeadView setBackgroundColor:titleBgColor];
    self.leftTableViewHeadView = leftTableViewHeadView;
    
    UIView *leftTableViewHeadViewTopLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, leftCellWidth, 1)];
    leftTableViewHeadViewTopLine.backgroundColor = headerBorderColor;
    [leftTableViewHeadView addSubview:leftTableViewHeadViewTopLine];
    
    UIView *leftTableViewHeadViewButtomLine = [[UIView alloc] initWithFrame:CGRectMake(0, [self.dataSource resetCellHeightWithOriginHeight:headerHeight] - 1, leftCellWidth, 1)];
    leftTableViewHeadViewButtomLine.backgroundColor = headerBorderColor;
    [leftTableViewHeadView addSubview:leftTableViewHeadViewButtomLine];
    
    for (int column = 0; column < 1; column++) {
        
        CGFloat label_x = MAIN_CELL_PADDING;
        CGFloat label_Width = leftCellWidth;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(label_x, 0, label_Width - label_x, [self.dataSource resetCellHeightWithOriginHeight:headerHeight])];
        NSString *text = [dataSource.titles objectAtIndex:0];
        label.font = kGridHeaderTitleFont;
        label.text = text;
        label.textColor = [UIColor colorForKey:@"GridHeaderTitleColor"];
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.textAlignment=NSTextAlignmentCenter;
        if (column == 0) {
            label.textAlignment = NSTextAlignmentLeft;
        }
        [leftTableViewHeadView addSubview:label];
    }

    CGFloat leftTableOriginY = self.showSerieLinkHeadView ? 44.0f : 0;
    UITableView *leftTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, leftTableOriginY, leftCellWidth, self.height) style:UITableViewStylePlain];
    leftTableView.delegate = self;
    leftTableView.dataSource = self;
    leftTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [leftTableView setAllowsMultipleSelectionDuringEditing:YES];
    leftTableView.backgroundColor = [UIColor whiteColor];
    leftTableView.showsVerticalScrollIndicator = NO;
    leftTableView.showsHorizontalScrollIndicator = NO;
    leftTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    leftTableView.bounces = NO;
    if (([self.currentFuncs.opt.deleteButton isEqualToString:@"1"] || [self.dataSource.currentTableItem.opt.deleteButton isEqualToString:@"1"]) && isAllProducts) {
        [self allowsMultipleSelection:YES];
    }
    [self addSubview:leftTableView];
    self.leftTableView = leftTableView;

    UIView *buttomLine = [[UIView alloc] initWithFrame:CGRectMake(0, aRect.size.height - 1, aRect.size.width, 1)];
    buttomLine.backgroundColor = headerBorderColor;
    buttomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.m_buttomLine = buttomLine;
    [self addSubview:buttomLine];
}

- (void)initUITabSteadyHeadViewWith:(CGRect)aRect {
    
    float contentWidth_ = _contentWidth  < aRect.size.width - leftCellWidth ? aRect.size.width - leftCellWidth : _contentWidth;
    UIColor *titleBgColor = [self getTableHeaderColor];
    UIColor *headerBorderColor = [self getTableHeaderBorderColor];
    float columnOffset = 0;
    float columnOffsetY = 0;
    int notHideColIndex = 1;
    WSTableItem *tableItem = dataSource.currentTableItem;
    
    UIScrollView *rightSteadyHeadView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, contentWidth_, [self.dataSource resetCellHeightWithOriginHeight:headerHeight])];
    [rightSteadyHeadView setBackgroundColor: titleBgColor];

    UIView *rightTableViewHeadViewTopLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentWidth_, 1)];
    rightTableViewHeadViewTopLine.backgroundColor = headerBorderColor;
    rightTableViewHeadViewTopLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [rightSteadyHeadView addSubview:rightTableViewHeadViewTopLine];
    
    UIView *rightTableViewHeadViewButtomLine = [[UIView alloc] initWithFrame:CGRectMake(0, [self.dataSource resetCellHeightWithOriginHeight:headerHeight] - 1, contentWidth_, 1)];
    rightTableViewHeadViewButtomLine.backgroundColor = headerBorderColor;
    rightTableViewHeadViewButtomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [rightSteadyHeadView addSubview:rightTableViewHeadViewButtomLine];

    for (int column = 1; column < [dataSource.titles count]; column++) {
        
        NSString *strinWidth = [dataSource.columnWidth objectAtIndex:column];
        NSArray *widthArray = [self transformedWidthStirng:strinWidth];
        float columnWidth = [((NSNumber *)[widthArray firstObject]) floatValue] + UINIT_SPACE_WIDTH * 2;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(columnOffset, columnOffsetY, columnWidth, headerHeight)];
        label.font = kGridHeaderTitleFont;
        label.text = [dataSource.titles objectAtIndex:column];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorForKey:@"GridHeaderTitleColor"];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 2;
        
        WSFuncsBean_Param *param = [tableItem.paramArray objectAtIndex:column - 1];
        if (param.align.length > 0) {
            
            if ([param.align isEqualToString:@"L"]) {
                label.textAlignment = NSTextAlignmentLeft;
            }
            else if ([param.align isEqualToString:@"R"]) {
                label.textAlignment = NSTextAlignmentRight;
            }
            else if ([param.align isEqualToString:@"C"]) {
                label.textAlignment = NSTextAlignmentCenter;
            }
            else {
                label.textAlignment = NSTextAlignmentCenter;
            }
        }
        
        if ([param.gone isEqualToString:@"0"] || param.gone.length == 0) {
            
            [rightSteadyHeadView addSubview:label];
            if ([widthArray count] > 1) {
                
                NSArray *rowUIdata = [self.dataSource.data firstObject];
                if (column < [rowUIdata count]) {
                    
                    UIView *view = [rowUIdata objectAtIndex:column];
                    if ([view isKindOfClass:[WSGridCheckBoxAll class]]) {
                        
                        WSCheckBox *mWSCheckBox = (WSCheckBox *)[((WSGridCheckBoxAll *)view) getView];
                        if (mWSCheckBox) {
                            
                            float secondUIViewWidth = [((NSNumber *)[widthArray objectAtIndex:1]) floatValue];
                            columnWidth =  [((NSNumber *)[widthArray firstObject]) floatValue] +  secondUIViewWidth;
                            CGRect frame = label.frame ;
                            frame.origin.x = columnOffset + secondUIViewWidth;
                            frame.size.width = [((NSNumber *)[widthArray firstObject]) floatValue] ;
                            label.frame = frame;
                            
                            WSGridCheckBoxAll *tempCheckBox = [[WSGridCheckBoxAll alloc] initWithParam:param rowIndex:0 columnIndex:column - 1] ;
                            tempCheckBox.widgetKey = [NSString stringWithFormat:@"steady_%@", param.col];
                            tempCheckBox.groupName = @"CA";
                            tempCheckBox.isHeader = YES;
                            UIView *checxBox = [tempCheckBox getView];
                            checxBox.frame = CGRectMake(columnOffset, 0, secondUIViewWidth, cellOriginHeight);
                            [rightSteadyHeadView addSubview:checxBox];
                            [self.checkBoxArray addObject:tempCheckBox];
                        }
                    }
                }
            }

            CGPoint newOffset = [self getNewColumnOffsetWithOldOffset:CGPointMake(columnOffset, columnOffsetY) andColumnWidth:columnWidth andColumnHeight:headerHeight andIndex:notHideColIndex];
            columnOffset = newOffset.x;
            columnOffsetY = newOffset.y;
            
            if (columnOffset == 0 && columnOffsetY > 0) {
                
                UIImageView *rightTableViewDashLineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, columnOffsetY - 1, contentWidth_, 1)];
                [rightTableViewDashLineView setImage:[UIImage imageForName:@"imaginary-line"]];
                rightTableViewDashLineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                [rightSteadyHeadView addSubview:rightTableViewDashLineView];
                
                WSAcvtDataGridComponentDataSource *acvtDataSource = [self getAcvtDataSource];
                if ([[acvtDataSource.currentQst getDisplayMode] isEqualToString:@"iconBtn"]) {
                    rightTableViewDashLineView.hidden = YES;
                }
            }
            notHideColIndex++;
        }
        [self.widthesArray addObject:[NSNumber numberWithFloat:columnWidth]];
    }
    
    contentWidth_ = [self resetCellWidthWithOriginWidth:contentWidth_];
 
    UIScrollView *leftSteadyHeadView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, leftCellWidth, [self.dataSource resetCellHeightWithOriginHeight:headerHeight])];
    [leftSteadyHeadView setBackgroundColor:titleBgColor];
 
    UIView *leftTableViewHeadViewTopLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, leftCellWidth, 1)];
    leftTableViewHeadViewTopLine.backgroundColor = headerBorderColor;
    [leftSteadyHeadView addSubview:leftTableViewHeadViewTopLine];

    UIView *leftTableViewHeadViewButtomLine = [[UIView alloc] initWithFrame:CGRectMake(0, [self.dataSource resetCellHeightWithOriginHeight:headerHeight] - 1, leftCellWidth, 1)];
    leftTableViewHeadViewButtomLine.backgroundColor = headerBorderColor;
    [leftSteadyHeadView addSubview:leftTableViewHeadViewButtomLine];
    
    for (int column = 0; column < 1; column++) {
        
        CGFloat label_x = MAIN_CELL_PADDING;
        CGFloat label_Width = leftCellWidth;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(label_x, 0, label_Width - label_x, [self.dataSource resetCellHeightWithOriginHeight:headerHeight])];
        NSString *text = [dataSource.titles objectAtIndex:0];
        label.font = kGridHeaderTitleFont;
        label.text = text;
        label.textColor = [UIColor colorForKey:@"GridHeaderTitleColor"];
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.textAlignment = NSTextAlignmentCenter;
        if (column == 0) {
            label.textAlignment = NSTextAlignmentLeft;
        }
        [leftSteadyHeadView addSubview:label];
    }
    
    _steadyTableHeadView = [self getTableHeadViewWithLeftHeadView:leftSteadyHeadView andRightHeadView:rightSteadyHeadView];
    _leftSteadyHeadView = leftSteadyHeadView;
    _rightSteadyHeadView = rightSteadyHeadView;
}

- (UIView *)getTableHeadViewWithLeftHeadView:(UIView *)leftHeadView andRightHeadView:(UIView *)rightHeadView {
    
    if (!_steadySerieLinkHeadView) {
        _steadySerieLinkHeadView = [[WSSerieLinkHeadView alloc] initWithFrame:self.serieLinkHeadView.frame];
        self.steadySerieLinkHeadView.delegate = self.serieLinkHeadView.delegate;
    }
    
    UIView *tableHeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, leftHeadView.frame.size.height + self.steadySerieLinkHeadView.frame.size.height)];
    tableHeadView.backgroundColor = [UIColor whiteColor];
    [tableHeadView addSubview:self.steadySerieLinkHeadView];
    
    CGRect leftTabHeadViewFrame = leftHeadView.frame;
    leftTabHeadViewFrame.origin.y = self.steadySerieLinkHeadView.frame.size.height;
    leftHeadView.frame = leftTabHeadViewFrame;
    
    CGRect rightTabHeadViewFrame = rightHeadView.frame;
    rightTabHeadViewFrame.origin.x = leftHeadView.frame.origin.x + leftHeadView.frame.size.width;
    rightTabHeadViewFrame.origin.y = self.steadySerieLinkHeadView.frame.size.height;
    rightTabHeadViewFrame.size.width = tableHeadView.frame.size.width - leftHeadView.frame.size.width;
    rightHeadView.frame = rightTabHeadViewFrame;
    
    [tableHeadView addSubview:leftHeadView];
    [tableHeadView addSubview:rightHeadView];
    
    return tableHeadView;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    if ([self.textFieldArray containsObject:textField]) {
        
        NSUInteger count = [self.textFieldArray indexOfObject:textField];
        UITextField *textF = textField;
        if (count == self.textFieldArray.count - 1) {
            return YES;
            textF = (UITextField *)[self.textFieldArray objectAtIndex:0];
        }
        else {
            textF = (UITextField *)[self.textFieldArray objectAtIndex:count + 1];
        }
        [textF becomeFirstResponder];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if ([self.textFieldArray.lastObject isKindOfClass:[UITextField class]]) {
        
        UITextField *textF = [self.textFieldArray lastObject];
        textF.returnKeyType = UIReturnKeyDone;
    }
}

- (void)getTextFieldArrayMethodFromTableView:(UITableView *)tableView andTableViewCell:(UITableViewCell *)cell {
    
    if (tableView == self.rightTableView) {
        
        for (int i = 0; i < cell.contentView.subviews.count; i++) {
            
            if ([[cell.contentView.subviews objectAtIndex:i] isKindOfClass:[UITextField class]] && ![cell.contentView.subviews objectAtIndex:i].hidden &&
                [cell.contentView.subviews objectAtIndex:i].isUserInteractionEnabled) {
                
                UITextField *textF = (UITextField *)[cell.contentView.subviews objectAtIndex:i];
                textF.delegate = self;
                
                if (![self.textFieldArray containsObject:textF]) {
                    [self.textFieldArray addObject:textF];
                }
            }
        }
    }
}

- (WSAcvtDataGridComponentDataSource *)getAcvtDataSource {

    return nil;
}

@end

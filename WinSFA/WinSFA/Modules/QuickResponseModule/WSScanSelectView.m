//
//  WSScanSelectView.m
//  WinSFA
//
//  Created by Alicia on 2017/9/1.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSScanSelectView.h"
#import "WSDropListCell.h"
#import "UIView+Additions.h"

#define kMaxTableHeight         180

static NSString *kScanSelectCellID = @"ScanSelectCell";

@interface WSScanSelectView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *dataTableView;
@property (nonatomic, strong) NSMutableArray *dataHeightArray;
@property (nonatomic, strong) NSMutableArray *selectedArray;

@end

@implementation WSScanSelectView

- (void)setupViews
{
    //YIHAIKERRY-3135 2018-06-19
    [self removeAllSubviews];
    
    CGFloat actionHeight = MAIN_CELL_HEIGHT;
    CGFloat titleHeight = MAIN_CELL_HEIGHT;
    CGFloat tableWidth = self.width * POP_VIEW_WIDTH_RATIO;
    CGFloat tableHeight = [self calcTableHeightByConstraintWidth:tableWidth];
    CGFloat viewHeight = tableHeight + actionHeight + titleHeight + MAIN_PADDING;
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake((self.width - tableWidth) / 2, (self.height - viewHeight) / 2, tableWidth, viewHeight)];
    contentView.layer.cornerRadius = 5;
    contentView.layer.masksToBounds = YES;
    [contentView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:contentView];
    
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(MAIN_PADDING, MAIN_PADDING, tableWidth - MAIN_PADDING, titleHeight)];
    [textLabel setText:NSLocalizedString(@"select_project", nil)];
    [textLabel setTextColor:DETAIL_TEXT_COLOR];
    [contentView addSubview:textLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(textLabel.frame) - 1, self.width, MAIN_CELL_SEPERATOR_HEIGHT)];
    [lineView setBackgroundColor:DETAIL_SEPERATE_LINE_COLOR];
    [contentView addSubview:lineView];
    
    CGRect tableFrame = CGRectMake(0, CGRectGetMaxY(textLabel.frame), tableWidth, tableHeight);
    self.dataTableView = [[UITableView alloc] initWithFrame:tableFrame];
    self.dataTableView.delegate = self;
    self.dataTableView.dataSource = self;
    [self.dataTableView registerClass:[WSDropListCell class] forCellReuseIdentifier:kScanSelectCellID];
    [contentView addSubview:self.dataTableView];
    
    UIColor *buttonColor = ([UIColor colorForKey:@"AlertViewTitle"] ? [UIColor colorForKey:@"AlertViewTitle"] : MAIN_TINT_COLOR);
    UIButton *confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tableFrame), tableWidth, actionHeight)];
    [confirmButton setTitle:NSLocalizedString(@"confirm_label", nil) forState:UIControlStateNormal];
    [confirmButton setTitleColor:buttonColor forState:UIControlStateNormal];
    [confirmButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [confirmButton addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:confirmButton];
}

- (void)setDataArray:(NSArray *)dataArray {
    if (!dataArray || [dataArray count] == 0) {
        LogError(@"没有设置数据");
        return;
    }
    _dataArray = dataArray;
    
    _selectedArray = [NSMutableArray arrayWithObject:dataArray[0]];
    
    [self setupViews];
}

// 计算列表所需的动态高度
- (CGFloat)calcTableHeightByConstraintWidth:(CGFloat)tableWidth {
    self.dataHeightArray = [NSMutableArray arrayWithCapacity:self.dataArray.count];
    
    CGFloat totalHeight = 0;
    
    UIFont *font = [UIFont systemFontOfSize:UI_Font];
    for (NSInteger i = 0; i < self.dataArray.count; i++) {
        WSProdBean *prodBean = [self.dataArray objectAtIndex:i];
        CGSize fontSize = [[prodBean name] ws_sizeWithFont:font constrainedToWidth:tableWidth];
        CGFloat cellHeight = fontSize.height + MAIN_PADDING * 2;
        [self.dataHeightArray addObject:[NSNumber numberWithFloat:cellHeight]];
        
        totalHeight += cellHeight;
    }
    
    if (totalHeight > kMaxTableHeight) {
        return kMaxTableHeight;
    } else {
        return totalHeight;
    }
}

#pragma mark - Actions
- (void)confirmAction:(id)sender {
    [self removeFromSuperview];
    
    if (self.delegate) {
        [self.delegate selectedData:[self.selectedArray copy]];
    }
}


#pragma mark - DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (NSInteger)numberOfSectionsInTableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    WSDropListCell * cell = [tableView dequeueReusableCellWithIdentifier:kScanSelectCellID];
    cell.isResetColor = NO;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    WSProdBean *prodBean = [self.dataArray objectAtIndex:indexPath.row];
    BOOL isSelected = NO;
    if ([self.selectedArray containsObject:prodBean]) {
        isSelected = YES;
    }

    [cell setDataItem:prodBean isSelected:isSelected];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *height = self.dataHeightArray[indexPath.row];
    return [height floatValue];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WSProdBean *prodBean = [self.dataArray objectAtIndex:indexPath.row];
    if ([self.selectedArray containsObject:prodBean]) {
        [self.selectedArray removeObject:prodBean];
    } else {
        [self.selectedArray addObject:prodBean];
    }
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

@end

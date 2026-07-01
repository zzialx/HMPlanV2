//
//  WSAddNewStoreSelectView.m
//  WinSFA
//
//  Created by Alicia on 17/2/22.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSAddNewStoreSelectView.h"
#import "WSAddNewStoreSelectCell.h"
#import "NSString+Additions.h"

#define kMaxTableHeight     180
#define kNotSelectIndex     -1

static NSString * const kNewStoreSelectCellId = @"NewStoreSelectCell";

@interface WSAddNewStoreSelectView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) UITableView *dataTableView;
@property (nonatomic, strong) NSMutableArray *dataHeightArray;


@end

@implementation WSAddNewStoreSelectView


- (void)setupViews {
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    [backgroundView setBackgroundColor:POP_WINDOW_BG_COLOR];
    [self addSubview:backgroundView];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(tapBackgroundAction:)];
    [backgroundView addGestureRecognizer:tapGesture];
    
  
    CGFloat actionHeight = MAIN_CELL_HEIGHT;
    CGFloat titleHeight = 20;
    CGFloat tableWidth = self.width * POP_VIEW_WIDTH_RATIO;
    CGFloat tableHeight = [self calcTableHeightByConstraintWidth:tableWidth];
    CGFloat viewHeight = tableHeight + actionHeight + titleHeight + MAIN_PADDING;
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake((self.width - tableWidth) / 2, (self.height - viewHeight) / 2, tableWidth, viewHeight)];
    contentView.layer.cornerRadius = 5;
    contentView.layer.masksToBounds = YES;
    [contentView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:contentView];
    
    CGFloat closeHeight = titleHeight;
    UIImage *closeImage = [[UIImage imageNamed:@"close_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(tableWidth - MAIN_BUTTON_WH, MAIN_PADDING, MAIN_BUTTON_WH, closeHeight)];
    [closeButton setImage:closeImage forState:UIControlStateNormal];
    closeButton.tintColor = MAIN_TINT_COLOR;
    [contentView addSubview:closeButton];
    [closeButton addTarget:self action:@selector(tapBackgroundAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(MAIN_PADDING, MAIN_PADDING, tableWidth - MAIN_PADDING - closeHeight, titleHeight)];
    [textLabel setText:NSLocalizedString(@"select_store_notify", nil)];
    [textLabel setTextColor:DETAIL_TEXT_COLOR];
    [textLabel setFont:[UIFont systemFontOfSize:12]];
    [contentView addSubview:textLabel];
    
    CGRect tableFrame = CGRectMake(0, CGRectGetMaxY(textLabel.frame), tableWidth, tableHeight);
    self.dataTableView = [[UITableView alloc] initWithFrame:tableFrame];
    self.dataTableView.delegate = self;
    self.dataTableView.dataSource = self;
    [self.dataTableView registerClass:[WSAddNewStoreSelectCell class] forCellReuseIdentifier:kNewStoreSelectCellId];
    [contentView addSubview:self.dataTableView];
    
    UIColor *buttonColor = ([UIColor colorForKey:@"AlertViewTitle"] ? [UIColor colorForKey:@"AlertViewTitle"] : MAIN_TINT_COLOR);
    UIButton *confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tableFrame), tableWidth / 2, actionHeight)];
    [confirmButton setTitle:NSLocalizedString(@"confirm_label", nil) forState:UIControlStateNormal];
    [confirmButton setTitleColor:buttonColor forState:UIControlStateNormal];
    [confirmButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [confirmButton addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:confirmButton];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(tableWidth / 2, CGRectGetMaxY(tableFrame), tableWidth / 2, actionHeight)];
    [addButton setTitle:NSLocalizedString(@"add_label", nil) forState:UIControlStateNormal];
    [addButton setTitleColor:buttonColor forState:UIControlStateNormal];
    [addButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [addButton addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:addButton];
    
    CALayer *rightLayer = [CALayer layer];
    rightLayer.frame = CGRectMake(confirmButton.frame.size.width, 0, 1, confirmButton.frame.size.height);
    rightLayer.backgroundColor = DETAIL_SEPERATE_LINE_COLOR.CGColor;
    [confirmButton.layer addSublayer:rightLayer];
    
    [self addTopLayerToView:confirmButton];
    [self addTopLayerToView:addButton];
}

- (void)addTopLayerToView:(UIView *)view {
    CALayer *topLayer = [CALayer layer];
    topLayer.frame = CGRectMake(0, 0, view.frame.size.width, 1);
    topLayer.backgroundColor = DETAIL_SEPERATE_LINE_COLOR.CGColor;
    [view.layer addSublayer:topLayer];
}

- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;

    self.selectedIndex = kNotSelectIndex;
    
    [self setupViews];
}

// 计算列表所需的动态高度
- (CGFloat)calcTableHeightByConstraintWidth:(CGFloat)tableWidth {
    self.dataHeightArray = [NSMutableArray arrayWithCapacity:self.dataArray.count];
    
    CGFloat totalHeight = 0;
    for (NSInteger i = 0; i < self.dataArray.count; i++) {
        WSStoreBean *storeBean = self.dataArray[i];
        
        UIFont *font = [UIFont systemFontOfSize:kAddNewStoreCellFontSize];
        
        NSString *name = storeBean.name;
        NSString *addr = storeBean.addr ? storeBean.addr : NSLocalizedString(@"empty_instruction_sheet_label", nil);
        NSString *phone = storeBean.phone ? storeBean.phone : NSLocalizedString(@"empty_instruction_sheet_label", nil);
        
        CGFloat labelWidth = tableWidth - kAddNewStoreLeftWdith;
        CGSize nameSize = [name ws_sizeWithFont:font constrainedToWidth:labelWidth];
        CGSize addrSize = [addr ws_sizeWithFont:font constrainedToWidth:labelWidth];
        CGSize phontSize = [phone ws_sizeWithFont:font constrainedToWidth:labelWidth];

        CGFloat cellHeight = nameSize.height;
        cellHeight += addrSize.height;
        cellHeight += phontSize.height;
        cellHeight += MAIN_PADDING * 2;
        
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
    if (self.selectedIndex == kNotSelectIndex) {
        NSString *title = NSLocalizedString(@"请选择一个门店", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    [self removeFromSuperview];
    
    if (self.delegate) {
        WSStoreBean *storeBean = self.dataArray[self.selectedIndex];
        [self.delegate addNewStoreByIsAdd:NO overideStore:storeBean];
    }
}

- (void)addAction:(id)sender {
    [self removeFromSuperview];
    
    if (self.delegate) {
        [self.delegate addNewStoreByIsAdd:YES overideStore:nil];
    }
}

- (void)tapBackgroundAction:(id)sender {
    [self removeFromSuperview];
}

#pragma mark - DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (NSInteger)numberOfSectionsInTableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WSAddNewStoreSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:kNewStoreSelectCellId forIndexPath:indexPath];
    
    WSStoreBean *storeBean = self.dataArray[indexPath.row];
    [cell setStoreBean:storeBean];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == self.selectedIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *height = self.dataHeightArray[indexPath.row];
    return [height floatValue];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.selectedIndex) {
        return;
    }
    
    // cancel last checked cell
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:self.selectedIndex inSection:0];
    UITableViewCell *lastCell = [tableView cellForRowAtIndexPath:lastIndexPath];
    lastCell.accessoryType = UITableViewCellAccessoryNone;
    
    
    self.selectedIndex = indexPath.row;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
}


@end

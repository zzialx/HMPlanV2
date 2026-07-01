//
//  WSTreeListViewController.m
//  WinSFA
//
//  Created by Alicia on 2018/3/5.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSTreeListViewController.h"
#import "UIView+Additions.h"

@interface WSTreeListViewController()

@property (nonatomic, strong) UIButton *selectAllButton;
@property (nonatomic, strong) NSMutableArray *lastSelctedArray;

@end

@implementation WSTreeListViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Init
- (void)setupViews {
    CGFloat controlHeight = MAIN_CELL_HEIGHT;
    
    WSPersonnelListStyle listStyle = WSPersonnelListStyleOption | WSPersonnelListStyleParentOption | WSPersonnelListStyleLeftOption | WSPersonnelListStyleSearchable;
    
    CGFloat treeViewHeight = self.view.height - controlHeight * 2;
    WSPersonnelListTreeView *treeView = [[WSPersonnelListTreeView alloc] initWithFrame: CGRectMake(0, 0, self.view.width, treeViewHeight) listStyle:listStyle];
    self.treeListView = treeView;
    [self.view addSubview:self.treeListView];
    
    NSInteger controlCount = 3;
    CGFloat controlWidth = self.view.width / controlCount;
    UIViewAutoresizing autoResizing = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    UIButton *selectAllButton = [[UIButton alloc] initWithFrame:CGRectMake(0, treeViewHeight, controlWidth, controlHeight)];
    NSString *title = [NSString stringWithFormat:@"  %@", NSLocalizedString(@"check_all", nil)];
    [selectAllButton setTitle:title forState:UIControlStateNormal];
    [selectAllButton setBackgroundColor:MAIN_TINT_COLOR];
    [selectAllButton setImage:[UIImage imageNamed:@"icn_check"] forState:UIControlStateSelected];
    [selectAllButton setImage:[UIImage imageNamed:@"icn_nocheck"] forState:UIControlStateNormal];
    [selectAllButton setAutoresizingMask:autoResizing];
    [selectAllButton addTarget:self action:@selector(selectAllAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:selectAllButton];
    self.selectAllButton = selectAllButton;
    
    UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(controlWidth, treeViewHeight, controlWidth, controlHeight)];
    [clearButton setTitle:NSLocalizedString(@"clear_label", nil) forState:UIControlStateNormal];
    [clearButton setBackgroundColor:MAIN_TINT_COLOR];
    [clearButton addLeftBorder];
    [clearButton addRightBorder];
    [clearButton setAutoresizingMask:autoResizing];
    [clearButton addTarget:self action:@selector(clearAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clearButton];
    
    UIButton *confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(controlWidth * (controlCount - 1), treeViewHeight, controlWidth, controlHeight)];
    [confirmButton setTitle:NSLocalizedString(@"confirm", nil) forState:UIControlStateNormal];
    [confirmButton setBackgroundColor:MAIN_TINT_COLOR];
    [confirmButton addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
    [confirmButton setAutoresizingMask:autoResizing];
    
    [self.view addSubview:confirmButton];
}

- (void)initializationBackItemAction {
    [self backItemAction:@selector(backAction) target:self];
}

#pragma mark - Public Method
- (void)setSelectedArray:(NSMutableArray *)selectedArray {
    self.lastSelctedArray = [[NSMutableArray alloc] initWithArray:selectedArray copyItems:YES];
    
    [self.treeListView setSelectArray:selectedArray];
    if ([selectedArray count] > 0 && [selectedArray count] == [self.treeListView.dataArray count]) {
        [self.selectAllButton setSelected:YES];
    }
}

#pragma mark - Action
- (void)backAction {
    if (self.selectBlock) {
        self.selectBlock(self.lastSelctedArray);
    }
    [self done];
}

- (void)selectAllAction:(UIButton *)sender {
    BOOL isSelected = !sender.selected;
    [sender setSelected:isSelected];
    [self.treeListView selectAll:isSelected];
}

- (void)clearAction:(id)sender {
    [self.selectAllButton setSelected:NO];
    [self.treeListView selectAll:NO];
}

- (void)confirmAction:(id)sender {
    [self done];
}

#pragma mark - Private Method
- (void)done {
    [self.treeListView resetSearchBar:YES];
    if (self.doneBlock) {
        self.doneBlock();
        
    }
}


@end

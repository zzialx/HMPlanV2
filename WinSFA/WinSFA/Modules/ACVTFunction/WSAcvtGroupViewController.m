//
//  WSAcvtGroupViewController.m
//  WinSFA
//
//  Created by Alicia on 2018/2/2.
//  Copyright © 2018年 WinChannel. All rights reserved.
//
//  为了实现分组功能，将 AcvtView 视图加到列表上

#import "WSAcvtGroupViewController.h"
#import "WSAcvtView.h"
#import "WSAcvtModel.h"
#import "UIView+Additions.h"

static NSString * const kAcvtTabelCellID = @"AcvtTabelCellID";

#define kTagBase        100
#define kHeaderHeight   44

@interface WSAcvtGroupViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableIndexSet *expandSections;
@property (nonatomic, strong) NSArray *viewArray;
@property (nonatomic, strong) NSArray *groupNameArray;
@property (nonatomic, strong) WSAcvtBean *acvtBean;
@end

@implementation WSAcvtGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeScrollViewOffSet:) name:CHANGE_ACVTSCROLLVIEW_OFFSET_NOTIFICATION object:nil];
    
    [self setupViews];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHANGE_ACVTSCROLLVIEW_OFFSET_NOTIFICATION object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Init
- (instancetype)initWithGroupNameArray:(NSArray *)groupNameArray acvtViewArray:(NSArray *)acvtViewArray {
    self = [super init];
    if (self) {
        self.groupNameArray = groupNameArray;
        self.viewArray = acvtViewArray;
        self.expandSections = [[NSMutableIndexSet alloc] init];
    }
    return self;
}

- (void)setupViews {
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    UIColor *bgColor = [UIColor colorForKey:@"AcvtViewBackgroundColor"];
    if (!bgColor) {
        bgColor = [UIColor whiteColor];
    }
    tableView.backgroundColor = bgColor;
    tableView.allowsSelection = NO;
    tableView.bounces = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kAcvtTabelCellID];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];

    self.tableView = tableView;
}

#pragma mark - Public Method

- (void)resetGroupNameArray:(NSArray *)groupNameArray acvtViewArray:(NSArray *)acvtViewArray {
    self.groupNameArray = groupNameArray;
    self.viewArray = acvtViewArray;
    
    [self expandFirstSection];
    [self.tableView reloadData];
}

- (void)setHeaderView:(UIView *)headerView {
    [self.tableView setTableHeaderView:headerView];
}


#pragma mark - Private Method
- (void)expandFirstSection {
    if ([self.groupNameArray count] == 0) {
        return;
    }
    
    if ([self.expandSections count] > 0) {
        [self.expandSections removeAllIndexes];
    }
    
    [self.expandSections addIndex:0];
}


#pragma mark - Actions
- (void)tapHeaderAction:(UIView *)sender {
    NSInteger section = sender.tag - kTagBase;
    BOOL isExpand = [self.expandSections containsIndex:section];
    if (isExpand) {
        [self.expandSections removeIndex:section];
    } else {
        [self.expandSections addIndex:section];
    }
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:section];
    [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationFade];
}


#pragma mark - Keyboard Notification
- (void)changeScrollViewOffSet:(NSNotification*)notification {
    NSDictionary *userInfo = [notification userInfo];

    CGFloat changeHeight = [userInfo[WSTEXTVIEWPANEL_CHANGED_HEIGHT] floatValue];
    self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y + changeHeight);    
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.groupNameArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 目前 WSAcvtView 只能通过 acvtBean 和 qstArray 创建，所以每个组的 WSAcvtView 都只会有一个
    if ([self.expandSections containsIndex:section]) {
        return 1;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAcvtTabelCellID forIndexPath:indexPath];
    [cell.contentView removeAllSubviews];
    UIView *view = self.viewArray[indexPath.section];
    [cell.contentView addSubview:view];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.expandSections containsIndex:indexPath.section]) {
        UIView *view = self.viewArray[indexPath.section];
        return view.height;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIControl *headerControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kHeaderHeight)];
    [headerControl setBackgroundColor:[UIColor whiteColor]];
    [headerControl addTarget:self action:@selector(tapHeaderAction:) forControlEvents:UIControlEventTouchUpInside];
    headerControl.tag = kTagBase + section;
    [headerControl addBottomBorder];
    
    UIImageView *arrowImageView = [[UIImageView alloc] init];
    UIImage *arrowImage;
    BOOL isExpand = [self.expandSections containsIndex:section];
    if (isExpand) {
        arrowImage = [UIImage imageNamed:@"brand_checked"];
    } else {
        arrowImage = [UIImage imageNamed:@"brand_unchecked"];
    }
    [arrowImageView setImage:arrowImage];
    [arrowImageView setContentMode:UIViewContentModeCenter];
    CGSize imageSize = arrowImage.size;
    [arrowImageView setFrame:CGRectMake(MAIN_PADDING, (kHeaderHeight - imageSize.height) / 2, imageSize.width, imageSize.height)];
    [headerControl addSubview:arrowImageView];
    
    CGFloat paddingX = CGRectGetMaxX(arrowImageView.frame) + MAIN_TEXT_IMG_PADDING;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(paddingX, 0, CGRectGetWidth(self.view.frame) - paddingX - MAIN_PADDING, kHeaderHeight)];
    [label setFont:[UIFont systemFontOfSize:UI_Font]];
    [label setText:self.groupNameArray[section]];
    [label setTextColor:[UIColor blackColor]];
    [headerControl addSubview:label];
    return headerControl;
}


@end

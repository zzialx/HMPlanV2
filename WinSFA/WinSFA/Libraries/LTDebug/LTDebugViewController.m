//
//  LTDebugViewController.m
//  WinSFA
//
//  Created by Alicia on 2017/3/18.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "LTDebugViewController.h"
#import "LTDDLog.h"
#import "LTDebugTableViewCell.h"
#import "LTDebugView.h"

static NSString * const kDebugCellTag = @"DebugCell";

@interface LTDebugViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *logTableView;
@property (nonatomic, strong) NSArray *logArray;

@end

@implementation LTDebugViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupViews {
    self.title = @"Logs";
    
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearAction:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[LTDebugTableViewCell class] forCellReuseIdentifier:kDebugCellTag];
    [self.view addSubview:tableView];
    self.logTableView = tableView;
}

- (void)loadData {
    LTDDLog *log = [[LTDDLog alloc] init];
    self.logArray = [log getLogs];
}

#pragma mark - Action
- (void)doneAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [[LTDebugView sharedInstance] resetWindowAndViewByIsHidden:NO];
    }];
}

- (void)clearAction:(id)sender {
    LTDDLog *log = [[LTDDLog alloc] init];
    [log clearLog];
    
    [self loadData];
    [self.logTableView reloadData];
}

#pragma mark - UITableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.logArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LTDebugTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDebugCellTag forIndexPath:indexPath];
    NSInteger index = self.logArray.count - indexPath.row - 1;
    [cell setLogModel:self.logArray[index]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = self.logArray.count - indexPath.row - 1;
    return [LTDebugTableViewCell getCellHeightByLogModel:self.logArray[index]];
}


@end

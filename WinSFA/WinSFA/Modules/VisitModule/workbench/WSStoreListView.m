//
//  WSStoreListView.m
//  WinSFA
//
//  Created by yang on 16/12/15.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSStoreListView.h"
#import "WSSelectListNewTableviewCell.h"

#define kAnimationDuration 0.35
#define kViewWidth 240
#define kMaxViewHeight 320

@interface WSStoreListView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *blockView;

@property (nonatomic, strong) NSArray *storeList;

@property (nonatomic, strong) WSStoreBean *selectedStore;

@property (nonatomic, strong) UITableView *tableView;


@end

@implementation WSStoreListView

- (instancetype)initWithStoreList:(NSArray *)storeList
{
    self = [super init];
    
    if (self) {
        
        self.layer.cornerRadius = 5.0f;
        self.clipsToBounds = YES;
        
        _storeList = storeList;
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.bounces = NO;
        [self addSubview:tableView];
        self.tableView = tableView;
    }
    
    return self;
}

- (void)showOnView:(UIView *)view
{
    [self.tableView reloadData];
    
    self.blockView = [[UIView alloc] initWithFrame:view.bounds];
    self.blockView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.blockView.alpha = 0.01;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blockViewTapped:)];
    [self.blockView addGestureRecognizer:tap];
    [view addSubview:self.blockView];
    
    CGFloat height = self.storeList.count * STORE_LIST_CELL_DEFAULT_HEIGHT;
    if (height > kMaxViewHeight) {
        height = kMaxViewHeight;
    }
    
    CGRect endFrame = CGRectMake((view.width - kViewWidth)/2, (view.height - height)/2, kViewWidth, height);
    
    self.frame = CGRectMake(view.width/2, view.height/2, 0, 0);
    
    [view addSubview:self];
    
    self.alpha = 1.0;
    
    if (IOS7_OR_LATER) {
        [UIView animateWithDuration:kAnimationDuration delay:0 usingSpringWithDamping:0.65 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.frame = endFrame;
            self.blockView.alpha = 1.0;
        } completion:^(BOOL finished) {
            
        }];
    }else {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.frame = endFrame;
            self.blockView.alpha = 1.0;
        }];
    }
    
}

- (void)hideView
{
    [self.blockView removeFromSuperview];
    
    if (IOS7_OR_LATER) {
        [UIView animateWithDuration:kAnimationDuration delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.frame = CGRectMake(self.superview.width/2, self.superview.height/2, 10, 10);
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }else {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.frame = CGRectMake(self.superview.width/2, self.superview.height/2, 10, 10);
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}

- (void)blockViewTapped:(id) sender
{
    [self hideView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.storeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    

        
    WSSelectListNewTableviewCell * cell = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    if (cell == nil) {

        cell = [[WSSelectListNewTableviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SimpleTableIdentifier withFuncStyle:WSSelectListNewTableviewCellStyleStoreVisitList isStoreInfo:@"0" cellWidth:tableView.width];
        
    }
    
    WSStoreBean *storeBean = self.storeList[indexPath.row];
    
    cell.store = storeBean;
    
    if ([storeBean.Id isEqualToString:self.selectedStore.Id]) {
        cell.contentView.backgroundColor = MAIN_CELL_SELECTED_COLOR;
    }else {
        cell.contentView.backgroundColor = WHITE_COLOR;
    }
    
    return cell;
        

}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return STORE_LIST_CELL_DEFAULT_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WSStoreBean *storeBean = self.storeList[indexPath.row];
    
    if (![storeBean.Id isEqualToString:self.selectedStore.Id]) {
        if ([self.delegate respondsToSelector:@selector(didSelectStore:)]) {
            [self.delegate didSelectStore:storeBean];
        }
    }
    
    
    [self hideView];
}


@end

//
//  WSMainLeftView.m
//  WinSFA
//
//  Created by yang on 14-4-21.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSMainLeftView.h"
#import "WSFuncsBeanArray.h"
#import "WSLeftTableViewCell.h"
#import "WSAppData.h"
#import "MJRefresh.h"
#import "WSLeftBottomButton.h"
#import "WSMJProgressHeader.h"

#define kLeftViewSectionHeaderHeight (IOS7_OR_LATER ? 150.0f : 130.0f)
#define kLeftViewLogoTopSpace (IOS7_OR_LATER ? 20.0f : 0.0f)
static const CGFloat kArrowHeight = 25;

#define kMainBottomCellGap 11

@interface WSMainLeftView ()

@property (nonatomic, strong) NSIndexPath *lastSelectedIndexPath;

@property (nonatomic, strong) UIImageView * buttomArrowImageView;
@property (nonatomic, strong) UIImageView * topArrowImageView;

@property (nonatomic, strong) NSMutableArray *topFuncsArray;
@property (nonatomic, strong) NSMutableArray *bottomFuncsArray;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) WSLeftBottomButton *lastSelectedBottomButton;

@property (nonatomic, strong) NSMutableArray *bottomButtonArray;

@property (nonatomic, assign) BOOL isShowArrow;

@end


@implementation WSMainLeftView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UIColor *bgColor = [UIColor colorForKey:@"LeftViewCellNormalBackgroundColor"];
        if (!bgColor) {
            bgColor = MAIN_TINT_COLOT;
        }
        
        self.backgroundColor = bgColor;
        
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, IOS7_OR_LATER ? 20 : 0, self.width, kLeftViewSectionHeaderHeight)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kLeftViewLogoTopSpace, k_MainkLeftVieWidth, kLeftViewSectionHeaderHeight - kLeftViewLogoTopSpace)];
        [imageView setImage:[UIImage imageForName:@"leftview_logo"]];
        imageView.contentMode = UIViewContentModeCenter;
        [view addSubview:imageView];
        UIColor *titleBgColor = [UIColor colorForKey:@"LeftTitleViewBackgroundColor"];
        if (!titleBgColor) {
            titleBgColor = MAIN_TINT_COLOT;
        }
        [view setBackgroundColor:titleBgColor];
        self.headerView = view;
        [self addSubview:self.headerView];
        
        
        WSFuncsBeanArray* fba = [WSAppData getObjectbyKey:FUNCS];
        self.funcsBeanArray = fba;
        
        _topFuncsArray = [NSMutableArray array];
        _bottomFuncsArray = [NSMutableArray array];
        _leftBottombtnDict = [NSMutableDictionary dictionary];
        
        for (WSFuncsBean *funcBean in self.funcsBeanArray.funcsArray) {
            if ([funcBean.alignBottom isEqualToString:@"1"]) {
                [_bottomFuncsArray addObject:funcBean];
            }else {
                [_topFuncsArray addObject:funcBean];
            }
        }
        
        CGFloat bottomHeight = 0;
        if ([_bottomFuncsArray count] > 0) {
            _bottomButtonArray = [NSMutableArray arrayWithCapacity:_bottomFuncsArray.count];
            
            bottomHeight = (kMainBottomCellGap + kMainBottomCellHeight) * [_bottomFuncsArray count];
            self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - bottomHeight, k_MainkLeftVieWidth, bottomHeight)];
            self.bottomView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
            self.bottomView.backgroundColor = bgColor;
            
            for (WSFuncsBean *funcsBean in _bottomFuncsArray) {
                NSInteger index = [_bottomFuncsArray indexOfObject:funcsBean];
                WSLeftBottomButton *button = [[WSLeftBottomButton alloc] initWithFrame:CGRectMake((self.width - kMainBottomCellWidth)/2, index * (kMainBottomCellGap + kMainBottomCellHeight), kMainBottomCellWidth, kMainBottomCellHeight) funcsBean:funcsBean];
                button.isBottomButton = YES;
                [button addTarget:self action:@selector(bottomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                [self.bottomView addSubview:button];
                [_leftBottombtnDict setObject:button forKey:funcsBean.fv];
                [_bottomButtonArray addObject:button];
            }
            
            [self addSubview:self.bottomView];
        }
        
        self.isShowArrow = NO;
        CGFloat tableViewHeight = self.height - self.headerView.bottom - bottomHeight;
        CGFloat kTitlePaddingBottom = 15; // 文字和底部空白
        // 正好能显示下时不需要添加下拉箭头，文字和底部有留白，该留白不影响显示所以去掉该留白
        if (tableViewHeight < (_topFuncsArray.count ) * kLeftViewCellHeight - kTitlePaddingBottom) {
            tableViewHeight -= kArrowHeight;
            self.isShowArrow = YES;
        }
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.headerView.bottom, self.width, tableViewHeight) style:UITableViewStylePlain];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.tableView setBackgroundColor:bgColor];
        self.tableView.bounces = YES;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.showsVerticalScrollIndicator = NO;
        
        WSMJProgressHeader *header = [WSMJProgressHeader headerWithRefreshingTarget:self refreshingAction:@selector(beginRefreshData)];
        header.automaticallyChangeAlpha = YES;
        self.tableView.mj_header = header;
        
        [self addSubview:self.tableView];
        [self.tableView reloadData];
        
        UIView* topView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 20)];
        [topView setBackgroundColor:bgColor];
        [self addSubview:topView];

    }
    return self;
}

- (void)beginRefreshData
{
    if ([self.delegate respondsToSelector:@selector(needRefreshData)]) {
        [self.delegate needRefreshData];
    }else {
        [self endRefreshData];
    }
}


-(void)setArrowImageView
{
    LogTrace();
    if(self.topArrowImageView == nil){
        self.topArrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.width/4, kLeftViewSectionHeaderHeight, self.width/2, kArrowHeight)];
        [self.topArrowImageView setImage:[UIImage imageForName:@"leftview_top_arrow"]];
        [self.topArrowImageView setContentMode:UIViewContentModeCenter];
        self.topArrowImageView.backgroundColor = [UIColor clearColor];
    }
    if(self.buttomArrowImageView == nil){
        self.buttomArrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.width/4, self.height-25, self.width/2, kArrowHeight)];
        self.buttomArrowImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self.buttomArrowImageView setImage:[UIImage imageForName:@"leftview_bottom_arrow"]];
        [self.buttomArrowImageView setContentMode:UIViewContentModeCenter];
        self.buttomArrowImageView.backgroundColor = [UIColor clearColor];
    }
    
    if(self.isShowArrow){
        [self addSubview:self.topArrowImageView];
        [self addSubview:self.buttomArrowImageView];
        self.topArrowImageView.hidden=YES;
    }
}

- (void)setEventIdentifer:(NSString *)identifer withFuncsBean:(WSFuncsBean *)funcsBean
{
    NSInteger index = [self findIndexOfFuncsBean:funcsBean inArray:self.topFuncsArray];
    
    if (index != NSNotFound) {
        
        WSLeftTableViewCell *cell = (WSLeftTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [cell setEventIdentifer:identifer];
    }else {
        
        WSLeftBottomButton *button = [self.leftBottombtnDict objectForKey:funcsBean.fv];
        [button setEventIdentifer:identifer];
    }
}

- (void)setValueChanged:(BOOL)changed withFuncsBean:(WSFuncsBean *)funcsBean
{
    NSInteger index = [self findIndexOfFuncsBean:funcsBean inArray:self.topFuncsArray];
    
    if (index != NSNotFound) {
        
        WSLeftTableViewCell *cell = (WSLeftTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [cell setValueChanged:changed];
    }
}

- (void)bottomButtonAction:(id)sender
{
    if ([sender isKindOfClass:[WSLeftBottomButton class]]) {
        WSLeftBottomButton *button = (WSLeftBottomButton *)sender;
        
        self.lastSelectedBottomButton.selected = NO;
        
        self.lastSelectedBottomButton = button;
        
        button.selected = YES;
        
        if (self.lastSelectedIndexPath) {
            [self.tableView deselectRowAtIndexPath:self.lastSelectedIndexPath animated:YES];
            self.lastSelectedIndexPath = nil;
        }
        
        if ([self.delegate respondsToSelector:@selector(didSelectFuncsBean:)]) {
            [self.delegate didSelectFuncsBean:button.funcsBean];
        }
    }
}

- (void)showFuncsBean:(WSFuncsBean *)funcsBean
{
    NSInteger index = [self findIndexOfFuncsBean:funcsBean inArray:self.topFuncsArray];
    
    if (index != NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        if ([self.tableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
            [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:indexPath];
        }
    }else {
        
        NSInteger index = [self findIndexOfFuncsBean:funcsBean inArray:self.bottomFuncsArray];
        
        if (index != NSNotFound) {
            WSLeftBottomButton *button = (WSLeftBottomButton *)self.bottomButtonArray[index];
            
            [self bottomButtonAction:button];
        }
    }
}

- (void)selectFuncsBean:(WSFuncsBean *)funcsBean
{
    LogTrace();
    NSInteger index = [self findIndexOfFuncsBean:funcsBean inArray:self.topFuncsArray];
    
    if (index != NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView deselectRowAtIndexPath:self.lastSelectedIndexPath animated:NO];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        self.lastSelectedIndexPath = indexPath;
    }
    
}

- (void)endRefreshData
{
    [self.tableView.mj_header endRefreshing];
}

- (NSInteger)findIndexOfFuncsBean:(WSFuncsBean *)funcsBean inArray:(NSArray *)array
{
    NSInteger index = [array indexOfObject:funcsBean];
    
    if (index == NSNotFound) {
        for (WSFuncsBean *fb in array) {
            if ([fb.fc isEqualToString:funcsBean.fc]) {
                index = [array indexOfObject:fb];
                break;
            }
        }
    }
    
    return index;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [self.topFuncsArray count];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    LogTrace();
//    return kLeftViewSectionHeaderHeight;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    
//    
//    return view;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kLeftViewCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"LeftViewCellReuseIdentifier";
    
    WSLeftTableViewCell *cell = (WSLeftTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (cell == nil) {
        cell = [[WSLeftTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    [cell setData:[self.topFuncsArray objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.lastSelectedBottomButton.selected = NO;
    
    if (self.lastSelectedIndexPath && [self.lastSelectedIndexPath compare:indexPath] == NSOrderedSame) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(didSelectFuncsBean:)]) {
        BOOL result = [self.delegate didSelectFuncsBean:[self.topFuncsArray objectAtIndex:indexPath.row]];
        if (!result) {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            if (self.lastSelectedIndexPath) {
                [tableView selectRowAtIndexPath:self.lastSelectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
        else
        {
            self.lastSelectedIndexPath = indexPath;
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // jira  winSFA MSTD-3616  测试如果只加在上滑的地方，当tableview的Offset为0时还是会有这个问题，所以就直接添加在这个地方
//    [self showFuncsBean:[self.topFuncsArray objectAtIndex:self.lastSelectedIndexPath.row]];
    
    if (self.tableView.contentOffset.y > 0 && self.tableView.contentOffset.y < (self.tableView.contentSize.height-self.tableView.height)) {
        self.topArrowImageView.hidden = NO;
        self.buttomArrowImageView.hidden = NO;
    }
    if(self.tableView.contentOffset.y == self.tableView.contentSize.height-self.tableView.height){
        self.topArrowImageView.hidden = NO;
        self.buttomArrowImageView.hidden = YES;
    }
    if(self.tableView.contentOffset.y == 0){
        self.topArrowImageView.hidden = YES;
        self.buttomArrowImageView.hidden = NO;
    }
    
}

@end

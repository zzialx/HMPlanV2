//
//  WSDropListView.m
//  WinSFA
//
//  Created by yang on 15/3/26.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSDropListView.h"
#import "QuartzCore/QuartzCore.h"
#import "I_W_OptionDataItem.h"
#import "WSDropListCell.h"
#import "WidgetConstant.h"
#import "WSSearchBar.h"
#import "WSHeaderSearchView.h"
#import "WSRequestHelper.h"
#import "WSDataSourceManager.h"
#import "WSAcvtModel.h"
#import "WSBaseOptionDataItem.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "WSBaseDictsDBService.h"
#import "WSMutilevelMenuDataTool.h"

#define defaultString           NSLocalizedString(@"please_select", nil)
#define kWidthRatio             (INTERFACE_IS_PHONE ? 1.0 : 0.5)
#define kRemoteSearchNotify     @"DropListRemoteSearch"
#define kTipsArrowWH            10
#define kTipsHeight             132

//static NSInteger const showSearchBarCount = 10;

//static NSInteger const popShowCount = 6;


@interface WSDropListView ()<WSHeaderSearchViewDelegate,WSDropListViewMultilevelMenuDelegate>
{
    CGFloat _listPanelFirstHeight;
    NSInteger _levelNumber;//有多少层级
    WSMutilevelMenuDataTool *dataTool;
}
@property (nonatomic, strong) UIButton *titleButton;
@property (nonatomic, strong) UIButton *arrowButton;
@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) WSDropListViewMultilevelMenu *countryAdministrationListView;
@property (nonatomic, strong) UIView *listPanel;
@property (nonatomic, strong) UIView *listShadowView;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic,assign)  CGFloat sourceTableMoveHeight;

@property (nonatomic, strong) NSArray    *filterItems;

@property (nonatomic, strong) UIView    *lineView;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, strong) UIViewController *contentViewController;

@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) UIButton *delButton;
@property (nonatomic, strong) UIView *tipsView;
@property (nonatomic, strong) CALayer *arrowLayer;

@property (nonatomic, strong) WSHeaderSearchView *headerSearchView;
@property (nonatomic, strong) MBProgressHUD *longPressHud;

@end


@implementation WSDropListView

- (id)initWithFrame:(CGRect)frame selectMode:(WSDropListViewSelectMode)selectMode
{
    self = [super initWithFrame:frame selectMode:selectMode];
    if (self) {
        
        self.isParentSelected = YES;
        
        //        CGFloat height = CHECK_LIST_CELL_HEIGHT;
        _titleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        
        //        UIColor *mainTintColor = MAIN_TINT_COLOT;
        //        if (!mainTintColor) {
        //            mainTintColor = [UIColor colorWithHexString:@"#00b4ff"];
        //        }
   
        _titleButton.backgroundColor = [UIColor clearColor];
        //        _titleButton.layer.cornerRadius = self.frame.size.height/3;
        //        _titleButton.layer.masksToBounds = YES;
        //        _titleButton.titleLabel.textColor=[UIColor blackColor];
        
        [_titleButton setTitleColor:PanelTextFieldColor forState:UIControlStateNormal];
        [_titleButton setTitleColor:PanelTextFieldColorReadonly forState:UIControlStateDisabled];
        _titleButton.titleLabel.font = PanelTextFieldFont;
        
        // SFA 联合利华 SFALHLH-1650  目前暂定位两行，后期不适应再重新设计
        _titleButton.titleLabel.numberOfLines = 2;
        [_titleButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        _titleButton.adjustsImageWhenHighlighted = NO;
        _titleButton.adjustsImageWhenDisabled = NO;
        /*Jira - SFA-13822 2017-11-6 create by  说要改 又改回去自动所缩放了 孙洪福*/
        _titleButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_titleButton addTarget:self action:@selector(titleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _titleButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self addSubview:_titleButton];
        
        // MSTD-6628 添加一个按钮为了实现对齐
        _arrowButton = [[UIButton alloc] initWithFrame:CGRectMake(self.width - MAIN_CELL_BUTTON_WH, 0, MAIN_CELL_BUTTON_WH, self.height)];
        [_arrowButton setImage:[UIImage imageNamed:@"downarrow"] forState:UIControlStateNormal];
        [_arrowButton setImage:[UIImage imageNamed:@"downarrow_disable"] forState:UIControlStateDisabled];
        [_arrowButton addTarget:self action:@selector(titleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - MAIN_CELL_SEPERATOR_LENGTH) / 2, 1, MAIN_CELL_SEPERATOR_LENGTH)];
        line.backgroundColor = DETAIL_SEPERATE_LINE_COLOR;
        [_arrowButton addSubview:line];
        _lineView = line;
        
        [self addSubview:_arrowButton];
        
        [self updateButtonTitle];
        
        // MMSH-3217
        if (self.selectMode == WSDropListViewSelectModeSingleSelection) {
            UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
            [self addGestureRecognizer:longPressGesture];
        }
        
    }
    return self;
}

- (void)layoutSubviews
{
    if (self.sourceTableReadOnly && _isInGroup) {
        _titleButton.frame = CGRectMake(0, 0, self.width - MAIN_PADDING, self.height);
        [_arrowButton setHidden:YES];
    }
    else
    {
        //MNXHJH-69 2018-03-30
        if (self.sourceTableReadOnly  && self.isParentSelected)
        {
            [_arrowButton setHidden:YES];
            _titleButton.frame = CGRectMake(MAIN_PADDING / 2, 0, self.width - MAIN_PADDING, self.height);
            return;
        } else {
            [_arrowButton setHidden:NO];
        }
        
        if(_isInGrid){
            CGFloat arrowGridWidth = MAIN_SMALL_BUTTON_WIDTH;
            CGFloat titleWidth = self.width - arrowGridWidth;
            [_titleButton setFrame:CGRectMake(0, 0, titleWidth - MAIN_TEXT_IMG_PADDING, self.height)];
            [_arrowButton setFrame:CGRectMake(titleWidth, 0, arrowGridWidth, self.height)];
        } else {
            CGFloat arrowGridWidth = MAIN_CELL_BUTTON_WH;
            CGFloat titleWidth = self.width - arrowGridWidth;
            _titleButton.frame = CGRectMake(0, 0, titleWidth - MAIN_PADDING, self.height);
            [_arrowButton setFrame:CGRectMake(titleWidth, 0, arrowGridWidth, self.height)];
        }
    }
}

- (void)titleButtonClicked:(id)sender
{
    if ([self.dataSourceArray count] == 0 && self.selectType != WSDropListViewTypeServerSearchBarShow) {
        return;
    }
    
    self.filterItems = self.dataSourceArray;
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    if (self.selectType == WSDropListViewTypePopShow) {
        if([self.dropListDelegate respondsToSelector:@selector(popupDropListViewDidAppear:)]){
            [self.dropListDelegate popupDropListViewDidAppear:self];
        }
        return;
    }
    self.hidden = YES;
    UIWindow *wc = [[[UIApplication sharedApplication] windows] firstObject];
    UIViewController *rootViewController = wc.rootViewController;
    if (rootViewController.presentedViewController) {
        rootViewController = rootViewController.presentedViewController;
    }
    if (rootViewController.presentedViewController) {
        rootViewController = rootViewController.presentedViewController;
    }
    UIView* rootView = rootViewController.view;
    
    [self.backView removeFromSuperview];
    [self.listPanel removeFromSuperview];
    [self disableContent];
    
    
    
    //    if (self.selectType == WSDropListViewTypeSearchBarShow) {
    //        self.listTableView.tableHeaderView = [self getTableHeaderView];
    //    }else {
    //        self.listTableView.tableHeaderView = nil;
    //    }
    
    if (self.sourceTableReadOnly) {
        self.listTableView.userInteractionEnabled = NO;
    }else {
        self.listTableView.userInteractionEnabled = YES;
    }
    
    
    
    //    CGPoint point = rect.origin;
    //    point = [[self superview] convertPoint:point toView:rootView];
    //    rect.origin = point;
    //    rect.size.width = self.width;
    //
    //    rect.size.height = [self getCellCount] * CHECK_LIST_CELL_HEIGHT;
    //
    //    CGFloat topSpaceHeight = rect.origin.y - 64 - 5 + CHECK_LIST_CELL_HEIGHT;
    //    CGFloat downSpaceHeight = 0.f;
    //    if (!IOS7_OR_LATER) {
    //        downSpaceHeight = rootView.width - rect.origin.y - 5;
    //    }
    //    else{
    //        downSpaceHeight = rootView.height - rect.origin.y - 5;
    //
    //    }
    //
    //    if (downSpaceHeight < rect.size.height) {
    //
    //        if (topSpaceHeight >= rect.size.height) {
    //            rect.origin.y -= rect.size.height - CHECK_LIST_CELL_HEIGHT;
    //        }else {
    //            if (downSpaceHeight > topSpaceHeight){
    //                rect.size.height = downSpaceHeight;
    //            }else {
    //                rect.size.height = topSpaceHeight;
    //                rect.origin.y -= rect.size.height - CHECK_LIST_CELL_HEIGHT;
    //            }
    //        }
    //    }
    //
    //    self.listTableView.frame = rect;
    //    self.listShadowView.frame = rect;
    
    if (_backView == nil)
    {
        _backView = [[UIView alloc] initWithFrame:rootView.bounds];
        [_backView setBackgroundColor:POP_WINDOW_BG_COLOR];
        
        //        if (self.selectMode == WSDropListViewSelectModeSingleSelection) {
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touch)];
        [tapRecognizer setNumberOfTapsRequired:1];
        [tapRecognizer setNumberOfTouchesRequired:1];
        [_backView addGestureRecognizer:tapRecognizer];
        //        }
    }
    
    
    //    [rootView addSubview:self.listShadowView];
    //    [rootView addSubview:self.listTableView];
    //    [rootView bringSubviewToFront:self.listShadowView];
    //    [rootView bringSubviewToFront:self.listTableView];
    
    [self setListPanelFrame];
    
    if (INTERFACE_IS_PHONE) {
        [rootView addSubview:_backView];
        [self showListPanelToView:rootView];
        [rootView bringSubviewToFront:self.listPanel];
    } else {
        UIButton *btn = (UIButton *)sender;
        [self popListPanelToBtn:btn];
    }
    
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)rootViewController;
        if (IOS7_OR_LATER) {
            navController.interactivePopGestureRecognizer.enabled = NO;
        }
    }
    
    self.isShow = YES;
    if (self.dropListDelegate && [self.dropListDelegate respondsToSelector:@selector(dropListViewDidAppear:)])
    {
        [self.dropListDelegate performSelector:@selector(dropListViewDidAppear:) withObject:self];
    }
    self.listTableView.contentOffset = CGPointMake(0, 0);
    
    [self.listTableView reloadData];
    
    self.tempSelectedItemArray = [self.selectedItemArray mutableCopy];
    /*MSTD-6893 create by sunhongfu */
    //    self.listTableView.tableHeaderView = [self getTableHeaderView];
}

- (NSInteger)getMultilevelMenuCount
{
    if (self.multileveMenuArray.count > 1)
    {
        NSMutableArray *firstArray = self.multileveMenuArray[0];
        NSMutableArray *secondArray = self.multileveMenuArray[1];
        if (firstArray.count > secondArray.count)
        {
            return firstArray.count;
        }
        else
        {
            return secondArray.count;
        }
    }
    return self.multileveMenuArray.count;
}

- (void)setListPanelFrame {
    BOOL isShowButton = NO;
    CGFloat buttonHeight = 0;
    if (self.selectMode == WSDropListViewSelectModeMultipleChoice) {
        isShowButton = YES;
        buttonHeight = MAIN_CELL_HEIGHT;
    }
    
    CGFloat paddingX = 0;
    CGFloat width = SCREEN_WIDTH * kWidthRatio;
    CGFloat height;
    
    CGFloat maxHeight = POP_VIEW_MAX_HEIGHT;
    if (self.selectType != WSDropListViewTypeServerSearchBarShow) {
        height = [self getCellCount] * MAIN_CELL_HEIGHT;
        // SFA-18835 如果是多选有底下btn的情况则此处加上底下btn的高度
        height += buttonHeight;
    } else {
        height = maxHeight;
    }
    
    if (self.selectType == WSDropListViewTypeSearchBarShow
        || self.selectType == WSDropListViewTypeServerSearchBarShow) {
        maxHeight += MAIN_CELL_HEIGHT;
    }
    
    //是否是使用多级菜单,使用多级菜单需要个性化计算高度
    if (self.multileveMenuArray.count && self.isUseMultilevelMenu)
    {
        //        height = [self getMultilevelMenuCount]*MAIN_CELL_HEIGHT;
        height = SCREEN_HEIGHT/2;
        
    }
    
    if (height > maxHeight) {
        height = maxHeight;
    }
    
    CGFloat tableHeight = height;
    
    if (self.selectType == WSDropListViewTypeSearchBarShow
        || self.selectType == WSDropListViewTypeServerSearchBarShow) {
        tableHeight -= MAIN_CELL_HEIGHT;
    }
    
    if (isShowButton) {
//        height += buttonHeight;
        tableHeight -= buttonHeight;
        
    }
    
    CGFloat paddingY = (SCREEN_HEIGHT - height);
    
    // 状态栏高度变为40需要调整Y的偏移量
    CGRect statusBarRect = [[UIApplication sharedApplication] statusBarFrame];
    int shouldBeSubtractionHeight = 0;
    if (statusBarRect.size.height == 40) {
        shouldBeSubtractionHeight = 20;
    }
    
    if ([self getCellCount] * MAIN_CELL_HEIGHT > tableHeight) {
        // 为了让箭头和表格内容不重合
        CGFloat padding = MAIN_PADDING;
        height += padding;
        paddingY -= padding;
        CGRect viewRect = CGRectMake(0, height - kTipsHeight - buttonHeight, width, kTipsHeight);
        [self.tipsView setFrame:viewRect];
        [_listPanel addSubview:self.tipsView];
        [self arrowAnim];
    } else {
        [self.tipsView removeFromSuperview];
    }
    
    _listPanelFirstHeight = height;
    
    paddingY -= shouldBeSubtractionHeight;
    
    CGRect panelFrame = CGRectMake(paddingX, paddingY, width, height);
    self.listPanel.frame = panelFrame;
    //YIHAIKERRY-4131
    if (self.selectType == WSDropListViewTypeSearchBarShow
        || self.selectType == WSDropListViewTypeServerSearchBarShow) {
        self.listTableView.frame = CGRectMake(0, MAIN_CELL_BUTTON_WH, width, tableHeight);
    } else {
        self.listTableView.frame = CGRectMake(0, 0, width, tableHeight);
    }
    
    /*判断是否使用多级菜单  SFA 玛氏  */
    if (self.isUseMultilevelMenu)
    {
        _listTableView.hidden = YES;
        [self.listPanel addSubview:[self getTableHeaderView]];
        [_listPanel addSubview: self.countryAdministrationListView];
    }
    
    if (isShowButton) {
        CGFloat buttonWidth = 60;
        
        if (!self.delButton) {
            UIFont *font = [UIFont systemFontOfSize:UI_Font];
            NSString *okTitle = NSLocalizedString(@"delete_label", nil);
            UIButton *delButton = [[UIButton alloc] init];
            [delButton.titleLabel setFont:font];
            [delButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
            [delButton setTitleColor:MAIN_TINT_COLOR forState:UIControlStateNormal];
            [delButton setTitleColor:[MAIN_TINT_COLOR colorWithAlphaComponent:ALPHA_DISABLED] forState:UIControlStateDisabled];
            [delButton setTitle:okTitle forState:UIControlStateNormal];
            [delButton setBackgroundColor:[UIColor whiteColor]];
            [delButton addTarget:self action:@selector(delAction) forControlEvents:UIControlEventTouchUpInside];
            self.delButton = delButton;
        }
        
        
        if (!self.okButton) {
            UIFont *font = [UIFont systemFontOfSize:UI_Font];
            NSString *okTitle = NSLocalizedString(@"confirm", nil);
            UIButton *okButton = [[UIButton alloc] init];
            [okButton.titleLabel setFont:font];
            [okButton.titleLabel setTextAlignment:NSTextAlignmentRight];
            [okButton setTitleColor:MAIN_TINT_COLOR forState:UIControlStateNormal];
            [okButton setTitleColor:[MAIN_TINT_COLOR colorWithAlphaComponent:ALPHA_DISABLED] forState:UIControlStateDisabled];
            [okButton setTitle:okTitle forState:UIControlStateNormal];
            [okButton setBackgroundColor:[UIColor whiteColor]];
            [okButton addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
            self.okButton = okButton;
        }
        
        if (self.isScrollToBottomToEnableButton) {
            if ([self getCellCount] * MAIN_CELL_HEIGHT > tableHeight) {
                [self.okButton setEnabled:NO];
                [self.delButton setEnabled:NO];
            } else {
                self.isScrollToBottomToEnableButton = NO;
            }
        }
        
        [self.delButton setFrame:CGRectMake(0, height - buttonHeight, buttonWidth, buttonHeight)];
        [self.okButton setFrame:CGRectMake(_listPanel.width - buttonWidth, height - buttonHeight, buttonWidth, buttonHeight)];
        [_listPanel addSubview:self.okButton];
        [_listPanel addSubview:self.delButton];
        
    }else {
        [self.okButton removeFromSuperview];
        [self.delButton removeFromSuperview];
    }
}

- (void)showListPanelToView:(UIView *)rootView {
    [rootView addSubview:self.listPanel];
    
    CGRect panelFrame = self.listPanel.frame;
    self.listPanel.frame = CGRectMake(0, SCREEN_HEIGHT, panelFrame.size.width, panelFrame.size.height);
    [UIView animateWithDuration:MAIN_ANIM_DURATION animations:^{
        self.listPanel.frame = panelFrame;
    }];
}

- (void)popListPanelToBtn:(UIButton *)btn {
    if (!self.popoverController) {
        UIViewController *contentController = [[UIViewController alloc] init];
        contentController.view  = self.listPanel;
        self.contentViewController = contentController;
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:contentController];
    }
    self.contentViewController.preferredContentSize = self.listPanel.bounds.size;
    /*SFA-14812 create by sunhongfu */
    UIImageView *btnImageView = self.arrowButton.imageView;
    [self.popoverController presentPopoverFromRect:btnImageView.bounds inView:btnImageView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)hideListPanel {
    if (INTERFACE_IS_PHONE) {
        CGRect panelFrame = self.listPanel.frame;
        
        [UIView animateWithDuration:MAIN_ANIM_DURATION animations:^ {
            self.listPanel.frame = CGRectMake(0, SCREEN_HEIGHT, panelFrame.size.width, panelFrame.size.height);
        }completion:^(BOOL finished) {
            [self.backView removeFromSuperview];
            [self.listPanel removeFromSuperview];
        }];
    } else {
        [self.popoverController dismissPopoverAnimated:YES];
    }
}

- (void)setIsInGrid:(BOOL)isInGrid
{
    _isInGrid = isInGrid;
    if (isInGrid) {
        [_lineView removeFromSuperview];
    }
}

- (void)setFont:(UIFont *)font
{
    [_titleButton.titleLabel setFont:font];
}

- (NSInteger)getCellCount
{
    NSInteger count = self.filterItems.count;
    
    //    if (self.selectType != WSDropListViewTypeSearchBarShow) {
    //        count += 1;
    //    }
    return count;
}

- (void)updateButtonTitle
{
    NSString *title;
    if ([self.dataSourceArray count] == 0 && self.isParentSelected) {
        title = NSLocalizedString(@"no_option", nil);
    }else {
        title = [self getSelectedContentString];
    }
    [_titleButton setTitle:title forState:UIControlStateDisabled];
    [_titleButton setTitle:title forState:UIControlStateNormal];
}

- (void)setSourceTableReadOnly:(BOOL)sourceTableReadOnly {
    [super setSourceTableReadOnly:sourceTableReadOnly];
    
    [_titleButton setEnabled:!sourceTableReadOnly];
    [_arrowButton setEnabled:!sourceTableReadOnly];
    //SFA-24196
    [self setTableHeader];
}

- (NSString *)getSelectedContentString
{
    NSString *result = nil;
    
    if (self.selectMode == WSDropListViewSelectModeSingleSelection) {
        if(self.selectedItem){
            NSString *resultId = [self.selectedItem getDataItemID];
            if ([resultId isEqualToString:kCancelItemId]) {
                result = [self getDefaultString];
            }else {
                result = [self.selectedItem getDataItemName];
            }
        }else{
            result = [self getDefaultString];
        }
    }
    else if (self.selectMode == WSDropListViewSelectModeMultipleChoice)
    {
        if ([self.selectedItemArray count] > 0) {
            if (self.isInGrid) {
                NSMutableArray *contentArray = [NSMutableArray array];
                for (NSObject<I_W_OptionDataItem> *dataItem in self.selectedItemArray) {
                    [contentArray addObject:[dataItem getDataItemName]];
                }
                result = [contentArray componentsJoinedByString:@","];
            }
            // MN-2305 去掉已选择提示
//            else {
//                result = NSLocalizedString(@"selected", nil);
//            }
        }
        else
        {
            result = [self getDefaultString];
        }
        
    }
    
    return result;
}


- (void)touch
{
    self.headerSearchView.searchBar.searchBar.text = @"";
    [self hideListPanel];
    [self disableContent];
}


- (void)disableContent {
    [self moveSourceTableDown];
    //    [self.listShadowView removeFromSuperview];
    //    [self.listTableView removeFromSuperview];
    
    self.hidden = NO;
    
    UIWindow *wc = [[[UIApplication sharedApplication] windows] firstObject];
    UIViewController *rootViewController = wc.rootViewController;
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)rootViewController;
        if (IOS7_OR_LATER) {
            navController.interactivePopGestureRecognizer.enabled = YES;
        }
    }
}

// 如果下拉框内容被遮挡 上移后 下拉框在消失 父视图回到的正常frame的方法
- (void)moveSourceTableDown {
    if ((_listTableView.frame.origin.y + _listTableView.size.height + self.sourceTableMoveHeight) > [self superview].height) {
        [UIView animateWithDuration:0.2 animations:^{
            
            UIView *superView = [self superview];
            [superView setFrame:CGRectMake(superView.frame.origin.x, superView.frame.origin.y + self.sourceTableMoveHeight, superView.frame.size.width, superView.frame.size.height)];
            
            [_listTableView setFrame:CGRectMake(_listTableView.frame.origin.x, _listTableView.frame.origin
                                                .y + self.sourceTableMoveHeight, _listTableView.frame.size.width, _listTableView.frame.size.height)];
        } completion:nil];
    }
}

- (void)setUpSelectionByItemIDArray:(NSArray *)dataItemIDArray
{
    [super setUpSelectionByItemIDArray:dataItemIDArray];
    
    [self updateButtonTitle];
    [self.listTableView reloadData];
}

- (void) closeSelectList
{
    if(!self.isShow)
    {
        return ;
    }
    self.isShow = NO;
    [self.backView removeFromSuperview];
    [self.listTableView removeFromSuperview];
}


- (void)setSelectedItem:(NSObject<I_W_OptionDataItem> *)selectedItem {
    //MMSH-5031 董宏 重置数据源
    //SFA 项目SFA-22484 【SFA泸州老窖】【iOS】新增终端时，选择产品小类时闪退
    if(selectedItem && self.isUseMultilevelMenu )
    {
        NSMutableArray *dataArray = [NSMutableArray arrayWithObject:selectedItem];
        [self getMultilevelMenuWithDataSourceArray:dataArray];
    }
    [super setSelectedItem:selectedItem];
    [self updateButtonTitle];
}


- (void)setSelectedItemArray:(NSMutableArray *)selectedItemArray {
    [super setSelectedItemArray:selectedItemArray];
    
    [self updateButtonTitle];
    [self.listTableView reloadData];
}

- (NSString *)getDefaultString
{
    if (_isInGrid)  return @"";
    
    return defaultString;
}

- (void) flushTable
{
    if (self.listTableView) {
        [self.listTableView reloadData];
    }
    
}

- (void)setDataSourceArray:(NSArray *)dataSourceArray {
    [super setDataSourceArray:dataSourceArray];
    
    _filterItems = dataSourceArray;
    
    [self updateButtonTitle];
    [self setTableHeader];
    if (self.isUseMultilevelMenu) {
        [self getMultilevelMenuWithDataSourceArray:(NSMutableArray *)dataSourceArray];
    }
}

- (void)getMultilevelMenuWithDataSourceArray:(NSMutableArray *)dataSourceArray
{
    //判断使用多级菜单时候  获得需要显示默认时候各级菜单数据
    if (dataSourceArray.count)
    {
        if ([dataSourceArray.firstObject isKindOfClass:[WSDictBean class]])
        {
            [self.multileveMenuArray removeAllObjects];
            [self.backShowLevelDataArray removeAllObjects];
            if (!dataTool)
            {
                dataTool = [[WSMutilevelMenuDataTool alloc] init];
            }
            [self.multileveMenuArray addObjectsFromArray:[dataTool getMutilevelMenuDataWith:(NSMutableArray *)dataSourceArray]];
            [self.backShowLevelDataArray addObjectsFromArray:dataTool.defaultSelectedLevleDataArray];
            //一共有多少层级
            _levelNumber = dataTool.maxLevelNumber;
        }
    }
}

- (NSMutableArray *)multileveMenuArray
{
    if (!_multileveMenuArray) {
        _multileveMenuArray = [NSMutableArray array];
    }
    return _multileveMenuArray;
}

- (NSMutableArray *)backShowLevelDataArray
{
    if (!_backShowLevelDataArray) {
        _backShowLevelDataArray = [NSMutableArray array];
    }
    return _backShowLevelDataArray;
}


- (void)setSelectType:(WSDropListViewType)selectType {
    [super setSelectType:selectType];
    
    if (selectType == WSDropListViewTypeServerSearchBarShow ||
        selectType == WSDropListViewTypeSearchBarShow) {
        [self setTableHeader];
        if (selectType == WSDropListViewTypeServerSearchBarShow) {
            [_titleButton setTitle:@"" forState:UIControlStateNormal];
        }
    }
}

- (void)setTableHeader {
    //YIHAIKERRY-4205 益海嘉里-上海：客户信息：省为北京市后，市下拉框没有选项，为空 (搜索框把第一条数据的位置给占用了)
    // SFA-4713 iOS 8 使用 viewForHeaderInSection 方式设置，会导致搜索框内输入文字后，刷新列表搜索框文字不显示
    if (self.selectType == WSDropListViewTypeSearchBarShow ||
        self.selectType == WSDropListViewTypeServerSearchBarShow) {
        if (!self.headerSearchView) {
            [self fixedTableHeaderView];
        }
    } else {
        if (self.headerSearchView) {
            [self.headerSearchView removeFromSuperview];
            self.headerSearchView= nil;
        }
//        self.listTableView.tableHeaderView = nil;
    }
}

- (void)confirmAction {
    [self touch];
    
    self.selectedItemArray = [self.tempSelectedItemArray mutableCopy];
}

- (void)delAction {
    [self setUpSelectionByItemIDArray:nil];
}


#pragma mark - Gesture
- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSString *tip = [self getSelectedContentString];
        if ([tip length] > 0 && ![tip isEqualToString:defaultString]) {
            self.longPressHud = [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tip tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeText];
        }
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self.longPressHud hide:YES];
    }
}


#pragma mark - UITableViewDelegate, UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return MAIN_CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self getCellCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isMultiChoice = NO;
    if (self.selectMode == WSDropListViewSelectModeMultipleChoice) {
        isMultiChoice = YES;
    }
    static NSString *identify = @"dropListTableViewCell";
    WSDropListCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil)
    {
        cell = [[WSDropListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identify isMultiChoice:isMultiChoice];
    }
    cell.accessoryView = nil;
    cell.backgroundColor = [UIColor clearColor];
    cell.markImageView.image = nil;
    NSInteger index = indexPath.row;
    BOOL isSelected = NO;
    NSObject<I_W_OptionDataItem> *dataItem = [self.filterItems objectAtIndex:index];
    
    if (self.selectMode == WSDropListViewSelectModeSingleSelection) {
        if (self.selectedItem == dataItem) {
            isSelected = YES;
        }
    }
    else if (self.selectMode == WSDropListViewSelectModeMultipleChoice) {
        if ([self.tempSelectedItemArray containsObject:dataItem]) {
            isSelected = YES;
        }
    }
    [cell setDataItem:dataItem isSelected:isSelected];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id<I_W_OptionDataItem> dataItem ;
    if (self.selectMode == WSDropListViewSelectModeSingleSelection) {
        
        NSInteger index =  [indexPath row];
        
        if (self.filterItems.count > index) {
            dataItem  = [self.filterItems objectAtIndex:index];
        }
        [self cellDidClickWithParam:dataItem];
    }
    else if (self.selectMode == WSDropListViewSelectModeMultipleChoice)
    {
        
        
        if (self.filterItems.count > [indexPath row]) {
            dataItem  =  [self.filterItems objectAtIndex:[indexPath row]];
        }
        if (![self.tempSelectedItemArray containsObject:dataItem]) {
            
            NSInteger maxCount = 0;
            if (self.limitNum && [self.limitNum integerValue] > 0) {
                maxCount = [self.limitNum integerValue];
            } else if (self.maxNum > 0) {
                maxCount = self.maxNum;
            }
            
            if (maxCount > 0 && ([self.tempSelectedItemArray count] >= maxCount)) {
                NSString *tips =[NSString stringWithFormat:NSLocalizedString(@"select_the_maximum_number_is", nil), (long)maxCount];
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:nil tips:tips tapTarget:self action:nil type:MBProgressHUDMessageTypeFailed autoHideTime:1.5f];
                return;
            }
        }
        
        if (![self.tempSelectedItemArray containsObject:dataItem])
        {
           
//            MN-2307
//            蒙牛(ios)-拜访-进店后结束拜访点击下次提醒，选项显示顺序，如图按原顺序显示，不需要按选择顺序显示（效率有点低，以后有好的方法可以修改）
            if ([dataItem isKindOfClass:[WSDictBean class]]) {
                WSDictBean *currentDictBean = (WSDictBean *)dataItem;
                NSString *currentDicts_sequence = currentDictBean.dicts_sequence;
                  BOOL insertSuccess = NO;
                for (NSInteger i =0; i < self.tempSelectedItemArray.count; i++ ) {
                     WSDictBean * dictBean = self.tempSelectedItemArray[i];
                    if ([currentDicts_sequence integerValue] < [dictBean.dicts_sequence integerValue]) {
                       [self.tempSelectedItemArray insertObject:currentDictBean atIndex:i];
                        insertSuccess = YES;
                        break;
                    }
                }
                    if (!insertSuccess) {
                        [self.tempSelectedItemArray addObject:dataItem];
                    }
                
            } else {
                // SFA-22364
                //  【SFA泸州老窖】【iOS】添加参与人时，无法选择参与人
                [self.tempSelectedItemArray addObject:dataItem];
            }
        }
        else
        {
            [self.tempSelectedItemArray removeObject:dataItem];
        }
        
        self.isValueChange = YES;
        
        //        if (self.dropListDelegate && [self.dropListDelegate respondsToSelector:@selector(dropListViewDidChangeSelect:)])
        //        {
        //            [self.dropListDelegate performSelector:@selector(dropListViewDidChangeSelect:) withObject:self];
        //        }
    }
    
    // 实时请求的数据在选中后入库，上传后再次进入才能获取到对应的名字
    if (self.selectType == WSDropListViewTypeServerSearchBarShow) {
        NSDictionary *dic = @{@"type":self.searchObjId,
                              @"item1": [dataItem getDataItemID],
                              @"item2": [dataItem getDataItemName]};
        WSBaseStoreOtherDataDBService *dataService = [[WSBaseStoreOtherDataDBService alloc] init];
        [dataService insertOrUpdateStoreWithDataDic:dic];
    }
    
    [self updateButtonTitle];
    [self.listTableView reloadData];
    
    self.headerSearchView.searchBar.searchBar.text = @"";
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isScrollToBottomToEnableButton) {
        CGFloat height = scrollView.frame.size.height;
        CGFloat contentYoffset = scrollView.contentOffset.y;
        CGFloat bottomOffset = scrollView.contentSize.height - contentYoffset - MAIN_TEXT_IMG_PADDING;
        if (bottomOffset <= height) {
            // 滚动到底部
            [self.okButton setEnabled:YES];
            [self.delButton setEnabled:YES];
            self.isScrollToBottomToEnableButton = NO;
        }
    }
    
    if (self.tipsView) {
        [self.tipsView setHidden:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self hideTipsView:scrollView];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self hideTipsView:scrollView];
}

- (void)hideTipsView:(UIScrollView *)scrollView {
    if (self.tipsView) {
        CGFloat height = scrollView.frame.size.height;
        CGFloat contentYoffset = scrollView.contentOffset.y;
        CGFloat bottomOffset = scrollView.contentSize.height - contentYoffset - MAIN_TEXT_IMG_PADDING;
        if (bottomOffset <= height) {
            // 滚动到底部
            [self.tipsView setHidden:YES];
        } else {
            [self.tipsView setHidden:NO];
        }
    }
}

- (void)setLimitNum:(NSString *)limitNum {
    [super setLimitNum:limitNum];
    
    [self updateButtonTitle];
    [self.listTableView reloadData];
}


#pragma mark - WSValidateData

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.headerSearchView) {
        self.headerSearchView.delegate = nil;
    }
    
}

- (void)setNotificationPrefix:(NSString *)aNotificationPrefix
                       andRow:(unsigned int)aRow
                    andColumn:(unsigned int)aColumn
                  andDataType:(WSValidateDataDependType)aDataType
{
    //    NSLog(@"%d--%s---%p", __LINE__, __FUNCTION__,self);
    
    if (aNotificationPrefix == nil) return;
    
    self.iNotificationPrefix = aNotificationPrefix;
    //    self.iRow = aRow;
    //    self.iColumn = aColumn;
    self.m_nRow = aRow;
    self.m_nColumn = aColumn;
    self.iDataType = aDataType;
    
    if (self.iDataType == WSValidateDataDependOtherData){
        NSString *notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.iNotificationPrefix, aRow, aColumn];
        //        NSLog(@"notifyname = %@", notifyName);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateState:) name:notifyName object:nil];
    }
}

- (void)startObservingEntity
{
    //    NSLog(@"%s---%d", __FUNCTION__, __LINE__);
}

- (void)updateState:(NSNotification *)sender
{
    //    NSLog(@"%d--%s--%p", __LINE__, __FUNCTION__,self);
    NSString *notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.iNotificationPrefix, self.m_nRow, self.m_nColumn];
    if (sender.name != nil && [sender.name isEqualToString:notifyName]) {
        NSNumber *number = (NSNumber *)sender.object;
        BOOL isEnable = [number boolValue];
        self.userInteractionEnabled = isEnable;
        self.alpha = isEnable ? 1.0 : 0.5;
    }
}


- (BOOL)entityIsEnable
{
    return self.isUserInteractionEnabled;
}

- (NSString *)getTextValue
{
    
    return [self getResultDirectly];
}

- (BOOL)isValueLegal
{
    return ([self getTextValue] != nil && [[self getTextValue] length] > 0) ? YES : NO;
}

- (BOOL)textCheck
{
    
    return YES;
}


- (NSArray *)searchItemByKeyword:(NSString *)keywordString{
    
    if (keywordString == nil) {
        return self.dataSourceArray;
    }
    
    //去除字符串两边的空格
    keywordString = [keywordString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //只有空格 不作为
    if ([keywordString isEqualToString:@""]) {
        return self.dataSourceArray;
    }
    
    NSArray *keywordArray = [keywordString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSMutableArray *resultArray = [NSMutableArray array];
    
    if ([keywordArray count] > 0) {
        
        for (NSObject<I_W_OptionDataItem> *dataItem in self.dataSourceArray) {
            NSString *name = [dataItem getDataItemName];
            // SFA-25363 过滤掉名称为空的数据
            if ([name length] > 0) {
                BOOL isMatch = YES;
                for (NSString *keyword in keywordArray) {
                    if ([name rangeOfString:keyword options:NSCaseInsensitiveSearch].location == NSNotFound) {
                        isMatch = NO;
                        break;
                    }
                }
                if (isMatch) {
                    [resultArray addObject:dataItem];
                }
            }
        }
    }
    
    if ([resultArray count] > 0) {
        return resultArray;
    }
    else {
        return [self getFilterStoreCodeDataItemWithKeywordArray:keywordArray];
    }
    
}

// SFA-18226 新增根据门店编码本地模糊搜索过滤数据的逻辑
- (NSArray *)getFilterStoreCodeDataItemWithKeywordArray:(NSArray *)keywordArray
{
    NSMutableArray *resultArray = [NSMutableArray array];

    if ([keywordArray count] > 0) {
        if (self.dataSourceArray.count > 0 && [[self.dataSourceArray firstObject] isKindOfClass:[WSStoreBean class]]) {
            for (NSObject<I_W_OptionDataItem> *dataItem in self.dataSourceArray) {
                if ([dataItem isKindOfClass:[WSStoreBean class]]) {
                    WSStoreBean *storeBean = (WSStoreBean *)dataItem;
                    
                    NSString *code = [storeBean code];
                    BOOL isMatch = YES;
                    for (NSString *keyword in keywordArray) {
                        if ([code rangeOfString:keyword options:NSCaseInsensitiveSearch].location == NSNotFound) {
                            isMatch = NO;
                            break;
                        }
                    }
                    if (isMatch) {
                        [resultArray addObject:dataItem];
                    }
                }
                
            }
        }
    }
    
    if ([resultArray count] > 0) {
        return [NSArray arrayWithArray:resultArray];
    }
    else {
        return nil;
    }
    
}

- (NSString *) getIsSearchableMethod{
    NSString *isSearchable;
    if (self.selectType != WSDropListViewTypeServerSearchBarShow) {
        isSearchable = FUNCS_OPT_Local;
    } else {
        isSearchable = FUNCS_OPT_Remote;
    }
    
    
    if (self.isUseMultilevelMenu)
    {
        isSearchable = FUNCS_OPT_MultilevelMenuSearch;
    }
    return isSearchable;
}
// YIHAIKERRY-3807 zhaodanyang
- (void) fixedTableHeaderView{
    NSString *isSearchable = [self getIsSearchableMethod];
    
    // 暂时不需要设置
    NSString *searchTag = @"";
    //    SFA-17054 SFA辉瑞医院--ipad端院内拜访中“拜访医生”问卷中搜索图标不居中显示
    WSHeaderSearchView *headerSearchView = [[WSHeaderSearchView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH * kWidthRatio, MAIN_CELL_HEIGHT) funcs:nil isSearchable:isSearchable searchTag:searchTag nativeStoreList:self.dataSourceArray];
    headerSearchView.delegate = self;
    self.headerSearchView = headerSearchView;
    [self.listPanel addSubview:headerSearchView];
}


- (UIView *)getTableHeaderView {
    // MN-2441 只读不需要搜索
    if (self.sourceTableReadOnly) {
        return nil;
    }
    
    //MSTD-6975 2017-11-20
    //    SFA-16547
    //    SFA-戴森--ios端--门店拜访--苏宁测试门店--产品库存管理模块--添加产品之后--点击调至门店按钮，应该是下拉框收索，现在没有收索框 把下面两行代码先给注释了
    //    if((([self getCellCount] * MAIN_CELL_HEIGHT) < (CGRectGetHeight(self.listTableView.frame) * 2)) && !self.listTableView.hidden)
    //        return nil;
    
    NSString *isSearchable = [self getIsSearchableMethod];

    // 暂时不需要设置
    NSString *searchTag = @"";
//    SFA-17054 SFA辉瑞医院--ipad端院内拜访中“拜访医生”问卷中搜索图标不居中显示
    WSHeaderSearchView *headerSearchView = [[WSHeaderSearchView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH * kWidthRatio, MAIN_CELL_HEIGHT) funcs:nil isSearchable:isSearchable searchTag:searchTag nativeStoreList:self.dataSourceArray];
    headerSearchView.delegate = self;
    self.headerSearchView = headerSearchView;
    return headerSearchView;
}

- (void)cancelSearch {
    self.filterItems = self.dataSourceArray;
    [self.listTableView reloadData];
}

- (void)remoteSearchByKeyword:(NSString *)keyword {
    if (!self.searchObjId || self.searchObjId.length == 0) {
        LogError(@"Not set searchObjId");
        return;
    }
    
    NSString *AccessInfortmpString = NSLocalizedString(@"querying_message",nil);
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:AccessInfortmpString  tips:nil tapTarget:self action:nil];
    
    NSMutableDictionary *searchDic = [NSMutableDictionary dictionary];
    [searchDic setObject:self.searchObjId forKey:@"objId"];
    [searchDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:APPDATA_EMPIDBIGI];
    if (self.searchStoreId.length > 0) {
        [searchDic setObjectSafe:self.searchStoreId forKey:@"storeId"];
        [searchDic setObject:keyword forKey:@"storeName"];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteSearchFinish:) name:kRemoteSearchNotify object:nil];
    [[WSRequestHelper shareInstance] postRequestData:searchDic notifyName:kRemoteSearchNotify];
}

#pragma - mark WSDropListViewMultilevelMenuDelegate
- (void)wsDropListViewMultilevelMenuCellDidClickWithParam:(WSDictBean *)dictBean
{
    [self cellDidClickWithParam:dictBean];
}

- (void)cellDidClickWithParam:(WSDictBean *)dictBean
{
    if (self.selectedItem != dictBean)
    {
        self.isValueChange = YES;
        [self.selectedItemArray removeAllObjects];
        [self.selectedItemArray addObject:dictBean];
        self.selectedItem = dictBean;
        
    }
    
    self.isShow = NO;
    self.hidden = NO;
    [self hideListPanel];
}
#pragma mark WSHeaderSearchViewDelegate Methods

- (void)headerSearchViewCancelButtonClicked:(WSHeaderSearchView *)view {
    [self cancelSearch];
    [self hideTipsView:self.listTableView];
}

- (NSArray *)headerSearchView:(WSHeaderSearchView *)view nativeSearch:(NSString *)text{
    
    self.filterItems = [NSMutableArray arrayWithArray:[self searchItemByKeyword:text]];
    
    // MSTD-5759 如果内容小于一页则不显示底部向下箭头
    [self hideTipsView:self.listTableView];
    
    [self.listTableView reloadData];
    if (self.headerSearchView.currentSearchType == WSMultilevelMenuSearchType)
    {
        
        WSDictBean *searchBean = [dataTool getSearchDictWithName:text withFilterStr:self.filterStr];
        if (searchBean)
        {
            NSMutableArray *dataArray = [NSMutableArray arrayWithObject:searchBean];
            self.countryAdministrationListView = nil;
            self.selectedItem = searchBean;
            [self getMultilevelMenuWithDataSourceArray:dataArray];
            [self titleButtonClicked:nil];
        }
        
    }
    return self.filterItems;
}

- (void)headerSearchView:(WSHeaderSearchView *)view remoteSearch:(NSString *)text isFromSearchLables:(BOOL)isFromLables {
    if (text.length == 0) {
        [self cancelSearch];
        [self hideTipsView:self.listTableView];
        return;
    }
    
    [self remoteSearchByKeyword:text];
}

// YIHAIKERRY-256 修复多选下拉框搜索所有选项不能显示全的问题
- (void)headerSearchViewTriggerKeyboardWillShowWithHeight:(NSNumber *)keyboardHeightNumber
{
    if (!INTERFACE_IS_PAD) {
        CGFloat keyboardHeight = [keyboardHeightNumber floatValue];
        CGRect panelFrame = self.listPanel.frame;
        
        CGRect statusBarRect = [[UIApplication sharedApplication] statusBarFrame];
        
        
        CGFloat panelMaxHeight = SCREEN_HEIGHT - keyboardHeight - statusBarRect.size.height;
        
        if (panelFrame.size.height >= panelMaxHeight) {
            panelFrame.origin.y = statusBarRect.size.height;
            panelFrame.size.height = panelMaxHeight;
        }else{
            panelFrame.origin.y = SCREEN_HEIGHT - keyboardHeight - panelFrame.size.height;
            
        }
        
        self.listPanel.frame = panelFrame;
        
        //    [self hideTipsView:self.listTableView];
    }
    
}

- (void)headerSearchViewTriggerKeyboardWillHideWithHeight:(NSNumber *)keyboardHeightNumber
{
    if (!INTERFACE_IS_PAD) {
        CGFloat paddingY = (SCREEN_HEIGHT - _listPanelFirstHeight);
        
        // 状态栏高度变为40需要调整Y的偏移量
        CGRect statusBarRect = [[UIApplication sharedApplication] statusBarFrame];
        int shouldBeSubtractionHeight = 0;
        if (statusBarRect.size.height == 40) {
            shouldBeSubtractionHeight = 20;
        }
        
        paddingY -= shouldBeSubtractionHeight;
        
        CGRect panelFrame = self.listPanel.frame;
        panelFrame.origin.y = paddingY;
        panelFrame.size.height = _listPanelFirstHeight;
        
        self.listPanel.frame = panelFrame;
        
        //    [self hideTipsView:self.listTableView];
        
        //    [self setListPanelFrame];
    }

}

// 服务器搜索返回数据
- (void)remoteSearchFinish:(id)sender {
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRemoteSearchNotify object:nil];
    // 解析数据
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSDictionary *dic = [info objectFromJSONString];
    
    
    NSArray *remoteAcvtdis = [dic objectForKey:self.searchObjId];
    NSString *flag = [NSString stringWithValue:[dic objectForKey:@"flag"]];
    
    if ([flag isEqualToString:@"0"]) {
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"refresh_failure", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        return;
    }
    
    NSString *alterString = nil;
    
    if (remoteAcvtdis && [remoteAcvtdis count] > 0) {
        
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:remoteAcvtdis.count];
        for (NSDictionary *dict in remoteAcvtdis) {
            WSBaseOptionDataItem *optItem = [[WSBaseOptionDataItem alloc] init];
            optItem.itemID = [NSString stringWithValue:[dict objectForKey:@"Id"]];
            optItem.itemName = [dict objectForKey:@"name"];
            [tempArray addObject:optItem];
        }
        
        
        self.filterItems = [tempArray copy];
        self.dataSourceArray = [tempArray copy];
        
        
        alterString = NSLocalizedString(@"update_done_label",nil);
        
    } else {
        // 提示没有搜出来结果
        self.filterItems = nil;
        self.dataSourceArray = nil;
        
        alterString = NSLocalizedString(@"no_result", nil);
    }
    
    [self hideTipsView:self.listTableView];
    
    [self updateButtonTitle];
    [self.listTableView reloadData];
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:alterString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
}

- (void)refreshListWithDataSourceArray:(NSArray *)dataSourceArray
{
    if (dataSourceArray && dataSourceArray.count > 0) {
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:dataSourceArray.count];
        for (NSDictionary *dict in dataSourceArray) {
            WSBaseOptionDataItem *optItem = [[WSBaseOptionDataItem alloc] init];
            if ([dict isKindOfClass:[WSDictBean class]]) {
                WSDictBean *dictBean = (WSDictBean *)dict;
                optItem.itemID = [NSString stringWithValue:dictBean.Id];
                optItem.itemName = dictBean.name;
            } else {
                optItem.itemID = [NSString stringWithValue:[dict objectForKey:@"Id"]];
                optItem.itemName = [dict objectForKey:@"name"];
            }
            [tempArray addObject:optItem];
        }
        
        
        self.filterItems = [tempArray copy];
        self.dataSourceArray = [tempArray copy];
    }

    [self updateButtonTitle];
    [self.listTableView reloadData];
}

#pragma mark - Getters and Setters

- (UIView *)listPanel {
    if (!_listPanel) {
        _listPanel = [[UIView alloc] init];
        [_listPanel setBackgroundColor:[UIColor whiteColor]];
        [_listPanel addSubview:self.listTableView];
    }
    return _listPanel;
}

- (UITableView *)listTableView {
    if (!_listTableView) {
        _listTableView = [[UITableView alloc] init];
        
        UIColor *tableBgColor = [UIColor colorForKey:@"DropListCellNormalBackgroudColor"];
        if (!tableBgColor) {
            tableBgColor = [UIColor whiteColor];
        }
        
        if (self.selectType == WSDropListViewTypeSearchBarShow ||
            self.selectType == WSDropListViewTypeServerSearchBarShow) {
            _listTableView.frame = CGRectMake(0, MAIN_CELL_BUTTON_WH, self.width, self.listPanel.height-MAIN_CELL_BUTTON_WH);
        }
        
        _listTableView.backgroundColor = tableBgColor;
        
        
        _listTableView.delegate = self;
        _listTableView.dataSource = self;
        _listTableView.bounces = NO;
        _listTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        if (self.selectMode == WSDropListViewSelectModeMultipleChoice) {
            _listTableView.allowsMultipleSelection = YES;
        }
    }
    
    return _listTableView;
}

- (WSDropListViewMultilevelMenu *)countryAdministrationListView
{
    if (!_countryAdministrationListView)
    {
        _countryAdministrationListView = [[WSDropListViewMultilevelMenu alloc] initWithFrame:CGRectMake(0, MAIN_CELL_HEIGHT,self.listPanel.frame.size.width, self.listPanel.frame.size.height-MAIN_CELL_HEIGHT-10) withLevelNumber:_levelNumber withAllData:self.multileveMenuArray withBackShowLevelData:self.backShowLevelDataArray];
        _countryAdministrationListView.delegate = self;
    }
    return _countryAdministrationListView;
}

- (UIView *)tipsView {
    if (!_tipsView) {
        CGFloat width = SCREEN_WIDTH * kWidthRatio;
        _tipsView = [[UIView alloc] init];
        
        UIColor *colorUp = [UIColor colorWithWhite:1.0 alpha:0.8];
        UIColor *colorDown = [UIColor colorWithWhite:1.0 alpha:0.0];
        NSArray *colors = [NSArray arrayWithObjects:(id)colorDown.CGColor, (id)colorUp.CGColor, nil];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.colors = colors;
        gradient.frame = CGRectMake(0, 0, width, kTipsHeight);
        [_tipsView.layer insertSublayer:gradient atIndex:0];
        _tipsView.userInteractionEnabled = NO;
        
        CALayer *arrowLayer = [self getArrowLayer];
        [arrowLayer setPosition:CGPointMake(width / 2, kTipsHeight - MAIN_TEXT_IMG_PADDING - kTipsArrowWH / 2)];
        [_tipsView.layer addSublayer:arrowLayer];
        _arrowLayer = arrowLayer;
    }
    return _tipsView;
}

- (void)arrowAnim {
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    CABasicAnimation *moveAnimation = [self arrowMoveAnim];
    CABasicAnimation *alphaAnimation = [self arrowAlphaAnim];
    animationGroup.animations = @[moveAnimation, alphaAnimation];
    animationGroup.duration = 1.5;
    animationGroup.repeatCount = 3;
    [self.arrowLayer addAnimation:animationGroup forKey:nil];
}

- (CABasicAnimation *)arrowMoveAnim {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    CGPoint point = self.arrowLayer.position;
    animation.toValue = [NSValue valueWithCGPoint:point];
    point.y -= 5;
    animation.fromValue = [NSValue valueWithCGPoint:point];
    return animation;
}

- (CABasicAnimation *)arrowAlphaAnim {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithInt:0.6];
    animation.toValue = [NSNumber numberWithInt:1];
    return animation;
}

- (CALayer *)getTopBorderWithWidth:(CGFloat)width {
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0, 0, width, 1);
    topBorder.backgroundColor =  DETAIL_SEPERATE_LINE_COLOR.CGColor;
    return topBorder;
}

- (CALayer *)getArrowLayer {
    CALayer *layer = [CALayer layer];
    [layer setBounds:CGRectMake(0, 0, kTipsArrowWH, kTipsArrowWH)];
    
    CAShapeLayer *upArrowLayer = [self getOneArrowLayer];
    [upArrowLayer setPosition:CGPointMake(kTipsArrowWH / 2, 0)];
    [layer addSublayer:upArrowLayer];
    
    CAShapeLayer *downArrowLayer = [self getOneArrowLayer];
    [downArrowLayer setPosition:CGPointMake(kTipsArrowWH / 2, kTipsArrowWH / 2)];
    [layer addSublayer:downArrowLayer];
    return layer;
}

- (CAShapeLayer *)getOneArrowLayer {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:CGRectMake(0, 0, kTipsArrowWH, kTipsArrowWH / 2)];
    [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    [shapeLayer setStrokeColor:[[UIColor lightGrayColor] CGColor]];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, kTipsArrowWH / 2, kTipsArrowWH / 2);
    CGPathAddLineToPoint(path, NULL, kTipsArrowWH, 0);
    [shapeLayer setPath:path];
    CGPathRelease(path);
    
    return shapeLayer;
}


@end






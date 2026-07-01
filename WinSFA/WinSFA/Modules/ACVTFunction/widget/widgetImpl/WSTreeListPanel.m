//
//  WSTreeListPanel.m
//  WinSFA
//
//  Created by winchannel on 15/12/24.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSTreeListPanel.h"
#import "I_W_DataSource.h"
#import "WSDVDataSourceFromDSStore.h"
#import "I_W_DisplayValue.h"
#import "WSStoreBeans.h"
#import "WSMutilevelMenuDataTool.h"
#import "WSDropListViewMultilevelMenu.h"
#import "UIView+Additions.h"
#import "WSTreeListViewController.h"


#define kDisplayAll       @"all"

@interface WSTreeListPanel ()

@property (nonatomic, strong) WSPersonnelListTreeView *treeListView;
@property (nonatomic, strong) UIView *listPanel;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIButton *titleButton;
@property (nonatomic, strong) WSTreeListViewController *treeViewController;

@property (nonatomic, strong) NSMutableArray *selectedItems;
@end



@implementation WSTreeListPanel

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.dataArray = [[NSArray alloc]init];
        
        return self;
    }
    return nil;
}

- (void)buildDisplayContent{
    
    [super buildDisplayContent];
    
     _originalValue = (NSArray *)[xdisplayValue getDisplayValueFor:xbuildInfo];
    
    //获取门店
    self.dataArray = [self getDataSource];
    
    // SFA-18200
    [self setSelectedDisplayAll];
    
    if (INTERFACE_IS_PHONE) {
        
        //SFA 项目SFA-20950 IOS端群发功能页面中显示有误
        NSString *tmpStr;
        NSRange range = [self.titleLabel.text rangeOfString:@"*"];
        if (range.location!= NSNotFound){
            tmpStr = [self.titleLabel.text stringByReplacingOccurrencesOfString:@"*" withString:@""];
        }
        self.treeViewController = [[WSTreeListViewController alloc] init];
        self.treeViewController.title = tmpStr;
        __weak __typeof(self) weakSelf = self;
        [self.treeViewController setSelectBlock:^(NSMutableArray *selectArray) {
            [weakSelf setSelectedItems:selectArray];
        }];
        
        //MN-2687 2018-05-31
        [self.treeViewController setDoneBlock:^{
            UINavigationController *navController = [weakSelf viewController].navigationController;
            if (navController)
                [weakSelf.treeViewController.navigationController popViewControllerAnimated:YES];
            else
                [weakSelf.treeViewController.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
        }];
        
//        UINavigationController *navController = [self viewController].navigationController;
//        if (navController) {
//            [self.treeViewController setDoneBlock:^{
//                [weakSelf.treeViewController.navigationController popViewControllerAnimated:YES];
//            }];
//        } else {
//            [self.treeViewController setDoneBlock:^{
//                [weakSelf.treeViewController.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
//            }];
//        }

        [self setupSelectTitle];
    } else {
        WSPersonnelListTreeView *treeView = [[WSPersonnelListTreeView alloc] initWithFrame:CGRectMake(0, self.titleLabel.bottom +5, self.frame.size.width, 0)];
        self.treeListView = treeView;
        [self setFrame:CGRectMake(self.frame.origin.x,self.frame.origin.y, treeView.frame.size.width , treeView.frame.size.height+treeView.frame.origin.y)];
        [self addSubview:treeView];
        
        self.treeListView.dataArray = self.dataArray;
    
        if ([_originalValue isKindOfClass:[NSArray class]]) {
            NSArray *selectedItemArray = (NSArray *)_originalValue;
            if ([selectedItemArray count] > 0) {
                [self.treeListView setSelectArray:selectedItemArray];
            }
        }
        self.treeListView.delegate = self;
    }
    
    if (_originalValue) {
        [self setSelectedItems:[_originalValue mutableCopy]];
    }
    
}

- (void)setSelectedDisplayAll {
    if (![_originalValue isKindOfClass:[NSArray class]]) {
        return;
    }
    NSArray *selectedItemArray = (NSArray *)_originalValue;
    if ([selectedItemArray count] == 1) {
        NSString *selectedItem = selectedItemArray[0];
        if ([selectedItem isKindOfClass:[NSString class]] && [selectedItem caseInsensitiveCompare:kDisplayAll] == NSOrderedSame) {
            NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:self.dataArray.count];
            for (NSObject<I_W_Cell> *cell in self.dataArray) {
                [tempArray addObject:[cell getId]];
            }
            _originalValue = [tempArray copy];
        }
    }
}

- (void)setupSelectTitle {
    CGFloat paddingX = CGRectGetMaxX(self.titleLabel.frame) - MAIN_TEXT_IMG_PADDING;
    self.titleButton = [[UIButton alloc] initWithFrame:CGRectMake(paddingX, 0, self.width - paddingX - MAIN_CELL_BUTTON_WH - MAIN_TEXT_IMG_PADDING, self.height)];
    [self.titleButton setTitleColor:MAIN_TEXT_COLOR forState:UIControlStateNormal];
    [self.titleButton setTitleColor:MAIN_TEXT_DISABLE_COLOR forState:UIControlStateDisabled];
    self.titleButton.titleLabel.font = [UIFont systemFontOfSize:UI_Font];
    [self.titleButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [self.titleButton addTarget:self action:@selector(arrowAction:) forControlEvents:UIControlEventTouchUpInside];
    self.titleButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.titleButton];
    
    UIButton *arrowButton = [[UIButton alloc] initWithFrame:CGRectMake(self.width - MAIN_CELL_BUTTON_WH, 0, MAIN_CELL_BUTTON_WH, self.height)];
    [arrowButton setImage:[UIImage imageNamed:@"downarrow"] forState:UIControlStateNormal];
    [arrowButton setImage:[UIImage imageNamed:@"downarrow_disable"] forState:UIControlStateDisabled];
    [arrowButton addTarget:self action:@selector(arrowAction:) forControlEvents:UIControlEventTouchUpInside];
    [arrowButton addLeftBorder];
    [self addSubview:arrowButton];
}

- (NSArray *)getDataSource {
    return (NSArray *)[xdataSource getDataSourceFor:xbuildInfo];
}

-(NSObject *)getResultDirectly {
    
    if (_selectedItems != nil && _selectedItems.count > 0) {
        
        for (int i = 0 ; i<_selectedItems.count ; i++ ) {
            NSString *result = [_selectedItems objectAtIndex:i];
            
            if ([result isEqualToString:@""]) {
                [_selectedItems removeObjectAtIndex:i];
            }
        }
        if (_selectedItems.count >0) {
            NSString *result = [_selectedItems componentsJoinedByString:@","];
            return result;
        }
        
    }
    return nil;
    
}

- (void)reloadCurrentWidgetWithValue:(NSObject *)value{
    
    //消除原有的记录
//    [self.treeListView setupSelectionBySelectItemIDArray:self.selectedItems withIsDisPlay:NO];
//    
//    [self.selectedItems removeAllObjects];
    
    if ([value isKindOfClass:[NSString class]]) {
        
        NSString *qstValue= (NSString *)value;
        
        NSArray *selectArray = [qstValue componentsSeparatedByString:@","];
        if ([selectArray count] > 0) {
            [self.treeListView setSelectArray:selectArray];
            //接收新值
            self.selectedItems =  [selectArray mutableCopy];
        } else {
            [self.treeListView selectAll:NO];
        }
        [self.treeListView reloadDataForDisplayArray];
    }
    
}



#pragma mark - Actions
- (void)arrowAction:(id)sender {
    [self pushToTreeViewController];
    
    // WSSearchBar 的自动布局 treeViewController 的后退按钮等多个问题，导致必须在页面加载完成后设置 treeListView
    if (!self.treeListView) {
        [self.treeViewController.view setNeedsLayout];
        self.treeListView = self.treeViewController.treeListView;
        self.treeListView.delegate = self;
    }
    [self.treeListView setDataArray:self.dataArray];
    
    [self.treeViewController setSelectedArray:self.selectedItems];
}

- (void)pushToTreeViewController {
    UINavigationController *navController = [self viewController].navigationController;
    if (navController) {
        [navController pushViewController:self.treeViewController animated:YES];
    } else {
        WCNavigationController* navController = [[WCNavigationController alloc] initWithRootViewController:self.treeViewController ];
        [self.window.rootViewController presentViewController:navController animated:YES completion:nil];
    }
}

#pragma mark - WSPersonnelListTreeViewDelegate
- (void)setSelectedArray:(NSMutableArray *)selectedArray {
    [self setSelectedItems:selectedArray];
}

- (void)resetFramePersonnelListTreeView:(WSPersonnelListTreeView *)personnelListTreeView {
     [self setFrame:CGRectMake(self.frame.origin.x,self.frame.origin.y, personnelListTreeView.frame.size.width , personnelListTreeView.frame.size.height+personnelListTreeView.frame.origin.y)];
}

- (void)setSelectedItems:(NSMutableArray *)selectedItems {
    _selectedItems = selectedItems;
    
    NSString *title = @"";
    if ([self.selectedItems count] > 0) {
        NSString *selected = NSLocalizedString(@"selected", nil);
        NSString *unit = NSLocalizedString(@"individual", nil);
        title = [NSString stringWithFormat:@"%@ %ld %@", selected, [self.selectedItems count], unit];
    }
    [self.titleButton setTitle:title forState:UIControlStateNormal];
}

#pragma mark - for lua
- (void)setCurrentValueWithPresentation:(NSString *)valuePresentation
{
    if (valuePresentation.length == 0) {
        //clear原有的选项;
        [self.selectedItems removeAllObjects];
        [self.treeListView selectAll:NO];
    }
}

- (void)setReadonly:(NSString *)isReadonly{
    [super setReadonly:isReadonly];
    
    if ([[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
        
        self.treeListView.sourceTreelistReadOnly = YES;
        
    }else{
        self.treeListView.sourceTreelistReadOnly = NO;
    }
    [self.treeListView reloadDataForDisplayArray];
    
}

- (void)updateContent:(NSObject *)content{
    if (![content isKindOfClass:[NSMutableArray class]]) {
        return;
    }
    self.dataArray = [content copy];
    
    self.treeListView.frame= CGRectMake(0, self.titleLabel.bottom +5, self.frame.size.width, self.dataArray.count *50);
    [self setFrame:CGRectMake(self.frame.origin.x,self.frame.origin.y, self.treeListView.frame.size.width , self.treeListView.frame.size.height+self.treeListView.frame.origin.y)];

    [self.treeListView setDataArray:self.dataArray];
    [self.treeListView reloadDataForDisplayArray];
}

@end

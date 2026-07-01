//
//  WSMultiSelectAndSearchDropListPanel.m
//  WinSFA
//
//  Created by HZH on 16/12/1.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSMultiSelectAndSearchDropListPanel.h"
#import "I_W_BuildInfo.h"
#import "I_W_DataSource.h"
#import "WidgetConstant.h"
#import "WSSelectListView.h"
#import "WSDropListView.h"
#import "WSInterAction.h"
#import "WSStoreBeans.h"
#import "WSMultiSelectAndSearchViewController.h"
#import "WSDropListView.h"
#import "I_W_DisplayValue.h"
#import "I_W_BuildInfo.h"
#import "I_W_DataSource.h"
#import "WSArrayValueChangeChecker.h"
#import "WSStoreBean.h"
#import "WSDataSourceFromDSStore.h"
#import "WSDataSourceFromDSDicts.h"
#import "WSBaseOptionDataItem.h"

@interface WSMultiSelectAndSearchDropListPanel () <MultiSelectAndSearchDelegate>

@property (nonatomic, strong) UIButton *titleButton;

@end


@implementation WSMultiSelectAndSearchDropListPanel {
    BOOL _needRiseSelectionChange; //是否需要发起change的事件 （触发脚本之类的）
    BOOL _showRedisValueAfterExcuteLuaSript;
}

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _needRiseSelectionChange = YES;
        _showRedisValueAfterExcuteLuaSript = YES;
        self.needCheckValueChange = YES;
        self.selectedItemArray = [[NSMutableArray alloc] init];
        return self;
    }
    return nil;
}


-(void)buildDisplayContent{
    
    [super buildDisplayContent];
    
    
    BOOL orientition = NO;
    if ([xbuildInfo getOrientation] && [[xbuildInfo getOrientation] isEqualToString:@"1"]) {
        orientition = YES;
    }
    
    
    _titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_titleButton setFrame:CGRectMake(self.titleLabel.frame.size.width + 20, 5, self.width - self.titleLabel.frame.size.width - 30, self.height - 10)];
    [_titleButton setFrame:CGRectMake(self.width - 80, 5, 70, self.height - 10)];
    _titleButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _titleButton.titleLabel.numberOfLines = 2;
    _titleButton.backgroundColor = [UIColor clearColor];

//    [_titleButton setTitle:NSLocalizedString(@"please_select", nil) forState:UIControlStateNormal];

    [_titleButton setTitleColor:MAIN_TEXT_COLOR forState:UIControlStateNormal];
    [_titleButton setTitleColor:MAIN_TEXT_DISABLE_COLOR forState:UIControlStateDisabled];
    _titleButton.titleLabel.font = [UIFont systemFontOfSize:(INTERFACE_IS_PAD ? 15.0 : 13.0)];
    
    [_titleButton setBackgroundImage:[UIImage imageNamed:@"button_bj"] forState:UIControlStateNormal];

    
    [_titleButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    _titleButton.adjustsImageWhenHighlighted = NO;
    _titleButton.adjustsImageWhenDisabled = NO;
    [_titleButton addTarget:self action:@selector(titleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _titleButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = DETAIL_SEPERATE_LINE_COLOR;
    [_titleButton addSubview:line];
    
    [self addSubview:_titleButton];
    
    if ([[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
        
        [self setSourceTableReadOnly:YES];
    }
    
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, MAIN_CELL_HEIGHT)];
    
    if (orientition) {
        CGRect labelFrame = self.titleLabel.frame;
        [self.titleLabel setFrame:CGRectMake(labelFrame.origin.x, (self.frame.size.height - labelFrame.size.height)/2 , labelFrame.size.width, labelFrame.size.height)];
    }
    
    [xdataSource getDataSourceFor:xbuildInfo];
    self.dataSourceArray = xdataSource.dataSourceArray;
    
    self.selectMode = WSMultiSelectAndSearchViewSelectModeMultipleChoice;
    self.selectType = WSMultiSelectAndSearchViewTypePushNewVCShow;
    
    // 如果数据源仅有一项（不包括没有默认选项时添加的@""）且为必填则直接选中该选项
    if ([[xbuildInfo getISRequire] isEqualToString:@"1"] && [xdataSource.dataSourceArray count] == 1) {
        [self setUpSelectionByItemIDArray:@[[[xdataSource.dataSourceArray firstObject] getDataItemID]]];
    }
    
    NSArray *selectItemIDArray = (NSArray *)[xdisplayValue getDisplayValueFor:xbuildInfo];
    if (selectItemIDArray) {
        [self setUpSelectionByItemIDArray:selectItemIDArray];
    }
    
    _originalValue = selectItemIDArray;
    
//    if (self.selectedItemArray && self.selectedItemArray.count > 0) {
//        [self resetButtonTitle];
//    }
}

- (NSMutableArray *)dataSource {
    
    NSMutableArray *dataSource = [NSMutableArray arrayWithArray:(NSArray *)[xdataSource getDataSourceFor:xbuildInfo]];

    return dataSource;
}

- (void)titleButtonClicked:(id)sender
{
    if ([self.dataSourceArray count] == 0) {
        return;
    }
    
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    

    if (self.selectType == WSMultiSelectAndSearchViewTypePushNewVCShow) {

        [self pushNewVCDropListViewDidAppear:nil];

        return;
    }

    UIWindow *wc = [[[UIApplication sharedApplication] windows] firstObject];
    UIViewController *rootViewController = wc.rootViewController;
    if (rootViewController.presentedViewController) {
        rootViewController = rootViewController.presentedViewController;
    }
    if (rootViewController.presentedViewController) {
        rootViewController = rootViewController.presentedViewController;
    }
    
}

- (NSString *)getResultDirectly
{
    NSString *result = nil;
    
    if (self.selectMode == WSMultiSelectAndSearchViewSelectModeSingleSelection) {
        if (self.selectedItem) {
            result = [self.selectedItem getDataItemID];
        }
    }
    else if (self.selectMode == WSMultiSelectAndSearchViewSelectModeMultipleChoice) {
        
        NSMutableArray *contentArray = [NSMutableArray array];
        if ([self.selectedItemArray count] > 0) {
            for (NSObject<I_W_OptionDataItem> *dataItem in self.selectedItemArray) {
                [contentArray addObject:[dataItem getDataItemID]];
            }
            result = [contentArray componentsJoinedByString:@","];
        }
    }

    
    return result;
}

- (void)setUpSelectionByItemIDArray:(NSArray *)dataItemIDArray
{
    if (self.selectMode == WSMultiSelectAndSearchViewSelectModeSingleSelection) {
        NSString *selectDataItemID = [dataItemIDArray firstObject];
        NSArray *arr = [selectDataItemID componentsSeparatedByString:@","];
        if (arr && arr.count > 0) {
            for (NSString *selID in arr) {
                for (NSObject<I_W_OptionDataItem> *dataItem in self.dataSourceArray) {
                    if ([[dataItem getDataItemID] isEqualToString:selID] || [[dataItem getDataItemName] isEqualToString:selID]) {
                        self.selectedItem = dataItem;
                        [self resetButtonTitle];
                        break;
                    }
                }
            }
        } else {
            self.selectedItem = nil;
            [self resetButtonTitle];
        }
        
        
    }
    else if (self.selectMode == WSMultiSelectAndSearchViewSelectModeMultipleChoice) {
        [self.selectedItemArray removeAllObjects];
        
        for (NSString *dataItemID in dataItemIDArray) {
            for (NSObject<I_W_OptionDataItem> *dataItem in self.dataSourceArray) {
                if ([[dataItem getDataItemID] isEqualToString:dataItemID]) {
                    [self.selectedItemArray addObject:dataItem];
                    break;
                }
            }
        }
        self.tempSelectedItemArray = [self.selectedItemArray mutableCopy];
        [self resetButtonTitle];
//        if (self.dropListDelegate && [self.dropListDelegate respondsToSelector:@selector(dropListViewDidChangeSelect:)])
//        {
//            [self.dropListDelegate performSelector:@selector(dropListViewDidChangeSelect:) withObject:self];
//        }
    }
}

- (void)updateWidgetOpts:(NSString *)conditions {
    
    if ([[xbuildInfo getDataSource] isEqualToString:@"store"]) {
        if ([conditions length] > 0 && [conditions rangeOfString:@","].location != NSNotFound) {
            
            
            
            NSArray *conditionsArray = [conditions componentsSeparatedByString:@","];
            if ([conditionsArray count] == 1) {
                
            }else if ([conditionsArray count] >= 2) {
                NSString *hospitalId = [conditionsArray firstObject];
                if ([hospitalId length] > 0) {
                    BOOL hasDepartment_id = YES;
                    for (NSInteger i=1; i < [conditionsArray count]; i++) {
                        NSString *condition = conditionsArray[i];
                        if ([condition length] > 0) {
                        }else {
                            hasDepartment_id = NO;
                        }
                    }
                    
                    if (hasDepartment_id) {
                        
                        if (_allStores == nil) {
                            WSStoreBeans *storeBeans = [WSAppData getObjectbyKey:STORES];
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.noteName == %@",STORES];
                            _allStores = [storeBeans.storesArray filteredArrayUsingPredicate:predicate];
                            
                            if ([[xbuildInfo getFilterCondition] length] > 0) {
                                _allStores = [_allStores filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.styp == %@",[xbuildInfo getFilterCondition]]];
                            }
                        }
                        NSArray *departments = [conditionsArray subarrayWithRange:NSMakeRange(1, [conditionsArray count]-1)];
                        NSPredicate *hosPredicate = [NSPredicate predicateWithFormat:@"self.pid == %@ and self.departmentId in %@",hospitalId,departments];
                        NSArray *hosStores = [_allStores filteredArrayUsingPredicate:hosPredicate];
                        self.dataSourceArray = hosStores;
                        
                        
                        /*若上次选中的选项不在这次更新的数据源中则清空*/
                        NSArray *items = self.selectedItemArray;
                        if ([items count] > 0) {
                            NSArray *itemIds = [items valueForKeyPath:@"@distinctUnionOfObjects.Id"];
                            NSArray *filters = [hosStores filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.Id in %@",itemIds]];
                            if ([filters count] == 0) {
                                self.selectedItemArray = [@[] mutableCopy];
//                                if ([self.dropListView.dropListDelegate respondsToSelector:@selector(dropListViewDidChangeSelect:)]) {
//                                    [self.dropListView.dropListDelegate dropListViewDidChangeSelect:self.dropListView];
//                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

- (void)setValidDataSourceFromScript:(NSString *)validDataSource
{
    NSArray *dataSourceArray = [validDataSource componentsSeparatedByString:@","];
    NSMutableArray *newDataSource = [[NSMutableArray alloc] init];
    for (NSString *dataName in dataSourceArray) {
        for (NSObject<I_W_OptionDataItem> *item in xdataSource.dataSourceArray) {
            if ([dataName isEqualToString:[item getDataItemName]]) {
                [newDataSource addObject:item];
                break;
            }
        }
    }
    
    self.dataSourceArray = newDataSource;
}



- (void)setFilter:(NSString *)filter
{
    [super setFilter:filter];
    
    [self setCurrentValueWithPresentation:@""];
    [self removeAllSubviews];
    [self buildDisplayContent];
}

- (void)widgetDidLoadFinish
{
    /* YIHAIKERRY-3084 问题加载完成后若无必要不执行脚本，如果安卓执行可以去掉这个屏蔽
    if ([xbuildInfo getLuaScript] && [[xbuildInfo getLuaScript] length] > 0 && _originalValue) {
        if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
            [self.delegate executeLuaScript:xbuildInfo widget:self];
        }
    }
    */
}

- (void)pushNewVCDropListViewDidAppear:(id)sender
{
    // 常规跳转
//    WSMultiSelectAndSearchViewController *msasvc = [[WSMultiSelectAndSearchViewController alloc]init];
//    msasvc.selectedDelegate = self;
//    NSMutableArray *itemIds = [[NSMutableArray alloc]init];
//    for (int i = 0 ; i< [dropListView.selectedItemArray count] ; i++) {
//        [itemIds addObject:[NSString stringWithFormat:@"%d",i]];
//    }
//    msasvc.itemArray = dropListView.selectedItemArray;
//    msasvc.itemIds = itemIds;
//    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:msasvc];
//    [self.parentViewController presentViewController:nc animated:YES completion:nil];
    
    // 脚本控制跳转
    WSInterAction  *interaction =[[WSInterAction alloc] init];
    
    [interaction setAcvt_qust_id:[xbuildInfo  getAcvtQstId]];
    
    [interaction setExecute_class:@"WSMultiSelectAndSearchViewController"];
    [interaction setExcute_class_delegate:self];
    [interaction setExecute_method_param:self.selectedItemArray];
    [interaction setExecute_class_param_title:[xbuildInfo  getQuestName]];

    [interaction setDirect_type:DIRECT_TYPE_PUSH];
    
    if ([self.dataSourceArray count] > 1) {
        [interaction setExecute_class_param:self.dataSourceArray];
    }else {
        [interaction setExecute_class_param:xdataSource.dataSourceArray];
    }
    
    
    
    if ([delegate respondsToSelector:@selector(executeInterAction:)]) {
        
        [delegate executeInterAction:interaction];
        
    }
}

- (void)multiSelectAndSearchView:(WSMultiSelectAndSearchViewController *)multiSelectAndSearchView selectedItemArray:(NSArray *)itemArray
{
    self.selectedItemArray = [NSMutableArray arrayWithArray:itemArray];
    
    [self resetButtonTitle];
}

- (void)resetButtonTitle
{
    NSString *prodsStr = @"";
    NSMutableArray *itemIdsMutableArray = [[NSMutableArray alloc] init];
    
    for (id<I_W_OptionDataItem> item in self.selectedItemArray) {
        prodsStr = [prodsStr stringByAppendingString:[NSString stringWithFormat:@"%@;", [item getDataItemName]]];
        [itemIdsMutableArray addObject:[item getDataItemID]];
    }
    [_titleButton setTitle:prodsStr forState:UIControlStateNormal];
    
    if ([prodsStr isEqualToString:@""]) {
        [_titleButton setFrame:CGRectMake(self.width - 80, 5, 70, self.height - 10)];

    }else{
        CGSize titleSize = [prodsStr sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:_titleButton.titleLabel.font.fontName size:_titleButton.titleLabel.font.pointSize]}];
        
        CGFloat btnNewWidth = titleSize.width < self.width - self.titleLabel.frame.size.width - 30 ? titleSize.width : self.width - self.titleLabel.frame.size.width - 30;
        
        [_titleButton setFrame:CGRectMake(self.titleLabel.frame.size.width + 20, 5, self.width - self.titleLabel.frame.size.width - 30, self.height - 10)];
        
        CGRect tempFrame = _titleButton.frame;
        tempFrame.origin.x = self.width - btnNewWidth - 10;
        tempFrame.size.width = btnNewWidth;
        
        [_titleButton setFrame:tempFrame];
    }
    
}

- (void)reloadCurrentWidgetWithValue:(NSObject *)value {
    NSObject *modelItem = [self.dataSourceArray firstObject];
    if ([modelItem isKindOfClass:[WSStoreBean class]]) {
        NSArray *selectItemIds = [(NSString *)value componentsSeparatedByString:@","];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.Id in %@",selectItemIds];
        NSArray *redisArrray = [self.dataSourceArray filteredArrayUsingPredicate:predicate];
        self.selectedItemArray = [NSMutableArray arrayWithArray: redisArrray];

    }else {
        /*to do something*/
    }
    
}

- (void)setSourceTableReadOnly:(BOOL)readOnly {
    if (_sourceTableReadOnly != readOnly) {
        _sourceTableReadOnly = readOnly;
        [_titleButton setEnabled:!readOnly];
    }
    if (readOnly) {
        self.titleLabel.textColor = MAIN_TEXT_DISABLE_COLOR;
        self.backgroundColor = MAIN_CELL_DISABLE_COLOR;
    } else {
        
        self.titleLabel.textColor = DETAIL_TEXT_COLOR;
        [self setTitleContent:self.titleLabel.text];
        self.backgroundColor = [UIColor whiteColor];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

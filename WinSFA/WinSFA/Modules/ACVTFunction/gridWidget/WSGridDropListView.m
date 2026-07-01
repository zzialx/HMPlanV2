//
//  WSGridDropListView.m
//  WinSFA
//
//  Created by Alicia on 2018/6/8.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSGridDropListView.h"
#import "WSDropListView.h"

@interface WSGridDropListView()<WSDropListViewDelegate>

@property (nonatomic, strong) WSDropListView *dropListView;

@end

@implementation WSGridDropListView

- (void)setupView {
    WSDropListViewSelectMode selectMode = WSDropListViewSelectModeSingleSelection;
    if ([self.param.tpy isEqualToString:COL_TYPDT]) {
        selectMode = WSDropListViewSelectModeSingleSelection;
    } else if ([self.param.tpy isEqualToString:COL_TYPSD]) {
        selectMode = WSDropListViewSelectModeMultipleChoice;
    }
    
    
    CGFloat width = 100;
    if ([self.param.charNum intValue] > 0) {
        width = [self.param.charNum intValue] * UINIT_WIDTH_OTHER ;
    } else if (self.param.wcol > 0) {
        width = self.param.wcol;
    }
    
    WSDropListView *list = [[WSDropListView alloc] initWithFrame:CGRectMake(0, 0, width, 40) selectMode:selectMode];
    list.dropListDelegate = self;
    list.layer.cornerRadius = 5.0f;
    list.isInGrid = YES;
    
    // TODO
    list.iRow = (unsigned int)self.iRow;
    list.iColumn = (unsigned int)self.iColumn;
    list.m_col = self.m_col;
 
    if (self.param.readonly == 1) {
        [list setSourceTableReadOnly:YES];
    }
    self.dropListView = list;
    
}


- (UIView *)getView {
    return self.dropListView;
}

- (NSString *)getValue {
    return [self.dropListView getResultDirectly];
}

- (NSString *)getValuePresentation {
    return [self.dropListView getResultPresentation];
}

- (void)setValue:(NSString *)value {
    [self resetDropList];
    
    NSArray *validValueArray = [value componentsSeparatedByString:@","];
    NSMutableArray *valueIDArray = [[NSMutableArray alloc] init];
    for (NSString *dataName in validValueArray) {
        for (NSObject<I_W_OptionDataItem> *item in self.dropListView.dataSourceArray) {
            if ([dataName isEqualToString:[item getDataItemName]] || [dataName isEqualToString:[item getDataItemID]]) {
                [valueIDArray addObject:[item getDataItemID]];
                break;
            }
        }
    }
    [self.dropListView setUpSelectionByItemIDArray:valueIDArray];
}

- (void)setReadonly:(BOOL)isReadonly {
    [self.dropListView setSourceTableReadOnly:isReadonly];
}

- (CGFloat)getSum {
    return [[self getValuePresentation] doubleValue];
}

- (void)setDefaultValue {
    if (!self.dropListView.selectedItem) {
        id<I_W_OptionDataItem> item = [self.dropListView.dataSourceArray firstObject];
        if ([item getDataItemID]) {
            [self.dropListView setUpSelectionByItemIDArray:@[[item getDataItemID]]];
        }
    }
}

#pragma mark - Private Method
- (void)resetDropList {
    if (!self.delegate) {
        return;
    }
    NSString *parentId = nil;
    if (self.param.parent.length > 0) {
        WSGridWidget *widgetRoot = [self.delegate dataSourceGetGroupViewByType:nil];
        WSGridWidget *widgetParent = [widgetRoot getGridWidgetByKey: [self getGridWidgetParentKeyByWidget:self]];
        parentId = [widgetParent getValue];
    }
    if (!parentId || !self.param) {
        return;
    }
    NSMutableArray *dataSourceArray = [self.delegate dataSourceGetDropListRedisByParam:self.param parentId:parentId];
    if (dataSourceArray && dataSourceArray.count > 0) {
        self.dropListView.dataSourceArray = dataSourceArray;
    }
}

#pragma mark - WSDropListViewDelegate
- (void)dropListViewDidChangeSelect:(WSDropListView *)dropListView {
    if (self.delegate) {
        [self.delegate dataSourceRunScriptWithWidgetKey:self.widgetKey];
    }
}

- (void)popupDropListViewDidAppear:(WSDropListView *)dropListView {
    if (self.delegate) {
        [self.delegate dataSourcePopDropListView:dropListView];
    }
}

@end

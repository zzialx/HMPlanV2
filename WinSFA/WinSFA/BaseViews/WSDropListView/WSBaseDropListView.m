//
//  WSBaseDropListView.m
//  WinSFA
//
//  Created by Alicia on 2018/3/20.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSBaseDropListView.h"


static NSInteger const showSearchBarCount = 10;


@implementation WSBaseDropListView

@synthesize selectedItemArray = _selectedItemArray;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [self initWithFrame:frame selectMode:WSDropListViewSelectModeSingleSelection];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame selectMode:(WSDropListViewSelectMode)selectMode {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectMode = selectMode;
    }
    return self;
}

- (void)setSelectMode:(WSDropListViewSelectMode)selectMode {
    if (_selectMode != selectMode) {
        _selectMode = selectMode;
        if (selectMode == WSDropListViewSelectModeSingleSelection) {
            if ([self.dataSourceArray count] > showSearchBarCount) {
                _selectType = WSDropListViewTypeSearchBarShow;
            }
        } else {
            _selectType = WSDropListViewTypeDefaultShow;
        }
    }
}

- (void)setSelectType:(WSDropListViewType)selectType {
    if (_selectType == selectType) {
        return;
    }

    _selectType = selectType;
}

- (void)setSelectedItem:(NSObject<I_W_OptionDataItem> *)selectedItem {
    
    // SFA-23002 - 【SFA泸州老窖】【iOS】假仿冒特征没有根据产品筛选(没有值时也需要走进去，dropListViewDidChangeSelect里边会调脚本，脚本会返回no_data，根据no_data会创造一个任意不为空的值用于判断取交集)
    if (_selectedItem != selectedItem || selectedItem == nil) {
        
        _selectedItem = selectedItem;

        if (self.dropListDelegate && [self.dropListDelegate respondsToSelector:@selector(dropListViewDidChangeSelect:)])
        {
            [self.dropListDelegate performSelector:@selector(dropListViewDidChangeSelect:) withObject:self];
        }
    }
}

- (void)setSelectedItemArray:(NSMutableArray *)selectedItemArray {
    _selectedItemArray = selectedItemArray;

    if (self.dropListDelegate && [self.dropListDelegate respondsToSelector:@selector(dropListViewDidChangeSelect:)])
    {
        [self.dropListDelegate performSelector:@selector(dropListViewDidChangeSelect:) withObject:self];
    }
}




- (void)setDataSourceArray:(NSArray *)dataSourceArray {
    if (_dataSourceArray != dataSourceArray) {
        _dataSourceArray = nil;
        _dataSourceArray = dataSourceArray;
     
        if (self.selectMode == WSDropListViewSelectModeSingleSelection &&
            self.selectType != WSDropListViewTypeServerSearchBarShow) {

            if ([dataSourceArray count] > showSearchBarCount) {
                self.selectType = WSDropListViewTypeSearchBarShow;
            } else {
                self.selectType = WSDropListViewTypeDefaultShow;
            }
        }
    }
}


- (void)setSourceTableReadOnly:(BOOL)sourceTableReadOnly {
    if (_sourceTableReadOnly != sourceTableReadOnly) {
        _sourceTableReadOnly = sourceTableReadOnly;
        [self setNeedsLayout];
    }
}



- (NSString *)getResultDirectly {
    NSString *result = nil;
    
    if (_selectMode == WSDropListViewSelectModeSingleSelection) {
        if (self.selectedItem
            && ![[self.selectedItem getDataItemID] isEqualToString:kCancelItemId]
            && ![[self.selectedItem getDataItemID] isEqualToString:kBlankItemID]) {
            result = [self.selectedItem getDataItemID];
        }
    } else if (self.selectMode == WSDropListViewSelectModeMultipleChoice) {
        
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

- (NSString *)getResultPresentation {
    NSString *result = nil;
    if (_selectMode == WSDropListViewSelectModeSingleSelection) {
        if (self.selectedItem
           && ![[self.selectedItem getDataItemID] isEqualToString:kCancelItemId]
           && ![[self.selectedItem getDataItemID] isEqualToString:kBlankItemID]){
            result = [self.selectedItem getDataItemName];
        }
    } else if (_selectMode == WSDropListViewSelectModeMultipleChoice) {
        if ([self.selectedItemArray count] > 0) {
            NSMutableArray *contentArray = [NSMutableArray array];
            for (NSObject<I_W_OptionDataItem> *dataItem in self.selectedItemArray) {
                [contentArray addObject:[dataItem getDataItemName]];
            }
            result = [contentArray componentsJoinedByString:@","];
        }
    }
    
    return result;
}
- (NSString*)getSelectItemMemo{
    NSString *result = nil;
    if (_selectMode == WSDropListViewSelectModeSingleSelection) {
        if (self.selectedItem
           && ![[self.selectedItem getDataItemID] isEqualToString:kCancelItemId]
           && ![[self.selectedItem getDataItemID] isEqualToString:kBlankItemID]){
            
            result = [self.selectedItem getDataItemMemo];
        }
    }else{
        LogError(@"不支持多选memo");
    }
    return result;
}

- (void)setUpSelectionByItemIDArray:(NSArray *)dataItemIDArray {
    self.dataItemIDArray = self.dataItemIDArray.count > 0 ? self.dataItemIDArray :dataItemIDArray;
    if (self.selectMode == WSDropListViewSelectModeSingleSelection) {
        NSString *selectDataItemID = [dataItemIDArray firstObject];
        NSArray *arr = [selectDataItemID componentsSeparatedByString:@","];
        if (arr && arr.count > 0) {
            for (NSString *selID in arr) {
                for (NSObject<I_W_OptionDataItem> *dataItem in self.dataSourceArray) {
                    if ([[dataItem getDataItemID] isEqualToString:selID] || [[dataItem getDataItemName] isEqualToString:selID]) {
                        [self.selectedItemArray removeAllObjects];
                        [self.selectedItemArray addObject:dataItem];
                        self.selectedItem = dataItem;
                        break;
                    }
                }
            }
        } else {
            self.selectedItem = nil;
        }
    } else if (self.selectMode == WSDropListViewSelectModeMultipleChoice) {
        [self.selectedItemArray removeAllObjects];
        
        for (NSString *dataItemID in dataItemIDArray) {
            for (NSObject<I_W_OptionDataItem> *dataItem in self.dataSourceArray) {
                if ([[dataItem getDataItemID] isEqualToString:dataItemID]|| [[dataItem getDataItemName] isEqualToString:dataItemID]) {
                    [self.selectedItemArray addObject:dataItem];
                    break;
                }
            }
        }
        self.tempSelectedItemArray = [self.selectedItemArray mutableCopy];
      
        if (self.dropListDelegate && [self.dropListDelegate respondsToSelector:@selector(dropListViewDidChangeSelect:)])
        {
            [self.dropListDelegate performSelector:@selector(dropListViewDidChangeSelect:) withObject:self];
        }
    }
}

- (void)setLimitNum:(NSString *)limitNum {
    _limitNum = limitNum;
    if (limitNum.length > 0 && [self.selectedItemArray count] > [limitNum integerValue]) {
        [self.selectedItemArray removeAllObjects];
        if (self.dropListDelegate && [self.dropListDelegate respondsToSelector:@selector(dropListViewDidChangeSelect:)])
        {
            [self.dropListDelegate performSelector:@selector(dropListViewDidChangeSelect:) withObject:self];
        }
    }
}

- (BOOL)isValueChange {
    return _isValueChange;
}

- (void)flushTable {
    
}

- (NSMutableArray *)selectedItemArray {
    if (!_selectedItemArray) {
        _selectedItemArray = [[NSMutableArray alloc] init];
    }
    return _selectedItemArray;
}


- (NSMutableArray *)tempSelectedItemArray {
    if (!_tempSelectedItemArray) {
        _tempSelectedItemArray = [[NSMutableArray alloc] init];
    }
    return _tempSelectedItemArray;
}

@end

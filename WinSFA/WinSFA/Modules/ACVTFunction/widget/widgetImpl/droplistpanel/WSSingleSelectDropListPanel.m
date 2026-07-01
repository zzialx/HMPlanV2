//
//  WSSingleSelectDropListPanel.m
//  WinSFA
//
//  Created by yang on 15-3-19.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSSingleSelectDropListPanel.h"
#import "WSDropListView.h"
#import "I_W_DisplayValue.h"
#import "I_W_BuildInfo.h"
#import "I_W_DataSource.h"
#import "WSStringValueChangeChecker.h"

@implementation WSSingleSelectDropListPanel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.xvalueChangeChecker = [[WSStringValueChangeChecker alloc] init];
        
        return self;
    }
    
    return nil;
}

- (void)buildDisplayContent
{
    [super buildDisplayContent];
    
    self.dropListView.selectMode = WSDropListViewSelectModeSingleSelection;
            
    NSString *selectItemID = (NSString *)[xdisplayValue getDisplayValueFor:xbuildInfo];
    if (selectItemID) {
        [self.dropListView setUpSelectionByItemIDArray:@[selectItemID]];
    }
    
    _originalValue = selectItemID;
    
}

- (void)reloadCurrentWidgetWithValue:(NSObject *)value {
    
    if (!value || [value isEqual:@""]) {
        [self.dropListView setSelectedItem:nil];
    }
    
    /*要检查value对象的是opt Id  还是  opt name*/
    [self.dropListView.dataSourceArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSObject <I_W_OptionDataItem> *dataItem = obj;
        NSString *dataItemId = [dataItem getDataItemID];
        NSString *dataItemName =[dataItem getDataItemName];
        if (value && [value isKindOfClass:[NSString class]] && ([dataItemId  isEqualToString:(NSString *)value]|| [dataItemName isEqualToString:(NSString *)value])) {
            [self.dropListView setSelectedItem:dataItem];
        }

    }];
    
}


@end

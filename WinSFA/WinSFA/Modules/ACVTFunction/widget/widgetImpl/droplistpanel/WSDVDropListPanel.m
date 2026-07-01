//
//  WSDVDropListPanel.m
//  WinSFA
//
//  Created by yang on 15-3-20.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSDVDropListPanel.h"
#import "WSBaseOptionDataItem.h"
#import "WSDropListView.h"

@implementation WSDVDropListPanel

- (void)buildDisplayContent {
    [super buildDisplayContent];
    
    if ([[xbuildInfo getDisplayMode] isEqualToString:QST_DISPLAYMODE_BN]) {
        [self.dropListView setSelectMode:WSDropListViewSelectModeMultipleChoice];
    }
    
}
- (void)refreshQstByServer:(NSArray *)resultArray {
    if ([self.dropListView isKindOfClass:[WSDropListView class]]) {
    WSDropListView *dropList = (WSDropListView *)self.dropListView;
    [dropList refreshListWithDataSourceArray:resultArray];
        if(self.dropListView.dataItemIDArray.count>0)
        {
            [self.dropListView setUpSelectionByItemIDArray:self.dropListView.dataItemIDArray];
        }
    }
}
@end

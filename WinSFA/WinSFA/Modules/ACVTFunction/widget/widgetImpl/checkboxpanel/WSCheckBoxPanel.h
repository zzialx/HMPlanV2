//
//  WSCheckBoxPanel.h
//  WinSFA
//
//  Created by yang on 15-3-24.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSSingleTitlePanel.h"
#import "WSOptionView.h"


@interface WSCheckBoxPanel : WSSingleTitlePanel<WSOptionViewDelegate>

@property (nonatomic, strong) NSMutableArray    *selectedItems;

@property (nonatomic, strong) NSMutableArray    *optionViewArray;

@property (nonatomic, strong) NSArray   *dataSourceArray;

- (BOOL)getReadOnly;

- (void)setButton:(UIButton *)button selected:(BOOL)selected;

- (void)setupSelectionBySelectItemIDArray:(NSArray *)selectItemIDArray;

- (void)setUpSubviews;

@end

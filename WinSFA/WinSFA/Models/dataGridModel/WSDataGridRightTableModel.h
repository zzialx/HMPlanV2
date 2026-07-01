//
//  WSDataGridRightTableModel.h
//  WinSFA
//
//  Created by HZH on 2017/7/19.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSDictBean.h"

@interface WSDataGridRightTableModel : NSObject

@property (nonatomic, assign) CGFloat firstColWidth;
@property (nonatomic, assign) BOOL isExPanded;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) WSDictBean *prodTypeDic;

@property (nonatomic, strong) NSArray *prodsArray;

@property (nonatomic, strong) NSArray *gridColParamArray;

@property (nonatomic, strong) NSMutableArray *gridColWidgetArray;//放cell里所有列item数组

@property (nonatomic, strong) NSArray *gridComViewCellHeightArray;

@property (nonatomic, assign) CGFloat gridComViewHeight;

@property (nonatomic, assign) NSInteger topTypeIndex;

@property (nonatomic, assign) NSInteger secondTypeIndex;

@property (nonatomic, strong) NSDictionary *prodKeyValueCacheDataDic;

@property (nonatomic, assign) BOOL isNeedHideFirstColAndKeepBlank;

@end

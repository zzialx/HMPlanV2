//
//  WSNewAddProdsWithSeriesModel.h
//  WinSFA
//
//  Created by HZH on 2017/9/19.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSProdBean.h"

@interface WSNewAddProdsWithSeriesModel : NSObject

@property (nonatomic, strong) WSProdBean *prodBean;
@property (nonatomic, copy) NSString *displayString;
@property (nonatomic, assign) BOOL isChecked;
@property (nonatomic, assign) BOOL isFolded;
@property (nonatomic, assign) NSInteger secondTypeIndex;
@property (nonatomic, copy) NSString *prodTypeImageUrls;
@property (nonatomic, assign) CGFloat cellRealHeight;
@property (nonatomic, strong) NSMutableDictionary *prodKeyValueCacheDataDic;
@property (nonatomic, assign) BOOL isCollected;
@property (nonatomic, copy) NSString *subDisplayString;

@end

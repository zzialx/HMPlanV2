//
//  WSHOrderCellModel.h
//  WinSFA
//
//  Created by HZH on 2017/7/23.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSHOrderCellModel : NSObject

@property (nonatomic, strong) WSProdBean *prodBean;
@property (nonatomic, strong) NSArray *paramArray;
@property (nonatomic, strong) NSArray *paramValueArray;

@property (nonatomic, copy) NSString *totalStr;

@end

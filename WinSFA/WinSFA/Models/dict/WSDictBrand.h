//
//  DictBrand.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSDictBean.h"

@interface WSDictBrand : NSObject

@property (nonatomic, strong) WSDictBean *dictBean;

@property (nonatomic, strong) NSMutableArray    *subDictBrandsArray;
@property (nonatomic, strong) NSMutableArray    *prodArray;

- (id)initWithDict:(WSDictBean *)dict DictArray:(NSArray *)dictArray;
@end

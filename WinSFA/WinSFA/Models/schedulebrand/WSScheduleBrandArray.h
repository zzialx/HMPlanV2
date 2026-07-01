//
//  WSScheduleBrandArray.h
//  WinSFA
//
//  Created by xiaotang.wang on 7/24/13.
//  Copyright (c) 2013 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSScheduleBrandArray : NSObject

@property (nonatomic, strong)NSMutableArray *iBrandInfos;

- (id)initWithObject:(id)aObject;

- (NSString *)getBrandNameByBrandId:(NSString *)aBrandId;

@end

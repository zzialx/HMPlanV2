//
//  DictBeanArray.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSDictBeanArray : NSObject

@property (nonatomic, strong) NSMutableArray *dictArray;

- (id)initWithObject:(id)object;

- (NSArray *)getDictsWithFilter:(NSString *)filter;
- (NSArray *)getProdsBrandByFilter:(NSString *)filter;
- (NSString *)getBrandIdByFilter:(NSString *)aFilter  searchQuestion:(NSString *)searchQuestion;
- (NSArray *)getDictsWithParentId:(NSString *)aId andFilter:(NSString *)afilter;
- (WSDictBean *)getDictWithByDictCode:(NSString *)filter;
@end

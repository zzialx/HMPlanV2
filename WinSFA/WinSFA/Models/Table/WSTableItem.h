//
//  WSTableItem.h
//  WinSFA
//
//  Created by ZhengJiepeng on 13-7-24.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>



@class WSFuncsBean,WSFuncsBean_opt;

@interface WSTableItem : NSObject

@property (nonatomic, copy, readonly) NSString *mc;
@property (nonatomic, copy, readonly) NSString *fCharNum;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, strong, readonly) WSFuncsBean_opt *opt;
@property (nonatomic, copy, readonly) NSString *filter;
@property (nonatomic, copy, readonly) NSString *required;
@property (nonatomic, copy, readonly) NSString *maxRow;
@property (nonatomic, copy, readonly) NSString *ds;
@property (nonatomic, copy, readonly) NSString *dateTyp;
@property (nonatomic, copy, readonly) NSString *isMore;
@property (nonatomic, strong, readonly) NSArray  *paramArray;
@property (nonatomic, copy, readonly) NSString *showThumbnail;

@property (nonatomic, readonly, strong) WSFuncsBean *funcsBean;

- (id)initWithObject:(id)object;

- (instancetype)initWithFuncsBean:(WSFuncsBean *)funcsBean;

- (instancetype)initWithFuncsBean:(WSFuncsBean *)funcsBean param:(NSArray *)params;

@end

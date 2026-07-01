//
//  WSLocation.h
//  WinSFA
//
//  Created by ZhengJiepeng on 13-8-16.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSLocation : NSObject

@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *cityCode;

- (id)initWithObject:(id)object;

@end

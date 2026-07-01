//
//  WSSubmicsBean.h
//  WinSFA
//
//  Created by zhangke on 14-5-16.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSSubempstoreBeanArray.h"


@interface WSSubmicsBean : NSObject <NSCopying>


@property (nonatomic, copy) NSString  *empId;
@property (nonatomic, copy) NSString  *id_;
@property (nonatomic, copy) NSString  *name;
@property (nonatomic, copy) NSString  *code;
@property (nonatomic, copy) NSString  *level_code;
@property (nonatomic, copy) NSString  *sub_level_code;
@property (nonatomic, copy) NSString  *org_id;
@property (nonatomic, copy) NSString  *org_name;

@property (nonatomic, strong) WSSubempstoreBeanArray * subempStoreArray;

@property (nonatomic, assign) BOOL bPlanned;


- (id)initWithObject:(id)object;


@end

//
//  StoreInfoBean.h
//  WinChannelFrameWork
//
//  Created by wdy on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSStoreInfoBean : NSObject

@property (nonatomic, copy) NSString    *Id;
@property (nonatomic, copy) NSString    *empId;
@property (nonatomic, copy) NSString    *storeId;
@property (nonatomic, copy) NSString    *col1;
@property (nonatomic, copy) NSString    *col2;
@property (nonatomic, copy) NSString    *col3;
@property (nonatomic, copy) NSString    *col4;
@property (nonatomic, copy) NSString    *col5;
@property (nonatomic, copy) NSString    *typ;
@property (nonatomic, copy) NSString    *typid;
@property (nonatomic, copy) NSString    *info_type;
@property (nonatomic, copy) NSString    *col_name;
@property (nonatomic, copy) NSString    *col_value;
@property (nonatomic, copy) NSString    *emp_or_store_id;
@property (nonatomic, copy) NSString    *group_id;

- (id)initWithObject:(id)object;

@end

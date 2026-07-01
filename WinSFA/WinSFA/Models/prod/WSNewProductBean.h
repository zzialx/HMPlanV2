//
//  NewProductBean.h
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 8/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSNewProductBean : NSObject

@property (nonatomic, copy)NSString* iProductId;
@property (nonatomic, copy)NSString* iProductName;
@property (nonatomic, copy)NSString* iProductShortName;
@property (nonatomic, copy)NSString* iMemo;
@property (nonatomic, copy)NSString* iProductType;
@property (nonatomic, assign)BOOL isPlan; // 计划内:1 计划外:0
@property (nonatomic, copy)NSString* iStoreId;
@property (nonatomic, copy)NSString* iUpdateIdMd5; // when update product use it to update

- (id)init;

@end

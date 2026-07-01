//
//  MsgsBean.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSMsgsBean : NSObject

@property (nonatomic, copy, readonly) NSString          *cod;
@property (nonatomic, copy, readonly) NSString          *empId;
@property (nonatomic, copy, readonly) NSString          *Id;
@property (nonatomic, copy, readonly) NSString          *k;
@property (nonatomic, copy, readonly) NSString          *name;
@property (nonatomic, copy, readonly) NSString          *icon_url;
@property (nonatomic, strong, readonly) NSMutableArray  *msg;

- (id)initWithObject:(id)object;

- (id)initWithObject:(id)object storeId:(NSString*)storeId;

@end

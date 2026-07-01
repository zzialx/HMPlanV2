//
//  PromBean.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSPromBean : NSObject

@property (nonatomic, copy, readonly) NSString          *efrdat;
@property (nonatomic, copy, readonly) NSString          *eftdat;
@property (nonatomic, copy, readonly) NSString          *empId;
@property (nonatomic, copy, readonly) NSString          *Id;
@property (nonatomic, copy, readonly) NSString          *name;
@property (nonatomic, strong, readonly) NSMutableArray  *opt;

- (id)initWithObject:(id)object;

@end

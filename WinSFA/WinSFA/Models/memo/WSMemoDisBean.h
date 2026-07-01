//
//  MemoDisBean.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSMemoDisBean : NSObject

@property (nonatomic, strong, readonly) NSString        *Id;
@property (nonatomic, strong, readonly) NSDictionary    *memos;

- (id)initMemoWithObject:(id)object;

@end

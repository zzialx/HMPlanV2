//
//  WSAcvtListFlag.h
//  WinSFA
//
//  Created by zhangke on 14/6/27.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSAcvtListFlag : NSObject

@property (nonatomic, copy, readonly) NSString          *acvtId;
@property (nonatomic, copy, readonly) NSString          *memo;
@property (nonatomic, copy, readonly) NSString          *storeId;
@property (nonatomic, copy, readonly) NSString          *empId;

- (id)initWithObject:(id)object;

@end

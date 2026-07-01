//
//  WSAcvtListFlagArray.h
//  WinSFA
//
//  Created by zhangke on 14/6/27.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSAcvtListFlagArray : NSObject
{
    NSMutableArray *acvtArray;
}
@property (nonatomic, strong) NSMutableArray *acvtArray;

- (id)initWithObject:(id)object;

- (id)initWithObjectEcho:(id)object;

@end

//
//  NSMutableDictionary+SafeOperation.h
//  WinCore
//
//  Created by heju on 4/4/14.
//  Copyright (c) 2014 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (SafeOperation)
/**
 *安全的添加成员（含空判断）
 */
-(void)setObjectSafe:(id)obj forKey:(id <NSCopying>)aKey;
@end

//
//  NSMutableDictionary+SafeOperation.m
//  WinCore
//
//  Created by heju on 4/4/14.
//  Copyright (c) 2014 WinChannel. All rights reserved.
//

#import "NSMutableDictionary+SafeOperation.h"

@implementation NSMutableDictionary (SafeOperation)
-(void)setObjectSafe:(id)anObject forKey:(id <NSCopying>)aKey{
    if(aKey == nil){
        return;
    }
    if(anObject == nil){
//        [self setObject:[NSNull null] forKey:key];
//        LogWarn(@"%@ is nil!!!",aKey);
        return;
    }
    [self setObject:anObject forKey:aKey];
}
@end

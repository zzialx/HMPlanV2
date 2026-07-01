//
//  WSStoreDataSource.m
//  WinSFA
//
//  Created by dujinfeng481 on 14-7-21.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSStoreDataSource.h"
#import "WSStoreBean.h"

@implementation WSStoreDataSource

-(id)initWithDicArray:(NSArray*)dicArray withNoteName:(NSString*)nameStr
{
    if (!dicArray) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _storesArray = [[NSMutableArray alloc] init];
        self.noteName = nameStr;
        if (dicArray && [dicArray isKindOfClass:[NSArray class]]) {
            for (int i = 0; i < [dicArray count]; i++) {
                WSStoreBean *store = [[WSStoreBean alloc] initStoreWithObject:[dicArray objectAtIndex:i]
                                                                       IsPlan:NO
                                                                     noteName:self.noteName];
                if (store) {
                    [_storesArray addObject:store];
                }
            }
        }
    }
    
    return self;
}

@end

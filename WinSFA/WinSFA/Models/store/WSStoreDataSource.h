//
//  WSStoreDataSource.h
//  WinSFA
//
//  Created by dujinfeng481 on 14-7-21.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#define NEWSTORE     @ "newstore"

#import <Foundation/Foundation.h>

@interface WSStoreDataSource : NSObject

@property (nonatomic, strong, readonly) NSMutableArray *storesArray;        //WSStoreBean对象数组
@property (nonatomic, strong) NSString *noteName;

-(id)initWithDicArray:(NSArray*)dicArray withNoteName:(NSString*)nameStr;

@end

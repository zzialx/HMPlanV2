//
//  SubempstoreBeanArray.h
//  WinChannelFrameWork
//
//  Created by wdy on 12-3-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSSubempstoreBean.h"
#define SUBEMPSTORES    @ "subempstore"
#define SUBEMPSTORES_EMP @"subempstore:emp"
#define SUBEMPSTORES1   @ "subempstore1"
#define SUBEMPSTOREDOC  @ "subempstoredoc"
#define SUBEMPSTOREINPLAN     @ "subempstoreinplan"
#define SUBEMPSTOREOUTPLAN    @ "subempstoreoutplan"

@interface WSSubempstoreBeanArray : NSObject

@property (nonatomic, strong) NSMutableArray *subempstoreArray;

- (id)initWithObject:(id)object;
- (id)initWithObject:(id)object noteName:(NSString *)aNoteName;

- (WSSubempstoreBean *)getSubempstoreById:(NSString *)anId;

@end

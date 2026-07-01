//
//  I_W_Cell.h
//  WinSFA
//
//  Created by winchannel on 15/4/27.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#ifndef WinSFA_I_W_Cell_h
#define WinSFA_I_W_Cell_h

#define kRootSubLevel           @"1"    // 根结点的 SubLevel 是 1

@protocol I_W_Cell <NSObject>

@optional
-(NSString *)getTtitle;

-(NSString *)getCode;

-(NSString *)getName;

-(NSString *)getOrgName;

-(NSString *)getOrgCode;

-(NSArray *)getCellContentArray;

-(NSInteger)getAccessStatus;

-(NSString *)getLevelCode;

- (NSString *)getSub_Level_Code;

-(NSArray *)getSonBean;

-(BOOL)getIsExpland;

- (NSString *)getPid;

- (NSString *)getId;

- (void)setIsExpland:(BOOL)isExpland;

- (void)setLevel_code:(NSString *)level_code;

- (void)setSonBean:(NSMutableArray *)sonBean;

- (void)setOptioned:(BOOL)isOptioned;

- (BOOL)getOptioned;

- (NSString *)getStyp;

- (BOOL)getIsAllExpand;

- (void)setIsAllExpand:(BOOL)isAllExpand;

- (NSString *)getLeafNode;

@end

#endif

//
//  I_W_OptionDataItem.h
//  WinSFA
//
//  Created by yang on 15-3-25.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#ifndef WinSFA_I_W_OptionDataItem_h
#define WinSFA_I_W_OptionDataItem_h

@protocol I_W_OptionDataItem <NSObject>

- (NSString *)getDataItemID;

- (NSString *)getDataItemName;

- (NSString *)getCacheKeyID;


@optional

- (void)setSelectedStatus:(BOOL)status;

- (BOOL)getSelectedStatus;

- (NSString *)getDataItemPic;

- (BOOL)isDataItemRequired;

- (NSString *)getDataItemDescName;

- (NSString *)getDataItemUrl;

- (NSString *)getDataItemMemo;


@end


#endif

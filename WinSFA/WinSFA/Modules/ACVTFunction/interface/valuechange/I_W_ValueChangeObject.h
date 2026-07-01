//
//  I_W_ValueChangeObject.h
//  WinSFA
//
//  Created by yang on 15/7/16.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol I_W_ValueChangeObject <NSObject>

- (NSObject *)getOriginalValue;

- (NSObject *)getCurrentValue;

- (BOOL)isEdited;

@end

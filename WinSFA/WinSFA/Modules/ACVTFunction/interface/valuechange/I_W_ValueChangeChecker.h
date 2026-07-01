//
//  I_W_ValueChangeChecker.h
//  WinSFA
//
//  Created by yang on 15/7/16.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "I_W_ValueChangeObject.h"

@protocol I_W_ValueChangeChecker <NSObject>

- (BOOL)checkValueIsChange:(NSObject <I_W_ValueChangeObject> *)object;

@end

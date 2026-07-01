//
//  WSBaseChecker.h
//  WinSFA
//
//  Created by yang on 15/6/4.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "I_Checker.h"

@interface WSBaseChecker : NSObject<I_Checker>

@property (nonatomic, weak) NSObject<I_Checker_Delegate> *delegate;

@end

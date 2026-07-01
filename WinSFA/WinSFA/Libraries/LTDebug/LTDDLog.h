//
//  LTDDLog.h
//  LTDebug
//
//  Created by Alicia on 2017/3/5.
//  Copyright © 2017年 WinChannel. All rights reserved.
//
#import "DDLog.h"
#import <Foundation/Foundation.h>
#import "LTDDLogModel.h"

@interface LTDDLog : NSObject

- (void)addLogModel:(LTDDLogModel *)logModel;
- (NSArray *)getLogs;
- (void)clearLog;

@end

//
//  LTDDLogModel.h
//  LTDebug
//
//  Created by Alicia on 2017/3/5.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LTDDLogModel : NSObject <NSCoding>

@property (nonatomic, assign) DDLogFlag logFlag;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *function;

- (instancetype)initWithLogFlag:(DDLogFlag)logFlag message:(NSString *)message function:(NSString *)function;

@end

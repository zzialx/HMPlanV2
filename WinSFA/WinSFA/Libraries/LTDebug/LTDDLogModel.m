//
//  LTDDLogModel.m
//  LTDebug
//
//  Created by Alicia on 2017/3/5.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "LTDDLogModel.h"


static NSString * const kFlagKey = @"LogFlag";
static NSString * const kMessageKey = @"LogMessage";
static NSString * const kFunctionKey = @"LogFunction";

@implementation LTDDLogModel


- (instancetype)initWithLogFlag:(DDLogFlag)logFlag message:(NSString *)message function:(NSString *)function {
    self = [super init];
    if (self) {
        self.logFlag = logFlag;
        self.message = message;
        self.function = function;
    }
    return self;
}


#pragma mark - Archiving

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _logFlag = [aDecoder decodeIntegerForKey:kFlagKey];
        _message = [aDecoder decodeObjectForKey:kMessageKey];
        _function = [aDecoder decodeObjectForKey:kFunctionKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.logFlag forKey:kFlagKey];
    [aCoder encodeObject:self.message forKey:kMessageKey];
    [aCoder encodeObject:self.function forKey:kFunctionKey];
}

@end

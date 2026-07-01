//
//  LTDDLog.m
//  LTDebug
//
//  Created by Alicia on 2017/3/5.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "LTDDLog.h"
#import "LTDebugView.h"


static NSString * const kFileName = @"/LTDDLog.data";
@implementation LTDDLog

#pragma mark - Public Method
- (void)addLogModel:(LTDDLogModel *)logModel {
    if (logModel.logFlag == DDLogFlagError) {
        UILabel *errorLabel = [LTDebugView sharedInstance].errorLabel;
        NSInteger errorNum = [errorLabel.text integerValue];
        [self setErrorNumber:++errorNum];
    }

    if (logModel.logFlag == DDLogFlagWarning || logModel.logFlag == DDLogFlagError) {
        [[LTDebugView sharedInstance] showThenHideWindow];
        
        [self setOther:logModel.message];

        [self archiveLogModel:logModel];
    }
}

- (void)setErrorNumber:(NSInteger)errorNum {
    UILabel *errorLabel = [LTDebugView sharedInstance].errorLabel;
    [errorLabel setText:[NSString stringWithFormat:@"%ld", (long)errorNum]];
}

- (void)setOther:(NSString *)other {
    UILabel *otherLabel = [LTDebugView sharedInstance].otherLabel;
    [otherLabel setText:[NSString stringWithFormat:@"%@", other]];

}

- (NSArray *)getLogs {
    NSArray * logArray =  [self unArchiveLog];
    if (!logArray) {
        logArray = [[NSArray alloc] init];
    }
    return logArray;
}


- (void)clearLog {
    NSString *filePath = [self getFilePath];
    [NSKeyedArchiver archiveRootObject:[NSArray array] toFile:filePath];
    
    [self setErrorNumber:0];
    [self setOther:@"..."];
}
#pragma mark - Private Method

- (NSString *)getFilePath {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingString:kFileName];
}

- (void)archiveLogModel:(LTDDLogModel *)logModel {
    NSArray *logArray = [self unArchiveLog];
    NSMutableArray *newLogArray;
    if (logArray) {
        newLogArray = [NSMutableArray arrayWithArray:logArray];
        [newLogArray addObject:logModel];
    } else {
        newLogArray = [NSMutableArray arrayWithObject:logModel];
    }
    
    NSString *filePath = [self getFilePath];
    [NSKeyedArchiver archiveRootObject:newLogArray toFile:filePath];
}

- (NSArray *)unArchiveLog {
    NSString *filePath = [self getFilePath];
    NSArray *logArray = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    return logArray;
}

@end

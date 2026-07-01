//
//  WCLogManager.h
//  WinSFA
//
//  Created by yang on 13-7-12.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kUploadAllLogDataFinishNotifyName @"UploadAllLogDataFinishNotifyName"
#define kUploadImageNilFinishNotifyName @"kUploadImageNilFinishNotifyName"
#define kUploadAllLogDataResultKey @"UploadAllLogDataResultIsSuccess"


typedef enum UploadLogTyped_
{
    UploadLogTypedAll,
    UploadLogTypedCrash,
    UploadLogTypedImageNilError
}UploadLogTyped;


@interface WCLogManager : NSObject

@property (nonatomic, copy) NSString *selErrorDate;//选中上传error的日期 yy-mm-dd
@property (nonatomic, copy) NSString *selCrashDate;//选中的crash日期 ,yymmdd


+ (WCLogManager*)sharedInstance;

- (void)setUpUncaughtExceptionHandler;

- (void)setUpDDlogger;

- (void)addCrashLog:(NSString*)crashLog;

/**
 * 上传日志
 *
 * @param isOnlyUploadCrashLog 是否仅上传崩溃日志
 *
 **/
- (void)startUploadLog:(UploadLogTyped)uploadLogTyped;

- (void)saveEmpIDAndEmpName;

- (NSString*)getEmpID;

- (NSString*)getEmpName;

//判断指定日期是否有日志，有yes
-(BOOL)checkIsHasData ;
@end

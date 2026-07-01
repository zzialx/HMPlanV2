//
//  WSFileCleanupManager.m
//

#import "WSFileCleanupManager.h"
#import "FCFileManager.h"

@implementation WSFileCleanupManager

#pragma mark - Public Methods
+ (void)cleanupFoldersInPath:(NSString *)basePath
                 daysToKeep:(NSInteger)daysToKeep
                 completion:(void(^)(BOOL success, NSInteger deletedCount, NSError *error))completion {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        NSInteger deletedCount = 0;
        BOOL success = YES;
        
        @try {
            // 检查基础路径是否存在
            if (![FCFileManager existsItemAtPath:basePath]) {
                LogError(@"FileCleanupManager: 基础路径不存在: %@", basePath);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(YES, 0, nil); // 路径不存在也算成功，删除数量为0
                    }
                });
                return;
            }
            
            // 获取截止日期
            NSString *cutoffDateString = [self getDateStringBeforeDays:daysToKeep];
            LogInfo(@"FileCleanupManager: 开始清理 %@ 之前的文件夹，截止日期: %@", basePath, cutoffDateString);
            
            // 获取所有子文件夹
            NSArray *subItems = [FCFileManager listItemsInDirectoryAtPath:basePath deep:NO];
            
            for (NSString *itemFilePath in subItems) {
                NSString *itemPath =  itemFilePath;
                NSString * itemName = itemPath.lastPathComponent;
                // 检查是否为文件夹
                if ([FCFileManager existsItemAtPath:itemPath]) {
                    // 检查文件夹名是否为日期格式
                    if ([self isValidDateFolderName:itemName]) {
                        // 比较日期
                        if ([self shouldDeleteFolderWithName:itemName cutoffDate:cutoffDateString]) {
                            LogInfo(@"FileCleanupManager: 准备删除文件夹: %@", itemPath);
                            
                            // 删除文件夹
                            if ([FCFileManager removeItemAtPath:itemPath]) {
                                deletedCount++;
                                LogInfo(@"FileCleanupManager: 成功删除文件夹: %@", itemPath);
                            } else {
                                LogError(@"FileCleanupManager: 删除文件夹失败: %@", itemPath);
                                success = NO;
                            }
                        } else {
                            LogInfo(@"FileCleanupManager: 保留文件夹: %@ (在保留期内)", itemPath);
                        }
                    } else {
                        LogInfo(@"FileCleanupManager: 跳过非日期格式文件夹: %@", itemName);
                    }
                }else{
                    LogError(@"文件夹:%@,不是文件夹",itemPath);
                }
            }
            
        } @catch (NSException *exception) {
            LogError(@"FileCleanupManager: 清理过程中发生异常: %@", exception.reason);
            error = [NSError errorWithDomain:@"FileCleanupManager"
                                        code:-1
                                    userInfo:@{NSLocalizedDescriptionKey: exception.reason}];
            success = NO;
        }
        
        // 回到主线程执行回调
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(success, deletedCount, error);
            }
        });
    });
}

+ (void)cleanupDefaultShareFoldersWithCompletion:(void(^)(BOOL success, NSInteger deletedCount, NSError *error))completion {
    NSString *shareFolderPath = [self getShareFolderPath];
    [self cleanupFoldersInPath:shareFolderPath daysToKeep:7 completion:completion];
}

+ (NSString *)getShareFolderPath {
    NSString *documentsPath = [FCFileManager pathForDocumentsDirectory];
    return [documentsPath stringByAppendingPathComponent:@"share"];
}

+ (NSString *)getDateStringBeforeDays:(NSInteger)days {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *targetDate = [calendar dateByAddingUnit:NSCalendarUnitDay
                                              value:-days
                                             toDate:[NSDate date]
                                            options:0];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter stringFromDate:targetDate];
}

+ (BOOL)isValidDateFolderName:(NSString *)folderName {
    
    if (!folderName || folderName.length != 10) {
        return NO;
    }
    
    // 检查格式是否为 yyyy-MM-dd
    NSString *pattern = @"^\\d{4}-\\d{2}-\\d{2}$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:0
                                                                             error:nil];
    NSUInteger matches = [regex numberOfMatchesInString:folderName
                                                options:0
                                                  range:NSMakeRange(0, folderName.length)];
    
    if (matches == 0) {
        return NO;
    }
    
    // 进一步验证是否为有效日期
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formatter dateFromString:folderName];
    
    return date != nil;
}

#pragma mark - Private Methods

+ (BOOL)shouldDeleteFolderWithName:(NSString *)folderName cutoffDate:(NSString *)cutoffDate {
    // 字符串比较，因为日期格式为 yyyy-MM-dd，可以直接进行字符串比较
    NSComparisonResult result = [folderName compare:cutoffDate];
    return result == NSOrderedAscending; // folderName < cutoffDate
}

@end

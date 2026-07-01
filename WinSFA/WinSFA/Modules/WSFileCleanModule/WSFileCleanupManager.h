//
//  WSFileCleanupManager.h
//

#import <Foundation/Foundation.h>

@interface WSFileCleanupManager : NSObject

/**
 * 清理指定天数之前的文件夹
 * @param basePath 基础路径，例如：/xxx/Documents/share/
 * @param daysToKeep 保留天数，例如：7（清理7天前的文件夹）
 * @param completion 完成回调，返回清理结果和错误信息
 */
+ (void)cleanupFoldersInPath:(NSString *)basePath
                 daysToKeep:(NSInteger)daysToKeep
                 completion:(void(^)(BOOL success, NSInteger deletedCount, NSError *error))completion;

/**
 * 清理默认分享文件夹（7天前的文件夹）
 * @param completion 完成回调
 */
+ (void)cleanupDefaultShareFoldersWithCompletion:(void(^)(BOOL success, NSInteger deletedCount, NSError *error))completion;

/**
 * 获取文档目录下的分享文件夹路径
 * @return 分享文件夹完整路径
 */
+ (NSString *)getShareFolderPath;

/**
 * 获取指定天数之前的日期字符串
 * @param days 天数
 * @return 日期字符串，格式：yyyy-MM-dd
 */
+ (NSString *)getDateStringBeforeDays:(NSInteger)days;

/**
 * 检查文件夹名是否为有效的日期格式
 * @param folderName 文件夹名称
 * @return 是否为有效日期格式
 */
+ (BOOL)isValidDateFolderName:(NSString *)folderName;

@end

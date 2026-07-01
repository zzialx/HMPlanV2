//
//  WSFileCleanupConfig.h
//  可配置的清理配置类
//

#import <Foundation/Foundation.h>

@interface WSFileCleanupConfig : NSObject

@property (nonatomic, assign) NSInteger daysToKeep;           // 保留天数
@property (nonatomic, strong) NSString *basePath;            // 基础路径
@property (nonatomic, assign) BOOL enableLogging;            // 是否启用日志
@property (nonatomic, assign) BOOL dryRun;                   // 是否为试运行（不实际删除）

/**
 * 创建默认配置
 */
+ (instancetype)defaultConfig;

/**
 * 创建自定义配置
 */
+ (instancetype)configWithDaysToKeep:(NSInteger)days basePath:(NSString *)path;

@end

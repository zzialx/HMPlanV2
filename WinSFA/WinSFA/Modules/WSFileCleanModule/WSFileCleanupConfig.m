//
//  WSFileCleanupConfig.m
//

#import "WSFileCleanupConfig.h"
#import "WSFileCleanupManager.h"

@implementation WSFileCleanupConfig

+ (instancetype)defaultConfig {
    WSFileCleanupConfig *config = [[WSFileCleanupConfig alloc] init];
    config.daysToKeep = 7;
    config.basePath = [WSFileCleanupManager getShareFolderPath];
    config.enableLogging = YES;
    config.dryRun = NO;
    return config;
}

+ (instancetype)configWithDaysToKeep:(NSInteger)days basePath:(NSString *)path {
    WSFileCleanupConfig *config = [[WSFileCleanupConfig alloc] init];
    config.daysToKeep = days;
    config.basePath = path;
    config.enableLogging = YES;
    config.dryRun = NO;
    return config;
}

@end

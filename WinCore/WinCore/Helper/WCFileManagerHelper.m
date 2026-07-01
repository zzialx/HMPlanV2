//
//  RSDataPersistenceAssistant.m
//  x2
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

// 数据持久化存放的目录
#define kPersistDir  @"persist"

#import "WCFileManagerHelper.h"

@implementation WCFileManagerHelper

//从文件中取得用户信息
+ (NSObject *)objectForKey:(NSString *)key userId:(long long)userId {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self dataFilePathForKey:key userId:userId]];
}

//向文件中写入用户信息
+ (BOOL)setObject:(NSObject *)value forKey:(NSString *)key userId:(long long)userId {
    
    NSError *error = nil;
    
    if (![[NSFileManager defaultManager] createDirectoryAtPath:[self persistFileDir] withIntermediateDirectories:YES attributes:nil error:&error]) {
        LogError(@"创建用户文件目录失败");
        return NO;
    }
    return [NSKeyedArchiver archiveRootObject:value toFile:[self dataFilePathForKey:key userId:userId]];
}

#pragma mark - private mehtod
+ (NSString *)dataFilePathForKey:(NSString *)key userId:(long long)userId {
    NSString *documentDirectory = [self documentsDir];
    NSString *dir = [NSString stringWithFormat:@"%@/%@/X2_persistence_%@_object_%@", documentDirectory, kPersistDir,
                     [NSString stringWithFormat:@"%lld",userId], key];
    return dir;
}

+ (NSString *)persistFileDir {
    NSString *documentDirectory = [self documentsDir];
    NSString *dir = [documentDirectory stringByAppendingPathComponent:kPersistDir];
    return dir;
}

#pragma mark - file path
+ (NSString *)documentsDir {
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([searchPaths count] > 0) {
        return [searchPaths objectAtIndex:0];
    }
    else {
        return nil;
    }
}
@end

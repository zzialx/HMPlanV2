//
//  FileManager.h
//  WinChannelIPhone
//
//  Created by winchannel on 11-10-12.
//  Copyright 2011年 Winchannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject
{}
+ (NSString *)setPath:(NSString *)fileName;
+ (NSInteger)getAllFilesCount:(NSString *)filePath;
+ (NSInteger)getCurrentFilesCount:(NSString *)filePath;
+ (NSArray *)getDirAllFilesName:(NSString *)filePath;
+ (NSArray *)getCurrentFilesName:(NSString *)filePath;
+ (BOOL)writeFileToEnd:(NSString *)fileName data:(NSData *)data;
+ (BOOL)writeFileAndCover:(NSString *)fileName data:(NSData *)data;
+ (NSString *)readFileContent:(NSString *)fileName;
+ (BOOL)deleFileWithName:(NSString *)fileName;
+ (NSObject *)getUserDefaults:(NSString *)name;
+ (void)setUserDefaults:(NSObject *)defaults forKey:(NSString *)key;
+ (void)removeDefaultsByKey:(NSString *)aKey;
+ (NSString*)Documents;
@end

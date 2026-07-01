//
//  FileManager.m
//  WinChannelIPhone
//
//  Created by winchannel on 11-10-12.
//  Copyright 2011年 Winchannel. All rights reserved.
//

#import "FileManager.h"

@implementation FileManager

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (NSString*)setPath:(NSString*)fileName
{
    //将数据库创建在／Library/Caches
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataBasePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    return dataBasePath;
}

//Documents
+(NSString*)Documents
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSLog(@"documentsDirectory:%@", documentsDirectory);
    return documentsDirectory;
}
// 获取程序app文件所在目录路径
+(NSString*)AppPath
{
    return NSHomeDirectory();
}

//Library/Caches
+(NSString*)Library
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
    NSString *lib = [paths objectAtIndex:0];
    return lib;
}

// temp
+(NSString*)temp
{
    return NSTemporaryDirectory();
}

// 获取程序应用包路径resourcePath
+(NSString*)resourcePath
{
    return [[NSBundle mainBundle] resourcePath];
}


/*
 *创建一个目录   未测试
 */

+(BOOL)CreateDirectoryAtPath:(NSString*)Path
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
   return [fileManager createDirectoryAtPath:Path withIntermediateDirectories:YES attributes:nil error:nil];
}
/*
 * 返回目下的所有文件名包括下级目录的文件
 */
+ (NSInteger)getAllFilesCount:(NSString*)filePath 
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator* fileEnumerator= [fileManager enumeratorAtPath:filePath];
    int count = 0;
    while ([fileEnumerator nextObject]!=nil) {
        count++;
    }
    return count;
}


+ (NSArray*)getDirAllFilesName:(NSString*)filePath
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator* fileEnumerator= [fileManager enumeratorAtPath:filePath];
    NSMutableArray* fileArray = [[NSMutableArray alloc]init];
    NSString* fileName ;
    
    while ((fileName = [fileEnumerator nextObject])!= nil) {
        [fileArray addObject:fileName];
    }
    return fileArray;
}


/*
 返回当前目录的文件个数，不返回下级目录的文件数
 */
+ (NSInteger)getCurrentFilesCount:(NSString*)filePath
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    //此方法高版本的sdk已不再使用
//    NSArray* fileArray= [fileManager directoryContentsAtPath:path];
    NSError* error = [[NSError alloc]init];
    NSArray* fileArray = [fileManager contentsOfDirectoryAtPath:filePath error:&error];
    if(!error)
        return [fileArray count];
    else
        return 0;
}


+ (NSArray*)getCurrentFilesName:(NSString*)filePath
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError* error = [[NSError alloc]init];
    NSArray* fileArray = [fileManager contentsOfDirectoryAtPath:filePath error:&error];
    if(!error)
        return fileArray ;
    else
        return nil;
}

//在文件后追加内容
+ (BOOL)writeFileToEnd:(NSString*)fileName data:(NSData*)data
{
    NSFileManager* fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:fileName])
        [fm createFileAtPath:fileName contents:nil attributes:nil];
    NSFileHandle* fh = [NSFileHandle fileHandleForWritingAtPath:fileName];
    if(fh == nil)
    {
        [fh closeFile];
        return NO;
    }
    
    //将文件设置成offset大小
//    [fh truncateFileAtOffset:[fh offsetInFile]];
    [fh seekToEndOfFile];
    [fh writeData:data];
    [fh closeFile];
    return YES;
}

//对同一个文件总是覆盖
+ (BOOL)writeFileAndCover:(NSString*)fileName data:(NSData*)data
{
    NSFileManager* fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:fileName])
        [fm createFileAtPath:fileName contents:nil attributes:nil];
    else
    {
        [self deleFileWithName:fileName];
        [fm createFileAtPath:fileName contents:nil attributes:nil];
    }
    NSFileHandle* fh = [NSFileHandle fileHandleForWritingAtPath:fileName];
    if(fh == nil)
    {
        [fh closeFile];
        return NO;
    }
    
    //将文件设置成offset大小
    //    [fh truncateFileAtOffset:[fh offsetInFile]];
    [fh seekToEndOfFile];
    [fh writeData:data];
    [fh closeFile];
    return YES;
}


+ (NSString* )readFileContent:(NSString*)fileName 
{
    //NSLog(@"filename is = %@",fileName);
    NSFileHandle* fh = [NSFileHandle fileHandleForReadingAtPath:fileName];
    if(fh == nil)
    {
        [fh closeFile];
        return nil;
    }
    NSData* data  = [fh readDataToEndOfFile];
    NSMutableString* content = [[NSMutableString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    [fh closeFile];
    return content;
}

+ (BOOL) deleFileWithName:(NSString*)fileName
{
    NSFileManager* fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:fileName])
    {
        [fm removeItemAtPath:fileName error:nil];
    
        return YES;
    }
    return YES;
}

+(NSObject *) getUserDefaults:(NSString *) name{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:name];
}

+(void) setUserDefaults:(NSObject *) defaults forKey:(NSString *) key{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:defaults forKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)removeDefaultsByKey:(NSString*)aKey
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:aKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


@end

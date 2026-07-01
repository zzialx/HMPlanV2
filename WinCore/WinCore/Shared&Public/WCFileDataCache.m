//
//  WCFileDataCache.m
//  RRSpring
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import "WCFileDataCache.h"
#include <CommonCrypto/CommonDigest.h>

#define kMp3FileExe @".mp3"

@interface WCFileDataCache ()
{
    NSOperationQueue *cacheQueue;
}

- (void)storeKeyWithDataToDisk:(NSArray *)keyAndData cacheType:(CacheType)cacheType;

- (NSString*)getStorePath:(CacheType)cacheType;
- (NSInteger)getMaxCacheFileNum:(CacheType)cacheType;
- (NSInteger)getDeleteCacheFileNum:(CacheType)cacheType;
- (NSInteger)getMaxCacheSpace:(CacheType)cacheType;
- (NSInteger)getMaxCacheTime:(CacheType)cacheType;
- (NSInteger)getMinCacheTime:(CacheType)cacheType;
@end

// ECacheTypeDownLoaded
const NSInteger cacheMaxCacheTime = 60*60*24*7; // 1 week
const NSInteger cacheMinCacheTime = 60*60*24; // 1 day

const NSInteger cacheMaxCacheSpace = 1024*100*200; // 100k data file , 200

const NSInteger cacheMaxFileNum = 300; // max file number
const NSInteger deleteCacheFileNum = 200; // delete file num one times

// ECacheTypeLocal
const NSInteger Local_CacheMaxCacheTime = 60*60*24*7; // 1 week
const NSInteger Local_CacheMinCacheTime = 60*60*24; // 1 day

const NSInteger Local_CacheMaxCacheSpace = 1024*100*30; // 100k data file , 200

const NSInteger Local_CacheMaxFileNum = 30; // max file number
const NSInteger Local_DeleteCacheFileNum = 1; // delete file num one times

// ECacheTypeTmp

const NSInteger Tmp_CacheMaxCacheTime = 60*60*24*7; // 1 week
const NSInteger Tmp_CacheMinCacheTime = 60*60*24; // 1 day

const NSInteger Tmp_CacheMaxCacheSpace = 1024*100*200; // 100k data file , 200

const NSInteger Tmp_CacheMaxFileNum = 300; // max file number
const NSInteger Tmp_DeleteCacheFileNum = 200; // delete file num one times


//#define CACHE_SUPPORT_SPACE_TIME_MANAGER

#define CACHE_SUPPORT_FILENUMBER_TIME_MANAGER

static WCFileDataCache *instance  =nil;


@implementation WCFileDataCache

@synthesize diskCachePath  =_diskCachePath;

+ (WCFileDataCache *)sharedInstance
{
    if (instance == nil)
    {
        instance = [[WCFileDataCache alloc] init];
    }
    
    return instance;
}

- (void)dealloc
{
    self.diskCachePath = nil;
    self.commentDiskCachePath = nil;
    self.downLoadingDiskCachePath = nil;
}

- (id)init
{
    if (self = [super init])
    {
        // Init the disk cache
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        self.diskCachePath =  [[paths objectAtIndex:0] stringByAppendingPathComponent:@"DLAudioCache"];
        self.commentDiskCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"LocalAudioCache"];
        self.downLoadingDiskCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"TmpAudioCache"];
                
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.diskCachePath])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:self.diskCachePath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:NULL];
        }
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.commentDiskCachePath])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:self.commentDiskCachePath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:NULL];
        }
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.downLoadingDiskCachePath])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:self.downLoadingDiskCachePath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:NULL];
        }
        
        cacheQueue = [[NSOperationQueue alloc] init];
        cacheQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)storeData:(NSData *)data forKey:(NSString *)key cacheType:(CacheType)cacheType
{
    if (!data || !key) {
        return;
    }

#ifdef CACHE_SUPPORT_SPACE_TIME_MANAGER
    NSInteger size = [self getSize:CacheType];
    NSInteger maxCacheSpace = [self getMaxCacheSpace:cacheType];
    if (size > maxCacheSpace) {
        [self cleanDisk:CacheType];
    }
#endif
    
#ifdef CACHE_SUPPORT_FILENUMBER_TIME_MANAGER
    NSInteger count = [self getDiskCount:cacheType];
    NSInteger maxCacheNum = [self getMaxCacheFileNum:cacheType];
    if (count >= maxCacheNum) {
        [self cleanDisk:cacheType];
    }
#endif
    
    NSArray *keyWithData;
    if (data)
    {
        keyWithData = [NSArray arrayWithObjects:key, data, nil];
    }
    else
    {
        keyWithData = [NSArray arrayWithObjects:key, nil];
    }

    [self storeKeyWithDataToDisk:keyWithData cacheType:cacheType];
//    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
//                                                                            selector:@selector(storeKeyWithDataToDisk:)
//                                                                              object:keyWithData];
//    [cacheQueue addOperation:operation];
}

- (NSString *)cachePathForKey:(NSString *)key cacheType:(CacheType)cacheType;
{
    if([key length] <= 0)
    {
        return nil;
    }
    const char *str = [key UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    filename = [filename stringByAppendingString:kMp3FileExe];
    NSString* storePath = [self getStorePath:cacheType];
    if (storePath) {
        return [storePath stringByAppendingPathComponent:filename];
    }
    
    return nil;
}

// Rename key map cache file name by naother key
- (void)renameCacheName:(NSString*)srcKey dst:(NSString*)dstKey cacheType:(CacheType)cacheType
{
    NSString* srcName = [self cachePathForKey:srcKey cacheType:cacheType];
    NSString* dstName = [self cachePathForKey:dstKey cacheType:cacheType];
    if ([[NSFileManager defaultManager] fileExistsAtPath:srcName]) {
        rename([srcName UTF8String], [dstName UTF8String]);
    }
}

- (void)moveFileToCache:(NSString*)srcFilePath dst:(NSString*)dstKey dstCacheType:(CacheType)dstCacheType
{
    if (nil ==srcFilePath || nil == dstKey) {
        return;
    }
    
    NSString* dstName = [self cachePathForKey:dstKey cacheType:dstCacheType];
    
    if (nil == dstName || [dstName length] <= 0) {
        return;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:srcFilePath]) {
        BOOL bRet = [[NSFileManager defaultManager] moveItemAtPath:srcFilePath toPath:dstName error:nil];
        if(!bRet)
        {
            NSLog(@"WCFileDataCache file remove failed");
        }
        
    }
    
}

- (void)removeCacheFile:(NSString*)srcKey srcCacheType:(CacheType)srcCacheType dst:(NSString*)dstKey dstCacheType:(CacheType)dstCacheType
{
    if (srcCacheType == dstCacheType) {
        [self renameCacheName:srcKey dst:dstKey cacheType:srcCacheType];
    }
    else
    {
        NSString* srcName = [self cachePathForKey:srcKey cacheType:srcCacheType];
        NSString* dstName = [self cachePathForKey:dstKey cacheType:dstCacheType];
        if ([[NSFileManager defaultManager] fileExistsAtPath:srcName]) {
            BOOL bRet = [[NSFileManager defaultManager] moveItemAtPath:srcName toPath:dstName error:nil];
            if(!bRet)
            {
                NSLog(@"WCFileDataCache file remove failed");
            }
            
        }
    }
}

// Rename a file with the new name
- (BOOL)renameFileName:(NSString *)oldName withNewName:(NSString *)newName
{
    BOOL ret = NO;
    if ( [[NSFileManager defaultManager] fileExistsAtPath:oldName] ) {
        ret = rename([oldName UTF8String], [newName UTF8String]) == 0 ? YES:NO;
    }
    
    return ret;
}

// The key map cache file exist?
- (BOOL)isCacheFileExistByKey:(NSString*)key cacheType:(CacheType)cacheType
{
    NSString* strFileName = [self cachePathForKey:key cacheType:cacheType];
    if (strFileName) {
         return [[NSFileManager defaultManager] fileExistsAtPath:strFileName];
    }
    return NO;
}

- (void)clearDisk:(CacheType)cacheType;
{
    NSString* storePath = [self getStorePath:cacheType];
    [[NSFileManager defaultManager] removeItemAtPath:storePath error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:storePath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
}


- (void)clearDiskWithBlock:(RRFileDataCacheRemoveBlock)removeBlock cacheType:(CacheType)cacheType;
{
    //clear dir
    @autoreleasepool {
        NSFileManager* fm = [NSFileManager defaultManager];
        NSError* err = nil;
        NSString* storePath = [self getStorePath:cacheType];
        NSArray *array = [fm contentsOfDirectoryAtPath:storePath error:nil];
        long long progress = 1;
        for(NSString *path in array){
            [fm removeItemAtPath:[storePath stringByAppendingPathComponent:path] error:&err];
            if (removeBlock) {
                removeBlock(progress++);
            }
        }

    }

}

- (void)cleanDisk:(CacheType)cacheType
{
#ifdef CACHE_SUPPORT_SPACE_TIME_MANAGER
    NSInteger maxCacheTime = [self getMaxCacheTime:cacheType];
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-maxCacheTime];
    
    NSString* path = [self getStorePath:cacheType];
    if (path) {
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
        for (NSString *fileName in fileEnumerator)
        {
            NSString *filePath = [path stringByAppendingPathComponent:fileName];
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            if ([[[attrs fileModificationDate] laterDate:expirationDate] isEqualToDate:expirationDate])
            {
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            }
        }
    }
#endif
    
#ifdef CACHE_SUPPORT_FILENUMBER_TIME_MANAGER
    
    NSInteger count = [self getDiskCount:cacheType];
    NSInteger maxCacheNum = [self getMaxCacheFileNum:cacheType];
    NSInteger deleteOneTimesNum = [self getDeleteCacheFileNum:cacheType];
    
    if (count < maxCacheNum) {
        return;
    }
    
    // sort file by modification date ascending
    NSString* storePath = [self getStorePath:cacheType];
    //NSURL *documentsURL = [NSURL URLWithString:storePath];
    NSURL *documentsURL = [NSURL fileURLWithPath:storePath isDirectory:YES];
    if (nil == documentsURL) {
        return;
    }
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:documentsURL
                                                              includingPropertiesForKeys:@[NSURLContentModificationDateKey]
                                                                                 options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                   error:nil];
    
    NSArray *sortedContent = [directoryContent sortedArrayUsingComparator:
                              ^(NSURL *file1, NSURL *file2)
                              {
                                  // compare
                                  NSDate *file1Date;
                                  [file1 getResourceValue:&file1Date forKey:NSURLContentModificationDateKey error:nil];
                                  
                                  NSDate *file2Date;
                                  [file2 getResourceValue:&file2Date forKey:NSURLContentModificationDateKey error:nil];
                                  
                                  // ascending:
                                  return [file1Date compare: file2Date];
                                  // descending:
                                  //return [file2Date compare: file1Date];
                              }];
    
    int deleteCount = 0;
    for (NSURL* filePath in sortedContent) {
        if (deleteCount >= deleteOneTimesNum) {
            break;
        }
        
        NSString* fileFullName = [filePath path];
        
        if (fileFullName != nil && [fileFullName length] > 0) {
            [[NSFileManager defaultManager] removeItemAtPath:fileFullName error:nil];
            deleteCount++;
        }
    }
    
#endif
}

- (int)getSize:(CacheType)cacheType
{
    int size = 0;
    
    NSString* path = [self getStorePath:cacheType];
    if (path) {
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
        for (NSString *fileName in fileEnumerator)
        {
            NSString *fileFullName = [path stringByAppendingPathComponent:fileName];
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:fileFullName error:nil];
            size += [attrs fileSize];
        }
    }
    return size;
}

- (int)getDiskCount:(CacheType)cacheType
{
    int count = 0;
    
    NSString* path = [self getStorePath:cacheType];
    if (path) {
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
        
        for (NSString *fileName in fileEnumerator)
        {
            count += 1;
        }
    }
    
    return count;
}

- (void)removeFileByKey:(NSString*)key cacheType:(CacheType)cacheType
{
    NSString* filePath = [self cachePathForKey:key cacheType:cacheType];
    if (filePath) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil]; 
    }
}

#pragma mark private
- (void)storeKeyWithDataToDisk:(NSArray *)keyAndData cacheType:(CacheType)cacheType;
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *key = [keyAndData objectAtIndex:0];
    NSData *data = [keyAndData count] > 1 ? [keyAndData objectAtIndex:1] : nil;
    if (key && data) {
        [fileManager createFileAtPath:[self cachePathForKey:key cacheType:cacheType] contents:data attributes:nil];
    }
}

- (NSString*)getStorePath:(CacheType)cacheType
{
    NSString* path = nil;
    switch (cacheType) {
        case ECacheTypeDownLoaded:
            path = [NSString stringWithString:self.diskCachePath];
            break;
        case ECacheTypeLocal:
            path = [NSString stringWithString:self.commentDiskCachePath];
            break;
        case ECacheTypeTmp:
            path = [NSString stringWithString:self.downLoadingDiskCachePath];
            break;
        default:
            path = [NSString stringWithString:self.diskCachePath];
            break;
    }
    return path;
}

- (NSInteger)getMaxCacheFileNum:(CacheType)cacheType
{
    NSInteger value = 0;
    switch (cacheType) {
        case ECacheTypeDownLoaded:
            value = cacheMaxFileNum;
            break;
        case ECacheTypeLocal:
            value = Local_CacheMaxFileNum;
            break;
        case ECacheTypeTmp:
            value = Tmp_CacheMaxFileNum;
            break;
        default:
            value = cacheMaxFileNum;
            break;
    }
    return value;
}

- (NSInteger)getDeleteCacheFileNum:(CacheType)cacheType
{
    NSInteger value = 0;
    switch (cacheType) {
        case ECacheTypeDownLoaded:
            value = deleteCacheFileNum;
            break;
        case ECacheTypeLocal:
            value = Local_DeleteCacheFileNum;
            break;
        case ECacheTypeTmp:
            value = Tmp_DeleteCacheFileNum;
            break;
        default:
            value = deleteCacheFileNum;
            break;
    }
    return value;
}
- (NSInteger)getMaxCacheSpace:(CacheType)cacheType
{
    NSInteger value = 0;
    switch (cacheType) {
        case ECacheTypeDownLoaded:
            value = cacheMaxCacheSpace;
            break;
        case ECacheTypeLocal:
            value = Local_CacheMaxCacheSpace;
            break;
        case ECacheTypeTmp:
            value = Tmp_CacheMaxCacheSpace;
            break;
        default:
            value = cacheMaxCacheSpace;
            break;
    }
    return value;
}

- (NSInteger)getMaxCacheTime:(CacheType)cacheType
{
    NSInteger value = 0;
    switch (cacheType) {
        case ECacheTypeDownLoaded:
            value = cacheMaxCacheTime;
            break;
        case ECacheTypeLocal:
            value = Local_CacheMaxCacheTime;
            break;
        case ECacheTypeTmp:
            value = Tmp_CacheMaxCacheTime;
            break;
        default:
            value = cacheMaxCacheTime;
            break;
    }
    return value;
}

- (NSInteger)getMinCacheTime:(CacheType)cacheType
{
    NSInteger value = 0;
    switch (cacheType) {
        case ECacheTypeDownLoaded:
            value = cacheMinCacheTime;
            break;
        case ECacheTypeLocal:
            value = Local_CacheMinCacheTime;
            break;
        case ECacheTypeTmp:
            value = Tmp_CacheMinCacheTime;
            break;
        default:
            value = cacheMinCacheTime;
            break;
    }
    return value;
}

@end

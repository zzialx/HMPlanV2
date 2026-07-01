//
//  WCFileDataCache.h
//  RRSpring
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

// will support cache by space and time, and support by file number and time (near feature... )
// 2012-12-5 already support cache by file number and time

#import <Foundation/Foundation.h>

typedef enum
{
    ECacheTypeDownLoaded = 0,   //在线文件缓存，下载下来的
    ECacheTypeLocal,            //本地文件缓存，本地生辰的
    ECacheTypeTmp       //临时文件缓存，用于记录临时文件
}CacheType; //缓存类型，不同类型的cachetype缓存在不同的目录下

//删除block，把count传出来
typedef void (^RRFileDataCacheRemoveBlock)(long long count);

@interface WCFileDataCache : NSObject
{
    NSString *_diskCachePath;
    NSString *_commentDiskCachePath;
    NSString *_downLoadingDiskCachePath;
}

@property (nonatomic, copy) NSString *diskCachePath;
@property (nonatomic, copy) NSString *commentDiskCachePath;
@property (nonatomic, copy) NSString *downLoadingDiskCachePath;

+ (WCFileDataCache *)sharedInstance;

// Get full path name by key
- (NSString *)cachePathForKey:(NSString *)key cacheType:(CacheType)cacheType;

// Rename key map cache file name by another key
- (void)renameCacheName:(NSString*)srcKey dst:(NSString*)dstKey cacheType:(CacheType)cacheType;

- (void)moveFileToCache:(NSString*)srcFilePath dst:(NSString*)dstKey dstCacheType:(CacheType)dstCacheType;

// remove key map cache file name to another key map
- (void)removeCacheFile:(NSString*)srcKey srcCacheType:(CacheType)srcCacheType dst:(NSString*)dstKey dstCacheType:(CacheType)dstCacheType;

// Rename a file with the new name
- (BOOL)renameFileName:(NSString *)oldName withNewName:(NSString *)newName;

// The key map cache file exist?
- (BOOL)isCacheFileExistByKey:(NSString*)key cacheType:(CacheType)cacheType;

// Save data by key
- (void)storeData:(NSData *)data forKey:(NSString *)key cacheType:(CacheType)cacheType;

// Clear all disk cached file
- (void)clearDisk:(CacheType)cacheType;

// Clear all disk cached file ,and show the num delegate
- (void)clearDiskWithBlock:(RRFileDataCacheRemoveBlock)removeBlock cacheType:(CacheType)cacheType;

// Remove all expired file from disk
- (void)cleanDisk:(CacheType)cacheType;

// Get the size used by the disk cache
- (int)getSize:(CacheType)cacheType;

// Get the number of file in the disk cache
- (int)getDiskCount:(CacheType)cacheType;

// remove ont file by path
- (void)removeFileByKey:(NSString*)key cacheType:(CacheType)cacheType;

@end

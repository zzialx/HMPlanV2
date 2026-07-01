/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#define SDImageSaveSuccess @"SDImageSaveSuccess"

#import <Foundation/Foundation.h>
#import "SDWebImageCompat.h"

enum SDImageCacheType
{
    /**
     * The image wasn't available the SDWebImage caches, but was downloaded from the web.
     */
    SDImageCacheTypeNone = 0,
    /**
     * The image was obtained from the disk cache.
     */
    SDImageCacheTypeDisk,
    /**
     * The image was obtained from the memory cache.
     */
    SDImageCacheTypeMemory
};
typedef enum SDImageCacheType SDImageCacheType;

typedef void(^SDWebImageQueryCompletedBlock)(UIImage *image, SDImageCacheType cacheType);

typedef void(^SDWebImageCheckCacheCompletionBlock)(BOOL isInCache);

typedef void(^SDWebImageCalculateSizeBlock)(NSUInteger fileCount, NSUInteger totalSize);

/**
 * SDImageCache maintains a memory cache and an optional disk cache. Disk cache write operations are performed
 * asynchronous so it doesn’t add unnecessary latency to the UI.
 */
@interface SDImageCache : NSObject

/**
 * The maximum length of time to keep an image in the cache, in seconds
 */
@property (assign, nonatomic) NSInteger maxCacheAge;

/**
 * The maximum length of time to keep an image in the document directory, in seconds
 */
@property (assign, nonatomic) NSInteger maxCacheAgeForDocument;

/**
 * The maximum size of the cache, in bytes.
 */
@property (assign, nonatomic) unsigned long long maxCacheSize;

/**
 * Returns global shared cache instance
 *
 * @return SDImageCache global instance
 */
+ (SDImageCache *)sharedImageCache;

/**
 * Init a new cache store with a specific namespace
 *
 * @param ns The namespace to use for this cache store
 */
- (id)initWithNamespace:(NSString *)ns;

/**
 * Store an image into memory and disk cache at the given key.
 *
 * @param image The image to store
 * @param key The unique image cache key, usually it's image absolute URL
 */
- (void)storeImage:(UIImage *)image forKey:(NSString *)key toDocument:(BOOL)isToDocument;

/**
 * Store an image into memory and optionally disk cache at the given key.
 *
 * @param image The image to store
 * @param key The unique image cache key, usually it's image absolute URL
 * @param toDisk Store the image to disk cache if YES
 */
- (void)storeImage:(UIImage *)image forKey:(NSString *)key toDisk:(BOOL)toDisk toDocument:(BOOL)isToDocument;

/**
 * Store an image into memory and optionally disk cache at the given key.
 *
 * @param image The image to store
 * @param data The image data as returned by the server, this representation will be used for disk storage
 *             instead of converting the given image object into a storable/compressed image format in order
 *             to save quality and CPU
 * @param key The unique image cache key, usually it's image absolute URL
 * @param toDisk Store the image to disk cache if YES
 * @param isToDocument Store the image to Ducument if YES
 */
- (void)storeImage:(UIImage *)image imageData:(NSData *)imageData forKey:(NSString *)key toDisk:(BOOL)toDisk toDocument:(BOOL)isToDocument;
- (void)storeImage:(UIImage *)image imageImgCompress:(NSNumber *)imgCompress forKey:(NSString *)key toDisk:(BOOL)toDisk toDocument:(BOOL)isToDocument;
- (void)storeImage:(UIImage *)image imageImgCompress:(NSNumber *)imgCompress forKey:(NSString *)key toDisk:(BOOL)toDisk toDocument:(BOOL)isToDocument isSynchronized:(BOOL)isSynchronized;

/**
 * Query the disk cache asynchronously.
 *
 * @param key The unique key used to store the wanted image
 */
- (void)queryDiskCacheForKey:(NSString *)key done:(void (^)(UIImage *image, SDImageCacheType cacheType))doneBlock;

/**
 * Query the memory cache synchronously.
 *
 * @param key The unique key used to store the wanted image
 */
- (UIImage *)imageFromMemoryCacheForKey:(NSString *)key;

/**
 * Query the disk cache synchronously after checking the memory cache.
 *
 * @param key The unique key used to store the wanted image
 */
- (UIImage *)imageFromDiskCacheForKey:(NSString *)key;

/**
 * Remove the image from memory and disk cache synchronously
 *
 * @param key The unique image cache key
 */
- (void)removeImageForKey:(NSString *)key;

/**
 * Remove the image from memory and optionaly disk cache synchronously
 *
 * @param key The unique image cache key
 * @param fromDisk Also remove cache entry from disk if YES
 */
- (void)removeImageForKey:(NSString *)key fromDisk:(BOOL)fromDisk;

/**
 * Query the memory cache for an image at a given key and fallback to disk cache
 * synchronousely if not found in memory.
 *
 * @warning This method may perform some synchronous IO operations
 *
 * @param key The unique key used to store the wanted image
 */
- (UIImage *)imageFromKey:(NSString *)key;

/**
 * Query the memory cache for an image at a given key and optionnaly fallback to disk cache
 * synchronousely if not found in memory.
 *
 * @warning This method may perform some synchronous IO operations if fromDisk is YES
 *
 * @param key The unique key used to store the wanted image
 * @param fromDisk Try to retrive the image from disk if not found in memory if YES
 */
- (UIImage *)imageFromKey:(NSString *)key fromDisk:(BOOL)fromDisk;

/**
 * 从磁盘直接获取image的data，为了上传时节省调用UIImageJPEGRepresentation所耗的时间
 *
 * @warning 存图片时必须存经过质量压缩后的data，因为上传时不在进行压缩
 *
 * @param key The unique key used to store the wanted image
 */
- (NSData *)imageDataFromKey:(NSString *)key;

- (NSString *)imagePathFromKey:(NSString *)key;

/**
 * Clear all memory cached images
 */
- (void)clearMemory;

/**
 * Clear all disk cached images
 */
- (void)clearDisk;

/**
 * Remove all expired cached image from disk
 */
- (void)cleanDisk;

/**
 * Remove all expired cached image from disk except the one in exceptFileNames
 */
- (void)cleanDiskWithExcludeFileNames:(NSArray *)exceptFileNames;

/**
 * Get the size used by the disk cache
 */
- (unsigned long long)getSize;

/**
 * Get the number of images in the disk cache
 */
- (int)getDiskCount;

/**
 * Get cache file name for key
 */
- (NSString *)cacheFileNameForKey:(NSString *)key;

//  更新保存路径
- (void)updateDisckCachePathToDocument:(BOOL)isToDocument;

// 输出照片信息日志（追踪离线数据照片找不到问题添加2014.6.25）
- (void) printfDebugPhotoInfo:(NSString*) logText;

/**
 *  Check if image exists in disk cache already (does not load the image)
 *
 *  @param key the key describing the url
 *
 *  @return YES if an image exists for the given key
 */
- (BOOL)diskImageExistsWithKey:(NSString *)key;

/**
 *  Async check if image exists in disk cache already (does not load the image)
 *
 *  @param key             the key describing the url
 *  @param completionBlock the block to be executed when the check is done.
 *  @note the completion block will be always executed on the main queue
 */
- (void)diskImageExistsWithKey:(NSString *)key completion:(SDWebImageCheckCacheCompletionBlock)completionBlock;


@end

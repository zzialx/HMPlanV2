/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDImageCache.h"
#import "SDWebImageDecoder.h"
#import "UIImage+GIF.h"
#import <CommonCrypto/CommonDigest.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import "BlockAlertView.h"
#import "NSData+ImageContentType.h"

static const NSInteger kDefaultCacheMaxCacheAge = 60 * 60 * 24 * 7; // 1 week
static natural_t minFreeMemLeft = 1024*1024*12; // reserve 12MB RAM

static natural_t get_free_memory(void)
{
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS)
    {
        NSLog(@"Failed to fetch vm statistics");
        return 0;
    }
    
    /* Stats in bytes */
    natural_t mem_free = vm_stat.free_count * pagesize;
    return mem_free;
}

@interface SDImageCache ()

@property (strong, nonatomic) NSCache *memCache;
@property (strong, nonatomic) NSString *diskCachePath;

@property (SDDispatchQueueSetterSementics, nonatomic) dispatch_queue_t ioQueue;

@end


@implementation SDImageCache

+ (SDImageCache *)sharedImageCache
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{instance = self.new;});
    return instance;
}

- (id)init
{
    return [self initWithNamespace:@"default"];
}

- (id)initWithNamespace:(NSString *)ns
{
    if ((self = [super init]))
    {
        NSString *fullNamespace = [@"com.hackemist.SDWebImageCache." stringByAppendingString:ns];
        
        // Create IO serial queue
        _ioQueue = dispatch_queue_create("com.hackemist.SDWebImageCache", DISPATCH_QUEUE_SERIAL);
        
        // Init default values
        _maxCacheAge = kDefaultCacheMaxCacheAge;
        
        // Init the memory cache
        _memCache = [[NSCache alloc] init];
        _memCache.name = fullNamespace;
        
        // Init the disk cache
        [self updateDisckCachePathToDocument:NO];
        
        
#if TARGET_OS_IPHONE
        // Subscribe to app events
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        
        //        [[NSNotificationCenter defaultCenter] addObserver:self
        //                                                 selector:@selector(cleanDisk)
        //                                                     name:UIApplicationWillTerminateNotification
        //                                                   object:nil];
#endif
    }
    
    return self;
}

//  更新保存路径
- (void)updateDisckCachePathToDocument:(BOOL)isToDocument
{
    NSString *fullNamespace = [@"com.hackemist.SDWebImageCache." stringByAppendingString:@"default"];
    if (isToDocument)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.diskCachePath = [paths[0] stringByAppendingPathComponent:fullNamespace];
    }
    else
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _diskCachePath = [paths[0] stringByAppendingPathComponent:fullNamespace];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SDDispatchQueueRelease(_ioQueue);
}

#pragma mark SDImageCache (private)

- (NSString *)cachePathForKey:(NSString *)key
{
    const char *str = [key UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return [self.diskCachePath stringByAppendingPathComponent:filename];
}

#pragma mark ImageCache

- (void)storeImage:(UIImage *)image imageData:(NSData *)imageData forKey:(NSString *)key toDisk:(BOOL)toDisk toDocument:(BOOL)isToDocument
{
    LogTrace();
    [self updateDisckCachePathToDocument:isToDocument];
    //  增加参数 isToDocument：yes no
    if (!image || !key)
    {
        LogError(@"保存照片失败 key is %@",key);
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"takePhotoAgain", nil)  message:nil];
        [alert setCancelButtonWithTitle:NSLocalizedString(@"OK", nil) block:nil];
        [alert show];
        return;
    }
    
    [self.memCache setObject:image forKey:key cost:image.size.height * image.size.width * image.scale];
    
    if (toDisk)
    {
        dispatch_async(self.ioQueue, ^
                       {
                           NSData *data = imageData;
                           
                           if (!data)
                           {
                               
                               if (image)
                               {
#if TARGET_OS_IPHONE
                                   data = UIImageJPEGRepresentation(image, (CGFloat)1.0);
#else
                                   data = [NSBitmapImageRep representationOfImageRepsInArray:image.representations usingType: NSJPEGFileType properties:nil];
#endif
                               }
                               else
                               {
                                   LogError(@"保存照片失败 key is %@",key);
                                   BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"takePhotoAgain", nil)  message:nil];
                                   [alert setCancelButtonWithTitle:NSLocalizedString(@"OK", nil) block:nil];
                                   [alert show];
                               }
                           }
                           
                           if (data)
                           {
                               // Can't use defaultManager another thread
                               NSFileManager *fileManager = NSFileManager.new;
                               
                               if (![fileManager fileExistsAtPath:_diskCachePath])
                               {
                                   BOOL ok= [fileManager createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
                                   if(ok){
                                       LogInfo(@"\n\n[ 创建 %@ 成功]\n\n",_diskCachePath);
                                   }else{
                                       LogInfo(@"\n\n[ 创建 %@ 失败]\n\n",_diskCachePath);
                                       BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"takePhotoAgain", nil)  message:nil];
                                       [alert setCancelButtonWithTitle:NSLocalizedString(@"OK", nil) block:nil];
                                       [alert show];
                                   }
                               }
                               
                               BOOL ok= [fileManager createFileAtPath:[self cachePathForKey:key] contents:data attributes:nil];
                               if(ok){
                                   LogInfo(@"\n\n[ 保存照片 %@ 成功]\n\n",key);
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [[NSNotificationCenter defaultCenter] postNotificationName:SDImageSaveSuccess object:@[image,key]];
                                   });
                               }else{
                                   LogInfo(@"\n\n[ 保存照片 %@ 失败]\n\n",key);
                                   BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"takePhotoAgain", nil)  message:nil];
                                   [alert setCancelButtonWithTitle:NSLocalizedString(@"OK", nil) block:nil];
                                   [alert show];
                               }
                           }
                           else
                           {
                               LogError(@"保存照片失败 key is %@",key);
                               BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"takePhotoAgain", nil)  message:nil];
                               [alert setCancelButtonWithTitle:NSLocalizedString(@"OK", nil) block:nil];
                               [alert show];
                           }
                       });
    }
}

- (void)storeImage:(UIImage *)image imageImgCompress:(NSNumber *)imgCompress forKey:(NSString *)key toDisk:(BOOL)toDisk toDocument:(BOOL)isToDocument{
    return [self storeImage:image imageImgCompress:imgCompress forKey:key toDisk:toDisk toDocument:isToDocument isSynchronized:NO];
}

- (void)storeImage:(UIImage *)image imageImgCompress:(NSNumber *)imgCompress forKey:(NSString *)key toDisk:(BOOL)toDisk toDocument:(BOOL)isToDocument isSynchronized:(BOOL)isSynchronized
{
    LogTrace();
    [self updateDisckCachePathToDocument:isToDocument];
    //  增加参数 isToDocument：yes no
    if (!image || !key)
    {
        LogError(@"保存照片失败 key is %@",key);
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"takePhotoAgain", nil)  message:nil];
        [alert setCancelButtonWithTitle:NSLocalizedString(@"OK", nil) block:nil];
        [alert show];
        return;
    }
    
    [self.memCache setObject:image forKey:key cost:image.size.height * image.size.width * image.scale];
    
    if (toDisk)
    {
        void (^blk)(void)  = ^{
            
            float compressScale = imgCompress.intValue / 100.0f;
            
            NSData *photodata = UIImageJPEGRepresentation(image, compressScale);
            
            
            
            if (!photodata)
            {
                
                if (image)
                {
#if TARGET_OS_IPHONE
                    photodata = UIImageJPEGRepresentation(image, (CGFloat)1.0);
#else
                    photodata = [NSBitmapImageRep representationOfImageRepsInArray:image.representations usingType: NSJPEGFileType properties:nil];
#endif
                }
                else
                {
                    LogError(@"保存照片失败 key is %@",key);
                    BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"takePhotoAgain", nil)  message:nil];
                    [alert setCancelButtonWithTitle:NSLocalizedString(@"OK", nil) block:nil];
                    [alert show];
                }
            }
            
            if (photodata)
            {
                // Can't use defaultManager another thread
                NSFileManager *fileManager = NSFileManager.new;
                
                if (![fileManager fileExistsAtPath:_diskCachePath])
                {
                    BOOL ok= [fileManager createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
                    if(ok){
                        LogInfo(@"\n\n[ 创建 %@ 成功]\n\n",_diskCachePath);
                    }else{
                        LogInfo(@"\n\n[ 创建 %@ 失败]\n\n",_diskCachePath);
                        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"takePhotoAgain", nil)  message:nil];
                        [alert setCancelButtonWithTitle:NSLocalizedString(@"OK", nil) block:nil];
                        [alert show];
                    }
                }
                
                BOOL ok= [fileManager createFileAtPath:[self cachePathForKey:key] contents:photodata attributes:nil];
                if(ok){
                    LogInfo(@"\n\n[ 保存照片 %@ 成功]\n\n",key);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:SDImageSaveSuccess object:@[image,key]];
                    });
                }else{
                    LogInfo(@"\n\n[ 保存照片 %@ 失败]\n\n",key);
                    BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"takePhotoAgain", nil)  message:nil];
                    [alert setCancelButtonWithTitle:NSLocalizedString(@"OK", nil) block:nil];
                    [alert show];
                }
            }
            else
            {
                LogError(@"保存照片失败 key is %@",key);
                BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"takePhotoAgain", nil)  message:nil];
                [alert setCancelButtonWithTitle:NSLocalizedString(@"OK", nil) block:nil];
                [alert show];
            }
        };
        
        if (isSynchronized) {
            dispatch_sync(self.ioQueue, blk);
        }else {
            dispatch_async(self.ioQueue, blk);
        }
    }
}


- (void)storeImage:(UIImage *)image forKey:(NSString *)key toDocument:(BOOL)isToDocument
{
    //  增加参数 isToDocument：yes no
    [self storeImage:image imageData:nil forKey:key toDisk:YES toDocument:isToDocument];
}

- (void)storeImage:(UIImage *)image forKey:(NSString *)key toDisk:(BOOL)toDisk toDocument:(BOOL)isToDocument
{
    
    //  增加参数 isToDocument：yes no
    [self storeImage:image imageData:nil forKey:key toDisk:toDisk toDocument:isToDocument];
}

- (UIImage *)imageFromMemoryCacheForKey:(NSString *)key
{
    return [self.memCache objectForKey:key];
}

- (UIImage *)imageFromDiskCacheForKey:(NSString *)key
{
    // First check the in-memory cache...
    UIImage *image = [self imageFromMemoryCacheForKey:key];
    if (image)
    {
        return image;
    }
    
    // Second check the disk cache...
    UIImage *diskImage = [self diskImageForKey:key];
    if (diskImage)
    {
        CGFloat cost = diskImage.size.height * diskImage.size.width * diskImage.scale;
        [self.memCache setObject:diskImage forKey:key cost:cost];
    }
    
    return diskImage;
}

- (UIImage *)diskImageForKey:(NSString *)key
{
    [self updateDisckCachePathToDocument:YES];
    NSData *data = nil;
    NSString *path = [self cachePathForKey:key];
    if (!path || [path length] <= 0 || ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [self updateDisckCachePathToDocument:NO];
        path = [self cachePathForKey:key];
    }
    if (path && [path length] > 0) {
        data = [NSData dataWithContentsOfFile:path];
    }
    
    //    NSString *path = [self cachePathForKey:key];
    //    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data)
    {
        if ([NSData sd_contentTypeForImageData:data])
        {
            UIImage *image = [UIImage sd_animatedGIFWithData:data];
            return [self scaledImageForKey:key image:image];
        }
        else
        {
            UIImage *image = [[UIImage alloc] initWithData:data];
            UIImage *scaledImage = [self scaledImageForKey:key image:image];
            return [UIImage decodedImageWithImage:scaledImage];
        }
    }
    else
    {
        return nil;
    }
}

- (UIImage *)scaledImageForKey:(NSString *)key image:(UIImage *)image
{
    return SDScaledImageForKey(key, image);
}

- (void)queryDiskCacheForKey:(NSString *)key done:(void (^)(UIImage *image, SDImageCacheType cacheType))doneBlock
{
    if (!doneBlock) return;
    
    if (!key)
    {
        doneBlock(nil, SDImageCacheTypeNone);
        return;
    }
    
    // First check the in-memory cache...
    UIImage *image = [self imageFromMemoryCacheForKey:key];
    if (image)
    {
        doneBlock(image, SDImageCacheTypeMemory);
        return;
    }
    
    dispatch_async(self.ioQueue, ^
                   {
                       @autoreleasepool
                       {
                           UIImage *diskImage = [self diskImageForKey:key];
                           if (diskImage)
                           {
                               CGFloat cost = diskImage.size.height * diskImage.size.width * diskImage.scale;
                               [self.memCache setObject:diskImage forKey:key cost:cost];
                           }
                           
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              doneBlock(diskImage, SDImageCacheTypeDisk);
                                          });
                       }
                   });
}

- (void)removeImageForKey:(NSString *)key
{
    [self removeImageForKey:key fromDisk:YES];
}

- (void)removeImageForKey:(NSString *)key fromDisk:(BOOL)fromDisk
{
    if (key == nil)
    {
        return;
    }
    
    [self.memCache removeObjectForKey:key];
    
    if (fromDisk)
    {
        dispatch_async(self.ioQueue, ^
                       {
                           [[NSFileManager defaultManager] removeItemAtPath:[self cachePathForKey:key] error:nil];
                       });
    }
}

- (UIImage *)imageFromKey:(NSString *)key
{
    return [self imageFromKey:key fromDisk:YES];
}

- (UIImage *)imageFromKey:(NSString *)key fromDisk:(BOOL)fromDisk
{
    if (key == nil)
    {
        return nil;
    }
    [self updateDisckCachePathToDocument:YES];
    
    UIImage *image =nil;
    
    if(fromDisk){
        [self updateDisckCachePathToDocument:YES];
        image = SDScaledImageForKey(key, [UIImage imageWithContentsOfFile:[self cachePathForKey:key]]);
        if (!image) {
            [self updateDisckCachePathToDocument:NO];
            image = SDScaledImageForKey(key, [UIImage imageWithContentsOfFile:[self cachePathForKey:key]]);
        }
        if (image)
        {
            if (get_free_memory() < minFreeMemLeft)
            {
                [self.memCache removeAllObjects];
            }
            [self.memCache setObject:image forKey:key];
        }
    }else{
        image = [self.memCache objectForKey:key];
        if (!image) {
            [self updateDisckCachePathToDocument:NO];
            image = [self.memCache objectForKey:key];
        }
    }
    
    
    return image;
}

- (NSData *)imageDataFromKey:(NSString *)key
{
    // 先在document下找 没有则在cache下找  抽离代码块
    [self updateDisckCachePathToDocument:YES];
    NSData *data = nil;
    NSString *path = [self cachePathForKey:key];
    if (!path || [path length] <= 0 || ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [self updateDisckCachePathToDocument:NO];
        path = [self cachePathForKey:key];
    }
    if (path && [path length] > 0) {
        data = [NSData dataWithContentsOfFile:path];
    }
    
    if (!data) {
        LogError(@"SDImageCache imageDataFromKey is null, key:%@, path:%@", key, path);
    }
    
    return data;
}

- (NSString *)imagePathFromKey:(NSString *)key
{
    [self updateDisckCachePathToDocument:YES];
    
    NSString *path = [self cachePathForKey:key];
    
    if (!path || [path length] <= 0 || ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [self updateDisckCachePathToDocument:NO];
        path = [self cachePathForKey:key];
    }
    if (!path || [path length] <= 0 || ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        path = nil;
    }
    
    if (!path) {
        LogError(@"SDImageCache imageData is null, key:%@, path:%@", key, path);
    }
    
    return path;
}

- (void)clearMemory
{
    [self.memCache removeAllObjects];
}

- (void)clearDisk
{
    dispatch_async(self.ioQueue, ^
                   {
                       [[NSFileManager defaultManager] removeItemAtPath:self.diskCachePath error:nil];
                       [[NSFileManager defaultManager] createDirectoryAtPath:self.diskCachePath
                                                 withIntermediateDirectories:YES
                                                                  attributes:nil
                                                                       error:NULL];
                   });
}

- (void)cleanDisk
{
    dispatch_async(self.ioQueue, ^
                   {
                       NSFileManager *fileManager = [NSFileManager defaultManager];
                       NSURL *diskCacheURL = [NSURL fileURLWithPath:self.diskCachePath isDirectory:YES];
                       NSArray *resourceKeys = @[ NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey ];
                       
                       // This enumerator prefetches useful properties for our cache files.
                       NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtURL:diskCacheURL
                                                                 includingPropertiesForKeys:resourceKeys
                                                                                    options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                               errorHandler:NULL];
                       
                       NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-self.maxCacheAge];
                       NSMutableDictionary *cacheFiles = [NSMutableDictionary dictionary];
                       unsigned long long currentCacheSize = 0;
                       
                       // Enumerate all of the files in the cache directory.  This loop has two purposes:
                       //
                       //  1. Removing files that are older than the expiration date.
                       //  2. Storing file attributes for the size-based cleanup pass.
                       for (NSURL *fileURL in fileEnumerator)
                       {
                           NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
                           
                           // Skip directories.
                           if ([resourceValues[NSURLIsDirectoryKey] boolValue])
                           {
                               continue;
                           }
                           
                           // Remove files that are older than the expiration date;
                           NSDate *modificationDate = resourceValues[NSURLContentModificationDateKey];
                           if ([[modificationDate laterDate:expirationDate] isEqualToDate:expirationDate])
                           {
                               [fileManager removeItemAtURL:fileURL error:nil];
                               continue;
                           }
                           
                           // Store a reference to this file and account for its total size.
                           NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                           currentCacheSize += [totalAllocatedSize unsignedLongLongValue];
                           [cacheFiles setObject:resourceValues forKey:fileURL];
                       }
                       
                       // If our remaining disk cache exceeds a configured maximum size, perform a second
                       // size-based cleanup pass.  We delete the oldest files first.
                       if (self.maxCacheSize > 0 && currentCacheSize > self.maxCacheSize)
                       {
                           // Target half of our maximum cache size for this cleanup pass.
                           const unsigned long long desiredCacheSize = self.maxCacheSize / 2;
                           
                           // Sort the remaining cache files by their last modification time (oldest first).
                           NSArray *sortedFiles = [cacheFiles keysSortedByValueWithOptions:NSSortConcurrent
                                                                           usingComparator:^NSComparisonResult(id obj1, id obj2)
                                                   {
                                                       return [obj1[NSURLContentModificationDateKey] compare:obj2[NSURLContentModificationDateKey]];
                                                   }];
                           
                           // Delete files until we fall below our desired cache size.
                           for (NSURL *fileURL in sortedFiles)
                           {
                               if ([fileManager removeItemAtURL:fileURL error:nil])
                               {
                                   NSDictionary *resourceValues = cacheFiles[fileURL];
                                   NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                                   currentCacheSize -= [totalAllocatedSize unsignedLongLongValue];
                                   
                                   if (currentCacheSize < desiredCacheSize)
                                   {
                                       break;
                                   }
                               }
                           }
                       }
                   });
}

- (void) printfDebugPhotoInfo:(NSString*) logText
{
    /*
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *diskCacheURL = [NSURL fileURLWithPath:self.diskCachePath isDirectory:YES];
    NSArray *resourceKeys = @[ NSURLNameKey, NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey ];
    
    // This enumerator prefetches useful properties for our cache files.
    NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtURL:diskCacheURL
                                              includingPropertiesForKeys:resourceKeys
                                                                 options:NSDirectoryEnumerationSkipsHiddenFiles
                                                            errorHandler:NULL];
    
    NSMutableArray *logArray = [NSMutableArray array];
    
    for (NSURL *fileURL in fileEnumerator)
    {
        NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
        [logArray addObject:resourceValues];
    }
    LogInfo(@"%@, SDImageCache storaged image:%@", logText, logArray);
     */
}

- (void)cleanDiskWithExcludeFileNames:(NSArray *)exceptFileNames
{
    dispatch_async(self.ioQueue, ^
                   {
                       // 清cache下文件
                       [self updateDisckCachePathToDocument:NO];
                       [self printfDebugPhotoInfo:@"no cleaned cache"];
                       [self cleanDisk];
                       [self printfDebugPhotoInfo:@"cleaned cache"];
                       
                       // 清Document下文件
                       [self updateDisckCachePathToDocument:YES];
                       [self printfDebugPhotoInfo:@"no cleaned document"];
                       NSFileManager *fileManager = [NSFileManager defaultManager];
                       NSURL *diskCacheURL = [NSURL fileURLWithPath:self.diskCachePath isDirectory:YES];
                       NSArray *resourceKeys = @[ NSURLNameKey, NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey ];
                       
                       // This enumerator prefetches useful properties for our cache files.
                       NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtURL:diskCacheURL
                                                                 includingPropertiesForKeys:resourceKeys
                                                                                    options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                               errorHandler:NULL];
                       
                       NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-self.maxCacheAgeForDocument];
                       NSMutableDictionary *cacheFiles = [NSMutableDictionary dictionary];
                       unsigned long long currentCacheSize = 0;
                       
                       // Enumerate all of the files in the cache directory.  This loop has two purposes:
                       //
                       //  1. Removing files that are older than the expiration date.
                       //  2. Storing file attributes for the size-based cleanup pass.
                       for (NSURL *fileURL in fileEnumerator)
                       {
                           NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
                           
                           // Skip directories.
                           if ([resourceValues[NSURLIsDirectoryKey] boolValue])
                           {
                               continue;
                           }
                           
                           // Remove files that are older than the expiration date;
                           NSDate *modificationDate = resourceValues[NSURLContentModificationDateKey];
                           if ([[modificationDate laterDate:expirationDate] isEqualToDate:expirationDate])
                           {
                               if (exceptFileNames && [exceptFileNames count] > 0) {
                                   NSString *fileName = resourceValues[NSURLNameKey];
                                   NSUInteger index = [exceptFileNames indexOfObject:fileName];
                                   if (index == NSNotFound) {
                                       [fileManager removeItemAtURL:fileURL error:nil];
                                       continue;
                                   }
                               }
                               else
                               {
                                   [fileManager removeItemAtURL:fileURL error:nil];
                                   continue;
                               }
                               
                           }
                           
                           // Store a reference to this file and account for its total size.
                           NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                           currentCacheSize += [totalAllocatedSize unsignedLongLongValue];
                           [cacheFiles setObject:resourceValues forKey:fileURL];
                       }
                       
                       // If our remaining disk cache exceeds a configured maximum size, perform a second
                       // size-based cleanup pass.  We delete the oldest files first.
                       if (self.maxCacheSize > 0 && currentCacheSize > self.maxCacheSize)
                       {
                           // Target half of our maximum cache size for this cleanup pass.
                           const unsigned long long desiredCacheSize = self.maxCacheSize / 2;
                           
                           // Sort the remaining cache files by their last modification time (oldest first).
                           NSArray *sortedFiles = [cacheFiles keysSortedByValueWithOptions:NSSortConcurrent
                                                                           usingComparator:^NSComparisonResult(id obj1, id obj2)
                                                   {
                                                       return [obj1[NSURLContentModificationDateKey] compare:obj2[NSURLContentModificationDateKey]];
                                                   }];
                           
                           // Delete files until we fall below our desired cache size.
                           for (NSURL *fileURL in sortedFiles)
                           {
                               if (exceptFileNames && [exceptFileNames count] > 0) {
                                   NSString *fileName = cacheFiles[fileURL][NSURLNameKey];
                                   NSUInteger index = [exceptFileNames indexOfObject:fileName];
                                   if (index != NSNotFound) {
                                       continue;      //在过滤对象中，不允许删除
                                   }
                               }
                               
                               if ([fileManager removeItemAtURL:fileURL error:nil])
                               {
                                   NSDictionary *resourceValues = cacheFiles[fileURL];
                                   NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                                   currentCacheSize -= [totalAllocatedSize unsignedLongLongValue];
                                   
                                   if (currentCacheSize < desiredCacheSize)
                                   {
                                       break;
                                   }
                               }
                           }
                       }
                       
                       [self printfDebugPhotoInfo:@"cleaned document"];
                   });
}


-(unsigned long long)getSize
{
    unsigned long long size = 0;
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:self.diskCachePath];
    for (NSString *fileName in fileEnumerator)
    {
        NSString *filePath = [self.diskCachePath stringByAppendingPathComponent:fileName];
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        size += [attrs fileSize];
    }
    return size;
}

- (int)getDiskCount
{
    int count = 0;
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:self.diskCachePath];
    for (NSString *fileName in fileEnumerator)
    {
        count += 1;
    }
    
    return count;
}

- (NSString *)cacheFileNameForKey:(NSString *)key
{
    const char *str = [key UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return filename;
}

- (BOOL)diskImageExistsWithKey:(NSString *)key {
    BOOL exists = NO;
    
    // this is an exception to access the filemanager on another queue than ioQueue, but we are using the shared instance
    // from apple docs on NSFileManager: The methods of the shared NSFileManager object can be called from multiple threads safely.
    exists = [[NSFileManager defaultManager] fileExistsAtPath:[self defaultCachePathForKey:key]];
    
    return exists;
}

- (NSString *)defaultCachePathForKey:(NSString *)key {
    return [self cachePathForKey:key inPath:self.diskCachePath];
}

- (NSString *)cachePathForKey:(NSString *)key inPath:(NSString *)path {
    NSString *filename = [self cachedFileNameForKey:key];
    return [path stringByAppendingPathComponent:filename];
}

#pragma mark SDImageCache (private)

- (NSString *)cachedFileNameForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return filename;
}

- (void)diskImageExistsWithKey:(NSString *)key completion:(SDWebImageCheckCacheCompletionBlock)completionBlock {
    dispatch_async(_ioQueue, ^{
        BOOL exists = [[NSFileManager new] fileExistsAtPath:[self defaultCachePathForKey:key]];
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(exists);
            });
        }
    });
}

@end

//
//  UIImage+ExtraInfo.m
//  WinSFA
//
//  Created by macbook  on 2018/6/8.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "UIImage+ExtraInfo.h"
#import <ImageIO/ImageIO.h>

@implementation UIImage(ExtraInfo)
+ (UIImage *)updateImageExif: (UIImage * )image mesArray: (NSArray *)mesArray{
    // 读取原图片的exif信息
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
    CFDictionaryRef imageInfo = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
    NSDictionary *dic = CFBridgingRelease(imageInfo);

    NSMutableDictionary *metaDataDic = [dic mutableCopy];
    NSMutableDictionary *tiffDic = [[metaDataDic objectForKey:(NSString*)kCGImagePropertyTIFFDictionary] mutableCopy];

    // 修改相关exif信息
    [tiffDic setObject:[mesArray firstObject] forKey:(NSString*)kCGImagePropertyTIFFModel];

    // 将相关修改的信息写入原数据
    [metaDataDic setObject:tiffDic forKey:(NSString*)kCGImagePropertyTIFFDictionary];

    CFStringRef uit = CGImageSourceGetType(imageSource);
    NSMutableData *newImageData = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)newImageData, uit, 1,NULL);
    CGImageDestinationAddImageFromSource(destination, imageSource, 0, (__bridge CFDictionaryRef)metaDataDic);

    CGImageDestinationFinalize(destination);
    NSString *directoryDocuments = NSTemporaryDirectory();
    [newImageData writeToFile:directoryDocuments atomically:YES];
    CIImage *newImage = [CIImage imageWithData:newImageData];
    return  [UIImage imageWithCIImage:newImage];
}
@end

//
//  ImageHelper.m
//  menu
//
//  Created by Niu Zhaowang on 11/8/12.
//  Copyright (c) 2012 Niu Zhaowang. All rights reserved.
//

#import "ImageHelper.h"
#import <QuartzCore/QuartzCore.h>

static NSString *documentsFolder()
{
    //Return the sandbox documents folder
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
}
static NSString *bundleFolder()
{
    //Return the app bundle folder
    return [[NSBundle mainBundle] bundlePath];
}
@implementation ImageHelper

+ (NSString *)pathForItemNamed:(NSString *)fname inFolder:(NSString *)path
{
    //Return a complete path for the named file
    NSString *file;
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:path];
    while (file = [dirEnum nextObject])
    {
        if ([[file lastPathComponent] isEqualToString:fname])
        {
            return [path stringByAppendingPathComponent:file];
        }
    }
    return nil;
}

//Searches bundle first then documents folder
+ (UIImage *)imageNamed:(NSString *)aName
{
    //Return a UIImage for the named item
    NSString *path = [ImageHelper pathForItemNamed:aName inFolder:bundleFolder()];
    path = path? path:[ImageHelper pathForItemNamed:aName inFolder:documentsFolder()];
    if (!path)
    {
        return nil;
    }
    return [UIImage imageWithContentsOfFile:path];
}

+ (UIImage *)imageFromURLString:(NSString *)urlstring
{
    //Download the image located at the URL
    //This method is blocking
    NSURL *url = [NSURL URLWithString:urlstring];
    if (!url)
    {
        return nil;
    }
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
}

//Calculate a size that fits in another size while retaining its original proportions
+ (CGSize)fitSize: (CGSize)thisSize inSize: (CGSize)aSize
{
    CGFloat scale;
    CGSize newSize = thisSize;
    if (newSize.height && (newSize.height > aSize.height))
    {
        scale = aSize.height / newSize.height;
        newSize.width *= scale;
        newSize.height *= scale;
    }
    if (newSize.width && (newSize.width > aSize.width))
    {
        scale = aSize.width / newSize.width;
        newSize.width *= scale;
        newSize.height *= scale;
    }
    
    return newSize;
}

//Proportionately resize, completely fit in view, no cropping
+ (UIImage *)image: (UIImage *)image fitInSize: (CGSize) viewsize
{
    //calculate the fitted size
    CGSize size = [ImageHelper fitSize:image.size inSize:viewsize];
    
    UIGraphicsBeginImageContext(viewsize);
    
    //calculate any matting needed for image spacing
    float dwidth = (viewsize.width - size.width) / 2.0f;
    float dheight = (viewsize.height - size.height) / 2.0f;
    
    CGRect rect = CGRectMake(dwidth, dheight, size.width, size.height);
    [image drawInRect:rect];
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimg;
}

//No resize, may crop
+ (UIImage *)image: (UIImage *) image centerInSize: (CGSize) viewsize
{
    CGSize size = image.size;
    
    UIGraphicsBeginImageContext(viewsize);
    
    //Calculate the offset to ensure that the image center is set to the view center
    float dwidth = (viewsize.width - size.width) / 2.0f;
    float dheight = (viewsize.height - size.height) / 2.0f;
    
    CGRect rect = CGRectMake(dwidth, dheight, size.width, size.height);
    [image drawInRect:rect];
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimg;
}

//Fill every view pixel with no black borders, resize and crop if needed
+ (UIImage *) image: (UIImage *)image fillSize: (CGSize) viewsize
{
    CGSize size = image.size;
    
    //Choose the scale factor that requires the least scaling
    CGFloat scalex = viewsize.width / size.width;
    CGFloat scaley = viewsize.height / size.height;
    CGFloat scale = MAX(scalex, scaley);
    
    UIGraphicsBeginImageContext(viewsize);
    
    CGFloat width = size.width * scale;
    CGFloat height = size.height * scale;
    
    //Center the scaled image
    CGFloat dwidth = (viewsize.width - width) / 2.0f;
    CGFloat dheight = (viewsize.height - height) / 2.0f;
    CGRect rect = CGRectMake(dwidth, dheight, width, height);
    [image drawInRect:rect];
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimg;
}

+ (UIImage *) imageFromView: (UIView *) theView
{
    //Draw a view's contents into an image context
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *) grayscaleImage: (UIImage *)image
{
    CGSize size = image.size;
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    //Create a mono/gray color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil, size.width, size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpace);
    
    //Draw the image into the grayscale context
    CGContextDrawImage(context, rect, [image CGImage]);
    CGImageRef grayscale = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    //Recover the image
    UIImage *img = [UIImage imageWithCGImage:grayscale];
    CFRelease(grayscale);
    return img;
}

//指定宽度按比例缩
+ (UIImage *) imageCompressForWidthScale:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth{
    
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = height / (width / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) == NO){
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if(widthFactor > heightFactor){
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            
        }else if(widthFactor < heightFactor){
            
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        
        NSLog(@"scale image fail");
    }
    UIGraphicsEndImageContext();
    return newImage;
}

@end

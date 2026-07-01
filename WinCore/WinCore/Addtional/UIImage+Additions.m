//
//  UIImage+Additions.m
//  
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import "UIImage+Additions.h"
#import "NSBundle+Additions.h"

#define kUIImageLongLineLimit           120
#define kUIImageShortLintLimit          68
#define kUIImageForUploadMaxLength      1080
#define kUIImageForUploadUnHandleLength 10800
#define kWaterMarkLargeFontSizeRatio    0.0667
#define kWaterMarkNormalFontSizeRatio   0.0333

static void AddRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight) {
    
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        
		CGContextAddRect(context, rect);
		return;
    }
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth(rect) / ovalWidth;
    fh = CGRectGetHeight(rect) / ovalHeight;
    
    CGContextMoveToPoint(context, fw, fh / 2);
    CGContextAddArcToPoint(context, fw, fh, fw / 2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh / 2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw / 2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh / 2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

@implementation UIImage (Additions)

+ (UIImage *)imageForName:(NSString *)name {
    
    if ([name hasSuffix:@".png"] || [name hasSuffix:@".jpg"]) {
        
        name = [name substringToIndex:name.length - 4];
    }
    
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    if (image) {
        
        return image;
    }
    
    imagePath = [[NSBundle mainBundle] pathForResource:name ofType:@"jpg"];
    image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}

+ (UIImage *)scaledImageForName:(NSString *)name ofType:(NSString *)type {
    
    NSString *imagePath = [[NSBundle mainBundle] pathForScaledResource:name ofType:type];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}

+ (UIImage *)scaledImageForName:(NSString *)name ofType:(NSString *)type bundleName:(NSString *)bundleName {
    
    NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:bundleName];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *imagePath = [bundle pathForScaledResource:name ofType:type];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}

+ (UIImage *)scaleImage:(UIImage *)image scaleToSize:(CGSize)size {

    CGSize newSize = CGSizeMake(size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0f);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
  
+ (UIImage *)getSubImage:(UIImage *)img rect:(CGRect)rect {
    
    CGImageRef subImageRef = CGImageCreateWithImageInRect(img.CGImage, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));  
    if ([[UIScreen mainScreen] scale] == 2.0) {
        UIGraphicsBeginImageContextWithOptions(smallBounds.size, NO, 2.0);
    }
    else {
        UIGraphicsBeginImageContext(smallBounds.size);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);  
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];  
    UIGraphicsEndImageContext();  
    
    CGImageRelease(subImageRef);
    return smallImage;  
} 

+ (UIImage *)getSubImage:(UIImage *)img scale:(CGFloat)scale rect:(CGRect)rect {
    
    CGImageRef subImageRef = CGImageCreateWithImageInRect(img.CGImage, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));

    if (!CGSizeEqualToSize(smallBounds.size, rect.size)) {
        
        CGImageRelease(subImageRef);
        subImageRef = nil;
        int wOffset = smallBounds.size.width - rect.size.width;
        int hOffset = smallBounds.size.height - rect.size.height;
        rect.size.width = rect.size.width - wOffset;
        rect.size.height = rect.size.height - hOffset;
        subImageRef = CGImageCreateWithImageInRect(img.CGImage, rect);
        smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    }
    
    if ([[UIScreen mainScreen] scale] == 2.0) {
        UIGraphicsBeginImageContextWithOptions(smallBounds.size, NO, 2.0);
    }
    else {
        UIGraphicsBeginImageContext(smallBounds.size);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage *smallImage = [UIImage imageWithCGImage:subImageRef scale:scale orientation:UIImageOrientationUp];
    UIGraphicsEndImageContext();
    
    CGImageRelease(subImageRef);
    return smallImage;
}

+ (UIImage *)middleStretchableImageWithKey:(NSString *)key {
    
    UIImage *image = [UIImage imageForName:key];
    return [image stretchableImageWithLeftCapWidth:image.size.width/2 topCapHeight:image.size.height/2];
}

+ (UIImage *)middleStretchableImageWithOutSupportSkin:(NSString *)key {
    
    UIImage *image = [UIImage imageNamed:key];
    return [image stretchableImageWithLeftCapWidth:image.size.width/2 topCapHeight:image.size.height/2];
}

+ (UIImage *) scaleImage:(UIImage *)image toScale:(float)scaleSize {
    
    if ([[UIScreen mainScreen] scale] == 2.0) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize), NO, 2.0);
    }
    else {
        UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    }
    
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();  
    UIGraphicsEndImageContext();  
    return scaledImage;  
}  

+ (UIImage *) scaleImageForImage:(UIImage *)image toScale:(float)scaleSize {
    
    if ([[UIScreen mainScreen] scale] == 2.0) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize), NO, 2.0);
    }
    else {
        UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    }
    
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

+ (UIImage *)middleScaleImage:(UIImage *)image scaleToSize:(CGSize)size {
    
    float scaleSize = 0.0;
    float screenScale = [UIScreen mainScreen].scale;
    CGSize imagesize = [image size];
    if (imagesize.width >= imagesize.height) {
        scaleSize = size.height/imagesize.height * screenScale;
    }
    else {
        scaleSize = size.width/imagesize.width * screenScale;
    }
    
    UIImage *currentimage = [UIImage scaleImage:image toScale:scaleSize];
    CGRect currentfram = CGRectMake((currentimage.size.width - size.width) / 2, (currentimage.size.height - size.height) / 2, size.width, size.height);
    return [UIImage getSubImage:currentimage rect:currentfram];
}

+ (UIImage *)suitableScaleImage:(UIImage *)image scaleToSize:(CGSize)size {
    
    CGFloat screenScale = [UIScreen mainScreen].scale;
    CGSize imageSize = image.size;
    CGFloat realScale = 0.0f;
    UIImage *tmpImage = nil;
    CGFloat imageSizeMax = MAX(imageSize.width, imageSize.height);
    CGFloat imageSizeMin = MIN(imageSize.width, imageSize.height);
    
    if (imageSizeMin >= size.width) {
        
        if (imageSize.width <= imageSize.height) {
            
            realScale = size.width / imageSize.width * screenScale;
            UIImage *currentImage = [UIImage scaleImage:image toScale:realScale];
            tmpImage = [UIImage getSubImage:currentImage scale:screenScale rect:CGRectMake(0, (currentImage.size.height - size.height * screenScale) / 2.0f,
                                                                                           size.width * screenScale, size.height *screenScale)];
        }
        else {
            
            realScale = size.height / imageSize.height * screenScale;
            UIImage *currentImage = [UIImage scaleImage:image toScale:realScale];
            tmpImage = [UIImage getSubImage:currentImage scale:screenScale rect:CGRectMake((currentImage.size.width - size.width * screenScale) / 2.0f, 0,
                                                                                           size.width * screenScale, size.height * screenScale)];
        }
    }
    else {
        
        if (imageSizeMax > size.width) {
            
            if (imageSize.width < imageSize.height) {
                
                tmpImage = [UIImage getSubImage:image scale:screenScale rect:CGRectMake(0, (imageSize.height - size.height * screenScale ) / 2.0f,
                                                                                        size.width * screenScale, size.height *screenScale)];
            }
            else {
                
                tmpImage = [UIImage getSubImage:image scale:screenScale rect:CGRectMake((imageSize.width - size.width * screenScale) / 2.0f, 0,
                                                                                        size.width * screenScale, size.height * screenScale)];
            }
        }
        else {
            tmpImage = image;
        }
    }
    
    return tmpImage;
}

+ (UIImage *)scaleToSize:(UIImage *)image size:(CGSize)size {
    
    CGFloat width = CGImageGetWidth(image.CGImage);
    CGFloat height = CGImageGetHeight(image.CGImage);
    float verticalRadio = size.height * 1.0 / height;
    float horizontalRadio = size.width * 1.0 / width;
    float radio = 1;
    
    if (verticalRadio > 1 && horizontalRadio > 1) {
        radio = verticalRadio > horizontalRadio ? horizontalRadio : verticalRadio;
    }  
    else {
        radio = verticalRadio < horizontalRadio ? verticalRadio : horizontalRadio;     
    }  
    
    width = width*radio;  
    height = height*radio;
    int xPos = (size.width - width) / 2;
    int yPos = (size.height-height) / 2;
    
    if ([[UIScreen mainScreen] scale] == 2.0) {
        UIGraphicsBeginImageContextWithOptions(size, NO, 2.0);
    }
    else {
        UIGraphicsBeginImageContext(size);
    }
    
    [image drawInRect:CGRectMake(xPos, yPos, width, height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;  
} 

- (UIImage *)fixOrientation {
    
    if (self.imageOrientation == UIImageOrientationUp) {
        return self;
    }
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
            
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
            
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
            
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    
    switch (self.imageOrientation) {
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (UIImage *) zoomImageWithImage:(UIImage *)image {
    
    if (!image) {
        return image;
    }
    
    CGSize imageSize = image.size;
    int imageHeight = imageSize.height;
    int imageWidth = imageSize.width;
    float scale = 1.0;
    CGRect realRect = CGRectZero;
    float determin = 0.0;
    
    if (imageWidth > imageHeight) {
        
        if (imageWidth <= imageHeight * 3) {
           
            determin = [UIScreen mainScreen].scale * kUIImageLongLineLimit;
            if (imageWidth < determin) {
                return image ;
            }
            
            scale = imageWidth / determin;
            realRect.origin.x = 0;
            realRect.origin.y = 0;
            realRect.size.width = determin;
            realRect.size.height = imageHeight / scale;
        }
        else {
            
            determin = [UIScreen mainScreen].scale * kUIImageShortLintLimit;
            float longLine = [UIScreen mainScreen].scale * kUIImageLongLineLimit;
            scale = imageHeight > determin ? imageHeight / determin : 1.0;
            realRect.origin.x = (imageWidth / scale - longLine) / 2 > 0 ? (imageWidth / scale - longLine) / 2 : 0;
            realRect.origin.y = 0;
            realRect.size.width = imageWidth > longLine ? longLine : imageWidth;
            realRect.size.height = imageHeight > determin ? determin : imageHeight;
        }
    }
    else {
        
        if (imageHeight <= imageWidth * 3) {
            
            determin = [UIScreen mainScreen].scale * kUIImageLongLineLimit;
            if (imageHeight < determin) {
                return image;
            }
            
            scale = imageHeight / determin;
            realRect.origin.x = 0;
            realRect.origin.y = 0;
            realRect.size.width = imageWidth / scale;
            realRect.size.height = determin;
        }
        else {
            
            determin = [UIScreen mainScreen].scale * kUIImageShortLintLimit;
            float longLine = [UIScreen mainScreen].scale * kUIImageLongLineLimit;
            scale = imageWidth > determin ? imageWidth / determin : 1.0;
            realRect.origin.x = 0;
            realRect.origin.y = (imageHeight / scale - longLine) / 2 > 0 ? (imageHeight / scale - longLine) / 2 : 0;
            realRect.size.width = imageWidth > determin ? determin : imageWidth;
            realRect.size.height = imageHeight > longLine ? longLine : imageHeight;
        }
    }

    UIImage *tempImage = nil;
    if (scale > 1.0) {
        tempImage = [UIImage scaleImageForImage:image toScale:1 / scale];
    }
    else {
        tempImage = image;
    }

    return [UIImage getSubImage:tempImage scale:[[UIScreen mainScreen] scale] rect:realRect];
}

+ (UIImage *)zoomUploadImageWithdImage:(UIImage *)image {
    
    if (!image) {
        return image;
    }
    
    CGSize imageSize = image.size;
    float imageWidth = imageSize.width;
    float imageHeight = imageSize.height;
    float scale = 1.0;
    
    if (imageWidth >= kUIImageForUploadUnHandleLength || imageHeight >= kUIImageForUploadUnHandleLength) {
        return image;
    }
    
    if (imageHeight <= 3 * imageWidth || imageWidth <= 3 * imageHeight) {
        
        if (imageWidth <= kUIImageForUploadMaxLength) {
            return image;
        }

        scale = imageWidth / kUIImageForUploadMaxLength;
    }
    else if (imageHeight > 3 * imageWidth || imageWidth > 3 * imageHeight) {
        
        float shortLength = imageHeight > imageWidth ? imageWidth : imageHeight;
        if (shortLength <= kUIImageForUploadMaxLength) {
            return image;
        }
   
        scale = shortLength / kUIImageForUploadMaxLength;
    }
    
    return [UIImage scaleImageForImage:image toScale:1 / scale];
}

+ (UIImage *)addTextsAndScaleImage:(UIImage *)image scaleToSize:(CGSize)size time:(NSString *)time date:(NSString *)date empName:(NSString *)empName
                         storeName:(NSString *)storeName storeAddr:(NSString *)storeAddr {
    
    return [UIImage addTextsAndScaleImage:image scaleToSize:size time:time date:date empName:empName storeName:storeAddr
                                storeAddr:storeAddr withLuaValue:nil];
}

+ (UIImage *)addTextsAndScaleImage:(UIImage *)image scaleToSize:(CGSize)size time:(NSString *)time date:(NSString *)date empName:(NSString *)empName
                         storeName:(NSString *)storeName storeAddr:(NSString *)storeAddr withLuaValue:(NSString *)luaVlaue {
    
    CGFloat largeFontSize = size.width * kWaterMarkLargeFontSizeRatio;
    CGFloat fontSize = size.width * kWaterMarkNormalFontSizeRatio;
    UIFont *timeFont = [UIFont boldSystemFontOfSize:largeFontSize];
    UIFont *dateFont = [UIFont boldSystemFontOfSize:fontSize];
    UIFont *empNameFont = [UIFont boldSystemFontOfSize:fontSize];
    UIFont *storeNameFont = [UIFont boldSystemFontOfSize:fontSize];
    UIFont *storeAddrFont = [UIFont boldSystemFontOfSize:fontSize];
    UIFont *luaValueFont =[UIFont boldSystemFontOfSize:fontSize];
    
    if ([[UIScreen mainScreen] scale] == 2.0) {
        UIGraphicsBeginImageContextWithOptions(size, NO, 2.0);
    }
    else {
        UIGraphicsBeginImageContext(size);
    }
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    float contentMaxWidth = size.width - 40;
    CGSize timeSize = [time sizeWithFont:timeFont constrainedToSize:CGSizeMake(contentMaxWidth, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    CGSize dateSize = [date sizeWithFont:dateFont constrainedToSize:CGSizeMake(contentMaxWidth, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    CGSize empSize = [empName sizeWithFont:empNameFont constrainedToSize:CGSizeMake(contentMaxWidth, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    CGSize storeNameSize = [storeName sizeWithFont:storeNameFont constrainedToSize:CGSizeMake(contentMaxWidth, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    CGSize storeAddrSize = [storeAddr sizeWithFont:storeAddrFont constrainedToSize:CGSizeMake(contentMaxWidth, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    CGSize luaValueSize =[luaVlaue sizeWithFont:luaValueFont constrainedToSize:CGSizeMake(contentMaxWidth, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    CGFloat offset = 20;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextDrawingMode(context, kCGTextFillStroke);
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextSetLineWidth(context, 1.0);
    
    if (time && [time length] > 0) {
        
        CGFloat rectY1 = size.height - luaValueSize.height - storeAddrSize.height - storeNameSize.height;
        CGFloat rectY2 = rectY1 - dateSize.height - timeSize.height - offset;
        CGRect rect = CGRectMake((size.width - timeSize.width)/2,  rectY2, size.width, timeSize.height);
        
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            
            NSDictionary *dic1 = @{NSFontAttributeName : timeFont, NSForegroundColorAttributeName : [UIColor whiteColor],
                                   NSStrokeColorAttributeName : [UIColor blackColor]};
            [time drawInRect:rect withAttributes:dic1];
        }
        else {
            
            [time drawInRect:rect withFont:timeFont];
        }
    }
    
    if (date && [date length] > 0) {
        
        CGFloat rectY1 = size.height - luaValueSize.height - storeAddrSize.height - storeNameSize.height;
        CGFloat rectY2 = rectY1 - empSize.height - dateSize.height - offset;
        CGRect rect = CGRectMake((size.width - dateSize.width) / 2, rectY2, size.width, dateSize.height);
        
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            
            NSDictionary *dic2 = @{NSFontAttributeName : dateFont, NSForegroundColorAttributeName: [UIColor whiteColor],
                                   NSStrokeColorAttributeName : [UIColor blackColor]};
            [date drawInRect:rect withAttributes:dic2];
        }
        else {
            
            [date drawInRect:rect withFont:dateFont];
        }
    }
    
    if (empName && [empName length] > 0) {
        
        CGFloat rectY1 = size.height - luaValueSize.height - storeAddrSize.height - storeNameSize.height;
        CGFloat rectY2 = rectY1 - empSize.height - offset;
        CGRect rect = CGRectMake((size.width - empSize.width) / 2, rectY2, size.width, empSize.height);
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            
            NSDictionary *dic2 = @{NSFontAttributeName : empNameFont, NSForegroundColorAttributeName : [UIColor whiteColor],
                                   NSStrokeColorAttributeName : [UIColor blackColor]};
            [empName drawInRect:rect withAttributes:dic2];
        }
        else {
            [empName drawInRect:rect withFont:empNameFont];
        }
    }
    
    if (storeName && [storeName length] > 0) {
        
        CGFloat rectY = size.height - luaValueSize.height - storeAddrSize.height - storeNameSize.height - offset;
        CGRect rect = CGRectMake((size.width - storeNameSize.width) / 2, rectY, storeNameSize.width, storeNameSize.height);
        
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            
            NSDictionary *dic2 = @{NSFontAttributeName : storeNameFont, NSForegroundColorAttributeName : [UIColor whiteColor],
                                   NSStrokeColorAttributeName : [UIColor blackColor]};
            [storeName drawInRect:rect withAttributes:dic2];
        }
        else {
            
            [storeName drawInRect:rect withFont:storeNameFont];
        }
    }
    
    if (storeAddr && [storeAddr length] > 0) {
        
        CGRect rect = CGRectMake((size.width - storeAddrSize.width) / 2, size.height - luaValueSize.height - storeAddrSize.height - offset,
                                 size.width, storeAddrSize.height);
        
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            
            NSDictionary *dic2 = @{NSFontAttributeName : storeAddrFont, NSForegroundColorAttributeName : [UIColor whiteColor],
                                   NSStrokeColorAttributeName : [UIColor blackColor]};
            [storeAddr drawInRect:rect withAttributes:dic2];
        }
        else {
            
            [storeAddr drawInRect:rect withFont:storeAddrFont];
        }
    }
    
    if (luaVlaue && [luaVlaue length] > 0) {
        
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            
            NSDictionary *dic2 = @{NSFontAttributeName : luaValueFont, NSForegroundColorAttributeName : [UIColor whiteColor],
                                   NSStrokeColorAttributeName : [UIColor blackColor]};
            CGFloat luaOffset = size.height - luaValueSize.height - offset;
            NSArray *luaValueArray = [luaVlaue componentsSeparatedByString:@"\n"];
            for (NSString *luaString in luaValueArray) {
                
                CGSize luaStringSize = [luaString sizeWithFont:luaValueFont constrainedToSize:CGSizeMake(contentMaxWidth, MAXFLOAT)
                                                 lineBreakMode:NSLineBreakByCharWrapping];
                [luaString drawInRect:CGRectMake((size.width - luaStringSize.width) / 2, luaOffset, luaStringSize.width, luaStringSize.height)
                       withAttributes:dic2];
                luaOffset += luaStringSize.height;
            }
        }
        else {
            
            [luaVlaue drawInRect:CGRectMake((size.width - luaValueSize.width) / 2, size.height - luaValueSize.height - offset,
                                            luaValueSize.width, luaValueSize.height) withFont:luaValueFont];
        }
    }

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)imageFromColor:(UIColor *)color with:(CGRect)frame {
    
    CGRect rect = CGRectMake(0, 0, frame.size.width, frame.size.height);
    if ([[UIScreen mainScreen] scale] == 2.0) {
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, 2.0);
    }
    else {
        UIGraphicsBeginImageContext(rect.size);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (UIImage *)createImageWithColor:(UIColor *)color {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)mergeImage:(UIImage *)newImage toImage:(UIImage *)image width:(CGFloat)width height:(CGFloat)height {
    
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    [newImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *mergeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return mergeImage;
}

+ (UIImage *)mergeToWaterImage:(UIImage *)newImage withWaterHeadHeight:(CGFloat)headHeight withImage:(UIImage *)image
                         width:(CGFloat)width height:(CGFloat)height {

    CGSize size = CGSizeMake(width,newImage.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    [newImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    [image drawInRect:CGRectMake(0, headHeight, size.width, height)];
    UIImage *mergeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return mergeImage;
}

+ (UIImage *)imageWithImage:(UIImage *)image andTintColor:(UIColor *)tintColor {
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    UIRectFill(bounds);
    
    [image drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];

    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

+ (UIImage *)rotate90DegreesWithImage:(UIImage *)image {
    
    CGRect bounds = CGRectApplyAffineTransform(CGRectMake(0, 0, image.size.width, image.size.height), CGAffineTransformMakeRotation(M_PI_2));
    CGSize rotatedSize = bounds.size;

    UIGraphicsBeginImageContextWithOptions(rotatedSize, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context != NULL) {

        CGContextTranslateCTM(context, rotatedSize.width / 2.0, rotatedSize.height / 2.0);
        CGContextRotateCTM(context, M_PI_2);
        [image drawInRect:CGRectMake(-image.size.width / 2.0, -image.size.height / 2.0, image.size.width, image.size.height)];
    }
    
    UIImage *rotatedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return rotatedImage;
}

@end

//
//  UIImage+Eemporary.m
//  WinSFA
//
//  Created by wangzhiwei on 2018/5/11.
//  Copyright © 2018年 WinChannel. All rights reserved.
//
#import "UIImage+Eemporary.h"
#import "WSImagePathTable.h"

@implementation UIImage (Eemporary)

+ (UIImage *)imageWithAcvtWidgetValues:(NSArray *)array width:(CGFloat)width{
    
    CGFloat y_offset = 0 ;
    UIView *backGroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, 0)];
    for (NSString *object in array) {
//        SFA-25547
        //备注：由于多个选项的时候分隔符一样导致出错
        NSArray *nameValue = [object componentsSeparatedByString:WeChat_SEPARATOR];
        NSString *name = [nameValue firstObject];
        NSString *qstType = [nameValue objectAtIndex:1];
        NSString *qstValue = [nameValue objectAtIndex:2];
        NSString *orientation = [nameValue lastObject];
        
        if ([qstType isEqualToString:@"BN"] || [qstType isEqualToString:@"UR"]) {
            continue;
        }
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,y_offset,0,0)];
        [titleLabel setNumberOfLines:0];
        titleLabel.lineBreakMode = UILineBreakModeWordWrap;
        NSString *s = name;
        UIFont *font = [UIFont fontWithName:@"Arial" size:17];
        titleLabel.font = font;
        CGSize size = CGSizeMake(width,MAXFLOAT);
        
        CGSize labelsize = [s sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
        titleLabel.frame = CGRectMake(0,y_offset, labelsize.width + 40, labelsize.height + 5);
        [backGroundView addSubview:titleLabel];
        titleLabel.text = name;
        
       if ([qstType isEqualToString:@"DP"] || [qstType isEqualToString:@"P"] || [qstType isEqualToString:@"GS"]) {
            y_offset += titleLabel.height ;
            qstValue =  [[WSImagePathTable sharedTable] backImagePathQueryWithImageIDX:qstValue];
            NSArray *imageIDs = [qstValue componentsSeparatedByString:@"|"];
            for (NSString *imageID in imageIDs) {
                UIImage *img = nil;
                if  (imageID  && imageID.length > 0){
                    
                    NSString *filePath = [[SDImageCache sharedImageCache] imagePathFromKey:imageID];
                    if (filePath) {
                        NSData * imgData = [NSData dataWithContentsOfFile:filePath];
                        img = [UIImage sd_animatedGIFWithData:imgData];
                        
                    }
                    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, y_offset, width, width *0.5625 )];
                    if (img.size.height > img.size.width) {
                        imageView.frame = CGRectMake(0, y_offset, width, width * img.size.height/img.size.width);
                    }
                    imageView.image = img;
                    [backGroundView addSubview:imageView];
                    y_offset += imageView.height  + 5;
                }
            }
        }else{
            UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
            [contentLabel setNumberOfLines:0];
            contentLabel.lineBreakMode = UILineBreakModeWordWrap;
            contentLabel.textAlignment = NSTextAlignmentLeft;
            contentLabel.contentMode = UIViewContentModeCenter;
            contentLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            contentLabel.text = qstValue ;
            NSString *s = qstValue;
            UIFont *font = [UIFont fontWithName:@"Arial" size:17];
            contentLabel.font = font;
            CGSize size = CGSizeMake(width,MAXFLOAT);
            
            if ([orientation isEqualToString:@"1"]) {
                size = CGSizeMake(width - titleLabel.right - 30, MAXFLOAT);
                contentLabel.textAlignment = NSTextAlignmentRight;
            }else{
                y_offset += titleLabel.height;
            }
            CGSize labelsize2 = [s sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
            
            CGFloat height = labelsize2.height + 15.0 > titleLabel.height ? labelsize2.height + 15.0 : titleLabel.height;
            if ([orientation isEqualToString:@"1"]) {
                contentLabel.frame = CGRectMake(titleLabel.right + 30,y_offset, size.width, height);
            }else{
                contentLabel.frame = CGRectMake(0,y_offset, size.width, labelsize2.height + 15);
            }
            
            
            [backGroundView addSubview:contentLabel];
            y_offset +=  contentLabel.height;
        }
    }
    backGroundView.frame = CGRectMake(0, 0, width, y_offset);
    CGSize s = backGroundView.bounds.size;
    UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [backGroundView.layer renderInContext:context];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    backGroundView.layer.contents = nil;
    return image;
}

+ (UIImage *)imageWithString:(NSString *)string width:(CGFloat)width{
    
    CGFloat y_offset = 15 ;
    CGFloat margin = 15;
    
    UIView *backGroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, 0)];
    backGroundView.frame = CGRectMake(0, 0, width, [UIScreen mainScreen].bounds.size.height);
    backGroundView.backgroundColor = [UIColor whiteColor];
    
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
    [contentLabel setNumberOfLines:0];
    contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.contentMode = UIViewContentModeCenter;
    contentLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    contentLabel.text = string;
    NSString *stringValue = string;
    UIFont *font = [UIFont fontWithName:@"Arial" size:15];
    contentLabel.font = font;
    CGSize size = CGSizeMake(width - (2 * margin),MAXFLOAT);
    CGSize labelsize2 = [stringValue sizeWithFont:font
                                constrainedToSize:size
                                    lineBreakMode:NSLineBreakByWordWrapping];
    contentLabel.frame = CGRectMake(margin,y_offset, size.width, labelsize2.height);
    [backGroundView addSubview:contentLabel];
    contentLabel.backgroundColor = [UIColor whiteColor];
    backGroundView.frame = CGRectMake(0, 0, width, contentLabel.height + y_offset *2);
    
    
    CGSize bSize = backGroundView.bounds.size;
    UIGraphicsBeginImageContextWithOptions(bSize, NO, [UIScreen mainScreen].scale);
    
    [backGroundView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    backGroundView.layer.contents = nil;
    
    return image;
}


@end

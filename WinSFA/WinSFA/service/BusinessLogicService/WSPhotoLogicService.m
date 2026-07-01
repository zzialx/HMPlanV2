//
//  WSPhotoLogicService.m
//  WinSFA
//
//  Created by yang on 17/4/6.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSPhotoLogicService.h"
#import "WSEnvrionment.h"

@implementation WSPhotoLogicService

#pragma mark - private method


#pragma mark - public method

+ (NSString *)getAcvtImageIndexWithFC:(NSString *)fc acvtMD5:(NSString *)acvtMD5 acvtQstId:(NSString *)acvtQstId {
    
    NSString *lastStrMd5 = [[NSString stringWithFormat:@"%@%@", acvtMD5, acvtQstId] md5];
    
    return [NSString stringWithFormat:@"%@_%@", fc, lastStrMd5];
    
}

+ (NSArray *)getPhotoNameArrayByImageIDArray:(NSArray *)imageIDArray {
 
    NSMutableArray *imageNamesArrary = [NSMutableArray array];
    
    for (NSString *imageId in imageIDArray) {
        /*
         1.对于回显的imageId 是这样的:包含imageId 和 请求网络的路径(989dae7ad1c8f5cb550c2b61f1185070.JPEG@/media/dot3Cdot3C172dot4D23dot4D3dot4D91dot3Crootdot2Bphotosdot2B2016-06-24dot2B989dae7ad1c8f5cb550c2b61f1185070dot4DJPEG.JPEG)
         进行分割
         2.对于拍照的imageId 是这样的(989dae7ad1c8f5cb550c2b61f1185070)
         
         3.isOld = YES时，仅包含后台回显的imageid,且不用拼接.JPEG
         
         注：后台回显包含两种格式：
         旧：photoKey@url
         新：imageIndex@photoKey@url
         */
        NSString *imageName = nil;
        
        NSString *saasStr = @"";
        NSString *appId = @"";
        NSString *dateStr = @"";
        
        
        if ([WSEnvrionment getUseAliyun]) {
            saasStr = @"Saas/";
            appId =  [NSString stringWithFormat:@"%@/", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]] ;
            dateStr = [NSString stringWithFormat:@"%@/",[WSCurrentTime getDateString]];
        }
        
        if ([imageId rangeOfString:@"@/media"].location != NSNotFound) {
            NSString *tmpImageId = [WSPhotoLogicService getPhotoKeyFromServerRedisValue:imageId];
//            YIHAIKERRY-1720
//            SFA 益海嘉里深圳【IOS】,手机端拍照上传阿里云上的照片后缀和发送到后台的照片后缀不一致
            imageName = [NSString stringWithFormat:@"%@%@%@%@%@",saasStr,appId,dateStr,tmpImageId, PHOTO_JPG_SUFFIX];
        }else {
            imageName = [NSString stringWithFormat:@"%@%@%@%@%@",saasStr,appId,dateStr,imageId, PHOTO_JPG_SUFFIX];
        }
        
        if (imageName) {
            [imageNamesArrary addObject:imageName];
        }
        
    }
    
    return imageNamesArrary;
}

/*
 注：后台回显包含两种格式：
 旧：photoKey@url
 新：imageIndex@photoKey@url
 两种格式都支持
 */
+ (NSString *)getImageIndexFromServerRedisValue:(NSString *)redisValue {
    
    NSArray *strArray = [redisValue componentsSeparatedByString:@"@"];
    if (strArray.count == 3) {
        
        if ([strArray[0] length] > 0) {
            return strArray[0];
        }
    }
    
    return nil;
    
}


+ (NSString *)getPhotoKeyFromServerRedisValue:(NSString *)redisValue {
    
    NSArray *strArray = [redisValue componentsSeparatedByString:@"@"];
    if (strArray.count == 3) { //新：imageIndex@photoKey@url
        if ([strArray[1] length] > 0) {
            return strArray[1];
        }
    }else if (strArray.count == 2) {  // 旧：photoKey@url
        if ([strArray[0] length] > 0) {
            return strArray[0];
        }
    }else if (strArray.count == 1) {
       
        if ([strArray[0] length] > 0) {
                return strArray[0];
            }
    }
    
    return nil;
}

+ (NSString *)getPhotoURLFromServerRedisValue:(NSString *)redisValue {
    
    NSArray *strArray = [redisValue componentsSeparatedByString:@"@"];
    if (strArray.count == 3) { //新：imageIndex@photoKey@url
        if ([strArray[2] length] > 0) {
            return strArray[2];
        }
    }else if (strArray.count == 2) {  // 旧：photoKey@url
        if ([strArray[1] length] > 0) {
            return strArray[1];
        }
    }
      // MNXHJH-75 引发  YIHAIKERRY-2382 所以都撤销

//    else if (strArray.count == 1) {
//        // YIHAIKERRY-2382
//        //        益海嘉里-上海：我的--我的信息：回显图片显示错误
//        if ([strArray[0] length] > 0) {
//            return strArray[0];
//        }
//    }
    
    return nil;
}

+ (NSString *)getFCFromImageIndex:(NSString *)imageIndex {
    
    NSRange range = [imageIndex rangeOfString:@"_" options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
        NSString *fc = [imageIndex substringToIndex:range.location];
        if ([fc length] > 0) {
            return fc;
        }
    }
    
    return nil;
    
}

+ (BOOL)isServerRedisPhoto:(NSString *)imageID {
    NSArray *imageKeyArray = [imageID componentsSeparatedByString:@"@"];
    if ([imageKeyArray count] > 1) {
        return YES;
    }
    
    return NO;
}
+ (NSString *)getImageTitleFromServerRedisValue:(NSString *)redisValue{
    NSArray *imageKeyArray = [redisValue componentsSeparatedByString:@"@"];
    if ([imageKeyArray count] > 1) {
        return imageKeyArray[0];
    }
}
@end

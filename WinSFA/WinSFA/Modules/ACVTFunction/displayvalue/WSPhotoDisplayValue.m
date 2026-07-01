//
//  WSPhotoDisplayValue.m
//  WinSFA
//
//  Created by yang on 15/9/2.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSPhotoDisplayValue.h"
#import "WSAcvtModel.h"
#import "WSImagePathTable.h"
#import "WSDataSourceManager.h"
#import "I_W_BuildInfo.h"
//===========================================================================================================================================

#pragma mark - 照片显示数值 延展(工具)
@interface WSPhotoDisplayValue (Tools)

#pragma mark - 照片url处理方法 urlStr:链接字符串
- (NSMutableArray *)photoUrlHandle:(NSString *)urlStr;

@end
//===========================================================================================================================================

#pragma mark - 照片显示数值
@implementation WSPhotoDisplayValue

//MN-1287 蒙牛(ios)_拜访_计划内门店_陈列管理_点击特仑苏-点击堆头-成功图像不显示
- (NSObject *)getDefaultValue:(NSObject<I_W_BuildInfo> *) buildInfo
{
    NSString *redisValue = [buildInfo getDefaultValue];
    if(redisValue.length > 0)
        return [self photoUrlHandle:redisValue];
    return nil;
}

- (NSObject *)getServerRedisValue:(NSObject<I_W_BuildInfo> *)buildInfo
{
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    NSString *redisValue = nil;
    if (!model.isNewAddAcvt)
    {
        NSString *value = [model getAcvtDisValueByAcvtQstId:[buildInfo getAcvtQstId]];
        if (value && [value length] > 0)
            redisValue = value;
    }
    return [self photoUrlHandle:redisValue];;
}

- (NSObject *)getNativeDBValue:(NSObject<I_W_BuildInfo> *)buildInfo
{
    WSAcvtModel *baseModel = nil;
    NSMutableArray *imagePathArray = nil;
    if ([[WSDataSourceManager sharedInstance].currentActiveModel isKindOfClass:[WSAcvtModel class]])
    {
        baseModel = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
        //   YIHAIKERRY-2877
        //   益海嘉里-深圳：【ios】：专项检查：拍照保存后查看，此时照片删除，保存，再次查看，图片还是显示
        id imageIndex = baseModel.qstDBValueDictionary[[buildInfo getAcvtQstId]];
        NSArray *imageObjectArray;
        if ([imageIndex isKindOfClass:[NSArray class]]) {
            // YIHAIKERRY-2768
            // 益海嘉里-深圳：【ios】门店拜访：专项检查：填写部分必填问题保存后再次填写剩余必填问题，点击上传闪退
            //备注:当点击保存的之后返回的imageIndex 是 字符串 ，当没有保存的时候imageIndex 是一个数组里面保存的是imageId ，所以我们要拼接对应的imageIDX
            NSString *imageIDX;
            NSString *lastStrMd5 = [[NSString stringWithFormat:@"%@%@", [baseModel md5], [buildInfo getAcvtQstId]] md5];
            imageIDX = [NSString stringWithFormat:@"%@_%@", [baseModel currentFuncs].fc, lastStrMd5];
            if ([imageIDX length] > 0)
                imageObjectArray = [[WSImagePathTable sharedTable] queryWithImageIDX:imageIDX];
            
        } else {
            if ([imageIndex length] > 0)
                imageObjectArray = [[WSImagePathTable sharedTable] queryWithImageIDX:imageIndex];
            
        }

        if (imageObjectArray && [imageObjectArray count] > 0)
        {
            imagePathArray = [[NSMutableArray alloc] init];
            for (WSImagePathObject *object in imageObjectArray)
            {
                NSString *imageID = object.img_path;
                if (imageID && [imageID length] > 0)
                    [imagePathArray addObject:imageID];
            }
        }
    }
    
    if ([imagePathArray count] > 0)
        return imagePathArray;
    
    return nil;
}

@end
//===========================================================================================================================================

#pragma mark - 照片显示数值 延展(工具)
@implementation WSPhotoDisplayValue (Tools)

#pragma mark - 照片url处理方法 urlStr:链接字符串
- (NSMutableArray *)photoUrlHandle:(NSString *)urlStr
{
    NSArray *imageUrlArray = [urlStr componentsSeparatedByString:@","];
    NSMutableArray *urlArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < imageUrlArray.count; ++i) {
        
        NSString *url = [imageUrlArray objectAtIndex:i];
        url = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([url containsString:@"@"]) {
            [urlArray addObject:url];
        }
    }
    
    return urlArray;
}

@end
//===========================================================================================================================================


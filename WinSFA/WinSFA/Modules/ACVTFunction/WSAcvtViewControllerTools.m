//
//  WSAcvtViewControllerTools.m
//  WinSFA
//
//  Created by yuanji on 2019/4/12.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import "WSAcvtViewControllerTools.h"
//==========================================================================================================================================================================

#pragma mark - 调查问卷视图管理器工具
@implementation WSAcvtViewControllerTools

#pragma mark - 缩放图片方法 image:原图 newSize:缩放尺寸 返回值:处理完毕的图片
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - 通过md5删除保存的问卷数据方法
- (void)removeSaveAcvtDataWithMD5:(NSString *)md5 {
    
    if (!md5) {
        return;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *genId = nil;
    if ([userDefaults objectForKey:SAVEACVTDATA]) {
        genId = [NSMutableDictionary dictionaryWithDictionary:[userDefaults objectForKey:SAVEACVTDATA]];
    }
    if ([genId objectForKey:md5]) {
        [genId removeObjectForKey:md5];
    }
    [userDefaults setObject:genId forKey:SAVEACVTDATA];
    [userDefaults synchronize];
}

@end
//==========================================================================================================================================================================

//
//  WSAcvtViewControllerTools.h
//  WinSFA
//
//  Created by yuanji on 2019/4/12.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
//==========================================================================================================================================================================

#pragma mark - 调查问卷视图管理器工具
@interface WSAcvtViewControllerTools : NSObject

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;  //缩放图片方法 image:原图 newSize:缩放尺寸 返回值:处理完毕的图片
- (void)removeSaveAcvtDataWithMD5:(NSString *)md5;                          //通过md5删除保存的问卷数据方法 md5:标示

@end
//==========================================================================================================================================================================

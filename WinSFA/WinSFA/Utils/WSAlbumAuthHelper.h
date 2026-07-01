//
//  WSAlbumAuthHelper.h
//  WinSFA
//
//  Created by yuanji on 2018/9/17.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WSAlbumAuthHelper;
typedef void (^albumAuthHelperAuthorizeBlock)(WSAlbumAuthHelper *albumAuthHelper, BOOL isAuthorize);

@interface WSAlbumAuthHelper : NSObject

+ (BOOL)isAlbumAuthorize;
+ (void)savePhotoWithImage:(UIImage *)image;
- (void)authAlbumWithBlock:(albumAuthHelperAuthorizeBlock)authorizeBlock;

@end

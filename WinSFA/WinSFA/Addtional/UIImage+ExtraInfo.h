//
//  UIImage+ExtraInfo.h
//  WinSFA
//
//  Created by macbook  on 2018/6/8.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage(ExtraInfo)
+ (UIImage *)updateImageExif: (UIImage * )image mesArray: (NSArray *)mesArray;
@end

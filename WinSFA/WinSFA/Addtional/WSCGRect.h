//
//  WSCGRect.h
//  WinSFA
//
//  Created by macbook  on 2018/6/28.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSCGRect : NSObject
+(CGRect)caculateNewRect:(CGRect)showRect previewRect:(CGRect)previewRect imageSize:(CGSize)size;
@end

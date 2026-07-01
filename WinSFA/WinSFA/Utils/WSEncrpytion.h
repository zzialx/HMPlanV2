//
//  Encrpytion.h
//  jiami_demo
//
//  Created by Nemo on 13-12-13.
//  Copyright (c) 2013年 Nemo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSEncrpytion : NSObject

//加密
+(NSString *) encryptUseDES:(NSString *)plainText key:(NSString *)key;
@end

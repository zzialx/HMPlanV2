//
//  DecompressUtil.h
//  WinchannelMobile_iphone
//
//  Created by Chen Angus on 11-7-2.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <zlib.h>

@interface DecompressUtil : NSObject

+ (NSData *)uncompressZippedData:(NSData *)compressedData;
@end

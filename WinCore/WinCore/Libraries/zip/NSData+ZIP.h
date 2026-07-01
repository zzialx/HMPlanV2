//
//  NSData+ZIP.h
//  testWinSFA
//
//  Created by Cai Lei on 12/5/12.
//  Copyright (c) 2012 com.cailei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (ZIP)

- (NSData *)unzip;
- (NSData *)zip;

@end

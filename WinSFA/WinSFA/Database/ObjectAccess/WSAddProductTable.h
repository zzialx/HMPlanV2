//
//  WSAddProductTable.h
//  WinSFA
//
//  Created by zhangke on 14/8/14.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WSAddProductTable : WSSqliteUtil

+ (WSAddProductTable*)sharedTable;

- (void)cleanOldData;

- (NSArray*)queryAllProduct;


@end

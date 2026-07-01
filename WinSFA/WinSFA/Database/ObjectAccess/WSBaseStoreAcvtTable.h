//
//  WSBaseStoreAcvtTable.h
//  WinSFA
//
//  Created by weida on 15/12/18.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSSqliteUtil.h"

@interface WSBaseStoreAcvtTable : WSSqliteUtil

+ (WSBaseStoreAcvtTable *)sharedTable;

- (NSInteger)queryUploadCountLimitWithStoreId:(NSString *)storeId acvtId:(NSString *)acvtId;

@end

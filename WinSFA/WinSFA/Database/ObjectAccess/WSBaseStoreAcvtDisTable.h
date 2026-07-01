//
//  WSBaseStoreAcvtDisTable.h
//  WinSFA
//
//  Created by heju on 16/2/23.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSqliteUtil.h"

@interface WSBaseStoreAcvtDisTable : WSSqliteUtil


+ (WSBaseStoreAcvtDisTable *)sharedTable;

- (void)insertAcvtDisDatasWith:(NSArray *)acvtdiss;

@end

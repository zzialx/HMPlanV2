//
//  StoreAcvtDisArray.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-4-9.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
//#define STOREACVTDIS @ "storeacvtdis"

@interface WSStoreAcvtDisArray : NSObject

@property (nonatomic, strong) NSMutableArray *storeAcvtDisArray;

- (id)initWithObject:(id)object;

-(id)initWithObject:(id)object andKey:(NSString *)parserkey;

- (NSString *)getAcvtDisValueByAcvtId:(NSString *)acvtID acvtQstId:(NSString *)acvtQstId storeId:(NSString *)storeId;


@end

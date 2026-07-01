//
//  AcvtManager.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSAcvtDisBean.h"
#import "WSAcvtBean.h"

@interface WSAcvtManager : NSObject <NSCopying>
{}
// /**根据门店id，查询回显项*/
// -(NSArray*)getFromSId:(NSString*)sId;
// /**根据门店id和acvtQstId和value，查询回显项是否存在*/
// -(BOOL)isFromSIdAndAcvtQstIdAndValue:(NSString*)sId AcvtQstId:(NSString*)acvtQstId
//                               Value:(NSString*)value;
//
// /**根据门店id和acvtQstId，查询回显项*/
// -(AcvtDisBean*)getFromSIdAndAcvtQstId:(NSString*)sId AcvtQstId:(NSString*)acvtQstId;
//
// -(AcvtBean*)getFromAcvtId:(NSString*)acvtId;
//
// -(NSArray*)getFromTyp:(NSString*)typ;
//
// -(AcvtBean*)getFromTypAndAcvtId:(NSString*)typ AcvtId:(NSString*)acvtId;
//
// -(NSArray*)getFromObj:(NSString*)typ;
@end

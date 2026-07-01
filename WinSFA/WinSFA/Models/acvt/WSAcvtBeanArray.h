//
//  AcvtBeanArray.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSAcvtBean.h"
#define ACVTS @ "acvt"

//所有acvt的集合，需要通过WSFuncsBean 的filter关联typ字段查找到对应的acvt

@interface WSAcvtBeanArray : NSObject
{
    NSMutableArray *acvtArray;
}
@property (nonatomic, strong) NSMutableArray *acvtArray;

- (id)initWithObject:(id)object;
- (NSArray *)getAcvtsWithFilter:(NSString *)filter;
//辉瑞ECALL增加，ECALL的返回数据会有多条acvtID一样的acvtBean,此方法为了过滤重复的acvt
- (NSArray *)getDistinctAcvtsWithFilter:(NSString*)filter;
- (WSAcvtBean *)getAcvtById:(NSString *)anAcvtId;
- (NSArray *)getAcvtsById:(NSString *)anAcvtId;

-(WSAcvtBean*)getAcvtWithFilter:(NSString*)filter withAcvtCode:(NSString*)acvtCode;
-(NSArray *)getAcvtArrayWithFilter:(NSString*)filter withAcvtCode:(NSString*)acvtCode;

-(NSArray*)getAcvtsWithFilter:(NSString*)filter withEmpid:(NSString*)empid;


- (WSAcvtBean *)getAcvtByQstCod:(NSString *)qstCod;

- (WSAcvtBean *)matchAcvtCodeWithFilter:(NSString *)filter;

@end

//
//  EmpAcvtDisArray.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-3-27.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define EMPACVTDIS @ "empacvtdis"

@interface WSEmpAcvtDisArray : NSObject

@property (nonatomic, strong, readonly) NSMutableArray *m_empAcvtDisArray;

- (id)initWithObject:(id)object;

@end

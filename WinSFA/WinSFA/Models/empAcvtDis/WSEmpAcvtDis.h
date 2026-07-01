//
//  EmpAcvtDis.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-3-27.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSEmpAcvtDis : NSObject

@property (nonatomic, copy) NSString    *m_empId;
@property (nonatomic, copy) NSString    *m_acvtId;
@property (nonatomic, copy) NSString    *m_qstId;
@property (nonatomic, copy) NSString    *m_disValue;
@property (nonatomic, copy) NSString    *m_p;

- (id)initWithObject:(id)object;

@end

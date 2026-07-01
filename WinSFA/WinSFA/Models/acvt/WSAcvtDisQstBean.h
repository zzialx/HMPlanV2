//
//  AcvtDisBean.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSAcvtDisQstBean : NSObject
@property (nonatomic, strong)  NSString  *m_empId;
@property (nonatomic, strong) NSString *gen_id;
@property (nonatomic, strong) NSString *submitEmpId;
@property (nonatomic, strong) NSString *storeIdForQst;
@property (nonatomic, strong) NSMutableArray *m_p;
@property (nonatomic, strong) NSString *acvtId;
@property (nonatomic, strong) NSString *qstId;
@property (nonatomic, strong) NSString *qstValue;


- (id)initWithObject:(id)object;
@end

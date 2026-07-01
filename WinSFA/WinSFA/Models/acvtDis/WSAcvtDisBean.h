//
//  WSAcvtDisBean.h
//  WinSFA
//
//  Created by heju on 15/8/21.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WinSFA.h"

#import "WSAcvtDisBean.h"

#import "WSAcvtDisQstBean.h"

 

@interface WSAcvtDisBean : NSObject

@property (nonatomic, strong) NSString *empId;
@property (nonatomic, strong) NSString *gen_id;
@property (nonatomic, strong) NSString *acvtId;
@property (nonatomic, strong) NSString *submitEmpId;
@property (nonatomic, strong) NSString *storeId;

@property (nonatomic, strong) NSMutableArray *acvtDisQsts;

- (id)initWithObject:(id)object;

- (void)addQstDisBean:(WSAcvtDisQstBean *)qst;

@end

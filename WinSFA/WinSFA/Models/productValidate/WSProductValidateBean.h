//
//  WSProductValidateBean.h
//  WinSFA
//
//  Created by yang on 15/11/5.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSBaseBean.h"

@interface WSProductValidateBean : WSBaseBean

@property (nonatomic, copy, readonly) NSString *type;

@property (nonatomic, copy, readonly) NSString *group;

@property (nonatomic, copy, readonly) NSString *prodId;

@property (nonatomic, copy, readonly) NSString *fenzhi;

@property (nonatomic, copy, readonly) NSString *tip;

@end

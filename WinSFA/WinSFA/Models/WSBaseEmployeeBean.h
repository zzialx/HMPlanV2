//
//  WSBaseEmployeeBean.h
//  WinSFA
//
//  Created by winchannel on 15/12/28.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "I_W_OptionDataItem.h"
@interface WSBaseEmployeeBean : NSObject<I_W_OptionDataItem>

@property (nonatomic, strong) NSString *empId;
@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *pid;

- (id)initWithObject:(id)object;

@end

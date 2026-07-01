//
//  WSOrgBean.h
//  WinSFA
//
//  Created by heju on 16/9/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WSBaseOrg.h"

#import "I_W_OptionDataItem.h"

#import "I_W_Children_DataSource.h"

@interface WSOrgBean : WSBaseOrg <I_W_OptionDataItem,I_W_Children_DataSource>

@property (nonatomic,copy) NSString *orgId;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,strong) NSString *parentId;
@property (nonatomic,copy) NSString *orgType;
@property (nonatomic,copy) NSString *level;
@property (nonatomic,copy) NSString *empId;
@property (nonatomic,copy) NSMutableArray *childen;
@property (nonatomic,assign) BOOL status;
@property (nonatomic,strong)NSMutableArray *selectedChildren;
@property (nonatomic,weak) WSOrgBean *parentOrgBean;
@property (nonatomic,assign)NSInteger selectedChildCount;

- (id)initWithObject:(id)object;

@end

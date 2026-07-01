//
//  WSVisitedMenuBean.h
//  WinSFA
//
//  Created by yang on 15/11/27.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSBaseBean.h"

@interface WSVisitedMenuBean : WSBaseBean

@property (nonatomic, copy, readonly) NSString *store_id;

@property (nonatomic, copy, readonly) NSString *pfc;

@property (nonatomic, copy, readonly) NSString *empId;

@property (nonatomic, copy, readonly) NSString *func_code;


@end

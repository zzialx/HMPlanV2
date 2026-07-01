//
//  WSOthersAttendanceBean.h
//  WinSFA
//
//  Created by xiajl on 15/6/12.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSOthersAttendanceBean : NSObject

@property (nonatomic,copy)NSString *ODTYPE_NAME;
@property (nonatomic,copy)NSString *biz_date;
@property (nonatomic,copy)NSString *atdc_value;
@property (nonatomic,assign)NSInteger ODTIME_ID;
@property (nonatomic,copy)NSString *ODTIME_NAME;
@property (nonatomic,assign)NSInteger empId;
@property (nonatomic,copy)NSString *DOC_DATE;
@property (nonatomic,assign)NSInteger ODTYPE_ID;

- (id)initWithObjec:(id)object;
@end
